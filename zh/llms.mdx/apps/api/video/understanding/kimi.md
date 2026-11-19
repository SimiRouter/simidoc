# Kimi 视频理解

## 接口说明

`kimi-k3` 原生支持视频理解，可以根据已有视频生成摘要、回答画面问题或分析事件。视频理解返回文字，不生成视频，也不承诺逐帧识别或精确时间对齐。

**接口地址**：`POST https://api.moonshot.cn/v1/chat/completions`。使用中国站 Moonshot API Key，通过 `Authorization: Bearer $MOONSHOT_API_KEY` 鉴权。国际站使用 `https://api.moonshot.ai` 和国际站 Key，两站账户及 Key 不能混用。

本页示例为 **Moonshot 官方直连**。模型具备视频能力，不代表 SimiRouter 已开放相同模型、媒体输入方式或文件存储协议；不能将 `ms://` 文件 ID 直接迁移到其他厂商或网关。

* **非流式**：`stream: false`，同一 HTTP 请求等待完整 JSON 响应。
* **流式**：`stream: true`，同一连接逐步返回 SSE，输出推理和正文增量；不是异步视频生成任务。
* **文件引用**：先上传文件，再在聊天请求中使用 `ms://<file_id>`，文件上传不代替聊天请求。

## 请求参数

内容类型为 `application/json`。

| 字段                             | 类型                       | 必填 | 说明                                                                               |
| ------------------------------ | ------------------------ | -- | -------------------------------------------------------------------------------- |
| `model`                        | string                   | 是  | 本页为 `kimi-k3`，不是界面显示名或模型简称。                                                      |
| `messages`                     | array                    | 是  | 消息列表。视频请求的用户消息使用内容数组。                                                            |
| `messages[].role`              | string                   | 是  | 视频与问题放在 `user` 消息中；可另设 `system` 指令。                                              |
| `messages[].content`           | array                    | 是  | 包含 `video_url` 视频项和 `text` 问题项，不能把数组序列化成字符串。                                     |
| `content[].type`               | string                   | 是  | 视频为 `video_url`，文字为 `text`。                                                      |
| `content[].video_url.url`      | string                   | 条件 | `data:video/mp4;base64,...` 等匹配真实 MIME 的数据 URL，或 Moonshot 文件引用 `ms://<file_id>`。 |
| `content[].text`               | string                   | 条件 | 要求模型完成的分析，例如摘要、事件顺序或指定时间段问答。                                                     |
| `reasoning_effort`             | string                   | 否  | K3 始终启用思考，使用顶层 `low`、`high` 或 `max`，默认 `max`。                                    |
| `max_completion_tokens`        | integer                  | 否  | 生成 Token 上限，须为推理与最终答案留足预算；达到上限时 `finish_reason` 为 `length`。                      |
| `stream`                       | boolean                  | 否  | 默认 `false`；`true` 返回 SSE。                                                        |
| `stream_options.include_usage` | boolean                  | 否  | 配合流式请求，在结束前获取用量统计块。                                                              |
| `response_format`              | object                   | 否  | 支持的结构化输出格式；需要 JSON 时按官方 JSON Mode 或 JSON Schema 配置。                              |
| `tools` / `tool_choice`        | array / string or object | 否  | 可使用工具调用；本页视频分析示例不启用工具。                                                           |

K3 不使用 K2.x 的 `thinking` 开关。`temperature` 固定为 `1.0`、`top_p` 固定为 `0.95`、`n` 固定为 `1`，重复惩罚固定为 `0`；建议省略这些字段，其他取值会报错。`max_tokens` 是旧参数，新集成使用 `max_completion_tokens`。

### 视频输入限制

官方视觉页列出 MP4、MPEG、MOV、AVI、FLV、MPG、WebM、WMV 和 3GPP 视频类型，建议视频分辨率不高于 1080p。请求 Body 不超过官方的 100M 限制；Base64 会增大请求体，不能把原视频大小直接当成 JSON 请求大小。

本页示例采用更保守的 **20 MiB 本地视频上限**，这是示例保护值，不是模型最大视频容量或时长承诺。较大视频或反复引用的视频应采用官方文件上传流程。不要将普通网页地址、小红书分享页或本地文件路径填写为 `video_url.url`；本页使用已确认的 Base64 和 `ms://` 两种输入方式。

### 使用已上传的视频

调用 Moonshot `POST /v1/files`，以 multipart 提交 `file` 和 `purpose=video`，读取上传返回的 `id`，然后在视频项中使用 `{"type":"video_url","video_url":{"url":"ms://<file_id>"}}`。不需要再读取文件的文本抽取内容。

