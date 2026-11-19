# PixVerse 影片

## 概覽

PixVerse 官方 OpenAPI 用普通 HTTP 請求提交非同步生成任務，建立成功後回傳 `video_id`，再用同一 ID 查詢狀態並取得影片位址。文生影片與圖生影片是兩個入口；圖生影片要先上傳圖片，拿到 `img_id` 後再提交。

| 你要做的事   | 輸入                                 | 輸出             | 端點                                        |
| ------- | ---------------------------------- | -------------- | ----------------------------------------- |
| 從文字生成影片 | 提示詞、時長、`quality`、`aspect_ratio`    | `video_id`     | `POST /openapi/v2/video/text/generate`    |
| 從圖片生成影片 | 已上傳圖片的 `img_id`（或模板 `img_ids`）加提示詞 | `video_id`     | `POST /openapi/v2/video/img/generate`     |
| 查詢任務結果  | `video_id`                         | 狀態、影片 URL、實際規格 | `GET /openapi/v2/video/result/{video_id}` |
| 上傳圖片    | 圖片檔案                               | `img_id`       | `POST /openapi/v2/image/upload`           |

## 核心概念

* **任務生命週期**：建立回傳 `ErrCode=0` 和 `video_id`，只表示任務已受理。查詢狀態 `1` 為完成，`5` 為生成中，`7` 為內容審核失敗，`8` 為生成失敗；`1`、`7`、`8` 都是終態。
* **兩個 ID 的用途不同**：`video_id` 是業務任務識別碼，用於查詢和下載；`Ai-trace-id` 是每個請求都要新生成的 UUID，只用於追蹤，不是冪等鍵，重複使用可能建立另一個任務。
* **輪詢節奏**：官方建議每 3–5 秒查詢一次。用戶端要設定總等待上限；進入 `7` 或 `8` 後立即停止，不要繼續重試同一任務。
* **計費單位**：建立回應中的 `Resp.credits` 是本次任務消耗的積分。實際單價、方案與退款規則以廠商計價頁和帳戶帳單為準。
* **畫幅與時長分開控制**：文生影片用 `quality` 指定清晰度檔位、用 `aspect_ratio` 指定畫幅；圖生影片沒有 `aspect_ratio` 欄位，畫幅由輸入圖片或模板決定。`duration` 的有效值隨模型變化，不能只按介面的 1–15 範圍填寫。

## 規格與能力

| 指標    | 已核實取值                                                                               |
| ----- | ----------------------------------------------------------------------------------- |
| 模型 ID | `v6-max`、`c1`、`v6`、`v5.6`、`v5.5`、`v5`、`v5-fast`、`v4.5`、`v4`、`v3.5`；`v5-fast` 需要帳戶權限 |
| 解析度   | `quality`：`360p`、`540p`、`720p`、`1080p`                                              |
| 寬高比   | 文生影片：`16:9`、`9:16`、`4:3`、`3:4`、`1:1`、`2:3`、`3:2`、`21:9`；圖生影片：無該欄位                   |
| 時長    | 介面範圍 1–15 秒；C1、V6 為 1–15 秒，V5.5、V5.6 為 5、8 或 10 秒，舊模型為 5 或 8 秒                      |
| 音訊    | `generate_audio_switch` 布林開關，預設 `false`；V5.5、V5.6、V6、C1 支援原生音訊                      |
| 參考圖片  | 圖生影片先上傳得到 `img_id`；模板任務用 `img_ids` 配合 `template_id`                                 |
| 計費計量  | 建立回應回傳 `Resp.credits`，單價按廠商計價頁為準                                                    |

選擇時先看模型代際，再看 `quality` 與 `duration`。`quality` 只決定輸出像素檔位，不改變畫幅；`aspect_ratio` 只決定形狀，最終像素由兩者共同決定。圖生影片沒有 `aspect_ratio` 欄位，不要照搬文生影片請求主體，畫幅由輸入圖片或模板決定。建立回應中的 `Resp.credits` 適合做預算記錄，實際扣費與退款仍以帳戶帳單為準。

## 呼叫流程

