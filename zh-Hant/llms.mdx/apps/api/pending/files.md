# Files API（不支援）

Files API 為 OpenAI 的檔案資源管理介面。上傳後獲得檔案 ID，可供微調、批處理或其他接受檔案 ID 的官方端點引用。它不等同於模型對檔案內容的識別能力。

**SimiRouter 暫不支援 Files API。以下頁面保留 OpenAI 官方介面說明與直連範例，呼叫時必須使用 OpenAI 項目的金鑰。**

## 概覽

Files API 解決的是「一次上傳、多次引用」：檔案先作為獨立資源存在，再由微調、批處理等端點按 ID 取用。它適合訓練集、批處理請求主體和需要反覆讀取的素材；單次對話裡的附件不走這套介面，而是在請求內直接傳入。

| 使用場景          | 上傳時的標記              | 上傳後還要做什麼     |
| ------------- | ------------------- | ------------ |
| 監督微調訓練資料      | `purpose=fine-tune` | 建立訓練任務並輪詢狀態  |
| 批次請求或輸出       | `purpose=batch`     | 建立批處理任務並輪詢狀態 |
| 其他接受檔案 ID 的端點 | 按端點要求               | 以該端點文件為準     |

## 核心概念

* **檔案 ID 與作用域**：ID 屬於建立它的項目或組織，不能跨供應商、跨項目沿用；把另一個服務的檔案 ID 填入 OpenAI 請求會得到 404 或 403。
* **purpose 決定用途**：上傳時的 `purpose` 表明資料給誰使用（如 `fine-tune`、`batch`），消費端點還會各自驗證格式、大小與行數。
* **生命週期**：上傳成功只代表資源已存在；訓練或批處理是否處理完成，要查對應任務的狀態，不能憑上傳結果判斷。
* **內容與元資料分離**：檔案物件裡的 `filename`、`bytes`、`status` 是元資料；模型看到的內容由消費端點讀取，二者不會自動同步。

## 介面與執行方式

| 操作                        | 官方請求                              | 執行方式                   |
| ------------------------- | --------------------------------- | ---------------------- |
| [上傳檔案（不支援）](/simidoc/zh-Hant/apps/api/pending/files/upload)     | `POST /v1/files`                  | multipart 上傳，同步回傳檔案物件。 |
| [取得檔案資訊（不支援）](/simidoc/zh-Hant/apps/api/pending/files/retrieve) | `GET /v1/files/{file_id}`         | 同步回傳元資料。               |
| [列出檔案（不支援）](/simidoc/zh-Hant/apps/api/pending/files/list)       | `GET /v1/files`                   | 同步分頁查詢。                |
| [取得檔案內容（不支援）](/simidoc/zh-Hant/apps/api/pending/files/content)  | `GET /v1/files/{file_id}/content` | 下載檔案位元組，不是模型SSE。       |
| [刪除檔案（不支援）](/simidoc/zh-Hant/apps/api/pending/files/delete)     | `DELETE /v1/files/{file_id}`      | 刪除資源，回傳刪除結果。           |

檔案上傳成功不代表其消費任務已完成。訓練、批處理和索引的處理狀態由各自端點查詢。檔案用途、格式和大小限制也由消費端點共同決定。

## 資源與安全

檔案 ID 屬於建立它的項目或組織，不能把另一個供應商或閘道的檔案 ID 直接用於 OpenAI。範例透過環境變數讀取金鑰；不得將訓練集、個人資訊或金鑰寫入公開倉庫。

## 官方參考

* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files)
* [OpenAI 上傳檔案](https\://developers.openai.com/api/reference/resources/files/methods/create)