# 工具呼叫

工具呼叫連接模型與資料、計算及外部服務。模型負責選擇工具和組織參數，應用或廠商工具服務負責執行；工具回傳值與最終自然語言回答是不同階段。

## 概覽

| 能力    | 誰執行  | 你看到的結果          | 典型場景              |
| ----- | ---- | --------------- | ----------------- |
| 用戶端函式 | 你的程式 | 呼叫意圖 + 你回傳的執行結果 | 查資料庫、呼叫內部 API、扣庫存 |
| 伺服端搜尋 | 廠商   | 最終回答與引用來源       | 查最新資料、核對事實        |

## 核心概念

* **工具定義**：名稱、用途說明和參數 JSON Schema。說明寫得越清楚，模型選錯工具或編造參數的機率越低。
* **呼叫意圖**：模型不執行程式碼，只回傳 `tool_calls`，其中 `arguments` 是 JSON 字串。它在串流回應中可能分片到達，必須收齊再解析。
* **執行與回傳**：你的程式驗證參數、執行函式，再把結果以 `role` 為 `tool`、帶同一個 `tool_call_id` 的訊息發回，模型才能繼續。
* **伺服端工具**：檢索由廠商完成，你只拿到答案與引用，無法控制中間過程，也不能把用戶端函式的用法套上去。

## 模擬呼叫

一次用戶端函式的請求、模型回應和回傳結果，欄位形態如下（內容為示意）：

```json
{
  "model": "gpt-5.5",
  "messages": [{ "role": "user", "content": "上海今天多少度？" }],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "查询指定城市的实时天气",
        "parameters": {
          "type": "object",
          "properties": { "city": { "type": "string" } },
          "required": ["city"]
        }
      }
    }
  ]
}
```

模型回傳呼叫意圖而不是溫度：

```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": null,
        "tool_calls": [
          {
            "id": "call_abc",
            "type": "function",
            "function": {
              "name": "get_weather",
              "arguments": "{\"city\":\"上海\"}"
            }
          }
        ]
      },
      "finish_reason": "tool_calls"
    }
  ]
}
```

執行函式後，把結果作為新訊息追加並再次請求：

```json
{
  "role": "tool",
  "tool_call_id": "call_abc",
  "content": "{\"temp_c\": 18}"
}
```

第三次回應才是給使用者看的自然語言答案。整條鏈路裡，模型從未真正存取天氣服務；你的程式才是執行者。

### 伺服端搜尋

伺服器端工具只需一次往返：你宣告工具，廠商完成檢索，一次回應同時給出檢索紀錄與最終回答。

```json
{
  "model": "gpt-5.5",
  "input": "查找 OpenAI 官方文档中关于 Responses API 的说明，并提供来源链接。",
  "tools": [{ "type": "web_search" }],
  "stream": false
}
```

回傳的 `output[]` 通常先出現檢索動作，再出現最終訊息與引用：

```json
{
  "status": "completed",
  "output": [
    {
      "type": "web_search_call",
      "status": "completed",
      "action": { "type": "search", "query": "site:developers.openai.com Responses API" }
    },
    {
      "type": "message",
      "role": "assistant",
      "content": [
        {
          "type": "output_text",
          "text": "Responses API 用于生成模型响应……",
          "annotations": [
            {
              "type": "url_citation",
              "url": "https://developers.openai.com/api/docs/guides/text",
              "title": "OpenAI text generation"
            }
          ]
        }
      ]
    }
  ]
}
```

`status` 為 `completed` 且存在 `message` 才代表回答可用；只看到 `web_search_call` 代表檢索階段結束，不等於回答完整。引用來自 `annotations[]`，應用程式應原樣呈現，不要自行改寫來源 URL。

## 工具型別

| 文件                      | 請求                                        | 執行方                            |
| ----------------------- | ----------------------------------------- | ------------------------------ |
| [函式呼叫](/simidoc/zh-Hant/apps/api/tools/function-call) | POST /v1/chat/completions；也有 Responses 格式 | 應用定義 JSON Schema、驗證參數並執行自己的函式。 |
| [網路搜尋](/simidoc/zh-Hant/apps/api/tools/web-search)    | POST /v1/responses + web\_search          | 廠商託管檢索，回傳網頁來源與引用。              |

## 同步、串流與平行

* **同步**：單次請求回傳完整工具呼叫或最終回答；自訂函式通常需要應用執行後再發下一輪請求。
* **串流**：工具名或參數以片段出現，須在參數收齊後解析，不能執行半截 JSON。
* **非同步**：耗時業務工具可以由應用建立背景任務，但必須自行提供任務狀態與結果關聯；宣告 tools 不會自動建立非同步服務。
* **平行**：parallel\_tool\_calls 允許模型在同一輪提出多個函式呼叫；應用只應平行執行已授權且相互獨立的操作。它不會自動提升限流配額，也不代表多條 HTTP 請求。

## 安全邊界

固定工具允許清單、驗證型別和業務範圍，對讀寫權限分離。對外傳送、付費、刪除和權限變更等副作用應設定確認及冪等控制。工具輸出可能含不可信文字，不得將其作為新的系統指令。

## 官方參考

* [OpenAI 函式呼叫](https\://developers.openai.com/api/docs/guides/function-calling)
* [OpenAI 網路搜尋](https\://developers.openai.com/api/docs/guides/tools-web-search)