# API Script Integration

Use Chat Completions to send messages and read model replies. The four examples perform the same operation\: send a non-streaming JSON request to `POST /v1/chat/completions`, wait for the complete response, and print the result.

## Image request scripts

Complete examples of generation, reference-image editing, and saving results are organized by protocol in the [Image API overview](/simidoc/en/apps/api/images).

## Prepare a key and model

First, open [API key management](https://api.dwchainless.com/keys) to create a key, then copy from [Model Square](https://api.dwchainless.com/en/pricing/) the exact model ID available to that key. Examples read configuration from environment variables rather than storing the key in a file.

* `SIMIROUTER_API_KEY`\: SimiRouter API key, required.
* `SIMIROUTER_MODEL`\: exact model ID, required.
* `SIMIROUTER_BASE_URL`\: optional; defaults to `https://api.dwchainless.com`. This is the root address, without `/v1`.

Set these values in your terminal or runtime environment. Never print keys in public logs. Real API requests may incur charges.

## Drop-in with the OpenAI SDK

If your code already uses the official OpenAI SDK, replace only `baseURL` and `apiKey`, and use a full model ID from SimiRouter. `baseURL` must end with `/v1`; method names, parameters and response objects keep the OpenAI shape.

<Tabs items={["Python","Node.js"]}>
  <Tab value="Python">
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
  </Tab>

  <Tab value="Node.js">
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
  </Tab>
</Tabs>

Install the official SDK first\: `pip install openai` or `npm install openai`. The SDK handles retries, timeouts and SSE parsing; client options such as custom timeouts and `max_retries` keep their SDK semantics, and the gateway does not rewrite them.

The gateway answers with the OpenAI-compatible protocol; model capabilities still depend on the selected model. If the SDK reports `404`, check that `baseURL` is not set to `https://api.dwchainless.com` without `/v1`.

## Request and response

| Item                          | Description                                                                                |
| ----------------------------- | ------------------------------------------------------------------------------------------ |
| Method and path               | `POST /v1/chat/completions`                                                                |
| Authentication                | `Authorization: Bearer <API Key>`                                                          |
| Content type                  | `application/json`                                                                         |
| Required parameters           | `model`, `messages`                                                                        |
| Optional parameters used here | `max_completion_tokens: 256`, `stream: false`; the selected model must support them        |
| Successful response           | HTTP 200, `choices[].message.content` contains the text reply; `usage` reports token usage |
| Streaming                     | `stream: true` returns SSE, which cannot be parsed as one JSON response                    |

For complete parameters, tool calls, multimodal input, and SSE events, see [Chat Completions](/simidoc/en/apps/api/chat/openai-chat).

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

## Errors

| HTTP status | Common cause                                           | Action                                                                           |
| ----------- | ------------------------------------------------------ | -------------------------------------------------------------------------------- |
| 400         | Invalid request format or unsupported model parameters | Inspect the error body and omit unsupported optional parameters                  |
| 401         | Missing, expired, or incorrect key                     | Check environment variables and create a new key if necessary                    |
| 403         | Model, group, or channel access denied                 | Check key and account permissions                                                |
| 404         | Incorrect path or model ID                             | Check for a duplicated `/v1` and verify the exact model ID                       |
| 429         | Rate or quota limit                                    | Check quota and limits first; back off as directed, without unlimited retries    |
| 5xx         | Gateway or upstream error                              | Keep the redacted error body and request ID; check usage records before retrying |

These status codes are starting points for troubleshooting; the error body provides the actual cause. A timeout does not prove the model did not run. Never retry generation requests without a limit.

## Other capabilities

* [Responses](/simidoc/en/apps/api/chat/openai-responses)\: organize requests using typed input and output items.
* [Claude Messages](/simidoc/en/apps/api/chat/claude) and [Gemini](/simidoc/en/apps/api/chat/gemini-text)\: native message structures.
* [Images](/simidoc/en/apps/api/images)\: generation, editing, and understanding.
* [Audio](/simidoc/en/apps/api/audio)\: audio understanding, speech synthesis, transcription, and translation.
* [Video](/simidoc/en/apps/api/video)\: generation tasks and video understanding.
* [MiMo audio integration](/simidoc/en/apps/api/audio/mimo-audio)\: MiMo speech synthesis, transcription, and voice capabilities.

## Official reference

Protocol fields follow [OpenAI Chat Completions API Reference](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create). SimiRouter uses a different address and key from direct OpenAI access.