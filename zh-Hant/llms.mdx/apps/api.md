# API 參考

SimiRouter 使用 API Key 驗證請求，並根據模型、群組和管道轉發模型呼叫。相容介面與廠商原生介面可能採用不同的位址、身分驗證方式和參數結構，不能只替換網域後混用。

## 概覽

介面按三層組織：先選能力（文字、圖片、影片、音訊、工具、模型查詢），再選協定（OpenAI 相容、Gemini 原生、Claude Messages），最後在介面頁核對參數。三種呼叫形態決定請求怎麼寫：

| 形態      | 特徵               | 典型介面           |
| ------- | ---------------- | -------------- |
| 同步      | 同一連線回傳完整結果       | 模型清單、圖片生成、音訊轉錄 |
| 串流（SSE） | 同一連線分批回傳事件       | 聊天、圖片理解、工具呼叫   |
| 非同步任務   | 先回傳任務 ID，再查詢任務狀態 | 影片生成、官方微調      |

用戶端逾時或斷開連線不一定意味著上游任務已取消，生成類請求應先核對任務和使用記錄，避免重複提交。

## 串接準備

1. 按[註冊 SimiRouter Key](/simidoc/zh-Hant/apps/getting-started)建立金鑰。
2. 從[模型廣場](https://api.dwchainless.com/zh-Hant/pricing/)選擇帳戶可用的完整模型 ID。
3. 在具體介面頁確認服務位址、請求格式和模型要求。SimiRouter 的 API 根位址為 `https://api.dwchainless.com`；`/v1` 或 `/v1beta` 由介面路徑決定。
4. 將金鑰儲存在環境變數或伺服器端金鑰儲存中。真實請求可能產生費用，不要在瀏覽器前端或公開程式碼中暴露金鑰。

[API 指令碼串接](/simidoc/zh-Hant/apps/api-script)提供一次完整文字請求的 Python、Node.js、curl 和 Go 範例。

## 服務位址

切換到廠商直連前，請核對介面路徑、身分驗證、模型 ID 和請求欄位。只有兩端使用相同通訊協定且介面頁明確說明相容時，才可以沿用請求結構。

| 服務                              | 位址                                           | 鑑權                                      |
| ------------------------------- | -------------------------------------------- | --------------------------------------- |
| SimiRouter 閘道                   | `https://api.dwchainless.com`                | `Authorization: Bearer` 加本站 Key         |
| Google Gemini API（AI Studio 金鑰） | `https://generativelanguage.googleapis.com`  | `x-goog-api-key`                        |
| Google Vertex AI                | `https://{region}-aiplatform.googleapis.com` | OAuth 存取權杖                              |
| OpenAI                          | `https://api.openai.com`                     | `Authorization: Bearer` 加 OpenAI Key    |
| Anthropic                       | `https://api.anthropic.com`                  | `x-api-key`                             |
| xAI                             | `https://api.x.ai`                           | `Authorization: Bearer`                 |
| 火山方舟                            | `https://ark.cn-beijing.volces.com/api/v3`   | `Authorization: Bearer`                 |
| 阿里雲 DashScope                   | `https://dashscope.aliyuncs.com`             | `Authorization: Bearer` 加 DashScope Key |

本機偵錯時閘道位址用 `http://127.0.0.1:3001`。廠商金鑰與本站 Key 不互通，替換位址時要一併替換鑑權。

## 功能目錄

| 功能                                | 內容                                                                         | 呼叫方式                            |
| --------------------------------- | -------------------------------------------------------------------------- | ------------------------------- |
| [聊天](/simidoc/zh-Hant/apps/api/chat)                      | Chat Completions、Responses、Claude Messages、Gemini 內容生成                     | 非串流請求等待完整回應；串流請求逐步接收 SSE 事件     |
| [繪圖](/simidoc/zh-Hant/apps/api/images)                    | 圖片生成、編輯、參考圖生成和圖片識別，涵蓋 OpenAI、Gemini、Qwen、即夢、Grok、FLUX 通訊協定                 | 按通訊協定回傳圖片資料、位址或文字；支援串流與否見具體介面   |
| [影片](/simidoc/zh-Hant/apps/api/video)                     | Seedance、Kling、Veo、PixVerse、Wan、Happy Horse、Grok Imagine 生成通訊協定與影片理解；即夢待串接 | 影片生成通常先提交任務，再查詢結果；影片理解使用多模態內容介面 |
| [音訊](/simidoc/zh-Hant/apps/api/audio)                     | OpenAI、Gemini 和 MiMo 的音訊輸入輸出                                               | 檔案請求、二進位音訊或串流事件，不能混用回應解析器       |
| [語音合成](/simidoc/zh-Hant/apps/api/audio/speech)            | 文字轉語音                                                                      | 回傳音訊檔案或模型支援的串流事件                |
| [語音轉錄](/simidoc/zh-Hant/apps/api/audio/transcriptions)    | 音訊轉原語言文字                                                                   | 上傳音訊後回傳轉錄結果                     |
| [音訊翻譯](/simidoc/zh-Hant/apps/api/audio/translations)      | 音訊轉英文文字                                                                    | 上傳音訊後回傳英文文字，不是語音翻譯輸出            |
| [音樂（不支援）](/simidoc/zh-Hant/apps/api/music)                | Google Lyria 官方呼叫參考                                                        | 僅提供 Google 官方直連參考               |
| [嵌入（不支援）](/simidoc/zh-Hant/apps/api/pending/embeddings)   | OpenAI、Gemini 官方向量介面參考                                                     | 僅提供廠商官方直連參考                     |
| [重新排序](/simidoc/zh-Hant/apps/api/pending/rerank)          | 文件相關性排序                                                                    | 按頁面列出的廠商通訊協定呼叫                  |
| [即時語音](/simidoc/zh-Hant/apps/api/pending/realtime)        | OpenAI Realtime 通訊協定                                                       | 雙向即時連接，不是普通 HTTP 音訊檔案請求         |
| [工具](/simidoc/zh-Hant/apps/api/tools)                     | Function Calling、網路搜尋                                                      | 模型提出工具呼叫後，按工具型別執行並回傳結果          |
| [內容審核](/simidoc/zh-Hant/apps/api/pending/moderations)     | 文字與圖片安全分類                                                                  | 回傳類別判定和評分                       |
| [取得模型](/simidoc/zh-Hant/apps/api/models)                  | OpenAI 和 Gemini 格式模型清單                                                     | 回傳模型識別碼；清單不等於每項能力均已開放           |
| [檔案識別](/simidoc/zh-Hant/apps/api/upload)                  | 將檔案內容傳入支援的多模態模型                                                            | 與獨立的 Files API 不同               |
| [微調（不支援）](/simidoc/zh-Hant/apps/api/pending/fine-tuning)  | 官方微調通訊協定參考                                                                 | 僅提供 OpenAI 官方直連參考               |
| [Files API（不支援）](/simidoc/zh-Hant/apps/api/pending/files) | 官方檔案管理通訊協定參考                                                               | 僅提供 OpenAI 官方直連參考               |

## 閱讀介面說明

介面頁列出請求方法、參數、回傳欄位、程式碼範例、錯誤碼和廠商官方參考。閘道範例使用 SimiRouter Key，官方直連範例使用廠商金鑰。標註「不支援」的功能僅提供廠商直連參考。