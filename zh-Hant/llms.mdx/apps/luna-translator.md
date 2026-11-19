# LunaTranslator設定

<Callout type="info" title="">
  LunaTranslator
  是一款開放原始碼免費的視覺小說（GalGame）翻譯器，致力於提供母語級別的視覺小說遊玩體驗。
</Callout>

* 項目位址：[https\://github.com/HIllya51/LunaTranslator](https\://github.com/HIllya51/LunaTranslator)
* 項目文件：[https\://docs.lunatranslator.org](https\://docs.lunatranslator.org/zh/README.html)

## 功能支援

* **HOOK** 主要使用HOOK提取遊戲文字，用於支援的視覺小說；具體相容情況見官方文件

* **內嵌翻譯** 部分遊戲還可以直接內嵌翻譯到遊戲中，以取得沉浸式體驗

* **HOOK模擬器** 對支援的模擬器和遊戲，透過 HOOK 讀取遊戲文字

* **OCR** 內建較高精度的OCR模型，並支援許多其他線上&離線OCR引擎，以便靈活地讀取任意文字

* **豐富的翻譯介面** 可設定多種大語言模型與離線翻譯介面

* **語言學習** 支援日語斷詞及假名注音，支援AnkiConnect，支援Yomitan外掛程式

* **語音合成** 支援大量線上&離線語音合成引擎

* **語音識別** 在Windows 10和Windows 11上，可以使用Windows語音識別。

## 安裝方式

在 [LunaTranslator 文件- 下載 & 啟動 & 更新](https\://docs.lunatranslator.org/zh/README.html) 進行下載安裝

## 在 LunaTranslator 手動串接 SimiRouter

1. 在 SimiRouter [API 金鑰管理](https://api.dwchainless.com/keys)頁面複製要使用的 API Key。
2. 在 LunaTranslator 的 **設定 → 翻譯設定 → 大模型**中選擇新增，複製「大模型通用介面」模板並新增介面。
3. 打開新增介面的設定，**API 介面位址**填寫 `https://api.dwchainless.com`，**API Key** 貼上複製的金鑰；重新整理模型清單或輸入帳戶可用的完整模型 ID。
4. 儲存並啟用該介面。先翻譯一小段非敏感文字，再到 SimiRouter 使用記錄核對呼叫記錄。

不要將金鑰放在公開截圖中。不同版本的選項名稱可能略有差異；詳細設定參見 [LunaTranslator 官方文件](https\://docs.lunatranslator.org/zh/guochandamoxing.html)。