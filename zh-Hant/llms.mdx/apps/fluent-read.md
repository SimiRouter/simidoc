# FluentRead設定

<Callout type="info" title="">
  🌊
  流暢閱讀（FluentRead）是一款開放原始碼瀏覽器翻譯外掛程式，致力於提供母語般的閱讀體驗。
</Callout>

* 項目位址：[https\://github.com/FluentRead/FluentRead](https\://github.com/FluentRead/FluentRead)

## 核心特性

### 智慧翻譯引擎

* **多引擎支援**：支援多種翻譯引擎
* **傳統翻譯**：微軟翻譯、谷歌翻譯、DeepL翻譯等
* **AI 大模型**：OpenAI、DeepSeek、Kimi、Ollama等
* **自訂引擎**：支援自訂翻譯服務設定

### 沉浸式閱讀體驗

* **雙語對照**：原文與譯文並列顯示，閱讀更輕鬆
* **划詞翻譯**：選取任意文字，即時獲得翻譯結果
* **一鍵複製**：快速複製譯文，提高閱讀效率
* **全文翻譯**：懸浮球一鍵翻譯整個網頁，無需重新整理頁面

### 隱私與定制

* **資料與隱私**：使用線上翻譯或雲端模型時，待翻譯內容會傳送到您設定的服務。請核對該服務的資料處理規則，不要將敏感資訊傳送給未經信任的提供者。
* **高度定制**：豐富的自訂選項，滿足不同場景需求
* **完全免費**：開放原始碼免費，非商業化項目

## 安裝方式

| 瀏覽器         | 安裝方式                                                                                                                                                                                                                                     |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Chrome**  | [Chrome 應用商店](https\://chromewebstore.google.com/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/djnlaiohfaaifbibleebjggkghlmcpcj?hl=zh-CN\&authuser=0) \| [國內鏡像](https\://www.crxsoso.com/webstore/detail/djnlaiohfaaifbibleebjggkghlmcpcj) |
| **Edge**    | [Edge 應用商店](https\://microsoftedge.microsoft.com/addons/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/kakgmllfpjldjhcnkghpplmlbnmcoflp?hl=zh-CN)                                                                                           |
| **Firefox** | [Firefox 附加元件商店](https\://addons.mozilla.org/zh-CN/firefox/addon/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/)                                                                                                                                  |

## 設定方法

### 在流暢閱讀中手動填寫設定

在 [API 金鑰管理](https://api.dwchainless.com/keys)頁面複製金鑰，打開流暢閱讀的設定並填寫：

| 設定項       | 內容                                      |
| --------- | --------------------------------------- |
| 翻譯服務      | New API                                 |
| 存取權杖      | 剛複製的 SimiRouter API 金鑰                  |
| NewAPI 介面 | `https://api.dwchainless.com`（不帶 `/v1`） |
| 模型        | 選擇或填寫帳戶可用的完整模型 ID                       |

儲存後先翻譯一小段非敏感文字，再到 SimiRouter 使用記錄核對呼叫記錄。線上翻譯會向所設定服務傳送待翻譯內容。