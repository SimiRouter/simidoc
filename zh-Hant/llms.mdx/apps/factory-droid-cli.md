# Factory Droid CLI 安裝及設定

Droid CLI 支援使用自有 API Key 設定模型。個人自訂模型儲存在本機設定中，不等於 Factory 託管網頁或移動端也使用該模型。

## 安裝

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

以上指令會執行官方安裝指令碼，執行前應核對來源；受管理環境按組織要求安裝。不要為安裝無條件關閉安全軟體或降低全域執行策略。啟動後若出現登入提示，按用戶端要求完成帳戶登入。

## 新增 SimiRouter 模型

1. 啟動 `droid`，執行 `/settings` 並打開 **Custom models**；也可在 `/model` 中選擇 **Manage custom models**。
2. 點擊 **Add model**，選擇通用 Chat Completions 提供者。
3. 設定以下欄位並儲存：

| 欄位           | 內容                               |
| ------------ | -------------------------------- |
| Provider     | `generic-chat-completion-api`    |
| Base URL     | `https://api.dwchainless.com/v1` |
| API Key      | SimiRouter API Key               |
| Model        | 帳戶可用的完整模型 ID                     |
| Display name | 例如 `SimiRouter`，僅用於顯示            |

## 設定檔方式

也可合併 `~/.factory/settings.json` 的 `customModels` 陣列。修改前先備份，保留已有條目和其他設定。

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

將 `MODEL_ID` 換成實際模型 ID，並在啟動 Droid 的環境中設定 `SIMIROUTER_API_KEY`。`${SIMIROUTER_API_KEY}` 是 Droid 支援的環境變數引用，不要改成公開可見的真實金鑰。

目前設定使用 `settings.json` 和 camelCase 欄位。舊版 `config.json` 的條目可能在首次啟動時遷移，後續應修改 `settings.json`，不要繼續執行舊第三方設定指令碼覆蓋設定。

## 驗證

在 `/model` 中選擇 **Custom Models** 下的 SimiRouter 模型，先請求解釋檔案等低風險任務，再到 SimiRouter 使用記錄核對實際模型與用量。輸出上限、圖片輸入和工具呼叫按所選模型設定，不要套用其他模型的固定能力數值。

## 官方參考

* [Factory Droid CLI 快速開始](https\://docs.factory.com/droid-cli/quickstart)
* [Factory 自訂模型（BYOK）](https\://docs.factory.com/model-independence/byok)