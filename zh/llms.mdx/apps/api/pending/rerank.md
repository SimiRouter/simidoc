# 文档重排序

## 接口说明

重排序把一个 query 与候选文档列表比较，返回按相关性排序的 index 和分数，不生成答案，也不返回嵌入向量。SimiRouter 的 `/v1/rerank` 是否可用需确认渠道；下面只演示 **Cohere 官方** `POST https://api.cohere.com/v2/rerank`，使用 `Authorization: Bearer $COHERE_API_KEY`。

## 请求参数

| 字段                    | 类型        | 必填 | 说明                                            |
| --------------------- | --------- | -- | --------------------------------------------- |
| model                 | string    | 是  | 例如 rerank-v5.0-pro，使用账户已开通的模型。                |
| query                 | string    | 是  | 搜索查询。                                         |
| documents             | string\[] | 是  | 候选文本数组；官方建议单次不超过 1000 条。结构化内容可先序列化为 YAML 字符串。 |
| top\_n                | integer   | 否  | 至少 1，不传则返回全部结果。                               |
| max\_tokens\_per\_doc | integer   | 否  | 默认 4096，长文档会截断。                               |
| relevant\_spans       | object    | 否  | v5 及更新模型可返回相关文本区间。                            |
| priority              | integer   | 否  | 0–999，默认 0；数字越小优先级越高。                         |

Cohere v2 的 documents 是字符串数组，不能混入未定义对象；`return_documents` 属于其他协议版本，不在本示例里发送。

## 返回值

`results[]` 依相关性排序：`index` 指向原文档下标，`relevance_score` 为相关性分数；启用并支持时返回 `relevant_spans[]`。分数不是正确率或可跨模型比较的统一概率。`meta.billed_units` 记录计量。

```json
{"results":[{"index":1,"relevance_score":0.95},{"index":0,"relevance_score":0.12}],"id":"request_example","meta":{"api_version":{"version":"2"}}}
```

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

设置 Cohere 官方 `COHERE_API_KEY`。示例 top\_n 为正数，不使用空 query 或空文档。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.cohere.com/v2/rerank'
    headers = {'Authorization': 'Bearer ' + os.environ['COHERE_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'rerank-v5.0-pro', 'query': '法国首都是哪里？', 'documents': ['柏林是德国首都。', '巴黎是法国首都。'], 'top_n': 2}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.cohere.com/v2/rerank";
      const headers = { "Authorization": "Bearer " + process.env.COHERE_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
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
    curl "https://api.cohere.com/v2/rerank" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $COHERE_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "rerank-v5.0-pro",
        "query": "法国首都是哪里？",
        "documents": [
          "柏林是德国首都。",
          "巴黎是法国首都。"
        ],
        "top_n": 2
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
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
    }`)
      req, err := http.NewRequest("POST", "https://api.cohere.com/v2/rerank", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("COHERE_API_KEY"))
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

| HTTP 状态               | 说明                     |
| --------------------- | ---------------------- |
| 400 / 422             | 参数或模型不接受的输入。           |
| 401 / 498             | 认证失败或 token 无效。        |
| 403 / 404             | 权限不足或资源不存在。            |
| 429                   | 限流，检查配额并有限退避。          |
| 499                   | 客户端已关闭请求。              |
| 500 / 501 / 503 / 504 | 服务内部错误、未实现或超时；保留请求 ID。 |

## 官方参考

[Cohere Rerank v2](https\://docs.cohere.com/reference/rerank)。