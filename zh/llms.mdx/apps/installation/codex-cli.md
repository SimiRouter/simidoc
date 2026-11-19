# Codex CLI 安装

## macOS / Linux

OpenAI 提供独立安装器：

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex --version
```

该命令会下载并执行官方脚本。受管理环境应先审阅脚本，或按官方文档使用组织批准的包管理方式安装。

## Windows

Windows 用户可在原生终端安装，也可在 WSL 中使用 Linux 工具链。安装方式和沙箱支持见 [OpenAI Windows 文档](https\://learn.chatgpt.com/docs/windows/windows-sandbox)。

若使用 npm 安装，先按 Node.js 官方说明配置兼容版本，然后执行：

```powershell
npm install -g @openai/codex
codex --version
```

WSL 用户应在 WSL 内安装并配置 Codex，不能将 `%USERPROFILE%` 下的 Windows 配置与 Linux 的 `~/.codex` 混为一处。不要为解决安装问题而关闭安全软件或无条件启用管理员权限。

## 配置并验证

1. 按 [Codex CLI 配置](/simidoc/zh/apps/codex-config)合并 `config.toml` 的供应商与模型字段；修改前保留原文件备份。
2. 进入项目目录，运行 `codex`。
3. 保留默认的审批与沙箱设置，先让 Codex 解释一个文件，再到 SimiRouter 使用日志核对本次请求。

`codex --version` 验证命令可执行；能进入界面不代表接口已接通。不要覆盖整个 `~/.codex` 目录，以免丢失历史会话和其他配置。

## 官方参考

* [OpenAI Codex CLI](https\://learn.chatgpt.com/docs/codex/cli)
* [OpenAI Windows 沙箱说明](https\://learn.chatgpt.com/docs/windows/windows-sandbox)