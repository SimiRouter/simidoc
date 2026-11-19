# Kimi video understanding

## Endpoint overview

`kimi-k3` natively supports video understanding for summaries, visual questions, and event analysis. It returns text, not video, and does not guarantee frame-by-frame recognition or precise temporal alignment.

**Endpoint address**\: `POST https://api.moonshot.cn/v1/chat/completions`. Use a China-site Moonshot API key with `Authorization: Bearer $MOONSHOT_API_KEY` authentication. The international site uses `https://api.moonshot.ai` and an international key; accounts and keys cannot be mixed across the two sites.

Examples on this page use **Official direct Moonshot access**. A model’s video capability does not establish equivalent SimiRouter model, media input, or file-storage support. Do not transfer `ms://` file IDs directly to other vendors or gateways.

* **Non-streaming**\: `stream: false`; one HTTP request waits for complete JSON.
* **Streaming**\: `stream: true`; the same connection streams reasoning and answer deltas over SSE, not an asynchronous video-generation task.
* **File references**\: upload first, then use `ms://<file_id>` in the chat request; uploading does not replace the chat request.

## Request parameters

The content type is `application/json`.

| Field                          | Type                     | Required    | Description                                                                                                                  |
| ------------------------------ | ------------------------ | ----------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `model`                        | string                   | Yes         | This page uses `kimi-k3`, not a display name or abbreviated model label.                                                     |
| `messages`                     | array                    | Yes         | Message list. User messages containing video require content arrays.                                                         |
| `messages[].role`              | string                   | Yes         | Place videos and questions in a `user` message; optional `system` instructions.                                              |
| `messages[].content`           | array                    | Yes         | Contains a `video_url` video item and a `text` question item; do not serialize the array as a string.                        |
| `content[].type`               | string                   | Yes         | For video use `video_url`; for text use `text`.                                                                              |
| `content[].video_url.url`      | string                   | Conditional | `data:video/mp4;base64,...` or other data URLs matching the actual MIME type, or a Moonshot file reference `ms://<file_id>`. |
| `content[].text`               | string                   | Conditional | The requested analysis, such as summaries, event order, or questions about specified time ranges.                            |
| `reasoning_effort`             | string                   | No          | K3 always enables thinking and uses top-level `low`, `high` or `max`, default `max`.                                         |
| `max_completion_tokens`        | integer                  | No          | The generation token limit; budget for reasoning and the final answer. When reached, `finish_reason` is `length`.            |
| `stream`                       | boolean                  | No          | Default `false`; `true` returns SSE.                                                                                         |
| `stream_options.include_usage` | boolean                  | No          | With streaming, retrieve a usage chunk before completion.                                                                    |
| `response_format`              | object                   | No          | Supported structured-output format; configure official JSON Mode or JSON Schema when JSON is required.                       |
| `tools` / `tool_choice`        | array / string or object | No          | Tool calling is available; the video-analysis example on this page does not enable it.                                       |

K3 does not use K2.x’s `thinking` switch. `temperature` is always `1.0`, `top_p` is always `0.95`, `n` is always `1`, with repetition penalties fixed at `0`; omit these fields, as other values cause errors. `max_tokens` is a legacy parameter; new integrations use `max_completion_tokens`.

### Video input limits

The official vision page lists MP4, MPEG, MOV, AVI, FLV, MPG, WebM, WMV, and 3GPP and recommends resolution no higher than 1080p. The request body must satisfy the official 100M limit. Base64 enlarges payloads; original video size is not JSON request size.

Examples use a more conservative **20 MiB local-video limit**, an example safeguard, not a maximum-capacity or duration guarantee. Use the official upload workflow for larger or repeatedly referenced videos. Do not put ordinary webpages, Xiaohongshu share pages, or local paths in `video_url.url`; this page uses the verified Base64 and `ms://` input methods.

### Using uploaded videos

Call Moonshot `POST /v1/files` with multipart `file` and `purpose=video`, read the upload response’s `id`, then use `{"type":"video_url","video_url":{"url":"ms://<file_id>"}}` in the video item. There is no need to retrieve extracted file text.

