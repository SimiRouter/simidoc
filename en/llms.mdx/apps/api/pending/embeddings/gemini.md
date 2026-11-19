# Gemini embeddings

**SimiRouter does not currently support this endpoint. The following references direct official Google access.** The examples use a Gemini API key from Google AI Studio. Follow the Google Cloud documentation for Vertex AI request paths, project setup, and authentication.

## Endpoint overview

`POST https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent` and `x-goog-api-key: $GEMINI_API_KEY`. Examples use text input. Gemini Embedding 2 also supports model-permitted multimodal content, but those capabilities do not apply to older text-embedding models.

## Request parameters

| Field                                   | Type      | Required | Description                                                                             |
| --------------------------------------- | --------- | -------- | --------------------------------------------------------------------------------------- |
| model (path)                            | string    | Yes      | models/gemini-embedding-2; must be an available embedding model.                        |
| content                                 | object    | Yes      | The Content object to embed, with text in parts\[].text.                                |
| content.parts                           | object\[] | Yes      | Text items, or model-supported inline\_data / file\_data multimodal items.              |
| embedContentConfig                      | object    | No       | Embedding configuration; supported settings follow the model version and API Reference. |
| embedContentConfig.outputDimensionality | integer   | No       | Model-supported output dimensions; keep indexing and queries consistent.                |

`gemini-embedding-2` does not support `embedContentConfig.taskType` or `title`. Use input prefixes for retrieval tasks instead\:

* Query\: `task: search result | query: {content}`
* Document\: `title: {title} | text: {content}`; use `title: none` when there is no title
* Symmetric task\: `task: {task} | query: {content}`

`taskType` and `title` apply only to `gemini-embedding-001`. `gemini-embedding-2` does not support these fields; use the input prefixes above instead of relying on undefined field handling. The vector spaces of embedding-2 and embedding-001 are incompatible, so the index and query sides must use the same model.

The top-level fields `taskType`, `title`, `outputDimensionality` are legacy configuration entries; SDKs use a config object, so do not mix SDK snake\_case with HTTP JSON camelCase.

## Response

A synchronous request returns `embedding.values` as a floating-point array. `batchEmbedContents` accepts a requests array and returns `embeddings[]` in input order. Asynchronous `asyncBatchEmbedContent` returns a long-running task resource requiring separate status and output-file management, unlike this page’s synchronous request.

```json
{"embedding":{"values":[0.01,-0.02,0.03]}}
```

Vectors are excerpted examples. If dimensions are reduced, normalize according to model guidance; the first three elements are not a complete vector.

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

First set `GEMINI_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent'
    headers = {'x-goog-api-key': os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'models/gemini-embedding-2', 'content': {'parts': [{'text': 'task: search result | query: 如何让文档检索理解语义？'}]}}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent";
      const headers = { "x-goog-api-key": process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
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
    curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "models/gemini-embedding-2",
        "content": {
          "parts": [
            {
              "text": "task: search result | query: 如何让文档检索理解语义？"
            }
          ]
        }
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
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent", body); check(err)
      req.Header.Set("x-goog-api-key", os.Getenv("GEMINI_API_KEY"))
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

Google error objects use `error.code`, `error.status`, and `error.message`; never infer the source from the HTTP number alone. This endpoint is synchronous\: there is no task ID or polling stage. Never treat error text as an embedding result.

## Official reference

[Google Embeddings guide](https\://ai.google.dev/gemini-api/docs/embeddings), [Embedding API](https\://ai.google.dev/api/embeddings).