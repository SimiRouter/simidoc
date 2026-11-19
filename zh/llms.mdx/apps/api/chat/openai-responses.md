# Responses API

## 接口说明

`POST /v1/responses` 使用输入项与输出项而不是 Chat 的 choices/message 结构，适合工具调用、多模态与结构化输出。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

网关提供创建响应接口，不提供通用的 `GET /v1/responses/{id}` 与取消接口。因此 `background: true` 的 OpenAI 原生异步工作流不适用于此接入；使用同步或 SSE。需要后台任务时，应使用具有完整创建、查询、取消能力的官方直连接入。

## 快速开始

1. **准备配置**：在 API 密钥管理 创建密钥，从模型与价格复制支持 Responses 的完整模型 ID。
2. **发送最小请求**：用一段文本作为 `input`，`stream` 保持 `false`，先确认鉴权、模型和参数都有效。
3. **读取结果**：HTTP 2xx 且 `status` 为 `completed` 才算成功，正文位于 `output[].content[]` 中 `type=output_text` 的项。
4. **验收**：检查 `error`、`incomplete_details` 和实际内容，再核对使用日志。

```bash
API_URL="https://api.dwchainless.com/v1/responses"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "input": "用一句话解释机器学习。",
    "stream": false
  }'
```

把 `PASTE_API_KEY_HERE` 和 `MODEL_ID` 换成实际值；确认可用后，再增加工具、结构化输出或开启流式。

## 请求参数

内容类型为 `application/json`。

| 字段                                                    | 类型                       | 必填 | 说明                                                                                 |
| ----------------------------------------------------- | ------------------------ | -- | ---------------------------------------------------------------------------------- |
| model                                                 | string                   | 是  | 网关调用必填，选择支持 Responses 的模型。                                                         |
| input                                                 | string / array           | 条件 | 文本或输入项列表；普通生成需提供输入，也可结合可用的历史上下文。                                                   |
| input\[].role                                         | string                   | 条件 | 消息角色：user、assistant、system 或 developer。                                            |
| input\[].content\[].type                              | string                   | 条件 | input\_text、input\_image 或 input\_file 等有类型的内容项。                                   |
| input\[].content\[].text                              | string                   | 条件 | type=input\_text 时的文本。                                                             |
| input\[].content\[].image\_url                        | string                   | 条件 | type=input\_image 时的图片 URL 或 data URL。                                             |
| input\[].content\[].file\_data / file\_url / file\_id | string                   | 条件 | type=input\_file 时选择一种文件来源，详见文件识别。                                                 |
| instructions                                          | string                   | 否  | 高优先级指令；使用 previous\_response\_id 时仍应重新提供所需指令。                                      |
| max\_output\_tokens                                   | integer                  | 否  | 输出总 Token 上限，包含推理 Token。                                                           |
| stream                                                | boolean                  | 否  | true 返回带事件类型的 SSE 流。                                                               |
| previous\_response\_id                                | string                   | 否  | 上一响应 ID；依赖上游状态保留与同一可访问上下文。不要与 conversation 同用。                                     |
| conversation                                          | string / object          | 否  | 会话对象或 ID；不能与 previous\_response\_id 同用。是否开放取决于渠道。                                  |
| store                                                 | boolean                  | 否  | 请求上游保存响应；不是网关日志保留开关。                                                               |
| tools / tool\_choice                                  | array / string or object | 否  | 函数或厂商内置工具及选择规则。                                                                    |
| parallel\_tool\_calls                                 | boolean                  | 否  | 控制一个响应中是否允许多个函数调用。                                                                 |
| reasoning                                             | object                   | 否  | 支持的推理模型可配置 effort、summary；范围随模型变化。                                                 |
| text.format                                           | object                   | 否  | 文本格式，如 type=json\_schema；与 Chat 的 response\_format 不同。                             |
| temperature / top\_p                                  | number                   | 否  | 模型支持时的采样参数。                                                                        |
| truncation                                            | string                   | 否  | 官方已标记弃用，建议改用 context\_management；disabled（默认）超过上下文报错，auto 允许丢弃部分上下文。网关是否支持以实际行为为准。 |
| include                                               | array                    | 否  | 请求附加数据，如 reasoning.encrypted\_content、web\_search\_call.action.sources。            |
| metadata                                              | object                   | 否  | 业务关联元数据，不应用于保存敏感信息。                                                                |

可选字段未设置时应省略。`stop`、`enable_thinking` 等兼容扩展不是 OpenAI Responses 标准字段。`reasoning_content` 也不是标准输出字段；推理输出使用独立 reasoning 项，且不承诺暴露模型内部思维链。

### 请求示例

```json
{
  "model": "MODEL_ID",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "用一句话解释什么是机器学习。"
        }
      ]
    }
  ],
  "max_output_tokens": 256,
  "stream": false
}
```

