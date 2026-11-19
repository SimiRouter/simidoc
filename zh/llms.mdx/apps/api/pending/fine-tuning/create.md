# 创建微调任务

提交训练集和基础模型配置，在 OpenAI 创建异步微调任务。

**SimiRouter 暂不支持此接口。以下为 OpenAI 官方 API 参考，调用地址为 `api.openai.com`，需要 OpenAI 项目的密钥，不能使用 SimiRouter Key。**

OpenAI 的自助微调服务正在逐步停止：新用户不能创建任务；符合资格的既有用户可创建至 **2027 年 1 月 6 日**，基础模型可能更早停用。请在提交前查看[官方停用时间表](https\://developers.openai.com/api/docs/deprecations)。

## 接口说明

* **方法**：`POST`
* **接口地址**：`/v1/fine_tuning/jobs`
* **鉴权**：`Authorization: Bearer $OPENAI_API_KEY`
* **请求类型**：`application/json`。

创建请求返回任务对象，训练随后在服务端运行。`200`或`queued`不代表训练成功；使用[获取任务详情](/simidoc/zh/apps/api/pending/fine-tuning/retrieve)查询最终 `status`，使用[获取事件](/simidoc/zh/apps/api/pending/fine-tuning/events)查看进度。路径为 `/v1/fine_tuning/jobs`，不是旧版 `/v1/fine-tunes`。

## 请求参数

| 参数                                  | 类型             | 必填 | 说明                                                                               |
| ----------------------------------- | -------------- | -- | -------------------------------------------------------------------------------- |
| `model`                             | string         | 是  | 支持对应微调方法的基础模型 ID。                                                                |
| `training_file`                     | string         | 是  | 以 `purpose=fine-tune` 上传的JSONL训练集文件ID。                                           |
| `validation_file`                   | string / null  | 否  | 独立验证集的文件 ID，数据不要与训练集重复。                                                          |
| `method`                            | object         | 否  | `type` 为 `supervised`、`dpo` 或 `reinforcement`，并填写同名配置对象；方法必须与模型兼容。               |
| `method.supervised.hyperparameters` | object         | 否  | `batch_size`：auto或1～256；`learning_rate_multiplier`：auto或正数；`n_epochs`：auto或1～50。 |
| `method.dpo.hyperparameters`        | object         | 否  | DPO训练超参数，包含 `beta`；不要直接套用监督训练的数据格式。                                              |
| `method.reinforcement`              | object         | 否  | 强化微调配置，包含 `grader` 与该方法的超参数。                                                     |
| `suffix`                            | string / null  | 否  | 产出模型名称的自定义后缀，最多64字符。                                                             |
| `seed`                              | integer / null | 否  | 随机种子；相同种子不构成完全可重复的保证。                                                            |
| `metadata`                          | object / null  | 否  | 最多16对键值；键最长64字符，值最长512字符。                                                        |
| `integrations`                      | array / null   | 否  | 外部训练指标集成，例如带项目名的 `wandb` 配置。                                                     |
| `hyperparameters`                   | object，已弃用     | 否  | 旧顶层写法，新增配置应放到 `method` 中。                                                        |

请求体示例中的模型和文件 ID 是结构示例，实际调用须使用所属项目的资源。

```json
{
  "model": "selected-base-model",
  "training_file": "file-training",
  "method": {
    "type": "supervised",
    "supervised": {
      "hyperparameters": {
        "n_epochs": 2
      }
    }
  }
}
```

## 返回值

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

响应示例（只展示核心字段，非实际任务）：

```json
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
```

## 代码调用

运行要求：Python 3、Node.js 20 或更新版本、curl、Go 1.20 或更新版本。各语言示例分别保存为 `.py`、`.cjs`、`.sh`、`.go` 文件后运行。

设置 `OPENAI_API_KEY`、`OPENAI_FINE_TUNING_MODEL` 和 `OPENAI_TRAINING_FILE_ID`。curl 示例使用 Python 3 生成 JSON。基础模型必须在官方项目中开放微调。训练会产生费用；只在确定数据、方法和预算后执行，不要把创建任务用于连通性测试。

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
    model = required("OPENAI_FINE_TUNING_MODEL")
    training_file = required("OPENAI_TRAINING_FILE_ID")
    payload = {"model": model, "training_file": training_file}
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        "https://api.openai.com/v1/fine_tuning/jobs",
        method="POST",
        data=data,
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
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
      const model = required("OPENAI_FINE_TUNING_MODEL");
      const training_file = required("OPENAI_TRAINING_FILE_ID");
      const body = JSON.stringify({"model": model, "training_file": training_file});
      const response = await fetch("https://api.openai.com/v1/fine_tuning/jobs", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body,
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
    : "${OPENAI_FINE_TUNING_MODEL:?请设置 OPENAI_FINE_TUNING_MODEL}"
    : "${OPENAI_TRAINING_FILE_ID:?请设置 OPENAI_TRAINING_FILE_ID}"
    payload=$(python3 - <<'JSON'
    import json, os
    print(json.dumps({"model": os.environ["OPENAI_FINE_TUNING_MODEL"], "training_file": os.environ["OPENAI_TRAINING_FILE_ID"]}))
    JSON
    )

    curl "https://api.openai.com/v1/fine_tuning/jobs" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request POST \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --header "Content-Type: application/json" \
      --data "$payload"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"bytes"
    	"encoding/json"
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
    	model := required("OPENAI_FINE_TUNING_MODEL")
    	training_file := required("OPENAI_TRAINING_FILE_ID")
    	payload, err := json.Marshal(map[string]any{"model": model, "training_file": training_file})
    	check(err)
    	req, err := http.NewRequest("POST", "https://api.openai.com/v1/fine_tuning/jobs", bytes.NewReader(payload))
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	req.Header.Set("Content-Type", "application/json")
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

* [OpenAI 创建微调任务](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/create)
* [OpenAI 模型优化指南](https\://developers.openai.com/api/docs/guides/model-optimization)
* [OpenAI 错误码](https\://developers.openai.com/api/docs/guides/error-codes)