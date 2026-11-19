# Gemini audio understanding

## Endpoint overview

Gemini accepts recordings as multimodal input and returns text for transcription, summaries, speaker descriptions, and time-range analysis. It is neither TTS nor the dedicated `/audio/transcriptions`. This page uses Google’s official `POST /v1beta/interactions` with authentication `x-goog-api-key: $GEMINI_API_KEY`; it does not guarantee SimiRouter native proxy availability.

## Request parameters

| Field               | Type    | Required    | Description                                                            |
| ------------------- | ------- | ----------- | ---------------------------------------------------------------------- |
| model               | string  | Yes         | An audio-input model, such as gemini-3.8-flash.                        |
| input               | array   | Yes         | An array combining text instructions and audio input.                  |
| input\[].type       | string  | Yes         | Use text for instructions and audio for recordings.                    |
| input\[].data       | string  | Conditional | Inline Base64 audio without a data URL prefix.                         |
| input\[].uri        | string  | Conditional | A file URI returned by Google Files API; choose this or inline data.   |
| input\[].mime\_type | string  | Conditional | For example audio/wav or audio/mpeg; it must match the actual content. |
| stream              | boolean | No          | Text output may stream; this is not continuous microphone upload.      |

For large recordings, upload with Google Files API and reference the URI. Inline files must fit model and request limits. A local path is not a cloud-readable URI, and model timestamps are not professional forced alignment.

## Response

Text appears in `steps[].content[]` text items; SDKs expose `output_text`. Check completion and truncation for full transcripts of long recordings. Response excerpt\:

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"录音主要介绍了会议议程。"}]}]}
```

## Code examples

Python 3 and Go use standard libraries. Node.js requires version 18+ with built-in fetch.

Prepare a short recording in the current directory named `speech.wav` and apply `GEMINI_API_KEY`. The examples read the file, encode Base64, submit it, and print the complete JSON.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import json, urllib.request

    url = os.environ.get('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com').rstrip('/') + '/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")}]}
    headers['Content-Type'] = 'application/json'
    request = urllib.request.Request(url, data=json.dumps(body).encode(), headers=headers, method='POST')
    with urllib.request.urlopen(request, timeout=180) as response:
        print(response.read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const url = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "") + "/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": (await readFile("speech.wav")).toString("base64")
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
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "${base%/}/v1beta/interactions" \
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
      if os.Getenv("GEMINI_API_KEY")=="" { panic("请设置 GEMINI_API_KEY") }
      base:=os.Getenv("GEMINI_BASE_URL"); if base=="" { base="https://generativelanguage.googleapis.com" }
      media, err := os.ReadFile("speech.wav"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", body); check(err)
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

| HTTP status           | Meaning and action                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| 400                   | Invalid request fields or model parameters; correct the request before resubmitting.                                                 |
| 401                   | Missing, invalid, or expired API key.                                                                                                |
| 403                   | No access to the project or model.                                                                                                   |
| 404                   | Model or route not found; check the address and model ID.                                                                            |
| 429                   | Rate or quota limit; distinguish insufficient funds from retryable throttling.                                                       |
| 500 / 502 / 503 / 504 | Service or upstream failure. Keep the request ID and back off for temporary faults; do not retry the same paid request indefinitely. |

Google error objects use `error.code`, `error.status`, and `error.message`; never infer the source from the HTTP number alone. This endpoint is synchronous\: there is no task ID or polling stage. Never treat error text as a transcript or summary.

## Official reference

[Google audio understanding](https\://ai.google.dev/gemini-api/docs/audio), [Google Files](https\://ai.google.dev/gemini-api/docs/files).