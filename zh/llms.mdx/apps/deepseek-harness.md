# DeepSeek Harness 设置

DeepSeek Harness（`dsh`）是 DeepSeek AI 开源的智能体框架。将 SimiRouter 配置为自定义供应商后，可以在 Harness 的 Web UI 和 headless 任务中使用 SimiRouter 模型。

## 前置条件

开始之前，请准备好：

* SimiRouter 账户和 API Key
* Node.js 与 `npx`
* macOS、Linux 或 Windows 终端
* 一个准备交给智能体操作的项目目录

## 安装并启动

进入希望智能体操作的项目目录，然后运行：

```bash
npx @deepseek-ai/dsh web
```

Web UI 默认地址为 `http://127.0.0.1:3080`。启动目录只是默认文件系统位置，全新的 Web UI 不会自动选中工作区：需要在界面中手动添加该目录，选中前会话输入框不可用。

如需更换端口：

```bash
npx @deepseek-ai/dsh web --port 8080
```

## 在 Web UI 中配置 SimiRouter（推荐）

### 1. 打开模型设置

在 DeepSeek Harness Web UI 中进入 **Settings → Models**。

![打开 DeepSeek Harness 模型设置](/simidoc/assets/deepseek-harness/open-model-settings.png)

### 2. 添加自定义供应商

选择 **Add a custom provider**，填写以下内容：

| 字段           | 填写内容                             |
| ------------ | -------------------------------- |
| Provider ID  | `simirouter`                     |
| Display name | `SimiRouter`                     |
| Base URL     | `https://api.dwchainless.com/v1` |
| API protocol | `openai-completions`             |
| API key      | 你的 SimiRouter API Key            |

![填写 SimiRouter 自定义供应商配置](/simidoc/assets/deepseek-harness/custom-provider-form.png)

<Callout type="warn" title="">
  Provider ID 会被会话、默认模型和凭据引用，保存后不能直接改名。请保持小写并使用 `simirouter`。
</Callout>

### 3. 获取模型

在 **Model catalog** 中选择 **Fetch available models**。Harness 会使用当前 Base URL 和 API Key 请求模型列表。

勾选需要的模型后保存。如果自动获取失败，也可以手动填写模型 ID，例如 `gpt-6-astra`。模型名称必须与当前 API Key 分组实际可用的名称一致。

![选择要添加到 SimiRouter 供应商的模型](/simidoc/assets/deepseek-harness/select-provider-models.png)

### 4. 选择模型

保存后，在输入框附近的模型选择器中找到 **SimiRouter**，选择准备使用的模型。该模型会成为新会话的默认模型；已经发送过请求的旧会话会继续使用其原有模型。

![在 DeepSeek Harness 中选择 SimiRouter 模型](/simidoc/assets/deepseek-harness/model-picker.png)

## 使用 Profile Patch 配置

Web Profile 的进阶供应商配置使用 `$DSH_HOME/profiles/web/cordis.patch.yml`（默认位于 `~/.dsh/profiles/web/cordis.patch.yml`）。编辑前备份原文件，合并以下插件配置，不覆盖已有插件或供应商：

```yaml
- id: llm-pi-ai
  config:
    providers:
      simirouter:
        displayName: SimiRouter
        apiKeyEnv: SIMIROUTER_API_KEY
        api: openai-completions
        baseURL: https://api.dwchainless.com/v1
        models:
          - id: MODEL_ID
```

将 `MODEL_ID` 替换为完整模型 ID，在启动 Harness 的环境中设置 `SIMIROUTER_API_KEY`。启动 Web UI 后，在模型选择器中选择 SimiRouter 模型。该配置用于 Web Profile，不能假定其他 Profile 自动继承。

## 验证配置

1. 打开 Web UI 地址：默认 `http://127.0.0.1:3080`；若启动时用 `--port` 改过端口，请改用对应端口。
2. 确认模型选择器中出现 **SimiRouter** 和已保存的模型。
3. 新建会话并发送一条简短测试消息。
4. 到 SimiRouter 使用日志核对请求时间、模型和消耗，确认本次调用。

## Headless 模式

Headless Profile 默认禁用 Web 的托管凭据存储，不能假定界面中保存的 Key 会自动生效。需要在 Headless 对应 Profile 中配置同一供应商，并通过启动环境传入 API Key。配置说明见 [DeepSeek Harness Headless 凭据说明](https\://github.com/deepseek-ai/deepseek-harness/blob/master/packages/bundle/headless/README.md#credentials)。

## 常见问题

### `MISSING_CREDENTIAL`

Harness 找不到 `SIMIROUTER_API_KEY`。请在 **Settings → Models** 重新保存 API Key，或在启动进程的终端中设置同名环境变量。

### `UNKNOWN_MODEL`

当前模型不在 当前 Profile 中 `simirouter` 的 `models` 列表中。请重新获取模型，或把正确的模型 ID 手动加入列表。

### 获取模型或对话时出现 401

* 检查 API Key 是否完整、有效且没有多余空格。
* 确认 Base URL 为 `https://api.dwchainless.com/v1`。
* 确认当前 API Key 分组可以使用所选模型。

### 请求没有经过 SimiRouter

确认添加的是 **custom provider**，Provider ID 为 `simirouter`。内置的 DeepSeek、OpenAI 或 Anthropic 供应商仍会使用各自的官方端点。

### 修改默认模型后没有生效

新建一个会话再测试。已经发送过请求的会话会保留自身记录的模型。

## 官方参考

* [DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness)
* [DeepSeek Harness 配置模型指南](https\://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/providers.zh.md)