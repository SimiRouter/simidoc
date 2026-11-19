# 微调（不支持）

模型微调通过训练数据调整基础模型的行为，产生可用于推理的新模型。OpenAI 提供监督微调、直接偏好优化（DPO）和强化微调等方法；可用方法取决于所选基础模型。

**SimiRouter 暂不支持微调。以下页面保留 OpenAI 官方接口说明与直连示例，调用时必须使用 OpenAI 项目的密钥。训练可能产生费用。**

OpenAI 当前正在逐步停止自助微调服务：新用户无法创建训练任务；符合资格的既有用户可创建任务至 **2027 年 1 月 6 日**，除非基础模型更早停用。已创建的微调模型只能在其基础模型停用前继续推理。资格、模型和时间表会变化，使用前请以[官方停用时间表](https\://developers.openai.com/api/docs/deprecations)为准。

## 概览

微调改的是模型权重，不是提示词。它适合稳定的格式约束、固定语气和领域表达；不适合注入随时会变的知识——那类需求用检索或更长的系统提示成本更低。验证效果必须用没有参与训练的独立样本。

| 你要做的事    | 输入               | 输出                       | 执行方式        |
| -------- | ---------------- | ------------------------ | ----------- |
| 训练一个专用模型 | JSONL 训练集 + 基础模型 | 任务对象与 `fine_tuned_model` | 后台异步，轮询状态   |
| 观察训练过程   | 任务 ID            | 事件日志与指标                  | 分页查询，不是 SSE |
| 停止训练     | 任务 ID            | 已取消的任务对象                 | 同步请求        |

## 核心概念

* **基础模型**：决定可用方法与价格。不同基础模型支持的方法和参数不同，选错方法会在创建任务时被拒绝。
* **训练集与验证集**：JSONL，每行一条对话样本；官方最低 10 条，通常从 50 条开始，50 到 100 条常能看到明显改善。验证集要单独准备，不能与训练集重叠。
* **任务状态**：`queued`、`running`、`succeeded`、`failed`、`cancelled`。只有 `succeeded` 才产出可推理的新模型；`failed` 要读 `error` 判断是数据问题还是参数问题。
* **产出模型**：成功后返回 `fine_tuned_model` 标识，用它替代基础模型发起推理。模型有独立生命周期，需要时自行删除。
* **成本**：训练按 Token 计费，产出模型在保存期内可能产生存储费用；用小样本试跑再扩大，比一次提交全量数据更可控。

## 接口与执行方式

| 操作                        | 官方请求                                                    | 执行方式            |
| ------------------------- | ------------------------------------------------------- | --------------- |
| [创建任务（不支持）](/simidoc/zh/apps/api/pending/fine-tuning/create)     | `POST /v1/fine_tuning/jobs`                             | 返回任务对象，后台异步训练。  |
| [获取任务详情（不支持）](/simidoc/zh/apps/api/pending/fine-tuning/retrieve) | `GET /v1/fine_tuning/jobs/{fine_tuning_job_id}`         | 同步查询状态、输出模型及错误。 |
| [列出任务（不支持）](/simidoc/zh/apps/api/pending/fine-tuning/list)       | `GET /v1/fine_tuning/jobs`                              | 同步分页查询。         |
| [获取任务事件（不支持）](/simidoc/zh/apps/api/pending/fine-tuning/events)   | `GET /v1/fine_tuning/jobs/{fine_tuning_job_id}/events`  | 分页日志，不是SSE。     |
| [取消任务（不支持）](/simidoc/zh/apps/api/pending/fine-tuning/cancel)     | `POST /v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel` | 停止任务并返回任务对象。    |

## 基本流程

1. 按所选微调方法准备JSONL训练集，独立准备验证集。
2. 通过[官方文件上传接口](/simidoc/zh/apps/api/pending/files/upload)以 `purpose=fine-tune` 上传数据。
3. 选择支持该方法的模型，创建任务并保存任务ID。
4. 查询任务状态和事件；`succeeded`表示成功，`failed`需读取`error`，`cancelled`表示已取消。
5. 训练成功后使用返回的 `fine_tuned_model` 进行推理，并通过独立评估集验证效果。

创建请求成功不等于训练成功；取消任务也不代表已发生用量被撤销。不要因网络超时直接重复创建同一训练任务。

## 官方参考

* [OpenAI 模型优化指南](https\://developers.openai.com/api/docs/guides/model-optimization)
* [OpenAI 监督微调指南](https\://developers.openai.com/api/docs/guides/supervised-fine-tuning)
* [OpenAI Fine-tuning Jobs API](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs)