# 聊天與內容生成

聊天 API 用一段對話或一條指令換取模型輸出。它既能只回答文字，也能讀取圖片、音訊、檔案，或呼叫外部工具後繼續作答。通訊協定決定請求與回應的形狀，模型決定可用的輸入模態、上下文長度與工具能力。

## 概覽

| 你想做的事               | 選擇                                      | 關鍵點                   |
| ------------------- | --------------------------------------- | --------------------- |
| 一般問答、寫作、摘要          | [Chat Completions](/simidoc/zh-Hant/apps/api/chat/openai-chat)       | 最通用，用戶端支援最廣           |
| 讓模型查資料、呼叫函式、回傳結構化資料 | [Responses](/simidoc/zh-Hant/apps/api/chat/openai-responses)         | 有型別的輸入輸出與內建工具         |
| 移轉既有 Claude 用戶端     | [Claude Messages](/simidoc/zh-Hant/apps/api/chat/claude)             | Anthropic 內容區塊與工具通訊協定 |
| 移轉既有 Gemini 用戶端     | [Gemini generateContent](/simidoc/zh-Hant/apps/api/chat/gemini-text) | parts 多模態輸入           |
| 維護舊式補全整合            | [Completions](/simidoc/zh-Hant/apps/api/chat/openai-completions)     | 僅文字 prompt，逐步淘汰       |
| 讓模型讀圖、聽音訊、看影片或 PDF  | [Gemini 媒體理解](/simidoc/zh-Hant/apps/api/chat/gemini-media)           | 輸入是媒體，輸出仍是文字          |

所有通訊協定共用同一套閘道驗證：基址 `https://api.dwchainless.com`，請求標頭 `Authorization: Bearer $SIMIROUTER_API_KEY`。換通訊協定不需要換 Key，但換模型要確認新模型支援你要的輸入模態與參數。

## 核心概念

先弄清楚這幾個詞，後面所有參數才有意義。

* **Token（詞元）**：模型讀寫文字的最小計費單位。英文約 4 個字元、中文約 1 到 2 個字算 1 個 Token，具體以模型分詞器為準。輸入 Token 與輸出 Token 分開計價。
* **上下文視窗（context window）**：單次請求裡輸入加輸出的 Token 總上限。歷史越長，留給回答的空間越小；超出上限時請求可能被拒絕，或被截斷並回傳 `finish_reason` 為 `length`。
* **訊息角色（role）**：`system` 或 `developer` 設定行為邊界，`user` 是使用者輸入，`assistant` 是模型輸出，`tool` 回傳工具執行結果。角色順序本身就是對話歷史。
* **無狀態**：伺服端不保存你的對話。每次請求都要把需要的歷史重新傳送一遍，歷史越長費用越高。
* **串流（streaming）**：伺服端用 SSE 逐段回傳增量，用戶端邊收邊渲染。它降低的是首字等待時間，不改變總耗時與總費用，也不是非同步任務。
* **工具呼叫（tool calling）**：模型不直接執行函式，而是回傳結構化的呼叫意圖；由你的程式執行後，把結果作為新訊息交回模型，模型再繼續作答。

## 規格與能力

| 指標     | 說明                                                                      |
| ------ | ----------------------------------------------------------------------- |
| 輸入模態   | 文字；圖片、音訊、PDF、影片取決於模型                                                    |
| 輸出模態   | 文字；部分模型支援結構化 JSON 或影像                                                   |
| 上下文長度  | 依模型區分，常見 8K 到 1M Token                                                  |
| 單次輸出上限 | Chat 用 `max_completion_tokens`，Responses 用 `max_output_tokens`，且受模型上限約束 |
| 並行     | 由你的額度與通道限流決定，與 `n`、`parallel_tool_calls` 無關                             |
| 計費     | 依輸入與輸出 Token 分別計價，工具與思考 Token 可能另計                                      |

參數不是越多越好：`temperature`、`top_p`、`reasoning_effort` 等取樣與推理參數在不同模型上支援程度不同，閘道會透傳給通道，通道不支援時可能報錯或被忽略。先送出最小請求，再逐項加參數。

## 呼叫流程

