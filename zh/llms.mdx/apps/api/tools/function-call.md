# 函数工具调用

## 接口说明

`POST /v1/chat/completions` 的 tools 参数告诉模型有哪些函数可用。模型只生成函数名和参数；应用负责参数校验、授权、执行，并用 tool 消息回传结果，再请求最终回答。函数调用本身不会替应用访问数据库、转账或发送通知。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

## 请求参数

| 字段                            | 类型              | 必填 | 说明                                         |
| ----------------------------- | --------------- | -- | ------------------------------------------ |
| model / messages              | string / array  | 是  | 模型和对话，模型必须支持函数工具。                          |
| tools\[].type                 | string          | 是  | 此处为 function。                              |
| tools\[].function.name        | string          | 是  | 函数名，用于应用侧白名单分派。                            |
| tools\[].function.description | string          | 否  | 描述用途、输入边界和副作用。                             |
| tools\[].function.parameters  | object          | 是  | 函数参数的 JSON Schema。                         |
| tools\[].function.strict      | boolean         | 否  | true 时要求严格匹配支持的 Schema 子集。                 |
| tool\_choice                  | string / object | 否  | auto 自行选择；none 禁用；required 至少调用一个；也可指定函数名。 |
| parallel\_tool\_calls         | boolean         | 否  | 允许同一轮多个函数调用；false 限制为至多一个调用。               |
| messages\[].tool\_call\_id    | string          | 条件 | 回传 tool 消息时，必须对应助手 tool\_calls 的 id。       |
| messages\[].content           | string          | 条件 | tool 消息的执行结果，建议序列化为 JSON 文本。               |

strict=true 时，每个对象必须 additionalProperties=false，properties 的全部字段须列入 required。逻辑上可选字段可定义为允许 null；不接受的 Schema 会导致请求错误。

### 首轮请求

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

## 返回值

| 字段                                   | 类型            | 说明                                     |
| ------------------------------------ | ------------- | -------------------------------------- |
| choices\[].message.tool\_calls\[].id | string        | 工具调用 ID，用于后续 tool\_call\_id。           |
| tool\_calls\[].type                  | string        | function。                              |
| tool\_calls\[].function.name         | string        | 请求调用的函数名，必须匹配应用白名单。                    |
| tool\_calls\[].function.arguments    | string        | JSON 文本，不是已解析对象；先解析再检查类型与取值。           |
| choices\[].message.content           | string / null | 函数调用时可为 null。                          |
| choices\[].finish\_reason            | string        | tool\_calls 表示需执行工具；stop 通常表示最终自然语言回复。 |
| usage                                | object        | 每一轮模型请求分别产生 Token 用量。                  |

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

### 执行与回传

应用应验证 name=multiply\_numbers，确认 a、b 为允许范围内的整数，计算结果为 391。以下为第二轮完整请求；call\_example 必须替换为首轮收到的真实 ID，不能复用静态 ID 执行任意请求。

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

收到多个 tool\_calls 时，每个调用都应有对应结果；不要漏回或混用其他对话的 ID。只允许无依赖且已授权的工具并行执行。对外发送、扣费等操作需单独幂等控制，不能因为模型再次请求就重复执行。

### Responses 的格式差异

Responses 的函数定义是 tools\[] 顶层的 type、name、description、parameters、strict，不包 function；返回 type=function\_call 的输出项，回传 `{"type":"function_call_output","call_id":"...","output":"391"}`。不要把 Chat 的 tool\_call\_id 和 Responses 的 call\_id 混用。

## 代码调用

四语言示例均自动执行一次无副作用的本地乘法并回传，最多请求两轮，不无限循环。设置 `SIMIROUTER_API_KEY`、`SIMIROUTER_MODEL`；`SIMIROUTER_BASE_URL` 可覆盖默认网关地址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 示例只使用标准库；curl 示例的 JSON 由 Python 3 安全编码。

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

## 错误码

| HTTP 状态   | 含义或厂商错误类型    | 处理方式                      |
| --------- | ------------ | ------------------------- |
| 400       | 请求无效         | 检查必填字段、JSON、模型参数和上下文长度。   |
| 401       | 认证失败         | 检查 Key 是否存在、有效及归属正确。      |
| 403 / 404 | 无权访问 / 资源不存在 | 检查模型权限、资源 ID 和 URL。       |
| 429       | 速率或配额限制      | 结合响应体区分限流与额度不足，后者不能靠重试解决。 |
| 500 / 503 | 服务错误 / 暂时不可用 | 保留请求标识，对暂时故障做有限次数退避。      |

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 arguments 解析失败、未知函数或业务执行失败是应用侧错误，不应伪造工具执行成功。成功的 HTTP 响应也可能只是在请求工具，而非完成用户任务。

## 官方参考

* [OpenAI 函数调用](https\://developers.openai.com/api/docs/guides/function-calling)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI Responses](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)