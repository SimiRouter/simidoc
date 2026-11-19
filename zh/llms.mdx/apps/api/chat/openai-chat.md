# Chat Completions

## 接口说明

`POST /v1/chat/completions` 根据消息历史生成助手回复。适用于已有 Chat Completions 客户端以及无状态多轮对话。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

## 快速开始

1. **准备配置**：在 API 密钥管理 创建密钥，从模型与价格复制支持 Chat Completions 的完整模型 ID。
2. **发送最小请求**：只提交一条用户消息，`stream` 保持 `false`，先确认鉴权、模型和参数都有效。
3. **读取结果**：HTTP 2xx 且 `choices[]` 非空才算成功，正文位于 `choices[0].message.content`。
4. **验收**：检查 `finish_reason`、拒绝信息和实际内容，再核对使用日志。

```bash
API_URL="https://api.dwchainless.com/v1/chat/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

把 `PASTE_API_KEY_HERE` 和 `MODEL_ID` 换成实际值；确认可用后，再增加多轮历史、工具或开启流式。

已有 OpenAI SDK 项目时，只需把 `baseURL` 指向 `https://api.dwchainless.com/v1`、换用本站 Key，方法名与参数不用改，见 [API 脚本接入](/simidoc/zh/apps/api-script)。

## 请求参数

内容类型为 `application/json`。未使用的可选字段应省略，不要批量发送空字符串、0、空对象或 null。

| 字段                                     | 类型                       | 必填 | 说明                                                                |
| -------------------------------------- | ------------------------ | -- | ----------------------------------------------------------------- |
| model                                  | string                   | 是  | 模型 ID。                                                            |
| messages                               | array                    | 是  | 至少一条消息；调用方按顺序提交所需历史。                                              |
| messages\[].role                       | string                   | 是  | `developer`、`system`、`user`、`assistant`、`tool`，可用角色随模型变化。         |
| messages\[].content                    | string / array / null    | 条件 | 普通消息的文本或内容数组；助手消息带 `tool_calls` 时可省略或为 null。                      |
| messages\[].content\[].type            | string                   | 条件 | 与内容对应的 `text`、`image_url`、`input_audio` 或 `file`。                 |
| messages\[].content\[].text            | string                   | 条件 | type=text 时的文本。                                                   |
| messages\[].content\[].image\_url      | object                   | 条件 | type=image\_url 时提供 `url`，可选 `detail`；详见图片理解。                     |
| messages\[].tool\_calls                | array                    | 否  | 助手请求的函数调用；每项包含 id、type=function、function.name、function.arguments。 |
| messages\[].tool\_call\_id             | string                   | 条件 | role=tool 时必填，对应助手给出的工具调用 ID。                                     |
| max\_completion\_tokens                | integer                  | 否  | 生成 Token 上限，包含可见输出与推理 Token。                                      |
| stream                                 | boolean                  | 否  | true 返回 SSE；默认非流式。                                                |
| stream\_options.include\_usage         | boolean                  | 否  | 流式结束前请求 usage 汇总块，须同时开启 stream。                                   |
| temperature / top\_p                   | number                   | 否  | 采样参数，仅在选定模型支持时使用；通常只调整一个。                                         |
| stop                                   | string / array           | 否  | 停止序列，仅部分模型支持。                                                     |
| n                                      | integer                  | 否  | 候选回复数量；不是并发请求数量。                                                  |
| tools / tool\_choice                   | array / string or object | 否  | 函数定义和调用选择，见工具调用。                                                  |
| parallel\_tool\_calls                  | boolean                  | 否  | 允许一次回复包含多个函数调用，不会替应用执行函数。                                         |
| response\_format                       | object                   | 否  | 结构化输出配置，支持时可用 json\_schema 或 json\_object。                        |
| reasoning\_effort                      | string                   | 否  | 推理强度；可选值由模型决定，不是任意模型都支持。                                          |
| presence\_penalty / frequency\_penalty | number                   | 否  | 重复惩罚，范围 -2 到 2，需模型支持。                                             |
| logprobs / top\_logprobs               | boolean / integer        | 否  | 输出 Token 概率及候选数量，需模型支持。                                           |

`max_tokens` 是旧参数，已由 `max_completion_tokens` 取代；非 o-series 模型仍可能接受该字段，`/v1/completions` 则仍只使用 `max_tokens`。新集成不要同时发送两者。`video_url`、`reasoning_content` 属于部分兼容模型扩展，不是 OpenAI Chat Completions 的通用标准字段。

