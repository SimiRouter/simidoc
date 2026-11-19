# BFL FLUX 圖片生成

## 概覽

Black Forest Labs（BFL）的 FLUX API 採用「提交任務 + 輪詢結果」的非同步模型。提交請求只回傳任務 ID 和 `polling_url`，圖片生成完成後才從輪詢結果中讀取簽章 URL。

| 你要做的事     | 輸入                        | 輸出                      | 端點                                              |
| --------- | ------------------------- | ----------------------- | ----------------------------------------------- |
| 從文字生成圖片   | `prompt`、`width`、`height` | 任務 `id` 與 `polling_url` | `POST https://api.bfl.ai/v1/flux-pro-1.1`       |
| 按比例生成寬幅圖片 | `prompt`、`aspect_ratio`   | 任務 `id` 與 `polling_url` | `POST https://api.bfl.ai/v1/flux-pro-1.1-ultra` |
| 參考圖生成或編輯  | `prompt` + `input_image`  | 任務 `id` 與 `polling_url` | `POST https://api.bfl.ai/v1/flux-2-pro` 等       |
| 取得最終圖片    | `polling_url`             | `result.sample` 簽章 URL  | `GET {polling_url}`                             |

## 核心概念

* **尺寸用 `width` / `height`**：FLUX 1.1 pro 的寬高範圍是 256–1440，且必須是 32 的倍數。它不是解析度檔位，也不是 `size` 字串。
* **Ultra 用 `aspect_ratio`**：`/v1/flux-pro-1.1-ultra` 沒有寬高欄位，改用 `aspect_ratio`（預設 `16:9`，文件描述範圍為 `21:9` 到 `9:21`）。
* **`seed` 控制可重現性**：相同的提示詞、參數和 `seed` 用於對比不同設定；它不保證跨模型或跨版本得到相同畫面。
* **`steps` / `guidance` 只出現在部分模型**：FLUX.2 flex 支援 `steps`（1–50）和 `guidance`（1.5–10.0）；FLUX 1.1 pro 沒有這兩個欄位。
* **提交與結果是兩次請求**：提交回傳 `id`、`polling_url` 和可選的 `cost`；輪詢到 `Ready` 後才從 `result.sample` 取圖，處理中為 `Pending`，失敗或內容審核會回傳對應狀態。
* **簽章 URL 有效期約 10 分鐘**：`result.sample` 過期很快，必須及時下載並轉存，不要把該位址長期當作公開圖片連結。

## 規格與能力

| 端點                       | 尺寸控制                                            | 參考圖                                            | 其他主要欄位                                                            | 回傳格式                 |
| ------------------------ | ----------------------------------------------- | ---------------------------------------------- | ----------------------------------------------------------------- | -------------------- |
| `/v1/flux-pro-1.1`       | `width`、`height`：256–1440，32 的倍數；預設 1024×768    | `image_prompt`（Base64，Flux Redux 風格參考）         | `seed`、`prompt_upsampling`、`safety_tolerance` 0–6、`output_format` | 輪詢後取 `result.sample` |
| `/v1/flux-pro-1.1-ultra` | 無 `width` / `height`；用 `aspect_ratio`，預設 `16:9` | `image_prompt`、`image_prompt_strength` 0.0–1.0 | `seed`、`prompt_upsampling`、`raw`、`safety_tolerance` 0–6           | 同上                   |
| `/v1/flux-2-pro`         | `width`、`height`：最小 64，文件未給上限                   | `input_image` 至 `input_image_8`，最多 8 張         | `seed`、`safety_tolerance` 0–7、`output_format`                     | 同上                   |
| `/v1/flux-2-flex`        | `width`、`height`：最小 64，文件未給上限                   | `input_image` 至 `input_image_8`，最多 8 張         | `steps` 1–50、`guidance` 1.5–10.0、`seed`、`output_format`           | 同上                   |

`output_format` 可選 `jpeg`、`png`、`webp`，預設 `jpeg`。表中未列上限的端點，以對應端點的 OpenAPI schema 為準；不要把一個端點的寬高限制套到另一個端點。

