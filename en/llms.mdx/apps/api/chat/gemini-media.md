# Gemini media understanding

## Endpoint overview

`POST /v1beta/models/{model}:generateContent` combines text and media in parts, and the model returns descriptions, transcriptions, or analysis. Media understanding does not generate or edit images.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $SIMIROUTER_API_KEY` . Direct Google access uses `https://generativelanguage.googleapis.com`, usually with `x-goog-api-key: $GEMINI_API_KEY`, not the gateway Bearer key. Select a model available to the account that supports the required capability.

The examples read and inline a local file without external asset URLs or the Files API; the scripts map common image, audio, video, and PDF extensions to MIME types. For audio, video, or PDFs, use the matching MIME type and a model supporting that input modality; changing a file extension to an image extension is not sufficient.

## Quick start

1. **Prepare configuration**\: create a key in API key management and copy a full model ID that supports the target media input from Models and pricing.
2. **Prepare the media**\: choose an authorized image, audio clip, video, or PDF and confirm its real MIME type.
3. **Send a minimal request**\: encode the file bytes as plain Base64 into `inlineData.data` and put the text question in the same `parts`; verify with a single image first.
4. **Read the result**\: the request succeeds only when HTTP is 2xx and `candidates[]` is non-empty; the analysis text is in `candidates[0].content.parts[].text`.
5. **Verify**\: check `finishReason` and the basis of the conclusion; high-risk cases require human review.

Images must be Base64-encoded first; see the "Code examples" section below for a minimal working script, and do not assemble long Base64 strings by hand.

## Request parameters

| Field                              | Type           | Required    | Description                                                                                                |
| ---------------------------------- | -------------- | ----------- | ---------------------------------------------------------------------------------------------------------- |
| model (path)                       | string         | Yes         | A model ID supporting the required media input.                                                            |
| contents\[].parts\[].text          | string         | Conditional | The question submitted with the media.                                                                     |
| contents\[].parts\[].inlineData    | object         | Conditional | Inline media containing mimeType and data; do not combine with text/fileData in the same Part.             |
| inlineData.mimeType                | string         | Yes         | The actual MIME type, such as image/png, image/jpeg, audio/mpeg, video/mp4, or application/pdf.            |
| inlineData.data                    | string         | Yes         | Pure Base64 file bytes, without a data\: prefix; not a local path.                                         |
| contents\[].parts\[].fileData      | object         | Conditional | An alternative media source containing mimeType and fileUri; use only authorized URIs the vendor can read. |
| contents\[].role                   | string         | No          | Usually user for a single turn.                                                                            |
| generationConfig.maxOutputTokens   | integer        | No          | The output token limit.                                                                                    |
| systemInstruction / safetySettings | object / array | No          | System instructions and safety settings.                                                                   |

Each Part selects one content type. Large files require an officially supported input method; do not assume the gateway implements Google’s Files upload and polling APIs. Base64 increases request size, which must satisfy gateway, vendor, and model limits.

### Request structure

BASE64\_MEDIA\_BYTES below represents encoded file bytes; the four language examples generate it from a local file.

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "描述这份素材的主要内容，并指出不确定之处。"
        },
        {
          "inlineData": {
            "mimeType": "image/png",
            "data": "BASE64_MEDIA_BYTES"
          }
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 512
  }
}
```

## Response

| Field                                 | Type           | Description                                                                                                                      |
| ------------------------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| candidates\[]                         | array          | Candidate results; may be empty when blocked.                                                                                    |
| candidates\[].index                   | integer        | The candidate index.                                                                                                             |
| candidates\[].content.role / parts\[] | string / array | Output role and content parts; text is usually in parts\[].text.                                                                 |
| candidates\[].finishReason            | string         | STOP means normal completion; MAX\_TOKENS means the limit was reached; SAFETY, RECITATION, and others require separate handling. |
| candidates\[].safetyRatings           | array          | Optional safety ratings.                                                                                                         |
| candidates\[].groundingMetadata       | object         | Source and citation information when grounding tools such as search are used.                                                    |
| promptFeedback.blockReason            | string         | The reason an input was blocked; candidates may be absent.                                                                       |
| usageMetadata.promptTokenCount        | integer        | Input tokens.                                                                                                                    |
| usageMetadata.candidatesTokenCount    | integer        | Candidate output tokens.                                                                                                         |
| usageMetadata.thoughtsTokenCount      | integer        | Optional thinking tokens, not directly displayable response text.                                                                |
| usageMetadata.totalTokenCount         | integer        | Total tokens for this request, possibly including tools or thinking.                                                             |
| modelVersion / responseId             | string         | Optional model version and response identifier.                                                                                  |

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "图片中可见一张桌子和一个杯子；杯中内容无法确定。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 280,
    "candidatesTokenCount": 30,
    "totalTokenCount": 310
  }
}
```

For streaming, use streamGenerateContent?alt=sse and merge by candidate index; not every output part is text. Model interpretations may be inaccurate. High-risk medical, identity, or document conclusions require human verification.

## Code examples

