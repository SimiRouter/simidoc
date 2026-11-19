# LangBot配置

LangBot 将连接信息保存在提供商中，再由具体模型引用。通过 OpenAI 兼容提供商可配置 SimiRouter 聊天模型。

## 创建提供商和模型

1. 按 [LangBot 官方文档](https\://docs.langbot.app/)安装并启动应用。
2. 从 SimiRouter [API 密钥管理](https://api.dwchainless.com/keys)复制密钥。
3. 在 LangBot 的模型页面添加对话模型，选择 OpenAI 兼容供应商，或创建对应提供商。
4. 配置连接信息：

| 字段                | 内容                               |
| ----------------- | -------------------------------- |
| Base URL / 请求 URL | `https://api.dwchainless.com/v1` |
| API Key           | SimiRouter API Key               |
| 模型名称              | 账户可用的完整模型 ID                     |

模型继承所属提供商的地址和密钥。按实际模型能力开启视觉或工具使用选项；这些开关不会赋予模型原本不具备的能力。

## 绑定流水线

在流水线中选择刚添加的模型，保存后通过调试对话或绑定的机器人发送消息。到 SimiRouter [使用日志](https://api.dwchainless.com/usage-logs/common)核对请求的时间、模型和消耗。

## 知识库与嵌入（不支持）

LangBot 的知识库需要嵌入模型。SimiRouter 目前不支持嵌入集成，不能将本站聊天模型配置当作知识库向量服务。需要使用知识库时，应另行配置 LangBot 支持的嵌入提供商，或按其官方说明选择内置方案。

## 官方参考

[LangBot 模型配置](https\://docs.langbot.app/zh/usage/models/readme)介绍提供商、聊天模型、嵌入模型和流水线的关系。