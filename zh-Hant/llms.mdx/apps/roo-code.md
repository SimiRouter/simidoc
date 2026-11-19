# 第三方外掛程式設定（VS Code Roo）

Roo Code 支援自訂 OpenAI 相容提供者。透過 SimiRouter 串接時，只需設定服務位址、API Key 和模型 ID，不需要在本機部署模型。

## 設定 Roo Code

1. 安裝 Roo Code，打開擴展設定。
2. 將 **API Provider** 設為 **OpenAI Compatible**。
3. 填寫以下資訊：

| 欄位       | 內容                                 |
| -------- | ---------------------------------- |
| Base URL | `https://api.dwchainless.com/v1`   |
| API Key  | SimiRouter [API 金鑰管理](https://api.dwchainless.com/keys)中建立的金鑰 |
| Model ID | 從[模型廣場](https://api.dwchainless.com/zh-Hant/pricing/)複製完整模型 ID，區分大小寫   |

4. 按模型實際能力設定上下文視窗、輸出上限與圖片輸入等實際存在的欄位，不要套用其他模型的固定數值。Roo Code 固定使用原生工具呼叫，沒有個別開關。
5. 儲存後傳送簡短訊息，並在 SimiRouter [使用記錄](https://api.dwchainless.com/usage-logs/common)核對呼叫。

## 介面測試

用戶端之外的完整 Python、Node.js、curl 和 Go 測試範例見 [API 指令碼串接](/simidoc/zh-Hant/apps/api-script)。測試和外掛程式必須使用同一個模型 ID 與金鑰權限；一次文字請求成功不代表工具或圖片功能已經整合測試通過。

## 常見錯誤

* **401**：檢查金鑰是否完整、有效且無多餘空格。
* **404**：檢查最終請求位址是否重複出現 `/v1`，並核對模型 ID。
* **模型不可用**：檢查模型、群組和金鑰權限，結合回應錯誤體排查。
* **參數不支援**：關閉不適用於目前模型的參數，尤其是取樣、推理強度和輸出長度設定。

保留外掛程式預設的工具審批設定。不要向不可信項目開放自動執行權限，也不要公開含金鑰的設定截圖。

## 官方參考

[Roo Code：OpenAI Compatible 提供者](https\://roocodeinc.github.io/Roo-Code/providers/openai-compatible/)。