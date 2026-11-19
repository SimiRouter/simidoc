# Gemini 音频理解

## 接口说明

Gemini 音频理解把录音作为多模态输入，返回文字，可用于转录、摘要、说话人描述和时间段分析。它不是 TTS，也不是专用 `/audio/transcriptions`。本页采用 Google 官方 `POST /v1beta/interactions`，鉴权为 `x-goog-api-key: $GEMINI_API_KEY`，不是 SimiRouter 原生代理可用性保证。

## 请求参数

| 字段                  | 类型      | 必填 | 说明                                        |
| ------------------- | ------- | -- | ----------------------------------------- |
| model               | string  | 是  | 支持音频输入的模型，例如 gemini-3.8-flash。            |
| input               | array   | 是  | text 指令与 audio 输入组成的内容数组。                 |
| input\[].type       | string  | 是  | 文本使用 text，音频使用 audio。                     |
| input\[].data       | string  | 条件 | 内联音频 Base64，不含 data URL 前缀。               |
| input\[].uri        | string  | 条件 | Google Files API 返回的文件 URI；与内联 data 选择一种。 |
| input\[].mime\_type | string  | 条件 | 例如 audio/wav、audio/mpeg，须与真实内容一致。         |
| stream              | boolean | 否  | 可流式接收文本输出，不等于持续上传麦克风。                     |

较大录音优先使用 Google Files API 上传后引用 URI。内联文件必须满足模型与请求体大小限制。不要把本地路径当作云端可读取的 URI，也不要假设模型给出的时间戳具备专业强制对齐精度。

## 返回值

文本位于 `steps[].content[]` 的 text 项，SDK 可用 `output_text`。长录音的完整转录需检查终态和截断情况。示例响应节选：

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"录音主要介绍了会议议程。"}]}]}
```

## 代码调用

Python 3 使用标准库；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

准备当前目录中的短录音 `speech.wav` 并设置 `GEMINI_API_KEY`。示例读取真实文件、编码 Base64 后提交，输出完整 JSON。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import json, urllib.request

    url = os.environ.get('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com').rstrip('/') + '/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")}]}
    headers['Content-Type'] = 'application/json'
    request = urllib.request.Request(url, data=json.dumps(body).encode(), headers=headers, method='POST')
    with urllib.request.urlopen(request, timeout=180) as response:
        print(response.read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const url = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "") + "/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": (await readFile("speech.wav")).toString("base64")
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
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "${base%/}/v1beta/interactions" \
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
      if os.Getenv("GEMINI_API_KEY")=="" { panic("请设置 GEMINI_API_KEY") }
      base:=os.Getenv("GEMINI_BASE_URL"); if base=="" { base="https://generativelanguage.googleapis.com" }
      media, err := os.ReadFile("speech.wav"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", body); check(err)
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

| HTTP 状态               | 含义与处理                                     |
| --------------------- | ----------------------------------------- |
| 400                   | 请求字段或模型参数不合法，修正后再提交。                      |
| 401                   | API Key 缺失、无效或已过期。                        |
| 403                   | 当前项目或模型没有权限。                              |
| 404                   | 模型或路由不存在，检查地址与模型 ID。                      |
| 429                   | 速率或配额限制，区分余额不足与可退避重试的限流。                  |
| 500 / 502 / 503 / 504 | 服务或上游异常，保留请求 ID；对暂时故障做有限次退避，不要无限重试同一付费请求。 |

Google 错误对象使用 `error.code`、`error.status`、`error.message`，不要只按 HTTP 数字判断来源。本接口是同步请求，没有任务 ID 或轮询阶段。失败时不要把错误正文当作转录或摘要结果。

## 官方参考

[Google 音频理解](https\://ai.google.dev/gemini-api/docs/audio)、[Google Files](https\://ai.google.dev/gemini-api/docs/files)。