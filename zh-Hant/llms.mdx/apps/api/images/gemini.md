# Gemini 圖片介面

本節採用 Gemini GenerateContent 原生 `contents/parts` 格式。生成與編輯要求模型具備圖像輸出能力；普通文字模型不會因為添加參數獲得生圖能力。先完成一次單張任務，再增加數量或接入智慧代理。

## 請求格式與參數

| API       | 請求格式                                               | 主要參數                                             | 詳細文件                                   |
| --------- | -------------------------------------------------- | ------------------------------------------------ | -------------------------------------- |
| 文字生圖      | `POST /v1beta/models/{model}:generateContent`，JSON | `contents[].parts[].text`、`generationConfig`     | [生成參數與四語言程式碼](/simidoc/zh-Hant/apps/api/images/gemini/generate)              |
| 編輯 / 以圖生圖 | 同一 `generateContent` 端點                            | `text` 與獨立圖片 Part：`inlineData` 或模型支援的 `fileData` | [編輯參數與四語言程式碼](/simidoc/zh-Hant/apps/api/images/gemini/edits)                 |
| 圖片理解      | 同一 `generateContent` 端點                            | 圖片與問題；目標是文字分析而非圖片輸出                              | [Gemini 媒體識別](/simidoc/zh-Hant/apps/api/chat/gemini-media) |

文生圖只放文字；編輯加入參考圖片並分別說明要保留和修改的內容。風格轉換、背景替換和多圖組合屬於編輯目標，不是獨立的 `/images/edits` 路徑。GenerateContent 的 `contents`、`candidates` 與 Interactions 的 `input`、`steps`、`response_format` 不同，不能混寫。

### 圖片規格

本協議支援時在 `generationConfig.imageConfig.aspectRatio` 設定比例，例如 `1:1`；在 `generationConfig.imageConfig.imageSize` 設定模型接受的解析度，如 `1K`、`2K`、`4K`。這些值不是所有 Gemini 圖像模型的共同能力，也不能替換成 OpenAI 的 `size`。實際像素與可用比例、模型版本相關；回傳格式由實際 MIME 判斷。

| 本站三檔按張計費 | 請求尺寸最長邊            | 像素例子      |
| -------- | ------------------ | --------- |
| 1K       | ≤ 1024 像素          | 1024×1024 |
| 2K       | > 1024 且 ≤ 2048 像素 | 1536×1024 |
| 4K       | > 2048 像素          | 2560×1440 |

此表是本站特定按張模型的計費口徑，不是 Google 對解析度名稱的統一定義。只有[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)明確使用該規則時才適用；按 Token 計費或其他價格規則不套用此表。更高解析度不保證文字或細節正確，模型不支援目標規格時應報錯，不擅自降檔。詳見[圖片規格與計費總覽](/simidoc/zh-Hant/apps/api/images)。

## 回傳參數

| 回傳欄位                                           | 含義與處理                                |
| ---------------------------------------------- | ------------------------------------ |
| `candidates[]`                                 | 候選列表；過濾或失敗時可能沒有可用圖片。                 |
| `candidates[].content.parts[]`                 | 按順序遍歷文字與圖片，不能假設第一項就是圖片。              |
| `parts[].inlineData.mimeType` / `.data`        | 實際圖片 MIME 與純 Base64；按 MIME 選擇副檔名並解碼。 |
| `parts[].thought` / `.thoughtSignature`        | 不把思考中間圖當最終圖；多輪編輯保留模型回傳的不透明簽名。        |
| `candidates[].finishReason` / `promptFeedback` | 檢查是否正常完成及是否被過濾，不能僅憑 HTTP 200 宣稱成功。   |
| `usageMetadata`                                | 可選用量資訊，具體費用仍以適用價格規則與記錄為準。            |

## 呼叫範例

### 準備配置

