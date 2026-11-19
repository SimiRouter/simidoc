# Claude Messages

## 接口说明

`POST /v1/messages` 接收 user/assistant 消息，返回由文本、工具调用或思考块组成的 Message。顶层 system 用于系统指令，不要创建 role=system 的 messages 项。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。Anthropic 官方直连为 `https://api.anthropic.com`，使用 `x-api-key: $ANTHROPIC_API_KEY`。示例固定 `anthropic-version: 2023-06-01` 以选择相应协议版本，不代表最新版。 模型名称应选用账户可访问且支持目标能力的模型。

## 快速开始

1. **准备配置**：在 API 密钥管理 创建密钥，从模型与价格复制支持 Claude Messages 的完整模型 ID。
2. **发送最小请求**：只提交一条用户消息，保留 `anthropic-version` 请求头，`stream` 保持 `false`。
3. **读取结果**：HTTP 2xx 且 `content[]` 非空才算成功，正文位于 `type=text` 的内容块。
4. **验收**：检查 `stop_reason`、`stop_sequence` 和实际内容，再核对使用日志。

```bash
API_URL="https://api.dwchainless.com/v1/messages"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "anthropic-version: 2023-06-01" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "max_tokens": 256,
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

把 `PASTE_API_KEY_HERE` 和 `MODEL_ID` 换成实际值；`anthropic-version` 用于选择协议版本，不代表最新版。

## 请求参数

请求体为 JSON；示例请求头包含 `anthropic-version: 2023-06-01`。

| 字段                            | 类型               | 必填 | 说明                                                    |
| ----------------------------- | ---------------- | -- | ----------------------------------------------------- |
| model                         | string           | 是  | 可访问的 Claude 模型 ID。                                    |
| max\_tokens                   | integer          | 是  | 生成 Token 上限；普通生成设为正整数，0 仅用于支持该行为的缓存写入流程。              |
| messages                      | array            | 是  | 对话消息列表。                                               |
| messages\[].role              | string           | 是  | user 或 assistant。                                     |
| messages\[].content           | string / array   | 是  | 文本字符串或内容块数组。                                          |
| content\[].type               | string           | 条件 | text、image、tool\_use、tool\_result 等对应类型。              |
| content\[].text               | string           | 条件 | text 块的正文。                                            |
| content\[].source             | object           | 条件 | image 的来源，可用 base64 的 media\_type/data 或 url 类型的 url。 |
| system                        | string / array   | 否  | 系统指令；支持时可使用文本块。                                       |
| stream                        | boolean          | 否  | true 返回 SSE；默认非流式。                                    |
| stop\_sequences               | array            | 否  | 自定义停止序列。                                              |
| temperature / top\_p / top\_k | number / integer | 否  | 采样设置，仅对支持该设置的模型使用。                                    |
| tools                         | array            | 否  | 函数工具定义，包含 name、description、input\_schema。             |
| tool\_choice                  | object           | 否  | auto、any、tool 或 none 等工具选择；使用 tool 时指定 name。          |
| thinking                      | object           | 否  | 思考配置与模型代际有关；adaptive、enabled 等不是所有模型都接受。              |
| metadata.user\_id             | string           | 否  | 业务用户标识，不应发送直接身份信息。                                    |

### 请求示例

```json
{
  "model": "MODEL_ID",
  "max_tokens": 256,
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释机器学习。"
    }
  ],
  "stream": false
}
```

## 返回值

HTTP 200 的非流式响应为 Message。

| 字段                                                                | 类型            | 说明                                                                     |
| ----------------------------------------------------------------- | ------------- | ---------------------------------------------------------------------- |
| id / type                                                         | string        | 消息 ID；type=message。                                                    |
| role / model                                                      | string        | assistant 与响应模型 ID。                                                    |
| content\[]                                                        | array         | 内容块列表；不能假定每一项都含 text。                                                  |
| content\[].type / text                                            | string        | type=text 时读取 text；tool\_use 时读取 id/name/input。                        |
| stop\_reason                                                      | string / null | end\_turn 自然结束；max\_tokens 达到上限；stop\_sequence 命中停止串；tool\_use 请求执行工具。 |
| stop\_sequence                                                    | string / null | 命中的停止序列，无则为 null。                                                      |
| usage.input\_tokens / output\_tokens                              | integer       | 输入与输出 Token。                                                           |
| usage.cache\_creation\_input\_tokens / cache\_read\_input\_tokens | integer       | 可选缓存写入与命中计量，不能简单算作额外正文。                                                |

```json
{
  "id": "msg_example",
  "type": "message",
  "role": "assistant",
  "model": "MODEL_ID",
  "content": [
    {
      "type": "text",
      "text": "机器学习是一种从数据中提取规律并用于预测的方法。"
    }
  ],
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 14,
    "output_tokens": 24
  }
}
```

### 流式响应

stream=true 后依次处理 message\_start、content\_block\_start、content\_block\_delta、content\_block\_stop、message\_delta、message\_stop。text\_delta 追加文本；input\_json\_delta 追加工具参数的 partial\_json，拼接完成后才解析。message\_delta 提供停止原因与用量更新，message\_stop 标记消息结束；error 事件可出现在 HTTP 200 之后。

工具使用时保留收到的助手内容块，在后续 user 消息中用 `{"type":"tool_result","tool_use_id":"...","content":"..."}` 返回结果。执行工具前必须校验参数与权限。

## 代码调用

设置 `SIMIROUTER_API_KEY`、`SIMIROUTER_CLAUDE_MODEL`；`SIMIROUTER_BASE_URL` 可覆盖默认网关地址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 示例只使用标准库；curl 示例的 JSON 由 Python 3 安全编码。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_CLAUDE_MODEL"): raise RuntimeError("请设置 SIMIROUTER_CLAUDE_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    path = '/v1/messages'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={'anthropic-version': '2023-06-01', "Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
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
      if (!process.env.SIMIROUTER_CLAUDE_MODEL)
        throw new Error('请设置 SIMIROUTER_CLAUDE_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        max_tokens: 256,
        messages: [
          {
            role: 'user',
            content: '用一句话解释机器学习。',
          },
        ],
        stream: false,
      };
      body.model = process.env.SIMIROUTER_CLAUDE_MODEL;
      const endpoint = '/v1/messages';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          'anthropic-version': '2023-06-01',
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
    : "${SIMIROUTER_CLAUDE_MODEL:?请设置 SIMIROUTER_CLAUDE_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/messages" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "anthropic-version: 2023-06-01" \
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
      model := os.Getenv("SIMIROUTER_CLAUDE_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_CLAUDE_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/messages"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("anthropic-version", "2023-06-01")
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

| HTTP 状态         | 含义或厂商错误类型                                          | 处理方式                   |
| --------------- | -------------------------------------------------- | ---------------------- |
| 400             | `invalid_request_error`                            | 请求结构、参数或模型能力不匹配。       |
| 401 / 403       | `authentication_error` / `permission_error`        | Key 无效或没有访问权限。         |
| 404             | `not_found_error`                                  | 端点、模型或资源不存在。           |
| 413             | `request_too_large`                                | 缩小请求体。                 |
| 429             | `rate_limit_error`                                 | 检查速率与额度限制。             |
| 500 / 504 / 529 | `api_error` / `timeout_error` / `overloaded_error` | 服务异常、超时或过载；仅对暂时故障有限重试。 |

Anthropic 原生错误形如 `{"type":"error","error":{"type":"invalid_request_error","message":"..."},"request_id":"..."}`。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。

长回复和流式请求可能持续数十秒到数分钟；客户端应设置足够超时，断流时按已收到的增量和终止原因判断，不要自动重发。429 与 5xx 先查看响应体和使用日志，内容策略拒绝时修改提示词或输入，不要原样重试。

## 官方参考

* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Anthropic API 版本](https\://platform.claude.com/docs/en/api/versioning)
* [Anthropic 错误处理](https\://platform.claude.com/docs/en/api/errors)