## 返回值

非流式成功返回 HTTP 200。以下展示主要字段；未使用的可选状态字段可以为 null。

| 字段                                                   | 类型               | 说明                                                                                  |
| ---------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------- |
| id / object                                          | string           | 响应 ID；object=response。                                                              |
| created\_at / model                                  | integer / string | 创建时间（Unix 秒）与模型。                                                                    |
| status                                               | string           | completed、incomplete、failed、queued、in\_progress、cancelled；流式与后台响应都可能出现这些状态。         |
| output\[]                                            | array            | 有类型的输出项，可能混合 message、reasoning、function\_call、web\_search\_call 等；不可固定读 output\[0]。 |
| output\[].type / id / status                         | string           | 输出项类型、ID 和项状态（视类型出现）。                                                               |
| output\[].role                                       | string           | 消息输出通常为 assistant。                                                                  |
| output\[].content\[]                                 | array            | 消息内容项，文本为 type=output\_text；拒绝为 type=refusal。                                       |
| output\[].content\[].text / annotations              | string / array   | 正文与引用等注释。                                                                           |
| output\[].call\_id / name / arguments                | string           | function\_call 的关联 ID、函数名、JSON 字符串参数。                                               |
| error                                                | object / null    | 失败信息；正常完成时通常为 null。                                                                 |
| incomplete\_details                                  | object / null    | 不完整原因，如 max\_output\_tokens，不应当作完整成功。                                               |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | 输入、输出和总 Token。                                                                      |
| usage.\*\_tokens\_details                            | object           | 可选缓存和推理等用量明细。                                                                       |

```json
{
  "id": "resp_example",
  "object": "response",
  "created_at": 1760000000,
  "model": "MODEL_ID",
  "status": "completed",
  "error": null,
  "incomplete_details": null,
  "output": [
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "机器学习让计算机从数据中学习规律，用于预测和决策。",
          "annotations": []
        }
      ]
    }
  ],
  "usage": {
    "input_tokens": 18,
    "output_tokens": 22,
    "total_tokens": 40
  }
}
```

提取正文时，遍历 `output` 内 `type=message` 的项，再拼接其 `content` 中 `type=output_text` 的 text。SDK 的 `output_text` 是便捷聚合属性，不应当作原始 REST JSON 必有字段。

### 流式响应

设置 stream=true 后，按 SSE 的 `event` 和 `data` 解析：response.created 建立响应；response.output\_text.delta 追加文字；response.output\_item.added/done 管理输出项；response.function\_call\_arguments.delta 拼接工具参数。只有收到 response.completed 并检查最终 response.status 后，才能判定完整完成；response.failed、response.incomplete 或 error 要单独处理。不要只靠网络 EOF 判定成功。

```text
event: response.output_text.delta
data: {"type":"response.output_text.delta","item_id":"msg_example","output_index":0,"content_index":0,"delta":"机器学习","sequence_number":3}

event: response.completed
data: {"type":"response.completed","response":{"id":"resp_example","object":"response","status":"completed","output":[]},"sequence_number":12}
```

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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/responses'
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
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        input: [
          {
            role: 'user',
            content: [
              {
                type: 'input_text',
                text: '用一句话解释什么是机器学习。',
              },
            ],
          },
        ],
        max_output_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/responses';
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/responses" \
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/responses"
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

| HTTP 状态   | 含义或厂商错误类型    | 处理方式                      |
| --------- | ------------ | ------------------------- |
| 400       | 请求无效         | 检查必填字段、JSON、模型参数和上下文长度。   |
| 401       | 认证失败         | 检查 Key 是否存在、有效及归属正确。      |
| 403 / 404 | 无权访问 / 资源不存在 | 检查模型权限、资源 ID 和 URL。       |
| 429       | 速率或配额限制      | 结合响应体区分限流与额度不足，后者不能靠重试解决。 |
| 500 / 503 | 服务错误 / 暂时不可用 | 保留请求标识，对暂时故障做有限次数退避。      |

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 即使 HTTP 200，也必须检查 status、error 和 incomplete\_details；SSE 中的失败事件不一定改变已经发送的 HTTP 状态。

长回复和流式请求可能持续数十秒到数分钟；客户端应设置足够超时，断流时按已收到的增量和终止原因判断，不要自动重发。429 与 5xx 先查看响应体和使用日志，内容策略拒绝时修改提示词或输入，不要原样重试。

## 官方参考

* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI 流式事件](https\://developers.openai.com/api/docs/guides/streaming-responses)
* [OpenAI 对话状态](https\://developers.openai.com/api/docs/guides/conversation-state)
* [OpenAI 后台模式](https\://developers.openai.com/api/docs/guides/background)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)