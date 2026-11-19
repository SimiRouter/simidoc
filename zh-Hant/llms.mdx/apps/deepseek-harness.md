# DeepSeek Harness 設定

DeepSeek Harness（`dsh`）是 DeepSeek AI 開放原始碼的智慧代理框架。將 SimiRouter 設定為自訂供應商後，可以在 Harness 的 Web UI 和 headless 任務中使用 SimiRouter 模型。

## 前置條件

開始之前，請準備好：

* SimiRouter 帳戶和 API Key
* Node.js 與 `npx`
* macOS、Linux 或 Windows 終端機
* 一個準備交給智慧代理操作的項目目錄

## 安裝並啟動

進入希望智慧代理操作的項目目錄，然後執行：

```bash
npx @deepseek-ai/dsh web
```

Web UI 預設位址為 `http://127.0.0.1:3080`。啟動目錄只是預設檔案系統位置，全新的 Web UI 不會自動選取工作區：需要在介面中手動加入該目錄，選取前工作階段輸入框不可用。

如需更換連接埠：

```bash
npx @deepseek-ai/dsh web --port 8080
```

## 在 Web UI 中設定 SimiRouter（推薦）

### 1. 打開模型設定

在 DeepSeek Harness Web UI 中進入 **Settings → Models**。

![打開 DeepSeek Harness 模型設定](/simidoc/assets/deepseek-harness/open-model-settings.png)

### 2. 新增自訂供應商

選擇 **Add a custom provider**，填寫以下內容：

| 欄位           | 填寫內容                             |
| ------------ | -------------------------------- |
| Provider ID  | `simirouter`                     |
| Display name | `SimiRouter`                     |
| Base URL     | `https://api.dwchainless.com/v1` |
| API protocol | `openai-completions`             |
| API key      | 你的 SimiRouter API Key            |

![填寫 SimiRouter 自訂供應商設定](/simidoc/assets/deepseek-harness/custom-provider-form.png)

<Callout type="warn" title="">
  Provider ID 會被工作階段、預設模型和憑證引用，儲存後不能直接改名。請保持小寫並使用 `simirouter`。
</Callout>

### 3. 取得模型

在 **Model catalog** 中選擇 **Fetch available models**。Harness 會使用目前 Base URL 和 API Key 請求模型清單。

勾選需要的模型後儲存。如果自動取得失敗，也可以手動填寫模型 ID，例如 `gpt-6-astra`。模型名稱必須與目前 API Key 群組實際可用的名稱一致。

![選擇要新增到 SimiRouter 供應商的模型](/simidoc/assets/deepseek-harness/select-provider-models.png)

### 4. 選擇模型

儲存後，在輸入框附近的模型選取器中找到 **SimiRouter**，選擇準備使用的模型。該模型會成為新工作階段的預設模型；已經傳送過請求的舊工作階段會繼續使用其原有模型。

![在 DeepSeek Harness 中選擇 SimiRouter 模型](/simidoc/assets/deepseek-harness/model-picker.png)

## 使用 Profile Patch 設定

Web Profile 的進階供應商設定使用 `$DSH_HOME/profiles/web/cordis.patch.yml`（預設位於 `~/.dsh/profiles/web/cordis.patch.yml`）。編輯前備份原檔案，合併以下外掛程式設定，不覆蓋已有外掛程式或供應商：

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

將 `MODEL_ID` 替換為完整模型 ID，在啟動 Harness 的環境中設定 `SIMIROUTER_API_KEY`。啟動 Web UI 後，在模型選取器中選擇 SimiRouter 模型。該設定用於 Web Profile，不能假定其他 Profile 自動繼承。

## 驗證設定

1. 打開 Web UI 位址：預設 `http://127.0.0.1:3080`；若啟動時用 `--port` 改過連接埠，請改用對應連接埠。
2. 確認模型選取器中出現 **SimiRouter** 和已儲存的模型。
3. 新建工作階段並傳送一條簡短測試訊息。
4. 到 SimiRouter 使用記錄核對請求時間、模型和消耗，確認本次呼叫。

## Headless 模式

Headless Profile 預設禁用 Web 的託管憑證儲存，不能假定介面中儲存的 Key 會自動生效。需要在 Headless 對應 Profile 中設定同一供應商，並透過啟動環境傳入 API Key。設定說明見 [DeepSeek Harness Headless 憑證說明](https\://github.com/deepseek-ai/deepseek-harness/blob/master/packages/bundle/headless/README.md#credentials)。

## 常見問題

### `MISSING_CREDENTIAL`

Harness 找不到 `SIMIROUTER_API_KEY`。請在 **Settings → Models** 重新儲存 API Key，或在啟動程序的終端機中設定同名環境變數。

### `UNKNOWN_MODEL`

目前模型不在 目前 Profile 中 `simirouter` 的 `models` 清單中。請重新取得模型，或把正確的模型 ID 手動加入清單。

### 取得模型或對話時出現 401

* 檢查 API Key 是否完整、有效且沒有多餘空格。
* 確認 Base URL 為 `https://api.dwchainless.com/v1`。
* 確認目前 API Key 群組可以使用所選模型。

### 請求沒有經過 SimiRouter

確認新增的是 **custom provider**，Provider ID 為 `simirouter`。內建的 DeepSeek、OpenAI 或 Anthropic 供應商仍會使用各自的官方端點。

### 修改預設模型後沒有生效

新建一個工作階段再測試。已經傳送過請求的工作階段會保留自身記錄的模型。

## 官方參考

* [DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness)
* [DeepSeek Harness 設定模型指南](https\://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/providers.zh.md)