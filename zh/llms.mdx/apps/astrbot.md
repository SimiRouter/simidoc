# AstrBot配置

AstrBot 是支持多种消息平台的开源 AI 助手。本教程使用 OpenAI 兼容协议连接 SimiRouter。

## 添加提供商

1. 安装并启动 AstrBot；安装步骤见 [AstrBot 官方文档](https\://docs.astrbot.app/)。
2. 在 SimiRouter 的 [API 密钥管理](https://api.dwchainless.com/keys)创建密钥。
3. 打开 AstrBot 管理面板的 **Providers → Chat Completion**，点击 **Add**，选择 **OpenAI Compatible**。旧版本可能显示为「模型提供商 → 新增 → OpenAI」。
4. 填写以下字段并保存：

| 字段           | 内容                               |
| ------------ | -------------------------------- |
| 提供商名称        | `SimiRouter`                     |
| API Base URL | `https://api.dwchainless.com/v1` |
| API Key      | SimiRouter API Key               |
| Model        | 从[模型广场](https://api.dwchainless.com/zh/pricing/)复制账户可用的完整模型 ID  |

点击 **Save and Fetch Models** 获取模型，使用模型右侧的 `+` 添加并启用。也可通过 **Custom Model** 手动填写模型 ID。

## 设置默认聊天模型

进入 **Config → AI → Model**，将 **Chat Model** 设为刚添加的模型，保存配置。使用 **Test Model** 或发送一条简短消息测试，再到 SimiRouter [使用日志](https://api.dwchainless.com/usage-logs/common)核对调用。

图片理解和工具调用需要 AstrBot、所选模型及渠道同时支持；文本对话成功不代表所有扩展能力均可用。

## 官方参考

* [AstrBot 模型提供商配置](https\://docs.astrbot.app/en/providers/llm.html)
* [AstrBot 接入模型服务](https\://docs.astrbot.app/en/providers/start.html)