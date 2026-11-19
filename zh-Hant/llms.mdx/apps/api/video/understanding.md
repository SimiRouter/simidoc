# 影片理解

影片理解將已有影片作為輸入，回傳摘要、畫面描述、事件順序或問題答案；它不是根據提示詞生成新影片。Dots、Kimi 和 Gemini 均提供影片輸入能力，採用的內容格式、檔案引用方式和身分驗證不同。

## 廠商與通訊協定

| 文件                      | 官方範例模型             | 影片輸入                                       | 請求與回應                                                    |
| ----------------------- | ------------------ | ------------------------------------------ | -------------------------------------------------------- |
| [Dots 影片理解](/simidoc/zh-Hant/apps/api/video/understanding/dots)     | `dots3-note-prev`  | 模型服務可存取的 `video_url.url`                   | Chat Completions 訊息陣列；最終文字位於 `choices[].message.content` |
| [Kimi 影片理解](/simidoc/zh-Hant/apps/api/video/understanding/kimi)     | `kimi-k3`          | Base64 影片 data URL，或 Moonshot `ms://` 檔案引用 | Chat Completions 訊息陣列；最終文字位於 `choices[].message.content` |
| [Gemini 影片理解](/simidoc/zh-Hant/apps/api/video/understanding/gemini) | `gemini-3.8-flash` | 行內影片資料或 Google 支援的檔案 URI                   | 本文採用 Interactions；文字位於 `steps[].content[]`               |

Dots 影片請求使用官方 `api-key` 請求標頭；Kimi 使用 Bearer；Gemini 使用 `x-goog-api-key`。Dots 和 Kimi 的 `video_url` 是廠商支援的多模態擴展，不是所有 OpenAI 相容服務都支援的影片通用標準。不能僅因路徑同為 `/v1/chat/completions` 就互換影片載荷。

## 同步、串流與檔案引用

* **非串流**：一次 HTTP 請求等待完整文字回應，不回傳影片生成任務 ID。
* **串流**：以 SSE 增量回傳文字；首個事件前可能仍需下載、解碼和分析影片。串流不代表持續上傳攝影機，也不保證立即回傳首字。
* **檔案引用**：先上傳到廠商儲存，再在分析請求中引用。上傳完成不等於已完成分析，各廠商的檔案 ID 不互通。
* **平行請求**：由用戶端發起多個獨立請求，每個請求單獨計算限流、上下文和用量，不是本文中的某個“平行”參數。

## 輸入準備

使用有權處理的影片。公開影片直鏈、平台分享頁、本機路徑和 Base64 資料是不同輸入，必須按對應通訊協定傳入。小紅書或其他網站的分享頁面不等同於可下載的影片檔案 URL；需要登入或防盜鏈的影片也不一定能由模型服務讀取。

影片長度、解析度、取樣影格數和檔案大小會影響耗時、Token 與費用；具體限制見廠商頁面。時間點與事件判斷應對照原影片複核，不作為精確逐影格取證或強制對齊結果。

## SimiRouter 串接

上述子頁提供廠商官方直連範例，使用廠商 Key。透過 SimiRouter 呼叫時，須確認帳戶可用的完整模型 ID、管道的影片輸入對應及檔案引用支援；不能把模型官方支援直接寫成本站已整合測試通過。廠商 Key 與 SimiRouter Key 不通用。

## 官方參考

* [Dots：影片輸入](https\://dots.ai/platform/docs#video-input)
* [Kimi K3 快速開始](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart)與[視覺模型](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Google：影片理解](https\://ai.google.dev/gemini-api/docs/video-understanding)