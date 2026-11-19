# Audio transcription

## Endpoint overview

`POST /v1/audio/transcriptions` with authentication `Authorization: Bearer $SIMIROUTER_API_KEY`. Upload with `multipart/form-data` and let the HTTP library generate the boundary; do not manually set Content-Type without a boundary.

This endpoint preserves the original language and does not automatically translate Chinese into English. Supported file formats include flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, and webm. File size and recording duration are also subject to model and channel limits.

<Callout type="warn" title="Some models shut down on 2027-02-26">
  `whisper-1`, `gpt-4o-transcribe`, and `gpt-4o-mini-transcribe` (including dated snapshots) are deprecated and shut down on 2027-02-26. Prefer `gpt-transcribe`; use `gpt-live-transcribe` for live audio or `gpt-4o-transcribe-diarize` when you need speaker labels.
</Callout>

## Request parameters

| Field                         | Type            | Required    | Description                                                                                                |
| ----------------------------- | --------------- | ----------- | ---------------------------------------------------------------------------------------------------------- |
| file                          | file            | Yes         | The audio file itself, not a path string or ordinary URL.                                                  |
| model                         | string          | Yes         | For example, gpt-transcribe, gpt-4o-transcribe, gpt-4o-mini-transcribe, whisper-1, or a diarization model. |
| language                      | string          | No          | The input language’s ISO-639-1 code, such as zh or en.                                                     |
| languages\[]                  | string\[]       | No          | Candidate languages; use only with models that support this field.                                         |
| prompt                        | string          | No          | Terminology and contextual hints in the recording’s language; not supported by diarization models.         |
| keywords\[]                   | string\[]       | No          | Terminology hints; gpt-transcribe only.                                                                    |
| response\_format              | string          | No          | Default json; support for text, srt, vtt, verbose\_json, and diarized\_json varies by model.               |
| temperature                   | number          | No          | 0–1; default 0.                                                                                            |
| stream                        | boolean         | No          | true returns SSE; whisper-1 does not support it.                                                           |
| include\[]                    | string\[]       | No          | logprobs requires a supported model and response\_format=json.                                             |
| timestamp\_granularities\[]   | string\[]       | No          | word / segment; requires verbose\_json and a supported model; not applicable to diarization.               |
| chunking\_strategy            | string / object | Conditional | auto or a server\_vad configuration; required for diarization input over 30 seconds.                       |
| known\_speaker\_names\[]      | string\[]       | No          | Short names for up to four known speakers, paired with audio references.                                   |
| known\_speaker\_references\[] | string\[]       | No          | Audio data URLs lasting 2–10 seconds, paired one-to-one with names, for models that support this feature.  |

`gpt-4o-transcribe` and `gpt-4o-mini-transcribe` use JSON output; `whisper-1` supports formats such as text, srt, vtt, and verbose\_json. For speaker labels, use a diarization-capable model and `diarized_json`; do not impose this parameter on ordinary models.

## Response

| Field                    | Description                                                                           |
| ------------------------ | ------------------------------------------------------------------------------------- |
| `text`                   | The complete transcription.                                                           |
| `usage`                  | Model-provided usage statistics; fields vary by model.                                |
| `logprobs`               | Token confidence information when requested and supported.                            |
| `language` / `duration`  | Language and audio duration in seconds for verbose\_json.                             |
| `words[]` / `segments[]` | Segments when timestamps or speaker output is supported; not present in every format. |

```json
{"text":"欢迎参加今天的会议。"}
```

`stream=true` returns transcription deltas and completion events over SSE on supported models. The recipient must keep reading the stream. The complete file is still uploaded first; this is not bidirectional microphone Realtime.

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

Prepare `speech.wav` and apply `SIMIROUTER_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'gpt-4o-mini-transcribe', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "gpt-4o-mini-transcribe");
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
    curl "https://api.dwchainless.com/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=gpt-4o-mini-transcribe" \
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
      check(writer.WriteField("model", "gpt-4o-mini-transcribe"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/transcriptions", &buffer); check(err)
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

[OpenAI Create transcription](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create).