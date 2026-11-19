# Chatbox AI 配置

本教程以 Chatbox AI 1.21.1 桌面界面为例，通过内置的 **OpenAI** 模型提供方连接 SimiRouter。其他版本的界面名称和位置可能不同；下方截图为中文界面示意。

<Callout type="warn" title="保护 API 密钥">
  API 密钥是调用凭证，不要分享给他人或展示在公开截图中。连接检查和实际对话可能产生费用，请先确认账户额度和模型价格。
</Callout>

## 准备工作

1. 从 [Chatbox AI 官网](https\://chatboxai.app/)下载并安装客户端。
2. 登录 SimiRouter，在 [API 密钥管理](https://api.dwchainless.com/keys)页面创建或复制密钥，并确认账户有使用目标模型的权限和额度。

![SimiRouter 的 API 密钥管理页面，密钥信息已遮挡](/simidoc/assets/chatbox/03a-create-api-key.png)

## 配置连接

### 1. 打开设置并选择提供方

在 Chatbox 主界面点击左下角 **设置**。

![打开 Chatbox 设置](/simidoc/assets/chatbox/01-open-settings.png)

进入 **模型提供方**，选择 **OpenAI**。本教程使用 API 密钥，无需通过 OAuth 登录。此操作会更改 OpenAI 提供方的配置；如果你已用它连接其他服务，请先记录原有配置，避免意外覆盖。

![在模型提供方中选择 OpenAI](/simidoc/assets/chatbox/02-select-openai.png)

### 2. 填写 API 密钥和主机

| 配置项    | 填写内容                                              |
| ------ | ------------------------------------------------- |
| API 密钥 | 粘贴刚才复制的 SimiRouter 密钥                             |
| API 主机 | `https://api.dwchainless.com`                     |
| 请求地址预览 | `https://api.dwchainless.com/v1/chat/completions` |

API 主机按上表填写，保留默认 API 路径，不要在主机后再手动拼接接口路径。如果之前自定义过 API 路径，请恢复默认并检查预览地址。

![在 OpenAI 提供方中填写 API 密钥和主机](/simidoc/assets/chatbox/03b-fill-api-fields.png)

### 3. 获取并添加模型

在模型区域点击 **获取**，搜索并点击模型右侧的 **+** 添加。如果无法获取列表，可使用 **新建**，手动填写账户可用的准确模型 ID。列表中的模型不一定都已对当前密钥开放，请以账户权限和模型列表为准。

![搜索并添加模型](/simidoc/assets/chatbox/04-add-models.png)

### 4. 检查连接并开始对话

对要使用的模型点击 **检查**。测试结果为“连接成功”时，仍建议发送一条简短消息验证实际对话。部分模型只支持文本；图片或工具调用检查未通过，不一定意味着文本不可用。

![示例模型的连接检查结果](/simidoc/assets/chatbox/05-check-success.png)

关闭设置，点击 **新对话**，在输入框旁的模型选择菜单中选择刚添加的 OpenAI 分组模型，发送一条简短消息。收到回复后，可在 SimiRouter 使用日志中核对请求和实际模型。

![新建对话并选择添加的模型](/simidoc/assets/chatbox/06-new-chat-select-model.png)

## 常见问题

* **获取模型失败：** 检查网络、主机地址和密钥；也可使用准确模型 ID 手动添加。
* **401 或认证失败：** 检查密钥是否完整、有效，前后是否有空格；必要时重新创建密钥。
* **404 或路径错误：** 核对请求地址预览，恢复默认 API 路径，避免重复拼接路径。
* **模型不存在或无法对话：** 核对实际模型 ID、密钥权限和账户额度，并确认对话中选择了正确模型。
* **图片或工具调用失败：** 检查模型和接口是否支持相应能力；仅需文本时，可单独验证文本请求。

参考：[Chatbox OpenAI 地址与路径处理](https\://github.com/chatboxai/chatbox/blob/main/src/shared/utils/llm_utils.ts)。