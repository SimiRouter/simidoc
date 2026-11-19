# Query Kling text-to-video task

## Endpoint overview

`GET https://api-singapore.klingai.com/tasks` and `Authorization: Bearer $KLING_API_KEY`. New Kling text-to-video and image-to-video use the same task query; do not append `/v1/videos/.../{id}`.

## Request parameters

| Field                       | Type   | Required   | Description                                                                              |
| --------------------------- | ------ | ---------- | ---------------------------------------------------------------------------------------- |
| task\_ids (query)           | string | Choose one | System task IDs, comma-separated for multiple values.                                    |
| external\_task\_ids (query) | string | Choose one | Values from options.external\_task\_id at creation, comma-separated for multiple values. |

Do not send both query parameters; there is no JSON body. Set `TASK_ID` to the creation response’s `data.id`.

## Response

| Field                             | Description                                                                         |
| --------------------------------- | ----------------------------------------------------------------------------------- |
| `code` / `message` / `request_id` | Business status and tracking identifier; parse data only if code=0.                 |
| `data[]`                          | Task array matching the query.                                                      |
| `data[].id` / `external_id`       | System and custom IDs.                                                              |
| `data[].status`                   | submitted, processing, succeeded, failed.                                           |
| `data[].message`                  | Failure reason.                                                                     |
| `data[].outputs[]`                | Distinguishes video/image/audio and other outputs by type, not legacy task\_result. |
| `outputs[].url` / `watermark_url` | Video result URL and available watermarked version.                                 |
| `outputs[].duration`              | Output video duration in seconds.                                                   |
| `create_time` / `update_time`     | Unix-millisecond timestamp.                                                         |
| `billing[]`                       | Returned billing-unit and related information.                                      |

```json
{"code":0,"message":"Success","request_id":"request_example","data":[{"id":"task_example","status":"succeeded","outputs":[{"type":"video","url":"https://example.com/video.mp4","duration":"5"}]}]}
```

Download only when status=succeeded and a valid type=video output exists. Links have access/retention limits; save promptly and stop polling on failure. HTTP success with data=\[] requires checking the ID and account, not marking generation successful.

## Code examples

Set `KLING_API_KEY` and `TASK_ID`; `TASK_ID` must be the actual creation task ID. Python 3, Node.js 18+, and Go examples use only standard libraries. curl uses `--data-urlencode` to encode query parameters. Poll every 5–10 seconds with an application-level overall timeout; examples query once only.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    key = os.environ.get("KLING_API_KEY")
    task_id = os.environ.get("TASK_ID")
    if not key or not task_id or not task_id.strip():
        raise SystemExit("请设置 KLING_API_KEY 和 TASK_ID")
    url = "https://api-singapore.klingai.com/tasks?" + urllib.parse.urlencode({"task_ids": task_id})
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
      const key = process.env.KLING_API_KEY;
      const taskId = process.env.TASK_ID;
      if (!key || !taskId?.trim()) throw new Error("请设置 KLING_API_KEY 和 TASK_ID");
      const url = new URL("https://api-singapore.klingai.com/tasks");
      url.searchParams.set("task_ids", taskId);
      const response = await fetch(url, {
        method: "GET", headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(180000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${KLING_API_KEY:?请设置 KLING_API_KEY}"
    : "${TASK_ID:?请设置 TASK_ID 为创建接口返回的真实任务 ID}"
    [[ "$TASK_ID" =~ [^[:space:]] ]] || { printf '%s\n' 'TASK_ID 不能为空白' >&2; exit 1; }
    curl "https://api-singapore.klingai.com/tasks" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      --get \
      --data-urlencode "task_ids=$TASK_ID" \
      --header "Authorization: Bearer $KLING_API_KEY"
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
    	key, taskID := os.Getenv("KLING_API_KEY"), os.Getenv("TASK_ID")
    	if key == "" || strings.TrimSpace(taskID) == "" {
    		log.Fatal("请设置 KLING_API_KEY 和 TASK_ID")
    	}
    	query := url.Values{"task_ids": []string{taskID}}
    	endpoint := "https://api-singapore.klingai.com/tasks?" + query.Encode()
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

| HTTP / business code               | Description                                                                              |
| ---------------------------------- | ---------------------------------------------------------------------------------------- |
| 200 / 0                            | Request succeeded; generation completion still depends on task status.                   |
| 400 / 1201                         | Invalid parameters; read message.                                                        |
| 404 / 1202, 1203                   | Wrong method or missing model/resource.                                                  |
| 401                                | Invalid API key or legacy JWT.                                                           |
| 400 / 1300, 1301                   | Platform policy or content-safety restriction; revise content rather than retry blindly. |
| 429 / 1302, 1303, 1304             | Rate, concurrency, or IP-policy limit.                                                   |
| 500 / 5000; 503 / 5001; 504 / 5002 | Service error or timeout; retain request\_id.                                            |

HTTP 200 is not business success; check code=0 before reading data.

## Official reference

[Kling official task query](https\://kling.ai/document-api/apiReference/model/textToVideo).