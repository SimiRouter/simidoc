# OpenAI-format model list

## Endpoint overview

`GET /v1/models` returns models visible to the current key. It can populate a model selector, but does not establish all modalities, tools, quota availability, or current service health.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $SIMIROUTER_API_KEY`. Direct OpenAI access uses `https://api.openai.com` and Bearer authentication, but requires an OpenAI key. Select a model available to the account that supports the required capability.

Send only Bearer authentication; do not mix x-api-key or x-goog-api-key, which may trigger another gateway response format.

## Request parameters

This list request has no JSON body or required query parameters.

| Field         | Type          | Required | Description                   |
| ------------- | ------------- | -------- | ----------------------------- |
| Authorization | header string | Yes      | The gateway key after Bearer. |

## Response

| Field                             | Type                   | Description                                                                                                                                                    |
| --------------------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| object                            | string                 | list.                                                                                                                                                          |
| data                              | array                  | The model list, which may be empty.                                                                                                                            |
| data\[].id                        | string                 | The model ID used in generation requests.                                                                                                                      |
| data\[].object                    | string                 | model.                                                                                                                                                         |
| data\[].created                   | integer                | Unix-second timestamp; gateway metadata may not reflect the vendor’s model release date.                                                                       |
| data\[].owned\_by                 | string                 | An ownership label; it does not prove routing to a particular vendor.                                                                                          |
| success                           | boolean                | An optional gateway business-result flag, not an OpenAI standard field.                                                                                        |
| `data[].context_length`           | integer                | Context length in tokens reported by the gateway. The platform default applies when no value is configured. Check the model documentation and endpoint limits. |
| `data[].supported_endpoint_types` | `array<string>` / null | Endpoint types reported by the gateway. Use them as a guide when selecting an endpoint.                                                                        |

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

An empty array is valid; do not access data\[0] without checking. A failed gateway group lookup may return HTTP 200 with success=false/message; clients must detect this application-level failure. Official OpenAI also provides GET /v1/models/\{model}; list metadata is not a complete capability description.

## Code examples

Set `SIMIROUTER_API_KEY`. To override the default gateway root, set `SIMIROUTER_BASE_URL` without a version suffix. All examples send a GET request without a body.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1/models'
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
      const endpoint = "/v1/models";
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
    curl "${BASE_URL%/}/v1/models" \
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
      endpoint := "/v1/models"
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

| HTTP status | Meaning or vendor error type           | Action                                                                                                           |
| ----------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| 400         | Invalid request                        | Check required fields, JSON, model parameters, and context length.                                               |
| 401         | Authentication failed                  | Check that the key exists, is valid, and belongs to the correct service.                                         |
| 403 / 404   | Access denied / resource not found     | Check model permissions, resource IDs, and the URL.                                                              |
| 429         | Rate or quota limit                    | Distinguish rate limits from insufficient quota using the response body; retrying cannot fix insufficient quota. |
| 500 / 503   | Server error / temporarily unavailable | Retain the request identifier and use bounded backoff for transient failures.                                    |

Native OpenAI errors usually contain `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` may be `null`; do not assume these fields always exist or equal the HTTP status. The gateway may return authentication, routing, or quota errors before contacting the vendor; the status alone does not establish an upstream error. Also check gateway success=false application errors, which differ from successful HTTP transport.

## Official reference

* [OpenAI List models](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [OpenAI Retrieve model](https\://developers.openai.com/api/reference/resources/models/methods/retrieve)
* [OpenAI error handling](https\://developers.openai.com/api/docs/guides/error-codes)