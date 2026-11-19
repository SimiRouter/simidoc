# Factory Droid CLI 安装及配置

Droid CLI 支持使用自有 API Key 配置模型。个人自定义模型保存在本机配置中，不等于 Factory 托管网页或移动端也使用该模型。

## 安装

macOS / Linux：

```bash
curl -fsSL https://app.factory.ai/cli | sh
droid --version
```

Windows PowerShell：

```powershell
irm https://app.factory.ai/cli/windows | iex
droid --version
```

以上命令会执行官方安装脚本，运行前应核对来源；受管理环境按组织要求安装。不要为安装无条件关闭安全软件或降低全局执行策略。启动后若出现登录提示，按客户端要求完成账户登录。

## 添加 SimiRouter 模型

1. 启动 `droid`，运行 `/settings` 并打开 **Custom models**；也可在 `/model` 中选择 **Manage custom models**。
2. 点击 **Add model**，选择通用 Chat Completions 提供商。
3. 配置以下字段并保存：

| 字段           | 内容                               |
| ------------ | -------------------------------- |
| Provider     | `generic-chat-completion-api`    |
| Base URL     | `https://api.dwchainless.com/v1` |
| API Key      | SimiRouter API Key               |
| Model        | 账户可用的完整模型 ID                     |
| Display name | 例如 `SimiRouter`，仅用于显示            |

## 配置文件方式

也可合并 `~/.factory/settings.json` 的 `customModels` 数组。修改前先备份，保留已有条目和其他设置。

```json
{
  "customModels": [
    {
      "model": "MODEL_ID",
      "displayName": "SimiRouter",
      "baseUrl": "https://api.dwchainless.com/v1",
      "apiKey": "${SIMIROUTER_API_KEY}",
      "provider": "generic-chat-completion-api"
    }
  ]
}
```

将 `MODEL_ID` 换成实际模型 ID，并在启动 Droid 的环境中设置 `SIMIROUTER_API_KEY`。`${SIMIROUTER_API_KEY}` 是 Droid 支持的环境变量引用，不要改成公开可见的真实密钥。

当前配置使用 `settings.json` 和 camelCase 字段。旧版 `config.json` 的条目可能在首次启动时迁移，后续应修改 `settings.json`，不要继续执行旧第三方配置脚本覆盖配置。

## 验证

在 `/model` 中选择 **Custom Models** 下的 SimiRouter 模型，先请求解释文件等低风险任务，再到 SimiRouter 使用日志核对实际模型与用量。输出上限、图片输入和工具调用按所选模型配置，不要套用其他模型的固定能力数值。

## 官方参考

* [Factory Droid CLI 快速开始](https\://docs.factory.com/droid-cli/quickstart)
* [Factory 自定义模型（BYOK）](https\://docs.factory.com/model-independence/byok)