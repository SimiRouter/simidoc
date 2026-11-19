# CodexApp桌面端设置

Codex 桌面端支持使用 API Key 登录，并允许在应用内打开用户级 `config.toml`。完成以下配置后，Codex 会通过 SimiRouter 的 Responses 兼容接口发起请求。

<Callout type="info" title="">
  登录界面的字段名称仍会显示为 **OpenAI API key**。请在这里填写你的 SimiRouter API Key，例如 `sk-...`。
</Callout>

## 前置条件

开始之前，请确认你已经准备好：

* 最新版 Codex 桌面端
* SimiRouter 账户
* 在 SimiRouter 控制台创建的 API Key
* 当前账户可以使用准备配置的模型

## 配置步骤

### 1. 使用 API Key 登录

1. 打开 Codex 桌面端。
2. 在登录页面选择 **Sign in another way**。
3. 在 **OpenAI API key** 输入框中填写你的 SimiRouter API Key。
4. 选择 **Continue** 进入应用。

![在 Codex 桌面端中填写 API Key](/simidoc/assets/codex-desktop/codex-api-key-login.png)

### 2. 打开用户级配置文件

1. 进入 Codex 设置页面。
2. 在左侧选择 **Configuration**。
3. 在 **Custom config.toml settings** 中选择 **User config**。
4. 选择 **Open config.toml**，打开用户级配置文件。

![在 Codex 桌面端中打开用户级 config.toml](/simidoc/assets/codex-desktop/codex-user-config.png)

### 3. 写入 SimiRouter 配置

编辑前先备份现有 `config.toml`；请合并以下模型与供应商字段，而非覆盖整个文件。保留原有 MCP、项目信任、审批和沙箱设置，不要重复添加同名 TOML 表。

```toml
model_provider = "simirouter"
review_model = "gpt-6-astra"
model = "gpt-6-astra"
model_reasoning_effort = "xhigh"
plan_mode_reasoning_effort = "high"
model_reasoning_summary = "auto"
model_verbosity = "high"

suppress_unstable_features_warning = true
web_search = "live"

[model_providers.simirouter]
name = "simirouter"
base_url = "https://api.dwchainless.com/v1"
wire_api = "responses"
stream_idle_timeout_ms = 900000
supports_websockets = false
http_headers = { "x-openai-actor-authorization" = "api.dwchainless.com" }
requires_openai_auth = false
experimental_bearer_token="PASTE_API_KEY_HERE"
```

保存文件后，完全退出并重新打开 Codex 桌面端。

<Callout type="info" title="">
  本示例采用 `requires_openai_auth = false` 和 `experimental_bearer_token` 直接提供令牌。请将占位符替换为你的 SimiRouter API Key；该方式不需要同时配置 `auth.json`，也不依赖登录流程保存的密钥。`config.toml` 中会包含明文密钥，请勿提交或分享；Linux / macOS 可用 `chmod 600 ~/.codex/config.toml` 限制访问，Windows 请限制文件访问权限。保留原有的审批、沙箱与项目信任设置，不要为接入服务而关闭安全确认。
</Callout>

## 验证配置

重新打开 Codex 后：

1. 打开一个项目或工作区。
2. 先让 Codex 解释一个文件等低风险任务。
3. 到 SimiRouter 使用日志中核对本次请求的时间、模型及用量。客户端显示名和模型自述不能证明实际路由。

## 常见问题

### API Key 无效

* 从 SimiRouter 控制台重新复制完整的 API Key。
* 检查 API Key 前后是否有多余空格。
* 确认 API Key 以 `sk-` 开头且仍然有效。

### 配置没有生效

* 确认修改的是 **User config** 下打开的 `config.toml`。
* 确认 `model_provider = "simirouter"` 与 `[model_providers.simirouter]` 名称完全一致。
* 保存文件后完全退出应用，而不是只关闭当前窗口。

### 模型或连接错误

* 确认 `base_url` 为 `https://api.dwchainless.com/v1`。
* 确认 `wire_api` 为 `responses`。
* 确认当前 API Key 所在分组可以使用 `gpt-6-astra`；如需使用其他模型，请将 `model` 替换为对应模型名称。

如需手动配置 `auth.json`、切换模型或使用命令行版本，请查看 [Codex CLI 配置](/simidoc/zh/apps/codex-config)。

## 官方参考

* [OpenAI Codex 配置参考](https\://developers.openai.com/codex/config-reference/)