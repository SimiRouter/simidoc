# Claude Messages

## Endpoint overview

`POST /v1/messages` accepts user/assistant messages and returns a Message containing text, tool-use, or thinking blocks. Use the top-level system field for system instructions; do not add role=system entries to messages.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $SIMIROUTER_API_KEY`. Direct Anthropic access uses `https://api.anthropic.com` and `x-api-key: $ANTHROPIC_API_KEY`. The examples pin `anthropic-version: 2023-06-01` to select a protocol version; this does not imply it is the latest. Select a model available to the account that supports the required capability.

## Quick start

1. **Prepare configuration**\: create a key in API key management and copy a full model ID that supports Claude Messages from Models and pricing.
2. **Send a minimal request**\: submit a single user message, keep the `anthropic-version` header, and leave `stream` set to `false`.
3. **Read the result**\: the request succeeds only when HTTP is 2xx and `content[]` is non-empty; the text is in the content block where `type=text`.
4. **Verify**\: check `stop_reason`, `stop_sequence`, and the actual content, then confirm against the usage logs.

```bash
API_URL="https://api.dwchainless.com/v1/messages"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "anthropic-version: 2023-06-01" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "max_tokens": 256,
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

Replace `PASTE_API_KEY_HERE` and `MODEL_ID` with real values; `anthropic-version` selects the protocol version and does not indicate the latest one.

## Request parameters

The request body is JSON; example headers include `anthropic-version: 2023-06-01`.

| Field                         | Type             | Required    | Description                                                                                                                     |
| ----------------------------- | ---------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------- |
| model                         | string           | Yes         | An accessible Claude model ID.                                                                                                  |
| max\_tokens                   | integer          | Yes         | The generation token limit; use a positive integer for ordinary generation. Zero is only for supported cache-writing workflows. |
| messages                      | array            | Yes         | The conversation message list.                                                                                                  |
| messages\[].role              | string           | Yes         | user or assistant.                                                                                                              |
| messages\[].content           | string / array   | Yes         | A text string or an array of content blocks.                                                                                    |
| content\[].type               | string           | Conditional | The corresponding type, such as text, image, tool\_use, or tool\_result.                                                        |
| content\[].text               | string           | Conditional | The body of a text block.                                                                                                       |
| content\[].source             | object           | Conditional | An image source\: base64 with media\_type/data, or url with a url field.                                                        |
| system                        | string / array   | No          | System instructions; text blocks are available where supported.                                                                 |
| stream                        | boolean          | No          | true returns SSE; non-streaming by default.                                                                                     |
| stop\_sequences               | array            | No          | Custom stop sequences.                                                                                                          |
| temperature / top\_p / top\_k | number / integer | No          | Sampling settings; only for models that support them.                                                                           |
| tools                         | array            | No          | Function tool definitions containing name, description, and input\_schema.                                                      |
| tool\_choice                  | object           | No          | Tool selection such as auto, any, tool, or none; specify name when using tool.                                                  |
| thinking                      | object           | No          | Thinking configuration varies by model generation; not all models accept adaptive, enabled, or other modes.                     |
| metadata.user\_id             | string           | No          | An application user identifier; do not send direct personal identifiers.                                                        |

### Request example

```json
{
  "model": "MODEL_ID",
  "max_tokens": 256,
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释机器学习。"
    }
  ],
  "stream": false
}
```

## Response

A non-streaming HTTP 200 response is a Message.

| Field                                                             | Type          | Description                                                                                                                                                    |
| ----------------------------------------------------------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| id / type                                                         | string        | Message ID; type=message.                                                                                                                                      |
| role / model                                                      | string        | assistant and the responding model ID.                                                                                                                         |
| content\[]                                                        | array         | A list of content blocks; not every item contains text.                                                                                                        |
| content\[].type / text                                            | string        | Read text for type=text and id/name/input for tool\_use.                                                                                                       |
| stop\_reason                                                      | string / null | end\_turn means normal completion; max\_tokens means the limit was reached; stop\_sequence indicates a matched stop string; tool\_use requests tool execution. |
| stop\_sequence                                                    | string / null | The matched stop sequence, or null.                                                                                                                            |
| usage.input\_tokens / output\_tokens                              | integer       | Input and output tokens.                                                                                                                                       |
| usage.cache\_creation\_input\_tokens / cache\_read\_input\_tokens | integer       | Optional cache creation and cache-read usage; do not simply treat these as additional text.                                                                    |

```json
{
  "id": "msg_example",
  "type": "message",
  "role": "assistant",
  "model": "MODEL_ID",
  "content": [
    {
      "type": "text",
      "text": "机器学习是一种从数据中提取规律并用于预测的方法。"
    }
  ],
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 14,
    "output_tokens": 24
  }
}
```

### Streaming responses

With stream=true, process message\_start, content\_block\_start, content\_block\_delta, content\_block\_stop, message\_delta, and message\_stop in order. Append text\_delta text and input\_json\_delta partial\_json tool arguments, parsing only after assembly. message\_delta provides stop reasons and usage updates; message\_stop ends the message. An error event may arrive after HTTP 200.

For tools, retain the assistant content blocks and return results using `{"type":"tool_result","tool_use_id":"...","content":"..."}` in a subsequent user message. Validate arguments and permissions before executing a tool.

## Code examples

Set `SIMIROUTER_API_KEY`, `SIMIROUTER_CLAUDE_MODEL`; `SIMIROUTER_BASE_URL` overrides the default gateway root; do not append `/v1`. Python 3, Node.js 18+, and Go examples use only standard libraries. The curl example uses Python 3 to encode JSON safely.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_CLAUDE_MODEL"): raise RuntimeError("请设置 SIMIROUTER_CLAUDE_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    path = '/v1/messages'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={'anthropic-version': '2023-06-01', "Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
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
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_CLAUDE_MODEL)
        throw new Error('请设置 SIMIROUTER_CLAUDE_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        max_tokens: 256,
        messages: [
          {
            role: 'user',
            content: '用一句话解释机器学习。',
          },
        ],
        stream: false,
      };
      body.model = process.env.SIMIROUTER_CLAUDE_MODEL;
      const endpoint = '/v1/messages';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          'anthropic-version': '2023-06-01',
          Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000),
      });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_CLAUDE_MODEL:?请设置 SIMIROUTER_CLAUDE_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/messages" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "anthropic-version: 2023-06-01" \
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
      model := os.Getenv("SIMIROUTER_CLAUDE_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_CLAUDE_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/messages"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("anthropic-version", "2023-06-01")
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

## Errors

| HTTP status     | Meaning or vendor error type                       | Action                                                                            |
| --------------- | -------------------------------------------------- | --------------------------------------------------------------------------------- |
| 400             | `invalid_request_error`                            | Request structure, parameters, or model capabilities do not match.                |
| 401 / 403       | `authentication_error` / `permission_error`        | The key is invalid or access is denied.                                           |
| 404             | `not_found_error`                                  | The endpoint, model, or resource does not exist.                                  |
| 413             | `request_too_large`                                | Reduce the request size.                                                          |
| 429             | `rate_limit_error`                                 | Check rate and quota limits.                                                      |
| 500 / 504 / 529 | `api_error` / `timeout_error` / `overloaded_error` | Service error, timeout, or overload; retry transient failures only, with a limit. |

Native Anthropic errors have the form `{"type":"error","error":{"type":"invalid_request_error","message":"..."},"request_id":"..."}`. The gateway may return authentication, routing, or quota errors before contacting the vendor; an HTTP status alone does not establish that an error came from upstream.

Long replies and streaming requests can take from tens of seconds to several minutes; set a sufficient client timeout, and when the stream breaks, judge from the deltas received and the termination reason instead of resending automatically. For 429 and 5xx, inspect the response body and usage logs first; when content policy rejects a request, change the prompt or input rather than retrying unchanged.

## Official reference

* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Anthropic API versions](https\://platform.claude.com/docs/en/api/versioning)
* [Anthropic error handling](https\://platform.claude.com/docs/en/api/errors)