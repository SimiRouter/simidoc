# AstrBot設定

AstrBot 是支援多種訊息平台的開放原始碼 AI 助手。本教學使用 OpenAI 相容通訊協定連接 SimiRouter。

## 新增提供者

1. 安裝並啟動 AstrBot；安裝步驟見 [AstrBot 官方文件](https\://docs.astrbot.app/)。
2. 在 SimiRouter 的 [API 金鑰管理](https://api.dwchainless.com/keys)建立金鑰。
3. 打開 AstrBot 管理面板的 **Providers → Chat Completion**，點擊 **Add**，選擇 **OpenAI Compatible**。舊版本可能顯示為「模型提供者 → 新增 → OpenAI」。
4. 填寫以下欄位並儲存：

| 欄位           | 內容                               |
| ------------ | -------------------------------- |
| 提供者名稱        | `SimiRouter`                     |
| API Base URL | `https://api.dwchainless.com/v1` |
| API Key      | SimiRouter API Key               |
| Model        | 從[模型廣場](https://api.dwchainless.com/zh-Hant/pricing/)複製帳戶可用的完整模型 ID  |

點擊 **Save and Fetch Models** 取得模型，使用模型右側的 `+` 新增並啟用。也可透過 **Custom Model** 手動填寫模型 ID。

## 設定預設聊天模型

進入 **Config → AI → Model**，將 **Chat Model** 設為剛新增的模型，儲存設定。使用 **Test Model** 或傳送一條簡短訊息測試，再到 SimiRouter [使用記錄](https://api.dwchainless.com/usage-logs/common)核對呼叫。

圖片理解和工具呼叫需要 AstrBot、所選模型及管道同時支援；文字對話成功不代表所有擴展能力均可用。

## 官方參考

* [AstrBot 模型提供者設定](https\://docs.astrbot.app/en/providers/llm.html)
* [AstrBot 串接模型服務](https\://docs.astrbot.app/en/providers/start.html)