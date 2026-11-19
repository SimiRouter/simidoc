# Gemini speech synthesis

## Endpoint overview

Gemini TTS reads specified text, unlike interactive Live API. The following examples use **Google’s official Interactions API**\: `POST https://generativelanguage.googleapis.com/v1beta/interactions` with authentication `x-goog-api-key: $GEMINI_API_KEY`. It is not OpenAI `/audio/speech`, and changing the domain and key does not make it a gateway call.

`gemini-3.8-flash-tts` and `gemini-3.8-flash-lite-tts` use this structure. Supported Gemini 3.1 / 2.5 Preview TTS models use their own generateContent configuration; do not mix the generations. Confirm Interactions support on the SimiRouter channel.

## Request parameters

| Field                             | Type           | Required    | Description                                                                    |
| --------------------------------- | -------------- | ----------- | ------------------------------------------------------------------------------ |
| model                             | string         | Yes         | For example gemini-3.8-flash-tts.                                              |
| input                             | string / array | Yes         | Text to read; style annotations use the user\_input/content structure.         |
| input\[].content\[].text          | string         | Yes         | Text to read verbatim.                                                         |
| annotations\[].type               | string         | Conditional | Style annotations use speech\_metadata.                                        |
| annotations\[].style              | string         | No          | Tone, accent, or rhythm for this turn.                                         |
| annotations\[].speaker            | string         | Conditional | For multiple speakers, match a speaker name in the configuration.              |
| response\_format                  | object         | No          | This example uses \{"type"\:"audio"}; follow the returned MIME type.           |
| generation\_config.speech\_config | array / object | Yes         | Single speaker\: \[\{"voice"\:"Kore"}]; multiple speakers\: a speakers object. |
| stream                            | boolean        | No          | true returns incremental events when supported; never save SSE text as audio.  |

For multiple speakers, use `{"speakers":[{"speaker":"Joe","voice":"Kore"},{"speaker":"Jane","voice":"Puck"}]}`. Each turn’s speech\_metadata.speaker must reference Joe or Jane; concatenating unannotated dialogue is insufficient. Voice design and cloning require a valid voice ID and usage rights.

## Response

REST returns an Interaction object. Audio appears in `steps[]`, in a `type=model_output` step’s `content[]`; audio items have `type=audio`, `data` as Base64 and `mime_type` identifies the format. The SDK’s `output_audio` is a convenience property, not a universal REST root field. Default WAV can be decoded and saved directly; do not add another WAV header.

```json
{"steps":[{"type":"model_output","content":[{"type":"audio","mime_type":"audio/wav","data":"<Base64音频>"}]}]}
```

## Code examples

Set Google’s official `GEMINI_API_KEY`. Python 3, Node.js 18+, and Go use standard libraries; curl requires Python 3 to parse results. Google is the default direct service; `GEMINI_BASE_URL` can point to a local test server or authorized native proxy, without `/v1beta`.

