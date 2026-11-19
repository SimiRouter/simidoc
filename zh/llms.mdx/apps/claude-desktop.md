# Claude Desktop 设置

使用 CC Switch 的**模型映射**，可以在 Claude Desktop 中选择一个菜单名称，由 CC Switch 将请求转发给 SimiRouter 上对应的实际模型。下面的流程基于 macOS 界面；其他系统或软件版本的界面名称可能略有不同。

## 准备工作

1. 安装并打开较新版本的 Claude Desktop 客户端。
2. 安装支持 **Claude Desktop** 的 [CC Switch](https\://github.com/farion1231/cc-switch/releases/latest)，并打开它。
3. 登录 SimiRouter，在 [API 密钥管理](https://api.dwchainless.com/keys)页面创建或复制一个可用的 API Key。确认该密钥有权限使用你想配置的模型。

<Callout type="info" title="">
  API Key 是调用凭证，请妥善保管，不要放进公开截图或分享给他人。模型名称及可用权限以 SimiRouter 控制台为准。
</Callout>

## 通过 CC Switch 配置模型映射

### 1. 添加 Claude Desktop 自定义供应商

在 CC Switch 左侧选择 **Claude Desktop**，点击 **添加供应商**，然后选择 **自定义配置**。注意选择的是 Claude Desktop，而不是 Claude Code。

![在 CC Switch 中为 Claude Desktop 添加自定义供应商](/simidoc/assets/claude-desktop/cc-switch-add-provider.png)

### 2. 填写连接信息与模型映射

在自定义配置页面填写：

| 字段      | 填写内容                                           |
| ------- | ---------------------------------------------- |
| 名称      | `SimiRouter`，也可以自定义                            |
| API Key | 刚才复制的 SimiRouter API Key                       |
| 请求地址    | `https://api.dwchainless.com`，末尾不加 `/` 或 `/v1` |
| 接入方式    | 选择 **模型映射**                                    |
| 上游格式    | 选择 **Anthropic Messages（原生）**                  |

在下方的**模型映射**中，为需要使用的角色填写「菜单显示名」和「实际请求模型」。例如：

| 模型角色   | 菜单显示名               | 实际请求模型        |
| ------ | ------------------- | ------------- |
| Sonnet | `claude-sonnet-5-5` | `gpt-6-astra` |
| Opus   | `claude-opus-5-5`   | `gpt-6-astra` |
| Haiku  | `claude-haiku-5-5`  | `gpt-6.1-sol` |

**菜单显示名只是 Claude Desktop 中的名称；真正调用的是右侧「实际请求模型」。** 比如选择显示为 `claude-sonnet-5-5` 的选项时，上例实际请求的是 `gpt-6-astra`，并不是 Claude Sonnet。请按自己的账户权限，将实际请求模型换成 SimiRouter 中可用的准确模型 ID；也可以把显示名设置为便于识别的名称。不同版本的角色列表可能不同，以界面为准。

截图中的 `1M` 选项仅用于向客户端声明上下文能力，**不要因为示例勾选就照搬**；只有在实际模型和接口均支持时才勾选。填写完成后点击 **添加**。

![在 CC Switch 中填写模型映射，菜单显示名和实际请求模型分别位于两列](/simidoc/assets/claude-desktop/cc-switch-model-mapping.png)

截图中的 API Key 已隐藏；实际配置时请填写自己的密钥。

### 3. 检测并启用路由

1. 回到供应商列表，在 SimiRouter 卡片右侧点击 **… → 检测连通**，查看检测结果。
2. 检测正常后，点击 SimiRouter 卡片右侧的启用按钮（▶），按界面提示启用路由。卡片显示 **路由中**表示已经选中该供应商。
3. 保持 CC Switch 和本地路由服务运行。切换路由或修改模型映射后，完全退出并重新打开 Claude Desktop，使配置重新加载。

![在供应商菜单中选择检测连通](/simidoc/assets/claude-desktop/cc-switch-test-connection.png)

![SimiRouter 供应商显示路由中](/simidoc/assets/claude-desktop/cc-switch-routing.png)

### 4. 在 Claude Desktop 启用开发者模式

打开 **Claude Desktop 桌面版**，在顶部菜单栏选择 **Help → Troubleshooting → Enable Developer Mode**。如果此前已启用，可跳过此步。

![在 Claude Desktop 的 Help 菜单中启用开发者模式](/simidoc/assets/claude-desktop/claude-enable-developer-mode.png)

### 5. 检查 CC Switch 推理配置

1. 点击 Claude Desktop 左下角的账户菜单，选择 **Inference configuration**，打开 **Configure third-party inference**。
2. 查看右上角配置列表，确认选择的是 **CC Switch**；如果有多个配置，请选择 CC Switch。若显示 **applied**，表示该配置已应用；如有未应用的更改，按界面提示点击 **Apply Changes**。
3. 在 **Connection** 页面点击 **Test Connection**。出现绿色成功提示后，关闭设置窗口。

![在账户菜单中打开 Inference configuration](/simidoc/assets/claude-desktop/claude-inference-menu.png)

![确认第三方推理配置选择 CC Switch 并已应用](/simidoc/assets/claude-desktop/claude-cc-switch-profile.png)

截图中的网关密钥已隐藏；请保留 CC Switch 自动配置的值，不要将其清空。

<Callout type="info" title="">
  CC Switch 配置中的网关地址指向本机路由，与第 2 步填写的 SimiRouter 请求地址不同；通常无需手动修改网关地址或网关密钥。连接测试成功只说明连接检测通过，并不能代替一次实际模型调用。
</Callout>

### 6. 选择模型并验证

1. 新建对话，在输入框旁的模型菜单中选择刚才配置的**菜单显示名**，发送一条简短消息。真实调用可能产生费用。
2. 收到回复后，前往 SimiRouter 控制台的调用记录，核对请求时间、**实际模型**和用量。模型的自述身份和 Claude Desktop 显示名不能证明实际调用了哪个模型。

## 常见问题

### 找不到 Claude Desktop 或开发者模式

* 确认使用的是支持 Claude Desktop 的较新版本 CC Switch，并在左侧选择 **Claude Desktop**。
* 在 Claude Desktop 的 **Help → Troubleshooting** 中启用 **Enable Developer Mode**；找不到入口时尝试更新客户端。

### 看不到 CC Switch 配置或模型没有更新

* 确认 SimiRouter 卡片显示 **路由中**，并保持 CC Switch 及本地路由服务运行。
* 完全退出并重新打开 Claude Desktop，再检查左下角 **Inference configuration** 中的配置。不同版本也可能通过 **Developer → Configure third-party inference** 打开该页面。
* 确认模型映射中的「菜单显示名」已填写，且已选中 **CC Switch** 配置。修改映射或切换供应商后重新启动 Claude Desktop。

### 检测失败或对话报错

* 检查 CC Switch 中的 API Key 是否完整、有效，且请求地址为 `https://api.dwchainless.com`。
* 确认已选择 **Anthropic Messages（原生）** 上游格式，并检查网络与本地路由服务状态。
* 核对「实际请求模型」的 ID、密钥分组和模型权限；不要只检查菜单显示名。
* 根据错误信息检查账户额度和模型兼容性。连接检测通过也不保证所有模型或功能都可用。

## 其他配置方式

### 可选：原有直连配置

以下保留原有的直连步骤，未在当前客户端版本重新验证，字段和界面可能有所变化；如果已按上面的 CC Switch 流程配置，无需重复操作。模型是否能在直连模式中使用，以客户端实际支持情况为准。

先在 **Help → Troubleshooting** 中启用开发者模式，然后：

1. 在顶部菜单栏进入 **Developer → Configure third-party inference**。
2. 按照下表填写配置：

| 字段                    | 填写内容                                                       |
| --------------------- | ---------------------------------------------------------- |
| Base URL              | `https://api.dwchainless.com`                              |
| API Key               | 你的 SimiRouter API Key，例如 `sk-...`                          |
| Authentication method | 选择 `x-api-key`                                             |
| Provider / API format | 如果界面出现该选项，选择 `Anthropic-compatible`、`custom gateway` 或类似选项 |

<Callout type="warn" title="">
  Claude Desktop 的 Base URL 请填写 `https://api.dwchainless.com`。这是 Claude Desktop 的第三方推理配置地址；不要把 Claude CLI 文档中的 `ANTHROPIC_BASE_URL` 环境变量写法直接复制到这里。
</Callout>

3. 选择 **Apply locally**，将配置保存到当前电脑。
4. 按客户端提示继续登录或启动 Claude Desktop。

## 官方参考

* [CC Switch：Claude Desktop 配置说明](https\://github.com/farion1231/cc-switch-website/blob/main/public/docs/en/2-providers/2.6-claude-desktop.md)
* [Anthropic Docs：Claude Cowork 第三方平台配置](https\://claude.com/docs/third-party/claude-desktop/overview)