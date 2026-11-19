# Codex CLI 安裝

## macOS / Linux

OpenAI 提供獨立安裝器：

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex --version
```

該指令會下載並執行官方指令碼。受管理環境應先審閱指令碼，或按官方文件使用組織批准的套件管理方式安裝。

## Windows

Windows 使用者可在原生終端機安裝，也可在 WSL 中使用 Linux 工具鏈。安裝方式和沙箱支援見 [OpenAI Windows 文件](https\://learn.chatgpt.com/docs/windows/windows-sandbox)。

若使用 npm 安裝，先按 Node.js 官方說明設定相容版本，然後執行：

```powershell
npm install -g @openai/codex
codex --version
```

WSL 使用者應在 WSL 內安裝並設定 Codex，不能將 `%USERPROFILE%` 下的 Windows 設定與 Linux 的 `~/.codex` 混為一處。不要為解決安裝問題而關閉安全軟體或無條件啟用管理員權限。

## 設定並驗證

1. 按 [Codex CLI 設定](/simidoc/zh-Hant/apps/codex-config)合併 `config.toml` 的供應商與模型欄位；修改前保留原檔案備份。
2. 進入項目目錄，執行 `codex`。
3. 保留預設的審批與沙箱設定，先讓 Codex 解釋一個檔案，再到 SimiRouter 使用記錄核對本次請求。

`codex --version` 驗證指令可執行；能進入介面不代表介面已接通。不要覆蓋整個 `~/.codex` 目錄，以免丟失歷史工作階段和其他設定。

## 官方參考

* [OpenAI Codex CLI](https\://learn.chatgpt.com/docs/codex/cli)
* [OpenAI Windows 沙箱說明](https\://learn.chatgpt.com/docs/windows/windows-sandbox)