1. **準備設定**：在 API 金鑰管理 建立金鑰，從模型與價格複製完整模型 ID。
2. **選擇介面**：一般情境用 Chat Completions；需要工具、結構化輸出或背景模式時用 Responses；移轉用戶端時用對應原生通訊協定。
3. **先發非串流請求**：只請求一則回覆，確認驗證、模型與參數有效，再開啟串流或接入工具。
4. **讀取並驗收**：檢查 HTTP 狀態、`finish_reason`、拒絕資訊與實際內容，再核對使用記錄與費用。

## 模擬呼叫

下面用一條最小請求展示三種形態：請求主體、完整回應、串流回應。數值與文案均為示意，不是真實帳戶的回傳。

**請求**

```json
{
  "model": "gpt-5.5",
  "messages": [
    { "role": "system", "content": "You are a concise technical documentation assistant." },
    { "role": "user", "content": "Explain what a token is in three sentences." }
  ],
  "max_completion_tokens": 300,
  "stream": false
}
```

**完整回應（非串流）**

```json
{
  "id": "chatcmpl_demo_0001",
  "object": "chat.completion",
  "model": "gpt-5.5",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "A token is a small unit of text processed by the model. It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 42,
    "completion_tokens": 58,
    "total_tokens": 100
  }
}
```

**串流回應（`"stream": true`）**

伺服端按 SSE 逐條推送增量，用戶端把 `delta.content` 依次拼接，收到 `[DONE]` 結束：

```text
data: {"choices":[{"index":0,"delta":{"role":"assistant"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":"Token"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" is a small unit of text processed by the model."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

判斷是否成功的標準不是「收到了資料」，而是：HTTP 狀態為 2xx、最終 `finish_reason` 合理、拼接後的文件完整。中途斷流時應按已收到的內容結束，不要自動重送同一筆付費請求。

## 工具呼叫

工具呼叫分兩類，混用是常見錯誤來源：

* **用戶端函式（function calling）**：你宣告函式簽名，模型回傳呼叫意圖，你的程式執行後把結果交回模型。資料與執行都在你這邊。
* **伺服端工具（server-side tools）**：模型側直接執行，例如 Responses 的內建網頁搜尋。你只看到最終答案與引用，看不到中間擷取過程。

一條用戶端函式的完整往返如下：

```text
1. Request: declare get_weather in tools and ask, "What is the weather in Paris today?"
2. Response: finish_reason = "tool_calls"
   tool_calls[0] = { id: "call_abc", function: { name: "get_weather", arguments: "{\"city\":\"Paris\"}" } }
3. Your program runs get_weather("Paris") and receives {"temp_c": 18}
4. Send another request with the assistant tool_calls message and role = "tool", tool_call_id = "call_abc", content = "{\"temp_c\": 18}"
5. Response: the model produces its final natural-language answer from the tool result
```

要點：`arguments` 是 JSON 字串而不是物件；工具結果必須帶回對應的 `tool_call_id`；一輪裡可以有多個工具呼叫，`parallel_tool_calls` 控制是否平行請求。工具呼叫會額外消耗 Token，錯誤重試也可能重複計費。

## 呼叫方式

* **同步非串流**：連線保持到生成結束，一次接收完整 JSON。適合短回覆與後端批次處理。
* **串流**：同一請求透過 SSE 增量回傳事件。必須處理終止原因與中途斷流。
* **非同步背景任務**：先取得任務或回應 ID，再透過查詢或 Webhook 收取結果。OpenAI 原生 Responses 提供 background 工作流程，但本站閘道沒有配套的查詢與取消端點，不應僅新增 `background` 參數。
* **平行請求**：用戶端同時發起多次獨立 HTTP 請求，分別處理成功、限流與費用。`n` 是候選數量，`parallel_tool_calls` 是同一輪中多個工具呼叫，兩者均不等於 HTTP 並行。

## 串接與工作階段

普通訊息介面是無狀態的，每次應帶上所需歷史；有狀態回應 ID 也受上游路由與資料保留限制。官方直連必須同時更換廠商網域與驗證資訊，不能只替換模型名稱。

## 官方參考

* [OpenAI 文字生成](https\://developers.openai.com/api/docs/guides/text)
* [OpenAI 背景模式](https\://developers.openai.com/api/docs/guides/background)
* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)