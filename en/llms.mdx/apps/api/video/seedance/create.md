# Create Seedance video task

## Endpoint overview

`POST https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks`, `Authorization: Bearer $ARK_API_KEY`, with a JSON body. The following is the official direct protocol, **not** a guaranteed mapping to SimiRouter `/v1/video/generations`.

## Request parameters

| Field                     | Type      | Required    | Description                                                                                                                                               |
| ------------------------- | --------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                     | string    | Yes         | An enabled Seedance model ID or inference-endpoint ID.                                                                                                    |
| content                   | object\[] | Yes         | Text and model-supported image/video/audio content items.                                                                                                 |
| content\[].type           | string    | Yes         | text, image\_url, video\_url, audio\_url, or draft\_task according to model capabilities.                                                                 |
| content\[].draft\_task.id | string    | Conditional | Draft task ID when type=draft\_task, used to render a final video from a draft.                                                                           |
| content\[].text           | string    | Conditional | The prompt for type=text.                                                                                                                                 |
| content\[].image\_url.url | string    | Conditional | An accessible image or model-permitted data URL.                                                                                                          |
| content\[].role           | string    | No          | For example, first\_frame, last\_frame, or reference\_image; use according to model and asset type.                                                       |
| resolution                | string    | No          | A model-permitted resolution\: 480p, 720p, 1080p, or 4k depending on the model; drafts support 480p only.                                                 |
| ratio                     | string    | No          | For example, 16\:9, 9\:16, 1\:1 or adaptive; consult the model capability table.                                                                          |
| duration                  | integer   | No          | Video duration, with model-specific limits; -1 for models supporting automatic duration.                                                                  |
| frames                    | integer   | No          | Frame count, only where supported; when sent with duration, frames takes precedence.                                                                      |
| generate\_audio           | boolean   | No          | Whether to generate an audio track; audio-capable models only.                                                                                            |
| watermark                 | boolean   | No          | Visible watermark settings; follow synthetic-content labeling requirements.                                                                               |
| seed                      | integer   | No          | Random seed; reproducibility is not a pixel-perfect guarantee.                                                                                            |
| return\_last\_frame       | boolean   | No          | Request the last-frame image.                                                                                                                             |
| callback\_url             | string    | No          | Status-change callback URL; receivers must handle duplicates and out-of-order notifications.                                                              |
| execution\_expires\_after | integer   | No          | Task expiration in seconds; default 172,800, range 3,600–259,200.                                                                                         |
| service\_tier             | string    | No          | default / flex, according to model support.                                                                                                               |
| draft                     | boolean   | No          | Create a draft video; defaults to false and accepts 480p only on supported models. To render a final video from a draft, use `content[].type=draft_task`. |
| priority                  | integer   | No          | Queue priority for supported models/service tiers; not universal.                                                                                         |

This example selects Seedance 2.5 with text-only input and short-video settings. For 1.0 pro / 2.0, adjust fields to that version’s capabilities; do not assume all multimodal references, audio, or drafts are available.

## Response

Successful creation returns `id`, not a finished video. Save the ID, then use [Query task status](/simidoc/en/apps/api/video/seedance/status).

```json
{"id":"cgt-example"}
```

A timeout does not prove the server rejected the request. Avoid unlimited automatic resubmission. Callback receivers should update state idempotently by task ID.

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

Set the official `ARK_API_KEY`; this creates a potentially billable task.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks'
    headers = {'Authorization': 'Bearer ' + os.environ['ARK_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'doubao-seedance-2-5-260628', 'content': [{'type': 'text', 'text': '海边日落时，一艘白色帆船缓缓驶过，镜头平稳。'}], 'duration': 5, 'ratio': '16:9', 'generate_audio': True, 'watermark': True}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks";
      const headers = { "Authorization": "Bearer " + process.env.ARK_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
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
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $ARK_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "doubao-seedance-2-5-260628",
        "content": [
          {
            "type": "text",
            "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
          }
        ],
        "duration": 5,
        "ratio": "16:9",
        "generate_audio": true,
        "watermark": true
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
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
    }`)
      req, err := http.NewRequest("POST", "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("ARK_API_KEY"))
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

| HTTP status           | Meaning and action                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Invalid fields, file format, or model parameters; correct before resubmitting.                                            |
| 401                   | Missing, invalid, or expired API key.                                                                                     |
| 403                   | No access to the project or model.                                                                                        |
| 404                   | Model, route, or task not found; check the address and resource ownership.                                                |
| 413 / 415             | Upload too large or unsupported media type.                                                                               |
| 429                   | Rate or quota limit; distinguish insufficient funds from retryable throttling.                                            |
| 500 / 502 / 503 / 504 | Service or upstream failure. Keep the request ID; after a creation timeout, check acceptance before creating a duplicate. |

Volcengine error objects use `error.code`, `error.message` and retain a request ID. Generation failures also require reading task-query results; creation HTTP status does not establish final success.

Volcengine errors use `error.code`, `error.message` and request IDs; read generation failures from the query result’s error field as well.

## Official reference

[Volcengine Ark create task](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh), [Official integration tutorial](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh).