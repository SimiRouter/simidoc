# Veo 影片（Gemini API 預覽模型已停用）

## 概覽

Veo 透過 Gemini API 的 long-running operation 生成影片：先呼叫 `predictLongRunning` 啟動任務，拿到 operation 名稱，再輪詢該 operation，完成後從回應中的檔案 URI 下載 MP4。

**Gemini API 上的 `veo-3.1-generate-preview`、`veo-3.1-fast-generate-preview` 等預覽模型已於 2026-10-22 停用。** 本頁保留協議結構，供理解既有呼叫和遷移參考；現在不能把這個端點當作可用的生產介面。可遷移到 `gemini-omni-1.2-flash`，或使用 Gemini Enterprise Agent Platform 上的 GA 模型。

| 你要做的事  | 輸入            | 輸出           | 端點                                                  |
| ------ | ------------- | ------------ | --------------------------------------------------- |
| 啟動影片生成 | 提示詞、首幀、尾幀或參考圖 | operation 名稱 | `POST /v1beta/models/{MODEL_ID}:predictLongRunning` |
| 查詢操作   | operation 名稱  | `done`、結果或錯誤 | `GET /v1beta/{operation_name}`                      |
| 下載影片   | 結果中的檔案 URI    | MP4 位元組      | `GET {video.uri}`                                   |

## 核心概念

* **操作（operation）不是任務 ID**：建立回應回傳 `name`，例如 `models/veo-3.1-generate-preview/operations/...`。輪詢、讀取結果和排錯都使用這個完整名稱。
* **完成條件是 `done: true`**：`done: false` 只表示仍在處理。`done: true` 時還要檢查是否存在 `error`，以及 `response.generateVideoResponse.generatedSamples[0].video.uri` 是否為空。
* **耗時範圍**：官方給出的生成耗時為最少 11 秒，峰值最長 6 分鐘。輪詢可用 10–15 秒間隔，並設定用戶端總等待上限。
* **時長與解析度聯動**：時長只有 4、6、8 秒三檔。使用 1080p、4k、參考圖或影片延長時，時長必須為 8 秒；不能把 4 秒請求直接改成 1080p。
* **音訊隨模型生成**：Gemini API 文件把音訊描述為始終開啟，沒有單獨的 `generateAudio` 開關。提示詞可以寫對白、音效和環境聲。
* **計費按平台區分**：Gemini API 與 Agent Platform 是兩套計費與配額體系，單價以廠商計價頁為準。預覽模型停用後，不應再產生新的呼叫費用。

## 規格與能力

| 指標    | Gemini API 預覽模型                                                                                                                                                                 | Agent Platform GA 模型                                                                         |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| 模型 ID | `veo-3.1-generate-preview`、`veo-3.1-fast-generate-preview`、`veo-3.1-lite-generate-preview`；`veo-3.0-generate-001`、`veo-3.0-fast-generate-001`。Gemini API 文件把這些 ID 標為 Deprecated | `veo-3.1-generate-001`、`veo-3.1-fast-generate-001`（GA）；`veo-3.1-lite-generate-001` 為 Preview |
| 解析度   | 預設 `720p`；`1080p` 與 `4k` 僅限 8 秒                                                                                                                                                 | 標準模型輸出 `720p`、`1080p`、`4K`；Fast 模型輸出 `720p`、`1080p`                                          |
| 寬高比   | `16:9`、`9:16`                                                                                                                                                                   | `16:9`、`9:16`                                                                                |
| 時長    | `4`、`6`、`8` 秒                                                                                                                                                                   | `4`、`6`、`8` 秒；參考圖模式僅 8 秒                                                                     |
| 音訊    | 原生生成，始終開啟                                                                                                                                                                       | 能力表列出聲音生成                                                                                    |
| 參考素材  | `image` 首幀、`lastFrame` 尾幀、最多 3 張 `referenceImages`                                                                                                                              | 資產參考圖、首尾幀                                                                                    |
| 影片延長  | 每次增加 7 秒，最多 20 次；輸入最長 141 秒，輸出最長 148 秒；僅 720p                                                                                                                                   | 支援延長能力，參數以平台文件為準                                                                             |

