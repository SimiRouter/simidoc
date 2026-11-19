# 网络搜索工具

## 接口说明

`POST /v1/responses` 可在 tools 中声明 OpenAI 托管 web\_search 工具，使支持它的模型检索网页、阅读结果并给出带引用的回答。搜索不是一个独立的通用 `/search` 端点，也不是所有 Chat 模型都可使用的函数名称。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

`{"type":"web_search"}` 用于 Responses。不要把它直接塞入普通 Chat Completions 的 tools：Chat 的通用工具是 function；官方 Chat 搜索另有专用搜索模型与 web\_search\_options，不等于同一协议。

## 请求参数

| 字段                                | 类型              | 必填 | 说明                                                               |
| --------------------------------- | --------------- | -- | ---------------------------------------------------------------- |
| model                             | string          | 是  | 支持 Responses web\_search 的模型。                                    |
| input                             | string / array  | 是  | 问题和必要背景。                                                         |
| tools\[].type                     | string          | 是  | web\_search。                                                     |
| tools\[].search\_context\_size    | string          | 否  | 支持时选择 low、medium 或 high 搜索上下文。                                   |
| tools\[].filters.allowed\_domains | array           | 否  | 支持时限制允许域名，不带协议前缀。                                                |
| tools\[].user\_location           | object          | 否  | 大致位置，如 type=approximate、country、city、region、timezone；避免提交精确隐私位置。 |
| tool\_choice                      | string / object | 否  | auto 允许模型决定是否调用；required 要求工具调用。                                 |
| include                           | array           | 否  | 可用 web\_search\_call.action.sources 请求完整来源列表。                    |
| stream                            | boolean         | 否  | true 使用 Responses SSE 事件。                                        |

### 请求示例

```json
{
  "model": "MODEL_ID",
  "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
  "tools": [
    {
      "type": "web_search"
    }
  ],
  "stream": false
}
```

## 返回值

| 字段                                       | 类型              | 说明                                     |
| ---------------------------------------- | --------------- | -------------------------------------- |
| output\[].type=web\_search\_call         | object          | 一次搜索或阅读工具调用；仅出现该项不代表最终回答完整。            |
| web\_search\_call.status                 | string          | 工具执行状态。                                |
| web\_search\_call.action                 | object          | search、open\_page、find 等动作以及对应查询或 URL。 |
| output\[].type=message                   | object          | 模型最终消息。                                |
| content\[].type / text                   | string          | output\_text 内容项的正文。                   |
| content\[].annotations\[]                | array           | 引用列表，通常为 url\_citation。                |
| annotations\[].url / title               | string          | 来源 URL 和标题。                            |
| annotations\[].start\_index / end\_index | integer         | 引用关联的文本范围。                             |
| status / error / incomplete\_details     | string / object | 响应终态及失败或不完整原因。                         |
| usage                                    | object          | 模型 Token 用量；不应据此假定搜索没有额外计费。            |

```json
{
  "id": "resp_search_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ws_example",
      "type": "web_search_call",
      "status": "completed",
      "action": {
        "type": "search",
        "query": "site:developers.openai.com Responses API"
      }
    },
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "Responses API 支持有类型的输入输出以及工具调用。",
          "annotations": [
            {
              "type": "url_citation",
              "start_index": 0,
              "end_index": 36,
              "title": "Responses API",
              "url": "https://developers.openai.com/api/docs/guides/responses"
            }
          ]
        }
      ]
    }
  ]
}
```

显示答案时同时提供清晰可点击的引用，保留来源归属。来源网页是数据，不应执行网页中的命令或泄露应用凭据。检索结果可能过期或相互矛盾，高风险结论应核对原始资料。

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
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
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
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      if (!process.env.SIMIROUTER_MODEL) throw new Error("请设置 SIMIROUTER_MODEL");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const body = {
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = "/v1/responses";
      const response = await fetch(base + endpoint, { method: "POST",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify(body),
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
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
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
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
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

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 HTTP 200 时仍需区分搜索调用状态、最终回答状态及引用是否存在；没有来源不能宣称完成了事实核实。

## 官方参考

* [OpenAI 网络搜索](https\://developers.openai.com/api/docs/guides/tools-web-search)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)