# 内容审核

## 接口说明

`POST https://api.openai.com/v1/moderations` 同步评估文本或图像的安全分类，使用 `Authorization: Bearer $OPENAI_API_KEY`。SimiRouter 路由、模型和权限需另行确认，下方为 OpenAI 官方直连示例。

审核结果是风险信号，不是法律合规结论，也不能保证没有漏判。图像与文本支持的分类可能不同，必须查看 category\_applied\_input\_types，不能用某类不支持的输入推导安全。

## 请求参数

| 字段                      | 类型                             | 必填 | 说明                                        |
| ----------------------- | ------------------------------ | -- | ----------------------------------------- |
| model                   | string                         | 否  | 如 omni-moderation-latest；明确固定模型可减少别名更新影响。 |
| input                   | string / string\[] / object\[] | 是  | 文本或多模态内容项。                                |
| input\[].type           | string                         | 条件 | text 或 image\_url。                        |
| input\[].text           | string                         | 条件 | 文本审核内容。                                   |
| input\[].image\_url.url | string                         | 条件 | 图像 URL 或 data URL，须符合模型输入要求。              |

## 返回值

| 字段                                       | 说明                  |
| ---------------------------------------- | ------------------- |
| `id` / `model`                           | 请求标识与审核模型。          |
| `results[].flagged`                      | 任一分类是否触发风险。         |
| `results[].categories`                   | 按分类返回布尔值。           |
| `results[].category_scores`              | 分类分数，非人工判断或跨模型恒定阈值。 |
| `results[].category_applied_input_types` | 各分类适用的输入类型。         |

```json
{"id":"modr_example","model":"omni-moderation-latest","results":[{"flagged":false,"categories":{},"category_scores":{},"category_applied_input_types":{}}]}
```

示例省略分类键，真实响应包含分类明细。应用应保存必要的风险证据而非无期限保留全部用户原文。

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

设置 `OPENAI_API_KEY`。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/moderations'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'omni-moderation-latest', 'input': '这是一段需要进行安全审核的示例文本。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/moderations";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
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
    curl "https://api.openai.com/v1/moderations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "omni-moderation-latest",
        "input": "这是一段需要进行安全审核的示例文本。"
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
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/moderations", body); check(err)
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

| HTTP 状态               | 含义与处理                           |
| --------------------- | ------------------------------- |
| 400 / 422             | 请求字段、文件格式或模型参数不合法，修正后再提交。       |
| 401                   | API Key 缺失、无效或已过期。              |
| 403                   | 当前项目或模型没有权限。                    |
| 404                   | 模型或路由不存在，检查地址与项目归属。             |
| 413 / 415             | 上传过大或媒体类型不受支持。                  |
| 429                   | 速率或配额限制，区分余额不足与可退避重试的限流。        |
| 500 / 502 / 503 / 504 | 服务或上游异常，保留请求 ID，检查响应正文后再决定是否重试。 |

错误正文中的 `error.message`、`error.type`、`error.code` 比 HTTP 状态提供更具体的原因。不要把错误正文当作审核结果保存。

## 官方参考

[OpenAI Create moderation](https\://developers.openai.com/api/reference/resources/moderations/methods/create)。