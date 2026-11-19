# 列出微调任务

分页查询 OpenAI 组织中当前密钥可见的微调任务。

**SimiRouter 暂不支持此接口。以下为 OpenAI 官方 API 参考，调用地址为 `api.openai.com`，需要 OpenAI 项目的密钥，不能使用 SimiRouter Key。**

## 接口说明

* **方法**：`GET`
* **接口地址**：`/v1/fine_tuning/jobs`
* **鉴权**：`Authorization: Bearer $OPENAI_API_KEY`
* **请求类型**：无请求体。

同步分页查询，不启动或等待训练。任务状态的含义与[获取任务详情](/simidoc/zh/apps/api/pending/fine-tuning/retrieve)相同。

## 请求参数

| 参数         | 类型               | 必填 | 说明                                                                          |
| ---------- | ---------------- | -- | --------------------------------------------------------------------------- |
| `after`    | string，查询        | 否  | 上页最后一个任务ID。                                                                 |
| `limit`    | integer，查询       | 否  | 每页任务数量，默认20。                                                                |
| `metadata` | object / null，查询 | 否  | 使用 `metadata[key]=value` 过滤；`metadata=null` 选择未设置 metadata 的任务。这两种形式不要同时使用。 |

## 返回值

| 字段         | 类型               | 说明                                |
| ---------- | ---------------- | --------------------------------- |
| `object`   | string           | 固定为 `list`。                       |
| `data`     | FineTuningJob\[] | 当前页的任务对象。                         |
| `has_more` | boolean          | 是否还有下一页；下一页以当前页最后一个任务ID作为`after`。 |

| 字段                 | 类型                | 说明                                                                                           |
| ------------------ | ----------------- | -------------------------------------------------------------------------------------------- |
| `id` / `object`    | string            | 任务 ID；对象类型固定为 `fine_tuning.job`。                                                             |
| `model`            | string            | 用于训练的基础模型。                                                                                   |
| `status`           | string            | `validating_files`、`queued`、`running`、`pausing`、`paused`、`succeeded`、`failed` 或 `cancelled`。 |
| `created_at`       | integer           | 创建时间，Unix 秒级时间戳。                                                                             |
| `finished_at`      | integer / null    | 完成时间；未结束时为空。                                                                                 |
| `estimated_finish` | integer / null，可选 | 预计结束时间，不是完成保证。                                                                               |
| `fine_tuned_model` | string / null     | 产出的模型 ID；尚未产出时为空。                                                                            |
| `training_file`    | string            | 训练集文件 ID。                                                                                    |
| `validation_file`  | string / null     | 验证集文件 ID；未设置时为空。                                                                             |
| `result_files`     | string\[]         | 结果文件 ID，可通过官方 Files API 下载。                                                                  |
| `trained_tokens`   | integer / null    | 训练处理的计费 token 数；进行中可能为空。                                                                     |
| `error`            | object / null     | 失败详情，包括 `code`、`message`、`param`；非参数错误的 `param` 可为空。                                         |
| `organization_id`  | string            | 任务所属组织。                                                                                      |
| `seed`             | integer / null    | 本次训练使用的随机种子。                                                                                 |
| `method`           | object / null，可选  | 微调方法及对应配置。                                                                                   |
| `hyperparameters`  | object / null，可选  | 监督微调的超参数兼容字段。                                                                                |
| `integrations`     | array / null，可选   | 启用的外部指标集成。                                                                                   |
| `metadata`         | object / null，可选  | 任务自定义键值信息。                                                                                   |

```json
{
  "object": "list",
  "data": [
    {
      "id": "ftjob-demo",
      "object": "fine_tuning.job",
      "model": "selected-base-model",
      "created_at": 1793491200,
      "finished_at": null,
      "fine_tuned_model": null,
      "status": "queued",
      "training_file": "file-training",
      "validation_file": null,
      "result_files": [],
      "trained_tokens": null,
      "error": null,
      "organization_id": "org-demo",
      "seed": null,
      "method": {
        "type": "supervised"
      },
      "metadata": {}
    }
  ],
  "has_more": false
}
```

## 代码调用

运行要求：Python 3、Node.js 20 或更新版本、curl、Go 1.20 或更新版本。各语言示例分别保存为 `.py`、`.cjs`、`.sh`、`.go` 文件后运行。

设置 `OPENAI_API_KEY`。示例获取前20条；若 `has_more=true`，将 `data` 最后一个对象的 `id` 填入下一页的 `after`。

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
        "https://api.openai.com/v1/fine_tuning/jobs?limit=20",
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

      const response = await fetch("https://api.openai.com/v1/fine_tuning/jobs?limit=20", {
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

    curl "https://api.openai.com/v1/fine_tuning/jobs?limit=20" \
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

    	req, err := http.NewRequest("GET", "https://api.openai.com/v1/fine_tuning/jobs?limit=20", nil)
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

* [OpenAI 微调任务列表](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/list)
* [OpenAI 错误码](https\://developers.openai.com/api/docs/guides/error-codes)