The official upload reference lists a 100 MiB per-file limit. New file-protocol versions must follow their `kimi-api-version` requirements; do not apply file-endpoint version headers to Chat Completions. Access resources through the same platform and account, then delete according to retention rules.

## Response

A successful non-streaming response is HTTP 200 JSON using Chat Completions structure.

| Field                                 | Type    | Description                                                                                                                        |
| ------------------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `id`                                  | string  | The completion identifier.                                                                                                         |
| `object`                              | string  | For non-streaming responses, `chat.completion`.                                                                                    |
| `created`                             | integer | Creation time in Unix seconds.                                                                                                     |
| `model`                               | string  | The response model identifier.                                                                                                     |
| `choices[].index`                     | integer | The candidate index.                                                                                                               |
| `choices[].message.role`              | string  | The assistant message is `assistant`.                                                                                              |
| `choices[].message.content`           | string  | The final video-analysis answer.                                                                                                   |
| `choices[].message.reasoning_content` | string  | Optional reasoning content; not the final answer and must not be merged with `content`.                                            |
| `choices[].finish_reason`             | string  | `stop` means normal completion; `length` means the generation limit was reached; `tool_calls` requests application tool execution. |
| `usage.prompt_tokens`                 | integer | Input usage, including model-accounted video input.                                                                                |
| `usage.completion_tokens`             | integer | Generated usage.                                                                                                                   |
| `usage.total_tokens`                  | integer | Total usage, optionally with caching and reasoning breakdowns.                                                                     |

The following IDs, times, and usage illustrate structure only, not measured calls\:

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1793500000,
  "model": "kimi-k3",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "视频先展示产品外观，随后演示操作步骤，最后对比使用前后的结果。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 1200,
    "completion_tokens": 300,
    "total_tokens": 1500
  }
}
```

### Parsing streams

In SSE `data:` JSON, `choices[].delta.reasoning_content` contains reasoning deltas and `choices[].delta.content` contains answer-text deltas. Append them separately rather than overwrite. Check the final `finish_reason` and wait for `data: [DONE]`. With usage enabled, the statistics chunk may have `choices: []`; read from top-level `usage` rather than hard-code `choices[0]`.

For multi-turn conversations, preserve the complete assistant message, including returned `reasoning_content`, and include required video and question context on the next turn. A disconnect or `length` is not a complete answer.

## Code examples

First set `MOONSHOT_API_KEY` and `VIDEO_FILE`; the latter is an actual local video you are authorized to upload. `VIDEO_MIME` is optional, default `video/mp4`, matching the actual file; examples do not convert arbitrary files to MP4. `MOONSHOT_BASE_URL` is optional, default `https://api.moonshot.cn`; the root URL excludes `/v1`, for authorized proxies or local mock tests.

