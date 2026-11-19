# Gemini 格式模型列表

## 接口说明

`GET /v1beta/models` 返回 Gemini 格式的模型列表。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。Google 官方直连为 `https://generativelanguage.googleapis.com`，通常使用 `x-goog-api-key: $GEMINI_API_KEY`，不是网关的 Bearer Key。 模型名称应选用账户可访问且支持目标能力的模型。

网关列表主要用于发现模型名，不能视为 Google 原生完整模型能力目录。

## 请求参数

网关请求无请求体，不要求分页参数。Google 原生 models.list 支持 pageSize（默认 50、最大 1000）和 pageToken，但当前网关返回完整列表，不提供相同的分页与模型元数据保证。

| 字段                   | 类型                     | 必填   | 说明                               |
| -------------------- | ---------------------- | ---- | -------------------------------- |
| Authorization        | header string          | 是    | Bearer 网关 Key；官方直连改用 Google Key。 |
| pageSize / pageToken | query integer / string | 原生可选 | 仅官方原生列表的分页请求；不要依赖网关处理它们。         |

## 返回值

| 字段                                           | 类型             | 说明                                         |
| -------------------------------------------- | -------------- | ------------------------------------------ |
| models                                       | array          | 模型列表，可为空。                                  |
| models\[].name                               | string         | 模型资源名；官方通常为 models/\{id}，网关也可能直接返回模型 ID。   |
| models\[].displayName                        | string         | 可读名称。                                      |
| nextPageToken                                | string / null  | 官方的下一页令牌；网关可返回 null 表示无分页。                 |
| models\[].version / description              | string / null  | 官方可提供的版本与说明；网关列表可缺失或为 null。                |
| models\[].inputTokenLimit / outputTokenLimit | integer / null | 官方可提供的输入与输出限制，不应从缺失值推断。                    |
| models\[].supportedGenerationMethods         | array / null   | 官方可提供 generateContent 等方法名；网关列表可缺失或为 null。 |

```json
{
  "models": [
    {
      "name": "MODEL_ID",
      "displayName": "MODEL_ID"
    }
  ],
  "nextPageToken": null
}
```

以上为网关精简结构示例。将 name 用于路径前，应只去掉一次开头的 models/。即使 models.list 成功，后续 generateContent 仍可能因权限、模型能力或配额失败。

## 代码调用

设置 `SIMIROUTER_API_KEY`。可用 `SIMIROUTER_BASE_URL` 覆盖默认网关根地址，末尾须去掉版本路径。所有示例都发送无请求体的 GET。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1beta/models'
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
      const endpoint = "/v1beta/models";
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
    curl "${BASE_URL%/}/v1beta/models" \
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
      endpoint := "/v1beta/models"
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

| HTTP 状态   | 含义或厂商错误类型                  | 处理方式                        |
| --------- | -------------------------- | --------------------------- |
| 400       | `INVALID_ARGUMENT` 等       | 检查 JSON、模型参数、媒体 MIME 和输入长度。 |
| 403       | `PERMISSION_DENIED`        | 检查 Key、项目权限、区域或账单限制。        |
| 404       | `NOT_FOUND`                | 检查模型名和 API 版本。              |
| 429       | `RESOURCE_EXHAUSTED`       | 检查限流与配额；可重试情况采用有限次数退避。      |
| 500 / 503 | `INTERNAL` / `UNAVAILABLE` | 记录请求标识，有限重试或稍后再试。           |

Google 原生错误对象包含 `error.code`（HTTP 数字）、`error.status`（枚举名称）、`error.message`，可能带 `details`。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 网关内部查询还可能返回 success=false 的 HTTP 200 业务错误，须同时检查响应结构。

## 官方参考

* [Google Models API](https\://ai.google.dev/api/models)
* [Google 模型目录](https\://ai.google.dev/gemini-api/docs/models)
* [Google 故障排查](https\://ai.google.dev/gemini-api/docs/troubleshooting)