# Responses API

## Endpoint overview

`POST /v1/responses` uses input and output items rather than Chat choices/message, making it suitable for tools, multimodal content, and structured output.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $SIMIROUTER_API_KEY`. Direct OpenAI access uses `https://api.openai.com` and Bearer authentication, but requires an OpenAI key. Select a model available to the account that supports the required capability.

The gateway provides response creation, but no general `GET /v1/responses/{id}` or cancellation endpoint. Therefore, the native OpenAI asynchronous workflow with `background: true` is not supported through this integration; use synchronous requests or SSE. Background jobs require direct official integration with complete create, retrieve, and cancel capabilities.

## Quick start

1. **Prepare configuration**\: create a key in API key management and copy a full model ID that supports Responses from Models and pricing.
2. **Send a minimal request**\: pass a short text as `input` and keep `stream` set to `false`; first confirm that authentication, the model, and parameters are valid.
3. **Read the result**\: the request succeeds only when HTTP is 2xx and `status` is `completed`; the text is in the `output[].content[]` item where `type=output_text`.
4. **Verify**\: check `error`, `incomplete_details`, and the actual content, then confirm against the usage logs.

```bash
API_URL="https://api.dwchainless.com/v1/responses"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "input": "用一句话解释机器学习。",
    "stream": false
  }'
```

Replace `PASTE_API_KEY_HERE` and `MODEL_ID` with real values; once it works, add tools or structured output, or enable streaming.

## Request parameters

The content type is `application/json`.

| Field                                                 | Type                     | Required    | Description                                                                                                                                                                         |
| ----------------------------------------------------- | ------------------------ | ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                                                 | string                   | Yes         | Required for gateway calls; choose a Responses-compatible model.                                                                                                                    |
| input                                                 | string / array           | Conditional | Text or a list of input items; ordinary generation needs input, optionally with available historical context.                                                                       |
| input\[].role                                         | string                   | Conditional | Message role\: user, assistant, system, or developer.                                                                                                                               |
| input\[].content\[].type                              | string                   | Conditional | Typed content such as input\_text, input\_image, or input\_file.                                                                                                                    |
| input\[].content\[].text                              | string                   | Conditional | Text for type=input\_text.                                                                                                                                                          |
| input\[].content\[].image\_url                        | string                   | Conditional | An image URL or data URL for type=input\_image.                                                                                                                                     |
| input\[].content\[].file\_data / file\_url / file\_id | string                   | Conditional | Select one file source for type=input\_file; see file understanding.                                                                                                                |
| instructions                                          | string                   | No          | High-priority instructions; provide required instructions again when using previous\_response\_id.                                                                                  |
| max\_output\_tokens                                   | integer                  | No          | Maximum total output tokens, including reasoning tokens.                                                                                                                            |
| stream                                                | boolean                  | No          | true returns an SSE stream with typed events.                                                                                                                                       |
| previous\_response\_id                                | string                   | No          | Previous response ID; depends on retained upstream state and the same accessible context. Do not combine with conversation.                                                         |
| conversation                                          | string / object          | No          | Conversation object or ID; cannot be combined with previous\_response\_id. Availability depends on the channel.                                                                     |
| store                                                 | boolean                  | No          | Ask the upstream to store the response; not a gateway-log retention switch.                                                                                                         |
| tools / tool\_choice                                  | array / string or object | No          | Function or vendor-provided tools and selection rules.                                                                                                                              |
| parallel\_tool\_calls                                 | boolean                  | No          | Whether one response may include multiple function calls.                                                                                                                           |
| reasoning                                             | object                   | No          | Supported reasoning models can configure effort and summary; options vary by model.                                                                                                 |
| text.format                                           | object                   | No          | Text format such as type=json\_schema; differs from Chat response\_format.                                                                                                          |
| temperature / top\_p                                  | number                   | No          | Sampling parameters where supported by the model.                                                                                                                                   |
| truncation                                            | string                   | No          | Deprecated by OpenAI; prefer context\_management. disabled (default) errors when context is exceeded, while auto may drop some context. Gateway support depends on actual behavior. |
| include                                               | array                    | No          | Request additional data such as reasoning.encrypted\_content or web\_search\_call.action.sources.                                                                                   |
| metadata                                              | object                   | No          | Application correlation metadata; do not store sensitive information here.                                                                                                          |

Omit optional fields when not configured. `stop`, `enable_thinking` and similar compatibility extensions are not standard OpenAI Responses fields. `reasoning_content` is not a standard output field either. Reasoning uses a separate reasoning item and does not guarantee access to internal chain-of-thought.

### Request example

```json
{
  "model": "MODEL_ID",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "用一句话解释什么是机器学习。"
        }
      ]
    }
  ],
  "max_output_tokens": 256,
  "stream": false
}
```

## Response

A successful non-streaming request returns HTTP 200. Key fields are shown below; unused optional state fields may be null.

