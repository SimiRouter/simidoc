# Create fine-tuning job

Submit training data and base-model settings to create an asynchronous OpenAI fine-tuning job.

**SimiRouter does not currently support this endpoint. The following references the official OpenAI API at `api.openai.com` and requires a key for the OpenAI project, not a SimiRouter key.**

OpenAI is winding down self-serve fine-tuning\: new users cannot create jobs, and eligible existing users can do so only until **January 6, 2027**, unless the base model shuts down earlier. Check the [official deprecation timeline](https\://developers.openai.com/api/docs/deprecations) before submitting.

## Endpoint overview

* **Method**\: `POST`
* **Endpoint address**\: `/v1/fine_tuning/jobs`
* **Authentication**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Request type**\: `application/json`.

The creation request returns a job object; training then runs server-side. `200` or `queued` does not establish successful training; use [Retrieve job details](/simidoc/en/apps/api/pending/fine-tuning/retrieve) to inspect the final `status`, and use [Retrieve events](/simidoc/en/apps/api/pending/fine-tuning/events) to track progress. The path is `/v1/fine_tuning/jobs`, not the legacy `/v1/fine-tunes`.

## Request parameters

| Parameters                          | Type               | Required | Description                                                                                                                                   |
| ----------------------------------- | ------------------ | -------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `model`                             | string             | Yes      | A base-model ID supporting the chosen fine-tuning method.                                                                                     |
| `training_file`                     | string             | Yes      | A JSONL training-file ID uploaded with `purpose=fine-tune`.                                                                                   |
| `validation_file`                   | string / null      | No       | A separate validation-file ID; do not duplicate training data.                                                                                |
| `method`                            | object             | No       | `type` is `supervised`, `dpo` or `reinforcement` and supply the configuration object with the same name; the method must be model-compatible. |
| `method.supervised.hyperparameters` | object             | No       | `batch_size`\: auto or 1–256; `learning_rate_multiplier`\: auto or a positive number; `n_epochs`\: auto or 1–50.                              |
| `method.dpo.hyperparameters`        | object             | No       | DPO training hyperparameters, including `beta`; do not reuse supervised-training data formats blindly.                                        |
| `method.reinforcement`              | object             | No       | Reinforcement fine-tuning configuration, including `grader` and method-specific hyperparameters.                                              |
| `suffix`                            | string / null      | No       | Custom suffix for the resulting model name, up to 64 characters.                                                                              |
| `seed`                              | integer / null     | No       | Random seed; the same seed does not guarantee exact reproducibility.                                                                          |
| `metadata`                          | object / null      | No       | Up to 16 key-value pairs; keys up to 64 characters, values up to 512.                                                                         |
| `integrations`                      | array / null       | No       | External training-metrics integrations, such as `wandb` configured with a project name.                                                       |
| `hyperparameters`                   | object, deprecated | No       | Legacy top-level form; new settings belong under `method`.                                                                                    |

The model and file IDs in the body are structural examples; actual calls require resources from the corresponding project.

```json
{
  "model": "selected-base-model",
  "training_file": "file-training",
  "method": {
    "type": "supervised",
    "supervised": {
      "hyperparameters": {
        "n_epochs": 2
      }
    }
  }
}
```

## Response

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

Response example (core fields only, not an actual job)\:

```json
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
```

## Code examples

Requirements\: Python 3, Node.js 20+, curl, or Go 1.20+. Save each language example as a `.py`, `.cjs`, `.sh`, `.go` file, then run it.

Set `OPENAI_API_KEY`, `OPENAI_FINE_TUNING_MODEL` and `OPENAI_TRAINING_FILE_ID`. The curl example uses Python 3 to generate JSON. The base model must support fine-tuning in the official project. Training incurs costs\: execute only after confirming data, method, and budget. Do not create jobs as connectivity tests.

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
    model = required("OPENAI_FINE_TUNING_MODEL")
    training_file = required("OPENAI_TRAINING_FILE_ID")
    payload = {"model": model, "training_file": training_file}
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        "https://api.openai.com/v1/fine_tuning/jobs",
        method="POST",
        data=data,
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
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
      const model = required("OPENAI_FINE_TUNING_MODEL");
      const training_file = required("OPENAI_TRAINING_FILE_ID");
      const body = JSON.stringify({"model": model, "training_file": training_file});
      const response = await fetch("https://api.openai.com/v1/fine_tuning/jobs", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body,
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
    : "${OPENAI_FINE_TUNING_MODEL:?请设置 OPENAI_FINE_TUNING_MODEL}"
    : "${OPENAI_TRAINING_FILE_ID:?请设置 OPENAI_TRAINING_FILE_ID}"
    payload=$(python3 - <<'JSON'
    import json, os
    print(json.dumps({"model": os.environ["OPENAI_FINE_TUNING_MODEL"], "training_file": os.environ["OPENAI_TRAINING_FILE_ID"]}))
    JSON
    )

    curl "https://api.openai.com/v1/fine_tuning/jobs" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request POST \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --header "Content-Type: application/json" \
      --data "$payload"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"bytes"
    	"encoding/json"
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
    	model := required("OPENAI_FINE_TUNING_MODEL")
    	training_file := required("OPENAI_TRAINING_FILE_ID")
    	payload, err := json.Marshal(map[string]any{"model": model, "training_file": training_file})
    	check(err)
    	req, err := http.NewRequest("POST", "https://api.openai.com/v1/fine_tuning/jobs", bytes.NewReader(payload))
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	req.Header.Set("Content-Type", "application/json")
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

* [OpenAI create fine-tuning job](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/create)
* [OpenAI model optimization guide](https\://developers.openai.com/api/docs/guides/model-optimization)
* [OpenAI error codes](https\://developers.openai.com/api/docs/guides/error-codes)