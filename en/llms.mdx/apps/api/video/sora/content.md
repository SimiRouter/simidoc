# Download Sora content (official API closed)

**Official OpenAI Sora 2 and Videos API closed on September 24, 2026.** The following retains interface structure only, not usable integration instructions. Any same-named SimiRouter models or third-party compatible implementations require separate source, capability, and protocol verification; they are not official direct OpenAI access.

## Endpoint overview

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content` was the official request format using an OpenAI Bearer key; do not send new production requests now.

## Request parameters

| Field            | Type   | Required | Description                                                     |
| ---------------- | ------ | -------- | --------------------------------------------------------------- |
| video\_id (path) | string | Yes      | The original creation task ID.                                  |
| variant (query)  | string | No       | Former content types such as video, thumbnail, and spritesheet. |

## Response

Former successful responses contained binary video MP4 or other content, not URL JSON; downloads required completed generation. This official content service is now closed.

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

**Archived examples do not establish that the endpoint still works.** The following illustrates the former HTTP structure; do not test new tasks with real keys.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('GET', url, headers=headers, timeout=180)
    response.raise_for_status()
    Path('video.mp4').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      const response = await fetch(url, { method: "GET", headers, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("video.mp4", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "video.mp4" ] || { printf '%s\n' "目标文件已存在：video.mp4" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X GET "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      --output "$temporary"; then
      mv "$temporary" "video.mp4"
    else
      status=$?
      cat "$temporary" >&2
      exit "$status"
    fi
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
        req, err := http.NewRequest("GET", "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content", nil); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("video.mp4", data, 0600))
    }
    ```
  </Tab>
</Tabs>

## Errors

After closure, no successful response can be promised. The former endpoint used HTTP 401/403 for authentication/permissions, 404 for missing resources, and 429 for rate limits; generation failures also included error.code/message. Do not endlessly retry retired endpoints or save error bodies as MP4.

## Official reference

[OpenAI deprecation notice](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create).