在 [API 金鑰管理](https://api.dwchainless.com/keys)建立金鑰，從[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)複製當前可用且支援 GenerateContent 圖像輸出的完整模型 ID，核對分組、額度和編輯能力。可直接在範例程式碼中填寫 API\_URL、API\_KEY 和 MODEL：

| 變數             | 用途                                                 |
| -------------- | -------------------------------------------------- |
| `API_KEY`      | 必填；直接在範例中填寫，不放進提示詞、程式碼、截圖或 Git。                    |
| `MODEL`        | 必填；選定的 Gemini 圖像模型，作為路徑中的模型名稱。                     |
| `API_URL`      | 完整請求位址；範例使用閘道 `https://api.dwchainless.com`。       |
| `IMAGE_BASE64` | 編輯範例中換成已授權圖片的純 Base64（不含 `data:` 前綴）；格式與尺寸須符合所選模型。 |

[生成範例](/simidoc/zh-Hant/apps/api/images/gemini/generate)和[編輯範例](/simidoc/zh-Hant/apps/api/images/gemini/edits)均有 Python、Node.js、curl、Go。先選一種語言，使用一次非串流呼叫。將 Python 程式碼儲存為 `generate.py` 或 `edit.py`，用 `python3 generate.py` 或 `python3 edit.py` 執行；Node.js 範例使用頂層 await（ESM），儲存為 `generate.mjs` 或 `edit.mjs`，用 `node generate.mjs` 或 `node edit.mjs` 執行。

### 智慧代理生成 Demo

智慧代理須能執行本地指令碼並檢查回傳結果。此流程不安裝遠端 Skill，也不改既有連線；只有文字對話能力的用戶端不能直接執行。

```text
Read this Gemini protocol page and the GenerateContent image generation reference first.
Use the configured SimiRouter request URL in API_URL (default gateway
https://api.dwchainless.com) and MODEL. Set API_KEY directly in the example; never
print, paste, commit, or store it in source files. For this one approved task, call POST
/v1beta/models/{model}:generateContent once, non-streaming, Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. with a text Part describing a calm blue library with a small robot reading,
watercolor, no lettering. Request one image; use imageConfig aspectRatio=1:1 and
imageSize=1K only if the model supports them. Do not invent an n parameter or mix
Interactions fields into GenerateContent. After the response, read only completed,
non-thought inlineData from parts; decode the Base64 in memory and report any unmet
requirement; do not write an image file. Do not switch providers/models/billing groups,
increase size/count, write files, install remote skills, or retry an ambiguous failure
without approval. Report a redacted error instead of false success.
```

### 智慧代理編輯 Demo

只讀取已授權的參考圖，先檢查個人資訊或商業機密。多輪編輯需要模型回傳的完整上下文，不能隨意丟棄簽名；“保留”要求不保證像素級一致。

```text
Read this Gemini protocol page and its image editing reference first. Use the existing
API_KEY, MODEL and configured SimiRouter request URL; never reveal credentials or change
the existing connection. Read only the authorized local image, encode it as pure Base64,
and put it in IMAGE_BASE64. Submit its inlineData Part alongside the text instruction
through POST /v1beta/models/{model}:generateContent. Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. Keep the subject and layout; change only the background to pale blue. Request one
image, non-streaming; use aspectRatio=1:1 and imageSize=1K only if supported. Do not use
OpenAI multipart or mask fields. After the response, read only completed, non-thought
inlineData from parts; decode the Base64 in memory and report any unmet requirement; do
not write an image file. Preserve opaque signatures for later turns. Do not upload
unrelated files, overwrite results, change model/size/count/provider, install remote
skills, or retry automatically. Ask before any additional paid request.
```

## 儲存與完成標準

* 檢查 HTTP 狀態、`finishReason` 與圖片內容。只有文字、被過濾、缺少最終圖片或格式不匹配時，明確報告未完成；不能把整個 JSON 儲存為圖片。
* 嚴格解碼 Base64，核對實際檔案格式與 MIME，確認檔案能打開、尺寸與內容符合要求。保留原有檔案，失敗只清理本次新建的無效輸出。
* 串流 `streamGenerateContent?alt=sse` 僅在模型支援時使用，任意片段不等於最終圖片。`generateContent` 同步回傳完整結果，不提供通用任務 ID 輪詢；Google Batch 是獨立服務，不等於本目錄端點。
* 多圖按內容項分別儲存，核對完成數量；提示詞寫“生成一張”不保證每個模型嚴格回傳一張。未獲授權不為補足數量自動再呼叫。

## 錯誤、重試與費用

400 先核對模型、欄位與參考圖，401/403 檢查金鑰權限，404 檢查模型與路徑，429 檢查額度及限流。超時、5xx 或缺少完整終態時，先查使用記錄和現有檔案，不自動重發。只報告脫敏錯誤和請求標識，不輸出金鑰、完整 Base64 或私密圖片內容。

真實生成與編輯可能產生費用。呼叫前確認模型、規格、數量與輸出位置；更高檔位、更多圖片、換模型或重試須重新確認。並行請求分別控制限流、超時與費用；用量欄位出現不代表模型一定按 Token 收費。最終以當前價格與使用記錄為準。

## 官方參考

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 圖片生成與編輯](https\://ai.google.dev/gemini-api/docs/image-generation)