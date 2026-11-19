# Legacy text completions

## Endpoint overview

`POST /v1/completions` accepts prompt and returns completion text, without messages, tool calls, or Responses output items. It is a legacy interface; prefer Chat Completions or Responses for new projects. Only models supporting this completion protocol can use it; an arbitrary chat model ID will not work.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $SIMIROUTER_API_KEY`. Direct OpenAI access uses `https://api.openai.com` and Bearer authentication, but requires an OpenAI key. Select a model available to the account that supports the required capability.

## Quick start

1. **Prepare configuration**\: create a key in API key management and copy a full model ID that supports legacy completions from Models and pricing.
2. **Send a minimal request**\: submit a single `prompt` and keep `stream` set to `false`; first confirm that authentication, the model, and parameters are valid.
3. **Read the result**\: the request succeeds only when HTTP is 2xx and `choices[]` is non-empty; the completion is in `choices[0].text`.
4. **Verify**\: check `finish_reason` and the actual content, then confirm against the usage logs.

```bash
API_URL="https://api.dwchainless.com/v1/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "prompt": "请补全这句话：机器学习是",
    "max_tokens": 64,
    "stream": false
  }'
```

Replace `PASTE_API_KEY_HERE` and `MODEL_ID` with real values; new projects should prefer Chat Completions or Responses.

## Request parameters

JSON request body.

| Field                                  | Type           | Required    | Description                                                                                                             |
| -------------------------------------- | -------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| model                                  | string         | Yes         | A model ID supporting legacy completions.                                                                               |
| prompt                                 | string / array | Conditional | The text to complete; may also be multiple texts or token ID arrays. The examples use a string.                         |
| max\_tokens                            | integer        | No          | Maximum generated tokens; input and output together must fit the context window.                                        |
| stream                                 | boolean        | No          | true returns SSE; default false.                                                                                        |
| temperature / top\_p                   | number         | No          | Sampling control; usually adjust one.                                                                                   |
| n                                      | integer        | No          | Candidate completions per prompt.                                                                                       |
| stop                                   | string / array | No          | Up to four stop sequences; returned text excludes the stop string.                                                      |
| echo                                   | boolean        | No          | Whether to include the input prompt in returned text.                                                                   |
| logprobs                               | integer        | No          | Return log probabilities for candidate tokens, up to 5.                                                                 |
| presence\_penalty / frequency\_penalty | number         | No          | Repetition penalties, from -2 to 2.                                                                                     |
| suffix                                 | string         | No          | Only for models supporting insertion completions.                                                                       |
| best\_of                               | integer        | No          | Generate multiple candidates server-side and select the best; incompatible with stream and increases generation volume. |

### Request example

```json
{
  "model": "MODEL_ID",
  "prompt": "请补全这句话：机器学习是",
  "max_tokens": 64,
  "stream": false
}
```

## Response

| Field                                                     | Type             | Description                                                     |
| --------------------------------------------------------- | ---------------- | --------------------------------------------------------------- |
| id / object                                               | string           | Completion ID; object=text\_completion.                         |
| created / model                                           | integer / string | Unix-second timestamp and model.                                |
| choices\[].text                                           | string           | Completion result, not message.content.                         |
| choices\[].index                                          | integer          | Candidate index.                                                |
| choices\[].finish\_reason                                 | string           | stop, length, or content\_filter.                               |
| choices\[].logprobs                                       | object / null    | Token probability information; usually null when not requested. |
| usage.prompt\_tokens / completion\_tokens / total\_tokens | integer          | Input, generated, and total tokens.                             |

```json
{
  "id": "cmpl_example",
  "object": "text_completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "text": "一种从数据中学习规律的方法。",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 14,
    "total_tokens": 26
  }
}
```

For streaming, concatenate choices\[].text and end at `[DONE]`; merge separately by index for multiple prompts or candidates.

## Code examples

Set `SIMIROUTER_API_KEY`, `SIMIROUTER_COMPLETION_MODEL`; `SIMIROUTER_BASE_URL` overrides the default gateway root; do not append `/v1`. Python 3, Node.js 18+, and Go examples use only standard libraries. The curl example uses Python 3 to encode JSON safely.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_COMPLETION_MODEL"): raise RuntimeError("请设置 SIMIROUTER_COMPLETION_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    path = '/v1/completions'
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
      if (!process.env.SIMIROUTER_COMPLETION_MODEL)
        throw new Error('请设置 SIMIROUTER_COMPLETION_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        prompt: '请补全这句话：机器学习是',
        max_tokens: 64,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_COMPLETION_MODEL;
      const endpoint = '/v1/completions';
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
    : "${SIMIROUTER_COMPLETION_MODEL:?请设置 SIMIROUTER_COMPLETION_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/completions" \
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
      model := os.Getenv("SIMIROUTER_COMPLETION_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_COMPLETION_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/completions"
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

Native OpenAI errors usually contain `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` may be `null`; do not assume these fields always exist or equal the HTTP status. The gateway may return authentication, routing, or quota errors before contacting the vendor; the status alone does not establish an upstream error.

Long replies and streaming requests can take from tens of seconds to several minutes; set a sufficient client timeout, and when the stream breaks, judge from the deltas received and the termination reason instead of resending automatically. For 429 and 5xx, inspect the response body and usage logs first; when content policy rejects a request, change the prompt or input rather than retrying unchanged.

## Official reference

* [OpenAI Completions API](https\://developers.openai.com/api/reference/resources/completions/methods/create)
* [OpenAI error handling](https\://developers.openai.com/api/docs/guides/error-codes)