## 呼叫流程

1. **準備金鑰**：在 BFL 控制台建立 API Key，請求標頭使用 `x-key: $BFL_API_KEY`，不是 `Authorization: Bearer`。
2. **選擇端點**：按模型能力選擇 `/v1/flux-pro-1.1`、`/v1/flux-pro-1.1-ultra` 或其他 `/v1/flux-*` 端點。
3. **提交任務**：傳送 JSON，設定 `prompt`、尺寸欄位、`output_format` 和可選的 `seed`。
4. **儲存 `polling_url`**：從回應中讀取 `id` 與 `polling_url`，不要自行拼接輪詢位址。
5. **輪詢到 `Ready`**：用相同的 `x-key` 請求 `polling_url`；`Pending` 時繼續等待，`Error` 或審核狀態時停止並記錄原因。
6. **下載並驗收**：在簽章 URL 過期前下載 `result.sample`，檢查檔案能否開啟、尺寸與內容，再核對 `cost` 和使用紀錄。

## 模擬呼叫

以下報文為示意，不是真實帳戶回傳；任務 ID、URL 和費用數值僅用於說明結構。

提交請求：

```json
{
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "width": 1024,
  "height": 768,
  "seed": 42,
  "output_format": "jpeg",
  "safety_tolerance": 2
}
```

提交成功回應（非同步，尚未生成圖片）：

```json
{
  "id": "task_example_01",
  "polling_url": "https://api.bfl.ai/v1/get_result?id=task_example_01",
  "cost": 0.04
}
```

輪詢完成回應（`status` 為 `Ready`）：

```json
{
  "id": "task_example_01",
  "status": "Ready",
  "progress": 1,
  "result": {
    "sample": "https://delivery.example.bfl.ai/sample/image.jpeg"
  }
}
```

輪詢期間還可能看到 `Pending`、`Error`、`Request Moderated`、`Content Moderated` 等狀態。審核不通過時 `result` 可能為 `null`，原因在 `details` 中。

## 串接與工作階段

* **Base URL**：`https://api.bfl.ai`；也提供 `https://api.eu.bfl.ai` 和 `https://api.us.bfl.ai`。使用哪個入口，就輪詢回應裡回傳的同一個 `polling_url`。
* **鑑權**：`x-key: $BFL_API_KEY`。這是與 OpenAI 風格介面最明顯的差異，不要把 Key 放進 `Authorization` 標頭。
* **完全非同步**：提交請求不回傳圖片，只回傳 `id` 和 `polling_url`；必須再送一次 `GET` 才能拿到結果。
* **與 OpenAI 的差異**：沒有 `/v1/images/generations` 端點，也沒有 `size`、`quality`、`n` 欄位；尺寸由 `width` / `height` 或 `aspect_ratio` 控制。
* **回呼替代輪詢**：請求可以帶 `webhook_url` 和 `webhook_secret`，由 BFL 在完成時回呼；使用回呼時仍要校驗簽章並處理失敗事件。
* **經本站閘道呼叫**：把位址換成 `https://api.dwchainless.com`，鑑權使用本站 Key；FLUX 是非同步任務，閘道是否透傳 `polling_url` 和 `x-key` 標頭以管道為準，未開通時按上面的官方位址直連。
* **經本站閘道呼叫**：請求位址與鑑權方式以本站管道說明為準；本頁欄位是 BFL 原生協議，接入閘道前先確認模型可用性與參數透傳範圍。
* **逾時**：提交請求應快速回傳，逾時後可先查詢是否已建立任務；輪詢建議間隔約 0.5 秒，整體等待時間按模型和佇列長度設定上限，不要無限重試。

## 官方參考

* [BFL 快速開始：文字生成圖片](https\://docs.bfl.ai/quick_start/generating_images)
* [BFL OpenAPI 規範](https\://api.bfl.ai/openapi.json)
* [BFL API 文件全文](https\://docs.bfl.ai/llms-full.txt)