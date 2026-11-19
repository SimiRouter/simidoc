# Gemini 文本生成

## 接口说明

`POST /v1beta/models/{model}:generateContent` 接收 Gemini contents/parts 结构，非流式返回完整 GenerateContentResponse。该接口与 OpenAI 的 messages 或 input 格式不同。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。Google 官方直连为 `https://generativelanguage.googleapis.com`，通常使用 `x-goog-api-key: $GEMINI_API_KEY`，不是网关的 Bearer Key。 模型名称应选用账户可访问且支持目标能力的模型。

## 快速开始

1. **准备配置**：在 API 密钥管理 创建密钥，从模型与价格复制支持 generateContent 的完整模型 ID。
2. **发送最小请求**：把模型 ID 直接写进路径（不要带 `models/` 前缀），`generationConfig.maxOutputTokens` 设为较小值。
3. **读取结果**：HTTP 2xx 且 `candidates[]` 非空才算成功，正文通常位于 `candidates[0].content.parts[].text`。
4. **验收**：检查 `finishReason` 和 `promptFeedback`，再核对使用日志。

```bash
API_URL="https://api.dwchainless.com/v1beta/models/MODEL_ID:generateContent"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"role": "user", "parts": [{"text": "用一句话解释机器学习。"}]}],
    "generationConfig": {"maxOutputTokens": 256}
  }'
```

把 `PASTE_API_KEY_HERE` 和路径中的 `MODEL_ID` 换成实际值；流式需改用 `streamGenerateContent?alt=sse`。

## 请求参数

请求体为 JSON。REST 字段统一使用 lowerCamelCase；不要把 Python SDK 的 snake\_case 参数名机械复制到 REST 请求中。

| 字段                                         | 类型               | 必填 | 说明                                          |
| ------------------------------------------ | ---------------- | -- | ------------------------------------------- |
| model（路径）                                  | string           | 是  | 模型 ID，不带 models/ 前缀；原生资源名为 models/\{model}。 |
| contents                                   | array            | 是  | 按顺序包含历史和当前消息。                               |
| contents\[].role                           | string           | 否  | user 或 model；多轮对话显式指定。                      |
| contents\[].parts                          | array            | 是  | 消息内容片段，至少一项。                                |
| parts\[].text                              | string           | 条件 | 文本片段；媒体片段改用 inlineData 或 fileData。          |
| systemInstruction.parts\[].text            | string           | 否  | 系统指令，不要使用 role=system 代替。                   |
| generationConfig.maxOutputTokens           | integer          | 否  | 生成 Token 上限，需结合模型对推理 Token 的计量规则。           |
| generationConfig.responseMimeType          | string           | 否  | 需要结构化输出时可使用 application/json，须模型支持。         |
| generationConfig.responseJsonSchema        | object           | 否  | 响应 JSON Schema，通常与 application/json 一同设置。   |
| generationConfig.temperature / topP / topK | number / integer | 否  | 仅支持该采样配置的模型使用；不要跨代复用固定参数。                   |
| generationConfig.stopSequences             | array            | 否  | 模型支持时的停止串。                                  |
| safetySettings                             | array            | 否  | 安全类别与阈值，不能关闭所有模型的全部安全机制。                    |
| tools / toolConfig                         | array / object   | 否  | Google 搜索、函数调用等工具定义与调用配置。                   |

### 请求示例

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "用一句话解释机器学习。"
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 256
  }
}
```

多轮对话交替加入 role=user 和 role=model，最后一项是当前问题；服务器不会根据前一次 HTTP 连接自动保存本次对话。

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
            "text": "机器学习让计算机通过数据学习规律并完成预测。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 12,
    "candidatesTokenCount": 20,
    "totalTokenCount": 32
  }
}
```

### 流式响应

将路径改为 `/v1beta/models/{model}:streamGenerateContent?alt=sse`，请求体不变。逐个解析 data 中的 GenerateContentResponse，按 candidate.index 合并 parts 文本；不要等待 OpenAI 的 `[DONE]` 标记。最终检查 finishReason、promptFeedback 与用量。SSE 是同一次生成的增量交付，不是后台任务，也不等于多个请求并行。

## 代码调用

设置 `SIMIROUTER_API_KEY`、`SIMIROUTER_GEMINI_MODEL`；`SIMIROUTER_BASE_URL` 可覆盖默认网关地址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 示例只使用标准库；curl 示例的 JSON 由 Python 3 安全编码。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
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
                text: '用一句话解释机器学习。',
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 256,
        },
      };
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
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
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
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }`), &body); err != nil { log.Fatal(err) }
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

Google 原生错误对象包含 `error.code`（HTTP 数字）、`error.status`（枚举名称）、`error.message`，可能带 `details`。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 HTTP 200 下 candidates 为空或 finishReason=SAFETY 可能表示内容被阻止，不是网络故障。

长回复和流式请求可能持续数十秒到数分钟；客户端应设置足够超时，断流时按已收到的增量和终止原因判断，不要自动重发。429 与 5xx 先查看响应体和使用日志，内容策略拒绝时修改提示词或输入，不要原样重试。

## 官方参考

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 文本生成](https\://ai.google.dev/gemini-api/docs/text-generation)
* [Google 故障排查](https\://ai.google.dev/gemini-api/docs/troubleshooting)