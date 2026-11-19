# 列出文件

分页查询当前 OpenAI 项目中可访问的文件。

**SimiRouter 暂不支持此接口。以下为 OpenAI 官方 API 参考，调用地址为 `api.openai.com`，需要 OpenAI 项目的密钥，不能使用 SimiRouter Key。**

## 接口说明

* **方法**：`GET`
* **接口地址**：`/v1/files`
* **鉴权**：`Authorization: Bearer $OPENAI_API_KEY`
* **请求类型**：无请求体。

同步返回当前页JSON；`has_more=true`时需要后续分页请求，单次调用不会自动返回全部文件。

## 请求参数

| 参数        | 类型         | 必填 | 说明                                |
| --------- | ---------- | -- | --------------------------------- |
| `after`   | string，查询  | 否  | 上一页最后一个文件的 ID。                    |
| `limit`   | integer，查询 | 否  | 每页1～10000条，默认10000；示例使用20。        |
| `order`   | string，查询  | 否  | 按创建时间排序：`asc` 或 `desc`，默认 `desc`。 |
| `purpose` | string，查询  | 否  | 只返回指定用途的文件。                       |

## 返回值

| 字段                     | 类型            | 说明               |
| ---------------------- | ------------- | ---------------- |
| `object`               | string        | 列表类型，通常为 `list`。 |
| `data`                 | FileObject\[] | 当前页文件；对象字段如下。    |
| `first_id` / `last_id` | string        | 当前页首尾文件 ID。      |
| `has_more`             | boolean       | 是否还有下一页。         |

| 字段               | 类型                   | 说明                                                                  |
| ---------------- | -------------------- | ------------------------------------------------------------------- |
| `id`             | string               | 文件 ID，供后续请求引用。                                                      |
| `object`         | string               | 固定为 `file`。                                                         |
| `bytes`          | integer / null       | 文件大小，单位为字节；尚未获取大小时可能为 null。                                         |
| `created_at`     | integer              | 创建时间，Unix 秒级时间戳。                                                    |
| `filename`       | string               | 上传时的文件名。                                                            |
| `purpose`        | string               | 文件用途，例如 `fine-tune`、`user_data`；生成的结果文件可能使用 `fine-tune-results` 等值。 |
| `expires_at`     | integer / null，可选    | 过期时间，Unix 秒级时间戳；未设置过期策略时可能为空。                                       |
| `status`         | string，已弃用           | 旧状态字段：`uploaded`、`processed` 或 `error`。不要用它替代消费端点自身的处理状态。           |
| `status_details` | string / null，可选，已弃用 | 旧状态说明；微调数据校验错误应读取任务的 `error`。                                       |

```json
{
  "object": "list",
  "data": [
    {
      "id": "file-demo",
      "object": "file",
      "bytes": 4096,
      "created_at": 1793491200,
      "filename": "training.jsonl",
      "purpose": "fine-tune",
      "expires_at": null
    }
  ],
  "first_id": "file-demo",
  "last_id": "file-demo",
  "has_more": false
}
```

## 代码调用

运行要求：Python 3、Node.js 20 或更新版本、curl、Go 1.20 或更新版本。各语言示例分别保存为 `.py`、`.cjs`、`.sh`、`.go` 文件后运行。

设置 `OPENAI_API_KEY`。示例获取前20条；下一页将上页 `last_id` 作为 `after` 查询参数。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    def required(name):
        value = os.environ.get(name)
        if not value:
            raise SystemExit(f"请设置 {name}")
        return value

    key = required("OPENAI_API_KEY")

    request = urllib.request.Request(
        "https://api.openai.com/v1/files?limit=20&order=desc",
        method="GET",
        data=None,
        headers={"Authorization": "Bearer " + key},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = response.read()
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    print(json.dumps(json.loads(result), ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    function required(name) {
      const value = process.env[name];
      if (!value) throw new Error(`请设置 ${name}`);
      return value;
    }
    async function main() {
      const key = required("OPENAI_API_KEY");

      const response = await fetch("https://api.openai.com/v1/files?limit=20&order=desc", {
        method: "GET",
        headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(JSON.stringify(await response.json(), null, 2));
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"

    curl "https://api.openai.com/v1/files?limit=20&order=desc" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request GET \
      --header "Authorization: Bearer $OPENAI_API_KEY"
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
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func required(name string) string {
    	value := os.Getenv(name)
    	if value == "" {
    		log.Fatal("请设置 " + name)
    	}
    	return value
    }
    func main() {
    	key := required("OPENAI_API_KEY")

    	req, err := http.NewRequest("GET", "https://api.openai.com/v1/files?limit=20&order=desc", nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 120 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	result, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, result)
    	}
    	fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## 错误码

以下为 OpenAI 官方直连请求的常见 HTTP 错误，不是 SimiRouter 的支持状态。

| HTTP 状态码      | 含义                | 处理方式                                       |
| ------------- | ----------------- | ------------------------------------------ |
| `400`         | 参数、文件用途或资源状态不符合要求 | 读取 `error.message` 和 `error.param`，修正后再提交。 |
| `401`         | 密钥无效或缺失           | 检查 OpenAI 密钥及其所属项目。                        |
| `403`         | 无权访问项目或资源         | 检查项目、组织和角色权限。                              |
| `404`         | 文件、任务或模型不存在       | 核对 ID，并使用资源所属项目的密钥。                        |
| `429`         | 速率限制或额度不足         | 区分限流与额度错误；限流时退避，额度不足时不要重复提交。               |
| `500` / `503` | 服务端异常或暂不可用        | 保留请求 ID；写入请求先核对是否已创建资源，避免重复上传或重复训练。        |

非成功响应通常包含 `error.message`、`error.type`、`error.param` 和 `error.code`；字段可能为空。

## 官方参考

* [OpenAI 文件列表](https\://developers.openai.com/api/reference/resources/files/methods/list)
* [OpenAI 错误码](https\://developers.openai.com/api/docs/guides/error-codes)