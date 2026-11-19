# Query Seedance video task

## Endpoint overview

`GET https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/{id}`, authentication `Authorization: Bearer $ARK_API_KEY`. This page uses the official Ark protocol, not generic gateway video statuses.

## Request parameters

| Field     | Type   | Required | Description                                                 |
| --------- | ------ | -------- | ----------------------------------------------------------- |
| id (path) | string | Yes      | The cgt- task ID from creation, in the same account/region. |

No JSON body. Task IDs generally remain valid for seven days; some newly created Draft tasks have separate lifetimes. Do not use task endpoints as permanent archives.

## Response

| Field                                                   | Description                                                          |
| ------------------------------------------------------- | -------------------------------------------------------------------- |
| `id` / `model`                                          | Task ID and model version.                                           |
| `status`                                                | queued, running, succeeded, failed, expired, cancelled.              |
| `content.video_url`                                     | Result URL after success, usually valid for 24 hours; save promptly. |
| `content.last_frame_url`                                | Last-frame image URL when requested and supported.                   |
| `error.code` / `error.message`                          | Failure reason; may be empty.                                        |
| `created_at` / `updated_at`                             | Unix-second timestamp.                                               |
| `usage`                                                 | Task usage statistics, model-dependent.                              |
| `duration` / `ratio` / `resolution` / `framespersecond` | Actual video specifications.                                         |
| `seed` / `service_tier` / `execution_expires_after`     | Execution settings and reproducibility information.                  |

```json
{"id":"cgt-example","model":"doubao-seedance-2-5-260628","status":"succeeded","content":{"video_url":"https://example.com/video.mp4"},"error":null,"created_at":1780000000,"updated_at":1780000120}
```

Download only when succeeded and video\_url is nonempty. Stop polling immediately for failed, expired, or cancelled. Example URLs illustrate fields only.

## Code examples

Set `ARK_API_KEY` and `TASK_ID`; `TASK_ID` must be the actual creation task ID. Python 3, Node.js 18+, and Go examples use only standard libraries. curl additionally requires Python 3 for safe path encoding. Poll every 5–10 seconds with an application-level overall timeout; examples query once only.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    key = os.environ.get("ARK_API_KEY")
    task_id = os.environ.get("TASK_ID")
    if not key or not task_id or not task_id.strip():
        raise SystemExit("请设置 ARK_API_KEY 和 TASK_ID")
    url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + urllib.parse.quote(task_id, safe="")
    request = urllib.request.Request(url, headers={"Authorization": "Bearer " + key}, method="GET")
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            print(json.dumps(json.load(response), ensure_ascii=False, indent=2))
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const key = process.env.ARK_API_KEY;
      const taskId = process.env.TASK_ID;
      if (!key || !taskId?.trim()) throw new Error("请设置 ARK_API_KEY 和 TASK_ID");
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + encodeURIComponent(taskId);
      const response = await fetch(url, {
        method: "GET", headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(180000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${ARK_API_KEY:?请设置 ARK_API_KEY}"
    : "${TASK_ID:?请设置 TASK_ID 为创建接口返回的真实任务 ID}"
    TASK_PATH=$(python3 - <<'PY_TASK'
    import os, urllib.parse
    task_id = os.environ["TASK_ID"]
    if not task_id.strip():
        raise SystemExit("TASK_ID 不能为空白")
    print(urllib.parse.quote(task_id, safe=""))
    PY_TASK
    )
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/${TASK_PATH}" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      --header "Authorization: Bearer $ARK_API_KEY"
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
    	"net/url"
    	"os"
    	"strings"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func main() {
    	key, taskID := os.Getenv("ARK_API_KEY"), os.Getenv("TASK_ID")
    	if key == "" || strings.TrimSpace(taskID) == "" {
    		log.Fatal("请设置 ARK_API_KEY 和 TASK_ID")
    	}
    	endpoint := "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + url.PathEscape(taskID)
    	req, err := http.NewRequest("GET", endpoint, nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 180 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	data, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, data)
    	}
    	fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Errors

| HTTP status           | Meaning and action                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Invalid fields, file format, or model parameters; correct before resubmitting.                                            |
| 401                   | Missing, invalid, or expired API key.                                                                                     |
| 403                   | No access to the project or model.                                                                                        |
| 404                   | Model, route, or task not found; check the address and resource ownership.                                                |
| 413 / 415             | Upload too large or unsupported media type.                                                                               |
| 429                   | Rate or quota limit; distinguish insufficient funds from retryable throttling.                                            |
| 500 / 502 / 503 / 504 | Service or upstream failure. Keep the request ID; after a creation timeout, check acceptance before creating a duplicate. |

Volcengine error objects use `error.code`, `error.message` and retain the request ID. A successful query HTTP response still requires checking task status and error.

## Official reference

[Volcengine Ark query task](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh).