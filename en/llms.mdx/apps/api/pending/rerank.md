# Document reranking

## Endpoint overview

Reranking compares a query with candidate documents and returns indices and relevance scores in ranked order. It does not generate answers or embedding vectors. Availability of SimiRouter’s `/v1/rerank` requires channel confirmation; the following demonstrates only **official Cohere access** `POST https://api.cohere.com/v2/rerank` and `Authorization: Bearer $COHERE_API_KEY`.

## Request parameters

| Field                 | Type      | Required | Description                                                                                                                                        |
| --------------------- | --------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                 | string    | Yes      | For example, rerank-v5.0-pro; select a model enabled for your account.                                                                             |
| query                 | string    | Yes      | The search query.                                                                                                                                  |
| documents             | string\[] | Yes      | Candidate text strings; the official recommendation is no more than 1,000 per request. Structured content can first be serialized as YAML strings. |
| top\_n                | integer   | No       | At least 1; omit to return all results.                                                                                                            |
| max\_tokens\_per\_doc | integer   | No       | Default 4,096; long documents are truncated.                                                                                                       |
| relevant\_spans       | object    | No       | v5 and newer models can return relevant text spans.                                                                                                |
| priority              | integer   | No       | 0–999; default 0. Lower numbers have higher priority.                                                                                              |

Cohere v2 documents is an array of strings; do not mix in undefined objects. `return_documents` belongs to other protocol versions and is not sent in this example.

## Response

`results[]` is sorted by relevance\: `index` points to the original document index, and `relevance_score` is the relevance score. When enabled and supported, responses include `relevant_spans[]`. Scores are not accuracy measures or uniform probabilities comparable across models. `meta.billed_units` records usage.

```json
{"results":[{"index":1,"relevance_score":0.95},{"index":0,"relevance_score":0.12}],"id":"request_example","meta":{"api_version":{"version":"2"}}}
```

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

Set the official Cohere `COHERE_API_KEY`. Examples use a positive top\_n and nonempty queries and documents.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.cohere.com/v2/rerank'
    headers = {'Authorization': 'Bearer ' + os.environ['COHERE_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'rerank-v5.0-pro', 'query': '法国首都是哪里？', 'documents': ['柏林是德国首都。', '巴黎是法国首都。'], 'top_n': 2}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.cohere.com/v2/rerank";
      const headers = { "Authorization": "Bearer " + process.env.COHERE_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
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
    curl "https://api.cohere.com/v2/rerank" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $COHERE_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "rerank-v5.0-pro",
        "query": "法国首都是哪里？",
        "documents": [
          "柏林是德国首都。",
          "巴黎是法国首都。"
        ],
        "top_n": 2
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
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
    }`)
      req, err := http.NewRequest("POST", "https://api.cohere.com/v2/rerank", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("COHERE_API_KEY"))
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

| HTTP status           | Description                                                                         |
| --------------------- | ----------------------------------------------------------------------------------- |
| 400 / 422             | Invalid parameters or model-incompatible input.                                     |
| 401 / 498             | Authentication failed or token invalid.                                             |
| 403 / 404             | Insufficient permissions or resource not found.                                     |
| 429                   | Rate limit; check quota and use bounded backoff.                                    |
| 499                   | The client closed the request.                                                      |
| 500 / 501 / 503 / 504 | Internal service error, unimplemented operation, or timeout; retain the request ID. |

## Official reference

[Cohere Rerank v2](https\://docs.cohere.com/reference/rerank).