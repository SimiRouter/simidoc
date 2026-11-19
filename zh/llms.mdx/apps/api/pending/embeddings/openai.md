# OpenAI 嵌入

**SimiRouter 暂不支持本接口。以下为 OpenAI 官方直连参考。**

## 接口说明

`POST https://api.openai.com/v1/embeddings`，`Content-Type: application/json`，`Authorization: Bearer $OPENAI_API_KEY`。一次请求返回完整向量，不支持 SSE。

## 请求参数

| 字段               | 类型                           | 必填 | 说明                                                                  |
| ---------------- | ---------------------------- | -- | ------------------------------------------------------------------- |
| model            | string                       | 是  | text-embedding-3-small、text-embedding-3-large 等账户可用嵌入模型。            |
| input            | string / string\[] / token数组 | 是  | 非空文本或 token 输入；数组最多 2048 项，单输入最多 8192 tokens，单请求合计最多 300000 tokens。 |
| dimensions       | integer                      | 否  | 正整数，text-embedding-3 及后续支持的模型可缩短维度。                                 |
| encoding\_format | string                       | 否  | float（默认）返回浮点数组，base64 返回编码字符串。                                     |
| user             | string                       | 否  | 不包含个人明文信息的终端用户标识。                                                   |

## 返回值

| 字段                                           | 说明                                     |
| -------------------------------------------- | -------------------------------------- |
| `object`                                     | list。                                  |
| `data[].object`                              | embedding。                             |
| `data[].index`                               | 对应输入数组的位置。                             |
| `data[].embedding`                           | 向量数组或 Base64 字符串，取决于 encoding\_format。 |
| `model`                                      | 使用的模型。                                 |
| `usage.prompt_tokens` / `usage.total_tokens` | token 统计。                              |

以下省略向量中间元素，仅说明结构：

```json
{"object":"list","data":[{"object":"embedding","index":0,"embedding":[0.01,-0.02]}],"model":"text-embedding-3-small","usage":{"prompt_tokens":3,"total_tokens":3}}
```

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

设置 `OPENAI_API_KEY`。示例为同步批量输入，结果按 index 与两条输入对应。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/embeddings'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'text-embedding-3-small', 'input': ['语义搜索', '文档检索'], 'encoding_format': 'float'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/embeddings";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
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
    curl "https://api.openai.com/v1/embeddings" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "text-embedding-3-small",
        "input": [
          "语义搜索",
          "文档检索"
        ],
        "encoding_format": "float"
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
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/embeddings", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

错误正文中的 `error.message`、`error.type`、`error.code` 比 HTTP 状态提供更具体的原因。本接口是同步请求，没有任务 ID 或轮询阶段。失败时不要把错误正文当作向量结果解析。

## 官方参考

[OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings/methods/create)、[Embeddings guide](https\://developers.openai.com/api/docs/guides/embeddings)。