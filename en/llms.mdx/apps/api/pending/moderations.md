# Content moderation

## Endpoint overview

`POST https://api.openai.com/v1/moderations` synchronously evaluates safety categories for text or images using `Authorization: Bearer $OPENAI_API_KEY`. SimiRouter routing, models, and permissions require separate confirmation; examples below connect directly to OpenAI.

Moderation results are risk signals, not legal-compliance conclusions or a guarantee against missed cases. Image and text categories may differ. Inspect category\_applied\_input\_types; unsupported input in a category does not establish safety.

## Request parameters

| Field                   | Type                           | Required    | Description                                                                                 |
| ----------------------- | ------------------------------ | ----------- | ------------------------------------------------------------------------------------------- |
| model                   | string                         | No          | For example, omni-moderation-latest; pinning a specific model reduces alias-update effects. |
| input                   | string / string\[] / object\[] | Yes         | Text or multimodal content items.                                                           |
| input\[].type           | string                         | Conditional | text or image\_url.                                                                         |
| input\[].text           | string                         | Conditional | Text to moderate.                                                                           |
| input\[].image\_url.url | string                         | Conditional | An image URL or data URL meeting model input requirements.                                  |

## Response

| Field                                    | Description                                                            |
| ---------------------------------------- | ---------------------------------------------------------------------- |
| `id` / `model`                           | Request identifier and moderation model.                               |
| `results[].flagged`                      | Whether any category was flagged.                                      |
| `results[].categories`                   | Boolean results by category.                                           |
| `results[].category_scores`              | Category scores, not human judgment or fixed thresholds across models. |
| `results[].category_applied_input_types` | Input types applicable to each category.                               |

```json
{"id":"modr_example","model":"omni-moderation-latest","results":[{"flagged":false,"categories":{},"category_scores":{},"category_applied_input_types":{}}]}
```

The example omits category keys; actual responses include category details. Retain necessary risk evidence rather than keeping all raw user content indefinitely.

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

Set `OPENAI_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/moderations'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'omni-moderation-latest', 'input': '这是一段需要进行安全审核的示例文本。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/moderations";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
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
    curl "https://api.openai.com/v1/moderations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "omni-moderation-latest",
        "input": "这是一段需要进行安全审核的示例文本。"
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
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/moderations", body); check(err)
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

| HTTP status           | Meaning and action                                                                                         |
| --------------------- | ---------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Invalid fields, file format, or model parameters; correct before resubmitting.                             |
| 401                   | Missing, invalid, or expired API key.                                                                      |
| 403                   | No access to the project or model.                                                                         |
| 404                   | Model or route not found; check the address and project ownership.                                         |
| 413 / 415             | Upload too large or unsupported media type.                                                                |
| 429                   | Rate or quota limit; distinguish insufficient funds from retryable throttling.                             |
| 500 / 502 / 503 / 504 | Service or upstream failure. Keep the request ID, inspect the response body, then decide whether to retry. |

The error body’s `error.message`, `error.type`, `error.code` gives more specific reasons than HTTP status alone. Do not treat the error body as a moderation result.

## Official reference

[OpenAI Create moderation](https\://developers.openai.com/api/reference/resources/moderations/methods/create).