Python 3, Node.js 18+, and Go examples use standard libraries; curl requires Python 3 for request encoding and response parsing. All four enforce the 20 MiB video limit, set timeouts, reject incomplete results, and do not automatically retry billable requests.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import base64
    import json
    import os
    import urllib.error
    import urllib.request
    from pathlib import Path

    key = os.environ.get("MOONSHOT_API_KEY")
    filename = os.environ.get("VIDEO_FILE")
    if not key or not filename:
        raise SystemExit("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE")
    path = Path(filename)
    if not path.is_file() or not 0 < path.stat().st_size <= 20 * 1024 * 1024:
        raise SystemExit("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
    mime = os.environ.get("VIDEO_MIME", "video/mp4")
    allowed = {"video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
               "video/mpg", "video/webm", "video/wmv", "video/3gpp"}
    if mime not in allowed:
        raise SystemExit("VIDEO_MIME 不在本页列出的格式范围内")
    video = base64.b64encode(path.read_bytes()).decode("ascii")
    body = {
        "model": "kimi-k3",
        "messages": [{"role": "user", "content": [
            {"type": "video_url", "video_url": {"url": f"data:{mime};base64,{video}"}},
            {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"},
        ]}],
        "reasoning_effort": "low",
        "max_completion_tokens": 4096,
        "stream": False,
    }
    base = os.environ.get("MOONSHOT_BASE_URL", "https://api.moonshot.cn").rstrip("/")
    request = urllib.request.Request(
        base + "/v1/chat/completions", data=json.dumps(body).encode("utf-8"),
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=300) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop":
        raise RuntimeError("视频分析未正常完成，请检查 finish_reason 与错误信息")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip():
        raise RuntimeError("响应没有最终文字答案")
    print(answer)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile, stat } = require("node:fs/promises");

    async function main() {
      const key = process.env.MOONSHOT_API_KEY;
      const filename = process.env.VIDEO_FILE;
      if (!key || !filename) throw new Error("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE");
      const info = await stat(filename);
      if (!info.isFile() || info.size <= 0 || info.size > 20 * 1024 * 1024)
        throw new Error("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件");
      const mime = process.env.VIDEO_MIME || "video/mp4";
      const allowed = ["video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
        "video/mpg", "video/webm", "video/wmv", "video/3gpp"];
      if (!allowed.includes(mime)) throw new Error("不支持的 VIDEO_MIME");
      const video = (await readFile(filename)).toString("base64");
      const body = {
        model: "kimi-k3",
        messages: [{ role: "user", content: [
          { type: "video_url", video_url: { url: `data:${mime};base64,${video}` } },
          { type: "text", text: "概括视频内容，并按顺序列出关键事件。" },
        ] }],
        reasoning_effort: "low", max_completion_tokens: 4096, stream: false,
      };
      const base = (process.env.MOONSHOT_BASE_URL || "https://api.moonshot.cn").replace(/\/+$/, "");
      const response = await fetch(base + "/v1/chat/completions", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body: JSON.stringify(body), signal: AbortSignal.timeout(300000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      const choice = result.choices?.[0];
      if (choice?.finish_reason !== "stop") throw new Error("视频分析未正常完成");
      const answer = choice.message?.content;
      if (typeof answer !== "string" || !answer.trim()) throw new Error("响应没有最终文字答案");
      console.log(answer);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${MOONSHOT_API_KEY:?请设置 MOONSHOT_API_KEY}"
    : "${VIDEO_FILE:?请设置 VIDEO_FILE}"
    base="${MOONSHOT_BASE_URL:-https://api.moonshot.cn}"
    request=$(mktemp)
    response=$(mktemp)
    trap 'rm -f "$request" "$response"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json, os
    from pathlib import Path
    path = Path(os.environ["VIDEO_FILE"])
    if not path.is_file() or not 0 < path.stat().st_size <= 20 * 1024 * 1024:
        raise SystemExit("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
    mime = os.environ.get("VIDEO_MIME", "video/mp4")
    allowed = {"video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
               "video/mpg", "video/webm", "video/wmv", "video/3gpp"}
    if mime not in allowed: raise SystemExit("不支持的 VIDEO_MIME")
    video = base64.b64encode(path.read_bytes()).decode("ascii")
    print(json.dumps({
        "model": "kimi-k3",
        "messages": [{"role": "user", "content": [
            {"type": "video_url", "video_url": {"url": f"data:{mime};base64,{video}"}},
            {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"},
        ]}],
        "reasoning_effort": "low", "max_completion_tokens": 4096, "stream": False,
    }, ensure_ascii=False))
    PY_BODY
    if curl --fail-with-body --connect-timeout 15 --max-time 300 \
      "${base%/}/v1/chat/completions" \
      -H "Authorization: Bearer $MOONSHOT_API_KEY" \
      -H "Content-Type: application/json" --data-binary "@$request" --output "$response"; then
      python3 - "$response" <<'PY_RESULT'
    import json, sys
    with open(sys.argv[1], encoding="utf-8") as source: result = json.load(source)
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop":
        raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    PY_RESULT
    else
      status=$?
      cat "$response" >&2
      exit "$status"
    fi
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
        "bytes"
        "encoding/base64"
        "encoding/json"
        "fmt"
        "io"
        "net/http"
        "os"
        "strings"
        "time"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        key, filename := os.Getenv("MOONSHOT_API_KEY"), os.Getenv("VIDEO_FILE")
        if key == "" || filename == "" { panic("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE") }
        info, err := os.Stat(filename); check(err)
        if !info.Mode().IsRegular() || info.Size() <= 0 || info.Size() > 20*1024*1024 {
            panic("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
        }
        mime := os.Getenv("VIDEO_MIME"); if mime == "" { mime = "video/mp4" }
        allowed := map[string]bool{"video/mp4":true, "video/mpeg":true, "video/mov":true,
            "video/avi":true, "video/x-flv":true, "video/mpg":true, "video/webm":true,
            "video/wmv":true, "video/3gpp":true}
        if !allowed[mime] { panic("不支持的 VIDEO_MIME") }
        video, err := os.ReadFile(filename); check(err)
        body := map[string]any{
            "model":"kimi-k3",
            "messages":[]any{map[string]any{"role":"user", "content":[]any{
                map[string]any{"type":"video_url", "video_url":map[string]string{
                    "url":"data:"+mime+";base64,"+base64.StdEncoding.EncodeToString(video)}},
                map[string]string{"type":"text", "text":"概括视频内容，并按顺序列出关键事件。"},
            }}},
            "reasoning_effort":"low", "max_completion_tokens":4096, "stream":false,
        }
        payload, err := json.Marshal(body); check(err)
        base := os.Getenv("MOONSHOT_BASE_URL"); if base == "" { base = "https://api.moonshot.cn" }
        req, err := http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1/chat/completions", bytes.NewReader(payload)); check(err)
        req.Header.Set("Authorization","Bearer "+key); req.Header.Set("Content-Type","application/json")
        res, err := (&http.Client{Timeout:300*time.Second}).Do(req); check(err); defer res.Body.Close()
        raw, err := io.ReadAll(res.Body); check(err)
        if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw)) }
        var result struct { Choices []struct {
            Finish string `json:"finish_reason"`
            Message struct { Content string `json:"content"` } `json:"message"`
        } `json:"choices"` }
        check(json.Unmarshal(raw,&result))
        if len(result.Choices)==0 || result.Choices[0].Finish!="stop" { panic("视频分析未正常完成") }
        answer := result.Choices[0].Message.Content
        if strings.TrimSpace(answer)=="" { panic("响应没有最终文字答案") }
        fmt.Println(answer)
    }
    ```
  </Tab>
</Tabs>

## Errors

| HTTP status           | Common error types                                                                    | Action                                                                                                                 |
| --------------------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| 400                   | `invalid_request_error`, `content_filter`                                             | Check content arrays, Base64/MIME, body size, fixed parameters, and context; adjust input to meet safety requirements. |
| 401                   | `invalid_authentication_error`, `incorrect_api_key_error`                             | Check that the key matches the endpoint’s site; do not mix China, international, or SimiRouter keys.                   |
| 403                   | `permission_denied_error`                                                             | Check model permissions, organization allowlists, and feature availability.                                            |
| 404                   | `resource_not_found_error`                                                            | Verify model IDs, file IDs, and resource ownership.                                                                    |
| 429                   | `engine_overloaded_error`, `exceeded_current_quota_error`, `rate_limit_reached_error` | Distinguish capacity, balance, and rate limits; repeated requests cannot fix insufficient quota.                       |
| 499 / 500 / 503 / 504 | `client_closed_request`, `server_error` and similar errors                            | Retain the request ID and inspect connection/service status; use SSE for long requests where appropriate.              |

Errors usually contain `error.type` and `error.message`; some responses also include `error.code`. A timeout does not prove non-execution. Check usage before retrying, and never log keys or complete video Base64.

## Official reference

* [Kimi K3\: models and video-file examples](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart)
* [Kimi vision input\: video formats and limits](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Kimi Chat Completions API\: video data URLs, requests, and responses](https\://platform.kimi.com/docs/api/chat)
* [Kimi model parameters](https\://platform.kimi.com/docs/api/models-overview)
* [Kimi streaming output](https\://platform.kimi.com/docs/guide/utilize-the-streaming-output-feature-of-kimi-api)
* [Moonshot file uploads](https\://platform.kimi.com/docs/api/files-upload)
* [Kimi error codes](https\://platform.kimi.com/docs/api/errors)