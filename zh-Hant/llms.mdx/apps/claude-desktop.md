# Claude Desktop 設定

使用 CC Switch 的**模型對應**，可以在 Claude Desktop 中選擇一個選單名稱，由 CC Switch 將請求轉發給 SimiRouter 上對應的實際模型。下面的流程基於 macOS 介面；其他系統或軟體版本的介面名稱可能略有不同。

## 準備工作

1. 安裝並打開較新版本的 Claude Desktop 用戶端。
2. 安裝支援 **Claude Desktop** 的 [CC Switch](https\://github.com/farion1231/cc-switch/releases/latest)，並打開它。
3. 登入 SimiRouter，在 [API 金鑰管理](https://api.dwchainless.com/keys)頁面建立或複製一個可用的 API Key。確認該金鑰有權限使用你想設定的模型。

<Callout type="info" title="">
  API Key 是呼叫憑證，請妥善保管，不要放進公開截圖或分享給他人。模型名稱及可用權限以 SimiRouter 控制台為準。
</Callout>

## 透過 CC Switch 設定模型對應

### 1. 新增 Claude Desktop 自訂供應商

在 CC Switch 左側選擇 **Claude Desktop**，點擊 **新增供應商**，然後選擇 **自訂設定**。注意選擇的是 Claude Desktop，而不是 Claude Code。

![在 CC Switch 中為 Claude Desktop 新增自訂供應商](/simidoc/assets/claude-desktop/cc-switch-add-provider.png)

### 2. 填寫連接資訊與模型對應

在自訂設定頁面填寫：

| 欄位      | 填寫內容                                           |
| ------- | ---------------------------------------------- |
| 名稱      | `SimiRouter`，也可以自訂                             |
| API Key | 剛才複製的 SimiRouter API Key                       |
| 請求位址    | `https://api.dwchainless.com`，末尾不加 `/` 或 `/v1` |
| 串接方式    | 選擇 **模型對應**                                    |
| 上游格式    | 選擇 **Anthropic Messages（原生）**                  |

在下方的**模型對應**中，為需要使用的角色填寫「選單顯示名」和「實際請求模型」。例如：

| 模型角色   | 選單顯示名               | 實際請求模型        |
| ------ | ------------------- | ------------- |
| Sonnet | `claude-sonnet-5-5` | `gpt-6-astra` |
| Opus   | `claude-opus-5-5`   | `gpt-6-astra` |
| Haiku  | `claude-haiku-5-5`  | `gpt-6.1-sol` |

**選單顯示名只是 Claude Desktop 中的名稱；真正呼叫的是右側「實際請求模型」。** 比如選擇顯示為 `claude-sonnet-5-5` 的選項時，上例實際請求的是 `gpt-6-astra`，並不是 Claude Sonnet。請按自己的帳戶權限，將實際請求模型換成 SimiRouter 中可用的準確模型 ID；也可以把顯示名設定為便於識別的名稱。不同版本的角色清單可能不同，以介面為準。

截圖中的 `1M` 選項僅用於向用戶端聲明上下文能力，**不要因為範例勾選就照搬**；只有在實際模型和介面均支援時才勾選。填寫完成後點擊 **新增**。

![在 CC Switch 中填寫模型對應，選單顯示名和實際請求模型分別位於兩欄](/simidoc/assets/claude-desktop/cc-switch-model-mapping.png)

截圖中的 API Key 已隱藏；實際設定時請填寫自己的金鑰。

### 3. 偵測並啟用路由

1. 回到供應商清單，在 SimiRouter 卡片右側點擊 **… → 偵測連線**，查看偵測結果。
2. 偵測正常後，點擊 SimiRouter 卡片右側的啟用按鈕（▶），按介面提示啟用路由。卡片顯示 **路由中**表示已經選取該供應商。
3. 保持 CC Switch 和本機路由服務執行。切換路由或修改模型對應後，完全結束並重新打開 Claude Desktop，使設定重新載入。

![在供應商選單中選擇偵測連線](/simidoc/assets/claude-desktop/cc-switch-test-connection.png)

![SimiRouter 供應商顯示路由中](/simidoc/assets/claude-desktop/cc-switch-routing.png)

### 4. 在 Claude Desktop 啟用開發者模式

打開 **Claude Desktop 桌面版**，在頂部選單欄選擇 **Help → Troubleshooting → Enable Developer Mode**。如果此前已啟用，可跳過此步。

![在 Claude Desktop 的 Help 選單中啟用開發者模式](/simidoc/assets/claude-desktop/claude-enable-developer-mode.png)

### 5. 檢查 CC Switch 推理設定

1. 點擊 Claude Desktop 左下角的帳戶選單，選擇 **Inference configuration**，打開 **Configure third-party inference**。
2. 查看右上角設定清單，確認選擇的是 **CC Switch**；如果有多個設定，請選擇 CC Switch。若顯示 **applied**，表示該設定已應用；如有未應用的更改，按介面提示點擊 **Apply Changes**。
3. 在 **Connection** 頁面點擊 **Test Connection**。出現綠色成功提示後，關閉設定視窗。

![在帳戶選單中打開 Inference configuration](/simidoc/assets/claude-desktop/claude-inference-menu.png)

![確認第三方推理設定選擇 CC Switch 並已應用](/simidoc/assets/claude-desktop/claude-cc-switch-profile.png)

截圖中的閘道金鑰已隱藏；請保留 CC Switch 自動設定的值，不要將其清空。

<Callout type="info" title="">
  CC Switch 設定中的閘道位址指向本機路由，與第 2 步填寫的 SimiRouter 請求位址不同；通常無需手動修改閘道位址或閘道金鑰。連接測試成功只說明連接偵測通過，並不能代替一次實際模型呼叫。
</Callout>

### 6. 選擇模型並驗證

1. 新建對話，在輸入框旁的模型選單中選擇剛才設定的**選單顯示名**，傳送一條簡短訊息。真實呼叫可能產生費用。
2. 收到回覆後，前往 SimiRouter 控制台的呼叫記錄，核對請求時間、**實際模型**和用量。模型的自述身分和 Claude Desktop 顯示名不能證明實際呼叫了哪個模型。

## 常見問題

### 找不到 Claude Desktop 或開發者模式

* 確認使用的是支援 Claude Desktop 的較新版本 CC Switch，並在左側選擇 **Claude Desktop**。
* 在 Claude Desktop 的 **Help → Troubleshooting** 中啟用 **Enable Developer Mode**；找不到入口時嘗試更新用戶端。

### 看不到 CC Switch 設定或模型沒有更新

* 確認 SimiRouter 卡片顯示 **路由中**，並保持 CC Switch 及本機路由服務執行。
* 完全結束並重新打開 Claude Desktop，再檢查左下角 **Inference configuration** 中的設定。不同版本也可能通過 **Developer → Configure third-party inference** 打開該頁面。
* 確認模型對應中的「選單顯示名」已填寫，且已選取 **CC Switch** 設定。修改對應或切換供應商後重新啟動 Claude Desktop。

### 偵測失敗或對話發生錯誤

* 檢查 CC Switch 中的 API Key 是否完整、有效，且請求位址為 `https://api.dwchainless.com`。
* 確認已選擇 **Anthropic Messages（原生）** 上游格式，並檢查網路與本機路由服務狀態。
* 核對「實際請求模型」的 ID、金鑰群組和模型權限；不要只檢查選單顯示名。
* 根據錯誤資訊檢查帳戶額度和模型相容性。連接偵測通過也不保證所有模型或功能都可用。

## 其他設定方式

### 選用：原有直連設定

以下保留原有的直連步驟，未在目前用戶端版本重新驗證，欄位和介面可能有所變化；如果已按上面的 CC Switch 流程設定，無需重複操作。模型是否能在直連模式中使用，以用戶端實際支援情況為準。

先在 **Help → Troubleshooting** 中啟用開發者模式，然後：

1. 在頂部選單欄進入 **Developer → Configure third-party inference**。
2. 按照下表填寫設定：

| 欄位                    | 填寫內容                                                       |
| --------------------- | ---------------------------------------------------------- |
| Base URL              | `https://api.dwchainless.com`                              |
| API Key               | 你的 SimiRouter API Key，例如 `sk-...`                          |
| Authentication method | 選擇 `x-api-key`                                             |
| Provider / API format | 如果介面出現該選項，選擇 `Anthropic-compatible`、`custom gateway` 或類似選項 |

<Callout type="warn" title="">
  Claude Desktop 的 Base URL 請填寫 `https://api.dwchainless.com`。這是 Claude Desktop 的第三方推理設定位址；不要把 Claude CLI 文件中的 `ANTHROPIC_BASE_URL` 環境變數寫法直接複製到這裡。
</Callout>

3. 選擇 **Apply locally**，將設定儲存到目前電腦。
4. 按用戶端提示繼續登入或啟動 Claude Desktop。

## 官方參考

* [CC Switch：Claude Desktop 設定說明](https\://github.com/farion1231/cc-switch-website/blob/main/public/docs/en/2-providers/2.6-claude-desktop.md)
* [Anthropic Docs：Claude Cowork 第三方平台設定](https\://claude.com/docs/third-party/claude-desktop/overview)