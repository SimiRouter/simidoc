# API 脚本接入

使用 Chat Completions 接口发送消息并读取模型回复。以下四种语言完成同一项操作：向 `POST /v1/chat/completions` 发送非流式 JSON 请求，等待完整响应后输出结果。

## 图片调用脚本

图片生成、参考图编辑和结果保存的完整示例按协议整理在[图片 API 总览](/simidoc/zh/apps/api/images)。

## 准备密钥和模型

先在[API 密钥管理](https://api.dwchainless.com/keys)创建密钥，再从[模型广场](https://api.dwchainless.com/zh/pricing/)复制当前密钥可用的完整模型 ID。示例从环境变量读取配置，不在文件内保存密钥。

* `SIMIROUTER_API_KEY`：SimiRouter API Key，必填。
* `SIMIROUTER_MODEL`：完整模型 ID，必填。
* `SIMIROUTER_BASE_URL`：可选，默认 `https://api.dwchainless.com`。此变量为根地址，不包含 `/v1`。

在本地终端或运行平台的环境变量设置中配置以上值。不要在公开日志中打印密钥。真实 API 请求可能产生费用。

## 使用 OpenAI SDK（直接替换）

已有基于 OpenAI 官方 SDK 的代码时，只替换 `baseURL` 与 `apiKey`，模型名换成 SimiRouter 的完整模型 ID。`baseURL` 必须以 `/v1` 结尾；SDK 方法名、参数与响应对象保持 OpenAI 的形状。

<Tabs items={["Python","Node.js"]}>
  <Tab value="Python">
    ```python
    import os
    from openai import OpenAI

    client = OpenAI(
        base_url="https://api.dwchainless.com/v1",
        api_key=os.environ["SIMIROUTER_API_KEY"],
    )
    response = client.chat.completions.create(
        model=os.environ["SIMIROUTER_MODEL"],
        messages=[{"role": "user", "content": "用一句话解释什么是机器学习。"}],
    )
    print(response.choices[0].message.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    import OpenAI from 'openai';

    const client = new OpenAI({
      baseURL: 'https://api.dwchainless.com/v1',
      apiKey: process.env.SIMIROUTER_API_KEY,
    });
    const response = await client.chat.completions.create({
      model: process.env.SIMIROUTER_MODEL,
      messages: [{ role: 'user', content: '用一句话解释什么是机器学习。' }],
    });
    console.log(response.choices[0].message.content);
    ```
  </Tab>
</Tabs>

Python 与 Node.js 需要先安装官方 SDK：`pip install openai` 或 `npm install openai`。SDK 会自动处理重试、超时与 SSE 流式解析；自定义超时、`max_retries` 等客户端选项保持 SDK 默认语义，网关不会改写。

网关按 OpenAI 兼容协议返回；模型能力差异由所选模型决定，SDK 不会改变这一点。若 SDK 报 `404`，先检查 `baseURL` 是否误写成 `https://api.dwchainless.com`（缺少 `/v1`）。

## 请求和返回

| 项目     | 说明                                                                |
| ------ | ----------------------------------------------------------------- |
| 方法与路径  | `POST /v1/chat/completions`                                       |
| 鉴权     | `Authorization: Bearer <API Key>`                                 |
| 内容类型   | `application/json`                                                |
| 必填参数   | `model`、`messages`                                                |
| 本例可选参数 | `max_completion_tokens: 256`、`stream: false`；须由选定模型支持             |
| 成功响应   | HTTP 200，`choices[].message.content` 包含文本回复，`usage` 为返回的 Token 用量 |
| 流式调用   | `stream: true` 时返回 SSE，不能按单个 JSON 响应解析                            |

完整参数、工具调用、多模态输入和 SSE 事件说明见 [Chat Completions](/simidoc/zh/apps/api/chat/openai-chat)。

## 代码调用

设置 `SIMIROUTER_API_KEY`、`SIMIROUTER_MODEL`；`SIMIROUTER_BASE_URL` 可覆盖默认网关地址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 示例只使用标准库；curl 示例的 JSON 由 Python 3 安全编码。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/chat/completions'
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
      if (!process.env.SIMIROUTER_API_KEY)
        throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        messages: [
          {
            role: 'user',
            content: '用一句话解释什么是机器学习。',
          },
        ],
        max_completion_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/chat/completions';
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
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/chat/completions" \
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
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/chat/completions"
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

| HTTP 状态 | 常见原因             | 处理方法                          |
| ------- | ---------------- | ----------------------------- |
| 400     | 请求格式错误、模型不支持所传参数 | 检查响应错误体，省略不支持的可选参数            |
| 401     | 密钥缺失、失效或不正确      | 检查当前环境变量，必要时重新创建密钥            |
| 403     | 模型、分组或渠道权限受限     | 核对密钥和账户权限                     |
| 404     | 路径或模型标识不正确       | 检查是否重复追加 `/v1`，核对完整模型 ID      |
| 429     | 速率限制或额度限制        | 先检查额度与限制，按错误信息退避；不要无限重试       |
| 5xx     | 网关或上游异常          | 保留脱敏的错误体和请求 ID；先核对使用记录再决定是否重试 |

上述状态是排查入口，具体原因以错误响应为准。请求超时不保证模型未执行；不要对生成请求进行无上限的自动重试。

## 其他功能

* [Responses](/simidoc/zh/apps/api/chat/openai-responses)：使用输入项与输出项组织请求。
* [Claude Messages](/simidoc/zh/apps/api/chat/claude)和 [Gemini](/simidoc/zh/apps/api/chat/gemini-text)：原生消息结构。
* [画图](/simidoc/zh/apps/api/images)：生成、编辑与识别。
* [音频](/simidoc/zh/apps/api/audio)：音频理解、语音合成、转录与翻译。
* [视频](/simidoc/zh/apps/api/video)：生成任务和视频理解。
* [MiMo 音频接入](/simidoc/zh/apps/api/audio/mimo-audio)：MiMo 语音合成、转录与音色能力。

## 官方参考

协议字段参考 [OpenAI Chat Completions API Reference](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)。SimiRouter 的地址和密钥与 OpenAI 官方直连不同。