| Field                                                | Type             | Description                                                                                                                           |
| ---------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| id / object                                          | string           | Response ID; object=response.                                                                                                         |
| created\_at / model                                  | integer / string | Creation time in Unix seconds and model.                                                                                              |
| status                                               | string           | completed, incomplete, failed, queued, in\_progress, or cancelled; these states can appear in both streamed and background responses. |
| output\[]                                            | array            | Typed output items may mix message, reasoning, function\_call, web\_search\_call, and more; do not hard-code output\[0].              |
| output\[].type / id / status                         | string           | Output item type, ID, and status, where applicable.                                                                                   |
| output\[].role                                       | string           | Message output usually uses assistant.                                                                                                |
| output\[].content\[]                                 | array            | Message content items\: type=output\_text for text, type=refusal for refusals.                                                        |
| output\[].content\[].text / annotations              | string / array   | Response text and annotations such as citations.                                                                                      |
| output\[].call\_id / name / arguments                | string           | The function\_call correlation ID, name, and JSON-string arguments.                                                                   |
| error                                                | object / null    | Failure information; usually null on normal completion.                                                                               |
| incomplete\_details                                  | object / null    | The incomplete reason, such as max\_output\_tokens; do not treat it as complete success.                                              |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | Input, output, and total tokens.                                                                                                      |
| usage.\*\_tokens\_details                            | object           | Optional usage details such as caching and reasoning.                                                                                 |

```json
{
  "id": "resp_example",
  "object": "response",
  "created_at": 1760000000,
  "model": "MODEL_ID",
  "status": "completed",
  "error": null,
  "incomplete_details": null,
  "output": [
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "机器学习让计算机从数据中学习规律，用于预测和决策。",
          "annotations": []
        }
      ]
    }
  ],
  "usage": {
    "input_tokens": 18,
    "output_tokens": 22,
    "total_tokens": 40
  }
}
```

To extract text, iterate through `output` for items of `type=message` and concatenate the text in their `content` under `type=output_text`. The SDK’s `output_text` is a convenience aggregation property, not a required field in raw REST JSON.

### Streaming responses

With stream=true, parse SSE `event` and `data`\: response.created creates the response; response.output\_text.delta appends text; response.output\_item.added/done manage output items; response.function\_call\_arguments.delta assembles tool arguments. Only response.completed plus the final response.status establishes complete success. Handle response.failed, response.incomplete, and error separately; network EOF alone does not mean success.

```text
event: response.output_text.delta
data: {"type":"response.output_text.delta","item_id":"msg_example","output_index":0,"content_index":0,"delta":"机器学习","sequence_number":3}

event: response.completed
data: {"type":"response.completed","response":{"id":"resp_example","object":"response","status":"completed","output":[]},"sequence_number":12}
```

## Code examples

Set `SIMIROUTER_API_KEY`, `SIMIROUTER_MODEL`; `SIMIROUTER_BASE_URL` overrides the default gateway root; do not append `/v1`. Python 3, Node.js 18+, and Go examples use only standard libraries. The curl example uses Python 3 to encode JSON safely.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
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
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        input: [
          {
            role: 'user',
            content: [
              {
                type: 'input_text',
                text: '用一句话解释什么是机器学习。',
              },
            ],
          },
        ],
        max_output_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/responses';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
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
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
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

## Errors

| HTTP status | Meaning or vendor error type           | Action                                                                                                           |
| ----------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| 400         | Invalid request                        | Check required fields, JSON, model parameters, and context length.                                               |
| 401         | Authentication failed                  | Check that the key exists, is valid, and belongs to the correct service.                                         |
| 403 / 404   | Access denied / resource not found     | Check model permissions, resource IDs, and the URL.                                                              |
| 429         | Rate or quota limit                    | Distinguish rate limits from insufficient quota using the response body; retrying cannot fix insufficient quota. |
| 500 / 503   | Server error / temporarily unavailable | Retain the request identifier and use bounded backoff for transient failures.                                    |

Native OpenAI errors usually contain `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` may be `null`; do not assume these fields always exist or equal the HTTP status. The gateway may return authentication, routing, or quota errors before contacting the vendor; the status alone does not establish an upstream error. Even under HTTP 200, inspect status, error, and incomplete\_details; SSE failure events may not change an HTTP status already sent.

Long replies and streaming requests can take from tens of seconds to several minutes; set a sufficient client timeout, and when the stream breaks, judge from the deltas received and the termination reason instead of resending automatically. For 429 and 5xx, inspect the response body and usage logs first; when content policy rejects a request, change the prompt or input rather than retrying unchanged.

## Official reference

* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI streaming events](https\://developers.openai.com/api/docs/guides/streaming-responses)
* [OpenAI conversation state](https\://developers.openai.com/api/docs/guides/conversation-state)
* [OpenAI background mode](https\://developers.openai.com/api/docs/guides/background)
* [OpenAI error handling](https\://developers.openai.com/api/docs/guides/error-codes)