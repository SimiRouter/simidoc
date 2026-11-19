# 微調（不支援）

模型微調透過訓練資料調整基礎模型的行為，產生可用於推理的新模型。OpenAI 提供監督微調、直接偏好優化（DPO）和強化微調等方法；可用方法取決於所選基礎模型。

**SimiRouter 暫不支援微調。以下頁面保留 OpenAI 官方介面說明與直連範例，呼叫時必須使用 OpenAI 項目的金鑰。訓練可能產生費用。**

OpenAI 正逐步停止自助式微調：新使用者無法建立訓練任務，符合資格的既有使用者可建立任務至 **2027 年 1 月 6 日**，除非基礎模型更早停用。已建立的微調模型只能在其基礎模型停用前繼續推理。資格、模型和日期可能變更；使用前請以[官方淘汰時間表](https\://developers.openai.com/api/docs/deprecations)為準。

## 概覽

微調改的是模型權重，不是提示詞。它適合穩定的格式約束、固定語氣和領域表達；不適合注入隨時會變的知識——那類需求用檢索或更長的系統提示成本更低。驗證效果必須用沒有參與訓練的獨立樣本。

| 你要做的事    | 輸入               | 輸出                       | 執行方式        |
| -------- | ---------------- | ------------------------ | ----------- |
| 訓練一個專用模型 | JSONL 訓練集 + 基礎模型 | 任務物件與 `fine_tuned_model` | 背景非同步，輪詢狀態  |
| 觀察訓練過程   | 任務 ID            | 事件日誌與指標                  | 分頁查詢，不是 SSE |
| 停止訓練     | 任務 ID            | 已取消的任務物件                 | 同步請求        |

## 核心概念

* **基礎模型**：決定可用方法與價格。不同基礎模型支援的方法和參數不同，選錯方法會在建立任務時被拒絕。
* **訓練集與驗證集**：JSONL，每行一條對話樣本；官方最低 10 條，通常從 50 條開始，50 到 100 條常能看到明顯改善。驗證集要單獨準備，不能與訓練集重疊。
* **任務狀態**：`queued`、`running`、`succeeded`、`failed`、`cancelled`。只有 `succeeded` 才產出可推理的新模型；`failed` 要讀 `error` 判斷是資料問題還是參數問題。
* **產出模型**：成功後回傳 `fine_tuned_model` 識別碼，用它替代基礎模型發起推理。模型有獨立生命週期，需要時自行刪除。
* **成本**：訓練按 Token 計費，產出模型在保存期內可能產生儲存費用；用小樣本試跑再擴大，比一次提交全量資料更可控。

## 介面與執行方式

| 操作                        | 官方請求                                                    | 執行方式            |
| ------------------------- | ------------------------------------------------------- | --------------- |
| [建立任務（不支援）](/simidoc/zh-Hant/apps/api/pending/fine-tuning/create)     | `POST /v1/fine_tuning/jobs`                             | 回傳任務物件，背景非同步訓練。 |
| [取得任務詳情（不支援）](/simidoc/zh-Hant/apps/api/pending/fine-tuning/retrieve) | `GET /v1/fine_tuning/jobs/{fine_tuning_job_id}`         | 同步查詢狀態、輸出模型及錯誤。 |
| [列出任務（不支援）](/simidoc/zh-Hant/apps/api/pending/fine-tuning/list)       | `GET /v1/fine_tuning/jobs`                              | 同步分頁查詢。         |
| [取得任務事件（不支援）](/simidoc/zh-Hant/apps/api/pending/fine-tuning/events)   | `GET /v1/fine_tuning/jobs/{fine_tuning_job_id}/events`  | 分頁記錄，不是SSE。     |
| [取消任務（不支援）](/simidoc/zh-Hant/apps/api/pending/fine-tuning/cancel)     | `POST /v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel` | 停止任務並回傳任務物件。    |

## 基本流程

1. 按所選微調方法準備JSONL訓練集，獨立準備驗證集。
2. 透過[官方檔案上傳介面](/simidoc/zh-Hant/apps/api/pending/files/upload)以 `purpose=fine-tune` 上傳資料。
3. 選擇支援該方法的模型，建立任務並儲存任務ID。
4. 查詢任務狀態和事件；`succeeded`表示成功，`failed`需讀取`error`，`cancelled`表示已取消。
5. 訓練成功後使用回傳的 `fine_tuned_model` 進行推理，並透過獨立評估集驗證效果。

建立請求成功不等於訓練成功；取消任務也不代表已發生用量被撤銷。不要因網路逾時直接重複建立同一訓練任務。

## 官方參考

* [OpenAI 模型優化指南](https\://developers.openai.com/api/docs/guides/model-optimization)
* [OpenAI 監督微調指南](https\://developers.openai.com/api/docs/guides/supervised-fine-tuning)
* [OpenAI Fine-tuning Jobs API](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs)