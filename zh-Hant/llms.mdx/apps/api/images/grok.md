# xAI Grok 圖片生成

## 概覽

xAI Grok 的圖片生成介面沿用 OpenAI Images 的路徑和回應封裝，但請求參數是 xAI 原生欄位：用 `aspect_ratio` 與 `resolution` 指定畫幅，而不是 `size`。預設同步回傳，也可以開啟 `deferred` 後輪詢任務。

| 你要做的事    | 輸入                          | 輸出               | 端點                                            |
| -------- | --------------------------- | ---------------- | --------------------------------------------- |
| 從文字生成圖片  | `prompt`                    | 新圖片              | `POST https://api.x.ai/v1/images/generations` |
| 一次生成多張   | `prompt` + `n`（1–10）        | 多張圖片             | 同上                                            |
| 後台生成後取結果 | `prompt` + `deferred: true` | `request_id`，再輪詢 | 同上，輪詢 `GET /v1/images/{request_id}`           |
| 編輯已有圖片   | `prompt` + 圖片               | 編輯後的圖片           | `POST https://api.x.ai/v1/images/edits`       |

## 核心概念

* **`aspect_ratio` 取代 `size`**：介面不接受 OpenAI 的 `size` 和 `style`。畫幅由 `aspect_ratio` 控制，常用值包括 `1:1`、`16:9`、`9:16`、`4:3`、`3:4`、`2:3`、`3:2`、`21:9` 與 `auto`。
* **`resolution` 控制解析度檔位**：取 `1k` 或 `2k`，預設 `1k`。它是檔位，不是像素值；同一檔位下的實際寬高由 `aspect_ratio` 決定。
* **`quality` 只對 2.0 模型生效**：可選 `low`、`medium`、`auto`；`auto` 在生成時目前按 `low` 處理，在編輯時按 `medium` 處理。
* **預設同步，`deferred` 可選非同步**：同步請求直接回傳 `data[]`；設定 `deferred: true` 後立即回傳 `request_id`，再輪詢 `GET /v1/images/{request_id}`。延遲任務只支援 `response_format: "url"`，結果保留 24 小時。
* **URL 是暫時的**：`response_format` 為 `url`（預設）時，回傳的圖片位址會過期；需要長期儲存時及時下載，或改用 `b64_json`。
* **按張計費**：`n` 表示單次請求生成張數，範圍為 1–10。回應的 `usage.cost_in_usd_ticks` 給出該次請求的費用資訊，實際結算以本站帳單為準。

## 規格與能力

| 模型 ID                    | 解析度檔位     | 寬高比                                                                                                         | 參考圖                               | 回傳格式               |
| ------------------------ | --------- | ----------------------------------------------------------------------------------------------------------- | --------------------------------- | ------------------ |
| `grok-imagine-image-2.0` | `1k`、`2k` | `1:1`、`16:9`、`9:16`、`4:3`、`3:4`、`3:2`、`2:3`、`2:1`、`1:2`、`19.5:9`、`9:19.5`、`20:9`、`9:20`、`21:9`、`5:2`、`auto` | 生成介面不接收參考圖；編輯走 `/v1/images/edits` | `url` 或 `b64_json` |

`grok-2-image` 是舊模型名，現行官方介面文件使用 `grok-imagine-image-2.0`。呼叫前從[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)確認本站管道實際提供的模型 ID，不要直接套用舊教學中的名稱。

## 呼叫流程

1. **準備金鑰**：在 xAI 控制台建立 Key，請求標頭使用 `Authorization: Bearer $XAI_API_KEY`。
2. **確認模型**：在[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)核對 `grok-imagine-image-2.0` 或管道提供的等價模型。
3. **選擇畫幅**：設定 `aspect_ratio` 和 `resolution`；不要傳送 `size`。
4. **傳送請求**：向 `/v1/images/generations` 提交 JSON。預計耗時較長時加 `deferred: true`。
5. **讀取結果**：同步回應取 `data[].url` 或 `data[].b64_json`；延遲任務輪詢到 `done` 後再取 `data[]`。
6. **儲存並驗收**：在 URL 過期前下載圖片，檢查檔案能否開啟、尺寸與內容，再核對使用紀錄。

## 模擬呼叫

以下報文為示意，不是真實帳戶回傳；URL 與費用數值已截斷或僅作示例。

同步請求：

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "response_format": "url"
}
```

同步成功回應：

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

延遲任務請求：

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "deferred": true
}
```

提交後的示意回應：

```json
{
  "request_id": "req_example_01"
}
```

輪詢完成的示意回應（HTTP 200；處理中為 202，失敗時回傳 `error.code` 與 `error.message`）：

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

## 串接與工作階段

* **Base URL**：`https://api.x.ai/v1`。生成端點為 `/v1/images/generations`，編輯端點為 `/v1/images/edits`。
* **鑑權**：`Authorization: Bearer $XAI_API_KEY`。OpenAI SDK 可以把 `base_url` 設為 `https://api.x.ai/v1` 重複使用，但請求欄位仍按 xAI 文件填寫。
* **與 OpenAI 的差異**：路徑和 `data[]` 封裝相似，但 `size`、`style` 不受支援；用 `aspect_ratio`、`resolution`、`quality` 代替。`n` 上限為 10。
* **延遲任務**：`deferred` 只支援 URL 輸出，提交後輪詢 `GET /v1/images/{request_id}`；結果保留 24 小時，逾時需重新生成。
* **經本站閘道呼叫**：請求位址改為 `https://api.dwchainless.com/v1/images/generations`，鑑權使用本站 Key；模型 ID 與參數透傳以管道為準。
* **逾時**：同步生成通常在一次請求內完成，用戶端仍應留出足夠逾時；耗時不可控或批次生成時優先使用 `deferred`，不要在逾時後盲目重送。

## 官方參考

* [xAI 圖片生成能力](https\://docs.x.ai/developers/model-capabilities/images/generation)
* [xAI Images REST API 參考](https\://docs.x.ai/developers/rest-api-reference/inference/images)