1. 在 PixVerse 開放平台建立 API Key。請求使用 `API-KEY` 標頭，不要把它寫進提示詞或程式碼儲存庫。
2. 圖生影片先呼叫 `POST /openapi/v2/image/upload` 上傳圖片，儲存回應中的 `Resp.img_id`；文生影片跳過這一步。
3. 向對應生成端點提交 JSON。必填欄位為 `model`、`prompt`、`duration`、`quality`；文生影片還需要 `aspect_ratio`。每次請求生成新的 `Ai-trace-id`。
4. 儲存建立回應中的 `Resp.video_id`。不要把 `ErrCode=0` 當作影片已經生成。
5. 每 3–5 秒呼叫一次查詢端點。只在 `status=1` 且 `Resp.url` 可存取時下載；`status=7` 修正內容後再決定是否重試，`status=8` 保留 `Ai-trace-id` 供排查。
6. 把影片轉存到自己的儲存。結果 URL 的存取策略與有效期以廠商說明為準，不要把它當作永久公開位址。

## 模擬呼叫

以下報文只用於說明欄位結構，任務 ID、積分和 URL 都是示意值，不是真實帳戶資料。

建立文生影片任務：

```json
{
  "model": "v6-max",
  "prompt": "示例：海边日落，一艘白色帆船缓慢驶过，镜头平稳。",
  "duration": 5,
  "quality": "720p",
  "aspect_ratio": "16:9",
  "seed": 20260804,
  "generate_audio_switch": false
}
```

建立成功只回傳任務 ID 和消耗積分：

```json
{
  "ErrCode": 0,
  "ErrMsg": "Success",
  "Resp": {
    "video_id": 900000000000001,
    "credits": 12
  }
}
```

查詢到 `status=1` 才有可下載位址：

```json
{
  "ErrCode": 0,
  "ErrMsg": "Success",
  "Resp": {
    "id": 900000000000001,
    "status": 1,
    "url": "https://example.com/demo-pixverse.mp4",
    "duration": 5,
    "quality": "720p",
    "aspect_ratio": "16:9",
    "outputWidth": 1280,
    "outputHeight": 720,
    "has_audio": false,
    "credits": 12
  }
}
```

`status=5` 時繼續輪詢；`status=7` 或 `status=8` 立即結束，並從 `ErrMsg`、`Error.Message` 和 `Ai-trace-id` 記錄失敗原因。

## 串接與工作階段

* **基礎位址**：`https://app-api.pixverse.ai`。生成與查詢都在 `/openapi/v2/` 下。
* **鑑權標頭**：`API-KEY: PASTE_API_KEY_HERE`；`Content-Type: application/json`；每個請求再加一個新的 `Ai-trace-id`。
* **兩套位址**：直連用 `https://app-api.pixverse.ai`，鑑權標頭為 `API-KEY`；只有管道明確確認對應本站閘道時，才使用 `https://api.dwchainless.com` 和 `Authorization: Bearer` 加本站 Key；不能只替換位址和鑑權。SimiRouter 管道是否對應這些路徑、是否改用統一影片協議，取決於管道設定；不能只換網域就假定欄位相容。
* **逾時與冪等**：建立請求逾時不能說明伺服器端沒有受理。先按已儲存的 `video_id` 查詢，確認不存在後再重試；不要連續提交相同提示詞來「催進度」。
* **錯誤判斷**：HTTP 200 也可能帶非零 `ErrCode`。業務錯誤要讀 `ErrCode`、`ErrMsg` 和可選的 `Error.Type`、`Error.Param`，不要只看 HTTP 狀態碼。

## 官方參考

* [PixVerse Quick Start](https\://docs.platform.pixverse.ai/quick-start-2394985m0)
* [PixVerse 文生影片 API](https\://docs.platform.pixverse.ai/text-to-video-generation-13016634e0)
* [PixVerse 圖生影片 API](https\://docs.platform.pixverse.ai/image-to-video-generation-13016633e0)
* [PixVerse 查詢任務狀態](https\://docs.platform.pixverse.ai/query-task-status-43051212e0)