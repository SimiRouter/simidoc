# Claude Code CLI 安裝

Claude Code 支援 macOS、Linux、原生 Windows 和 WSL。原生安裝器不需要 Node.js；只有選擇 npm 安裝時才需要符合要求的 Node.js 版本。

## macOS / Linux / WSL

在 Bash 或 Zsh 中執行官方安裝指令：

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
```

指令會下載並執行官方指令碼。受管理環境應先審閱指令碼或使用組織批准的安裝方式；不要以 `sudo` 執行。

## Windows PowerShell

```powershell
irm https://claude.ai/install.ps1 | iex
claude --version
```

安裝不要求管理員權限。原生 Windows 的 Git for Windows 為選用依賴；需要 Bash 工具時再安裝。WSL 使用者應在 WSL 終端機使用 Linux 安裝指令，而不是在 PowerShell 中設定 Linux 用戶端。

## 設定並啟動

1. 按 [Claude CLI 設定](/simidoc/zh-Hant/apps/claude-config)設定 SimiRouter 位址和金鑰。
2. 進入準備使用的項目目錄，執行 `claude`。
3. 保留權限確認，先請求解釋檔案等低風險操作，再核對 SimiRouter 使用記錄。

`claude --version` 僅驗證指令已安裝，不能證明模型介面已接通。不要因安裝受阻而關閉殺毒軟體或全域降低系統安全設定。

## 官方參考

[Anthropic：Claude Code 安裝與系統要求](https\://code.claude.com/docs/en/setup)。