# DeepChat配置

DeepChat 是支持云端与本地模型的开源 AI 客户端。工具调用等扩展能力需所选模型和提供商支持。

* 官网地址：[https\://deepchat.thinkinai.xyz](https\://deepchat.thinkinai.xyz)
* GitHub 仓库：[https\://github.com/ThinkInAIXYZ/deepchat](https\://github.com/ThinkInAIXYZ/deepchat)
* 下载地址：[https\://deepchat.thinkinai.xyz/#/download](https\://deepchat.thinkinai.xyz/#/download)

## 手动接入 SimiRouter

1. 在 SimiRouter 的 [API 密钥管理](https://api.dwchainless.com/keys)页面复制要使用的 API Key。

2. 打开 DeepChat 的 **设置 → 服务商设置**，选择 New API 或添加兼容服务商。**API URL 填写 `https://api.dwchainless.com`**，API Key 粘贴刚才复制的密钥。

   ![DeepChat 中填写 SimiRouter 地址和 API Key 的示意](/simidoc/assets/deepchat/simirouter-manual.png)

3. 验证密钥、刷新或添加模型，启用服务商并选择账户可用的模型。发送一条简短消息后，可在 SimiRouter 使用日志核对对应调用记录。

<Callout type="warn" title="保护密钥">
  请勿把 API Key 放入公开截图或分享给不可信的应用。客户端界面可能随版本变化，请以实际显示的字段为准。
</Callout>

## 相关链接

* [DeepChat GitHub 仓库](https\://github.com/ThinkInAIXYZ/deepchat)
* [DeepChat 下载页面](https\://deepchat.thinkinai.xyz/#/download)