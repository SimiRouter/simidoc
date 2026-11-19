# Gemini-format model list

## Endpoint overview

`GET /v1beta/models` returns a Gemini-format model list.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $SIMIROUTER_API_KEY` . Direct Google access uses `https://generativelanguage.googleapis.com`, usually with `x-goog-api-key: $GEMINI_API_KEY`, not the gateway Bearer key. Select a model available to the account that supports the required capability.

The gateway list primarily discovers model names; it is not Google’s complete native capability catalog.

## Request parameters

Gateway list requests have no body and require no pagination parameters. Native Google models.list supports pageSize (default 50, maximum 1,000) and pageToken, but the gateway returns the full list without identical pagination or metadata guarantees.

| Field                | Type                   | Required        | Description                                                                     |
| -------------------- | ---------------------- | --------------- | ------------------------------------------------------------------------------- |
| Authorization        | header string          | Yes             | Bearer gateway key; use a Google key for official direct access.                |
| pageSize / pageToken | query integer / string | Native optional | Pagination for the official native list only; do not depend on gateway support. |

## Response

| Field                                        | Type           | Description                                                                                          |
| -------------------------------------------- | -------------- | ---------------------------------------------------------------------------------------------------- |
| models                                       | array          | The model list, which may be empty.                                                                  |
| models\[].name                               | string         | Model resource name; usually models/\{id} officially, but the gateway may return the plain model ID. |
| models\[].displayName                        | string         | Human-readable name.                                                                                 |
| nextPageToken                                | string / null  | Official next-page token; the gateway may return null when not paginated.                            |
| models\[].version / description              | string / null  | Version and description available officially; gateway values may be absent or null.                  |
| models\[].inputTokenLimit / outputTokenLimit | integer / null | Official input and output limits; do not infer values from missing fields.                           |
| models\[].supportedGenerationMethods         | array / null   | Official supported method names such as generateContent; gateway values may be absent or null.       |

```json
{
  "models": [
    {
      "name": "MODEL_ID",
      "displayName": "MODEL_ID"
    }
  ],
  "nextPageToken": null
}
```

The example above shows the gateway’s reduced structure. Before using name in a path, strip only one leading models/. A successful models.list does not guarantee generateContent access\: permissions, capabilities, or quotas may still cause failure.

## Code examples

Set `SIMIROUTER_API_KEY`. To override the default gateway root, set `SIMIROUTER_BASE_URL` without a version suffix. All examples send a GET request without a body.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1beta/models'
    request = urllib.request.Request(base + path, method="GET",
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
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const endpoint = "/v1beta/models";
      const response = await fetch(base + endpoint, { method: "GET",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    curl "${BASE_URL%/}/v1beta/models" \
      --fail-with-body \
      --max-time 120 \
      -X GET \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      endpoint := "/v1beta/models"
      req, err := http.NewRequest("GET", base + endpoint, nil); if err != nil { log.Fatal(err) }
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

Google’s native error object contains `error.code` (HTTP number), `error.status` (enum name), and `error.message`, optionally with `details`. The gateway may return authentication, routing, or quota errors before contacting the vendor; an HTTP number alone does not establish an upstream error. Internal gateway lookups may also return HTTP 200 with success=false; inspect the response structure.

## Official reference

* [Google Models API](https\://ai.google.dev/api/models)
* [Google model catalog](https\://ai.google.dev/gemini-api/docs/models)
* [Google troubleshooting](https\://ai.google.dev/gemini-api/docs/troubleshooting)