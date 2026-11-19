# MiMo audio integration

## Endpoint overview

MiMo supports speech synthesis, transcription, voice design, and reference-voice cloning. Distinguish these interfaces\:

| Protocol                             | Address / endpoint                                                     | Authentication                                           | Output                               |
| ------------------------------------ | ---------------------------------------------------------------------- | -------------------------------------------------------- | ------------------------------------ |
| Independent compatible audio service | Deployment address plus `/v1/audio/speech`, `/v1/audio/transcriptions` | The service’s own Bearer key; x-api-key is also accepted | Audio bytes or transcription results |
| Xiaomi native API                    | `https://api.xiaomimimo.com/v1/chat/completions`                       | Official MiMo api-key or Bearer key                      | Chat Completions JSON / SSE          |

**The compatibility route is not Xiaomi’s native endpoint.** Compatible examples default to the independent service at `http://127.0.0.1:8080`. Replace host and port for other deployments. Confirm equivalent SimiRouter routing separately; its key is not interchangeable with the service key.

## Request parameters

### Speech synthesis\: POST /v1/audio/speech

| Field            | Type            | Required | Description                                                                                                  |
| ---------------- | --------------- | -------- | ------------------------------------------------------------------------------------------------------------ |
| model            | string          | Yes      | mimo-v2.5-tts, mimo-v2.5-tts-voicedesign, mimo-v2.5-tts-voiceclone.                                          |
| input            | string          | Yes      | Nonempty text; default maximum 4096 characters, configurable by deployment.                                  |
| voice            | string / object | Yes      | Preset voice; for cloning, an audio data URL or service-created \{"id"\:"voice\_..."}.                       |
| instructions     | string          | No       | Tone/style instructions, up to 4096 characters.                                                              |
| style            | string          | No       | Compatibility extension taking precedence over instructions; voicedesign uses it to describe the voice.      |
| speed            | number          | No       | 0.25–4, default 1; converted to a style prompt, not guaranteed sample-accurate speed control.                |
| response\_format | string          | No       | wav, mp3, opus, aac, flac, pcm. Direct MiMo defaults to wav; specify explicitly.                             |
| stream\_format   | string          | No       | The service accepts audio only; sse returns 400. It does not expose a low-latency upstream synthesis stream. |

Preset mapping\: alloy→Bingtang, echo→Moli, fable→Baihua, onyx→Suda, nova→Mia, shimmer→Chloe, dean→Dean, milo→Milo. These service mappings are not OpenAI’s same-named voices.

### Transcription\: POST /v1/audio/transcriptions

| Field                       | Type      | Required | Description                                                                                            |
| --------------------------- | --------- | -------- | ------------------------------------------------------------------------------------------------------ |
| file                        | file      | Yes      | Multipart file; default maximum 25 MiB, configurable by deployment.                                    |
| model                       | string    | Yes      | mimo-v2.5-asr.                                                                                         |
| language                    | string    | No       | auto (default), zh, en.                                                                                |
| languages\[]                | string\[] | No       | Candidate languages, mutually exclusive with language; multiple candidates become automatic detection. |
| response\_format            | string    | No       | json (default), text, verbose\_json, srt, vtt. diarized\_json is unsupported.                          |
| stream                      | boolean   | No       | SSE is emitted after transcription completes, not while the upstream listens.                          |
| timestamp\_granularities\[] | string\[] | No       | Unsupported; a nonempty value returns 400. Word or segment timestamps are not fabricated.              |

The service accepts mp3, wav, aac, flac, m4a, mp4, mpeg, mpga, oga, ogg, opus, and webm; non-native formats need media conversion. Xiaomi native ASR accepts only MP3/WAV; do not interchange these limits.

## Response

* Successful TTS returns audio bytes with the appropriate MIME type after synthesis completes; no public task\_id is provided.
* ASR JSON is `{"text":"识别文字"}`; text returns plain text directly.
* verbose\_json contains task, language, duration, text, and empty segments, but **does not provide real segment timestamps**. SRT/VTT covers the whole recording, not word alignment.
* stream=true wraps the final transcript in SSE; it does not prove realtime upstream recognition.

## Code examples

Python examples require `python3 -m pip install requests`; Node.js uses version 18+ with built-in fetch; Go uses standard libraries.

### Text to speech

