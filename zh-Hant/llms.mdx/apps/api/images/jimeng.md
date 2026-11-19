# 即夢 / 火山方舟圖片生成

## 概覽

火山方舟（Volcengine Ark）的圖片生成介面使用 Seedream 系列模型（`doubao-seedream-*`），從文字或參考圖生成圖片。請求一次提交，同步回傳 `data[]`；部分模型還支援串流或批次生成。

| 你要做的事    | 輸入                 | 輸出   | 端點                                                                 |
| -------- | ------------------ | ---- | ------------------------------------------------------------------ |
| 從文字生成圖片  | `prompt`           | 新圖片  | `POST https://ark.cn-beijing.volces.com/api/v3/images/generations` |
| 參考圖生成或改圖 | `prompt` + `image` | 新圖片  | 同上                                                                 |
| 批次生成多張   | `prompt` + 批次生成參數  | 多張圖片 | 同上                                                                 |

## 核心概念

* **`size` 有兩種寫法**：解析度檔位（如 `2K`）或明確像素（如 `2048x2048`）。檔位是模型預設，不等於固定寬高；同一檔位下實際尺寸取決於模型與提示詞中的畫幅描述。
* **參考圖放在 `image`**：可以是 HTTP(S) URL 或 `data:image/...;base64,...`。傳陣列即為多圖參考，數量上限隨模型變化。
* **`watermark` 預設開啟**：預設 `true` 時會在圖片上新增「AI 生成」標識；需要無浮水印輸出時顯式傳 `false`，並確認用途符合適用的合成內容標識要求。
* **同步回傳**：普通請求直接等待 `data[]`。`stream` 只對 Seedream 5.0 lite、4.5、4.0 等部分模型開放，不能靠新增串流參數把其他模型變成非同步任務。
* **按張計費**：計費與生成張數相關。`sequential_image_generation` 的批次輸出會按實際生成的圖片張數累計，失敗項以 `data[].error` 單獨回傳。

## 規格與能力

| 模型 ID                             | `size` 檔位與上限                                          | 參考圖     | 輸出格式                                   |
| --------------------------------- | ----------------------------------------------------- | ------- | -------------------------------------- |
| `doubao-seedream-5-5-261028`      | `1K`、`1.5K`、`2K` 或 `WxH`；像素 921600–4624220，比例 1/16–16 | 最多 10 張 | `url` / `b64_json`；`png` 預設，也支援 `jpeg` |
| `doubao-seedream-5-0-lite-260128` | `2K`、`3K`、`4K` 或 `WxH`；像素 3686400–16777216，比例 1/16–16 | 最多 14 張 | `url` / `b64_json`；`png` / `jpeg`      |
| `doubao-seedream-4-5-251128`      | `2K`、`4K` 或 `WxH`；像素 3686400–16777216，比例 1/16–16      | 最多 14 張 | `url` / `b64_json`；`png` / `jpeg`      |
| `doubao-seedream-4-0-250828`      | `1K`、`2K`、`4K` 或 `WxH`；像素 921600–16777216，比例 1/16–16  | 最多 14 張 | `url` / `b64_json`；`png` / `jpeg`      |

像素上限按總像素計算，例如 16777216 像素對應 4096×4096。模型 ID 會隨版本更新，呼叫前以火山方舟模型目錄和[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)為準；`model` 也可以填推理接入點 ID（`ep-...`）。

## 呼叫流程

1. **準備金鑰**：在火山方舟控制台建立 API Key，請求標頭使用 `Authorization: Bearer $ARK_API_KEY`。
2. **選擇模型與尺寸**：確認模型支援的 `size` 檔位或像素範圍，並決定是否需要參考圖。
3. **傳送 JSON 請求**：向 `/api/v3/images/generations` 提交 `model`、`prompt`，按需新增 `image`、`size`、`response_format` 和 `watermark`。
4. **讀取 `data[]`**：`response_format` 為 `url` 時取 `data[].url`（有效期 24 小時），為 `b64_json` 時解碼 `data[].b64_json`。
5. **儲存並驗收**：檢查檔案能否開啟、實際尺寸與內容；批次生成時逐項檢查 `data[].error`，不要只看 HTTP 狀態。
6. **核對費用**：在使用日誌中確認模型、張數與扣費，批次輸出按實際成功生成的張數計算。

## 模擬呼叫

以下報文為示意，不是真實帳戶回傳；URL 與 Base64 已截斷，數值不代表目前價格。

請求：

```json
{
  "model": "doubao-seedream-5-5-261028",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "size": "2K",
  "response_format": "url",
  "watermark": true
}
```

成功回應（同步）：

```json
{
  "created": 1763366400,
  "model": "doubao-seedream-5-5-261028",
  "data": [
    {
      "url": "https://example.com/generated-image.png",
      "size": "2048x2048",
      "output_format": "png"
    }
  ]
}
```

未生成圖片時回傳頂層 `error`；批次生成中單張失敗時，失敗項在 `data[].error` 中給出 `code` 與 `message`。

## 串接與工作階段

* **Base URL**：`https://ark.cn-beijing.volces.com/api/v3`。
* **鑑權**：`Authorization: Bearer $ARK_API_KEY`。金鑰只放在請求標頭，不要寫進提示詞或原始碼。
* **與 OpenAI Images 的差異**：路徑是 `/api/v3/images/generations`，不是 `/v1/images/generations`；沒有 `quality` 參數；`size` 可以直接寫 `1K`、`2K` 檔位；回傳 `data[].url` 或 `data[].b64_json`。
* **經本站閘道呼叫**：請求位址改為 `https://api.dwchainless.com/v1/images/generations`，鑑權使用本站 Key；請求主體是否原樣透傳、模型 ID 是否可用，以管道和[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)為準。
* **逾時**：同步生成可能持續數十秒，用戶端逾時應明顯高於普通文字請求；逾時後先查呼叫日誌，確認是否已產生圖片和費用，再決定是否重試。
* **批次與串流**：`sequential_image_generation` 和 `stream` 僅部分模型支援；同時開啟時要按最終完成事件或完整 `data[]` 驗收，中間結果不算完成圖片。

## 官方參考

* [火山方舟圖片生成 API](https\://docs.volcengine.com/docs/82379/1541523)
* [火山方舟 Base URL 及鑑權](https\://docs.volcengine.com/docs/ark/base-url-and-authentication)
* [Seedream 系列圖片生成與編輯](https\://docs.volcengine.com/docs/lake-ai-service/image-generation-and-editing-doubao-seed-ream-series-models?lang=en)