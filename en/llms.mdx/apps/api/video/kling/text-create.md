# Kling text-to-video

## Endpoint overview

`POST https://api-singapore.klingai.com/text-to-video/kling-3.0`, authentication `Authorization: Bearer $KLING_API_KEY`, with a JSON body. The example uses Kling’s official new version, not SimiRouter’s `/kling/v1/videos/...` legacy mapping.

## Request parameters

| Field                           | Type    | Required | Description                                                                                      |
| ------------------------------- | ------- | -------- | ------------------------------------------------------------------------------------------------ |
| prompt                          | string  | Yes      | Up to 3,072 characters; recommended under 2,500. May include positive and negative descriptions. |
| settings.resolution             | string  | No       | 720p (default), 1080p, or 4k, subject to model permissions.                                      |
| settings.duration               | integer | No       | Default 5 seconds; the current 3.0 reference allows 3–15 seconds.                                |
| settings.audio                  | string  | No       | off (default) or native for a native audio track.                                                |
| settings.multi\_shot            | boolean | No       | Default true; this example uses false for a single shot.                                         |
| settings.aspect\_ratio          | string  | No       | 16\:9 (default), 9\:16, 1\:1.                                                                    |
| options.callback\_url           | string  | No       | Task-status callback; implement secure reception and idempotency.                                |
| options.external\_task\_id      | string  | No       | An account-unique custom task ID for querying; does not replace the system ID.                   |
| options.watermark\_info.enabled | boolean | No       | Whether to also provide watermarked results; custom watermarks are unsupported.                  |

Field existence alone does not establish support across models. Multi-shot prompts must follow official shot syntax, and shot durations must sum to total duration. First/last frame, element count, and asset-format limits follow the current model documentation.

## Response

```json
{"code":0,"message":"Success","request_id":"request_example","data":{"id":"task_example","status":"submitted","create_time":1780000000000,"update_time":1780000000000}}
```

`data.id` is the system task ID used for polling; `data.status` can be submitted, processing, succeeded, or failed. Timestamps use milliseconds. Creation returns no finished video. Do not read the legacy `data.task_id` or `task_status`.

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

Set Kling’s official `KLING_API_KEY`. The call creates a billable task. After creation, see [Task query](/simidoc/en/apps/api/video/kling/text-status).

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api-singapore.klingai.com/text-to-video/kling-3.0'
    headers = {'Authorization': 'Bearer ' + os.environ['KLING_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'prompt': '日落时的海边灯塔，海浪缓缓拍岸，镜头平稳向前。', 'settings': {'resolution': '720p', 'duration': 5, 'audio': 'off', 'multi_shot': False, 'aspect_ratio': '16:9'}}, timeout=180)
    response.raise_for_status()
    result = response.json()
    if result.get("code") != 0:
        raise RuntimeError(result)
    print(result)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api-singapore.klingai.com/text-to-video/kling-3.0";
      const headers = { "Authorization": "Bearer " + process.env.KLING_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "prompt": "日落时的海边灯塔，海浪缓缓拍岸，镜头平稳向前。",
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false,
        "aspect_ratio": "16:9"
      }
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "https://api-singapore.klingai.com/text-to-video/kling-3.0" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $KLING_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "prompt": "日落时的海边灯塔，海浪缓缓拍岸，镜头平稳向前。",
        "settings": {
          "resolution": "720p",
          "duration": 5,
          "audio": "off",
          "multi_shot": false,
          "aspect_ratio": "16:9"
        }
      }'
    python3 - "$response" <<'PY_CHECK'
    import json, sys
    from pathlib import Path
    result = json.loads(Path(sys.argv[1]).read_text())
    if result.get("code") != 0:
        raise SystemExit(json.dumps(result, ensure_ascii=False))
    print(json.dumps(result, ensure_ascii=False))
    PY_CHECK
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "encoding/json"
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
      "prompt": "日落时的海边灯塔，海浪缓缓拍岸，镜头平稳向前。",
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false,
        "aspect_ratio": "16:9"
      }
    }`)
      req, err := http.NewRequest("POST", "https://api-singapore.klingai.com/text-to-video/kling-3.0", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("KLING_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      var result struct { Code int `json:"code"` }
      check(json.Unmarshal(data, &result))
      if result.Code != 0 { panic(string(data)) }
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

[Kling official API](https\://kling.ai/document-api/apiReference/model/textToVideo), [Authentication](https\://kling.ai/document-api/api/get-started/authentication), [Errors](https\://kling.ai/document-api/api/get-started/error-codes).