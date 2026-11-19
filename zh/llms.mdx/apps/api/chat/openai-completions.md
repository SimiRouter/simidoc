# 传统文本补全

## 接口说明

`POST /v1/completions` 接收 prompt 并返回补全文本，不使用 messages、工具调用或 Responses 输出项。它是传统接口；新项目优先采用 Chat Completions 或 Responses。只有支持该补全协议的模型才能调用，不可把任意聊天模型 ID 直接放入。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

## 快速开始

1. **准备配置**：在 API 密钥管理 创建密钥，从模型与价格复制支持传统补全的完整模型 ID。
2. **发送最小请求**：只提交一个 `prompt`，`stream` 保持 `false`，先确认鉴权、模型和参数都有效。
3. **读取结果**：HTTP 2xx 且 `choices[]` 非空才算成功，补全文本位于 `choices[0].text`。
4. **验收**：检查 `finish_reason` 和实际内容，再核对使用日志。

```bash
API_URL="https://api.dwchainless.com/v1/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "prompt": "请补全这句话：机器学习是",
    "max_tokens": 64,
    "stream": false
  }'
```

把 `PASTE_API_KEY_HERE` 和 `MODEL_ID` 换成实际值；新项目优先使用 Chat Completions 或 Responses。

## 请求参数

JSON 请求体。

| 字段                                     | 类型             | 必填 | 说明                                  |
| -------------------------------------- | -------------- | -- | ----------------------------------- |
| model                                  | string         | 是  | 支持传统补全的模型 ID。                       |
| prompt                                 | string / array | 条件 | 待补全文本；也可为多段文本或 Token ID 数组。示例使用字符串。 |
| max\_tokens                            | integer        | 否  | 最多生成的 Token 数，需与输入总量共同满足窗口限制。       |
| stream                                 | boolean        | 否  | true 返回 SSE；默认 false。               |
| temperature / top\_p                   | number         | 否  | 采样控制，通常只调整一个。                       |
| n                                      | integer        | 否  | 每个 prompt 的候选补全数。                   |
| stop                                   | string / array | 否  | 最多 4 个停止序列；返回文本不包含停止串。              |
| echo                                   | boolean        | 否  | 是否把输入 prompt 包含在返回 text 中。          |
| logprobs                               | integer        | 否  | 返回候选 Token 的对数概率，最大值 5。             |
| presence\_penalty / frequency\_penalty | number         | 否  | 重复惩罚，范围 -2 到 2。                     |
| suffix                                 | string         | 否  | 仅支持插入补全的模型可用。                       |
| best\_of                               | integer        | 否  | 服务端生成多候选后择优，不能与 stream 同用，且会增加生成量。  |

### 请求示例

```json
{
  "model": "MODEL_ID",
  "prompt": "请补全这句话：机器学习是",
  "max_tokens": 64,
  "stream": false
}
```

## 返回值

| 字段                                                        | 类型               | 说明                             |
| --------------------------------------------------------- | ---------------- | ------------------------------ |
| id / object                                               | string           | 补全 ID；object=text\_completion。 |
| created / model                                           | integer / string | Unix 秒时间戳与模型。                  |
| choices\[].text                                           | string           | 补全结果，不是 message.content。       |
| choices\[].index                                          | integer          | 候选序号。                          |
| choices\[].finish\_reason                                 | string           | stop、length 或 content\_filter。 |
| choices\[].logprobs                                       | object / null    | Token 概率信息；未请求时通常为 null。       |
| usage.prompt\_tokens / completion\_tokens / total\_tokens | integer          | 输入、生成与总 Token。                 |

```json
{
  "id": "cmpl_example",
  "object": "text_completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "text": "一种从数据中学习规律的方法。",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 14,
    "total_tokens": 26
  }
}
```

流式时拼接 choices\[].text，以 `[DONE]` 结束；多 prompt 或多候选时按 index 分别合并。

## 代码调用

设置 `SIMIROUTER_API_KEY`、`SIMIROUTER_COMPLETION_MODEL`；`SIMIROUTER_BASE_URL` 可覆盖默认网关地址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 示例只使用标准库；curl 示例的 JSON 由 Python 3 安全编码。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_COMPLETION_MODEL"): raise RuntimeError("请设置 SIMIROUTER_COMPLETION_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    path = '/v1/completions'
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
      if (!process.env.SIMIROUTER_COMPLETION_MODEL)
        throw new Error('请设置 SIMIROUTER_COMPLETION_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        prompt: '请补全这句话：机器学习是',
        max_tokens: 64,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_COMPLETION_MODEL;
      const endpoint = '/v1/completions';
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
    : "${SIMIROUTER_COMPLETION_MODEL:?请设置 SIMIROUTER_COMPLETION_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/completions" \
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
      model := os.Getenv("SIMIROUTER_COMPLETION_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_COMPLETION_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/completions"
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

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。

长回复和流式请求可能持续数十秒到数分钟；客户端应设置足够超时，断流时按已收到的增量和终止原因判断，不要自动重发。429 与 5xx 先查看响应体和使用日志，内容策略拒绝时修改提示词或输入，不要原样重试。

## 官方参考

* [OpenAI Completions API](https\://developers.openai.com/api/reference/resources/completions/methods/create)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)