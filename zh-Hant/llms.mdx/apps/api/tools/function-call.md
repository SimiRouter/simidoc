# 函式工具呼叫

## 介面說明

`POST /v1/chat/completions` 的 tools 參數告訴模型有哪些函式可用。模型只生成函式名和參數；應用負責參數驗證、授權、執行，並用 tool 訊息回傳結果，再請求最終回答。函式呼叫本身不會替應用存取資料庫、轉帳或傳送通知。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直連為 `https://api.openai.com`，同樣使用 Bearer 身分驗證，但必須換成 OpenAI 的 Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

## 請求參數

| 欄位                            | 型別              | 必填 | 說明                                         |
| ----------------------------- | --------------- | -- | ------------------------------------------ |
| model / messages              | string / array  | 是  | 模型和對話，模型必須支援函式工具。                          |
| tools\[].type                 | string          | 是  | 此處為 function。                              |
| tools\[].function.name        | string          | 是  | 函式名，用於應用側允許清單分派。                           |
| tools\[].function.description | string          | 否  | 描述用途、輸入邊界和副作用。                             |
| tools\[].function.parameters  | object          | 是  | 函式參數的 JSON Schema。                         |
| tools\[].function.strict      | boolean         | 否  | true 時要求嚴格匹配支援的 Schema 子集。                 |
| tool\_choice                  | string / object | 否  | auto 自行選擇；none 禁用；required 至少呼叫一個；也可指定函式名。 |
| parallel\_tool\_calls         | boolean         | 否  | 允許同一輪多個函式呼叫；false 限制為至多一個呼叫。               |
| messages\[].tool\_call\_id    | string          | 條件 | 回傳 tool 訊息時，必須對應助手 tool\_calls 的 id。       |
| messages\[].content           | string          | 條件 | tool 訊息的執行結果，建議序列化為 JSON 文字。               |

strict=true 時，每個物件必須 additionalProperties=false，properties 的全部欄位須列入 required。邏輯上選用欄位可定義為允許 null；不接受的 Schema 會導致請求錯誤。

### 首輪請求

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "请计算17乘以23。"
    }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "multiply_numbers",
        "description": "将两个整数相乘。",
        "strict": true,
        "parameters": {
          "type": "object",
          "properties": {
            "a": {
              "type": "integer"
            },
            "b": {
              "type": "integer"
            }
          },
          "required": [
            "a",
            "b"
          ],
          "additionalProperties": false
        }
      }
    }
  ],
  "tool_choice": "auto",
  "parallel_tool_calls": false,
  "stream": false
}
```

## 回傳值

| 欄位                                   | 型別            | 說明                                     |
| ------------------------------------ | ------------- | -------------------------------------- |
| choices\[].message.tool\_calls\[].id | string        | 工具呼叫 ID，用於後續 tool\_call\_id。           |
| tool\_calls\[].type                  | string        | function。                              |
| tool\_calls\[].function.name         | string        | 請求呼叫的函式名，必須匹配應用允許清單。                   |
| tool\_calls\[].function.arguments    | string        | JSON 文字，不是已解析物件；先解析再檢查型別與取值。           |
| choices\[].message.content           | string / null | 函式呼叫時可為 null。                          |
| choices\[].finish\_reason            | string        | tool\_calls 表示需執行工具；stop 通常表示最終自然語言回覆。 |
| usage                                | object        | 每一輪模型請求分別產生 Token 用量。                  |

```json
{
  "id": "chatcmpl_tool_example",
  "object": "chat.completion",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": null,
        "tool_calls": [
          {
            "id": "call_example",
            "type": "function",
            "function": {
              "name": "multiply_numbers",
              "arguments": "{\"a\":17,\"b\":23}"
            }
          }
        ]
      },
      "finish_reason": "tool_calls"
    }
  ]
}
```

### 執行與回傳

應用應驗證 name=multiply\_numbers，確認 a、b 為允許範圍內的整數，計算結果為 391。以下為第二輪完整請求；call\_example 必須替換為首輪收到的真實 ID，不能重複使用靜態 ID 執行任意請求。

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "请计算17乘以23。"
    },
    {
      "role": "assistant",
      "content": null,
      "tool_calls": [
        {
          "id": "call_example",
          "type": "function",
          "function": {
            "name": "multiply_numbers",
            "arguments": "{\"a\":17,\"b\":23}"
          }
        }
      ]
    },
    {
      "role": "tool",
      "tool_call_id": "call_example",
      "content": "391"
    }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "multiply_numbers",
        "description": "将两个整数相乘。",
        "strict": true,
        "parameters": {
          "type": "object",
          "properties": {
            "a": {
              "type": "integer"
            },
            "b": {
              "type": "integer"
            }
          },
          "required": [
            "a",
            "b"
          ],
          "additionalProperties": false
        }
      }
    }
  ],
  "tool_choice": "none",
  "stream": false
}
```

