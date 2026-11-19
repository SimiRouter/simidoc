# Codex CLI 配置

本页示例通过 `config.toml` 直接提供 API 密钥。脚本只处理用户级 `config.toml` 与本地 `models.json`；`auth.json` 不由脚本创建或修改。

脚本使用两个地址和同一个 API Key：

* **推理 Base URL**：`https://api.dwchainless.com/v1`，写入 `model_providers.simirouter.base_url`，用于 Codex 请求。
* **模型目录 URL**：`https://api.dwchainless.com/v1/models`，脚本用同一个 API Key 以 Bearer 方式请求，将 OpenAI 格式的模型列表转换为本地 `~/.codex/models.json`，并写入 `model_catalog_json`。它不是另一个推理地址。
* **API Key**：同一个 SimiRouter API Key 同时用于上述两个地址；脚本只会将其作为 Bearer 凭据发送到这两个固定地址，不会写入文档或其他位置。

模型目录接口需要有效 Key；可用模型和上下文等基础信息以接口返回为准，目录转换不会凭空添加未确认的工具或推理能力。

* **Linux / macOS**：`~/.codex/config.toml`
* **Windows**：`%USERPROFILE%\.codex\config.toml`

## 方式一：一键配置脚本（可选，先审阅再执行）

仓库提供 Bash 和 PowerShell 脚本。运行前请确保已安装并启动过 Codex CLI 或 Codex 桌面端；先下载并审阅脚本，再执行本地文件。

* [下载 Bash 脚本（CDN）](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [下载 Bash 脚本（GitHub Raw 备用）](https\://raw.githubusercontent.com/SimiRouter/simidoc/cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [下载 PowerShell 脚本（CDN）](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)
* [下载 PowerShell 脚本（GitHub Raw 备用）](https\://raw.githubusercontent.com/SimiRouter/simidoc/cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)

macOS / Linux 用户在终端中执行：

<Callout type="warn" title="">
  以下步骤会从上方的 CDN 或 GitHub Raw 链接下载脚本，但不会直接把网络响应交给解释器。下载后请审阅本地文件内容并确认备份目录，再运行本地副本。
  脚本会把 API 密钥写入 `experimental_bearer_token`（位于 `config.toml`）；不会创建或修改 `auth.json`。该文件包含明文密钥，请勿提交或分享。
</Callout>

```bash
# Download the script from the public script link above, then review it.
less ./codex-simirouter-setup.sh
bash ./codex-simirouter-setup.sh
```

Windows 用户在 PowerShell 中执行：

```powershell
# Download the script from the public script link above, then review it.
$script = Join-Path (Get-Location) 'codex-simirouter-setup.ps1'
Get-Content -LiteralPath $script
& powershell -File $script
```

<Callout type="info" title="">
  PowerShell 5.1 和 PowerShell 7 都先保存本地文件，再以文件方式运行；这样可以在输入 API 密钥前检查脚本。使用 PowerShell 7 时，将最后一行的 `powershell` 替换为 `pwsh`。
</Callout>

运行后按菜单选择要使用的模型。首次运行会提示输入 API Key（以 `sk-` 开头，在 SimiRouter 控制台获取）。

脚本会依次完成以下工作（Bash 需要 Python 3.11 或更高版本）：

* **备份现有配置**：将 `config.toml` 快照保存到 `~/.codex/backup-simirouter/`，恢复菜单只在明确输入 `RESTORE` 后执行。
* **同步模型目录**：使用同一个 API Key 请求模型目录 URL，将返回的模型 ID 和基础元数据写入 `~/.codex/models.json`，并让 `model_catalog_json` 指向该文件。
* **修改 `config.toml`**：更新顶层 `model_provider`、`model`、`model_catalog_json`，并维护 `[model_providers.simirouter]` 中的 `base_url`、`wire_api` 和 `experimental_bearer_token`；其他未管理内容尽量保留。
* **保护文件**：Linux / macOS 尝试将目录和配置文件权限限制为当前用户；Windows 脚本尝试设置当前用户 ACL。权限设置失败会显示警告，不应据此忽略密钥保护。
* **校验**：Bash 版本使用 Python 3.11+ 解析 TOML 和模型目录 JSON；配置或目录转换失败会保留原文件。脚本不会验证或修改 `auth.json`，也不会声称已完成真实推理调用。

<Callout type="info" title="">
  再次运行脚本可切换模型，或选择「恢复默认配置」用备份还原到安装前的状态。
</Callout>

## 方式二：Linux / macOS 手动配置（备用）

修改前，分别备份现有的 `config.toml` 与 `auth.json`，不要移动或重建整个 `~/.codex` 目录，以免影响历史记录、会话与其他配置。只合并供应商及模型字段，不要整份覆盖，也不要重复添加同名 TOML 表；保留已有的 MCP、审批、沙箱与项目信任设置。

### `~/.codex/config.toml`

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
model_catalog_json = "~/.codex/models.json"

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

上面的 `model_catalog_json` 指向脚本根据 `https://api.dwchainless.com/v1/models` 生成的本地目录；手动配置时需要先用同一个 API Key 请求该地址并按 Codex 的 `models.json` 格式保存，不能直接把 OpenAI 的 `data` 列表当作 Codex 目录。

该文件包含明文令牌，请勿提交或分享。Linux / macOS 保存后限制访问：

```bash
chmod 600 ~/.codex/config.toml
```

### `auth.json`（仅其他认证方式需要时）

上方示例使用配置内令牌，已足够提供认证，不需要额外创建或覆盖 `auth.json`。下方 JSON 仅供需要该文件的其他认证方式参考；请按当前 Codex 版本要求选择一种方式，不要混用来掩盖认证错误。

```json
{
  "OPENAI_API_KEY": "PASTE_API_KEY_HERE"
}
```

## Windows 配置

### PowerShell

创建目录并打开配置文件：

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex" | Out-Null
notepad "$env:USERPROFILE\.codex\config.toml"
```

### CMD

```cmd
if not exist "%USERPROFILE%\.codex" mkdir "%USERPROFILE%\.codex"
notepad "%USERPROFILE%\.codex\config.toml"
```

备份已有配置后，将上方 TOML 的供应商与模型字段合并到 `config.toml` 并保存；不要覆盖无关设置。该示例使用配置内令牌，无需另外创建或覆盖 `auth.json`。Windows 请将含密钥文件的访问权限限制为当前用户。

## 启动验证

```bash
codex
```

<Callout type="warn" title="">
  Windows 下 `config.toml` 与 `auth.json` 路径为 `%USERPROFILE%\.codex\`，请确保文件保存在正确位置。
</Callout>