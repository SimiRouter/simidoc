# 註冊 SimiRouter Key

這篇指南介紹如何註冊或登入 SimiRouter、建立 API Key，並完成第一次呼叫。已有帳戶可以直接登入，具體用戶端操作和 API 參數分別放在對應文件中。

## 1. 註冊或登入 SimiRouter

前往 [註冊頁面](https://api.dwchainless.com/sign-up) 建立帳戶；已有帳戶可直接 [登入](https://api.dwchainless.com/sign-in)。註冊方式與是否開放註冊以頁面實際顯示為準。

登入後打開 [錢包](https://api.dwchainless.com/wallet)，確認帳戶有可用額度，且所選模型在帳戶群組與金鑰權限內。需要儲值或使用兌換碼時，依錢包頁的提示操作；套餐、到帳額度和有效期以目前頁面為準，不要重複付款。

## 2. 建立 API 金鑰

打開 [API 金鑰管理](https://api.dwchainless.com/keys)，選擇「建立金鑰」。按需設定群組、模型權限、額度和有效期；不確定的選項先核對頁面說明，再儲存並複製金鑰。

![API 金鑰管理頁面與建立入口](/simidoc/assets/start/start5.png)

<Callout type="warn" title="保護金鑰">
  API 金鑰代表呼叫權限。不要放進公開倉庫、截圖或記錄，不要發給不可信的應用；懷疑洩露時立即撤銷並重新建立。
</Callout>

## 3. 分清三項串接資訊

| 資訊                | 用途       | 注意                                         |
| ----------------- | -------- | ------------------------------------------ |
| API 位址 / Base URL | 決定請求發到哪裡 | 按用戶端教學填寫；有的需要 `/v1`，有的需要根位址，不要重複追加路徑。      |
| API Key           | 驗證呼叫權限   | 使用剛建立的金鑰，不是登入密碼。                           |
| 模型名稱              | 選擇呼叫的模型  | 在 [模型廣場](https://api.dwchainless.com/zh-Hant/pricing/) 複製完整模型 ID；名稱、群組與權限需要匹配。 |

介面位址、金鑰和模型名稱是三個獨立欄位；不要把金鑰拼進位址。

## 4. 選擇正在使用的用戶端

* [Codex 桌面版](/simidoc/zh-Hant/apps/codex-desktop)：桌面程式開發工作流程。
* [Codex CLI](/simidoc/zh-Hant/apps/installation/codex-cli)：命令列安裝與串接。
* [Claude Code](/simidoc/zh-Hant/apps/installation/claude-code)：安裝、環境設定與使用。
* [WorkBuddy](/simidoc/zh-Hant/apps/workbuddy)：桌面自訂模型串接。
* [API 指令碼](/simidoc/zh-Hant/apps/api-script)：透過請求範例整合自己的程式。

每個用戶端的欄位與通訊協定不同，以對應教學為準；不能把一個用戶端的設定檔直接套給另一個。

## 5. 發起小規模測試並核對記錄

儲存設定後，先傳送一條簡短請求。再打開 [使用記錄](https://api.dwchainless.com/usage-logs/common)，核對請求時間、模型、狀態和消耗。超級管理員可查看全域記錄；管理員可查看自己的請求、儲值、管理操作與錯誤記錄；一般使用者只能查看自己的請求、儲值及管理操作相關記錄，不能查看錯誤記錄。需要匯總趨勢時查看 [資料看板](https://api.dwchainless.com/dashboard)。

模型能回覆，只能說明這次請求回傳了結果；不能只憑回覆內容確認實際路由。失敗時，先核對位址、金鑰、完整模型 ID 和群組權限，再根據具體錯誤與請求 ID 排查。向客服提供脫敏資訊，不要附上金鑰。