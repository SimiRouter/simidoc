# Memoh設定

Memoh 是支援獨立工作環境和長期記憶的開放原始碼多智慧代理平台。聊天模型與語音、轉錄模型使用不同的用戶端型別，不能共用同一種通訊協定設定。

## 安裝 Memoh

按 [Memoh 官方部署說明](https\://docs.memoh.ai/self-hosted/docker)安裝目前版本。首次登入後完成帳戶安全設定；不要沿用舊版教學中的預設密碼。

## 新增提供者

1. 在 SimiRouter [API 金鑰管理](https://api.dwchainless.com/keys)建立金鑰。
2. 打開 Memoh 設定側欄的 **Models** 頁面，選擇 **Add Provider**。
3. 使用 OpenAI Chat Completions 模板，或建立自訂提供者：

| 欄位          | 內容                               |
| ----------- | -------------------------------- |
| Name        | `SimiRouter`                     |
| Client Type | `openai-completions`             |
| Base URL    | `https://api.dwchainless.com/v1` |
| API Key     | SimiRouter API Key               |

`openai-responses` 對應 Responses 通訊協定，`openai-completions` 對應 Chat Completions；不要僅憑名稱將後者當作舊文字補全介面。OAuth 登入型別不能代替 SimiRouter API Key 提供者。

## 新增並啟用模型

在提供者詳情中點擊 **Import Models** 匯入，或手動填寫帳戶可用的模型 ID。批量匯入的模型預設可能未啟用，需要打開模型開關，再到機器人設定中選擇該聊天模型。

傳送一條簡短訊息，並到 SimiRouter [使用記錄](https://api.dwchainless.com/usage-logs/common)核對對應請求。Memoh 的記憶、搜尋等功能可能需要額外提供者；SimiRouter 目前不支援嵌入整合，不能使用聊天模型代替向量模型。

## 官方參考

* [Memoh 提供者與模型](https\://docs.memoh.ai/integrations/providers/llm)
* [Memoh 項目](https\://github.com/felinics/Memoh)