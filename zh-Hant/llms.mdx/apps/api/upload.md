# 檔案與內容識別

檔案相關流程有兩層：上傳 API 管理檔案資源，模型輸入 API 讀取檔案內容並生成答案。把檔案附加到生成請求不等於將它儲存為可重複使用的檔案資源。

## 概覽

| 你要做的事        | 輸入方式                 | 檔案去哪     | 是否需要先上傳         |
| ------------ | -------------------- | -------- | --------------- |
| 讓模型讀一份 PDF   | 請求行內 Base64 或可存取 URL | 只存在於本次請求 | 否               |
| 在多輪請求中重複使用檔案 | file\_id 或廠商檔案引用     | 廠商檔案資源   | 是（官方 Files API） |
| 批次或超長檔案預處理   | 上傳後等待處理完成            | 廠商檔案資源   | 是，且有生命週期        |

## 核心概念

* **行內輸入**：檔案編碼進請求體隨訊息發送，請求結束即結束，沒有 file\_id，也沒有後續刪除步驟。
* **檔案資源**：先上傳取得 id，再在多次請求中引用；資源有歸屬、有效期和配額，需要顯式刪除。
* **生命週期**：上傳完成不等於文字抽取完成，也不等於模型已經理解；輪詢到可處理狀態後才能推理。
* **大小與格式**：限制按檔案大小、頁數、時長分別設定；壓縮圖片不會轉換檔案類型，掃描版 PDF 還需要 OCR 能力。
* **資料保留**：各廠商對檔案內容與識別結果的保留策略不同，敏感材料先確認授權與刪除方式。

## 請求與能力

| 用途                                  | 請求                                            | 邊界                                 |
| ----------------------------------- | --------------------------------------------- | ---------------------------------- |
| [PDF 內容識別](/simidoc/zh-Hant/apps/api/upload/file-recognition)      | POST /v1/responses + input\_file              | 行內 Base64，無需 Files API。            |
| Chat PDF 輸入                         | POST /v1/chat/completions + type=file         | 使用 Chat 的 file 物件，不是 Responses 結構。 |
| [Files API](/simidoc/zh-Hant/apps/api/pending/files)       | /v1/files                                     | 閘道未實現；官方原生上傳能力不代表本站開放。             |
| [Gemini 媒體理解](/simidoc/zh-Hant/apps/api/chat/gemini-media) | POST /v1beta/models/\{model}\:generateContent | inlineData 或適用的 fileData。          |

## 呼叫方式

行內識別可同步回傳 JSON，也可串流回傳文字事件；均屬於一次模型請求。官方某些上傳或檔案預處理流程需要等待資源可用，屬於資源生命週期，不等於模型自動背景執行。多檔案可以在一個支援的請求里提交，也可以分成平行請求；兩種方式的上下文、費用和總大小限制不同。

上傳敏感檔案前確認處理授權與服務商資料政策。大型文件宜按任務選擇相關頁或片段，不要為追求一次完成無限增加輸入。識別輸出必須保留不確定性，關鍵金額、編號與法律醫療結論應人工複核。

## 模擬呼叫

行內識別一次請求即可完成，檔案以 Base64 放在 `input_file` 裡：

```json
{
  "model": "gpt-5.5",
  "input": [
    {
      "role": "user",
      "content": [
        { "type": "input_text", "text": "总结这份合同的付款条款。" },
        { "type": "input_file", "filename": "contract.pdf", "file_data": "data:application/pdf;base64,JVBERi0xLjQK..." }
      ]
    }
  ]
}
```

回應是普通的模型訊息，識別結果在 `output_text` 中：

```json
{
  "status": "completed",
  "output": [
    {
      "type": "message",
      "content": [
        { "type": "output_text", "text": "（示意）合同约定分三期付款……" }
      ]
    }
  ]
}
```

整個過程中沒有上傳步驟，也沒有可重複使用的 file\_id；同一個檔案要再問一次，需要重新提交 Base64 或改用官方檔案資源。

## 官方參考

* [OpenAI 檔案輸入](https\://developers.openai.com/api/docs/guides/file-inputs)
* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [Google 檔案輸入](https\://ai.google.dev/gemini-api/docs/file-input-methods)