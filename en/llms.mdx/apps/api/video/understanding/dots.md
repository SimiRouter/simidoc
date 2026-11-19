# Dots video understanding

## Endpoint overview

`dots3-note-prev` supports video input, combining videos, images, and questions in one message-content array for textual analysis. The official video protocol uses `POST https://note3-prev-api.askdiandian.com/v1/chat/completions`, with the request header `api-key: $DOTS_API_KEY`, not Bearer authentication.

Examples connect directly to **the official Dots service**. This is neither Gemini’s `input/steps` protocol nor an asynchronous video-generation task. For SimiRouter, verify model and channel passthrough of this video extension; replacing the domain and key alone is insufficient.

* `stream: false`\: waits for complete JSON; the final answer is in `choices[].message.content`.
* `stream: true`\: receives text deltas over SSE. Video processing may increase time to first token; allow sufficient client timeout.
* Videos must be file URLs readable by the model service. Official video examples do not specify Base64, `ms://`, frame-sampling rates, maximum duration, or fixed file-size parameters; this page does not claim those methods are supported.

## Request parameters

The request body is `application/json`.

| Field                                  | Type                     | Required                 | Description                                                                                                 |
| -------------------------------------- | ------------------------ | ------------------------ | ----------------------------------------------------------------------------------------------------------- |
| `model`                                | string                   | Yes                      | The official example model is `dots3-note-prev`.                                                            |
| `messages`                             | array                    | Yes                      | Submit message history in order.                                                                            |
| `messages[].role`                      | string                   | Yes                      | Place the video and question in `user`; optional `system` instructions.                                     |
| `messages[].content`                   | array                    | Yes                      | Video requests require a content array, not a serialized string.                                            |
| `content[].type`                       | string                   | Yes                      | `video_url` for the video and `text` for the question; optionally include `image_url` images.               |
| `content[].video_url.url`              | string                   | Required for video items | A video-file URL accessible to the model service, not a local path or website share page.                   |
| `content[].text`                       | string                   | Required for text items  | The analysis task to perform.                                                                               |
| `stream`                               | boolean                  | No                       | Examples on this page use `false`; for `true`, switch to SSE parsing                                        |
| `max_tokens`                           | integer                  | No                       | Maximum output tokens; 4,096 here. Input plus this limit must not exceed the model’s 524,288-token context. |
| `chat_template_kwargs.enable_thinking` | boolean                  | No                       | Default `true`; `false` disables deep thinking; this example explicitly enables it.                         |
| `stop`                                 | string\[]                | No                       | An array of stop sequences; matching ends generation.                                                       |
| `tools` / `tool_choice`                | array / string or object | No                       | Function definitions and tool selection; this example analyzes video without tools.                         |

Public video links are downloaded by Dots. Use URLs you are authorized to disclose to the model service; signed URLs need sufficient validity and must not contain account-login credentials. A Xiaohongshu share page is not a direct video-file link.

## Response

HTTP 200 returns Chat Completions JSON. The following illustrates structure; content, IDs, and usage are not measured test records.

| Field                                            | Type             | Description                                                                                                  |
| ------------------------------------------------ | ---------------- | ------------------------------------------------------------------------------------------------------------ |
| `id` / `object`                                  | string           | Request identifier; non-streaming `object` is `chat.completion`.                                             |
| `created` / `model`                              | integer / string | Unix-second time and responding model.                                                                       |
| `choices[].index`                                | integer          | Candidate index.                                                                                             |
| `choices[].message.role`                         | string           | The assistant message is `assistant`.                                                                        |
| `choices[].message.content`                      | string           | The final textual answer.                                                                                    |
| `choices[].message.reasoning_content`            | string, optional | Reasoning content that may appear when thinking is enabled; handle separately from the final answer.         |
| `choices[].finish_reason`                        | string           | `stop` means normal completion; `length` means truncation; `tool_calls` requires application tool execution. |
| `usage.prompt_tokens`                            | integer          | Input tokens; video follows the service’s multimodal accounting rules.                                       |
| `usage.completion_tokens` / `usage.total_tokens` | integer          | Generated and total usage.                                                                                   |
| `system_fingerprint`                             | string, optional | Server-provided system identifier; may be an empty string.                                                   |

