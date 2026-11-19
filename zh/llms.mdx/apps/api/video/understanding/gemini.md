# Gemini 视频理解

## 接口说明

视频理解接收已有视频，返回文字分析，不生成新视频。下方使用 **Google 官方 Interactions**：`POST https://generativelanguage.googleapis.com/v1beta/interactions`，鉴权为 `x-goog-api-key: $GEMINI_API_KEY`。不能把它当 Seedance/Kling 创建任务，也不意味着 SimiRouter 已映射 Google 全部媒体输入能力。

## 请求参数

| 字段                  | 类型      | 必填 | 说明                                        |
| ------------------- | ------- | -- | ----------------------------------------- |
| model               | string  | 是  | 支持视频输入的模型，例如 gemini-3.8-flash。            |
| input               | array   | 是  | video 素材与 text 问题。                        |
| input\[].type       | string  | 是  | video 或 text。                             |
| input\[].data       | string  | 条件 | 短视频 Base64 内容，与 uri 二选一。                  |
| input\[].mime\_type | string  | 条件 | 如 video/mp4，应匹配真实编码。                      |
| input\[].uri        | string  | 条件 | 已上传并 ACTIVE 的 Google 文件 URI，或模型支持的公开视频地址。 |
| input\[].text       | string  | 条件 | 摘要、问答或带具体时间范围的问题。                         |
| stream / background | boolean | 否  | 长分析可采用流式或后台模式，须使用对应事件/任务处理流程。             |

本示例保守选择总请求小于 20 MB 的短 MP4。较大或重复使用的视频优先走 Google Files API；文件完成上传后还需等待 ACTIVE，FAILED 必须停止，不能无上限轮询。公开视频 URL、Cloud Storage 与直接内联是不同输入路径，不能随意互换。

## 返回值

Interactions 的 `steps[]` 中包含 model\_output，文本项为 `content[].type=text` 与 `text`。SDK 的 output\_text 是便利属性。时间点属于模型理解结果，应按原视频复核，不能自动视为精确取证或逐帧标注。

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"00:10 出现海面上的帆船，随后镜头向右移动。"}]}]}
```

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

准备短视频 `video.mp4` 并设置 Google 官方 `GEMINI_API_KEY`。示例没有调用付费生成模型，也没有发起文件管理操作，但推理请求本身仍可能计费。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")}]}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": (await readFile("video.mp4")).toString("base64")
        }
      ]
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
    set -eu
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "encoding/base64"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      media, err := os.ReadFile("video.mp4"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
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

## 错误码

| HTTP 状态               | 含义与处理                                             |
| --------------------- | ------------------------------------------------- |
| 400 / 422             | 请求字段、文件格式或模型参数不合法，修正后再提交。                         |
| 401                   | API Key 缺失、无效或已过期。                                |
| 403                   | 当前项目或模型没有权限。                                      |
| 404                   | 模型、路由或输入资源不存在，检查地址、模型 ID 与文件状态。                   |
| 413 / 415             | 上传过大或媒体类型不受支持。                                    |
| 429                   | 速率或配额限制，区分余额不足与可退避重试的限流。                          |
| 500 / 502 / 503 / 504 | 服务或上游异常，保留请求 ID；同步请求超时后先查看日志或请求状态，再决定是否重试，避免重复计费。 |

Google 错误对象使用 `error.code`、`error.status`、`error.message`；请求失败时不要把错误正文当作正常分析结果。

## 官方参考

[Google 视频理解](https\://ai.google.dev/gemini-api/docs/video-understanding)、[Files](https\://ai.google.dev/gemini-api/docs/files)。