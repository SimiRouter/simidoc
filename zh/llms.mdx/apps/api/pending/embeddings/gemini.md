# Gemini 嵌入

**SimiRouter 暂不支持本接口。以下为 Google 官方直连参考。** 本页示例使用 Google AI Studio 的 Gemini API 密钥。Vertex AI 有独立的请求路径、项目配置和鉴权要求，须按 Google Cloud 的文档接入。

## 接口说明

`POST https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent`，使用 `x-goog-api-key: $GEMINI_API_KEY`。示例为文本输入；Gemini Embedding 2 也可处理模型支持的多模态内容，但不能将这些能力套给旧文本嵌入模型。

## 请求参数

| 字段                                      | 类型        | 必填 | 说明                                          |
| --------------------------------------- | --------- | -- | ------------------------------------------- |
| model（路径）                               | string    | 是  | models/gemini-embedding-2；必须是可用的嵌入模型。       |
| content                                 | object    | 是  | 要嵌入的 Content 对象，文本放 parts\[].text。          |
| content.parts                           | object\[] | 是  | 文本项，或该模型支持的 inline\_data / file\_data 多模态项。 |
| embedContentConfig                      | object    | 否  | 嵌入配置。支持项以模型版本和 API Reference 为准。            |
| embedContentConfig.outputDimensionality | integer   | 否  | 模型支持的输出维度；索引端和查询端保持一致。                      |

`gemini-embedding-2` 不支持 `embedContentConfig.taskType` / `title`，检索任务改用输入前缀：

* 查询：`task: search result | query: {content}`
* 文档：`title: {title} | text: {content}`；没有标题时用 `title: none`
* 对称任务：`task: {task} | query: {content}`

`taskType` / `title` 只适用于 `gemini-embedding-001`。`gemini-embedding-2` 不支持这些字段，请改用上面的输入前缀，不要依赖未定义的字段处理。embedding-2 与 embedding-001 的向量空间不兼容，索引端和查询端必须使用同一模型。

旧版顶层 `taskType`、`title`、`outputDimensionality` 属于旧配置入口；SDK 使用 config 配置对象，不要混用 SDK snake\_case 与 HTTP JSON 的 camelCase。

## 返回值

同步单次返回 `embedding.values` 浮点数组。`batchEmbedContents` 接收 requests 数组，返回 `embeddings[]` 按输入顺序对应。异步 `asyncBatchEmbedContent` 会返回长任务资源，需另行管理状态与输出文件，不是本页同步请求。

```json
{"embedding":{"values":[0.01,-0.02,0.03]}}
```

向量为节选示例。若缩短维度，应按模型指南处理归一化，不能把向量前三项当完整向量。

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

先设置 `GEMINI_API_KEY`。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent'
    headers = {'x-goog-api-key': os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'models/gemini-embedding-2', 'content': {'parts': [{'text': 'task: search result | query: 如何让文档检索理解语义？'}]}}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent";
      const headers = { "x-goog-api-key": process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "models/gemini-embedding-2",
        "content": {
          "parts": [
            {
              "text": "task: search result | query: 如何让文档检索理解语义？"
            }
          ]
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent", body); check(err)
      req.Header.Set("x-goog-api-key", os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## 错误码

| HTTP 状态               | 含义与处理                                     |
| --------------------- | ----------------------------------------- |
| 400                   | 请求字段或模型参数不合法，修正后再提交。                      |
| 401                   | API Key 缺失、无效或已过期。                        |
| 403                   | 当前项目或模型没有权限。                              |
| 404                   | 模型或路由不存在，检查地址与模型 ID。                      |
| 429                   | 速率或配额限制，区分余额不足与可退避重试的限流。                  |
| 500 / 502 / 503 / 504 | 服务或上游异常，保留请求 ID；对暂时故障做有限次退避，不要无限重试同一付费请求。 |

Google 错误对象使用 `error.code`、`error.status`、`error.message`，不要只按 HTTP 数字判断来源。本接口是同步请求，没有任务 ID 或轮询阶段。失败时不要把错误正文当作向量结果解析。

## 官方参考

[Google Embeddings guide](https\://ai.google.dev/gemini-api/docs/embeddings)、[Embedding API](https\://ai.google.dev/api/embeddings)。