# List files

List accessible files in the current OpenAI project with pagination.

**SimiRouter does not currently support this endpoint. The following references the official OpenAI API at `api.openai.com` and requires a key for the OpenAI project, not a SimiRouter key.**

## Endpoint overview

* **Method**\: `GET`
* **Endpoint address**\: `/v1/files`
* **Authentication**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Request type**\: no request body.

Synchronously returns the current page as JSON; when `has_more=true`, additional page requests are required. One call does not automatically return all files.

## Request parameters

| Parameters | Type           | Required | Description                                               |
| ---------- | -------------- | -------- | --------------------------------------------------------- |
| `after`    | string, query  | No       | The last file ID on the previous page.                    |
| `limit`    | integer, query | No       | 1–10,000 files per page, default 10,000; examples use 20. |
| `order`    | string, query  | No       | Sort by creation time\: `asc` or `desc`, default `desc`.  |
| `purpose`  | string, query  | No       | Return only files with the specified purpose.             |

## Response

| Field                  | Type          | Description                                                   |
| ---------------------- | ------------- | ------------------------------------------------------------- |
| `object`               | string        | List type, usually `list`.                                    |
| `data`                 | FileObject\[] | Files on the current page; object fields are described below. |
| `first_id` / `last_id` | string        | The first and last file IDs on the current page.              |
| `has_more`             | boolean       | Whether another page exists.                                  |

| Field            | Type                                | Description                                                                                                                    |
| ---------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `id`             | string                              | File ID for subsequent requests.                                                                                               |
| `object`         | string                              | Always `file`.                                                                                                                 |
| `bytes`          | integer / null                      | File size in bytes; may be null before size is available.                                                                      |
| `created_at`     | integer                             | Creation time as a Unix-second timestamp.                                                                                      |
| `filename`       | string                              | The uploaded filename.                                                                                                         |
| `purpose`        | string                              | File purpose, such as `fine-tune`, `user_data`; generated output files may use `fine-tune-results` or other values.            |
| `expires_at`     | integer / null, optional            | Expiration as a Unix-second timestamp; may be empty without an expiration policy.                                              |
| `status`         | string, deprecated                  | Legacy status field\: `uploaded`, `processed` or `error`. Do not substitute it for the consuming endpoint’s processing status. |
| `status_details` | string / null, optional, deprecated | Legacy status description; read fine-tuning validation errors from the job’s `error`.                                          |

```json
{
  "object": "list",
  "data": [
    {
      "id": "file-demo",
      "object": "file",
      "bytes": 4096,
      "created_at": 1793491200,
      "filename": "training.jsonl",
      "purpose": "fine-tune",
      "expires_at": null
    }
  ],
  "first_id": "file-demo",
  "last_id": "file-demo",
  "has_more": false
}
```

## Code examples

Requirements\: Python 3, Node.js 20+, curl, or Go 1.20+. Save each language example as a `.py`, `.cjs`, `.sh`, `.go` file, then run it.

Set `OPENAI_API_KEY`. The example retrieves the first 20 files. For the next page, pass the previous page’s `last_id` as the `after` query parameter.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    def required(name):
        value = os.environ.get(name)
        if not value:
            raise SystemExit(f"请设置 {name}")
        return value

    key = required("OPENAI_API_KEY")

    request = urllib.request.Request(
        "https://api.openai.com/v1/files?limit=20&order=desc",
        method="GET",
        data=None,
        headers={"Authorization": "Bearer " + key},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = response.read()
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    print(json.dumps(json.loads(result), ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    function required(name) {
      const value = process.env[name];
      if (!value) throw new Error(`请设置 ${name}`);
      return value;
    }
    async function main() {
      const key = required("OPENAI_API_KEY");

      const response = await fetch("https://api.openai.com/v1/files?limit=20&order=desc", {
        method: "GET",
        headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(JSON.stringify(await response.json(), null, 2));
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"

    curl "https://api.openai.com/v1/files?limit=20&order=desc" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request GET \
      --header "Authorization: Bearer $OPENAI_API_KEY"
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
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func required(name string) string {
    	value := os.Getenv(name)
    	if value == "" {
    		log.Fatal("请设置 " + name)
    	}
    	return value
    }
    func main() {
    	key := required("OPENAI_API_KEY")

    	req, err := http.NewRequest("GET", "https://api.openai.com/v1/files?limit=20&order=desc", nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 120 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	result, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, result)
    	}
    	fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Errors

The following are common HTTP errors from direct official OpenAI requests, not SimiRouter support statuses.

| HTTP status   | Meaning                                             | Action                                                                                                                      |
| ------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `400`         | Invalid parameters, file purpose, or resource state | Read `error.message` and `error.param` and correct the issue before resubmitting.                                           |
| `401`         | Invalid or missing key                              | Check the OpenAI key and its project.                                                                                       |
| `403`         | No access to the project or resource                | Check project, organization, and role permissions.                                                                          |
| `404`         | File, job, or model not found                       | Verify the ID and use a key belonging to the resource’s project.                                                            |
| `429`         | Rate limit or insufficient quota                    | Distinguish rate limits from quota errors; back off for rate limits, but do not repeatedly submit with insufficient quota.  |
| `500` / `503` | Server error or temporarily unavailable             | Retain the request ID. Before retrying writes, check whether a resource was created to avoid duplicate uploads or training. |

Unsuccessful responses usually contain `error.message`, `error.type`, `error.param` and `error.code`; fields may be empty.

## Official reference

* [OpenAI list files](https\://developers.openai.com/api/reference/resources/files/methods/list)
* [OpenAI error codes](https\://developers.openai.com/api/docs/guides/error-codes)