# Chat Completions

## Endpoint overview

`POST /v1/chat/completions` generates assistant replies from message history. It suits existing Chat Completions clients and stateless multi-turn conversations.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $SIMIROUTER_API_KEY`. Direct OpenAI access uses `https://api.openai.com` and Bearer authentication, but requires an OpenAI key. Select a model available to the account that supports the required capability.

## Quick start

1. **Prepare configuration**\: create a key in API key management and copy a full model ID that supports Chat Completions from Models and pricing.
2. **Send a minimal request**\: submit a single user message and keep `stream` set to `false`; first confirm that authentication, the model, and parameters are valid.
3. **Read the result**\: the request succeeds only when HTTP is 2xx and `choices[]` is non-empty; the text is in `choices[0].message.content`.
4. **Verify**\: check `finish_reason`, refusals, and the actual content, then confirm against the usage logs.

```bash
API_URL="https://api.dwchainless.com/v1/chat/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

Replace `PASTE_API_KEY_HERE` and `MODEL_ID` with real values; once it works, add multi-turn history or tools, or enable streaming.

If the project already uses the OpenAI SDK, point `baseURL` at `https://api.dwchainless.com/v1` and swap in a SimiRouter key; method names and parameters stay unchanged. See [API request scripts](/simidoc/en/apps/api-script).

## Request parameters

The content type is `application/json`. Omit unused optional fields; do not send empty strings, zeroes, empty objects, or null values indiscriminately.

| Field                                  | Type                     | Required    | Description                                                                                                               |
| -------------------------------------- | ------------------------ | ----------- | ------------------------------------------------------------------------------------------------------------------------- |
| model                                  | string                   | Yes         | The model ID.                                                                                                             |
| messages                               | array                    | Yes         | At least one message; the caller supplies required history in order.                                                      |
| messages\[].role                       | string                   | Yes         | `developer`, `system`, `user`, `assistant`, `tool`; available roles vary by model.                                        |
| messages\[].content                    | string / array / null    | Conditional | Text or content arrays for ordinary messages; assistant messages with `tool_calls` may omit this field or set it to null. |
| messages\[].content\[].type            | string                   | Conditional | The corresponding content `text`, `image_url`, `input_audio` or `file`.                                                   |
| messages\[].content\[].text            | string                   | Conditional | Text for type=text.                                                                                                       |
| messages\[].content\[].image\_url      | object                   | Conditional | For type=image\_url, supply `url` and optional `detail`; see image understanding.                                         |
| messages\[].tool\_calls                | array                    | No          | Assistant-requested function calls; each includes id, type=function, function.name, and function.arguments.               |
| messages\[].tool\_call\_id             | string                   | Conditional | Required for role=tool; matches the tool-call ID provided by the assistant.                                               |
| max\_completion\_tokens                | integer                  | No          | The generation token limit, including visible output and reasoning tokens.                                                |
| stream                                 | boolean                  | No          | true returns SSE; non-streaming by default.                                                                               |
| stream\_options.include\_usage         | boolean                  | No          | Request a usage summary chunk before streaming ends; stream must also be enabled.                                         |
| temperature / top\_p                   | number                   | No          | Sampling parameters; only for supported models. Usually adjust one.                                                       |
| stop                                   | string / array           | No          | Stop sequences; supported by some models only.                                                                            |
| n                                      | integer                  | No          | The number of candidate replies, not concurrent requests.                                                                 |
| tools / tool\_choice                   | array / string or object | No          | Function definitions and tool selection; see tool calling.                                                                |
| parallel\_tool\_calls                  | boolean                  | No          | Allow multiple function calls in one reply; this does not execute functions for the application.                          |
| response\_format                       | object                   | No          | Structured output configuration; json\_schema or json\_object where supported.                                            |
| reasoning\_effort                      | string                   | No          | Reasoning effort; allowed values depend on the model, and not every model supports it.                                    |
| presence\_penalty / frequency\_penalty | number                   | No          | Repetition penalties, from -2 to 2, where supported.                                                                      |
| logprobs / top\_logprobs               | boolean / integer        | No          | Output token probabilities and candidate count, where supported.                                                          |

`max_tokens` is a legacy parameter replaced by `max_completion_tokens`; non-o-series models may still accept it, while `/v1/completions` still uses only `max_tokens`. New integrations should not send both. `video_url`, `reasoning_content` are extensions in some compatible models, not universal OpenAI Chat Completions fields.

### Request example

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释什么是机器学习。"
    }
  ],
  "max_completion_tokens": 256,
  "stream": false
}
```

## Response

A successful non-streaming response is HTTP 200 JSON. The structure below uses illustrative IDs and token counts.

| Field                          | Type             | Description                                                                                                                                         |
| ------------------------------ | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| id / object                    | string           | Response ID; object=chat.completion.                                                                                                                |
| created / model                | integer / string | Creation time in Unix seconds and the responding model.                                                                                             |
| choices\[]                     | array            | Candidate replies; each index identifies its position.                                                                                              |
| choices\[].message.role        | string           | assistant.                                                                                                                                          |
| choices\[].message.content     | string / null    | Reply text; may be empty for tool calls or refusals, which does not itself mean the request failed.                                                 |
| choices\[].message.tool\_calls | array            | Function calls for the application to execute. arguments is a JSON string that must be parsed and validated.                                        |
| choices\[].message.refusal     | string / null    | Refusal information, if present.                                                                                                                    |
| choices\[].finish\_reason      | string           | stop means normal completion; length means the limit was reached; tool\_calls requests tool execution; content\_filter indicates content filtering. |
| usage.prompt\_tokens           | integer          | Input tokens.                                                                                                                                       |
| usage.completion\_tokens       | integer          | Generated tokens, possibly including reasoning tokens.                                                                                              |
| usage.total\_tokens            | integer          | Total input and generated tokens.                                                                                                                   |
| usage.\*\_tokens\_details      | object           | Optional usage details such as cached\_tokens and reasoning\_tokens.                                                                                |

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "机器学习是让计算机从数据中学习规律并用于预测或决策的方法。",
        "refusal": null
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 18,
    "completion_tokens": 24,
    "total_tokens": 42
  }
}
```

