# Gemini text generation

## Endpoint overview

`POST /v1beta/models/{model}:generateContent` accepts Gemini contents/parts and returns a complete GenerateContentResponse when not streaming. Its format differs from OpenAI messages or input.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $SIMIROUTER_API_KEY` . Direct Google access uses `https://generativelanguage.googleapis.com`, usually with `x-goog-api-key: $GEMINI_API_KEY`, not the gateway Bearer key. Select a model available to the account that supports the required capability.

## Quick start

1. **Prepare configuration**\: create a key in API key management and copy a full model ID that supports generateContent from Models and pricing.
2. **Send a minimal request**\: put the model ID directly in the path (without the `models/` prefix) and set `generationConfig.maxOutputTokens` to a small value.
3. **Read the result**\: the request succeeds only when HTTP is 2xx and `candidates[]` is non-empty; the text is usually in `candidates[0].content.parts[].text`.
4. **Verify**\: check `finishReason` and `promptFeedback`, then confirm against the usage logs.

```bash
API_URL="https://api.dwchainless.com/v1beta/models/MODEL_ID:generateContent"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"role": "user", "parts": [{"text": "用一句话解释机器学习。"}]}],
    "generationConfig": {"maxOutputTokens": 256}
  }'
```

Replace `PASTE_API_KEY_HERE` and `MODEL_ID` in the path with real values; for streaming, switch to `streamGenerateContent?alt=sse`.

## Request parameters

The request body is JSON. REST fields use lowerCamelCase; do not mechanically copy Python SDK snake\_case parameter names into REST requests.

| Field                                      | Type             | Required    | Description                                                                                                    |
| ------------------------------------------ | ---------------- | ----------- | -------------------------------------------------------------------------------------------------------------- |
| model (path)                               | string           | Yes         | The model ID without the models/ prefix; the native resource name is models/\{model}.                          |
| contents                                   | array            | Yes         | History and the current message, in order.                                                                     |
| contents\[].role                           | string           | No          | user or model; specify explicitly in multi-turn conversations.                                                 |
| contents\[].parts                          | array            | Yes         | Message content parts; at least one.                                                                           |
| parts\[].text                              | string           | Conditional | A text part; use inlineData or fileData for media.                                                             |
| systemInstruction.parts\[].text            | string           | No          | System instructions; do not substitute role=system.                                                            |
| generationConfig.maxOutputTokens           | integer          | No          | The generation token limit, accounting for the model’s reasoning-token usage rules.                            |
| generationConfig.responseMimeType          | string           | No          | Use application/json for structured output when supported by the model.                                        |
| generationConfig.responseJsonSchema        | object           | No          | Response JSON Schema, usually set together with application/json.                                              |
| generationConfig.temperature / topP / topK | number / integer | No          | Use only with models supporting this sampling configuration; do not reuse fixed parameters across generations. |
| generationConfig.stopSequences             | array            | No          | Stop strings when supported by the model.                                                                      |
| safetySettings                             | array            | No          | Safety categories and thresholds; this cannot disable all safeguards in every model.                           |
| tools / toolConfig                         | array / object   | No          | Tool definitions and calling configuration for Google Search, function calling, and more.                      |

### Request example

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "用一句话解释机器学习。"
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 256
  }
}
```

For multi-turn conversations, alternate role=user and role=model and end with the current question. The server does not automatically retain the conversation from a previous HTTP connection.

## Response

| Field                                 | Type           | Description                                                                                                                      |
| ------------------------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| candidates\[]                         | array          | Candidate results; may be empty when blocked.                                                                                    |
| candidates\[].index                   | integer        | The candidate index.                                                                                                             |
| candidates\[].content.role / parts\[] | string / array | Output role and content parts; text is usually in parts\[].text.                                                                 |
| candidates\[].finishReason            | string         | STOP means normal completion; MAX\_TOKENS means the limit was reached; SAFETY, RECITATION, and others require separate handling. |
| candidates\[].safetyRatings           | array          | Optional safety ratings.                                                                                                         |
| candidates\[].groundingMetadata       | object         | Source and citation information when grounding tools such as search are used.                                                    |
| promptFeedback.blockReason            | string         | The reason an input was blocked; candidates may be absent.                                                                       |
| usageMetadata.promptTokenCount        | integer        | Input tokens.                                                                                                                    |
| usageMetadata.candidatesTokenCount    | integer        | Candidate output tokens.                                                                                                         |
| usageMetadata.thoughtsTokenCount      | integer        | Optional thinking tokens, not directly displayable response text.                                                                |
| usageMetadata.totalTokenCount         | integer        | Total tokens for this request, possibly including tools or thinking.                                                             |
| modelVersion / responseId             | string         | Optional model version and response identifier.                                                                                  |

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "机器学习让计算机通过数据学习规律并完成预测。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 12,
    "candidatesTokenCount": 20,
    "totalTokenCount": 32
  }
}
```

