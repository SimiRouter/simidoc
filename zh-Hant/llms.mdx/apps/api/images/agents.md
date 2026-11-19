# 智慧代理圖片呼叫已合併到協議文件

智慧代理呼叫任務已分散到三個協議，每個協議均有生成和編輯模板、配置準備、結果儲存與失敗處理，不再單獨維護一套偏向 OpenAI Images 的教學：

* [OpenAI 格式的智慧代理呼叫](/simidoc/zh-Hant/apps/api/images/openai)：Images 生成、JSON 編輯及最終事件檢查。
* [Gemini 原生格式的智慧代理呼叫](/simidoc/zh-Hant/apps/api/images/gemini)：GenerateContent 圖片 Part、MIME 與多輪上下文。
* [Qwen 原生格式的智慧代理呼叫](/simidoc/zh-Hant/apps/api/images/qwen)：百煉區域配置、原生同步呼叫和圖片 URL 下載。

智慧代理仍須具備本地執行和回傳結果檢查能力；這些文件不會安裝遠端 Skill。真實請求可能收費，呼叫前確認模型、規格、數量和輸出位置；不洩露金鑰、不覆蓋檔案、不自動重試。介面、效果與規格比較見[圖片 API 總覽](/simidoc/zh-Hant/apps/api/images)。