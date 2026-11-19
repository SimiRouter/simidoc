# OpenAI 格式圖片介面

本節使用 OpenAI 格式，區分生成、編輯、對話式生圖與圖片理解。先完成一次單張呼叫，再增加數量或接入智慧代理；只有具備相應圖像能力的模型才能完成對應任務。

## 呼叫順序

1. **準備設定**：在 [API 金鑰管理](https://api.dwchainless.com/keys) 建立金鑰，從[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)複製支援的完整模型 ID；請求位址為閘道 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $API_KEY`。
2. **選擇端點**：文字生圖用 `POST /v1/images/generations`，編輯 / 以圖生圖用 `POST /v1/images/edits`，對話式生圖用 `POST /v1/responses`，圖片理解用 `POST /v1/chat/completions`。
3. **先傳最小請求**：只請求一張、不使用串流，確認驗證、模型和參數都有效，再增加數量、尺寸或接入智慧代理。
4. **讀取並驗收**：從 `data[]` 解碼 Base64 或下載 URL，檢查檔案可開啟、尺寸與內容符合要求，再核對使用記錄。

完整參數、範例與錯誤處理見下方各協定頁面；第一次呼叫建議從[生成](/simidoc/zh-Hant/apps/api/images/openai/generations)開始。

## 請求格式與參數

| API       | 請求格式                                         | 主要參數                                                 | 詳細文件                         |
| --------- | -------------------------------------------- | ---------------------------------------------------- | ---------------------------- |
| 文字生圖      | `POST /v1/images/generations`，JSON           | `model`、`prompt`；按模型設定 `n`、`size`、`quality`          | [生成參數與四語言程式碼](/simidoc/zh-Hant/apps/api/images/openai/generations) |
| 編輯 / 以圖生圖 | `POST /v1/images/edits`，JSON 或 multipart 二選一 | `model`、`prompt`、`images[]` 或檔案 `image`；可用時添加 `mask` | [編輯參數與四語言程式碼](/simidoc/zh-Hant/apps/api/images/openai/edits)       |
| 對話式生圖     | `POST /v1/responses`，JSON                    | `input`、圖像生成工具及對應模型配置                                | [對話式圖片生成](/simidoc/zh-Hant/apps/api/images/openai/chat-format)     |
| 圖片理解      | `POST /v1/chat/completions`，JSON             | `messages` 內的文字與 `image_url` 內容項                     | [圖片理解](/simidoc/zh-Hant/apps/api/images/openai/vision)             |

編輯提示詞應分別說明“保留什麼、修改什麼”。風格轉換、背景替換和增刪元素是編輯目標，不是另一套 API；蒙版、多圖和透明背景必須由選定模型支援，不能保證人物、商品或文字逐像素保持不變。

### 圖片規格

`size` 表示像素寬高，例如 `1024x1024`，不是通用的 `1K` / `2K` / `4K` 枚舉；可接受尺寸隨模型變化。`quality` 控制品質，`output_format` 控制 PNG/JPEG/WebP 編碼，不能用它們代替解析度。透明背景還需模型支援 `background: transparent`，並使用 PNG 或 WebP。

尺寸的三種寫法、14 種比例速查與 1K/2K/4K 按張計費檔位統一見[圖片規格與計費總覽](/simidoc/zh-Hant/apps/api/images)。計費表只適用於[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)明確採用該規則的模型，不保證範例尺寸均可請求。

## 回傳參數

| 回傳欄位 / 事件                                             | 含義與處理                                                  |
| ----------------------------------------------------- | ------------------------------------------------------ |
| Images `data[].b64_json`                              | GPT Image 的 Base64 圖片資料，解碼後儲存二進位圖片；不要把整份 JSON 改名為 PNG。 |
| Images `data[].url`                                   | 僅支援 URL 輸出的舊或相容模型可能回傳；及時下載，不能假定 GPT Image 必有此欄位。       |
| Images `usage`                                        | 可選用量資料；欄位出現不代表一定按 Token 收費。                            |
| `image_generation.completed` / `image_edit.completed` | Images 串流生成 / 編輯的最終事件；`partial_image` 只是中間預覽。          |
| Responses `output[]`                                  | 對話式生圖按圖像工具輸出項處理，不照搬 Images `data[]`。                   |
| Chat `choices[].message.content`                      | 圖片理解回傳文字分析，不是生成圖片。                                     |

## 呼叫範例

### 準備配置

在 [API 金鑰管理](https://api.dwchainless.com/keys)建立金鑰，從[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)複製當前金鑰可用的完整圖像模型 ID，並核對權限、分組和額度。可直接在範例程式碼中填寫 API\_URL、API\_KEY 和 MODEL：

| 變數          | 用途                                            |
| ----------- | --------------------------------------------- |
| `API_KEY`   | 必填；直接在範例中填寫，不貼上到提示詞、原始檔案、截圖或 Git。             |
| `MODEL`     | 必填；生成和編輯分別確認模型支援對應端點。                         |
| `API_URL`   | 完整請求位址；範例使用閘道 `https://api.dwchainless.com`。  |
| `IMAGE_URL` | 編輯範例使用的 HTTPS 圖片位址，須為伺服器可存取的 PNG、JPEG 或 WebP。 |

[生成範例](/simidoc/zh-Hant/apps/api/images/openai/generations)和[編輯範例](/simidoc/zh-Hant/apps/api/images/openai/edits)均提供 Python、Node.js、curl、Go。先選一種語言、只請求一張非串流圖片。Python 3.8+ 與 Node.js 20+ 範例使用標準函式庫；將生成程式碼儲存為 `generate.py` 或 `generate.mjs`，編輯程式碼儲存為 `edit.py` 或 `edit.mjs`，執行對應檔案，例如 `python3 generate.py` 或 `node generate.mjs`。Python 和 Node.js 編輯範例都使用 JSON `images[].image_url`，不使用 multipart 上傳。

### 智慧代理生成 Demo

智慧代理須具備執行本地指令碼、讀取授權圖片和檢查回傳結果的能力；本頁不會安裝 Skill，也不會讓純文字用戶端自動獲得工具能力。保留既有連線，不擅自換服務。

```text
Read this OpenAI image protocol page and its generation reference first. Use the
SimiRouter request URL in API_URL (default gateway https://api.dwchainless.com) and the
image model in MODEL. Set API_KEY directly in the example; never print, paste, commit,
or store it in source files. For this one approved request, use POST
/v1/images/generations with n=1, size=1024x1024, stream=false and output_format=png only
after verifying the model supports these parameters. Image brief: a calm blue library
with a small robot reading, watercolor illustration, no lettering. Print the returned
JSON and inspect data[].b64_json; do not write an image file. Confirm that
data[].b64_json contains non-empty Base64 data before reporting completion. Do not
install remote skills, switch providers/models/billing groups, increase size/count,
write files, or retry after timeout or ambiguous failure without approval. If the
request or validation fails, report a redacted error, not success.
```

### 智慧代理編輯 Demo

先確認參考圖的處理權限，檢查個人資訊或商業機密；只授權所需檔案。提示詞中的“保留”是目標，不是像素級保證。

```text
Read this OpenAI image protocol page and its editing reference first. Set API_KEY,
MODEL, and API_URL directly in the example; use the configured SimiRouter request URL;
never reveal the key or change the existing connection. Use only the authorized HTTPS
image URL in IMAGE_URL. Use POST /v1/images/edits with JSON images[]; do not set
multipart Content-Type or send local files. Keep the subject and layout; change only the
background to pale blue. Request one PNG at 1024x1024 with stream=false only if the
selected model supports it. Print the returned JSON and inspect data[].b64_json; do not
write an image file. Confirm that data[].b64_json contains non-empty Base64 data and
report any unmet requirement. Do not upload unrelated files, change
size/count/model/provider, install remote skills, or retry automatically after an error
or timeout. Ask before another paid request.
```

## 儲存與完成標準

* 儲存前檢查 HTTP 狀態、最終圖片欄位、解碼結果與實際檔案格式；僅改副檔名不能轉換格式。失敗時清理本次新建的無效檔案，不刪除原有檔案。
* 先使用單張非串流請求。串流必須等相應 `completed`，按圖片索引處理多張結果；沒有終態不能把預覽標記完成。標準 Images 不是先回傳任務 ID 再輪詢的通用非同步佇列。
* 確認檔案存在、可開啟、尺寸與內容符合要求，再核對使用記錄。HTTP 成功或智慧代理口頭說“完成”不等於圖片已儲存。

## 錯誤、重試與費用

400 先核對模型與參數，401 檢查金鑰，403/404 檢查權限、模型 ID 與路徑，429 檢查額度及速率限制。5xx、超時或串流中斷後先查看記錄和已有結果，不自動重發，避免重複生成或扣費。只報告脫敏錯誤與請求標識，不輸出金鑰、完整圖片 Base64 或私密圖片內容。

真實生成與編輯可能產生費用。呼叫前確認模型、尺寸、張數和輸出位置；增加 `n`、改高檔位、換模型或重試須重新確認。並行請求分別限流、超時和計費；`n` 是單次請求的數量，不是並行度。最終費用以當前模型價格和使用記錄為準。

## 官方參考

* [OpenAI 圖像生成指南](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Images API](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [OpenAI 視覺輸入](https\://developers.openai.com/api/docs/guides/images-vision)