解析度和時長不是獨立選項：1080p、4k、參考圖和延長都要求 8 秒；4 秒或 6 秒只能配 720p。參考圖最多 3 張，首幀與尾幀是畫面約束，不是風格參考。音訊始終生成，不能透過參數關閉。遷移到 Agent Platform 後，模型 ID、認證和配額都換了一套，不能把本文端點直接換成 GA 模型名繼續使用。

## 呼叫流程

1. 確認平台與憑證。Gemini API 使用 `x-goog-api-key`；Agent Platform 使用平台自身的認證方式，兩者不能互換。
2. 向 `POST /v1beta/models/{MODEL_ID}:predictLongRunning` 提交 `instances` 與 `parameters`。提示詞放在 `instances[0].prompt`，首幀放在 `instances[0].image`。
3. 儲存回應中的 `name`。建立成功只代表操作已建立，不代表影片可下載。
4. 輪詢 `GET /v1beta/{operation_name}`，直到 `done: true`。若存在 `error`，按錯誤內容結束，不要繼續等待。
5. 從 `response.generateVideoResponse.generatedSamples[0].video.uri` 讀取下載位址，攜帶 API Key 請求該 URI，並允許 HTTP 重新導向。
6. 把檔案轉存到自己的儲存。官方文件說明生成影片保留 2 天，延長引用會重置計時；不要依賴長期有效的廠商 URL。

## 模擬呼叫

以下為歸檔示意，用來說明原 Gemini API 的報文結構。預覽模型已於 2026-10-22 停用，目前不會據此產生新任務；operation 名稱與 URL 均為示意值。

啟動請求：

```json
{
  "instances": [
    {
      "prompt": "示例：海边日落，镜头缓慢推进。"
    }
  ],
  "parameters": {
    "aspectRatio": "16:9",
    "resolution": "720p",
    "numberOfVideos": 1,
    "durationSeconds": 8,
    "personGeneration": "allow_all"
  }
}
```

建立回應只有操作名稱：

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": false
}
```

完成後的操作回應：

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": true,
  "response": {
    "generateVideoResponse": {
      "generatedSamples": [
        {
          "video": {
            "uri": "https://example.com/demo-veo.mp4"
          }
        }
      ]
    }
  }
}
```

`done: true` 但沒有 `generatedSamples` 或 URI 為空時，按失敗處理並保留 operation 名稱。

## 串接與工作階段

* **基礎位址**：`https://generativelanguage.googleapis.com/v1beta`。
* **鑑權標頭**：`x-goog-api-key: PASTE_API_KEY_HERE`，同時傳送 `Content-Type: application/json`。
* **兩套位址**：直連 Gemini API 用 `https://generativelanguage.googleapis.com/v1beta`，鑑權標頭為 `x-goog-api-key`；只有管道明確確認對應本站閘道時，才使用 `https://api.dwchainless.com` 和 `Authorization: Bearer` 加本站 Key；不能只替換位址和鑑權。SimiRouter 若提供同名模型，路徑、欄位和輪詢方式由管道對應決定。Agent Platform 的 GA 模型使用 `https://{region}-aiplatform.googleapis.com` 這類區域位址與專案認證，既不是 `generativelanguage` 位址，也不是模型字串替換。
* **逾時與冪等**：啟動請求逾時後，先檢查是否已建立 operation；儲存 `name` 比儲存 HTTP 狀態更重要。不要因為等待時間長而重複啟動相同任務。
* **遷移提示**：`gemini-omni-1.2-flash` 的介面形態與 `predictLongRunning` 不同，現有輪詢程式碼可能必須重寫。遷移前以官方遷移文件和帳戶可用模型清單為準。

## 官方參考

* [Gemini API：Veo 影片生成](https\://aistudio.google.com/docs/veo)
* [Veo 3.1 預覽模型停用說明](https\://aistudio.google.com/docs/models/veo-3.1-generate-preview)
* [Gemini Enterprise Agent Platform：Veo 3.1](https\://docs.cloud.google.com/gemini-enterprise-agent-platform/models/veo/3-1-generate)