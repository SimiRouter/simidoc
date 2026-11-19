# DashScope 影片生成（Wan / HappyHorse）

## 概覽

Wan 與 HappyHorse 都是阿里雲百煉平台上的影片生成模型族，共用同一套 DashScope 非同步協定：提交端點、`X-DashScope-Async` 標頭、任務查詢路徑、狀態字串與結果欄位都相同。差別只在三處——模型 ID、輸入結構、畫幅參數。

| 你要做的事                 | 輸入                                                       | 輸出                        | 端點                                                            |
| --------------------- | -------------------------------------------------------- | ------------------------- | ------------------------------------------------------------- |
| 文生影片（Wan）             | 提示詞、`parameters.size`、`duration`                         | `task_id`                 | `POST /api/v1/services/aigc/video-generation/video-synthesis` |
| 首幀圖生影片（Wan）           | 提示詞、`input.img_url`、`parameters.resolution`              | `task_id`                 | 同一提交端點                                                        |
| 文生影片（HappyHorse）      | 提示詞、`resolution`、`ratio`、`duration`                      | `task_id`                 | 同一提交端點                                                        |
| 首幀或參考圖生影片（HappyHorse） | `input.media` 中的 `first_frame` 或 1–9 張 `reference_image` | `task_id`                 | 同一提交端點                                                        |
| 查詢任務                  | `task_id`                                                | `task_status`、`video_url` | `GET /api/v1/tasks/{task_id}`                                 |

## 核心概念

* **任務生命週期**：`PENDING → RUNNING → SUCCEEDED`，失敗終態為 `FAILED`，另有 `CANCELED` 與 `UNKNOWN`。只有 `SUCCEEDED` 才讀取 `output.video_url`。
* **兩個 ID 分工不同**：`output.task_id` 用於查詢任務；`request_id` 只用於追蹤一次 HTTP 請求。排錯時兩者都要保留。
* **輪詢節奏**：官方建議每 15 秒查詢一次。任務 ID 與結果 URL 的有效期均為 24 小時，逾時後查詢會傳回 `UNKNOWN`。
* **輸入結構按模型族區分**：Wan 的圖生影片用 `input.img_url`；HappyHorse 用 `input.media` 陣列，元素帶 `type`（`first_frame` 或 `reference_image`）與 `url`。兩套結構不能互換。
* **畫幅參數按模型族區分**：Wan 文生影片用 `parameters.size`（`宽*高`，如 `1280*720`），Wan 圖生影片用 `parameters.resolution`（`480P`、`720P`、`1080P`）；HappyHorse 文生與參考圖生影片用 `parameters.ratio`（如 `16:9`），首幀圖生影片跟隨首幀圖片。
* **音訊只在部分 Wan 代際**：Wan2.6 與 Wan2.5 預設生成與畫面匹配的音樂或音效，也可用 `input.audio_url` 提供 WAV、MP3；Wan2.2 與 Wan2.1 預設輸出無聲影片。HappyHorse 文件沒有音訊輸入或輸出參數。
* **計費按輸出秒數計量**：查詢回應的 `usage.duration` 是輸出影片時長。單價、失敗任務結算和退款規則以廠商計價頁與帳單為準。

## 規格與能力

Wan 的取值：

| 指標     | 已核實取值                                                                                                                                                                                               |
| ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 文生影片模型 | `wan2.6-t2v`、`wan2.5-t2v-preview`、`wan2.2-t2v-plus`、`wan2.1-t2v-turbo`、`wan2.1-t2v-plus`                                                                                                            |
| 圖生影片模型 | `wan2.6-i2v`、`wan2.6-i2v-flash`、`wan2.5-i2v-preview`、`wan2.2-i2v-plus`、`wan2.2-i2v-flash`、`wan2.1-i2v-turbo`、`wan2.1-i2v-plus`                                                                      |
| 解析度    | 文生影片 `size`：`832*480`、`480*832`、`624*624`、`1280*720`、`720*1280`、`960*960`、`1088*832`、`832*1088`、`1920*1080`、`1080*1920`、`1440*1440`、`1632*1248`、`1248*1632`；圖生影片 `resolution`：`480P`、`720P`、`1080P` |
| 時長     | `wan2.6-t2v` 為 2–15 秒；`wan2.5-t2v-preview` 為 5 或 10 秒；`wan2.2`、`wan2.1` 文生影片固定 5 秒；`wan2.1-i2v-turbo` 支援 3、4、5 秒                                                                                    |
| 音訊     | Wan2.6、Wan2.5 自動生成音樂或音效；`audio_url` 支援 WAV、MP3，3–30 秒，最大 15 MB；Wan2.2、Wan2.1 預設無聲                                                                                                                   |
| 參考素材   | 圖生影片用 `input.img_url`，支援公網 URL 或 Base64；圖片寬高 240–8000 像素，Wan2.6/2.5 最大 20 MB                                                                                                                        |

HappyHorse 的取值：

| 指標    | 已核實取值                                                                                               |
| ----- | --------------------------------------------------------------------------------------------------- |
| 模型 ID | `happyhorse-1.1-t2v`、`happyhorse-1.0-t2v`、`happyhorse-1.1-i2v`、`happyhorse-1.1-r2v`                 |
| 解析度   | `480P`、`720P`、`1080P`，預設 `1080P`                                                                    |
| 寬高比   | 文生與參考圖生影片：`16:9`（預設）、`9:16`、`1:1`、`4:3`、`3:4`、`4:5`、`5:4`、`9:21`、`21:9`；圖生影片跟隨首幀，允許 1\:2.5 到 2.5\:1 |
| 時長    | 3–15 秒，預設 5 秒；該範圍在 `happyhorse-1.0-t2v`、圖生影片和參考圖生影片文件中明確，`happyhorse-1.1-t2v` 文件未給範圍                |
| 參考圖片  | 圖生影片 1 張首幀，最短邊至少 300 像素；參考圖生影片 1–9 張，最短邊至少 400 像素；單張最大 20 MB；格式 JPEG、JPG、PNG、WEBP                   |
| 其他參數  | `watermark` 預設 `true`，開啟時右下角顯示 HappyHorse；`seed` 範圍 0–2147483647                                    |