官方上传参考列出单文件 100 MiB 上限；使用新版本文件协议时按其 `kimi-api-version` 要求处理，不要将文件端点的版本头要求套用于 Chat Completions。上传资源应由相同平台和账户访问，使用完毕按业务保留规则删除。

## 返回值

成功的非流式响应为 HTTP 200 JSON，沿用 Chat Completions 结构。

| 字段                                    | 类型      | 说明                                                 |
| ------------------------------------- | ------- | -------------------------------------------------- |
| `id`                                  | string  | 本次补全的标识符。                                          |
| `object`                              | string  | 非流式为 `chat.completion`。                            |
| `created`                             | integer | 创建时间，Unix 秒。                                       |
| `model`                               | string  | 响应模型标识。                                            |
| `choices[].index`                     | integer | 候选位置。                                              |
| `choices[].message.role`              | string  | 助手消息为 `assistant`。                                 |
| `choices[].message.content`           | string  | 最终视频分析答案。                                          |
| `choices[].message.reasoning_content` | string  | 可能返回的推理内容；不是最终答案，不能与 `content` 混为一项。               |
| `choices[].finish_reason`             | string  | `stop` 正常结束；`length` 达到生成上限；`tool_calls` 要求业务执行工具。 |
| `usage.prompt_tokens`                 | integer | 输入用量，包含按模型计算的视频输入。                                 |
| `usage.completion_tokens`             | integer | 生成用量。                                              |
| `usage.total_tokens`                  | integer | 总用量；可另带缓存与推理明细。                                    |

下列 ID、时间和用量仅为结构示例，不是实测记录：

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

### 流式解析

SSE 的 `data:` JSON 中，`choices[].delta.reasoning_content` 为推理增量，`choices[].delta.content` 为正文增量；分别追加，不要覆盖。检查最终 `finish_reason`，并等待 `data: [DONE]`。开启用量后，统计块可能为 `choices: []`，从顶层 `usage` 读取，不能固定访问 `choices[0]`。

多轮对话应保留完整 assistant 消息，包括返回的 `reasoning_content`；下一轮继续带入所需视频和问题上下文。连接中断或收到 `length` 不能当作完整答案。

## 代码调用

先设置 `MOONSHOT_API_KEY` 和 `VIDEO_FILE`，后者为有权上传的真实本地视频。`VIDEO_MIME` 可选，默认 `video/mp4`，须匹配实际文件；示例不会把任意文件转换为 MP4。`MOONSHOT_BASE_URL` 可选，默认为 `https://api.moonshot.cn`，根地址不含 `/v1`，可用于经授权代理或本地 mock 测试。

Python 3、Node.js 18+ 和 Go 示例使用标准库；curl 示例需要 Python 3 编码请求和解析结果。四种示例均限制视频 20 MiB、设置超时、拒绝不完整结果，不自动重试计费请求。

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

## 错误码

| HTTP 状态               | 常见错误类型                                                                              | 处理方式                                         |
| --------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------- |
| 400                   | `invalid_request_error`、`content_filter`                                            | 检查内容数组、Base64/MIME、请求体大小、固定参数及上下文；按安全要求调整输入。 |
| 401                   | `invalid_authentication_error`、`incorrect_api_key_error`                            | 检查 Key 和端点所属站点，不混用中国站、国际站或 SimiRouter Key。   |
| 403                   | `permission_denied_error`                                                           | 检查模型权限、组织白名单与功能开放范围。                         |
| 404                   | `resource_not_found_error`                                                          | 核对模型 ID、文件 ID 与资源归属。                         |
| 429                   | `engine_overloaded_error`、`exceeded_current_quota_error`、`rate_limit_reached_error` | 分清容量、余额和速率限制；额度不足不能靠重复请求解决。                  |
| 499 / 500 / 503 / 504 | `client_closed_request`、`server_error` 等                                            | 保留请求 ID，检查连接与服务状态；长请求可改用 SSE。                |

错误通常包含 `error.type` 和 `error.message`，部分响应另带 `error.code`。超时不证明请求未执行，重试前先核对用量；不要在日志中记录 Key 或完整视频 Base64。

## 官方参考

* [Kimi K3：模型与视频文件示例](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart)
* [Kimi 视觉输入：视频类型与限制](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Kimi Chat Completions API：视频数据 URL、请求与返回](https\://platform.kimi.com/docs/api/chat)
* [Kimi 模型参数参考](https\://platform.kimi.com/docs/api/models-overview)
* [Kimi 流式输出](https\://platform.kimi.com/docs/guide/utilize-the-streaming-output-feature-of-kimi-api)
* [Moonshot 文件上传](https\://platform.kimi.com/docs/api/files-upload)
* [Kimi 错误码](https\://platform.kimi.com/docs/api/errors)