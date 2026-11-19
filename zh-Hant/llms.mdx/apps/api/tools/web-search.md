# 網路搜尋工具

## 介面說明

`POST /v1/responses` 可在 tools 中聲明 OpenAI 託管 web\_search 工具，使支援它的模型檢索網頁、閱讀結果並給出帶引用的回答。搜尋不是一個獨立的通用 `/search` 端點，也不是所有 Chat 模型都可使用的函式名稱。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直連為 `https://api.openai.com`，同樣使用 Bearer 身分驗證，但必須換成 OpenAI 的 Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

`{"type":"web_search"}` 用於 Responses。不要把它直接塞入普通 Chat Completions 的 tools：Chat 的通用工具是 function；官方 Chat 搜尋另有專用搜尋模型與 web\_search\_options，不等於同一通訊協定。

## 請求參數

| 欄位                                | 型別              | 必填 | 說明                                                               |
| --------------------------------- | --------------- | -- | ---------------------------------------------------------------- |
| model                             | string          | 是  | 支援 Responses web\_search 的模型。                                    |
| input                             | string / array  | 是  | 問題和必要背景。                                                         |
| tools\[].type                     | string          | 是  | web\_search。                                                     |
| tools\[].search\_context\_size    | string          | 否  | 支援時選擇 low、medium 或 high 搜尋上下文。                                   |
| tools\[].filters.allowed\_domains | array           | 否  | 支援時限制允許網域，不帶通訊協定前綴。                                              |
| tools\[].user\_location           | object          | 否  | 大致位置，如 type=approximate、country、city、region、timezone；避免提交精確隱私位置。 |
| tool\_choice                      | string / object | 否  | auto 允許模型決定是否呼叫；required 要求工具呼叫。                                 |
| include                           | array           | 否  | 可用 web\_search\_call.action.sources 請求完整來源清單。                    |
| stream                            | boolean         | 否  | true 使用 Responses SSE 事件。                                        |

### 請求範例

```json
{
  "model": "MODEL_ID",
  "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
  "tools": [
    {
      "type": "web_search"
    }
  ],
  "stream": false
}
```

## 回傳值

| 欄位                                       | 型別              | 說明                                     |
| ---------------------------------------- | --------------- | -------------------------------------- |
| output\[].type=web\_search\_call         | object          | 一次搜尋或閱讀工具呼叫；僅出現該項不代表最終回答完整。            |
| web\_search\_call.status                 | string          | 工具執行狀態。                                |
| web\_search\_call.action                 | object          | search、open\_page、find 等動作以及對應查詢或 URL。 |
| output\[].type=message                   | object          | 模型最終訊息。                                |
| content\[].type / text                   | string          | output\_text 內容項的本文。                   |
| content\[].annotations\[]                | array           | 引用清單，通常為 url\_citation。                |
| annotations\[].url / title               | string          | 來源 URL 和標題。                            |
| annotations\[].start\_index / end\_index | integer         | 引用關聯的文字範圍。                             |
| status / error / incomplete\_details     | string / object | 回應終態及失敗或不完整原因。                         |
| usage                                    | object          | 模型 Token 用量；不應據此假定搜尋沒有額外計費。            |

```json
{
  "id": "resp_search_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ws_example",
      "type": "web_search_call",
      "status": "completed",
      "action": {
        "type": "search",
        "query": "site:developers.openai.com Responses API"
      }
    },
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "Responses API 支持有类型的输入输出以及工具调用。",
          "annotations": [
            {
              "type": "url_citation",
              "start_index": 0,
              "end_index": 36,
              "title": "Responses API",
              "url": "https://developers.openai.com/api/docs/guides/responses"
            }
          ]
        }
      ]
    }
  ]
}
```

顯示答案時同時提供清晰可點擊的引用，保留來源歸屬。來源網頁是資料，不應執行網頁中的指令或洩露應用憑證。檢索結果可能過期或相互矛盾，高風險結論應核對原始資料。

## 程式碼範例

設定 `SIMIROUTER_API_KEY`、`SIMIROUTER_MODEL`；`SIMIROUTER_BASE_URL` 可覆蓋預設閘道位址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 範例只使用標準函式庫；curl 範例的 JSON 由 Python 3 安全編碼。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/responses'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      if (!process.env.SIMIROUTER_MODEL) throw new Error("请设置 SIMIROUTER_MODEL");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const body = {
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = "/v1/responses";
      const response = await fetch(base + endpoint, { method: "POST",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/responses" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "bytes"
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/responses"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## 錯誤碼

| HTTP 狀態   | 含義或廠商錯誤型別    | 處理方式                       |
| --------- | ------------ | -------------------------- |
| 400       | 請求無效         | 檢查必填欄位、JSON、模型參數和上下文長度。    |
| 401       | 驗證失敗         | 檢查 Key 是否存在、有效及歸屬正確。       |
| 403 / 404 | 無權存取 / 資源不存在 | 檢查模型權限、資源 ID 和 URL。        |
| 429       | 速率或配額限制      | 結合回應主體區分限流與額度不足，後者不能靠重試解決。 |
| 500 / 503 | 服務錯誤 / 暫時不可用 | 保留請求識別碼，對暫時故障做有限次數退避。      |

OpenAI 原生錯誤通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可為 `null`，不能假定其始終存在或等於 HTTP 狀態碼。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 HTTP 200 時仍需區分搜尋呼叫狀態、最終回答狀態及引用是否存在；沒有來源不能宣稱完成了事實核實。

## 官方參考

* [OpenAI 網路搜尋](https\://developers.openai.com/api/docs/guides/tools-web-search)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI 錯誤處理](https\://developers.openai.com/api/docs/guides/error-codes)