### Streaming responses

Change the path to `/v1beta/models/{model}:streamGenerateContent?alt=sse`, keeping the request body unchanged. Parse each GenerateContentResponse in data and merge parts text by candidate.index; do not wait for OpenAI’s `[DONE]` marker. Finally, inspect finishReason, promptFeedback, and usage. SSE delivers increments of one generation; it is neither a background job nor parallel requests.

## Code examples

Set `SIMIROUTER_API_KEY`, `SIMIROUTER_GEMINI_MODEL`; `SIMIROUTER_BASE_URL` overrides the default gateway root; do not append `/v1`. Python 3, Node.js 18+, and Go examples use only standard libraries. The curl example uses Python 3 to encode JSON safely.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
    path = "/v1beta/models/" + urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe="") + ":generateContent"
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
      if (!process.env.SIMIROUTER_GEMINI_MODEL)
        throw new Error('请设置 SIMIROUTER_GEMINI_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '用一句话解释机器学习。',
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 256,
        },
      };
      const endpoint = `/v1beta/models/${encodeURIComponent(process.env.SIMIROUTER_GEMINI_MODEL)}:generateContent`;
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
    : "${SIMIROUTER_GEMINI_MODEL:?请设置 SIMIROUTER_GEMINI_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    MODEL_PATH=$(python3 -c 'import os, urllib.parse; print(urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe=""))')
    curl "${BASE_URL%/}/v1beta/models/${MODEL_PATH}:generateContent" \
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
      model := os.Getenv("SIMIROUTER_GEMINI_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_GEMINI_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }`), &body); err != nil { log.Fatal(err) }
      endpoint := "/v1beta/models/" + model + ":generateContent"
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

| HTTP status | Meaning or vendor error type          | Action                                                                          |
| ----------- | ------------------------------------- | ------------------------------------------------------------------------------- |
| 400         | `INVALID_ARGUMENT` and similar errors | Check JSON, model parameters, media MIME type, and input length.                |
| 403         | `PERMISSION_DENIED`                   | Check the key, project permissions, region, or billing restrictions.            |
| 404         | `NOT_FOUND`                           | Check the model name and API version.                                           |
| 429         | `RESOURCE_EXHAUSTED`                  | Check rate limits and quotas; use bounded backoff when retrying is appropriate. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`            | Record the request identifier and retry a limited number of times or later.     |

Google’s native error object contains `error.code` (HTTP number), `error.status` (enum name), and `error.message`, optionally with `details`. The gateway may return authentication, routing, or quota errors before contacting the vendor; the HTTP number alone does not establish an upstream error. Empty candidates or finishReason=SAFETY under HTTP 200 may indicate blocked content, not network failure.

Long replies and streaming requests can take from tens of seconds to several minutes; set a sufficient client timeout, and when the stream breaks, judge from the deltas received and the termination reason instead of resending automatically. For 429 and 5xx, inspect the response body and usage logs first; when content policy rejects a request, change the prompt or input rather than retrying unchanged.

## Official reference

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google text generation](https\://ai.google.dev/gemini-api/docs/text-generation)
* [Google troubleshooting](https\://ai.google.dev/gemini-api/docs/troubleshooting)