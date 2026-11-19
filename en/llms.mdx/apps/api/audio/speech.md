# Text to speech

## Endpoint overview

`POST /v1/audio/speech` synthesizes `input` into speech. For SimiRouter, the base URL is `https://api.dwchainless.com` with authentication `Authorization: Bearer $SIMIROUTER_API_KEY` and the body is `application/json`. This page references the official OpenAI Speech API; model availability and parameter passthrough depend on the selected channel.

<Callout type="warn" title="Models shut down on 2027-01-06">
  `gpt-4o-mini-tts`, `tts-1`, and `tts-1-hd` are deprecated by OpenAI and shut down on 2027-01-06. The official replacement is `gpt-realtime-2.1-mini` on the Realtime API, which does not support `/v1/audio/speech`; migrate through `/v1/realtime`. Examples still use a currently routable model; confirm the channel offers a replacement before calling.
</Callout>

## Request parameters

| Field            | Type            | Required | Description                                                                                   |
| ---------------- | --------------- | -------- | --------------------------------------------------------------------------------------------- |
| model            | string          | Yes      | An available TTS model, such as gpt-4o-mini-tts; transcription models are not supported here. |
| input            | string          | Yes      | Text to read, up to 4,096 characters.                                                         |
| voice            | string / object | Yes      | A built-in voice name or an authorized custom voice \{"id"\:"voice\_..."}.                    |
| instructions     | string          | No       | Tone and style instructions; not supported by tts-1/tts-1-hd. Up to 4,096 characters.         |
| response\_format | string          | No       | mp3 (default), opus, aac, flac, wav, or pcm.                                                  |
| speed            | number          | No       | 0.25–4.0; default 1.                                                                          |
| stream\_format   | string          | No       | audio (default) or sse; tts-1/tts-1-hd do not support sse.                                    |

Built-in voices include `alloy`, `ash`, `ballad`, `coral`, `echo`, `fable`, `onyx`, `nova`, `sage`, `shimmer`, `verse`, `marin`, `cedar`; a model may support only a subset. Voice names do not designate a fixed language.

## Response

A successful response contains audio bytes, not JSON with a URL. Match the saved file extension to `response_format`. PCM contains raw samples without a container and requires the correct playback settings. The default audio response can be read incrementally to reduce latency.

`stream_format: "sse"` uses an event stream. Parse events and decode audio deltas; do not save the full SSE text as MP3. SSE availability also depends on the channel implementation.

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

First set `SIMIROUTER_API_KEY`. The examples select MP3 and stop on HTTP errors to avoid writing an error JSON response as audio.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.dwchainless.com/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gpt-4o-mini-tts', 'input': '你好，欢迎使用语音合成。', 'voice': 'alloy', 'response_format': 'mp3'}, timeout=180)
    response.raise_for_status()
    Path('speech.mp3').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("speech.mp3", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "speech.mp3" ] || { printf '%s\n' "目标文件已存在：speech.mp3" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "https://api.dwchainless.com/v1/audio/speech" \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }' \
      --output "$temporary"; then
      mv "$temporary" "speech.mp3"
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
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }`)
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("speech.mp3", data, 0600))
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

The error body’s `error.message`, `error.type`, and `error.code` give more specific reasons than the HTTP status. This endpoint is synchronous\: there is no task ID or polling stage. Never save error text as an audio file.

## Official reference

[OpenAI Create speech](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create).