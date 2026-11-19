# Hermes 設定

## 準備工作

1. Hermes 已安裝並可正常啟動。
2. 在 SimiRouter 控制台已建立可用 API Key。
3. CC Switch 已安裝。

<Callout type="info" title="">
  如果尚未安裝 CC Switch，請先閱讀 [CC Switch 安裝與匯入指南](/simidoc/zh-Hant/apps/cc-switch)。
</Callout>

## 在 CC Switch 設定 Hermes

1. 打開 CC Switch，在左側應用清單中選擇 **Hermes**；舊版本使用頂部分頁。

![CC Switch 頂部切到 Hermes](/simidoc/assets/hermers/h1.png)

2. 點擊 **新增**，新增自訂供應商後，回傳 Hermes tab，選擇啟用。

![點擊新增並填寫供應商參數](/simidoc/assets/hermers/h2.png)

3. 打開終端機，輸入 `hermes desktop`，啟動桌面應用，並傳送簡短訊息測試。`--skip-build` 僅適用於已有桌面構建產物的開發環境，不用於首次啟動。

![儲存並啟用供應商](/simidoc/assets/hermers/h4.png)

4. 也可在終端機執行 `hermes --tui` 使用 TUI 模式。打開介面後傳送一條簡短訊息，並在 SimiRouter 控制台核對對應的呼叫記錄；僅顯示 TUI 介面不能證明模型連接成功。

![儲存並啟用供應商](/simidoc/assets/hermers/h5.png)

## 常見問題

* `baseUrl` 未帶 `/v1`：最常見導致模型清單不回傳的原因。
* 模型 ID 不一致：模型名稱需與實際暴露模型完全匹配。
* 仍報身分驗證/不可用：確認 API Key 與供應商綁定環境一致。

## 官方參考

[Hermes 桌面版 CLI 參考](https\://hermes-agent.nousresearch.com/docs/user-guide/desktop#cli-reference-hermes-desktop)。