收到多個 tool\_calls 時，每個呼叫都應有對應結果；不要漏回或混用其他對話的 ID。只允許無依賴且已授權的工具平行執行。對外傳送、扣費等操作需單獨冪等控制，不能因為模型再次請求就重複執行。

### Responses 的格式差異

Responses 的函式定義是 tools\[] 頂層的 type、name、description、parameters、strict，不包 function；回傳 type=function\_call 的輸出項，回傳 `{"type":"function_call_output","call_id":"...","output":"391"}`。不要把 Chat 的 tool\_call\_id 和 Responses 的 call\_id 混用。

## 程式碼範例

四語言範例均自動執行一次無副作用的本機乘法並回傳，最多請求兩輪，不無限循環。設定 `SIMIROUTER_API_KEY`、`SIMIROUTER_MODEL`；`SIMIROUTER_BASE_URL` 可覆蓋預設閘道位址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 範例只使用標準函式庫；curl 範例的 JSON 由 Python 3 安全編碼。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "请计算17乘以23。"
        }
      ],
      "tools": [
        {
          "type": "function",
          "function": {
            "name": "multiply_numbers",
            "description": "将两个整数相乘。",
            "strict": true,
            "parameters": {
              "type": "object",
              "properties": {
                "a": {
                  "type": "integer"
                },
                "b": {
                  "type": "integer"
                }
              },
              "required": [
                "a",
                "b"
              ],
              "additionalProperties": false
            }
          }
        }
      ],
      "tool_choice": "auto",
      "parallel_tool_calls": false,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/chat/completions'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    assistant = result["choices"][0]["message"]
    body["messages"].append(assistant)
    for call in assistant.get("tool_calls", []):
        if call.get("type") != "function" or call["function"]["name"] != "multiply_numbers":
            raise ValueError("未知函数")
        args = json.loads(call["function"]["arguments"])
        if set(args) != {"a", "b"} or any(type(args[k]) is not int or abs(args[k]) > 1000000 for k in ("a", "b")):
            raise ValueError("参数须为绝对值不超过1000000的两个整数")
        body["messages"].append({"role": "tool", "tool_call_id": call["id"], "content": str(args["a"] * args["b"])})
    if assistant.get("tool_calls"):
        body["tool_choice"] = "none"
        request.data = json.dumps(body).encode("utf-8")
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
      "messages": [
        {
          "role": "user",
          "content": "请计算17乘以23。"
        }
      ],
      "tools": [
        {
          "type": "function",
          "function": {
            "name": "multiply_numbers",
            "description": "将两个整数相乘。",
            "strict": true,
            "parameters": {
              "type": "object",
              "properties": {
                "a": {
                  "type": "integer"
                },
                "b": {
                  "type": "integer"
                }
              },
              "required": [
                "a",
                "b"
              ],
              "additionalProperties": false
            }
          }
        }
      ],
      "tool_choice": "auto",
      "parallel_tool_calls": false,
      "stream": false
    };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = "/v1/chat/completions";
      const response = await fetch(base + endpoint, { method: "POST",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      let parsed = JSON.parse(result);
      const assistant = parsed.choices[0].message;
      body.messages.push(assistant);
      for (const call of assistant.tool_calls || []) {
        if (call.type !== "function" || call.function.name !== "multiply_numbers") throw new Error("未知函数");
        const args = JSON.parse(call.function.arguments);
        if (Object.keys(args).sort().join(",") !== "a,b" || ![args.a, args.b].every(x => Number.isSafeInteger(x) && Math.abs(x) <= 1000000)) throw new Error("函数参数超出范围");
        body.messages.push({ role: "tool", tool_call_id: call.id, content: String(args.a * args.b) });
      }
      if (assistant.tool_calls?.length) {
        body.tool_choice = "none";
        const final = await fetch(base + endpoint, { method: "POST", headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" }, body: JSON.stringify(body), signal: AbortSignal.timeout(120000) });
        const text = await final.text();
        if (!final.ok) throw new Error(`HTTP ${final.status}: ${text}`);
        parsed = JSON.parse(text);
      }
      console.log(JSON.stringify(parsed, null, 2));
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
      "messages": [
        {
          "role": "user",
          "content": "请计算17乘以23。"
        }
      ],
      "tools": [
        {
          "type": "function",
          "function": {
            "name": "multiply_numbers",
            "description": "将两个整数相乘。",
            "strict": true,
            "parameters": {
              "type": "object",
              "properties": {
                "a": {
                  "type": "integer"
                },
                "b": {
                  "type": "integer"
                }
              },
              "required": [
                "a",
                "b"
              ],
              "additionalProperties": false
            }
          }
        }
      ],
      "tool_choice": "auto",
      "parallel_tool_calls": false,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    WORK_DIR=$(mktemp -d)
    trap 'rm -rf "$WORK_DIR"' EXIT
    printf '%s' "$BODY" > "$WORK_DIR/request.json"
    curl "${BASE_URL%/}/v1/chat/completions" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY" \
      --output "$WORK_DIR/response.json"
    python3 - "$WORK_DIR" <<'PYTOOL'
    import json, sys
    from pathlib import Path
    folder = Path(sys.argv[1])
    body = json.loads((folder / "request.json").read_text())
    result = json.loads((folder / "response.json").read_text())
    assistant = result["choices"][0]["message"]
    body["messages"].append(assistant)
    for call in assistant.get("tool_calls", []):
        if call.get("type") != "function" or call["function"]["name"] != "multiply_numbers":
            raise ValueError("未知函数")
        args = json.loads(call["function"]["arguments"])
        if set(args) != {"a", "b"} or any(type(args[k]) is not int or abs(args[k]) > 1000000 for k in ("a", "b")):
            raise ValueError("函数参数超出范围")
        body["messages"].append({"role": "tool", "tool_call_id": call["id"], "content": str(args["a"] * args["b"])})
    if assistant.get("tool_calls"):
        body["tool_choice"] = "none"
        (folder / "follow-up.json").write_text(json.dumps(body, ensure_ascii=False))
    else:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    PYTOOL
    if [ -f "$WORK_DIR/follow-up.json" ]; then
      curl "${BASE_URL%/}/v1/chat/completions" \
        --fail-with-body \
        --max-time 120 \
        -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        --data-binary "@$WORK_DIR/follow-up.json"
    fi
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "math"
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
      "messages": [
        {
          "role": "user",
          "content": "请计算17乘以23。"
        }
      ],
      "tools": [
        {
          "type": "function",
          "function": {
            "name": "multiply_numbers",
            "description": "将两个整数相乘。",
            "strict": true,
            "parameters": {
              "type": "object",
              "properties": {
                "a": {
                  "type": "integer"
                },
                "b": {
                  "type": "integer"
                }
              },
              "required": [
                "a",
                "b"
              ],
              "additionalProperties": false
            }
          }
        }
      ],
      "tool_choice": "auto",
      "parallel_tool_calls": false,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/chat/completions"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      var parsed struct { Choices []struct { Message map[string]any `json:"message"` } `json:"choices"` }
      if err := json.Unmarshal(result, &parsed); err != nil { log.Fatal(err) }
      if len(parsed.Choices) == 0 { log.Fatal("响应没有候选消息") }
      assistant := parsed.Choices[0].Message
      messages := body["messages"].([]any)
      messages = append(messages, assistant)
      calls, _ := assistant["tool_calls"].([]any)
      for _, raw := range calls {
        call, ok := raw.(map[string]any); if !ok { log.Fatal("无效调用") }
        function, ok := call["function"].(map[string]any); if !ok || call["type"] != "function" || function["name"] != "multiply_numbers" { log.Fatal("未知函数") }
        arguments, ok := function["arguments"].(string); if !ok { log.Fatal("参数不是JSON文本") }
        var args map[string]any; if err := json.Unmarshal([]byte(arguments), &args); err != nil { log.Fatal(err) }
        a, aOK := args["a"].(float64); b, bOK := args["b"].(float64)
        if len(args) != 2 || !aOK || !bOK || math.Trunc(a) != a || math.Trunc(b) != b || math.Abs(a) > 1000000 || math.Abs(b) > 1000000 { log.Fatal("函数参数超出范围") }
        id, ok := call["id"].(string); if !ok || id == "" { log.Fatal("缺少调用ID") }
        messages = append(messages, map[string]any{"role":"tool", "tool_call_id":id, "content":fmt.Sprintf("%.0f", a*b)})
      }
      if len(calls) > 0 {
        body["messages"] = messages; body["tool_choice"] = "none"
        payload, err = json.Marshal(body); if err != nil { log.Fatal(err) }
        req, err = http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
        req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
        final, err := client.Do(req); if err != nil { log.Fatal(err) }; defer final.Body.Close()
        result, err = io.ReadAll(final.Body); if err != nil { log.Fatal(err) }
        if final.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", final.StatusCode, result) }
      }
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

OpenAI 原生錯誤通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可為 `null`，不能假定其始終存在或等於 HTTP 狀態碼。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 arguments 解析失敗、未知函式或業務執行失敗是應用側錯誤，不應偽造工具執行成功。成功的 HTTP 回應也可能只是在請求工具，而非完成使用者任務。

## 官方參考

* [OpenAI 函式呼叫](https\://developers.openai.com/api/docs/guides/function-calling)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI Responses](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI 錯誤處理](https\://developers.openai.com/api/docs/guides/error-codes)