```json
{
  "id": "dots_video_example",
  "object": "chat.completion",
  "created": 1793500000,
  "model": "dots3-note-prev",
  "choices": [{
    "index": 0,
    "message": {"role": "assistant", "content": "视频先展示室外场景，随后人物走入画面。"},
    "finish_reason": "stop"
  }],
  "usage": {"prompt_tokens": 1200, "completion_tokens": 100, "total_tokens": 1300}
}
```

Streaming uses Chat Completions deltas; read response text from `choices[].delta.content` and accumulate thinking separately. Handle SSE event boundaries, terminal status, and stream completion. One network read is not necessarily a complete event; a disconnect or `length` is not a complete answer.

## Code examples

Set `DOTS_API_KEY` and `VIDEO_URL`. `VIDEO_URL` must be an HTTP(S) video-file URL directly readable by the model service. None of the four examples downloads it locally first. `DOTS_BASE_URL` is optional, default `https://note3-prev-api.askdiandian.com`; the root URL excludes `/v1`. Change only for authorized native-protocol proxies or local testing.

Python 3, Node.js 18+, and Go use standard libraries; curl requires Python 3 to construct JSON safely and validate results. Requests wait up to 300 seconds without automatic retries. Examples output text only when `finish_reason=stop` and the answer is nonempty.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, urllib.error, urllib.parse, urllib.request
    key, video = os.environ.get("DOTS_API_KEY"), os.environ.get("VIDEO_URL")
    if not key or not video: raise SystemExit("请设置 DOTS_API_KEY 和 VIDEO_URL")
    url = urllib.parse.urlsplit(video)
    if url.scheme not in ("http", "https") or not url.hostname or url.username is not None or url.password is not None:
        raise SystemExit("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")
    body = {"model": "dots3-note-prev", "messages": [{"role": "user", "content": [
        {"type": "video_url", "video_url": {"url": video}},
        {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"}
    ]}], "stream": False, "max_tokens": 4096, "chat_template_kwargs": {"enable_thinking": True}}
    base = os.environ.get("DOTS_BASE_URL", "https://note3-prev-api.askdiandian.com").rstrip("/")
    request = urllib.request.Request(base + "/v1/chat/completions", data=json.dumps(body).encode(),
        headers={"api-key": key, "Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=300) as response: result = json.load(response)
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop": raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const key = process.env.DOTS_API_KEY, video = process.env.VIDEO_URL;
      if (!key || !video) throw new Error("请设置 DOTS_API_KEY 和 VIDEO_URL");
      const url = new URL(video);
      if (!["http:", "https:"].includes(url.protocol) || !url.hostname || url.username || url.password)
        throw new Error("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址");
      const body = {model:"dots3-note-prev",messages:[{role:"user",content:[
        {type:"video_url",video_url:{url:video}},
        {type:"text",text:"概括视频内容，并按顺序列出关键事件。"}
      ]}],stream:false,max_tokens:4096,chat_template_kwargs:{enable_thinking:true}};
      const base = (process.env.DOTS_BASE_URL || "https://note3-prev-api.askdiandian.com").replace(/\/$/, "");
      const response = await fetch(base + "/v1/chat/completions", {method:"POST",
        headers:{"api-key":key,"Content-Type":"application/json"},body:JSON.stringify(body),signal:AbortSignal.timeout(300000)});
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json(), choice = result.choices?.[0];
      if (choice?.finish_reason !== "stop") throw new Error("视频分析未正常完成");
      const answer = choice.message?.content;
      if (typeof answer !== "string" || !answer.trim()) throw new Error("响应没有最终文字答案");
      console.log(answer);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${DOTS_API_KEY:?请设置 DOTS_API_KEY}"
    : "${VIDEO_URL:?请设置 VIDEO_URL}"
    request=$(mktemp)
    response=$(mktemp)
    trap 'rm -f "$request" "$response"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import json, os, urllib.parse
    video = os.environ["VIDEO_URL"]
    url = urllib.parse.urlsplit(video)
    if url.scheme not in ("http", "https") or not url.hostname or url.username is not None or url.password is not None:
        raise SystemExit("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")
    print(json.dumps({"model":"dots3-note-prev","messages":[{"role":"user","content":[
        {"type":"video_url","video_url":{"url":video}},
        {"type":"text","text":"概括视频内容，并按顺序列出关键事件。"}
    ]}],"stream":False,"max_tokens":4096,"chat_template_kwargs":{"enable_thinking":True}}))
    PY_BODY
    base="${DOTS_BASE_URL:-https://note3-prev-api.askdiandian.com}"
    curl "${base%/}/v1/chat/completions" \
      --fail-with-body \
      --connect-timeout 20 \
      --max-time 300 \
      -H "api-key: $DOTS_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request" \
      --output "$response"
    python3 - "$response" <<'PY_ANSWER'
    import json, sys
    with open(sys.argv[1]) as source: result = json.load(source)
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop": raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    PY_ANSWER
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import ("bytes"; "encoding/json"; "fmt"; "io"; "net/http"; "net/url"; "os"; "strings"; "time")
    func check(err error) { if err != nil { panic(err) } }
    func main() {
     key,video:=os.Getenv("DOTS_API_KEY"),os.Getenv("VIDEO_URL")
     if key=="" || video=="" {panic("请设置 DOTS_API_KEY 和 VIDEO_URL")}
     parsed,err:=url.Parse(video);check(err)
     if (parsed.Scheme!="http" && parsed.Scheme!="https") || parsed.Hostname()=="" || parsed.User!=nil {panic("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")}
     body:=map[string]any{"model":"dots3-note-prev","messages":[]any{map[string]any{"role":"user","content":[]any{
     map[string]any{"type":"video_url","video_url":map[string]string{"url":video}},
     map[string]string{"type":"text","text":"概括视频内容，并按顺序列出关键事件。"},
     }}},"stream":false,"max_tokens":4096,"chat_template_kwargs":map[string]bool{"enable_thinking":true}}
     data,err:=json.Marshal(body);check(err)
     base:=os.Getenv("DOTS_BASE_URL");if base=="" {base="https://note3-prev-api.askdiandian.com"}
     req,err:=http.NewRequest("POST",strings.TrimRight(base,"/")+"/v1/chat/completions",bytes.NewReader(data));check(err)
     req.Header.Set("api-key",key);req.Header.Set("Content-Type","application/json")
     res,err:=(&http.Client{Timeout:300*time.Second}).Do(req);check(err);defer res.Body.Close()
     raw,err:=io.ReadAll(res.Body);check(err)
     if res.StatusCode<200 || res.StatusCode>=300 {panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw))}
     var result struct {Choices []struct {Finish string `json:"finish_reason"`;Message struct {Content string `json:"content"`} `json:"message"`} `json:"choices"`}
     check(json.Unmarshal(raw,&result))
     if len(result.Choices)==0 || result.Choices[0].Finish!="stop" {panic("视频分析未正常完成")}
     answer:=result.Choices[0].Message.Content;if strings.TrimSpace(answer)=="" {panic("响应没有最终文字答案")};fmt.Println(answer)
    }
    ```
  </Tab>
</Tabs>

## Errors

| HTTP status | Official meaning                    | Action                                                                          |
| ----------- | ----------------------------------- | ------------------------------------------------------------------------------- |
| 400         | Invalid parameters or JSON          | Check the multimodal array, video link, model name, and context length          |
| 401         | Missing or invalid API key          | Check the Dots key and `api-key` header                                         |
| 403         | The key cannot access this resource | Check platform permissions                                                      |
| 429         | Too many requests                   | Reduce concurrency and use bounded backoff                                      |
| 500         | Internal service error              | Retain sanitized error bodies and response identifiers; avoid unlimited retries |

HTTP 200 does not guarantee completeness; still inspect `finish_reason` and the textual answer. For expired URLs, download failures, or parsing errors, diagnose the actual error body rather than assume authentication failure. A client timeout does not guarantee the service did not execute; beware duplicate usage before resubmitting.

## Official reference

[Dots API\: video input](https\://dots.ai/platform/docs#video-input), [Request parameters](https\://dots.ai/platform/docs#request-parameters), [Authentication](https\://dots.ai/platform/docs#authentication) and [Response statuses](https\://dots.ai/platform/docs#error-codes).