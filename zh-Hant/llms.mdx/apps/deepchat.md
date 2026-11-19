# DeepChat設定

DeepChat 是支援雲端與本機模型的開放原始碼 AI 用戶端。工具呼叫等擴展能力需所選模型和提供者支援。

* 官網位址：[https\://deepchat.thinkinai.xyz](https\://deepchat.thinkinai.xyz)
* GitHub 倉庫：[https\://github.com/ThinkInAIXYZ/deepchat](https\://github.com/ThinkInAIXYZ/deepchat)
* 下載位址：[https\://deepchat.thinkinai.xyz/#/download](https\://deepchat.thinkinai.xyz/#/download)

## 手動串接 SimiRouter

1. 在 SimiRouter 的 [API 金鑰管理](https://api.dwchainless.com/keys)頁面複製要使用的 API Key。

2. 打開 DeepChat 的 **設定 → 服務商設定**，選擇 New API 或新增相容服務商。**API URL 填寫 `https://api.dwchainless.com`**，API Key 貼上剛才複製的金鑰。

   ![DeepChat 中填寫 SimiRouter 位址和 API Key 的示意](/simidoc/assets/deepchat/simirouter-manual.png)

3. 驗證金鑰、重新整理或新增模型，啟用服務商並選擇帳戶可用的模型。傳送一條簡短訊息後，可在 SimiRouter 使用記錄核對對應呼叫記錄。

<Callout type="warn" title="保護金鑰">
  請勿把 API Key 放入公開截圖或分享給不可信的應用。用戶端介面可能隨版本變化，請以實際顯示的欄位為準。
</Callout>

## 相關連結

* [DeepChat GitHub 倉庫](https\://github.com/ThinkInAIXYZ/deepchat)
* [DeepChat 下載頁面](https\://deepchat.thinkinai.xyz/#/download)