Set the independent service’s `MIMO_AUDIO_API_KEY`. Output is `mimo-speech.wav`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'http://127.0.0.1:8080/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'mimo-v2.5-tts', 'input': '你好，欢迎使用 MiMo 语音。', 'voice': 'alloy', 'response_format': 'wav'}, timeout=180)
    response.raise_for_status()
    Path('mimo-speech.wav').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("mimo-speech.wav", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "mimo-speech.wav" ] || { printf '%s\n' "目标文件已存在：mimo-speech.wav" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "http://127.0.0.1:8080/v1/audio/speech" \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }' \
      --output "$temporary"; then
      mv "$temporary" "mimo-speech.wav"
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
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }`)
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("mimo-speech.wav", data, 0600))
    }
    ```
  </Tab>
</Tabs>

### Speech to text

Prepare `speech.wav`. Authentication still uses the independent service key.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'http://127.0.0.1:8080/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'mimo-v2.5-asr', 'language': 'auto', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "mimo-v2.5-asr");
      form.append("language", "auto");
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
    curl "http://127.0.0.1:8080/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=mimo-v2.5-asr" \
      -F "language=auto" \
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
      check(writer.WriteField("model", "mimo-v2.5-asr"))
      check(writer.WriteField("language", "auto"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/transcriptions", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
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

### Voice design and cloning

For voice design, change model to `mimo-v2.5-tts-voicedesign` and add `style: "温暖低沉的成年男声，普通话清晰"`. For cloning, change model to `mimo-v2.5-tts-voiceclone` and set voice to `data:audio/wav;base64,<真实参考音频>`. Never send empty Base64, disguise a file extension, or clone another person without authorization.

```python
import base64
import os
from pathlib import Path
import requests
reference = base64.b64encode(Path("reference.wav").read_bytes()).decode("ascii")
response = requests.post("http://127.0.0.1:8080/v1/audio/speech",
    headers={"Authorization": "Bearer " + os.environ["MIMO_AUDIO_API_KEY"]},
    json={"model":"mimo-v2.5-tts-voiceclone","input":"这是一条授权声音示例。",
          "voice":"data:audio/wav;base64," + reference,"response_format":"wav"}, timeout=180)
response.raise_for_status()
Path("clone.wav").write_bytes(response.content)
```

### Xiaomi native protocol

Official TTS puts spoken text in an `assistant` message and style instructions in a `user` message. This is official JSON, not a request for `/audio/speech`\:

```json
{"model":"mimo-v2.5-tts","messages":[{"role":"user","content":"温暖自然"},{"role":"assistant","content":"你好，欢迎使用 MiMo。"}],"audio":{"format":"wav","voice":"mimo_default"},"stream":false}
```

Official returned audio is in `choices[0].message.audio.data` and needs Base64 decoding. Native ASR places audio in `messages[0].content`\:

```json
{"model":"mimo-v2.5-asr","messages":[{"role":"user","content":[{"type":"input_audio","input_audio":{"data":"data:audio/wav;base64,<真实Base64>"}}]}],"asr_options":{"language":"auto"},"stream":false}
```

Native ASR text is in `choices[0].message.content`. format is optional for a typed data URL; bare Base64 requires `format: "wav"` or `"mp3"`. If both are supplied, they must agree.

## Errors

| HTTP / code                       | Meaning                                               |
| --------------------------------- | ----------------------------------------------------- |
| 400 / unsupported\_audio\_format  | Invalid TTS output format.                            |
| 400 / speech\_sse\_not\_supported | The compatibility service does not support TTS SSE.   |
| 400 / diarization\_not\_supported | ASR does not support speaker diarization output.      |
| 400 / timestamps\_not\_supported  | ASR does not support timestamp granularity.           |
| 401 / 403                         | Invalid independent service key or permissions.       |
| 404 / voice\_not\_found           | Custom voice missing or not owned by the current key. |
| 413 / input\_too\_large           | Text or media exceeds limits.                         |
| 415 / unsupported\_file\_type     | Unsupported extension or MIME type.                   |
| 422 / invalid\_audio              | Media cannot be decoded.                              |
| 502 / invalid\_audio\_output      | Upstream returned no valid audio.                     |
| 503 / audio\_failover\_exhausted  | Audio service temporarily unavailable.                |

Uploading a cloned voice changes service state. Do not blindly repeat after a timeout.

## Official reference

[MiMo TTS](https\://mimo.mi.com/docs/en-US/api/audio/tts), [MiMo ASR](https\://mimo.mi.com/docs/en-US/api/audio/Speech-Recognition). These official pages describe native protocols, not compatibility extensions as vendor capabilities.