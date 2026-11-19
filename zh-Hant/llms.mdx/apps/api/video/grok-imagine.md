# Grok Imagine 影片

## 概覽

Grok Imagine 用 xAI 的非同步影片介面：`POST /v1/videos/generations` 提交任務並回傳 `request_id`，再用 `GET /v1/videos/{request_id}` 輪詢。文字提示詞可直接生成影片；提供 `image` 時進入圖生影片，提供參考圖或關鍵幀時進入參考生影片。

| 你要做的事 | 輸入                                          | 輸出           | 端點                            |
| ----- | ------------------------------------------- | ------------ | ----------------------------- |
| 文生影片  | `prompt`、時長、畫幅、解析度                          | `request_id` | `POST /v1/videos/generations` |
| 圖生影片  | `image` + 可選 `prompt`                       | `request_id` | 同一端點                          |
| 參考生影片 | `prompt` + `reference_images` 或 `keyframes` | `request_id` | 同一端點                          |
| 查詢任務  | `request_id`                                | 狀態、影片 URL、用量 | `GET /v1/videos/{request_id}` |

## 核心概念

* **任務生命週期**：查詢狀態只有 `pending`、`done`、`failed`。`pending` 時 `progress` 在 0–99，`done` 時為 100，`failed` 時可能省略。
* **`request_id` 是輪詢識別碼**：它不是冪等鍵。提交逾時後不能憑「沒有收到回應」判斷任務未建立，應先保留並查詢可能存在的 `request_id`。
* **輪詢節奏**：官方文件沒有規定固定間隔。用戶端可用 5–10 秒間隔，並設定總等待上限；`failed` 後立即停止。
* **時長與畫幅**：`duration` 範圍 1–15 秒，預設 8 秒；圖生影片會忽略 `aspect_ratio`，畫幅隨輸入圖片。`resolution` 預設 `480p`，`grok-imagine-video-1.5` 支援原生 1080p。
* **音訊開關**：能力頁列出 `generate_audio`，預設 `true`，設為 `false` 請求靜音；REST 參考沒有單列該欄位，實際可用性以介面回傳為準。
* **計費單位**：查詢回應的 `usage.cost_in_usd_ticks` 是本次任務的成本計數，具體換算、單價與失敗結算以廠商計價頁為準。

## 規格與能力

| 指標    | 已核實取值                                                                       |
| ----- | --------------------------------------------------------------------------- |
| 模型 ID | `grok-imagine-video-1.5`、`grok-imagine-video-1.5-lite`、`grok-imagine-video` |
| 解析度   | `480p`（預設）、`720p`、`1080p`；`grok-imagine-video-1.5` 為原生 1080p                |
| 寬高比   | `1:1`、`16:9`（預設）、`9:16`、`4:3`、`3:4`、`3:2`、`2:3`、`21:9`、`5:2`；圖生影片忽略該欄位      |
| 時長    | 1–15 秒，預設 8 秒；編輯既有影片時不接受自訂時長                                                |
| 音訊    | `generate_audio` 預設 `true`，`false` 請求靜音；以能力頁描述為準                            |
| 參考素材  | `image` 首幀、`reference_images` 參考圖、`keyframes` 最多 4 個、`last_frame` 尾幀（1.5）   |
| 圖片輸入  | 公網 URL、Base64 data URI，或 xAI Files API 的 `file_id`；JPEG、PNG、WebP            |
| 計費計量  | `usage.cost_in_usd_ticks`，單價按廠商計價頁為準                                        |

預設 `480p` 適合預覽，`720p` 與 `1080p` 會增加生成時間和成本。圖生影片忽略 `aspect_ratio`，畫幅由 `image` 決定；要控制橫屏或直式，應在準備輸入圖片時處理。`duration` 預設 8 秒，實際耗時還受排隊影響，不能只按時長估算。`generate_audio` 在能力頁有說明、REST 參考未單列，接入前先用一個短請求驗證目前模型是否接受該欄位。

## 呼叫流程

1. 在 xAI 控制台建立 API Key，後續請求使用 `Authorization: Bearer`。
2. 選擇生成方式：只送 `prompt` 是文生影片；加 `image` 是圖生影片；加 `reference_images`、`keyframes` 或 `last_frame` 是參考生影片。
3. 呼叫 `POST https://api.x.ai/v1/videos/generations`，按目標模型設定 `duration`、`aspect_ratio`、`resolution` 和音訊開關。
4. 儲存回應中的 `request_id`。建立成功只代表任務已受理。
5. 輪詢 `GET https://api.x.ai/v1/videos/{request_id}`，直到 `status` 為 `done` 或 `failed`。
6. `done` 後下載 `video.url`；需要寫入自己的物件儲存時，也可以在請求裡使用 `output.upload_url` 或 `storage_options`。`failed` 時讀取 `error.code` 與 `error.message`。

## 模擬呼叫

以下為示意報文，`request_id`、URL 和用量都不是真實帳戶資料。

建立請求：

```json
{
  "model": "grok-imagine-video-1.5",
  "prompt": "示例：夜晚的霓虹街道，镜头缓慢前推。",
  "duration": 6,
  "aspect_ratio": "16:9",
  "resolution": "720p",
  "generate_audio": true
}
```

建立成功回傳輪詢識別碼：

```json
{
  "request_id": "demo-request-0001"
}
```

查詢到成功終態：

```json
{
  "status": "done",
  "progress": 100,
  "model": "grok-imagine-video-1.5",
  "video": {
    "url": "https://example.com/demo-grok-imagine.mp4",
    "duration": 6,
    "respect_moderation": true
  }
}
```

`pending` 時繼續輪詢；`failed` 時停止並讀取 `error`。`video.respect_moderation` 為 `false` 時，URL 可能為空，不能當作可播放結果。

## 串接與工作階段

* **基礎位址**：`https://api.x.ai`。生成、查詢、編輯和延長分別是 `/v1/videos/generations`、`/v1/videos/{request_id}`、`/v1/videos/edits`、`/v1/videos/extensions`。
* **鑑權標頭**：`Authorization: Bearer PASTE_API_KEY_HERE`，請求主體為 JSON。
* **兩套位址**：直連用 `https://api.x.ai`；只有管道明確確認對應本站閘道時，才使用 `https://api.dwchainless.com` 和 `Authorization: Bearer` 加本站 Key；不能只替換位址和鑑權。SimiRouter 管道是否暴露 `/v1/videos/*`、是否保留 `request_id` 和狀態欄位，由管道對應決定。
* **逾時與冪等**：沒有公開的冪等鍵。提交逾時後先查詢已知 `request_id`，確認任務不存在再重試；不要並發提交相同提示詞來規避等待。
* **結果儲存**：`video.url` 是暫時位址，文件同時提供檔案輸出與過期時間欄位。產品側應先下載或轉存，再對外提供長期連結。

## 官方參考

* [xAI：Grok Imagine 影片生成](https\://docs.x.ai/developers/model-capabilities/video/generation)
* [xAI：影片 REST API 參考](https\://docs.x.ai/developers/rest-api-reference/inference/videos)
* [xAI：圖生影片](https\://docs.x.ai/developers/model-capabilities/video/image-to-video)