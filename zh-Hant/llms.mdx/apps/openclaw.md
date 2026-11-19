# OpenClaw 設定

## 準備工作

1. OpenClaw 已安裝並可正常啟動。
2. 在 SimiRouter 控制台已建立可用 API Key。
3. CC Switch 已安裝。

<Callout type="info" title="">
  如果尚未安裝 CC Switch，請先閱讀 [CC Switch 安裝與匯入指南](/simidoc/zh-Hant/apps/cc-switch)。
</Callout>

## 在 CC Switch 設定 OpenClaw

1. 打開 CC Switch，在左側應用清單中選擇 **OpenClaw**；舊版本使用頂部分頁。

![CC Switch 頂部切到 OpenClaw](/simidoc/assets/cc/cc1.png)

2. 點擊 **新增**，新增自訂供應商。

![點擊新增並填寫供應商參數](/simidoc/assets/cc/cc2.png)

3. 儲存後，確認供應商已啟用。在終端機執行 `openclaw onboard`，按提示完成 OpenClaw 的初始設定與配對。

![儲存並啟用供應商](/simidoc/assets/cc/cc4.png)

4. 傳送一條簡短訊息，確認收到正常回覆，再到 SimiRouter 控制台核對對應的呼叫記錄。僅看到設定介面或截圖中的紅框，不能證明模型串接成功。
   ![儲存並啟用供應商](/simidoc/assets/cc/cc3.png)

## 常見問題

* `baseUrl` 未帶 `/v1`：最常見導致模型清單不回傳的原因。
* 模型 ID 不一致：模型名稱需與實際暴露模型完全匹配。
* 仍報身分驗證/不可用：確認 API Key 與供應商綁定環境一致。
* 想看更詳細記錄：可使用前台執行方式 `openclaw gateway --port 18789` 查看啟動記錄。

## 官方參考

[CC Switch 官方項目](https\://github.com/farion1231/cc-switch)。