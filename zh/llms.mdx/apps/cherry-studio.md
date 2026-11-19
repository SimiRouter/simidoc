# Cherry Studio配置

Cherry Studio 是支持多种模型提供商的桌面 AI 客户端。以下说明使用 SimiRouter API Key 接入。

* 官网地址：[https\://cherry-ai.com](https\://cherry-ai.com/)
* 下载地址：[https\://cherry-ai.com/download](https\://cherry-ai.com/download)
* 官方文档：[https\://docs.cherry-ai.com](https\://docs.cherry-ai.com)

## 接入 SimiRouter

### 方式一：从密钥页面打开

1. 安装并启动 Cherry Studio，在 SimiRouter [API 密钥管理](https://api.dwchainless.com/keys)页面找到要使用的密钥。
2. 点击该密钥右侧的 **…**，选择 **Cherry Studio**，并在浏览器提示时允许打开应用。
3. 在 Cherry Studio 中检查导入的 API 地址、密钥和模型；API 地址应为 `https://api.dwchainless.com`。保存后选择账户可用的模型。

### 方式二：手动配置

1. 在 [API 密钥管理](https://api.dwchainless.com/keys)页面复制 API 密钥；也可通过密钥右侧 **…** 中的「复制连接信息」获取地址。
2. 打开 Cherry Studio 的 **设置 → 模型服务**，选择 **New API**。API 地址填写 `https://api.dwchainless.com`，API 密钥粘贴刚才复制的密钥。
3. 点击「管理」添加或选择当前账户可用的模型，启用提供商后返回聊天页面使用。

![Cherry Studio 的 API 地址和密钥设置示意](/simidoc/assets/cherry_studio/simirouter-provider.png)

<Callout type="warn" title="保护密钥">
  不要将 API 密钥写入公开截图或分享给不可信的应用。发送一条简短测试消息后，可在 SimiRouter 使用日志核对模型和调用记录。
</Callout>

## 在 Cherry Studio 中画图

1. 添加当前账户可用、且 Cherry Studio 支持其接口格式的画图模型
   ![Cherry Studio 添加画图模型的设置页面](/simidoc/assets/cherry_studio/add_paint_models.png)

2. 在画图页面选择模型并输入提示词，生成后检查结果。
   ![Cherry Studio 画图页面与提示词输入区域](/simidoc/assets/cherry_studio/paint.png)