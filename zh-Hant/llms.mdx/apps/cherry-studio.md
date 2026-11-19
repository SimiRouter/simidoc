# Cherry Studio設定

Cherry Studio 是支援多種模型提供者的桌面 AI 用戶端。以下說明使用 SimiRouter API Key 串接。

* 官網位址：[https\://cherry-ai.com](https\://cherry-ai.com/)
* 下載位址：[https\://cherry-ai.com/download](https\://cherry-ai.com/download)
* 官方文件：[https\://docs.cherry-ai.com](https\://docs.cherry-ai.com)

## 串接 SimiRouter

### 方式一：從金鑰頁面打開

1. 安裝並啟動 Cherry Studio，在 SimiRouter [API 金鑰管理](https://api.dwchainless.com/keys)頁面找到要使用的金鑰。
2. 點擊該金鑰右側的 **…**，選擇 **Cherry Studio**，並在瀏覽器提示時允許打開應用。
3. 在 Cherry Studio 中檢查匯入的 API 位址、金鑰和模型；API 位址應為 `https://api.dwchainless.com`。儲存後選擇帳戶可用的模型。

### 方式二：手動設定

1. 在 [API 金鑰管理](https://api.dwchainless.com/keys)頁面複製 API 金鑰；也可透過金鑰右側 **…** 中的「複製連接資訊」取得位址。
2. 打開 Cherry Studio 的 **設定 → 模型服務**，選擇 **New API**。API 位址填寫 `https://api.dwchainless.com`，API 金鑰貼上剛才複製的金鑰。
3. 點擊「管理」新增或選擇目前帳戶可用的模型，啟用提供者後回傳聊天頁面使用。

![Cherry Studio 的 API 位址和金鑰設定示意](/simidoc/assets/cherry_studio/simirouter-provider.png)

<Callout type="warn" title="保護金鑰">
  不要將 API 金鑰寫入公開截圖或分享給不可信的應用。傳送一條簡短測試訊息後，可在 SimiRouter 使用記錄核對模型和呼叫記錄。
</Callout>

## 在 Cherry Studio 中繪圖

1. 新增目前帳戶可用、且 Cherry Studio 支援其介面格式的繪圖模型
   ![Cherry Studio 新增繪圖模型的設定頁面](/simidoc/assets/cherry_studio/add_paint_models.png)

2. 在繪圖頁面選擇模型並輸入提示詞，生成後檢查結果。
   ![Cherry Studio 繪圖頁面與提示詞輸入區域](/simidoc/assets/cherry_studio/paint.png)