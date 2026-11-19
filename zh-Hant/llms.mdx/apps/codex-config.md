# Codex CLI 設定

本頁範例透過 `config.toml` 直接提供 API 金鑰。指令碼會處理使用者層級 `config.toml` 與本機 `models.json`，不會建立或修改 `auth.json`。

指令碼使用兩個 URL 與一個 API 金鑰：

* **推理 Base URL**：`https://api.dwchainless.com/v1`，寫入 `model_providers.simirouter.base_url`，供 Codex 請求使用。
* **模型目錄 URL**：`https://api.dwchainless.com/v1/models`。指令碼使用同一個 API 金鑰作為 Bearer，將 OpenAI 格式的模型清單轉換為本機 `~/.codex/models.json`，並設定 `model_catalog_json`。這不是第二個推理端點。
* **API 金鑰**：同一個 SimiRouter 金鑰同時用於兩個 URL。指令碼只會將它作為 Bearer 憑據傳送到這兩個固定 URL，不會寫入文件或其他位置。

模型目錄需要有效金鑰。可用模型與上下文長度等基本中繼資料以回應為準；轉換不會憑空加入未確認的工具或推理能力。

* **Linux / macOS**：`~/.codex/config.toml`
* **Windows**：`%USERPROFILE%\.codex\config.toml`

## 方式一：一鍵設定指令碼（可選，先審閱再執行）

儲存庫提供 Bash 與 PowerShell 指令碼。執行前請確保已安裝並啟動過 Codex CLI 或 Codex 桌面版；先下載並審閱指令碼，再執行本機檔案。

* [下載 Bash 指令碼](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [下載 PowerShell 指令碼](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)

macOS / Linux 使用者在終端機中執行：

<Callout type="warn" title="">
  以下步驟會從文件網站下載指令碼，但不會把網路回應直接交給直譯器。請先審閱儲存的檔案再執行。若網站尚未提供檔案，請使用儲存庫 `public/scripts/` 中的相同檔案，或使用下方手動設定。
  指令碼會將 API 金鑰寫入 `experimental_bearer_token` in `config.toml`，不會建立或修改 `auth.json`。請將此設定檔視為含明文秘密。
</Callout>

```bash
# Download the script from the public script link above, then review it.
less ./codex-simirouter-setup.sh
bash ./codex-simirouter-setup.sh
```

Windows 使用者在 PowerShell 中執行：

```powershell
# Download the script from the public script link above, then review it.
$script = Join-Path (Get-Location) 'codex-simirouter-setup.ps1'
Get-Content -LiteralPath $script
& powershell -File $script
```

<Callout type="info" title="">
  Windows PowerShell 5.1 與 PowerShell 7 都會先儲存檔案，再以檔案方式執行，方便在輸入 API 金鑰前檢查內容。使用 PowerShell 7 時，將最後一行的 `powershell` 改為 `pwsh`。
</Callout>

執行後按選單選擇要使用的模型。首次執行會提示輸入 API Key（以 `sk-` 開頭，在 SimiRouter 控制台取得）。

指令碼會依次完成以下工作（Bash 版本需要 Python 3.11 或更新版本）：

* **備份現有設定**：將 `config.toml` 快照保存到 `~/.codex/backup-simirouter/`，還原時必須明確輸入 `RESTORE`。
* **同步模型目錄**：使用同一個金鑰請求目錄 URL，將模型 ID 與基本中繼資料轉換到 `~/.codex/models.json`，並讓 `model_catalog_json` 指向該檔案。
* **修改 `config.toml`**：更新頂層 `model_provider`、`model`、`model_catalog_json`，以及 `[model_providers.simirouter]` 中的 `base_url`、`wire_api`、`experimental_bearer_token`，其他內容儘量保留。
* **保護檔案**：指令碼會嘗試將目錄與設定檔存取限制為目前使用者；作業系統拒絕時會顯示警告。
* **驗證**：Bash 版本使用 Python 3.11+ 解析 TOML 與目錄 JSON 後才替換檔案。指令碼不會驗證或修改 `auth.json`，也不宣稱實際推理呼叫已成功。

<Callout type="info" title="">
  再次執行指令碼可切換模型，或選擇「恢復預設設定」用備份還原到安裝前的狀態。
</Callout>

## 方式二：Linux / macOS 手動設定（備用）

修改前，分別備份現有的 `config.toml` 與 `auth.json`，不要移動或重建整個 `~/.codex` 目錄，以免影響歷史記錄、工作階段與其他設定。只合併供應商及模型欄位，不要整份覆蓋，也不要重複新增同名 TOML 資料表；保留已有的 MCP、審批、沙箱與項目信任設定。

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

`model_catalog_json` 指向由 `https://api.dwchainless.com/v1/models` 產生的本機目錄；手動設定時，請使用同一金鑰請求該 URL，並以 Codex 的 `models.json` 格式儲存，不能直接將 OpenAI 的 `data` 清單當作 Codex 目錄。

該檔案包含明文權杖，請勿提交或分享。Linux / macOS 儲存後限制存取：

```bash
chmod 600 ~/.codex/config.toml
```

### `auth.json`（僅其他驗證方式需要時）

上方範例使用設定內權杖，已足夠提供驗證，不需要額外建立或覆蓋 `auth.json`。下方 JSON 僅供需要該檔案的其他驗證方式參考；請按目前 Codex 版本要求選擇一種方式，不要混用來掩蓋驗證錯誤。

```json
{
  "OPENAI_API_KEY": "PASTE_API_KEY_HERE"
}
```

## Windows 設定

### PowerShell

建立目錄並打開設定檔：

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex" | Out-Null
notepad "$env:USERPROFILE\.codex\config.toml"
```

### CMD

```cmd
if not exist "%USERPROFILE%\.codex" mkdir "%USERPROFILE%\.codex"
notepad "%USERPROFILE%\.codex\config.toml"
```

備份已有設定後，將上方 TOML 的供應商與模型欄位合併到 `config.toml` 並儲存；不要覆蓋無關設定。該範例使用設定內權杖，無需另外建立或覆蓋 `auth.json`。Windows 請將含金鑰檔案的存取權限限制為目前使用者。

## 啟動驗證

```bash
codex
```

<Callout type="warn" title="">
  Windows 下 `config.toml` 與 `auth.json` 路徑為 `%USERPROFILE%\.codex\`，請確保檔案儲存在正確位置。
</Callout>