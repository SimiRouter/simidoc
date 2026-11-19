# CodexApp桌面版設定

Codex 桌面版支援使用 API Key 登入，並允許在應用內打開使用者層級 `config.toml`。完成以下設定後，Codex 會透過 SimiRouter 的 Responses 相容介面發起請求。

<Callout type="info" title="">
  登入介面的欄位名稱仍會顯示為 **OpenAI API key**。請在這裡填寫你的 SimiRouter API Key，例如 `sk-...`。
</Callout>

## 前置條件

開始之前，請確認你已經準備好：

* 最新版 Codex 桌面版
* SimiRouter 帳戶
* 在 SimiRouter 控制台建立的 API Key
* 目前帳戶可以使用準備設定的模型

## 設定步驟

### 1. 使用 API Key 登入

1. 打開 Codex 桌面版。
2. 在登入頁面選擇 **Sign in another way**。
3. 在 **OpenAI API key** 輸入框中填寫你的 SimiRouter API Key。
4. 選擇 **Continue** 進入應用。

![在 Codex 桌面版中填寫 API Key](/simidoc/assets/codex-desktop/codex-api-key-login.png)

### 2. 打開使用者層級設定檔

1. 進入 Codex 設定頁面。
2. 在左側選擇 **Configuration**。
3. 在 **Custom config.toml settings** 中選擇 **User config**。
4. 選擇 **Open config.toml**，打開使用者層級設定檔。

![在 Codex 桌面版中打開使用者層級 config.toml](/simidoc/assets/codex-desktop/codex-user-config.png)

### 3. 寫入 SimiRouter 設定

編輯前先備份現有 `config.toml`；請合併以下模型與供應商欄位，而非覆蓋整個檔案。保留原有 MCP、項目信任、審批和沙箱設定，不要重複新增同名 TOML 資料表。

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

儲存檔案後，完全結束並重新打開 Codex 桌面版。

<Callout type="info" title="">
  本範例採用 `requires_openai_auth = false` 和 `experimental_bearer_token` 直接提供權杖。請將佔位符替換為你的 SimiRouter API Key；該方式不需要同時設定 `auth.json`，也不依賴登入流程儲存的金鑰。`config.toml` 中會包含明文金鑰，請勿提交或分享；Linux / macOS 可用 `chmod 600 ~/.codex/config.toml` 限制存取，Windows 請限制檔案存取權限。保留原有的審批、沙箱與項目信任設定，不要為串接服務而關閉安全確認。
</Callout>

## 驗證設定

重新打開 Codex 後：

1. 打開一個項目或工作區。
2. 先讓 Codex 解釋一個檔案等低風險任務。
3. 到 SimiRouter 使用記錄中核對本次請求的時間、模型及用量。用戶端顯示名和模型自述不能證明實際路由。

## 常見問題

### API Key 無效

* 從 SimiRouter 控制台重新複製完整的 API Key。
* 檢查 API Key 前後是否有多餘空格。
* 確認 API Key 以 `sk-` 開頭且仍然有效。

### 設定沒有生效

* 確認修改的是 **User config** 下打開的 `config.toml`。
* 確認 `model_provider = "simirouter"` 與 `[model_providers.simirouter]` 名稱完全一致。
* 儲存檔案後完全結束應用，而不是只關閉目前視窗。

### 模型或連接錯誤

* 確認 `base_url` 為 `https://api.dwchainless.com/v1`。
* 確認 `wire_api` 為 `responses`。
* 確認目前 API Key 所在群組可以使用 `gpt-6-astra`；如需使用其他模型，請將 `model` 替換為對應模型名稱。

如需手動設定 `auth.json`、切換模型或使用命令列版本，請查看 [Codex CLI 設定](/simidoc/zh-Hant/apps/codex-config)。

## 官方參考

* [OpenAI Codex 設定參考](https\://developers.openai.com/codex/config-reference/)