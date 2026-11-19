# Files API（不支持）

Files API 为 OpenAI 的文件资源管理接口。上传后获得文件 ID，可供微调、批处理或其他接受文件 ID 的官方端点引用。它不等同于模型对文件内容的识别能力。

**SimiRouter 暂不支持 Files API。以下页面保留 OpenAI 官方接口说明与直连示例，调用时必须使用 OpenAI 项目的密钥。**

## 概览

Files API 解决的是“一次上传、多次引用”：文件先作为独立资源存在，再由微调、批处理等端点按 ID 取用。它适合训练集、批处理请求体和需要反复读取的素材；单次对话里的附件不走这套接口，而是在请求内直接传入。

| 使用场景          | 上传时的标记              | 上传后还要做什么     |
| ------------- | ------------------- | ------------ |
| 监督微调训练数据      | `purpose=fine-tune` | 创建训练任务并轮询状态  |
| 批量请求或输出       | `purpose=batch`     | 创建批处理任务并轮询状态 |
| 其他接受文件 ID 的端点 | 按端点要求               | 以该端点文档为准     |

## 核心概念

* **文件 ID 与作用域**：ID 属于创建它的项目或组织，不能跨供应商、跨项目复用；把另一个服务的文件 ID 填进 OpenAI 请求会 404 或 403。
* **purpose 决定用途**：上传时的 `purpose` 表明数据给谁用（如 `fine-tune`、`batch`），消费端点还会各自校验格式、大小与行数。
* **生命周期**：上传成功只代表资源已存在；训练或批处理是否处理完成，要查对应任务的状态，不能凭上传结果判断。
* **内容与元数据分离**：文件对象里的 `filename`、`bytes`、`status` 是元数据；模型看到的内容由消费端点读取，二者不自动同步。

## 接口与执行方式

| 操作                        | 官方请求                              | 执行方式                   |
| ------------------------- | --------------------------------- | ---------------------- |
| [上传文件（不支持）](/simidoc/zh/apps/api/pending/files/upload)     | `POST /v1/files`                  | multipart 上传，同步返回文件对象。 |
| [获取文件信息（不支持）](/simidoc/zh/apps/api/pending/files/retrieve) | `GET /v1/files/{file_id}`         | 同步返回元数据。               |
| [列出文件（不支持）](/simidoc/zh/apps/api/pending/files/list)       | `GET /v1/files`                   | 同步分页查询。                |
| [获取文件内容（不支持）](/simidoc/zh/apps/api/pending/files/content)  | `GET /v1/files/{file_id}/content` | 下载文件字节，不是模型SSE。        |
| [删除文件（不支持）](/simidoc/zh/apps/api/pending/files/delete)     | `DELETE /v1/files/{file_id}`      | 删除资源，返回删除结果。           |

文件上传成功不代表其消费任务已完成。训练、批处理和索引的处理状态由各自端点查询。文件用途、格式和大小限制也由消费端点共同决定。

## 资源与安全

文件 ID 属于创建它的项目或组织，不能把另一个供应商或网关的文件 ID 直接用于 OpenAI。示例通过环境变量读取密钥；不得将训练集、个人信息或密钥写入公开仓库。

## 官方参考

* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files)
* [OpenAI 上传文件](https\://developers.openai.com/api/reference/resources/files/methods/create)