The example checks `status=completed`, decodes all audio items, and saves them as `speech-1.wav` without overwriting existing files. If the service returns another MIME type, handle that format instead of merely changing the extension.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import base64, json, os, urllib.request
    key = os.environ["GEMINI_API_KEY"]
    base = os.environ.get("GEMINI_BASE_URL", "https://generativelanguage.googleapis.com").rstrip("/")
    body = json.loads(r'''{
      "model": "gemini-3.8-flash-tts",
      "input": [
        {
          "type": "user_input",
          "content": [
            {
              "type": "text",
              "text": "祝你今天过得愉快。",
              "annotations": [
                {
                  "type": "speech_metadata",
                  "style": "温暖自然"
                }
              ]
            }
          ]
        }
      ],
      "response_format": {
        "type": "audio"
      },
      "generation_config": {
        "speech_config": [
          {
            "voice": "Kore"
          }
        ]
      }
    }''')
    request = urllib.request.Request(base + "/v1beta/interactions", data=json.dumps(body).encode(),
        headers={"x-goog-api-key": key, "Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(request, timeout=180) as response:
        result = json.load(response)
    if result.get("status") != "completed":
        raise RuntimeError("生成未完成: " + str(result.get("status")))
    audio = [part for step in result.get("steps", []) if step.get("type") == "model_output"
             for part in step.get("content", []) if part.get("type") == "audio"]
    if not audio: raise RuntimeError("响应没有音频")
    for i, part in enumerate(audio):
        if part.get("mime_type") not in ("audio/wav", "audio/x-wav", "audio/wave"):
            raise RuntimeError("响应不是 WAV: " + str(part.get("mime_type")))
        data = base64.b64decode(part["data"], validate=True)
        if not data: raise RuntimeError("音频为空")
        name = f"speech-{i + 1}.wav"
        with open(name, "xb") as output: output.write(data)
        print(name)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { writeFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const base = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "");
      const response = await fetch(base + "/v1beta/interactions", {
        method: "POST", headers: {"x-goog-api-key": process.env.GEMINI_API_KEY, "Content-Type": "application/json"},
        body: JSON.stringify({"model":"gemini-3.8-flash-tts","input":[{"type":"user_input","content":[{"type":"text","text":"祝你今天过得愉快。","annotations":[{"type":"speech_metadata","style":"温暖自然"}]}]}],"response_format":{"type":"audio"},"generation_config":{"speech_config":[{"voice":"Kore"}]}}), signal: AbortSignal.timeout(180000)
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.status !== "completed") throw new Error("生成未完成: " + result.status);
      const audio = (result.steps || []).filter(s => s.type === "model_output").flatMap(s => s.content || []).filter(p => p.type === "audio");
      if (!audio.length) throw new Error("响应没有音频");
      for (const [i, part] of audio.entries()) {
        if (!["audio/wav", "audio/x-wav", "audio/wave"].includes(part.mime_type)) throw new Error("响应不是 WAV");
        if (!part.data || !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(part.data)) throw new Error("无效 Base64");
        const data = Buffer.from(part.data, "base64");
        const name = `speech-${i + 1}.wav`;
        await writeFile(name, data, {flag: "wx"}); console.log(name);
      }
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "${base%/}/v1beta/interactions" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "model": "gemini-3.8-flash-tts",
        "input": [
          {
            "type": "user_input",
            "content": [
              {
                "type": "text",
                "text": "祝你今天过得愉快。",
                "annotations": [
                  {
                    "type": "speech_metadata",
                    "style": "温暖自然"
                  }
                ]
              }
            ]
          }
        ],
        "response_format": {
          "type": "audio"
        },
        "generation_config": {
          "speech_config": [
            {
              "voice": "Kore"
            }
          ]
        }
      }'
    python3 - "$response" <<'PY_AUDIO'
    import base64, json, sys
    with open(sys.argv[1]) as source: result = json.load(source)
    if result.get("status") != "completed": raise RuntimeError("生成未完成")
    audio = [part for step in result.get("steps", []) if step.get("type") == "model_output"
             for part in step.get("content", []) if part.get("type") == "audio"]
    if not audio: raise RuntimeError("响应没有音频")
    for i, part in enumerate(audio):
        if part.get("mime_type") not in ("audio/wav", "audio/x-wav", "audio/wave"): raise RuntimeError("响应不是 WAV")
        data = base64.b64decode(part["data"], validate=True)
        if not data: raise RuntimeError("音频为空")
        name = f"speech-{i + 1}.wav"
        with open(name, "xb") as output: output.write(data)
        print(name)
    PY_AUDIO
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import ("bytes"; "encoding/base64"; "encoding/json"; "fmt"; "io"; "net/http"; "os"; "time"; "strings")
    func check(err error) { if err != nil { panic(err) } }
    func main() {
     key:=os.Getenv("GEMINI_API_KEY"); if key=="" { panic("请设置 GEMINI_API_KEY") }
     base:=os.Getenv("GEMINI_BASE_URL"); if base=="" {base="https://generativelanguage.googleapis.com"}
     req,err:=http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", bytes.NewBufferString(`{"model":"gemini-3.8-flash-tts","input":[{"type":"user_input","content":[{"type":"text","text":"祝你今天过得愉快。","annotations":[{"type":"speech_metadata","style":"温暖自然"}]}]}],"response_format":{"type":"audio"},"generation_config":{"speech_config":[{"voice":"Kore"}]}}`));check(err)
     req.Header.Set("x-goog-api-key",key);req.Header.Set("Content-Type","application/json")
     res,err:=(&http.Client{Timeout:180*time.Second}).Do(req);check(err);defer res.Body.Close()
     raw,err:=io.ReadAll(res.Body);check(err);if res.StatusCode>=300 {panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw))}
     var result struct {Status string `json:"status"`; Steps []struct {Type string `json:"type"`;Content []struct {Type string `json:"type"`;Mime string `json:"mime_type"`;Data string `json:"data"`} `json:"content"`} `json:"steps"`}
     check(json.Unmarshal(raw,&result));if result.Status!="completed" {panic("生成未完成")}
     count:=0
     for _,step:=range result.Steps { if step.Type!="model_output" {continue}; for _,part:=range step.Content {if part.Type!="audio" {continue}
     if part.Mime!="audio/wav" && part.Mime!="audio/x-wav" && part.Mime!="audio/wave" {panic("响应不是 WAV")}
     data,err:=base64.StdEncoding.Strict().DecodeString(part.Data);check(err);if len(data)==0 {panic("音频为空")}
     count++;name:=fmt.Sprintf("speech-%d.wav",count);out,err:=os.OpenFile(name,os.O_WRONLY|os.O_CREATE|os.O_EXCL,0600);check(err)
     _,err=out.Write(data);closeErr:=out.Close();check(err);check(closeErr);fmt.Println(name)
     }};if count==0 {panic("响应没有音频")}
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

[Google Gemini TTS](https\://ai.google.dev/gemini-api/docs/speech-generation), [Interactions](https\://ai.google.dev/gemini-api/docs/interactions).