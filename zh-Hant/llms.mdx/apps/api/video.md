# 影片

影片分為**生成**與**理解**：生成從文字/參考素材合成新影片；理解從現有影片提取摘要、事件和文字答案。二者請求、耗時與輸出完全不同。

## 概覽

| 能力    | 輸入         | 輸出        | 耗時量級    |
| ----- | ---------- | --------- | ------- |
| 文生影片  | 提示詞        | 影片檔案或下載位址 | 數十秒到數分鐘 |
| 圖生影片  | 首幀圖片 + 提示詞 | 影片檔案      | 數十秒到數分鐘 |
| 首尾幀控制 | 首幀、尾幀圖片    | 兩端受控的影片   | 數分鐘     |
| 影片理解  | 影片 + 問題    | 文字摘要或答案   | 與影片時長相關 |

## 核心概念

* **解析度**：常見 480p、720p、1080p。它決定畫面清晰度，也直接影響生成耗時與價格；草稿或預覽通常只支援較低解析度。
* **寬高比**：`16:9` 橫屏、`9:16` 直式、`1:1` 方形。比例與解析度共同決定實際像素，例如 1080p 直式是 `1080x1920`。
* **影格率（fps）**：每秒影格數，常見 24 或 30。提高影格率會讓檔案更大、生成更慢，不必然讓動作更自然。
* **時長**：單段影片的秒數，按模型設上限。部分模型支援用影格數代替時長，同時提交時二者誰優先要按介面說明確認。
* **參考素材**：圖片用於首幀、尾幀或風格參考；參考影片與音訊支援情況隨模型差異很大，不能預設存在。
* **任務狀態**：建立回傳的 ID 只代表受理。真正的成功要看查詢介面的終態和有效輸出位址，`done` 一類狀態不總是等於成功。

這些規格的可用值與上限由模型版本決定，逐項見各子頁請求參數表；不要把一個版本的欄位套給另一個版本。

## 介面說明

| 能力              | 模式                 | 官方協議                                           | 文件                                               |
| --------------- | ------------------ | ---------------------------------------------- | ------------------------------------------------ |
| Seedance 生成     | 非同步建立 → 查詢 → 下載    | 火山方舟 contents/generations/tasks                | [Seedance](/simidoc/zh-Hant/apps/api/video/seedance)                           |
| Kling 生成        | 非同步建立 → 查詢/回呼      | Kling 3.0 新任務協議                                | [Kling](/simidoc/zh-Hant/apps/api/video/kling)                                 |
| 即夢生成            | 非同步提交 → 查詢         | 火山視覺 CVSync2Async，AK/SK 簽名                     | [即夢（待接入）](/simidoc/zh-Hant/apps/api/video/jimeng)                              |
| Sora 參考         | 官方 Videos API 已關閉  | 僅保留介面結構參考                                      | [Sora](/simidoc/zh-Hant/apps/api/video/sora)                                   |
| Veo 生成          | 非同步 operation → 輪詢 | Gemini API `predictLongRunning`                | [Veo](/simidoc/zh-Hant/apps/api/video/veo)                                     |
| PixVerse 生成     | 非同步建立 → 查詢         | PixVerse OpenAPI v2                            | [PixVerse](/simidoc/zh-Hant/apps/api/video/pixverse)                           |
| DashScope 影片生成  | 非同步建立 → 查詢         | DashScope video-synthesis                      | [DashScope（Wan / HappyHorse）](/simidoc/zh-Hant/apps/api/video/dashscope-video) |
| Grok Imagine 生成 | 非同步建立 → 查詢         | xAI `/v1/videos`                               | [Grok Imagine](/simidoc/zh-Hant/apps/api/video/grok-imagine)                   |
| 影片理解            | 多模態請求 → 文字 / SSE   | Dots、Kimi Chat Completions；Gemini Interactions | [影片理解](/simidoc/zh-Hant/apps/api/video/understanding)                          |

## 請求流程

1. 建立請求回傳任務 ID，僅表示受理，不表示影片已生成。
2. 使用同一廠商/管道的任務查詢介面；建議間隔數秒並設定總等待上限，失敗、過期或取消立即結束。
3. 只有成功終態且存在有效影片輸出時才下載。儲存原始任務 ID、請求 ID 和失敗原因，避免只記「HTTP 200」。
4. 結果 URL 常有有效期，應及時轉存。下載連結不能當永久儲存位址。

影片生成通常不是 SSE；輪詢狀態不是即時影片流。音訊、解析度、時長、首尾幀及多參考能力按模型版本區分，不能把某一版本欄位套給所有影片模型。

## 模擬呼叫

以下以 Seedance 協議為例，展示建立、受理和查詢三個階段；內容為示意，位址與鑑權屬於火山方舟官方直連。

建立請求只提交提示詞和影片規格：

```json
{
  "model": "doubao-seedance-2-5-260628",
  "content": [
    { "type": "text", "text": "海边日落，镜头缓慢推进" }
  ],
  "resolution": "720p",
  "ratio": "16:9",
  "duration": 5
}
```

建立成功只回傳任務 ID，不是影片：

```json
{"id":"cgt-example"}
```

查詢到終態且有結果位址才算完成：

```json
{
  "id": "cgt-example",
  "status": "succeeded",
  "content": { "video_url": "https://example.com/video.mp4" },
  "error": null
}
```

狀態為 `queued` 或 `running` 時繼續等待；`failed`、`expired`、`cancelled` 立即停止輪詢並儲存 `error`。影片生成沒有 SSE 增量，結果只能透過輪詢或回呼取得。

## 廠商位址與 SimiRouter

各子頁按**廠商官方協議**整理欄位與流程。範例中的請求本文、路徑與狀態欄位，首先應視為廠商直連參考；只有頁面明確確認已對應到 SimiRouter 時，才可使用閘道位址 `https://api.dwchainless.com` 與本站 Key。閘道是否開放同名模型、使用哪條路徑以及欄位如何對應，以帳戶模型清單和目前頻道設定為準，不能只替換網域就把廠商請求直接送到閘道。

廠商 Key、火山 AK/SK 和本站 Key 不互通。管道沒有明確對應時，不要只替換網域就發起付費生成。

## 官方參考

* [火山方舟：建立影片生成任務](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)
* [火山方舟：查詢影片生成任務](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)
* [即夢影片生成介面](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh)
* [Kling 文生影片](https\://kling.ai/document-api/apiReference/model/textToVideo)
* [OpenAI Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)