### 请求示例

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释什么是机器学习。"
    }
  ],
  "max_completion_tokens": 256,
  "stream": false
}
```

## 返回值

成功的非流式响应为 HTTP 200 JSON。以下为结构示例，ID 和 Token 数仅用于说明。

| 字段                             | 类型               | 说明                                                             |
| ------------------------------ | ---------------- | -------------------------------------------------------------- |
| id / object                    | string           | 响应 ID；object=chat.completion。                                  |
| created / model                | integer / string | 创建时间（Unix 秒）与响应模型。                                             |
| choices\[]                     | array            | 候选回复列表，每项的 index 标识位置。                                         |
| choices\[].message.role        | string           | assistant。                                                     |
| choices\[].message.content     | string / null    | 文本回复；工具调用或拒绝时可为空，不等同于请求失败。                                     |
| choices\[].message.tool\_calls | array            | 待应用执行的函数调用。arguments 是 JSON 字符串，须解析并验证。                        |
| choices\[].message.refusal     | string / null    | 拒绝信息，若有。                                                       |
| choices\[].finish\_reason      | string           | stop 正常结束；length 达到上限；tool\_calls 进入工具调用；content\_filter 内容过滤。 |
| usage.prompt\_tokens           | integer          | 输入 Token。                                                      |
| usage.completion\_tokens       | integer          | 生成 Token，可能包含推理 Token。                                         |
| usage.total\_tokens            | integer          | 输入与生成 Token 总计。                                                |
| usage.\*\_tokens\_details      | object           | 可选用量明细，如 cached\_tokens、reasoning\_tokens。                     |

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "机器学习是让计算机从数据中学习规律并用于预测或决策的方法。",
        "refusal": null
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 18,
    "completion_tokens": 24,
    "total_tokens": 42
  }
}
```

### 流式响应

设置 `stream: true` 后接收 `text/event-stream`。逐个解析 `data:` 行的 JSON，按 `choices[].index` 合并 `delta.content`；函数参数按工具 index 合并 `delta.tool_calls`。完成标记是 `data: [DONE]`，不是 JSON 对象。开启 include\_usage 时最终用量块的 choices 可以为空，普通块的 usage 可以为 null。连接中断前没有收到结束信号时，应将回复标记为不完整，而不是自动当作成功。

```text
data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"content":"机器学习"},"finish_reason":null}]}

data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
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

### 使用 OpenAI SDK

已安装官方 `openai` SDK 时不必手写 HTTP 请求：把 `baseURL` 指向网关即可复用官方类型定义、重试与流式解析。安装命令为 `pip install openai` 或 `npm install openai`。

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

## 错误码

| HTTP 状态   | 含义或厂商错误类型    | 处理方式                      |
| --------- | ------------ | ------------------------- |
| 400       | 请求无效         | 检查必填字段、JSON、模型参数和上下文长度。   |
| 401       | 认证失败         | 检查 Key 是否存在、有效及归属正确。      |
| 403 / 404 | 无权访问 / 资源不存在 | 检查模型权限、资源 ID 和 URL。       |
| 429       | 速率或配额限制      | 结合响应体区分限流与额度不足，后者不能靠重试解决。 |
| 500 / 503 | 服务错误 / 暂时不可用 | 保留请求标识，对暂时故障做有限次数退避。      |

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 HTTP 200 仍需检查 finish\_reason、拒绝信息和流式完整性；length 与 content\_filter 不是 HTTP 错误。

长回复和流式请求可能持续数十秒到数分钟；客户端应设置足够超时，断流时按已收到的增量和终止原因判断，不要自动重发。429 与 5xx 先查看响应体和使用日志，内容策略拒绝时修改提示词或输入，不要原样重试。

### 错误响应示例

错误响应通常是 OpenAI 形状的 `error` 对象，`param` 与 `code` 可能为 `null`；以下仅为示意，文案会随网关或上游变化，不要按字符串匹配。

```json
{
  "error": {
    "message": "You didn't provide an API key.",
    "type": "invalid_request_error",
    "param": null,
    "code": "invalid_api_key"
  }
}
```

```json
{
  "error": {
    "message": "Rate limit reached for requests.",
    "type": "rate_limit_error",
    "param": null,
    "code": "rate_limit_exceeded"
  }
}
```

## 常见问题

**返回 401 或 `Invalid token` 怎么办？**
确认请求头是 `Authorization: Bearer <Key>`，Key 属于当前网关且未被撤销；不要把登录密码或厂商 Key 当成本站 Key。

**返回 404 或提示模型不存在？**
`model` 必须是模型广场里的完整模型 ID，并确认当前密钥分组有该模型权限。SDK 用户还要检查 `baseURL` 是否包含 `/v1`。

**429 应该重试吗？**
先看响应体：限流可以按指数退避重试并加随机抖动；额度不足或余额耗尽是计费问题，重试不会成功，应充值或调整额度。

**流式响应怎样才算完整？**
收到 `data: [DONE]` 且最后一块带 `finish_reason` 才算正常结束。连接中断且没有结束标记时，把回复当作不完整，不要自动重发已计费的请求。

**`max_tokens` 和 `max_completion_tokens` 用哪个？**
Chat Completions 用 `max_completion_tokens`；`max_tokens` 是旧字段，仅部分模型仍接受。两者不要同时发送，`/v1/completions` 仍只用 `max_tokens`。

**为什么设置了 temperature 却没有效果？**
部分推理模型固定采样或只接受默认值，网关会透传给渠道；以该模型的文档与报错为准，不要假定所有 OpenAI 参数都生效。

## 官方参考

* [OpenAI Chat Completions API](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI 文本生成](https\://developers.openai.com/api/docs/guides/text)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)