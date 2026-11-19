# LangBot設定

LangBot 將連接資訊儲存在提供者中，再由具體模型引用。透過 OpenAI 相容提供者可設定 SimiRouter 聊天模型。

## 建立提供者和模型

1. 按 [LangBot 官方文件](https\://docs.langbot.app/)安裝並啟動應用。
2. 從 SimiRouter [API 金鑰管理](https://api.dwchainless.com/keys)複製金鑰。
3. 在 LangBot 的模型頁面新增對話模型，選擇 OpenAI 相容供應商，或建立對應提供者。
4. 設定連接資訊：

| 欄位                | 內容                               |
| ----------------- | -------------------------------- |
| Base URL / 請求 URL | `https://api.dwchainless.com/v1` |
| API Key           | SimiRouter API Key               |
| 模型名稱              | 帳戶可用的完整模型 ID                     |

模型繼承所屬提供者的位址和金鑰。按實際模型能力開啟視覺或工具使用選項；這些開關不會賦予模型原本不具備的能力。

## 綁定流水線

在流水線中選擇剛新增的模型，儲存後通過偵錯對話或綁定的機器人傳送訊息。到 SimiRouter [使用記錄](https://api.dwchainless.com/usage-logs/common)核對請求的時間、模型和消耗。

## 知識庫與嵌入（不支援）

LangBot 的知識庫需要嵌入模型。SimiRouter 目前不支援嵌入整合，不能將本站聊天模型設定當作知識庫向量服務。需要使用知識庫時，應另行設定 LangBot 支援的嵌入提供者，或按其官方說明選擇內建方案。

## 官方參考

[LangBot 模型設定](https\://docs.langbot.app/zh/usage/models/readme)介紹提供者、聊天模型、嵌入模型和流水線的關係。