# List fine-tuning jobs

List jobs visible to the current key in the OpenAI organization, with pagination.

**SimiRouter does not currently support this endpoint. The following references the official OpenAI API at `api.openai.com` and requires a key for the OpenAI project, not a SimiRouter key.**

## Endpoint overview

* **Method**\: `GET`
* **Endpoint address**\: `/v1/fine_tuning/jobs`
* **Authentication**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Request type**\: no request body.

Synchronous paginated query; does not start or wait for training. Status meanings match [Retrieve job details](/simidoc/en/apps/api/pending/fine-tuning/retrieve).

## Request parameters

| Parameters | Type                 | Required | Description                                                                                                   |
| ---------- | -------------------- | -------- | ------------------------------------------------------------------------------------------------------------- |
| `after`    | string, query        | No       | The last job ID on the previous page.                                                                         |
| `limit`    | integer, query       | No       | Jobs per page; default 20.                                                                                    |
| `metadata` | object / null, query | No       | Filter with `metadata[key]=value`; `metadata=null` selects jobs without metadata. Do not combine these forms. |

## Response

| Field      | Type             | Description                                                  |
| ---------- | ---------------- | ------------------------------------------------------------ |
| `object`   | string           | Always `list`.                                               |
| `data`     | FineTuningJob\[] | Job objects on the current page.                             |
| `has_more` | boolean          | Whether another page exists; use the last job ID as `after`. |

| Field              | Type                     | Description                                                                                            |
| ------------------ | ------------------------ | ------------------------------------------------------------------------------------------------------ |
| `id` / `object`    | string                   | Job ID; object type is always `fine_tuning.job`.                                                       |
| `model`            | string                   | The base model used for training.                                                                      |
| `status`           | string                   | `validating_files`, `queued`, `running`, `pausing`, `paused`, `succeeded`, `failed` or `cancelled`.    |
| `created_at`       | integer                  | Creation time as a Unix-second timestamp.                                                              |
| `finished_at`      | integer / null           | Finish time; empty before termination.                                                                 |
| `estimated_finish` | integer / null, optional | Estimated completion time, not a guarantee.                                                            |
| `fine_tuned_model` | string / null            | The resulting model ID; empty before it is produced.                                                   |
| `training_file`    | string                   | Training file ID.                                                                                      |
| `validation_file`  | string / null            | Validation file ID; empty if not configured.                                                           |
| `result_files`     | string\[]                | Result file IDs, downloadable through the official Files API.                                          |
| `trained_tokens`   | integer / null           | Billable training tokens; may be empty while running.                                                  |
| `error`            | object / null            | Failure details, including `code`, `message`, `param`; for non-parameter errors, `param` may be empty. |
| `organization_id`  | string                   | The job’s organization.                                                                                |
| `seed`             | integer / null           | The random seed used for this training run.                                                            |
| `method`           | object / null, optional  | Fine-tuning method and its configuration.                                                              |
| `hyperparameters`  | object / null, optional  | Compatibility field for supervised fine-tuning hyperparameters.                                        |
| `integrations`     | array / null, optional   | Enabled external metrics integrations.                                                                 |
| `metadata`         | object / null, optional  | Custom key-value job metadata.                                                                         |

```json
{
  "object": "list",
  "data": [
    {
      "id": "ftjob-demo",
      "object": "fine_tuning.job",
      "model": "selected-base-model",
      "created_at": 1793491200,
      "finished_at": null,
      "fine_tuned_model": null,
      "status": "queued",
      "training_file": "file-training",
      "validation_file": null,
      "result_files": [],
      "trained_tokens": null,
      "error": null,
      "organization_id": "org-demo",
      "seed": null,
      "method": {
        "type": "supervised"
      },
      "metadata": {}
    }
  ],
  "has_more": false
}
```

## Code examples

Requirements\: Python 3, Node.js 20+, curl, or Go 1.20+. Save each language example as a `.py`, `.cjs`, `.sh`, `.go` file, then run it.

Set `OPENAI_API_KEY`. Examples retrieve the first 20; if `has_more=true`, inspect `data` and use its final object’s `id` as the next page’s `after`.

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
        "https://api.openai.com/v1/fine_tuning/jobs?limit=20",
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

      const response = await fetch("https://api.openai.com/v1/fine_tuning/jobs?limit=20", {
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

    curl "https://api.openai.com/v1/fine_tuning/jobs?limit=20" \
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

    	req, err := http.NewRequest("GET", "https://api.openai.com/v1/fine_tuning/jobs?limit=20", nil)
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

* [OpenAI fine-tuning job list](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/list)
* [OpenAI error codes](https\://developers.openai.com/api/docs/guides/error-codes)