# Gemini video understanding

## Endpoint overview

Video understanding takes existing videos and returns textual analysis, not new videos. The following uses **Google’s official Interactions API**\: `POST https://generativelanguage.googleapis.com/v1beta/interactions` with authentication `x-goog-api-key: $GEMINI_API_KEY`. It is not Seedance/Kling task creation and does not imply SimiRouter maps every Google media-input capability.

## Request parameters

| Field               | Type    | Required    | Description                                                                                    |
| ------------------- | ------- | ----------- | ---------------------------------------------------------------------------------------------- |
| model               | string  | Yes         | A video-input model, such as gemini-3.8-flash.                                                 |
| input               | array   | Yes         | video assets and text questions.                                                               |
| input\[].type       | string  | Yes         | video or text.                                                                                 |
| input\[].data       | string  | Conditional | Base64 content for short videos; choose this or uri.                                           |
| input\[].mime\_type | string  | Conditional | For example, video/mp4, matching the actual encoding.                                          |
| input\[].uri        | string  | Conditional | An uploaded Google file URI in ACTIVE state, or a public video URL supported by the model.     |
| input\[].text       | string  | Conditional | A summary, question, or query about a specific time range.                                     |
| stream / background | boolean | No          | Long analyses can use streaming or background mode with the corresponding event/task workflow. |

This example conservatively uses a short MP4 with total request size below 20 MB. Prefer Google Files API for larger or reused videos. Wait for ACTIVE after upload; stop for FAILED and bound polling. Public URLs, Cloud Storage, and inline data are distinct input paths and not freely interchangeable.

## Response

Interactions `steps[]` contains model\_output, with text items at `content[].type=text` and their content in `text`. SDK output\_text is a convenience property. Timestamps are model interpretations\: verify against the original video rather than treat them as precise forensic evidence or frame annotations.

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"00:10 出现海面上的帆船，随后镜头向右移动。"}]}]}
```

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

Prepare a short video `video.mp4` and set Google’s official `GEMINI_API_KEY`. Examples do not call paid generation models or file-management operations, but inference itself may still incur charges.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")}]}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": (await readFile("video.mp4")).toString("base64")
        }
      ]
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
    set -eu
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "encoding/base64"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      media, err := os.ReadFile("video.mp4"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
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

| HTTP status           | Meaning and action                                                                                                                                     |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 400 / 422             | Invalid fields, file format, or model parameters; correct before resubmitting.                                                                         |
| 401                   | Missing, invalid, or expired API key.                                                                                                                  |
| 403                   | No access to the project or model.                                                                                                                     |
| 404                   | Model, route, or input resource not found; check the address, model ID, and file state.                                                                |
| 413 / 415             | Upload too large or unsupported media type.                                                                                                            |
| 429                   | Rate or quota limit; distinguish insufficient funds from retryable throttling.                                                                         |
| 500 / 502 / 503 / 504 | Service or upstream failure. Keep the request ID; after a synchronous timeout, check logs or request state before retrying to avoid duplicate charges. |

Google errors use `error.code`, `error.status`, `error.message`; do not treat the error body as a normal analysis result.

## Official reference

[Google video understanding](https\://ai.google.dev/gemini-api/docs/video-understanding), [Files](https\://ai.google.dev/gemini-api/docs/files).