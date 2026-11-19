# OpenAI embeddings

**SimiRouter does not currently support this endpoint. The following references direct official OpenAI access.**

## Endpoint overview

`POST https://api.openai.com/v1/embeddings`, `Content-Type: application/json`, `Authorization: Bearer $OPENAI_API_KEY`. Each request returns complete vectors; SSE is not supported.

## Request parameters

| Field            | Type                              | Required | Description                                                                                                    |
| ---------------- | --------------------------------- | -------- | -------------------------------------------------------------------------------------------------------------- |
| model            | string                            | Yes      | An available embedding model such as text-embedding-3-small or text-embedding-3-large.                         |
| input            | string / string\[] / token arrays | Yes      | Nonempty text or token input; up to 2,048 array items, 8,192 tokens per input, and 300,000 tokens per request. |
| dimensions       | integer                           | No       | A positive integer; text-embedding-3 and later supported models can reduce dimensions.                         |
| encoding\_format | string                            | No       | float (default) returns floating-point arrays; base64 returns encoded strings.                                 |
| user             | string                            | No       | An end-user identifier without plaintext personal information.                                                 |

## Response

| Field                                        | Description                                                     |
| -------------------------------------------- | --------------------------------------------------------------- |
| `object`                                     | list.                                                           |
| `data[].object`                              | embedding.                                                      |
| `data[].index`                               | The corresponding input-array position.                         |
| `data[].embedding`                           | A vector array or Base64 string, according to encoding\_format. |
| `model`                                      | The model used.                                                 |
| `usage.prompt_tokens` / `usage.total_tokens` | Token statistics.                                               |

The following omits middle vector elements to illustrate structure only\:

```json
{"object":"list","data":[{"object":"embedding","index":0,"embedding":[0.01,-0.02]}],"model":"text-embedding-3-small","usage":{"prompt_tokens":3,"total_tokens":3}}
```

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

Set `OPENAI_API_KEY`. This synchronous batch-input example aligns results with the two inputs by index.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/embeddings'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'text-embedding-3-small', 'input': ['语义搜索', '文档检索'], 'encoding_format': 'float'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/embeddings";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.openai.com/v1/embeddings" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "text-embedding-3-small",
        "input": [
          "语义搜索",
          "文档检索"
        ],
        "encoding_format": "float"
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/embeddings", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Errors

| HTTP status           | Meaning and action                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| 400                   | Invalid request fields or model parameters; correct the request before resubmitting.                                                 |
| 401                   | Missing, invalid, or expired API key.                                                                                                |
| 403                   | No access to the project or model.                                                                                                   |
| 404                   | Model or route not found; check the address and model ID.                                                                            |
| 429                   | Rate or quota limit; distinguish insufficient funds from retryable throttling.                                                       |
| 500 / 502 / 503 / 504 | Service or upstream failure. Keep the request ID and back off for temporary faults; do not retry the same paid request indefinitely. |

The error body’s `error.message`, `error.type`, and `error.code` give more specific reasons than the HTTP status. This endpoint is synchronous\: there is no task ID or polling stage. Never treat error text as an embedding result.

## Official reference

[OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings/methods/create), [Embeddings guide](https\://developers.openai.com/api/docs/guides/embeddings).