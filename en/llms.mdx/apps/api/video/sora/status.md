# Query Sora task (official API closed)

**Official OpenAI Sora 2 and Videos API closed on September 24, 2026.** The following retains interface structure only, not usable integration instructions. Any same-named SimiRouter models or third-party compatible implementations require separate source, capability, and protocol verification; they are not official direct OpenAI access.

## Endpoint overview

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID` was the official request format using an OpenAI Bearer key; do not send new production requests now.

## Request parameters

| Field            | Type   | Required | Description                    |
| ---------------- | ------ | -------- | ------------------------------ |
| video\_id (path) | string | Yes      | The original creation task ID. |

## Response

Queries formerly returned id, status, progress, model, created\_at, completed\_at, expires\_at, error, and more. Download only after completed; read error.code/message for failed.

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

**Archived examples do not establish that the endpoint still works.** The following illustrates the former HTTP structure; do not test new tasks with real keys.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('GET', url, headers=headers, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      const response = await fetch(url, { method: "GET", headers, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID" \
      --fail-with-body \
      --max-time 180 \
      -X GET \
      -H "Authorization: Bearer $OPENAI_API_KEY"
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
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        req, err := http.NewRequest("GET", "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID", nil); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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