Wan 的 `size` 是具體像素，`resolution` 是檔位，兩者服務於不同端點：文生影片 1080P 直式要寫 `1080*1920`，不能寫 `1080P`；圖生影片反過來，只接受 `480P`、`720P`、`1080P`。HappyHorse 的首幀圖生影片不讀 `ratio`，輸出比例由圖片決定。Wan2.2 與 Wan2.1 文生影片固定 5 秒，加長 `duration` 不會得到更長片段。Wan2.6 與 Wan2.5 會自動生成音軌，下游不需要音訊時應在後期移除，或先確認該模型是否提供關閉參數。參考圖數量為 1–9 張時，提示詞中的 `[Image N]` 必須與 `media` 順序一致，順序錯了會引用錯圖。

## 呼叫流程

1. 在阿里雲百煉建立 API Key。模型、請求位址和 Key 必須屬於同一區域，跨區呼叫會失敗。
2. 選擇模型族與模式：Wan 的文生/圖生影片，或 HappyHorse 的文生/首幀圖生/參考圖生影片。輸入結構不同，不能重複使用同一份請求主體。
3. 向 `POST /api/v1/services/aigc/video-generation/video-synthesis` 提交 JSON，帶上 `Authorization: Bearer`、`Content-Type: application/json` 和 `X-DashScope-Async: enable`。
4. 儲存 `output.task_id` 和 `request_id`。建立回應傳回 `PENDING` 只代表排隊成功。
5. 每 15 秒呼叫 `GET /api/v1/tasks/{task_id}`。`SUCCEEDED` 後讀取 `output.video_url`；`FAILED` 時讀取 `output.code` 與 `output.message`。
6. 在 24 小時內下載並轉存影片。任務過期後不能再查詢，結果 URL 也不能繼續依賴。

## 模擬呼叫

以下為示意報文，任務 ID、請求 ID、URL 與用量都不是真實帳戶資料。

Wan 文生影片的建立請求：

```json
{
  "model": "wan2.5-t2v-preview",
  "input": {
    "prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "parameters": {
    "size": "1280*720",
    "duration": 5,
    "prompt_extend": true,
    "watermark": false,
    "seed": 20260804
  }
}
```

HappyHorse 首幀圖生影片的建立請求：

```json
{
  "model": "happyhorse-1.1-i2v",
  "input": {
    "prompt": "示例：让画面中的帆船缓慢向前移动。",
    "media": [
      {
        "type": "first_frame",
        "url": "https://example.com/demo-first-frame.png"
      }
    ]
  },
  "parameters": {
    "resolution": "720P",
    "duration": 5,
    "watermark": false,
    "seed": 20260804
  }
}
```

兩族模型的建立成功回應結構一致，只傳回排隊狀態：

```json
{
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "PENDING"
  },
  "request_id": "demo-request-0001"
}
```

查詢到成功終態：

```json
{
  "request_id": "demo-request-0001",
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "SUCCEEDED",
    "video_url": "https://example.com/demo-video.mp4",
    "orig_prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "usage": {
    "duration": 5,
    "output_video_duration": 5,
    "video_count": 1,
    "SR": 720
  }
}
```

`PENDING`、`RUNNING` 繼續等待；`FAILED`、`CANCELED` 立即停止並儲存 `output.code` 與 `output.message`；`UNKNOWN` 先確認任務是否已超過 24 小時。

## 接入與工作階段

* **基礎位址**：`https://{WorkspaceId}.{region}.maas.aliyuncs.com`。新加坡、美國、北京、法蘭克福、東京使用不同區域主機，提交與查詢路徑相同。
* **鑑權標頭**：`Authorization: Bearer PASTE_API_KEY_HERE`；建立任務必須加 `X-DashScope-Async: enable`，缺少該標頭會收到同步呼叫錯誤。
* **兩套位址**：直連用 `https://{WorkspaceId}.{region}.maas.aliyuncs.com`；只有管道明確確認對應本站閘道時，才使用 `https://api.dwchainless.com` 和 `Authorization: Bearer` 加本站金鑰；不能只替換位址和鑑權。SimiRouter 管道若做統一封裝，`task_id`、狀態字串和結果欄位可能被改寫；以管道文件為準。
* **逾時與冪等**：提交逾時後先儲存並查詢可能已建立的 `task_id`，不要立即重複提交。輪詢請求本身可以重試，但要設定總等待上限。
* **結果儲存**：`video_url` 是帶時效的下載位址。需要長期使用時，下載後轉碼或轉存，不要把廠商 URL 直接寫進產品資料庫當作永久資源。

## 官方參考

* [Wan 文生影片 API 參考](https\://www.alibabacloud.com/help/en/model-studio/legacy-wan-text-to-video-api-reference)
* [Wan 圖生影片 API 參考](https\://www.alibabacloud.com/help/en/model-studio/image-to-video-api-reference)
* [Wan2.5 圖生影片模型說明](https\://www.alibabacloud.com/help/en/model-studio/wan2-5-i2v)
* [HappyHorse 文生影片 API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-text-to-video-api-reference)
* [HappyHorse 首幀圖生影片 API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-image-to-video-api-reference)
* [HappyHorse 參考圖生影片 API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-reference-to-video-api-reference)