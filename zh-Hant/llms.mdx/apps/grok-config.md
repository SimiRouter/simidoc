# Grok CLI 設定

Grok CLI 的模型清單位址與推理位址分別設定。`[endpoints].models_base_url` 既是模型清單的來源，也是推理請求的預設基址；具體模型的 `base_url` 可以覆蓋它。只設定其中一處時，另一處可能仍指向官方位址，需要分別核對。

設定檔路徑：

* **Linux / macOS**：`~/.grok/config.toml`
* **Windows**：`%USERPROFILE%\.grok\config.toml`

## 安裝 / 更新

Linux / macOS：

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
grok update
grok --version
```

Windows（PowerShell）：

```powershell
irm https://x.ai/cli/install.ps1 | iex
```

透過 WinGet 安裝的版本請用 `winget upgrade` 更新，不要依賴 `grok update`。

<Callout type="warn" title="啟動時需要 XAI_API_KEY">
  Grok CLI 啟動階段拉取模型清單只讀取環境變數 `XAI_API_KEY`，未設定會直接報錯，與設定檔裡的 `api_key` 無關。使用 SimiRouter 時把同一個 Key 同時寫入環境變數：

  ```bash
  export XAI_API_KEY="PASTE_API_KEY_HERE"
  ```

  不要把金鑰寫進會提交到 Git 的檔案；長期使用可放進權限為 `600` 的環境檔後再 `source`。
</Callout>

## 寫入設定檔

將以下內容寫入 `~/.grok/config.toml`，並將 `api_key` 替換為自己的 API 金鑰：

```toml
[models]
default = "grok-4.5"

[endpoints]
models_base_url = "https://api.dwchainless.com/v1"

[model."grok-4.5"]
base_url = "https://api.dwchainless.com/v1"
model = "grok-4.5"
name = "Grok 4.5"
api_key = "PASTE_API_KEY_HERE"
api_backend = "responses"
context_window = 500000
supports_backend_search = true

[session]
# 可选：官方默认值为 85；80 会更早触发自动压缩
auto_compact_threshold_percent = 80

[ui]
max_thoughts_width = 120
yolo = false
compact_mode = false
# permission_mode = "always-approve"  # enable only in trusted environments
```

上述 UI 設定與推薦的本機使用方式一致：思考內容最大寬度為 120、不啟用緊湊介面，並自動批准工具呼叫。

<Callout type="warn" title="">
  範例關閉 `yolo`，並註解掉 `permission_mode = "always-approve"`。啟用它們會讓 Grok 無需確認即可修改檔案和執行指令，**只應在可信項目與可信執行環境中使用**。
</Callout>

<Callout type="info" title="">
  `api_key` 必須填寫本站提供的 SimiRouter Key，不能填寫 grok.com OAuth `refresh_token`。行內 Key 以明文儲存，Linux / macOS 請執行 `chmod 600 ~/.grok/config.toml`。共享機器建議改用官方支援的 `env_key` 方式。
</Callout>

## 驗證設定

```bash
grok inspect
grok models
grok --model grok-4.5 --output-format json -p '只输出 YAI_GROK_OK'
```

## 官方參考

* [xAI Grok CLI：自訂模型](https\://docs.x.ai/build/overview)
* [xAI Grok CLI：設定參考](https\://docs.x.ai/build/settings)