### Streaming responses

Set `stream: true` then receive `text/event-stream`. Parse JSON from each `data:` line; use `choices[].index` to group and concatenate `delta.content`; group function arguments from `delta.tool_calls` by tool index. The completion marker is `data: [DONE]`, not a JSON object. With include\_usage, the final usage chunk may have empty choices, and ordinary chunks may have usage=null. If the connection closes without an end signal, mark the reply incomplete rather than automatically successful.

```text
data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"content":"机器学习"},"finish_reason":null}]}

data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
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
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
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
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      if (!process.env.SIMIROUTER_API_KEY)
        throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        messages: [
          {
            role: 'user',
            content: '用一句话解释什么是机器学习。',
          },
        ],
        max_completion_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/chat/completions';
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
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/chat/completions" \
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
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
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
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

### Using the OpenAI SDK

With the official `openai` SDK installed you do not need to hand-write HTTP requests\: point `baseURL` at the gateway to reuse the official types, retries and stream parsing. Install it with `pip install openai` or `npm install openai`.

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://api.dwchainless.com/v1",
    api_key=os.environ["SIMIROUTER_API_KEY"],
)
response = client.chat.completions.create(
    model=os.environ["SIMIROUTER_MODEL"],
    messages=[{"role": "user", "content": "用一句话解释什么是机器学习。"}],
)
print(response.choices[0].message.content)
```

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'https://api.dwchainless.com/v1',
  apiKey: process.env.SIMIROUTER_API_KEY,
});
const response = await client.chat.completions.create({
  model: process.env.SIMIROUTER_MODEL,
  messages: [{ role: 'user', content: '用一句话解释什么是机器学习。' }],
});
console.log(response.choices[0].message.content);
```

## Errors

| HTTP status | Meaning or vendor error type           | Action                                                                                                           |
| ----------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| 400         | Invalid request                        | Check required fields, JSON, model parameters, and context length.                                               |
| 401         | Authentication failed                  | Check that the key exists, is valid, and belongs to the correct service.                                         |
| 403 / 404   | Access denied / resource not found     | Check model permissions, resource IDs, and the URL.                                                              |
| 429         | Rate or quota limit                    | Distinguish rate limits from insufficient quota using the response body; retrying cannot fix insufficient quota. |
| 500 / 503   | Server error / temporarily unavailable | Retain the request identifier and use bounded backoff for transient failures.                                    |

Native OpenAI errors usually contain `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` may be `null`; do not assume these fields always exist or equal the HTTP status. The gateway may return authentication, routing, or quota errors before contacting the vendor; the status alone does not establish an upstream error. Under HTTP 200, still inspect finish\_reason, refusals, and stream completeness; length and content\_filter are not HTTP errors.

Long replies and streaming requests can take from tens of seconds to several minutes; set a sufficient client timeout, and when the stream breaks, judge from the deltas received and the termination reason instead of resending automatically. For 429 and 5xx, inspect the response body and usage logs first; when content policy rejects a request, change the prompt or input rather than retrying unchanged.

### Error response examples

Error responses are usually an OpenAI-shaped `error` object, with `param` and `code` possibly `null`. The examples below are illustrative; wording changes with the gateway or provider, so never match on the message string.

```json
{
  "error": {
    "message": "You didn't provide an API key.",
    "type": "invalid_request_error",
    "param": null,
    "code": "invalid_api_key"
  }
}
```

```json
{
  "error": {
    "message": "Rate limit reached for requests.",
    "type": "rate_limit_error",
    "param": null,
    "code": "rate_limit_exceeded"
  }
}
```

## FAQ

**What should I do about a 401 or `Invalid token`?**
Check that the header is `Authorization: Bearer <Key>`, that the key belongs to this gateway and has not been revoked, and that you did not paste your login password or a provider key.

**Why do I get 404 or a missing-model error?**
`model` must be a full model ID from Models & pricing, and your key's group must be allowed to use it. SDK users should also confirm that `baseURL` includes `/v1`.

**Should I retry a 429?**
Read the response body first. For rate limiting, retry with exponential backoff and jitter; for exhausted quota or balance, retrying cannot succeed — top up or adjust the limit instead.

**When is a streamed response complete?**
Only after `data: [DONE]` and a final chunk carrying `finish_reason`. If the connection drops without an end marker, treat the reply as incomplete and do not automatically resend a request you have already paid for.

**`max_tokens` or `max_completion_tokens`?**
Use `max_completion_tokens` for Chat Completions. `max_tokens` is the legacy field and only some models still accept it. Never send both; `/v1/completions` still uses only `max_tokens`.

**Why does temperature have no effect?**
Some reasoning models fix sampling or accept only default values, and the gateway passes values through to the provider. Follow that model's documentation and errors instead of assuming every OpenAI parameter applies.

## Official reference

* [OpenAI Chat Completions API](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI text generation](https\://developers.openai.com/api/docs/guides/text)
* [OpenAI error handling](https\://developers.openai.com/api/docs/guides/error-codes)