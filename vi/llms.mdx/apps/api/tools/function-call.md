# Gọi công cụ hàm

## Tổng quan API

`POST /v1/chat/completions` dùng tools cho biết hàm có sẵn. Mô hình chỉ sinh tên/tham số; ứng dụng kiểm tra, cấp quyền, chạy, trả tool và yêu cầu đáp án cuối. Gọi hàm không tự truy cập CSDL, chuyển tiền hay gửi thông báo thay ứng dụng.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

## Tham số yêu cầu

| Trường                        | Kiểu            | Bắt buộc     | Mô tả                                                             |
| ----------------------------- | --------------- | ------------ | ----------------------------------------------------------------- |
| model / messages              | string / array  | Có           | Mô hình và hội thoại; mô hình phải hỗ trợ hàm.                    |
| tools\[].type                 | string          | Có           | Ở đây là function.                                                |
| tools\[].function.name        | string          | Có           | Tên hàm để phân phối qua danh sách cho phép ứng dụng.             |
| tools\[].function.description | string          | Không        | Mô tả mục đích, giới hạn vào và tác dụng phụ.                     |
| tools\[].function.parameters  | object          | Có           | JSON Schema tham số hàm.                                          |
| tools\[].function.strict      | boolean         | Không        | true yêu cầu khớp nghiêm tập con Schema hỗ trợ.                   |
| tool\_choice                  | string / object | Không        | auto tự chọn; none tắt; required ít nhất một; có thể chỉ tên hàm. |
| parallel\_tool\_calls         | boolean         | Không        | Cho nhiều hàm cùng lượt; false giới hạn tối đa một.               |
| messages\[].tool\_call\_id    | string          | Có điều kiện | Tin tool trả về phải khớp id trong assistant tool\_calls.         |
| messages\[].content           | string          | Có điều kiện | Kết quả trong tin tool, nên tuần tự hóa thành chữ JSON.           |

strict=true cần additionalProperties=false mỗi đối tượng, mọi properties trong required. Trường tùy chọn logic có thể cho null. Schema không hỗ trợ gây lỗi.

### Yêu cầu đầu

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

## Phản hồi

| Trường                               | Kiểu          | Mô tả                                                              |
| ------------------------------------ | ------------- | ------------------------------------------------------------------ |
| choices\[].message.tool\_calls\[].id | string        | ID công cụ dùng cho tool\_call\_id sau.                            |
| tool\_calls\[].type                  | string        | function.                                                          |
| tool\_calls\[].function.name         | string        | Tên hàm yêu cầu, phải khớp danh sách cho phép.                     |
| tool\_calls\[].function.arguments    | string        | Chữ JSON, chưa là đối tượng; phân tích rồi kiểm tra kiểu/giá trị.  |
| choices\[].message.content           | string / null | Có thể null khi gọi hàm.                                           |
| choices\[].finish\_reason            | string        | tool\_calls cần chạy công cụ; stop thường là đáp án ngôn ngữ cuối. |
| usage                                | object        | Mỗi lượt mô hình có mức token riêng.                               |

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

### Thực thi và trả kết quả

Kiểm tra name=multiply\_numbers, a/b là số nguyên trong miền cho phép; kết quả 391. Dưới là yêu cầu lượt hai đầy đủ; thay call\_example bằng ID thực lượt đầu, không tái dùng ID tĩnh cho tùy ý yêu cầu.

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

Mỗi tool\_call phải có kết quả; không bỏ hoặc trộn ID hội thoại khác. Chỉ song song công cụ độc lập, được phép. Gửi ra ngoài, tính phí cần idempotency riêng; mô hình yêu cầu lại không làm thực thi trùng.

### Khác biệt định dạng Responses

Responses đặt type, name, description, parameters, strict trực tiếp tools\[], không bọc function; trả mục type=function\_call, trả kết quả bằng `{"type":"function_call_output","call_id":"...","output":"391"}`. Không trộn tool\_call\_id Chat và call\_id Responses.

## Ví dụ mã

Bốn ví dụ tự chạy phép nhân cục bộ không tác dụng phụ rồi trả, tối đa hai lượt, không vòng vô hạn. Đặt `SIMIROUTER_API_KEY`, `SIMIROUTER_MODEL`; `SIMIROUTER_BASE_URL` để ghi đè địa chỉ cổng mặc định; không thêm `/v1`. Ví dụ Python 3, Node.js 18+ và Go chỉ dùng thư viện chuẩn; ví dụ curl dùng Python 3 để mã hóa JSON an toàn.

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

## Mã lỗi

| Trạng thái HTTP | Ý nghĩa hoặc loại lỗi hãng           | Cách xử lý                                                                                              |
| --------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------- |
| 400             | Yêu cầu không hợp lệ                 | Kiểm tra trường bắt buộc, JSON, tham số và độ dài ngữ cảnh.                                             |
| 401             | Xác thực thất bại                    | Kiểm tra khóa có, hợp lệ và thuộc đúng dịch vụ.                                                         |
| 403 / 404       | Không có quyền / không có tài nguyên | Kiểm tra quyền mô hình, ID và URL.                                                                      |
| 429             | Giới hạn tốc độ hoặc hạn mức         | Theo thân phản hồi phân biệt giới hạn tốc độ với thiếu hạn mức; thử lại không giải quyết thiếu hạn mức. |
| 500 / 503       | Lỗi máy chủ / tạm không khả dụng     | Giữ ID yêu cầu, lùi thời gian giới hạn cho lỗi tạm.                                                     |

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn có hoặc bằng HTTP. Cổng có thể lỗi trước hãng. Lỗi phân tích arguments, hàm lạ hay nghiệp vụ là lỗi ứng dụng; không giả công cụ thành công. HTTP thành công có thể chỉ yêu cầu công cụ, chưa hoàn tất tác vụ người dùng.

## Tham khảo chính thức

* [Gọi hàm OpenAI](https\://developers.openai.com/api/docs/guides/function-calling)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI Responses](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)