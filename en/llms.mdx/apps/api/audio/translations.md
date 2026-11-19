# Audio translation

## Endpoint overview

`POST /v1/audio/translations` accepts a recording and outputs **English**; it does not accept an arbitrary target-language parameter. Authentication uses `Authorization: Bearer $SIMIROUTER_API_KEY` and the body is `multipart/form-data`. This page references the official OpenAI Audio Translations API; the account needs a channel for the corresponding model.

<Callout type="warn" title="Endpoint and model shut down on 2027-02-26">
  OpenAI has deprecated `/v1/audio/translations` and `whisper-1`, which shut down on 2027-02-26. The replacement is the Realtime API at `/v1/realtime/translations` with `gpt-realtime-translate`, which requires a separate integration. This page is retained only as pre-migration reference.
</Callout>

## Request parameters

| Field            | Type   | Required | Description                                                                    |
| ---------------- | ------ | -------- | ------------------------------------------------------------------------------ |
| file             | file   | Yes      | The recording file itself; flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm. |
| model            | string | Yes      | This endpoint uses whisper-1, not an ordinary transcription model.             |
| prompt           | string | No       | English terminology or contextual hints.                                       |
| response\_format | string | No       | json (default), text, srt, verbose\_json, or vtt.                              |
| temperature      | number | No       | 0–1; default 0.                                                                |

## Response

JSON returns `text` containing the English translation. `verbose_json` also includes `duration` (seconds), `language` (english), and `segments[]`. Subtitle formats return subtitle text directly and must not be parsed as JSON. This endpoint processes a single file and has no stream parameter; realtime translation uses a separate session interface.

```json
{"text":"Welcome to today's meeting."}
```

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

Prepare `speech.wav` and set `SIMIROUTER_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/translations'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'whisper-1', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/translations";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "whisper-1");
      form.append("response_format", "json");
      const body = form;
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.dwchainless.com/v1/audio/translations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=whisper-1" \
      -F "response_format=json"
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
      "bytes"
      "mime/multipart"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      var buffer bytes.Buffer
      writer := multipart.NewWriter(&buffer)
      source, err := os.Open("speech.wav"); check(err)
      part, err := writer.CreateFormFile("file", "speech.wav"); check(err)
      _, err = io.Copy(part, source); source.Close(); check(err)
      check(writer.WriteField("model", "whisper-1"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/translations", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", writer.FormDataContentType())
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
| 413                   | File exceeds the upload limit; compress it or send a smaller file.                                                                   |
| 429                   | Rate or quota limit; distinguish insufficient funds from retryable throttling.                                                       |
| 500 / 502 / 503 / 504 | Service or upstream failure. Keep the request ID and back off for temporary faults; do not retry the same paid request indefinitely. |

The error body’s `error.message`, `error.type`, and `error.code` give more specific reasons than the HTTP status. This endpoint is synchronous\: there is no task ID or polling stage. Never save error text as a transcript.

## Official reference

[OpenAI Create translation](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create).