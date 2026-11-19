# Gemini 媒体理解

## 接口说明

`POST /v1beta/models/{model}:generateContent` 在 parts 中组合文本和媒体数据，模型返回描述、转写或分析结果。媒体理解不负责生成或修改图片。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。Google 官方直连为 `https://generativelanguage.googleapis.com`，通常使用 `x-goog-api-key: $GEMINI_API_KEY`，不是网关的 Bearer Key。 模型名称应选用账户可访问且支持目标能力的模型。

示例读取本地文件并内联发送，不依赖外部素材地址或 Files API；示例脚本按扩展名识别常用图片、音频、视频和 PDF 的 MIME 类型。音频、视频、PDF 应分别使用匹配的 MIME 类型与支持该输入模态的模型；不要仅把扩展名改成图片后发送。

## 快速开始

1. **准备配置**：在 API 密钥管理 创建密钥，从模型与价格复制支持目标媒体输入的完整模型 ID。
2. **准备素材**：选择已授权的图片、音频、视频或 PDF，确认真实 MIME 类型。
3. **发送最小请求**：把文件字节编码为纯 Base64 填入 `inlineData.data`，文本问题放在同一 `parts` 中；先用单张图片验证。
4. **读取结果**：HTTP 2xx 且 `candidates[]` 非空才算成功，分析文字位于 `candidates[0].content.parts[].text`。
5. **验收**：检查 `finishReason` 和结论依据，高风险场景须人工复核。

图片需要先编码为 Base64，最小可用脚本见下方「代码调用」一节；不要手工拼接超长 Base64。

## 请求参数

| 字段                                 | 类型             | 必填 | 说明                                                                     |
| ---------------------------------- | -------------- | -- | ---------------------------------------------------------------------- |
| model（路径）                          | string         | 是  | 支持目标媒体输入的模型 ID。                                                        |
| contents\[].parts\[].text          | string         | 条件 | 与媒体一同提交的问题。                                                            |
| contents\[].parts\[].inlineData    | object         | 条件 | 内联媒体，包含 mimeType 与 data；不能与同一 Part 的 text/fileData 混用。                 |
| inlineData.mimeType                | string         | 是  | 真实 MIME，如 image/png、image/jpeg、audio/mpeg、video/mp4 或 application/pdf。 |
| inlineData.data                    | string         | 是  | 文件字节的纯 Base64，不含 data\: 前缀，也不是本地路径。                                    |
| contents\[].parts\[].fileData      | object         | 条件 | 另一种媒体来源，包含 mimeType、fileUri；仅用已授权且厂商可读取的 URI。                          |
| contents\[].role                   | string         | 否  | 单轮通常为 user。                                                            |
| generationConfig.maxOutputTokens   | integer        | 否  | 输出 Token 上限。                                                           |
| systemInstruction / safetySettings | object / array | 否  | 系统指令与安全设置。                                                             |

单个 Part 只选择一种内容类型。大文件应使用官方支持的文件输入方法，不能假定网关提供 Google 的 Files 上传与轮询接口。Base64 会扩大请求体；限制需同时满足网关、厂商与模型要求。

### 请求结构

下面的 BASE64\_MEDIA\_BYTES 表示编码后的文件字节；四语言代码会从本地文件生成该字段。

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

## 返回值

| 字段                                    | 类型             | 说明                                                  |
| ------------------------------------- | -------------- | --------------------------------------------------- |
| candidates\[]                         | array          | 候选结果；被拦截时可能为空。                                      |
| candidates\[].index                   | integer        | 候选位置。                                               |
| candidates\[].content.role / parts\[] | string / array | 输出角色和内容片段，文本通常位于 parts\[].text。                     |
| candidates\[].finishReason            | string         | STOP 正常结束；MAX\_TOKENS 达上限；SAFETY、RECITATION 等需单独处理。 |
| candidates\[].safetyRatings           | array          | 可选安全评估。                                             |
| candidates\[].groundingMetadata       | object         | 使用搜索等 grounding 工具时的来源与引用信息。                        |
| promptFeedback.blockReason            | string         | 输入被阻止的原因，可能没有候选结果。                                  |
| usageMetadata.promptTokenCount        | integer        | 输入 Token。                                           |
| usageMetadata.candidatesTokenCount    | integer        | 候选输出 Token。                                         |
| usageMetadata.thoughtsTokenCount      | integer        | 可选思考 Token，不是可直接显示的正文。                              |
| usageMetadata.totalTokenCount         | integer        | 本请求总 Token，可能还包括工具或思考等部分。                           |
| modelVersion / responseId             | string         | 可选模型版本与响应标识。                                        |

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

如果流式返回，使用 streamGenerateContent?alt=sse 并按候选序号合并；不要假设输出每个 part 都是文字。模型解读存在误差，医疗、身份或证件等高风险结论须经人工核对。

## 代码调用

设置 `SIMIROUTER_API_KEY`、`SIMIROUTER_GEMINI_MODEL`；`SIMIROUTER_BASE_URL` 可覆盖默认网关地址，不要在末尾追加 `/v1`。 `MEDIA_PATH` 指向已有的本地文件。 Python 3、Node.js 18+ 和 Go 示例只使用标准库；curl 示例的 JSON 由 Python 3 安全编码。

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

## 错误码

| HTTP 状态   | 含义或厂商错误类型                  | 处理方式                        |
| --------- | -------------------------- | --------------------------- |
| 400       | `INVALID_ARGUMENT` 等       | 检查 JSON、模型参数、媒体 MIME 和输入长度。 |
| 403       | `PERMISSION_DENIED`        | 检查 Key、项目权限、区域或账单限制。        |
| 404       | `NOT_FOUND`                | 检查模型名和 API 版本。              |
| 429       | `RESOURCE_EXHAUSTED`       | 检查限流与配额；可重试情况采用有限次数退避。      |
| 500 / 503 | `INTERNAL` / `UNAVAILABLE` | 记录请求标识，有限重试或稍后再试。           |

Google 原生错误对象包含 `error.code`（HTTP 数字）、`error.status`（枚举名称）、`error.message`，可能带 `details`。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。

长回复和流式请求可能持续数十秒到数分钟；客户端应设置足够超时，断流时按已收到的增量和终止原因判断，不要自动重发。429 与 5xx 先查看响应体和使用日志，内容策略拒绝时修改提示词或输入，不要原样重试。

## 官方参考

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 图片理解](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Google 音频理解](https\://ai.google.dev/gemini-api/docs/audio)
* [Google 视频理解](https\://ai.google.dev/gemini-api/docs/video-understanding)
* [Google PDF 理解](https\://ai.google.dev/gemini-api/docs/document-processing)
* [Google 故障排查](https\://ai.google.dev/gemini-api/docs/troubleshooting)