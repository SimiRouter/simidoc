# Claude Code CLI 安装

Claude Code 支持 macOS、Linux、原生 Windows 和 WSL。原生安装器不需要 Node.js；只有选择 npm 安装时才需要符合要求的 Node.js 版本。

## macOS / Linux / WSL

在 Bash 或 Zsh 中执行官方安装命令：

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
```

命令会下载并执行官方脚本。受管理环境应先审阅脚本或使用组织批准的安装方式；不要以 `sudo` 运行。

## Windows PowerShell

```powershell
irm https://claude.ai/install.ps1 | iex
claude --version
```

安装不要求管理员权限。原生 Windows 的 Git for Windows 为可选依赖；需要 Bash 工具时再安装。WSL 用户应在 WSL 终端使用 Linux 安装命令，而不是在 PowerShell 中配置 Linux 客户端。

## 配置并启动

1. 按 [Claude CLI 配置](/simidoc/zh/apps/claude-config)设置 SimiRouter 地址和密钥。
2. 进入准备使用的项目目录，运行 `claude`。
3. 保留权限确认，先请求解释文件等低风险操作，再核对 SimiRouter 使用日志。

`claude --version` 仅验证命令已安装，不能证明模型接口已接通。不要因安装受阻而关闭杀毒软件或全局降低系统安全设置。

## 官方参考

[Anthropic：Claude Code 安装与系统要求](https\://code.claude.com/docs/en/setup)。