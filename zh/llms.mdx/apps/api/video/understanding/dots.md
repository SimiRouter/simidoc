# Dots 视频理解

## 接口说明

`dots3-note-prev` 支持视频输入，可将视频、图片与问题放入同一消息内容数组，生成文字分析。官方视频协议为 `POST https://note3-prev-api.askdiandian.com/v1/chat/completions`，请求头使用 `api-key: $DOTS_API_KEY`，不是 Bearer 鉴权。

本页示例直连 **Dots 官方服务**。它不是 Gemini 的 `input/steps` 协议，也不是生成视频的异步任务。通过 SimiRouter 使用时须确认模型与渠道是否透传此视频扩展，不能只替换域名和密钥。

* `stream: false`：等待完整 JSON，最终答案位于 `choices[].message.content`。
* `stream: true`：按 SSE 接收文字增量；视频处理可能使首 Token 等待时间增加，应给客户端保留足够超时。
* 视频必须是模型服务可读取的文件 URL。官方视频示例未给出 Base64、`ms://`、采样帧率、最大时长或固定文件容量参数，本页不将这些方式视为已支持。

## 请求参数

请求体为 `application/json`。

| 字段                                     | 类型                       | 必填    | 说明                                                   |
| -------------------------------------- | ------------------------ | ----- | ---------------------------------------------------- |
| `model`                                | string                   | 是     | 官方示例模型为 `dots3-note-prev`。                           |
| `messages`                             | array                    | 是     | 按顺序提交消息历史。                                           |
| `messages[].role`                      | string                   | 是     | 视频和问题置于 `user`；可另设 `system` 指令。                      |
| `messages[].content`                   | array                    | 是     | 视频请求使用内容数组，不要序列化成一个字符串。                              |
| `content[].type`                       | string                   | 是     | `video_url` 为视频，`text` 为问题；可同时加入 `image_url` 图片。     |
| `content[].video_url.url`              | string                   | 视频项必填 | 模型服务可访问的视频文件地址，非本地路径或网站分享页。                          |
| `content[].text`                       | string                   | 文字项必填 | 需要执行的分析任务。                                           |
| `stream`                               | boolean                  | 否     | 本页示例为 `false`，`true` 时改用 SSE 解析。                     |
| `max_tokens`                           | integer                  | 否     | 最大输出 Token，本例 4096。输入与该上限之和不能超过模型 524,288 Token 上下文。 |
| `chat_template_kwargs.enable_thinking` | boolean                  | 否     | 默认 `true`；`false` 关闭深度思考，本例显式开启。                     |
| `stop`                                 | string\[]                | 否     | 停止序列数组，匹配时结束生成。                                      |
| `tools` / `tool_choice`                | array / string or object | 否     | 函数定义和工具选择；本例仅分析视频，不调用工具。                             |

公网视频链接会交给 Dots 下载。使用有权公开给模型服务读取的地址；签名 URL 应保留足够有效期，不要包含账户登录凭据。小红书分享页地址不等于视频文件直链。

## 返回值

HTTP 200 返回 Chat Completions JSON。下面为结构示例，内容、ID 与用量不代表实测记录。

| 字段                                               | 类型               | 说明                                               |
| ------------------------------------------------ | ---------------- | ------------------------------------------------ |
| `id` / `object`                                  | string           | 请求标识；非流式 `object` 为 `chat.completion`。           |
| `created` / `model`                              | integer / string | Unix 秒级时间与响应模型。                                  |
| `choices[].index`                                | integer          | 候选序号。                                            |
| `choices[].message.role`                         | string           | 助手消息为 `assistant`。                               |
| `choices[].message.content`                      | string           | 最终文字答案。                                          |
| `choices[].message.reasoning_content`            | string，可选        | 开启思考时可能返回的推理内容；与最终答案分开处理。                        |
| `choices[].finish_reason`                        | string           | `stop` 正常结束；`length` 表示截断；`tool_calls` 需要应用执行工具。 |
| `usage.prompt_tokens`                            | integer          | 输入 Token，视频按服务的多模态规则计算。                          |
| `usage.completion_tokens` / `usage.total_tokens` | integer          | 生成与总用量。                                          |
| `system_fingerprint`                             | string，可选        | 服务端返回的系统标识，可为空字符串。                               |

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

流式响应使用 Chat Completions 增量结构，正文读取 `choices[].delta.content`，思考字段单独累积。客户端应处理 SSE 事件分隔、终态和流结束，不能把一次网络读取当作一个完整事件；连接中断或 `length` 不视为完整答案。

## 代码调用

设置 `DOTS_API_KEY` 与 `VIDEO_URL`。`VIDEO_URL` 必须是模型服务能直接读取的 HTTP(S) 视频文件地址，四种示例均不会先在本机下载该视频。`DOTS_BASE_URL` 可选，默认 `https://note3-prev-api.askdiandian.com`，根地址不含 `/v1`；仅在使用经授权原生协议代理或本地测试时修改。

Python 3、Node.js 18+ 和 Go 使用标准库；curl 示例依赖 Python 3 安全构造 JSON 并检查返回结果。请求最多等待 300 秒，不自动重试。示例仅在 `finish_reason=stop` 且答案非空时输出正文。

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

## 错误码

| HTTP 状态 | 官方含义          | 处理                          |
| ------- | ------------- | --------------------------- |
| 400     | 参数或 JSON 格式错误 | 检查多模态数组、视频链接、模型名和上下文长度      |
| 401     | API Key 缺失或无效 | 核对 Dots Key 与 `api-key` 请求头 |
| 403     | Key 无权访问资源    | 核对平台权限                      |
| 429     | 请求过于频繁        | 降低并发，有限次数退避                 |
| 500     | 服务内部错误        | 保留脱敏错误正文与响应标识，避免无上限重试       |

HTTP 200 不代表结果一定完整；应继续检查 `finish_reason` 与文字答案。视频地址失效、无法下载或解析失败时，按实际错误正文排查，不把它误判为鉴权失败。客户端超时不保证服务未执行，重新提交前注意重复消耗。

## 官方参考

[Dots API：视频输入](https\://dots.ai/platform/docs#video-input)、[请求参数](https\://dots.ai/platform/docs#request-parameters)、[鉴权](https\://dots.ai/platform/docs#authentication)和[响应状态](https\://dots.ai/platform/docs#error-codes)。