Set `SIMIROUTER_API_KEY`, `SIMIROUTER_GEMINI_MODEL`; `SIMIROUTER_BASE_URL` overrides the default gateway root; do not append `/v1`. `MEDIA_PATH` points to an existing local file. Python 3, Node.js 18+, and Go examples use only standard libraries; the curl example uses Python 3 to encode JSON safely.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    import base64
    from pathlib import Path
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }''')
    p = Path(os.environ["MEDIA_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.m4a': 'audio/mp4', '.flac': 'audio/flac', '.ogg': 'audio/ogg', '.mp4': 'video/mp4', '.mov': 'video/quicktime', '.webm': 'video/webm', '.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["contents"][0]["parts"][1]["inlineData"] = {"mimeType": mime, "data": encoded}
    path = "/v1beta/models/" + urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe="") + ":generateContent"
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const fs = require('node:fs');
      const path = require('node:path');
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_GEMINI_MODEL)
        throw new Error('请设置 SIMIROUTER_GEMINI_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '描述这份素材的主要内容，并指出不确定之处。',
              },
              {
                inlineData: {
                  mimeType: 'image/png',
                  data: 'BASE64_MEDIA_BYTES',
                },
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 512,
        },
      };
      const filename = process.env.MEDIA_PATH;
      if (!filename) throw new Error('请设置 MEDIA_PATH');
      const mime = {
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.webp': 'image/webp',
        '.mp3': 'audio/mpeg',
        '.wav': 'audio/wav',
        '.m4a': 'audio/mp4',
        '.flac': 'audio/flac',
        '.ogg': 'audio/ogg',
        '.mp4': 'video/mp4',
        '.mov': 'video/quicktime',
        '.webm': 'video/webm',
        '.pdf': 'application/pdf',
      }[path.extname(filename).toLowerCase()];
      if (!mime) throw new Error('不支持的文件扩展名');
      const data = fs.readFileSync(filename);
      if (!data.length) throw new Error('输入文件为空');
      const encoded = data.toString('base64');
      body.contents[0].parts[1].inlineData = { mimeType: mime, data: encoded };
      const endpoint = `/v1beta/models/${encodeURIComponent(process.env.SIMIROUTER_GEMINI_MODEL)}:generateContent`;
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000),
      });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_GEMINI_MODEL:?请设置 SIMIROUTER_GEMINI_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    import base64
    from pathlib import Path
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }''')
    p = Path(os.environ["MEDIA_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.m4a': 'audio/mp4', '.flac': 'audio/flac', '.ogg': 'audio/ogg', '.mp4': 'video/mp4', '.mov': 'video/quicktime', '.webm': 'video/webm', '.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["contents"][0]["parts"][1]["inlineData"] = {"mimeType": mime, "data": encoded}
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    MODEL_PATH=$(python3 -c 'import os, urllib.parse; print(urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe=""))')
    curl "${BASE_URL%/}/v1beta/models/${MODEL_PATH}:generateContent" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "bytes"
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
      "encoding/base64"
      "path/filepath"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_GEMINI_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_GEMINI_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }`), &body); err != nil { log.Fatal(err) }
      filename := os.Getenv("MEDIA_PATH"); if filename == "" { log.Fatal("请设置 MEDIA_PATH") }
      mime := map[string]string{".png":"image/png",".jpg":"image/jpeg",".jpeg":"image/jpeg",".webp":"image/webp",".mp3":"audio/mpeg",".wav":"audio/wav",".m4a":"audio/mp4",".flac":"audio/flac",".ogg":"audio/ogg",".mp4":"video/mp4",".mov":"video/quicktime",".webm":"video/webm",".pdf":"application/pdf"}[strings.ToLower(filepath.Ext(filename))]
      if mime == "" { log.Fatal("不支持的文件扩展名") }
      data, err := os.ReadFile(filename); if err != nil { log.Fatal(err) }; if len(data) == 0 { log.Fatal("输入文件为空") }
      encoded := base64.StdEncoding.EncodeToString(data)
      body["contents"].([]any)[0].(map[string]any)["parts"].([]any)[1].(map[string]any)["inlineData"] = map[string]any{"mimeType": mime, "data": encoded}
      endpoint := "/v1beta/models/" + model + ":generateContent"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Errors

| HTTP status | Meaning or vendor error type          | Action                                                                          |
| ----------- | ------------------------------------- | ------------------------------------------------------------------------------- |
| 400         | `INVALID_ARGUMENT` and similar errors | Check JSON, model parameters, media MIME type, and input length.                |
| 403         | `PERMISSION_DENIED`                   | Check the key, project permissions, region, or billing restrictions.            |
| 404         | `NOT_FOUND`                           | Check the model name and API version.                                           |
| 429         | `RESOURCE_EXHAUSTED`                  | Check rate limits and quotas; use bounded backoff when retrying is appropriate. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`            | Record the request identifier and retry a limited number of times or later.     |

Google’s native error object contains `error.code` (HTTP number), `error.status` (enum name), and `error.message`, optionally with `details`. The gateway may return authentication, routing, or quota errors before contacting the vendor; an HTTP status alone does not establish that an error came from upstream.

Long replies and streaming requests can take from tens of seconds to several minutes; set a sufficient client timeout, and when the stream breaks, judge from the deltas received and the termination reason instead of resending automatically. For 429 and 5xx, inspect the response body and usage logs first; when content policy rejects a request, change the prompt or input rather than retrying unchanged.

## Official reference

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google image understanding](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Google audio understanding](https\://ai.google.dev/gemini-api/docs/audio)
* [Google video understanding](https\://ai.google.dev/gemini-api/docs/video-understanding)
* [Google PDF understanding](https\://ai.google.dev/gemini-api/docs/document-processing)
* [Google troubleshooting](https\://ai.google.dev/gemini-api/docs/troubleshooting)