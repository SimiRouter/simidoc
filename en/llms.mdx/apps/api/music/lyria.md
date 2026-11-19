# Google Lyria music generation

The pages below follow the official Google API. SimiRouter has not yet opened this capability, so all examples connect directly to the Google AI Studio Gemini API using `https://generativelanguage.googleapis.com` and a Google API key. Vertex AI requires a separate protocol that is not verified on this page; do not substitute its address directly.

## Endpoint overview

`POST https://generativelanguage.googleapis.com/v1beta/interactions` with authentication `x-goog-api-key: $GEMINI_API_KEY`. Lyria uses Interactions, not generateContent or `/audio/speech`.

| Model                  | Purpose                                  | Duration and output                                                                 |
| ---------------------- | ---------------------------------------- | ----------------------------------------------------------------------------------- |
| `lyria-3-clip-preview` | Clips, loops, and quick previews         | Fixed 30 seconds; MP3 by default.                                                   |
| `lyria-3.5`            | Songs with verses, choruses, and bridges | Prompt-controlled songs lasting several minutes; MP3 by default, with optional WAV. |

## Request parameters

| Field                      | Type           | Required    | Description                                                               |
| -------------------------- | -------------- | ----------- | ------------------------------------------------------------------------- |
| model                      | string         | Yes         | One of the Lyria models above.                                            |
| input                      | string / array | Yes         | A music description or a text/image multimodal content array.             |
| input\[].text              | string         | Conditional | Style, tempo, mood, instruments, lyrics, and structure.                   |
| input\[].mime\_type / data | string         | Conditional | Image input uses an image item with its actual MIME type and Base64 data. |
| response\_format           | object         | No          | \{"type"\:"audio"} can request WAV; inspect the actual MIME type.         |

Do not treat duration control as an exact guarantee. Describing style and instrumentation is safer than requesting imitation of a particular singer.

## Response

| Field                                    | Description                                                                 |
| ---------------------------------------- | --------------------------------------------------------------------------- |
| `id` / `status`                          | Interaction identifier and processing status.                               |
| `steps[].content[]`                      | model\_output contains audio, lyrics, and song structure; parse every item. |
| Audio item `type` / `mime_type` / `data` | type=audio; data is Base64, not a URL.                                      |
| Text item `text`                         | Lyrics, structure, or other text content.                                   |

The SDK’s `output_audio` / `output_text` are convenience properties. For complex interleaved results, iterate through steps rather than reading only the final part and omitting content. Response excerpt\:

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"[Instrumental]"},{"type":"audio","mime_type":"audio/mpeg","data":"<Base64音频>"}]}]}
```

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

Set `GEMINI_API_KEY`. The example receives JSON and decodes audio-item data to an MP3 file. Change model to `lyria-3.5` to generate complete songs.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY'], 'Api-Revision': '2026-05-20'}
    response = requests.request('POST', url, headers=headers, json={'model': 'lyria-3-clip-preview', 'input': '30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY, "Api-Revision": "2026-05-20" };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "lyria-3-clip-preview",
      "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
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
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Api-Revision: 2026-05-20" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "lyria-3-clip-preview",
        "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
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
      "model": "lyria-3-clip-preview",
      "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Api-Revision", "2026-05-20")
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

Google error objects use `error.code`, `error.status`, and `error.message`; never infer the source from the HTTP number alone. This endpoint is synchronous\: there is no task ID or polling stage. Never decode error text as audio data.

## Official reference

[Google Lyria music generation](https\://ai.google.dev/gemini-api/docs/music-generation), [Interactions](https\://ai.google.dev/gemini-api/docs/interactions).