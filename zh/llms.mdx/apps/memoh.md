# Memoh配置

Memoh 是支持独立工作环境和长期记忆的开源多智能体平台。聊天模型与语音、转录模型使用不同的客户端类型，不能共用同一种协议配置。

## 安装 Memoh

按 [Memoh 官方部署说明](https\://docs.memoh.ai/self-hosted/docker)安装当前版本。首次登录后完成账户安全设置；不要沿用旧版教程中的默认密码。

## 添加提供商

1. 在 SimiRouter [API 密钥管理](https://api.dwchainless.com/keys)创建密钥。
2. 打开 Memoh 设置侧栏的 **Models** 页面，选择 **Add Provider**。
3. 使用 OpenAI Chat Completions 模板，或创建自定义提供商：

| 字段          | 内容                               |
| ----------- | -------------------------------- |
| Name        | `SimiRouter`                     |
| Client Type | `openai-completions`             |
| Base URL    | `https://api.dwchainless.com/v1` |
| API Key     | SimiRouter API Key               |

`openai-responses` 对应 Responses 协议，`openai-completions` 对应 Chat Completions；不要仅凭名称将后者当作旧文本补全接口。OAuth 登录类型不能代替 SimiRouter API Key 提供商。

## 添加并启用模型

在提供商详情中点击 **Import Models** 导入，或手动填写账户可用的模型 ID。批量导入的模型默认可能未启用，需要打开模型开关，再到机器人设置中选择该聊天模型。

发送一条简短消息，并到 SimiRouter [使用日志](https://api.dwchainless.com/usage-logs/common)核对对应请求。Memoh 的记忆、搜索等功能可能需要额外提供商；SimiRouter 目前不支持嵌入集成，不能使用聊天模型代替向量模型。

## 官方参考

* [Memoh 提供商与模型](https\://docs.memoh.ai/integrations/providers/llm)
* [Memoh 项目](https\://github.com/felinics/Memoh)