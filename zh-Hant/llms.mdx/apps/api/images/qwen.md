# Qwen 原生圖片介面

本節使用 Qwen 原生請求體，但統一透過本站閘道呼叫：`API_URL` 為 `https://api.dwchainless.com/v1/images/...`，鑑權使用本站 `API_KEY`。請求參數沿用 `model`、`input.messages`、`parameters`，回傳統一為 `data[]`；先完成一次單張呼叫，再增加數量或接入智慧代理。

## 請求格式與參數

| API       | 請求格式                               | 主要參數                                                   | 詳細文件                         |
| --------- | ---------------------------------- | ------------------------------------------------------ | ---------------------------- |
| 文字生圖      | `POST /v1/images/generations`，JSON | `model`、`input.messages[].content[].text`、`parameters` | [生成參數與四語言程式碼](/simidoc/zh-Hant/apps/api/images/qwen/generations) |
| 編輯 / 以圖生圖 | `POST /v1/images/edits`，JSON       | `content[]` 內的 `image` 與一條 `text`，加 `parameters`       | [編輯參數與四語言程式碼](/simidoc/zh-Hant/apps/api/images/qwen/edits)       |

當前頁面的 2.0 系列範例在 `input.messages` 放一條 `user` 訊息，文字描述主體、構圖、風格與需渲染的文字；編輯時加入已授權的圖片 URL 或模型支援的 data URL。背景替換、風格轉換、圖中文字修改和多圖融合屬於編輯目標，不另設 OpenAI multipart 欄位，也不保證細節逐像素保留。

### 圖片規格

尺寸寫在 `parameters.size`，格式為 `width*height`，例如 `"2048*2048"`；不是 `"2048x2048"` 或 `"2K"`。2.0 系列以總像素範圍約束尺寸，具體輸入圖、寬高及輸出限制須按模型核對；總像素限制不等於最長邊限制。

| 本站三檔按張計費 | 請求尺寸最長邊            | 像素例子      |
| -------- | ------------------ | --------- |
| 1K       | ≤ 1024 像素          | 1024×1024 |
| 2K       | > 1024 且 ≤ 2048 像素 | 1536×1024 |
| 4K       | > 2048 像素          | 2560×1440 |

此表只解釋本站特定模型的計費檔位，不表示模型接受 `1K` / `2K` / `4K` 參數。透過本站呼叫按[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)結算，並參考[圖片規格與計費總覽](/simidoc/zh-Hant/apps/api/images)。更大像素數不保證文字和細節正確，不支援目標規格時應報錯而非靜默替換。

## 回傳參數

| 回傳欄位                    | 含義與處理                          |
| ----------------------- | ------------------------------ |
| `created`               | 回應生成時間戳。                       |
| `data[].url`            | 最終圖片 URL；有效期由渠道決定，需及時下載儲存。     |
| `data[].b64_json`       | 部分渠道回傳純 Base64；存在時可直接解碼儲存。     |
| `data[].revised_prompt` | 渠道改寫後的提示詞；可能不存在。               |
| `error` / `message`     | 錯誤碼與說明；HTTP 成功也要檢查業務錯誤和圖片是否存在。 |

請求體是 Qwen 原生結構，回傳是統一的 `data[]`。不要照搬其他渠道的 `prompt`、multipart 或非同步 `task_id` 協定；模型 ID 必須與本站渠道實際提供的名稱一致。

## 呼叫示例

### 準備配置

在[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)核對可用模型與餘額，並使用本站建立的 Key。`API_URL` 始終指向本站閘道，不需要工作空間 ID、地域網域或百煉官方 Key。

| 配置          | 用途                                                                |
| ----------- | ----------------------------------------------------------------- |
| `API_KEY`   | 本站 Key；直接在範例中填入，不貼上到提示詞、程式碼、截圖或 Git。                              |
| `API_URL`   | 本站閘道完整請求位址，如 `https://api.dwchainless.com/v1/images/generations`。 |
| `model`     | 已有範例為 `qwen-image-2.0-pro`；先確認本站渠道支援該模型與所需能力。                     |
| `IMAGE_URL` | 編輯範例所用的已授權、雲端可存取 HTTP(S) 圖片位址，不是本機路徑或 localhost。                  |

