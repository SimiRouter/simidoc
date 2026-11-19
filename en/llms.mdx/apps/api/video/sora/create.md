# Create Sora video (official API closed)

**Official OpenAI Sora 2 and Videos API closed on September 24, 2026.** The following retains interface structure only, not usable integration instructions. Any same-named SimiRouter models or third-party compatible implementations require separate source, capability, and protocol verification; they are not official direct OpenAI access.

## Endpoint overview

`POST https://api.openai.com/v1/videos` was the official request format using an OpenAI Bearer key; do not send new production requests now.

## Request parameters

| Field            | Type   | Required | Description                                                                            |
| ---------------- | ------ | -------- | -------------------------------------------------------------------------------------- |
| prompt           | string | Yes      | The video text description.                                                            |
| model            | string | No       | Former models sora-2 / sora-2-pro, now closed.                                         |
| seconds          | string | No       | Previously supported durations such as 4, 8, and 12; retained as structural reference. |
| size             | string | No       | Previously supported resolutions such as 1280x720.                                     |
| input\_reference | object | No       | Reference-image object; choose image\_url or file\_id.                                 |

## Response

Creation formerly returned a video object\: id, object, status, progress, model, created\_at, seconds, and size. status=queued / in\_progress did not mean completion.

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

**Archived examples do not establish that the endpoint still works.** The following illustrates the former HTTP structure; do not test new tasks with real keys.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/videos'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'sora-2', 'prompt': '海边日落，平稳镜头。', 'seconds': '4', 'size': '1280x720'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "sora-2",
      "prompt": "海边日落，平稳镜头。",
      "seconds": "4",
      "size": "1280x720"
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
    curl "https://api.openai.com/v1/videos" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "sora-2",
        "prompt": "海边日落，平稳镜头。",
        "seconds": "4",
        "size": "1280x720"
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
      "model": "sora-2",
      "prompt": "海边日落，平稳镜头。",
      "seconds": "4",
      "size": "1280x720"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/videos", body); check(err)
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

After closure, no successful response can be promised. The former endpoint used HTTP 401/403 for authentication/permissions, 404 for missing resources, and 429 for rate limits; generation failures also included error.code/message. Do not endlessly retry retired endpoints or save error bodies as MP4.

## Official reference

[OpenAI deprecation notice](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create).