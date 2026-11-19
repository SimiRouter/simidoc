# Chatbox AI 設定

本教學以 Chatbox AI 1.21.1 桌面介面為例，透過內建的 **OpenAI** 模型提供者連接 SimiRouter。其他版本的介面名稱和位置可能不同；下方截圖為中文介面示意。

<Callout type="warn" title="保護 API 金鑰">
  API 金鑰是呼叫憑證，不要分享給他人或展示在公開截圖中。連接檢查和實際對話可能產生費用，請先確認帳戶額度和模型價格。
</Callout>

## 準備工作

1. 從 [Chatbox AI 官網](https\://chatboxai.app/)下載並安裝用戶端。
2. 登入 SimiRouter，在 [API 金鑰管理](https://api.dwchainless.com/keys)頁面建立或複製金鑰，並確認帳戶有使用目標模型的權限和額度。

![SimiRouter 的 API 金鑰管理頁面，金鑰資訊已遮擋](/simidoc/assets/chatbox/03a-create-api-key.png)

## 設定連接

### 1. 打開設定並選擇提供者

在 Chatbox 主介面點擊左下角 **設定**。

![打開 Chatbox 設定](/simidoc/assets/chatbox/01-open-settings.png)

進入 **模型提供者**，選擇 **OpenAI**。本教學使用 API 金鑰，無需透過 OAuth 登入。此操作會更改 OpenAI 提供者的設定；如果你已用它連接其他服務，請先記錄原有設定，避免意外覆蓋。

![在模型提供者中選擇 OpenAI](/simidoc/assets/chatbox/02-select-openai.png)

### 2. 填寫 API 金鑰和主機

| 設定項    | 填寫內容                                              |
| ------ | ------------------------------------------------- |
| API 金鑰 | 貼上剛才複製的 SimiRouter 金鑰                             |
| API 主機 | `https://api.dwchainless.com`                     |
| 請求位址預覽 | `https://api.dwchainless.com/v1/chat/completions` |

API 主機按上表填寫，保留預設 API 路徑，不要在主機後再手動串接介面路徑。如果之前自訂過 API 路徑，請恢復預設並檢查預覽位址。

![在 OpenAI 提供者中填寫 API 金鑰和主機](/simidoc/assets/chatbox/03b-fill-api-fields.png)

### 3. 取得並新增模型

在模型區域點擊 **取得**，搜尋並點擊模型右側的 **+** 新增。如果無法取得清單，可使用 **新建**，手動填寫帳戶可用的準確模型 ID。清單中的模型不一定都已對目前金鑰開放，請以帳戶權限和模型清單為準。

![搜尋並新增模型](/simidoc/assets/chatbox/04-add-models.png)

### 4. 檢查連接並開始對話

對要使用的模型點擊 **檢查**。測試結果為“連接成功”時，仍建議傳送一條簡短訊息驗證實際對話。部分模型只支援文字；圖片或工具呼叫檢查未通過，不一定意味著文字不可用。

![範例模型的連接檢查結果](/simidoc/assets/chatbox/05-check-success.png)

關閉設定，點擊 **新對話**，在輸入框旁的模型選擇選單中選擇剛新增的 OpenAI 群組模型，傳送一條簡短訊息。收到回覆後，可在 SimiRouter 使用記錄中核對請求和實際模型。

![新建對話並選擇新增的模型](/simidoc/assets/chatbox/06-new-chat-select-model.png)

## 常見問題

* **取得模型失敗：** 檢查網路、主機位址和金鑰；也可使用準確模型 ID 手動新增。
* **401 或驗證失敗：** 檢查金鑰是否完整、有效，前後是否有空格；必要時重新建立金鑰。
* **404 或路徑錯誤：** 核對請求位址預覽，恢復預設 API 路徑，避免重複串接路徑。
* **模型不存在或無法對話：** 核對實際模型 ID、金鑰權限和帳戶額度，並確認對話中選擇了正確模型。
* **圖片或工具呼叫失敗：** 檢查模型和介面是否支援相應能力；僅需文字時，可單獨驗證文字請求。

參考：[Chatbox OpenAI 位址與路徑處理](https\://github.com/chatboxai/chatbox/blob/main/src/shared/utils/llm_utils.ts)。