[生成範例](/simidoc/zh-Hant/apps/api/images/qwen/generations)和[編輯範例](/simidoc/zh-Hant/apps/api/images/qwen/edits)均提供 Python、Node.js、curl、Go。現有程式碼送出一次請求並印出 JSON，**不會自動下載圖片**。將 Python 程式碼儲存為 `generate.py` / `edit.py`，執行 `python3 generate.py` / `python3 edit.py`；Node.js 儲存為 `generate.mjs` / `edit.mjs`，執行 `node generate.mjs` / `node edit.mjs`。按對應頁要求配置執行時與變數，先只請求一張，隨後按下節儲存 URL 指向的真實圖片。

### 智慧代理生成 Demo

智慧代理需要本機指令碼、網路請求與回傳結果檢查能力；本頁不是安裝 Skill 的指令，也不會給純文字用戶端增加這些能力。

```text
Read this Qwen image protocol page and its generation reference first. Use the
existing API_KEY and API_URL from this site's gateway; never print, paste, commit,
or store the key in source files. Use the documented qwen-image-2.0-pro model only
after checking availability and pricing. For this one approved request, POST once
to /v1/images/generations with the native Qwen body: one user message, one text
content item, parameters.n=1 and size=1024*1024 if supported. Image brief: a calm
blue library with a small robot reading, watercolor illustration, no lettering.
Print the returned JSON and inspect data[].url or data[].b64_json; report the final
image URL without forwarding the API key. JSON or a URL alone is not a saved image.
Do not switch model/provider, increase size/count, write files, install remote
skills, or automatically retry an error or timeout. Ask before another paid request.
```

### 智慧代理編輯 Demo

只使用獲得處理和上傳授權的圖片；先檢查個人資訊及商業機密。現有範例讀取 URL，不會自動把本機檔案公開上傳到其他服務。

```text
Read this Qwen image protocol page and its editing reference first. Use the existing
API_KEY and API_URL from this site's gateway; never reveal the key or switch the
existing connection. Verify qwen-image-2.0-pro supports the edit. Use only the
authorized cloud-readable image in IMAGE_URL; do not upload unrelated local files or
publish a file. POST once to /v1/images/edits with the native Qwen body: one user
message containing that image item and one text instruction: keep the subject and
layout; change only the background to pale blue. Set parameters.n=1 and size=1024*1024
only if supported. Do not use OpenAI multipart or mask fields. Check the completed
business result, inspect data[].url or data[].b64_json without forwarding the API key,
and report it. Do not write files, change model/size/count/provider, install remote
skills, or retry automatically. If any step fails or the requested edit is not met,
report a redacted error instead of claiming success.
```

## 儲存與完成標準

* 同步回應不是輪詢任務；本節不使用 `task_id` 或 `X-DashScope-Async`。不要混入其他模型的非同步協定，也不把串流事件當作完成標準。
* 檢查 HTTP 與業務錯誤、結束原因和實際圖片項，再遍歷圖片 URL。URL 有效期有限，盡快下載；JSON、位址或智慧代理的口頭結論都不等於檔案已儲存。
* 下載時檢查回應狀態、內容與檔案頭，不把錯誤網頁改名為 PNG；不要把本站 Key 發給結果儲存網域。保留原檔案，失敗只清理本次建立的無效輸出。
* 確認檔案存在、可開啟、尺寸與內容符合需求，並在本站帳單或使用日誌核對請求與費用。多圖逐項核對，不為補足數量自動再呼叫。

## 錯誤、重試與費用

參數錯誤先檢查 `model`、訊息結構、`size` 與輸入圖；鑑權錯誤先核對本站 Key 與模型權限；額度或限流錯誤先檢查帳戶狀態。逾時、5xx 或結果不明確時先查呼叫日誌與已有檔案，不自動重送，避免重複生成或扣費。僅報告脫敏錯誤，不輸出金鑰、完整 Base64 或私密圖片。

真實生成與編輯可能產生費用。呼叫前確認模型、尺寸、張數與輸出位置；增量、升級規格或重試須重新確認。並行請求分別控制限流、逾時與費用；`n` 是單請求數量。最終計價以本站規則和帳單為準。

## 官方參考

* [Qwen-Image 生成](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api)
* [Qwen-Image 編輯](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api)