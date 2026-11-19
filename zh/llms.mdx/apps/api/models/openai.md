# OpenAI 格式模型列表

## 接口说明

`GET /v1/models` 返回当前 Key 可见的模型列表。列表可用于配置界面的模型选择，不证明模型具备所有模态、工具、可用额度或实时服务能力。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

只发送 Bearer 认证，不混用 x-api-key 或 x-goog-api-key，以免触发网关其他返回格式。

## 请求参数

该列表请求无 JSON 请求体，也没有必填查询参数。

| 字段            | 类型            | 必填 | 说明                |
| ------------- | ------------- | -- | ----------------- |
| Authorization | header string | 是  | Bearer 后携带网关 Key。 |

## 返回值

| 字段                                | 类型                     | 说明                                            |
| --------------------------------- | ---------------------- | --------------------------------------------- |
| object                            | string                 | list。                                         |
| data                              | array                  | 模型列表，允许为空。                                    |
| data\[].id                        | string                 | 调用生成接口时使用的模型 ID。                              |
| data\[].object                    | string                 | model。                                        |
| data\[].created                   | integer                | Unix 秒时间戳；网关元数据不一定等于厂商模型发布日期。                 |
| data\[].owned\_by                 | string                 | 模型归属标签，不能据此证明请求一定路由到某一厂商。                     |
| success                           | boolean                | 网关可附加的业务结果标志，不是 OpenAI 标准字段。                  |
| `data[].context_length`           | integer                | 网关提供的上下文长度（Token），未配置时使用平台默认值。以模型说明和实际接口限制为准。 |
| `data[].supported_endpoint_types` | `array<string>` / null | 网关公布的接口类型。可作为选接口的参考。                          |

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

空数组是合法列表，不要直接访问 data\[0]。网关查询用户分组失败时可返回 HTTP 200 且 success=false/message；客户端仍须识别业务失败。官方 OpenAI 另有 GET /v1/models/\{model} 查询单模型，不应将列表元数据当作完整能力说明。

## 代码调用

设置 `SIMIROUTER_API_KEY`。可用 `SIMIROUTER_BASE_URL` 覆盖默认网关根地址，末尾须去掉版本路径。所有示例都发送无请求体的 GET。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1/models'
    request = urllib.request.Request(base + path, method="GET",
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
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const endpoint = "/v1/models";
      const response = await fetch(base + endpoint, { method: "GET",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    curl "${BASE_URL%/}/v1/models" \
      --fail-with-body \
      --max-time 120 \
      -X GET \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      endpoint := "/v1/models"
      req, err := http.NewRequest("GET", base + endpoint, nil); if err != nil { log.Fatal(err) }
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

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 还需检查网关 success=false 的业务错误；这与 HTTP 传输成功不同。

## 官方参考

* [OpenAI List models](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [OpenAI Retrieve model](https\://developers.openai.com/api/reference/resources/models/methods/retrieve)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)