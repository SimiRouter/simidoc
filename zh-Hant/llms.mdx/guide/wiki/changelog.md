# 更新記錄

<Callout type="warn" title="版本記錄資訊 · 資料更新於 2026-8-12 18:48:26">
  如需查看全部歷史版本，請存取 [GitHub Releases 頁面](https\://github.com/QuantumNous/new-api/releases)。本頁內容並非即時資料，最近一次同步時間見本提示標題；上游發佈節奏快於本頁時，以上游為準。
</Callout>

## v1.0.0-rc.24

<Callout type="info" title="本頁最新記錄 · 發佈於 2026-08-07 17:47:48 (中國時間)">
  ### 版本：v1.0.0-rc.24

  #### 新增功能

  * 為存取權杖和推廣回饋轉帳路由新增使用者關鍵操作限流中介軟體，提高安全性與穩定性。
  * 優化管道中取得模型的分類，便於組織和尋找。

  #### 問題修復

  * 修復兌換碼額度精度損失，確保準確分配額度（#6685）。
  * 透過正確設定 `Request.GetBody`，修復上游流重置後 HTTP/2 傳輸無法透明重試的問題（#6249）。
  * 確保 Claude 和 Gemini 端點使用原生請求格式進行測試，提高相容性。

  #### 其他

  * 增強版本同步工作流程，支援在 CI 中選擇性同步檔案。

  ***

  ### 變更內容

  * fix(relay)：設定 Request.GetBody，使 HTTP/2 在上游流重置後可透明重試，由 @BlockchainHe 提交於 [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * feat(channels)：優化取得模型的分類，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6632](https\://github.com/QuantumNous/new-api/pull/6632)
  * fix：使用原生格式測試 Claude/Gemini 端點，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6698](https\://github.com/QuantumNous/new-api/pull/6698)
  * fix\: 修復兌換碼額度精度損失(#6680)，由 @lihu-001 提交於 [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  ### 新貢獻者

  * @BlockchainHe 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * @lihu-001 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-arm64-v1.0.0-rc.24) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-macos-v1.0.0-rc.24) (132.6 MB)
  * [new-api-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24) (113.2 MB)
  * [new-api-v1.0.0-rc.24.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24.exe) (115.1 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.tar.gz)
</Callout>

***

## v1.0.0-rc.23

<Callout type="note" title="正式版本 · 發佈於 2026-08-01 23:25:04 (中國時間)">
  重點更新：擴展 New API 管道、DeepSeek Responses API、zstd 請求解壓和自動群組路由的相容性；記錄可顯示串流狀態，階梯重試計費更可靠，並在用戶端斷開時取消 Bedrock 上游請求。

  ### 新增功能

  * 支援 New API 管道，包括 Gemini 轉 OpenAI 串流轉換、Advanced Custom Responses Compact 處理和 multipart 影像編輯（#6559）。
  * 支援 DeepSeek Responses API（#6562）。
  * 支援請求路由自動選擇群組（#6590）。
  * 新增按管道設定的 HTTP 傳輸控制，便於調整連接行為。
  * 支援 zstd 壓縮請求（#6545）。
  * 記錄所屬使用者現在可以查看請求是否採用串流（#6558）。

  ### 問題修復

  * Qwen `thinking_budget` 現在會在請求轉發時保留（#5836）。
  * 階梯重試計費按最終選擇的群組結算，包括重試時切換群組的情況（#6570）。
  * 用戶端斷開時取消 Bedrock 請求，減少無效上游工作（#6589）。

  ### 改進

  * 統一公共頁頭導覽連結的字級（#6557）。

  ***

  ### 變更內容

  * refactor：將通訊協定轉換層提取為獨立 relaykit 模組，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/6369](https\://github.com/QuantumNous/new-api/pull/6369)
  * fix\: 慢查詢/錯誤 SQL 記錄參數化，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6493](https\://github.com/QuantumNous/new-api/pull/6493)
  * feat(oidc)\: 支援自訂 OIDC 登入顯示名稱，由 @mrchi 提交於 [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * fix：保留 Qwen thinking\_budget 透傳，由 @wxwwt 提交於 [https\://github.com/QuantumNous/new-api/pull/5836](https\://github.com/QuantumNous/new-api/pull/5836)
  * feat：支援 zstd 請求解壓，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6545](https\://github.com/QuantumNous/new-api/pull/6545)
  * feat(logs)：向記錄所屬使用者展示串流狀態，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6558](https\://github.com/QuantumNous/new-api/pull/6558)
  * fix(relay)：保留 New API 管道的 multipart 影像編輯，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6559](https\://github.com/QuantumNous/new-api/pull/6559)
  * fix(oauth)：不再將外部 window\.opener 當作綁定流程，由 @neimaravila 提交於 [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * style：將公共頁頭導覽字級統一為 14px（text-sm），由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6557](https\://github.com/QuantumNous/new-api/pull/6557)
  * feat：支援 DeepSeek Responses API，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6562](https\://github.com/QuantumNous/new-api/pull/6562)
  * fix(billing)：階梯重試按最終群組結算，由 @faithleysath 提交於 [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)
  * fix(billing)：加強階梯重試切換群組計費（#6518 後續修復），由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/6570](https\://github.com/QuantumNous/new-api/pull/6570)
  * fix(aws)：用戶端斷開時取消 Bedrock 請求，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/6589](https\://github.com/QuantumNous/new-api/pull/6589)
  * 功能：自動群組，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/6590](https\://github.com/QuantumNous/new-api/pull/6590)

  ### 新貢獻者

  * @mrchi 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * @neimaravila 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * @faithleysath 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-arm64-v1.0.0-rc.23) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-macos-v1.0.0-rc.23) (132.6 MB)
  * [new-api-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23) (113.2 MB)
  * [new-api-v1.0.0-rc.23.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23.exe) (115.0 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.tar.gz)
</Callout>

***

## v1.0.0-rc.22

<Callout type="note" title="正式版本 · 發佈於 2026-07-26 21:19:04 (中國時間)">
  擴展管道和模型管理，支援上游模型發現、新版 Gemini 影像模型、可設定計費和 Sub2API；改善串流、價格、退款、使用者管理及管理介面的可靠性。

  ### 新增功能

  * 管道可從高級自訂及 Codex 相容上游發現可用模型（#6184）。
  * 支援最新 Gemini 影像正式版模型（#6371）。
  * 支援可設定工具價格、Sub2API 管道和 alpha-search 計費。
  * 支援 OpenAI Realtime 正式版模型，改善路由相容性（#6032）。

  ### 問題修復

  * 修復 Responses 轉 Chat 串流回應重複產生工具呼叫（#6225）。
  * 建立同名模型不再清空已有價格（#6365）。
  * 未設定價格的模型視圖僅列出所選管道中的可用模型（#6126）。
  * 修復超大使用者額度的數值溢出（#6134）。
  * 分頁結果中的使用者清單排序正常工作（#6194）。
  * 將 MiniMax 模型正確歸屬到 MiniMax 廠商（#6164）。
  * 修復 Playground 群組選取器的自動群組清單和長選項（#6163）。
  * 並行狀態更新不再重複退還任務費用（#6074）。
  * 編輯儲值金額時可完全清空輸入框（#6473）。
  * 提高管道行內優先順序更新的可靠性（#6415）。

  ### 改進

  * 統一管理端 JSON 編輯體驗，避免內容被介面問題隱藏（#6421）。
  * 使用者搜尋加入防抖，減少無效請求並提高回應速度（#6474）。
  * 改善代理管道請求的相容性和穩定性（#6157）。
  * 上游錯誤不明確時提供更有用的兜底記錄（#6431）。

  ***

  ### 變更內容

  * fix：未定價模型清單僅顯示管道可用模型，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6126](https\://github.com/QuantumNous/new-api/pull/6126)
  * fix：永久刪除使用者時清理驗證資料，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6168](https\://github.com/QuantumNous/new-api/pull/6168)
  * fix(users)：防止超大額度溢出，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/6134](https\://github.com/QuantumNous/new-api/pull/6134)
  * fix：識別 MiniMax 模型的廠商歸屬，由 @fux-dev 提交於 [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * fix：使用者清單改為伺服器端排序，避免僅排序目前頁，由 @DawnMoon1542 提交於 [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * fix(data-table)：切換列時立即更新表格內容，由 @DawnMoon1542 提交於 [https\://github.com/QuantumNous/new-api/pull/6253](https\://github.com/QuantumNous/new-api/pull/6253)
  * fix：防止 Responses 轉 Chat 串流工具呼叫重複，由 @nikuleo 提交於 [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * feat(channel)：支援 Codex 上游模型發現，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6184](https\://github.com/QuantumNous/new-api/pull/6184)
  * feat：支援高級自訂管道取得上游模型，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5971](https\://github.com/QuantumNous/new-api/pull/5971)
  * refactor(auth)：以無狀態權杖及工作階段控制替換面板工作階段，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/6329](https\://github.com/QuantumNous/new-api/pull/6329)
  * fix\: 中轉 gpt-realtime 系列 GA 模型時不再傳送 realtime beta 識別碼，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6032](https\://github.com/QuantumNous/new-api/pull/6032)
  * fix(playground)：防止群組選項被拉伸，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/6120](https\://github.com/QuantumNous/new-api/pull/6120)
  * perf(data-table)：優化操作欄寬度分配，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/6135](https\://github.com/QuantumNous/new-api/pull/6135)
  * fix(web)：顯示無限額 API Key 的已用額度，由 @RedwindA 提交於 [https\://github.com/QuantumNous/new-api/pull/6224](https\://github.com/QuantumNous/new-api/pull/6224)
  * fix(channel)：改善代理相容性和快取生命週期，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/6157](https\://github.com/QuantumNous/new-api/pull/6157)
  * fix(playground)：修復自動群組模型清單，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/6163](https\://github.com/QuantumNous/new-api/pull/6163)
  * fix：透過 CAS 狀態更新防止 Suno 任務重複退款，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6074](https\://github.com/QuantumNous/new-api/pull/6074)
  * chore(github)：將議題模板遷移為必填表單，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6452](https\://github.com/QuantumNous/new-api/pull/6452)
  * fix(github)：恢復議題表單可見性，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6454](https\://github.com/QuantumNous/new-api/pull/6454)
  * fix：上游錯誤訊息解析為空時記錄回應主體，由 @bigsongeth 提交於 [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)
  * fix：建立同名模型時保留已有價格，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6365](https\://github.com/QuantumNous/new-api/pull/6365)
  * fix(web/channel)：穩定行內優先順序更新，由 @RedwindA 提交於 [https\://github.com/QuantumNous/new-api/pull/6415](https\://github.com/QuantumNous/new-api/pull/6415)
  * perf(json-editor)：統一管理端 JSON 編輯體驗，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/6421](https\://github.com/QuantumNous/new-api/pull/6421)
  * feat：新增 gemini-3-pro-image 和 gemini-3.1-flash-image 正式版模型，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6371](https\://github.com/QuantumNous/new-api/pull/6371)
  * feat：透過 OpenAI 相容通訊協定支援騰訊 TokenHub API Key，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6232](https\://github.com/QuantumNous/new-api/pull/6232)
  * fix：允許完全清空儲值金額輸入，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6473](https\://github.com/QuantumNous/new-api/pull/6473)
  * fix：使用者搜尋輸入加入防抖，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6474](https\://github.com/QuantumNous/new-api/pull/6474)

  ### 新貢獻者

  * @fux-dev 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * @DawnMoon1542 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * @nikuleo 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * @bigsongeth 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-arm64-v1.0.0-rc.22) (109.9 MB)
  * [new-api-macos-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-macos-v1.0.0-rc.22) (132.4 MB)
  * [new-api-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22) (113.0 MB)
  * [new-api-v1.0.0-rc.22.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22.exe) (114.9 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.tar.gz)
</Callout>

***

## v1.0.0-rc.21

<Callout type="note" title="正式版本 · 發佈於 2026-07-11 23:01:26 (中國時間)">
  ### 重點更新

  重點更新為 GPT-5.6 快取寫入計費：OpenAI 的 `cache_write_tokens` 按快取建立價格計費，並保護快取及非快取輸入 Token 的計量一致性。同時改進定價流程、Playground 控制項、管道表格以及計費和記錄可靠性。

  ### 新增功能

  * 支援 GPT-5.6 快取寫入計費，將 OpenAI 的 `cache_write_tokens` 按快取建立價格結算，並保持快取及非快取輸入 Token 計量一致。
  * 定價頁面支援按群組動態計算，不再顯示僅用於範例的特殊群組（#5906）。
  * 模型價格設定新增未定價模型頁及狀態、同步篩選，便於尋找未定價模型（#6124）。
  * Playground 新增聊天和生成參數面板，可直接調整模型行為（#6044）。
  * 管道清單支援手動調整欄寬，並保持表格填滿可用寬度（#5948）。
  * 記錄顯示串流時間指標和任務詳情，便於排錯。
  * 增強文字通訊協定轉換和高級自訂路由，提高管道設定靈活性（#5825）。

  ### 問題修復

  * 防止瀏覽器翻譯破壞 React 頁面（#5963）。
  * 可一致地新增僅大小寫不同的自訂模型名稱，包括多選控制項（#6061）。
  * 改善額度預扣和影像流斷連邊界的計費處理。
  * 提高並行更新時訂閱重置的可靠性（#6057）。
  * 正確同步 Codex Responses 透傳欄位（#6018）。
  * 模型變更後 Playground 模型選取器保持同步。
  * 自訂首頁 iframe 可在使用者操作後進行頂層導覽（#5955）。
  * 恢復預設管道連接設定的貼上行為。

  ### 改進

  * 優化模型價格中上游價格同步表格的載入和渲染（#6092）。
  * 改善表格徽標、價格版面配置、同步對話框和預設主題樣式，使管理介面更清晰。
  * 修復不同工作區版面配置中的字型資源解析。

  ***

  ### 變更內容

  * fix(web)：防止瀏覽器翻譯修改 React 根節點，由 @cat0825 提交於 [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)
  * feat(web)\: 支援管道清單手動調整欄寬，由 @zuiho-kai 提交於 [https\://github.com/QuantumNous/new-api/pull/5948](https\://github.com/QuantumNous/new-api/pull/5948)
  * fix(web)：管道表格填滿可用寬度，由 @zuiho-kai 提交於 [https\://github.com/QuantumNous/new-api/pull/6031](https\://github.com/QuantumNous/new-api/pull/6031)
  * chore：刪除 v1.0 發佈提交重新引入的無用檔案，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6041](https\://github.com/QuantumNous/new-api/pull/6041)
  * fix：訂閱重置使用 GORM v2 行鎖，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6057](https\://github.com/QuantumNous/new-api/pull/6057)
  * feat(playground)：新增參數設定面板，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/6044](https\://github.com/QuantumNous/new-api/pull/6044)
  * fix：允許多選新增僅大小寫不同的模型名稱，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6061](https\://github.com/QuantumNous/new-api/pull/6061)
  * fix：移除洩漏到價格頁的範例特殊群組，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5906](https\://github.com/QuantumNous/new-api/pull/5906)
  * perf(model-pricing)：優化上游價格同步表格，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/6092](https\://github.com/QuantumNous/new-api/pull/6092)
  * fix(web)：允許使用者操作觸發自訂首頁 iframe 頂層導覽，由 @Heykode 提交於 [https\://github.com/QuantumNous/new-api/pull/5955](https\://github.com/QuantumNous/new-api/pull/5955)
  * chore(deps)：將 golang.org/x/crypto 從 0.51.0 升級到 0.52.0，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/6096](https\://github.com/QuantumNous/new-api/pull/6096)
  * fix：同步 Codex Responses 透傳欄位，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/6018](https\://github.com/QuantumNous/new-api/pull/6018)
  * feat：增強文字通訊協定轉換和高級自訂路由，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/5825](https\://github.com/QuantumNous/new-api/pull/5825)
  * feat：模型價格設定新增未定價模型頁，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/6124](https\://github.com/QuantumNous/new-api/pull/6124)

  ### 新貢獻者

  * @cat0825 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-arm64-v1.0.0-rc.21) (129.6 MB)
  * [new-api-macos-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-macos-v1.0.0-rc.21) (152.2 MB)
  * [new-api-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21) (132.8 MB)
  * [new-api-v1.0.0-rc.21.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21.exe) (134.6 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.tar.gz)
</Callout>

***

## v1.0.0-rc.20

<Callout type="note" title="正式版本 · 發佈於 2026-07-07 21:46:39 (中國時間)">
  ### 重點更新

  支援 GPT-5.6 價格和管理端失效實例清理工具；修復錢包獎勵轉帳、群組小數倍率輸入等額度與計費邊界。

  ### 新增功能

  * 支援 GPT-5.6 模型 Token 價格。
  * 新增系統資訊中的失效實例清理操作（#5953）。

  ### 問題修復

  * 錢包獎勵轉帳使用已設定的額度單位，不再使用錯誤的固定值（#5808）。
  * 群組倍率欄位可正常輸入 `0.05` 等小數（#5995）。
  * 階梯計費預扣時使用預設 Token 估算，改善相關規則的額度計算。

  ***

  ### 變更內容

  * fix\: 群組倍率 Ratio 輸入框保留小數中間態,修復無法輸入 0.05，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5995](https\://github.com/QuantumNous/new-api/pull/5995)
  * feat(system-info)：新增失效實例清理操作，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5953](https\://github.com/QuantumNous/new-api/pull/5953)
  * fix(wallet)：獎勵轉帳遵循設定的額度單位，由 @A-Words 提交於 [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  ### 新貢獻者

  * @A-Words 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-arm64-v1.0.0-rc.20) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-macos-v1.0.0-rc.20) (151.7 MB)
  * [new-api-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20) (132.4 MB)
  * [new-api-v1.0.0-rc.20.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20.exe) (134.2 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.tar.gz)
</Callout>

***

## v1.0.0-rc.19-i18nfix.2

<Callout type="note" title="正式版本 · 發佈於 2026-07-07 14:06:07 (中國時間)">
  修復國際化錯誤

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-linux.txt) (200 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-macos.txt) (103 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-windows.txt) (101 B)
  * [new-api-arm64-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-arm64-v1.0.0-rc.19-i18nfix.2) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-macos-v1.0.0-rc.19-i18nfix.2) (151.7 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2) (132.4 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2.exe) (134.2 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.tar.gz)
</Callout>

***

## v1.0.0-rc.19

<Callout type="note" title="正式版本 · 發佈於 2026-07-07 13:19:27 (中國時間)">
  ### 新增功能

  * 管理員可重置訂閱額度並查看額度飽和事件，便於管理和審計（#5952）。
  * 新介面支援繁體中文 zh-TW（#5942）。

  ### 問題修復

  * 修復超大額度計費計算，確保正確應用限制。

  ***

  ### 變更內容

  * 新介面本機化為 zh-TW，由 @MeowTechOpenSource 提交於 [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)
  * feat(subscription)：新增管理員額度重置操作，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5952](https\://github.com/QuantumNous/new-api/pull/5952)

  ### 新貢獻者

  * @MeowTechOpenSource 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-arm64-v1.0.0-rc.19) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-macos-v1.0.0-rc.19) (151.7 MB)
  * [new-api-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19) (132.4 MB)
  * [new-api-v1.0.0-rc.19.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19.exe) (134.2 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.tar.gz)
</Callout>

***

## v1.0.0-rc.18

<Callout type="note" title="正式版本 · 發佈於 2026-07-07 01:16:57 (中國時間)">
  通過更嚴格的數量驗證，提高計費額度處理可靠性，避免錯誤額度計算。

  **問題修復**

  * 改進計費數量驗證，更可靠地處理無效或極端的額度和用量。

  ***

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-arm64-v1.0.0-rc.18) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-macos-v1.0.0-rc.18) (151.4 MB)
  * [new-api-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18) (132.0 MB)
  * [new-api-v1.0.0-rc.18.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18.exe) (133.9 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.tar.gz)
</Callout>

***

## v1.0.0-rc.17

<Callout type="note" title="正式版本 · 發佈於 2026-07-06 22:37:46 (中國時間)">
  ### 重點更新

  改善管道測試、兌換管理、主題和多項網頁流程；修重複使用量報告、經典介面構建、串流斷連及額度、影片時長計算。

  ### 新增功能

  * 兌換管理支援狀態篩選和清理操作，便於管理。
  * 改善群組倍率編輯，優化可見性和 JSON 輸入處理。
  * 兌換失敗時顯示更清晰的錯誤說明。

  ### 問題修復

  * AI Elements 整合讀取嵌套用量，正確報告 Token 消耗。
  * 修復經典網頁構建失敗（#5892）。
  * Codex 管道正確顯示欄位透傳控制項（#5902）。
  * 首頁 iframe 與所選主題、語言保持同步（#5917）。
  * Shadow DOM 中的自訂 HTML 正確回應深淺色切換（#5890）。
  * 已登入使用者存取註冊頁時，與登入及經典主題一致地重定向（#5910）。
  * 用戶端斷開後停止寫入串流回應（#5710）。
  * 修復任務餘額結算後的額度結算和阿里影片時長處理（#5923）。
  * DNS 查詢失敗不再導致構建日期生成失敗（#5945）。

  ### 改進

  * 管道和模型測試對話框更緊湊、更便於操作（#5886）。
  * 動態價格詳情與記錄詳情對話框保持樣式一致（#5905）。
  * 改善移動端使用者卡片版面配置和可讀性。
  * 優化舊儲值警告文案，使其更清晰易懂（#5855）。

  ***

  ### 變更內容

  * chore(deps-dev)：將 /electron 的 tmp 從 0.2.5 升級到 0.2.7，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/5147](https\://github.com/QuantumNous/new-api/pull/5147)
  * chore(web)：更新預設前端相依套件，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5884](https\://github.com/QuantumNous/new-api/pull/5884)
  * perf(web)：改善管道測試對話框互動，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5886](https\://github.com/QuantumNous/new-api/pull/5886)
  * fix(classic)：修復經典網頁構建失敗，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5892](https\://github.com/QuantumNous/new-api/pull/5892)
  * fix(channels)：為 Codex 顯示欄位透傳控制項，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5902](https\://github.com/QuantumNous/new-api/pull/5902)
  * fix：動態價格樣式與記錄詳情分區保持一致，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5905](https\://github.com/QuantumNous/new-api/pull/5905)
  * fix\: 任務差額結算後 quota 和阿里影片時長優化，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5923](https\://github.com/QuantumNous/new-api/pull/5923)
  * fix(web)：同步首頁 iframe 的主題和語言，由 @guoruqiang 提交於 [https\://github.com/QuantumNous/new-api/pull/5917](https\://github.com/QuantumNous/new-api/pull/5917)
  * fix(web)\: 修復 Shadow DOM 隔離渲染下自訂 HTML 深淺色失效的問題，由 @olwater 提交於 [https\://github.com/QuantumNous/new-api/pull/5890](https\://github.com/QuantumNous/new-api/pull/5890)
  * fix(web)\: 註冊頁補充已登入重定向守衛，與登入頁 / classic 主題保持一致 (#5908)，由 @Heykode 提交於 [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * feat：優化舊儲值警告橫幅文案（#5851），由 @Gravirei 提交於 [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)
  * fix：避免用戶端斷開後的過期流寫入，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5710](https\://github.com/QuantumNous/new-api/pull/5710)
  * 修復構建日期的 DNS 錯誤，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5945](https\://github.com/QuantumNous/new-api/pull/5945)

  ### 新貢獻者

  * @Heykode 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * @Gravirei 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-arm64-v1.0.0-rc.17) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-macos-v1.0.0-rc.17) (151.4 MB)
  * [new-api-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17) (132.0 MB)
  * [new-api-v1.0.0-rc.17.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17.exe) (133.8 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.tar.gz)
</Callout>

***

## v1.0.0-rc.16

<Callout type="note" title="正式版本 · 發佈於 2026-07-03 15:41:42 (中國時間)">
  **重點更新**

  擴展 Responses/Chat 互轉、豆包 Seedance 2.0 更新和 Wan2.7 圖生影片媒體對應；改進 Playground 渲染、管道管理、頁面狀態保留和優雅重新啟動。

  **新增功能**

  * 支援 Responses API 轉 Chat，提高不同通訊協定用戶端和供應商的互操作可靠性（#5787）。
  * 擴展豆包 Seedance 2.0，支援素材介面、解析度計費、影片輸入計費、4K 計費及新選項（#5824）。
  * 支援 Wan2.7 圖生影片媒體對應（#4984）。
  * 支援優雅停機，減少回覆中斷和重新啟動時面板快取丟失（#4258）。
  * 改善管道管理版面配置，增強高級自訂路由編輯器。

  **問題修復**

  * 切換模型時正確重新整理階梯價格表達式編輯器（#5752）。
  * 非同步任務用量記錄歸屬到發起任務的節點（#5684）。
  * 切換主題後回傳首頁，不再進入 404 路由（#5612）。
  * 自訂 HTML 和 Markdown 保持一致樣式和間距，包括隔離 HTML 視圖（#5795）。
  * 修復同路由切換標籤時頁面狀態重置，包括儀錶盤時間範圍（#5796）。
  * 管道狀態篩選在頁面導覽後保留（#5863）。
  * 修復 Ollama 非串流工具呼叫（#5865）。
  * 修復 Waffo 商品資訊和 webhook 行為（#5704）。

  **改進**

  * 改善 Playground 聊天體驗和 Markdown 渲染（#5217）。
  * 簡化表格操作及危險操作確認對話框（#5645）。
  * 改善 ClickHouse 記錄 LIKE 查詢篩選。
  * 優化前端構建管線，加快網頁構建（#5786）。

  ***

  ### 變更內容

  * chore(deps)：將 /web/default 的 dompurify 從 3.4.5 升級到 3.4.11，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/5718](https\://github.com/QuantumNous/new-api/pull/5718)
  * fix(ci)：發佈時安裝經典工作區相依套件，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5719](https\://github.com/QuantumNous/new-api/pull/5719)
  * perf(web)：簡化表格操作和危險操作對話框，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5645](https\://github.com/QuantumNous/new-api/pull/5645)
  * fix：新增 Waffo 商品資訊並更新 webhook SDK，由 @zhongyuanzhao-alt 提交於 [https\://github.com/QuantumNous/new-api/pull/5704](https\://github.com/QuantumNous/new-api/pull/5704)
  * fix(model-pricing)：切換模型時重新整理階梯表達式編輯器，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5752](https\://github.com/QuantumNous/new-api/pull/5752)
  * fix：同步 bun.lock 與 dompurify 3.4.11，恢復 frozen-lockfile 構建，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5738](https\://github.com/QuantumNous/new-api/pull/5738)
  * fix(theme)\: 切換前端主題後重置到首頁，避免路由 404，由 @zhangzhichaolove 提交於 [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * fix(task)：非同步任務用量記錄歸屬發起節點，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5684](https\://github.com/QuantumNous/new-api/pull/5684)
  * feat：新增 Casbin 管理員權限，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/5755](https\://github.com/QuantumNous/new-api/pull/5755)
  * feat(playground)：改善聊天體驗和 Markdown 渲染，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5217](https\://github.com/QuantumNous/new-api/pull/5217)
  * fix(auth)：統一密碼驗證文案，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5759](https\://github.com/QuantumNous/new-api/pull/5759)
  * fix(web)：一致地渲染自訂 HTML 和 Markdown，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5760](https\://github.com/QuantumNous/new-api/pull/5760)
  * fix(openai)：加強 Chat 轉 Responses 相容性，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/5772](https\://github.com/QuantumNous/new-api/pull/5772)
  * feat：支援 Responses 轉 Chat，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/5787](https\://github.com/QuantumNous/new-api/pull/5787)
  * feat\: doubao-seedance-2-0-260128支援按解析度區分計費，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5300](https\://github.com/QuantumNous/new-api/pull/5300)
  * feat：支援豆包 Seedance 2.0 safety\_identifier/priority 與 4K 計費，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5824](https\://github.com/QuantumNous/new-api/pull/5824)
  * fix(web)\: 修復自訂 HTML 樣式被過濾及排版間距異常的問題，由 @olwater 提交於 [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * feat：支援 Wan2.7 圖生影片媒體對應，由 @wxwwt 提交於 [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * perf(web)：優化 Rsbuild 和 Tailwind 構建管線，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5786](https\://github.com/QuantumNous/new-api/pull/5786)
  * fix(makefile)：dev-web 僅啟動預設網頁開發伺服器，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5794](https\://github.com/QuantumNous/new-api/pull/5794)
  * fix(web)：向隔離 HTML 注入應用樣式，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5860](https\://github.com/QuantumNous/new-api/pull/5860)
  * fix：同路由切換標籤時保留狀態，避免儀錶盤時間重置，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5796](https\://github.com/QuantumNous/new-api/pull/5796)
  * 支援服務優雅關閉,避免重新啟動回覆中斷和面板快取資料丟失，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/4258](https\://github.com/QuantumNous/new-api/pull/4258)
  * fix：預設主題驗證守衛僅將 401 視為工作階段過期，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5872](https\://github.com/QuantumNous/new-api/pull/5872)
  * fix：頁面導覽後保留管道狀態篩選，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5863](https\://github.com/QuantumNous/new-api/pull/5863)
  * chore(deps)：將 golang.org/x/net 從 0.50.0 升級到 0.55.0，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/5862](https\://github.com/QuantumNous/new-api/pull/5862)
  * chore(deps)：將 golang.org/x/image 從 0.38.0 升級到 0.41.0，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/5873](https\://github.com/QuantumNous/new-api/pull/5873)
  * fix：處理 Ollama 非串流工具呼叫，由 @stevenjoezhang 提交於 [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  ### 新貢獻者

  * @zhangzhichaolove 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * @olwater 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * @wxwwt 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * @stevenjoezhang 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-arm64-v1.0.0-rc.16) (127.4 MB)
  * [new-api-macos-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-macos-v1.0.0-rc.16) (149.8 MB)
  * [new-api-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16) (130.5 MB)
  * [new-api-v1.0.0-rc.16.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16.exe) (132.3 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.tar.gz)
</Callout>

***

## v1.0.0-rc.15

<Callout type="note" title="正式版本 · 發佈於 2026-06-24 21:00:04 (中國時間)">
  ### 重點更新

  新增運維控制，包括被動管道監控、ClickHouse 記錄儲存、系統任務和實例可見性；改善用量記錄、Markdown、管道選擇和選用錢包介面的可靠性。

  ### 新增功能

  * 支援被動管道監控，在不主動干擾流量的情況下檢查健康狀態（#5592）。
  * 支援 ClickHouse 記錄儲存，為大規模儲存與查詢提供選項（#5663）。
  * 新增系統任務執行器，持久跟蹤長時間維護清理的進度（#5680）。
  * 新增系統實例資訊面板，便於查看部署和節點狀態（#5716）。
  * 系統設定新增使用者權杖數量限制設定（#5678）。
  * 管道測試支援選擇環境和設定非同步輪詢間隔。
  * 未設定 `NODE_NAME` 時，預設節點名使用機器主機名稱稱（#5659）。

  ### 問題修復

  * 用量記錄正確顯示國內模型的廠商圖標（#5631）。
  * 修正 Stepfun 廠商顯示名稱（#5636）。
  * 修復 SMTP STARTTLS 模式和 NTLM 驗證相容性（#5426）。
  * 修復時區日期處理導致的經典主題構建失敗（#5676）。
  * 改善網頁 Markdown 渲染並擴展語法支援（#5689）。
  * 管道卡片選取狀態與目前管道保持同步（#5700）。
  * 錢包模組禁用時隱藏個人選單中的錢包入口（#5708）。

  ### 改進

  * 結合 ClickHouse 記錄和系統維護任務簡化記錄清理。

  ***

  ### 變更內容

  * fix(usage-logs)：為國內模型顯示廠商圖標，與經典前端一致，由 @DeliciousBuding 提交於 [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * fix：將 StepFun 修正為 Stepfun，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5636](https\://github.com/QuantumNous/new-api/pull/5636)
  * feat：支援被動管道監控，由 @exherb 提交於 [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)
  * feat：NODE\_NAME 未設定時預設使用主機名稱稱，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5659](https\://github.com/QuantumNous/new-api/pull/5659)
  * feat：支援 ClickHouse 記錄資料庫，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/5663](https\://github.com/QuantumNous/new-api/pull/5663)
  * fix：支援 SMTP STARTTLS 和 NTLM 驗證，由 @bensonfx 提交於 [https\://github.com/QuantumNous/new-api/pull/5426](https\://github.com/QuantumNous/new-api/pull/5426)
  * chore(deps)：將 github.com/ClickHouse/ch-go 從 0.58.2 升級到 0.65.0，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/5664](https\://github.com/QuantumNous/new-api/pull/5664)
  * fix：修復 date-fns-tz 經典主題構建錯誤，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5676](https\://github.com/QuantumNous/new-api/pull/5676)
  * feat：新增系統任務執行器，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/5680](https\://github.com/QuantumNous/new-api/pull/5680)
  * feat：新增系統實例資訊面板，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/5716](https\://github.com/QuantumNous/new-api/pull/5716)
  * fix(web)：替換預設 Markdown 渲染器並擴展語法，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5689](https\://github.com/QuantumNous/new-api/pull/5689)
  * fix(web)：同步管道卡片選取狀態，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5700](https\://github.com/QuantumNous/new-api/pull/5700)
  * fix(web)：錢包模組禁用時隱藏個人選單入口，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5708](https\://github.com/QuantumNous/new-api/pull/5708)
  * feat(system-settings)：新增使用者權杖限制設定，由 @RedwindA 提交於 [https\://github.com/QuantumNous/new-api/pull/5678](https\://github.com/QuantumNous/new-api/pull/5678)

  ### 新貢獻者

  * @DeliciousBuding 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * @exherb 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-arm64-v1.0.0-rc.15) (131.4 MB)
  * [new-api-macos-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-macos-v1.0.0-rc.15) (153.3 MB)
  * [new-api-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15) (134.2 MB)
  * [new-api-v1.0.0-rc.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15.exe) (136.0 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.tar.gz)
</Callout>

***

## v1.0.0-rc.14

<Callout type="note" title="正式版本 · 發佈於 2026-06-20 22:15:42 (中國時間)">
  ### 重點更新

  儀錶盤新增流量桑基圖，展示 Token 路由和流向，支援互動高亮、持久篩選及大圖規模限制。管道卡片版面配置更快更清晰，減少不必要的重新渲染。

  ### 新增功能

  * 新增儀錶盤流量桑基圖，便於快速理解 Token 流向和路由行為（#5465）。
  * 新增路由可靠性管理，提高路由行為的控制與可見性。

  ### 介面展示

  | 流量圖                                                                                             | 通道管理卡片版面                                                                                              |
  | ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
  | ![通道管理卡片版面範例](https\://github.com/user-attachments/assets/e0d82bd4-e052-4518-9fac-1144c0bd0721) | ![Gallery 發佈說明中的配圖](https\://github.com/user-attachments/assets/2ab5e6e6-f4f7-44f5-9abd-7191ed30e7aa) |

  ### 問題修復

  * 修復新前端按登入型別篩選記錄（#5620）。
  * 修復帳單歷史對話框分頁與清單重疊（#5627）。
  * 修復可視化價格清單中部分模型價格無法刪除（#5628）。
  * 修復重新啟動後重複執行資料庫欄位遷移（#5361、#5616）。

  ### 改進

  * 改善管道管理卡片，減少無效重新渲染，使體驗更流暢。
  * 簡化模型清單，便於瀏覽和管理。
  * 更新管道圖標以保持視覺一致。

  ***

  ### 變更內容

  * fix：停止重新啟動後重複遷移 allow\_balance\_pay 列，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5361](https\://github.com/QuantumNous/new-api/pull/5361)
  * fix：停止重新啟動後重複遷移 allow\_wallet\_overflow 列，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5616](https\://github.com/QuantumNous/new-api/pull/5616)
  * feat(dashboard)\: 增加分流圖，查看token流量。add traffic flow sankey chart，由 @Quaternijkon 提交於 [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)
  * fix(log)\: 修復新前端記錄按登入型別(type=7)篩選失效，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5620](https\://github.com/QuantumNous/new-api/pull/5620)
  * fix(wallet)\: 修復計費歷史彈窗分頁與清單重疊 (#5624)，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5627](https\://github.com/QuantumNous/new-api/pull/5627)
  * fix(model-pricing)\: 修復模型定價清單項無法刪除 (#5623)，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5628](https\://github.com/QuantumNous/new-api/pull/5628)

  ### 新貢獻者

  * @Quaternijkon 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-arm64-v1.0.0-rc.14) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-macos-v1.0.0-rc.14) (142.3 MB)
  * [new-api-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14) (125.4 MB)
  * [new-api-v1.0.0-rc.14.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14.exe) (127.1 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.tar.gz)
</Callout>

***

## v1.0.0-rc.13

<Callout type="note" title="正式版本 · 發佈於 2026-06-19 20:28:34 (中國時間)">
  v1.0.0-rc.13 重點改善前端體驗與回應速度，尤其是管道管理和密集資料頁面。管道頁支援卡片展示及更好的移動版面配置，記錄、指標、端點選擇、日期和用量視圖也得到完善。

  ### 新增功能

  * 新增可重複使用的卡片/表格切換，包括適應不同屏幕的管道及密集資料卡片版面配置。
  * 支援按語言區域格式化數字，使各地區使用者更易閱讀。

  ### 改進

  * 改善管道卡片左右結構及小屏幕移動版面配置。
  * 完善記錄、指標、端點選擇、日期、工具欄和模型抽屜，使介面更統一。
  * 改善 Codex 用量介面的可讀性和易用性（#5595）。
  * 減少瀏覽器視窗重新聚焦時的無效資料重新整理，提高前端性能。
  * 統一前端品牌文案和視覺樣式。

  ### 問題修復

  * 在需要時顯示毫秒，提高繪圖相關時間戳精度。

  ***

  ### 變更內容

  * chore(web)：預設前端執行 oxc 質量檢查，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5585](https\://github.com/QuantumNous/new-api/pull/5585)
  * refactor：重構 Codex 用量介面，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5595](https\://github.com/QuantumNous/new-api/pull/5595)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-arm64-v1.0.0-rc.13) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-macos-v1.0.0-rc.13) (142.2 MB)
  * [new-api-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13) (125.3 MB)
  * [new-api-v1.0.0-rc.13.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13.exe) (127.0 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.tar.gz)
</Callout>

***

## v1.0.0-rc.12

<Callout type="note" title="正式版本 · 發佈於 2026-06-18 20:34:16 (中國時間)">
  重點更新：AdvancedCustom 管道提供更靈活的自訂路由，管道批量測試更易操作，模型市場監控提供更清晰的成功率和延遲。

  ### 新增功能

  * 新增 AdvancedCustom 管道並改善自訂路由匹配（#5590）。
  * 增強模型批量測試，包括完整執行、狀態重新整理、清晰結果、刪除失敗模型及複製所選模型（#5532）。
  * 擴展模型市場性能監控，包括可用率、近期成功率、成功率評級和緊湊的延遲/吞吐顯示。
  * 持久儲存表格偏好，頁面大小和欄位可見性可跨頁面、跨工作階段保留（#5403）。

  ### 問題修復

  * 修復工具呼叫，使空的 `arguments` 值仍保留預期的 `tool_use` 塊（#5543）。
  * 修復 CC Switch 模型選取器，正確顯示和更新模型選項（#5515）。
  * 修復清單、表格、用量詳情和自訂首頁 iframe 的裁切及溢出（#5510、#5536、#5533、#5545）。

  ### 改進

  * 改善付款與儲值介面，明確付款方式按鈕、圖標和最低儲值資訊。
  * 改善訂閱套餐描述、錢包溢出處理和降級群組支援。
  * 優化設定、概覽引導、錢包/個人互動及記錄統計卡片，提高可讀性。

  ### 不相容變更

  * 訂閱產品選項和目錄端點現在使用 `GET`，用戶端整合可能需要更新請求方法。
  * 從排名篩選中移除「全部」時間範圍選項。

  ***

  ### 變更內容

  * fix(web)：防止清單文字和徽標溢出，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5510](https\://github.com/QuantumNous/new-api/pull/5510)
  * fix(keys)：重新整理 API Key 表單選項，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5512](https\://github.com/QuantumNous/new-api/pull/5512)
  * fix：修復 CC Switch 模型選取器，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5515](https\://github.com/QuantumNous/new-api/pull/5515)
  * fix(data-table)：memo 比較包含行選擇狀態，由 @RedwindA 提交於 [https\://github.com/QuantumNous/new-api/pull/5524](https\://github.com/QuantumNous/new-api/pull/5524)
  * fix(channels)：重新整理管道測試對話框狀態，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5517](https\://github.com/QuantumNous/new-api/pull/5517)
  * fix：恢復自訂首頁 iframe 視口高度，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5545](https\://github.com/QuantumNous/new-api/pull/5545)
  * fix(web)：避免用量詳情對話框裁切底部內容，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5533](https\://github.com/QuantumNous/new-api/pull/5533)
  * fix：修復 AWS AK/SK 上下文管理，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5547](https\://github.com/QuantumNous/new-api/pull/5547)
  * test：清理以獎勵投機方式通過的後端測試，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5563](https\://github.com/QuantumNous/new-api/pull/5563)
  * fix\: 工具呼叫 arguments 為空時保留 tool\_use 塊，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5543](https\://github.com/QuantumNous/new-api/pull/5543)
  * fix：完整執行管道模型批量測試，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5532](https\://github.com/QuantumNous/new-api/pull/5532)
  * feat\: 持久化表格每頁條數，跨導覽/工作階段記憶 (#5377)，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5403](https\://github.com/QuantumNous/new-api/pull/5403)
  * fix(data-table)：避免元件單元格被裁切，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5536](https\://github.com/QuantumNous/new-api/pull/5536)
  * fix(oauth)：永久刪除使用者時清理綁定，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5582](https\://github.com/QuantumNous/new-api/pull/5582)
  * feat：高級自訂管道，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5590](https\://github.com/QuantumNous/new-api/pull/5590)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-arm64-v1.0.0-rc.12) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-macos-v1.0.0-rc.12) (142.1 MB)
  * [new-api-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12) (125.3 MB)
  * [new-api-v1.0.0-rc.12.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12.exe) (127.0 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.tar.gz)
</Callout>

***

## v1.0.0-rc.11

<Callout type="note" title="正式版本 · 發佈於 2026-06-13 16:15:40 (中國時間)">
  重點更新：支援 Claude Opus 4.8，改善 OpenAI 圖片 API 相容性、模型價格編輯器和密集資料表格；修復介面、額度顯示、轉發相容性及廠商問題。

  ### 新增功能

  * 支援 Claude Opus 4.8（#5177）。
  * 選用擇禁用管道時是否清除管道親和性（#5306）。
  * 新增訂閱餘額兌換開關，提高餘額處理靈活性。
  * 個人頁顯示使用者 ID（#5317）。
  * OpenAI 圖片 API 支援串流圖片轉發和圖片編輯（#4608）。

  ### 問題修復

  * 提交表單後聚焦第一個驗證錯誤，便於定位和修正（#5163）。
  * 修復 cc-switch 自訂名稱失焦後重置（#5170）。
  * 修復價格視圖中自訂模型圖標不同步（#5224）。
  * 高級管道驗證錯誤可直接顯示，不再錯誤展開無關設定（#5239）。
  * 修復額度和餘額匯率轉換，同時更新單位及顯示值（#5296）。
  * 修復 Dify 檔案請求中的遠端圖片處理（#5134）。
  * 修復影片生成任務查詢的模型解析（#5133）。
  * 改善相容 Anthropic 的 GLM 轉發，避免相容失敗（#5307）。
  * 縮小 OpenAI o 系列適配範圍，避免影響不支援的模型（#5293）。
  * 多選彈出框遵循目前主題（#5328）。
  * 修復 Kimi K2.6 溫度規範化（#5390）。
  * 支援按狀態篩選已刪除使用者（#5464）。
  * 僅在部署頁取得部署設定（#5466）。

  ### 改進

  * 改善管理記錄和批量更新性能，使大規模操作更流暢（#5116）。
  * 改善模型價格編輯器版面配置、草稿儲存、JSON 重複使用及六位小數步長（#5275）。
  * 管道搜尋加入防抖並優化輸入法組合輸入處理（#5393）。
  * 改善前端表格渲染、固定列、版面配置及徽標（#5405）。
  * 改善前端對話框尺寸和底部版面配置（#5346）。
  * 簡化公共頁主視覺文案，使首頁更清晰（#5339）。

  ***

  ### 變更內容

  * fix(web)：改善表單驗證錯誤聚焦，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5163](https\://github.com/QuantumNous/new-api/pull/5163)
  * feat(keys/cc-switch-dialog)\: 修復自訂cc-switch名稱失焦後重置問題，由 @GnezIew 提交於 [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * fix(model)：將 idx\_created\_at\_id 索引欄位順序修正為 (created\_at, id)，由 @realRoc 提交於 [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * perf：管理記錄按 created\_at 排序以利用複合索引，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5116](https\://github.com/QuantumNous/new-api/pull/5116)
  * chore(deps)：將 /web/classic 的 axios 從 1.15.2 升級到 1.16.0，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/5185](https\://github.com/QuantumNous/new-api/pull/5185)
  * feat：支援 claude-opus-4-8，由 @hjxwz123 提交於 [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * fix(pricing)：同步自訂模型圖標，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5224](https\://github.com/QuantumNous/new-api/pull/5224)
  * chore(web)：集中管理共享前端相依套件版本，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5227](https\://github.com/QuantumNous/new-api/pull/5227)
  * feat(web)：支援經典前端 Rsbuild 開發與構建，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5232](https\://github.com/QuantumNous/new-api/pull/5232)
  * fix(channels)：展示高級驗證錯誤，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5239](https\://github.com/QuantumNous/new-api/pull/5239)
  * docs：改善議題模板，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5271](https\://github.com/QuantumNous/new-api/pull/5271)
  * fix\: 修復餘額顯示時只切換了單位未切換數值，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/5296](https\://github.com/QuantumNous/new-api/pull/5296)
  * fix(dify)：遠端圖片欄位賦值前初始化檔案指針，由 @Pluviobyte 提交於 [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * fix(distributor)：解析 GET /v1/video/generations/\:task\_id 對應模型，由 @Pluviobyte 提交於 [https\://github.com/QuantumNous/new-api/pull/5133](https\://github.com/QuantumNous/new-api/pull/5133)
  * fix：新增轉發閒置連線逾時設定，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5309](https\://github.com/QuantumNous/new-api/pull/5309)
  * feat\: 支援設定管道被禁用後是否清空管道粘性，由 @GuangYiDing 提交於 [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * fix(relay)：修復 GLM Anthropic 相容模式，避免 chunked 編碼，由 @Chen011214 提交於 [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * fix：限制匿名請求主體大小，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5244](https\://github.com/QuantumNous/new-api/pull/5244)
  * fix(i18n)：明確思考適配器文案，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5242](https\://github.com/QuantumNous/new-api/pull/5242)
  * fix\: 收窄 OpenAI o 系列模型適配範圍，由 @USER-HFC 提交於 [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * fix：管道處理器重複使用流掃描緩衝區，由 @xujiantop-crypto 提交於 [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * feat(web)：個人頁顯示使用者 ID，由 @P2K0 提交於 [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * perf(model-pricing)：改善模型價格編輯器體驗，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5275](https\://github.com/QuantumNous/new-api/pull/5275)
  * perf(web)：簡化公共頁主視覺文案，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5339](https\://github.com/QuantumNous/new-api/pull/5339)
  * perf(web)：改善對話框版面配置和尺寸，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5346](https\://github.com/QuantumNous/new-api/pull/5346)
  * fix：多選組合框彈窗遵循主題，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5328](https\://github.com/QuantumNous/new-api/pull/5328)
  * fix：對齊移動端用量記錄費用徽標，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5161](https\://github.com/QuantumNous/new-api/pull/5161)
  * fix：模型價格編輯器支援六位小數步長，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5332](https\://github.com/QuantumNous/new-api/pull/5332)
  * fix(openai)：圖片 API 支援串流圖片轉送與圖片編輯，由 @gaoren002 提交於 `#4608`
  * perf(web)：管道搜尋防抖，輸入法組合期間跳過搜尋，由 @QAbot-zh 提交於 [https\://github.com/QuantumNous/new-api/pull/5393](https\://github.com/QuantumNous/new-api/pull/5393)
  * fix：規範 Kimi K2.6 溫度，由 @bensonfx 提交於 [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)
  * perf(web)：改善前端表格渲染及固定列，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5405](https\://github.com/QuantumNous/new-api/pull/5405)
  * perf(data-table)：改善資料表版面配置和徽標，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/5460](https\://github.com/QuantumNous/new-api/pull/5460)
  * feat(audit)：新增本機化安全審計記錄，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/5462](https\://github.com/QuantumNous/new-api/pull/5462)
  * chore：更新 Codex 管道，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5461](https\://github.com/QuantumNous/new-api/pull/5461)
  * fix：新增已刪除使用者狀態篩選，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5464](https\://github.com/QuantumNous/new-api/pull/5464)
  * fix：僅在部署頁取得部署設定，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5466](https\://github.com/QuantumNous/new-api/pull/5466)

  ### 新貢獻者

  * @GnezIew 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * @realRoc 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * @hjxwz123 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * @Pluviobyte 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * @GuangYiDing 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * @Chen011214 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * @USER-HFC 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * @xujiantop-crypto 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * @P2K0 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * @bensonfx 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-arm64-v1.0.0-rc.11) (84.8 MB)
  * [new-api-macos-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-macos-v1.0.0-rc.11) (103.8 MB)
  * [new-api-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11) (87.2 MB)
  * [new-api-v1.0.0-rc.11.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11.exe) (88.9 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.tar.gz)
</Callout>

***

## v1.0.0-rc.10

<Callout type="note" title="正式版本 · 發佈於 2026-05-26 22:20:13 (中國時間)">
  ### 重點更新

  v1.0.0-rc.10 重點改善介面、轉送可靠性與管理流程。新增主題選項與餘額購買訂閱，並最佳化日誌、通道行為、Webhook、付款和上游工具呼叫處理。

  ### 新增功能

  * 主題自訂新增 Anthropic 和 Simple Large 預設，可設定襯線字型及超大縮放。
  * 訂閱計費支援餘額購買。

  ### 問題修復

  * 自動禁用的管道不再用於新請求，管道操作不再重複通知（#4983）。
  * 改善 Gemini 與 Claude 之間工具轉發，包括並行工具呼叫（#5095）。
  * 圖片轉發正確應用請求的質量設定（#5103）。
  * 用量篩選預設精確匹配，僅顯式使用通配符時模糊匹配；超大上游錯誤會截短以保持記錄可讀（#5097）。
  * 提高 webhook 處理可靠性（#5047）。
  * 統一 Waffo 付款設定儲存，隱藏舊版選項（#5110）。
  * 系統設定正確識別未儲存修改，並避免數值輸入產生無效值。

  ### 改進

  * 大型媒體轉發降低記憶體消耗，提高負載下穩定性。
  * 系統設定、管道建立和編輯頁更清晰緊湊，控制項更完善。
  * 改善用量記錄和預設網頁的移動體驗，包括表格間距、徽標、圖表及深色可讀性。
  * 首頁主視覺採用更清晰的雙欄版面配置並更新文案。

  ***

  ### 變更內容

  * 🐛 fix(channel)：從快取移除自動禁用的多金鑰管道，由 @t0ng7u 提交於 [https\://github.com/QuantumNous/new-api/pull/4983](https\://github.com/QuantumNous/new-api/pull/4983)
  * \[修復] 修復 webhook 處理流程，由 @Hill-waffo 提交於 [https\://github.com/QuantumNous/new-api/pull/5047](https\://github.com/QuantumNous/new-api/pull/5047)
  * fix(payment)：隱藏舊版 Waffo Pancake 設定，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5085](https\://github.com/QuantumNous/new-api/pull/5085)
  * fix(relay)：修正圖片質量參數處理，由 @lanfunoe 提交於 [https\://github.com/QuantumNous/new-api/pull/5103](https\://github.com/QuantumNous/new-api/pull/5103)
  * fix：截短超大上游錯誤記錄，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5083](https\://github.com/QuantumNous/new-api/pull/5083)
  * fix\: 移除 fcIdx -1 偏移，修復並行工具呼叫撞鍵問題，由 @learner-i 提交於 [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)
  * fix：修復 Gemini 轉 Claude tool\_use 錯誤，由 @nekohy 提交於 [https\://github.com/QuantumNous/new-api/pull/5041](https\://github.com/QuantumNous/new-api/pull/5041)
  * fix：處理 API Key 搜尋分頁回應，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5014](https\://github.com/QuantumNous/new-api/pull/5014)
  * fix：避免管道操作重複提示，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5015](https\://github.com/QuantumNous/new-api/pull/5015)
  * fix：整合 Waffo 付款設定儲存流程，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5110](https\://github.com/QuantumNous/new-api/pull/5110)
  * fix：管道測試使用真實使用者 ID，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5109](https\://github.com/QuantumNous/new-api/pull/5109)
  * fix：記錄篩選預設精確匹配，除非顯式使用通配符，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5097](https\://github.com/QuantumNous/new-api/pull/5097)

  ### 新貢獻者

  * @learner-i 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-linux.txt) (180 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-arm64-v1.0.0-rc.10) (82.8 MB)
  * [new-api-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10) (85.3 MB)
  * [new-api-v1.0.0-rc.10.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10.exe) (86.9 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.tar.gz)
</Callout>

***

## v1.0.0-rc.8

<Callout type="note" title="正式版本 · 發佈於 2026-05-22 16:25:46 (中國時間)">
  #### 重點更新

  新增 Waffo Pancake 閘道及管理端目錄/商品綁定；完善管理端和 API、模型元資料和價格一致性、管道測試診斷、報告篩選及請求效率。

  #### 新增功能

  * 支援 Waffo Pancake 閘道及管理端目錄/商品綁定（#4935）。

  #### 問題修復

  * 儀錶盤內容遵循可見性設定（#4975）。
  * 性能指標匯總僅包含活動群組（#4976）。
  * 規範模型價格顯示，避免數值不一致（#4985）。
  * 從活動管道解析模型歸屬元資料，提高清單準確性（#4416）。
  * 預設前端連結指向正確路由（#5016）。
  * 恢復原用量記錄篩選行為，避免此前修改的回歸。

  #### 改進

  * 管道測試失敗時提供更清晰的詳情（#4988）。
  * 減少請求處理開銷，改善負載下性能（#5009）。

  ***

  ### 變更內容

  * fix：為敏感訊息欄位展示參數覆蓋審計，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4974](https\://github.com/QuantumNous/new-api/pull/4974)
  * fix：遵循儀錶盤內容可見性設定，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4975](https\://github.com/QuantumNous/new-api/pull/4975)
  * fix：按活動群組篩選性能匯總，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4976](https\://github.com/QuantumNous/new-api/pull/4976)
  * fix：改善管道測試失敗詳情體驗，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4988](https\://github.com/QuantumNous/new-api/pull/4988)
  * fix：規範模型價格顯示偏差，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4985](https\://github.com/QuantumNous/new-api/pull/4985)
  * fix：從活動管道解析模型 owned\_by，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4416](https\://github.com/QuantumNous/new-api/pull/4416)
  * perf：優化請求元資料提取和禁用欄位過濾，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5009](https\://github.com/QuantumNous/new-api/pull/5009)
  * fix：更新預設前端硬編碼路由連結，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/5016](https\://github.com/QuantumNous/new-api/pull/5016)
  * 修復 切換新版前端Turnstile 開啟後註冊頁未顯示驗證的問題，由 @JunXiaoRuo 提交於 [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * \[功能請求] Waffo Pancake 閘道完整整合：支援訂閱及管理端目錄綁定，由 @Hill-waffo 提交於 [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)
  * fix：落實 Waffo 訂閱合規及商品 ID 更新，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/5038](https\://github.com/QuantumNous/new-api/pull/5038)

  ### 新貢獻者

  * @JunXiaoRuo 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * @Hill-waffo 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-arm64-v1.0.0-rc.8) (82.4 MB)
  * [new-api-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8) (84.8 MB)
  * [new-api-v1.0.0-rc.8.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8.exe) (86.5 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.tar.gz)
</Callout>

***

## v1.0.0-rc.7

<Callout type="note" title="正式版本 · 發佈於 2026-05-19 16:54:08 (中國時間)">
  #### 新增功能

  * 支援 `request_header` 金鑰來源（#4903）。

  #### 問題修復

  * 批量修復預設介面問題（#4880、#4893、#4817、#4877、#4898、#4876）。
  * 修復管道備注無法清空（#4886）。
  * 修重複使用量記錄篩選（#4883）。
  * 修復網頁 API Key 無限額度驗證（#4881）。
  * 公共模組頁頭導覽應用存取控制（#4889）。
  * 管道清單查詢正確應用群組篩選（#4847、#4885）。
  * 修復 `PerfMetric` upsert 中的列名歧義（#4684）。
  * 預設主題新增缺失的分析統計佔位符（#4928）。
  * 為忘記密碼表單按鈕設定正確型別，修復提交（#4910）。
  * 規範模型詳情標籤版面配置（#4938）。
  * 修復管理面板使用者建立和刪除（#4818）。
  * 登入頁註冊連結遵循註冊設定（#4871）。
  * 更新 ModelCardGrid 分頁按鈕說明（#4675）。
  * 本機化重置密碼確認訊息（#4769）。
  * 深色模式下可見儲值預設選取狀態（#4897）。
  * 修復語義顏色變數不匹配導致 API 資訊色點顏色錯誤（#4824）。
  * 修復 API 資訊儲存時無效顏色造成的靜默失敗（#4823）。
  * 註冊載荷使用正確的 `aff_code` 欄位（#4965）。
  * 資料表分面篩選彈窗寬度自適應（#4966）。
  * 修復金鑰提交時過期表單關聯（#4967）。

  #### 改進

  * 避免偵錯記錄提前格式化，提高性能（#4929）。

  ***

  ### 變更內容

  * fix：允許清空管道備注，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4886](https\://github.com/QuantumNous/new-api/pull/4886)
  * fix：修正用量記錄篩選，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4883](https\://github.com/QuantumNous/new-api/pull/4883)
  * fix(web)：處理 API Key 無限額度驗證，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4881](https\://github.com/QuantumNous/new-api/pull/4881)
  * fix：公共模組頁頭導覽應用存取控制，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4889](https\://github.com/QuantumNous/new-api/pull/4889)
  * fix：修復 GetAllChannels 忽略群組篩選參數，由 @draftgo 提交於 [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * fix：限定 PerfMetric upsert 列名，避免 PostgreSQL 歧義，由 @SAY-5 提交於 [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * fix：管道清單查詢應用群組篩選，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4885](https\://github.com/QuantumNous/new-api/pull/4885)
  * feat：支援 request\_header 金鑰來源，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4903](https\://github.com/QuantumNous/new-api/pull/4903)
  * fix\: 修復新 UI 語言與文案顯示問題，由 @QuentinHsu 提交於 [https\://github.com/QuantumNous/new-api/pull/4876](https\://github.com/QuantumNous/new-api/pull/4876)
  * fix：預設主題 index.html 新增 umami 和 ga4 佔位符，由 @NitroRCr 提交於 [https\://github.com/QuantumNous/new-api/pull/4928](https\://github.com/QuantumNous/new-api/pull/4928)
  * perf：避免偵錯記錄提前格式化，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4929](https\://github.com/QuantumNous/new-api/pull/4929)
  * fix：忘記密碼按鈕新增 type="submit"，由 @lihan3238 提交於 [https\://github.com/QuantumNous/new-api/pull/4910](https\://github.com/QuantumNous/new-api/pull/4910)
  * fix(web)：規範模型詳情標籤版面配置，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4938](https\://github.com/QuantumNous/new-api/pull/4938)
  * fix(user)：修復管理面板使用者建立和刪除，由 @bugmaker2 提交於 [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * fix(auth)：/api/status 暴露 register\_enabled，並控制登入頁註冊連結，由 @Gnonymous 提交於 [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * fix(web/default)：明確 ModelCardGrid 分頁按鈕說明，由 @ellisfan 提交於 [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * fix(auth)：本機化重置密碼確認訊息，由 @neow021 提交於 [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * fix(web/default/wallet)：深色模式顯示儲值預設選取狀態，由 @xinnyu 提交於 [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)
  * fix(web/default)：修復語義變數不匹配引起 API 資訊色點錯誤，由 @Micah-Zheng 提交於 [https\://github.com/QuantumNous/new-api/pull/4824](https\://github.com/QuantumNous/new-api/pull/4824)
  * fix(web/default)：修復無效顏色或未檢查結果時 API 資訊靜默儲存失敗，由 @Micah-Zheng 提交於 [https\://github.com/QuantumNous/new-api/pull/4823](https\://github.com/QuantumNous/new-api/pull/4823)
  * fix(auth)：註冊載荷使用 aff\_code 欄位（#4945），由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/4965](https\://github.com/QuantumNous/new-api/pull/4965)
  * fix(data-table)：分面篩選彈窗寬度自適應（#4905），由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/4966](https\://github.com/QuantumNous/new-api/pull/4966)
  * fix(keys)：直接呼叫提交處理器，避免過期表單關聯（#4858），由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/4967](https\://github.com/QuantumNous/new-api/pull/4967)

  ### 新貢獻者

  * @draftgo 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * @SAY-5 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * @bugmaker2 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * @Gnonymous 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * @ellisfan 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * @neow021 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * @xinnyu 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-arm64-v1.0.0-rc.7) (82.3 MB)
  * [new-api-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7) (84.6 MB)
  * [new-api-v1.0.0-rc.7.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7.exe) (86.3 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.tar.gz)
</Callout>

***

## v1.0.0-rc.6

<Callout type="note" title="正式版本 · 發佈於 2026-05-13 22:29:13 (中國時間)">
  ### 重點更新

  通過在記錄中記錄上游請求 ID 改善可觀測性，並在付費功能前新增合規確認。如果 `logs` 表較大，請在升級前以線上 DDL 預先新增 `upstream_request_id` 列及索引，避免遷移耗時過長。

  ### 新增功能

  * 記錄支援跟蹤上游請求 ID，便於追蹤呼叫，且避免意外覆蓋回應標頭。
  * 使用付費功能前新增合規確認步驟。

  ### 問題修復

  * 修復管道組合選擇框聚焦後隱藏有效選項（#4829）。

  ### 其他

  * 升級提示：`logs` 表新增 `upstream_request_id` 列及索引；大規模部署應在升級前執行下方對應的線上 DDL，避免自動遷移長時間阻塞。

  MySQL / InnoDB：

  ```sql
  -- 1. Add the column using online DDL.
  ALTER TABLE logs
    ADD COLUMN upstream_request_id VARCHAR(128) NOT NULL DEFAULT '',
    ALGORITHM=INPLACE, LOCK=NONE;

  -- 2. Add the index using online DDL.
  ALTER TABLE logs
    ADD INDEX idx_logs_upstream_request_id (upstream_request_id),
    ALGORITHM=INPLACE, LOCK=NONE;
  ```

  PostgreSQL 11+：

  ```sql
  -- 1. Add the column without rewriting the table on PG 11+.
  ALTER TABLE logs
    ADD COLUMN IF NOT EXISTS upstream_request_id VARCHAR(128) NOT NULL DEFAULT '';

  -- 2. Add the index concurrently to avoid blocking reads and writes.
  CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_logs_upstream_request_id
    ON logs (upstream_request_id);
  ```

  ***

  ### 變更內容

  * chore(deps)：將 /web/classic 的 axios 從 1.15.0 升級到 1.15.2，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/4634](https\://github.com/QuantumNous/new-api/pull/4634)
  * chore(deps-dev)：將 /electron 的 ip-address 從 10.1.0 升級到 10.2.0，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/4811](https\://github.com/QuantumNous/new-api/pull/4811)
  * 修復管道清單顯示不全問題，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/4829](https\://github.com/QuantumNous/new-api/pull/4829)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-arm64-v1.0.0-rc.6) (82.3 MB)
  * [new-api-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6) (84.6 MB)
  * [new-api-v1.0.0-rc.6.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6.exe) (86.3 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.tar.gz)
</Callout>

***

## v1.0.0-rc.5

<Callout type="note" title="正式版本 · 發佈於 2026-05-12 16:53:57 (中國時間)">
  ### 重點更新

  預設儀錶盤更新，整合模型性能指標及清晰的健康視圖；支援 DeepChat 深度連結，修復預設介面、錢包、Playground 和倍率顯示回歸。

  ### 新增功能

  * 重新設計儀錶盤概覽，整合模型性能指標及更清晰的健康面板。
  * 支援 DeepChat 深度連結，可直接打開相容的聊天連結（#4668）。

  ### 問題修復

  * 儲值閘道可用性讀取正確儲值設定，準確展示付款選項（#4599）。
  * 群組倍率顯示遵循群組間倍率設定（#4772）。
  * 預設介面下拉選單可靠觸發選擇處理器（#4787）。
  * Playground 可正常處理舊版經典格式訊息（#4650）。
  * 修復預設介面多項 v1 回歸，包括空描述區域及版面配置問題（#4802）。

  ### 改進

  * 預設網頁及圖表採用共享主題預設，統一顏色、控制項及圓角。
  * Docker 鏡像包含項目和第三方許可證說明，便於合規審查（#4739）。

  ***

  ### 變更內容

  * feat：支援 DeepChat 深度連結，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4668](https\://github.com/QuantumNous/new-api/pull/4668)
  * fix：Docker 構建時不再通過 .dockerignore 排除 THIRD-PARTY-LICENSES.md，由 @yeying-xingchen 提交於 [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * fix(wallet)：從 topupInfo 而非 status 讀取儲值閘道標誌，由 @ImogeneOctaviap794 提交於 [https\://github.com/QuantumNous/new-api/pull/4599](https\://github.com/QuantumNous/new-api/pull/4599)
  * fix(web/default)：透過 getUserGroups 顯示倍率並遵循 GroupGroupRatio，由 @Micah-Zheng 提交於 [https\://github.com/QuantumNous/new-api/pull/4772](https\://github.com/QuantumNous/new-api/pull/4772)
  * fix(default)：支援 DropdownMenuItem onSelect，由 @lihan3238 提交於 [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)
  * fix(web/default)：相容 Playground 舊版經典訊息結構，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/4650](https\://github.com/QuantumNous/new-api/pull/4650)
  * fix：修復預設介面問題，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/4802](https\://github.com/QuantumNous/new-api/pull/4802)

  ### 新貢獻者

  * @yeying-xingchen 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * @lihan3238 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-arm64-v1.0.0-rc.5) (82.1 MB)
  * [new-api-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5) (84.5 MB)
  * [new-api-v1.0.0-rc.5.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5.exe) (86.2 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.tar.gz)
</Callout>

***

## v1.0.0-rc.4

<Callout type="note" title="正式版本 · 發佈於 2026-05-06 22:25:59 (中國時間)">
  ### 重點更新

  OpenAI 影像編輯更可靠：請求保留參考圖和相關元資料，避免丟失編輯上下文（#4646）；新增模型性能徽標，修復計費及下拉介面問題。

  ### 新增功能

  * 模型清單新增性能徽標，便於快速比較可用模型。

  ### 問題修復

  * OpenAI 影像編輯轉發保留參考圖及相關元資料（#4646）。
  * 修復計費設定表單，使儲值及計費設定輸入更可靠。
  * 修復介面元件更新後下拉及選擇控制項的顯示和選取（#4655）。

  ### 不相容變更

  * 整合現在應從儲值資訊 API 而非狀態 API 讀取儲值連結。

  ### 介面展示

  | 模型可用性排名                                                                                               | 更新後的價格和設定介面                                                                                           |
  | ----------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
  | ![Gallery 發佈說明中的配圖](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Gallery 發佈說明中的配圖](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### 變更內容

  * fix：保留 OpenAI 影像編輯參考欄位，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4646](https\://github.com/QuantumNous/new-api/pull/4646)
  * fix：選擇控制項遷移到 Base UI items API，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4655](https\://github.com/QuantumNous/new-api/pull/4655)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-arm64-v1.0.0-rc.4) (82.0 MB)
  * [new-api-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4) (84.4 MB)
  * [new-api-v1.0.0-rc.4.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4.exe) (86.1 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.tar.gz)
</Callout>

***

## v1.0.0-rc.3

<Callout type="note" title="正式版本 · 發佈於 2026-05-06 18:43:33 (中國時間)">
  ### 重點更新

  v1.0.0-rc.3 新增模型排名，展示可用性和性能，便於在選擇路由或供應商前比較可靠性。同時更新預設介面的價格、設定頁和表格控制項。

  ### 新增功能

  * 新增模型排名儀錶盤，展示真實可用性和性能資料以比較可靠性（#4633）。

  ### 改進

  * 預設介面更新為 Base UI 元件及新主題預設，改善表格工具欄互動（#4633）。
  * 重新組織系統價格設定，便於瀏覽和管理。

  ### 問題修復

  * 修復管道表格的伺服器端排序（#4600）。
  * 修復預設介面的訂閱付款資訊顯示。

  ### 介面展示

  | 模型可用性排名                                                                                               | 更新後的價格和設定介面                                                                                           |
  | ----------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
  | ![Gallery 發佈說明中的配圖](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Gallery 發佈說明中的配圖](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### 變更內容

  * feat(web/default)：統一介面重構，遷移 Base UI、主題、排名面板和表格工具欄，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/4633](https\://github.com/QuantumNous/new-api/pull/4633)
  * feat：採集模型性能指標，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/4635](https\://github.com/QuantumNous/new-api/pull/4635)
  * fix：啟用管道表格伺服器端排序，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4600](https\://github.com/QuantumNous/new-api/pull/4600)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-arm64-v1.0.0-rc.3) (81.9 MB)
  * [new-api-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3) (84.4 MB)
  * [new-api-v1.0.0-rc.3.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3.exe) (86.1 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.tar.gz)
</Callout>

***

## v1.0.0-rc.2

<Callout type="note" title="正式版本 · 發佈於 2026-04-30 20:42:48 (中國時間)">
  ### 重點更新

  v1.0.0-rc.2 正式開放新版與經典前端切換，方便測試新介面、比較工作流程，並在需要時快速切回。此候選版本也更新控制台核心頁面，修正電子郵件綁定、階梯價格、API Key 分組與自訂 Vertex 基礎位址問題。

  ### 新增功能

  * 內建新舊前端切換，使團隊可逐步採用新介面並保留原有工作流程。

  ### 改進

  * 更新控制台價格頁、儀錶盤和記錄控制項，改善表格分析篩選、導覽及移動端適配。

  ### 問題修復

  * 修復新版前端郵箱綁定（#4551）。
  * 修復階梯價格數字輸入，提高編輯可靠性（#4536）。
  * 修復階梯價格數值和標籤顯示異常（#4530）。
  * 修復預設主題 API Key 群組，使金鑰顯示於正確群組（#4548）。
  * 修復 Vertex 自訂基址在設定閘道前綴時的路由（#4200）。

  ### 介面展示

  | 更新後的價格頁面                                                                                      | 儀錶盤和分析控制項                                                                                      |
  | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
  | ![更新後的價格頁面](https\://github.com/user-attachments/assets/8d403155-27ac-407d-b0ae-8815034c66a7) | ![儀錶盤和分析控制項](https\://github.com/user-attachments/assets/caa73f0a-13d2-47fc-ab7d-0ffb4e7b6194) |

  ### 變更內容

  * fix\: 修復預設主題 API 金鑰群組行為，由 @Micah-Zheng 提交於 [https\://github.com/QuantumNous/new-api/pull/4548](https\://github.com/QuantumNous/new-api/pull/4548)
  * bug fix\: 新版前端email綁定錯誤，由 @SHLE1 提交於 [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)
  * fix：改善階梯價格數值編輯，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4536](https\://github.com/QuantumNous/new-api/pull/4536)
  * fix(vertex)：將自訂 base\_url 作為閘道前綴，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4200](https\://github.com/QuantumNous/new-api/pull/4200)
  * fix(web)\: 修復階梯計費 Base64 解碼失敗與標籤不匹配導致的顯示錯誤，由 @wans10 提交於 [https\://github.com/QuantumNous/new-api/pull/4530](https\://github.com/QuantumNous/new-api/pull/4530)

  ### 新貢獻者

  * @SHLE1 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-arm64-v1.0.0-rc.2) (76.5 MB)
  * [new-api-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2) (78.9 MB)
  * [new-api-v1.0.0-rc.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2.exe) (80.6 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.tar.gz)
</Callout>

***

## v1.0.0-rc.1

<Callout type="note" title="正式版本 · 發佈於 2026-04-29 20:15:01 (中國時間)">
  v1.0.0-rc.1 是 1.0 的首個候選版本，重點是從頭重建 v1 前端，提供更清晰、更快速、更完善的管理體驗。

  此候選版更新導覽、設定、分析和記錄，在邁向 v1 正式版時簡化日常管理。

  ![v1.0.0-rc.1 發佈說明中的配圖](https\://github.com/user-attachments/assets/f3f8ed32-e0c5-4cfb-94a3-da0f357b62ab)

  ### 新增功能

  * 推出重建的 v1 前端，包含現代導覽版面配置、可視化參數覆蓋編輯器，以及更易存取的系統設定和主題切換（#4265）。

  ### 改進

  * 升級儀錶盤和圖表，提供更清晰的模型分析、資料排序及提示。
  * 完善用量記錄型別標誌、使用者名稱、頭像和表格，提高瀏覽效率。
  * 統一預設前端共享版面配置、表格和表單樣式。

  ### 問題修復

  * 從資料庫載入的主題可正確應用到執行時（#4518）。
  * 轉發請求保留空思考欄位，不再靜默丟棄（#4520）。
  * 修復必填欄位標記，明確展示必須填寫的輸入（#4533）。

  ***

  ### 變更內容

  * 🚀 feat：發佈 v1.0，從頭構建下一代前端，由 @t0ng7u 提交於 [https\://github.com/QuantumNous/new-api/pull/4265](https\://github.com/QuantumNous/new-api/pull/4265)
  * fix\: 修復 Message.ReasoningContent/Reasoning 空思考內容在請求轉發時被靜默丟棄，由 @heimoshuiyu 提交於 [https\://github.com/QuantumNous/new-api/pull/4520](https\://github.com/QuantumNous/new-api/pull/4520)
  * fix：資料庫載入主題後同步到執行時，由 @Micah-Zheng 提交於 [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  ### 新貢獻者

  * @Micah-Zheng 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-arm64-v1.0.0-rc.1) (76.4 MB)
  * [new-api-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1) (78.8 MB)
  * [new-api-v1.0.0-rc.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1.exe) (80.5 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.tar.gz)
</Callout>

***

## v1.0.0-alpha.1 — 授權條款邊界版本

<Callout type="note" title="預發佈版本 · 發佈於 2026-04-28 14:26:06 (中國時間)">
  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1](https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1)

  **下載資源**

  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.tar.gz)
</Callout>

***

## v0.13.2

<Callout type="note" title="正式版本 · 發佈於 2026-04-27 22:11:42 (中國時間)">
  ### 新增功能

  * 模型同步更準確地發現上游，自動從價格端點重新整理價格，顯示已移除上游模型，並在同步延遲時保持價格可用（#4452）。
  * 使用者記錄包含帳戶建立和最後登入時間，便於審計管理（#4450）。
  * 阿里原生 Messages API 支援可設定模型匹配，便於路由到相容上游（#4468）。

  ### 問題修復

  * 工具呼叫接受原始 JSON 參數，提高與回傳 JSON 物件供應商的相容性（#4469）。
  * 設定更新更可靠地處理 JSON 物件欄位，避免錯誤儲存。

  ### 改進

  * 重試資訊明確說明因親和性禁用而跳過管道（#4453）。

  ***

  ### 變更內容

  * fix(channel)：檢查上游模型時載入模型對應，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4437](https\://github.com/QuantumNous/new-api/pull/4437)
  * feat：從價格端點同步上游價格，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4452](https\://github.com/QuantumNous/new-api/pull/4452)
  * fix：明確親和性禁用時的重試資訊，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4453](https\://github.com/QuantumNous/new-api/pull/4453)
  * feat：阿里原生 Messages 支援模型匹配設定，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4468](https\://github.com/QuantumNous/new-api/pull/4468)
  * fix：支援原始 JSON 回應工具參數，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4469](https\://github.com/QuantumNous/new-api/pull/4469)
  * feat：取得模型彈窗顯示已移除上游模型，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4470](https\://github.com/QuantumNous/new-api/pull/4470)
  * 增加使用者建立時間和最後登入時間，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/4450](https\://github.com/QuantumNous/new-api/pull/4450)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2](https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.0.13.2.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.Setup.0.13.2.exe) (106.8 MB)
  * [new-api-arm64-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-arm64-v0.13.2) (64.6 MB)
  * [new-api-macos-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-macos-v0.13.2) (83.2 MB)
  * [new-api-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2) (67.0 MB)
  * [new-api-v0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2.exe) (68.6 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.tar.gz)
</Callout>

***

## v0.13.1-patch.1

<Callout type="note" title="正式版本 · 發佈於 2026-04-25 13:27:23 (中國時間)">
  ### 重點更新

  此補丁支援在階梯條件和 LLM 提示詞助手中使用 `len`，便於按提示詞長度定義規則。

  ### 新增功能

  * 為階梯條件和 LLM 提示詞助手新增 `len` 變數，以按提示詞長度定義規則。

  ***

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-linux.txt) (186 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-macos.txt) (96 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-windows.txt) (94 B)
  * [new-api-arm64-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-arm64-v0.13.1-patch.1) (64.6 MB)
  * [new-api-macos-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-macos-v0.13.1-patch.1) (83.2 MB)
  * [new-api-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1) (66.9 MB)
  * [new-api-v0.13.1-patch.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1.exe) (68.6 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.tar.gz)
</Callout>

***

## v0.13.1

<Callout type="note" title="正式版本 · 發佈於 2026-04-24 22:20:58 (中國時間)">
  #### 新增功能

  * 支援處理 DeepSeek V4 思考後綴（#4428）

  #### 問題修復

  * 修復階梯計費模型未包含在模型清單中（#4431）

  ***

  ### 變更內容

  * fix：模型清單包含階梯計費模型，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4431](https\://github.com/QuantumNous/new-api/pull/4431)
  * feat：實現並測試 DeepSeek V4 思考後綴，由 @HynoR 提交於 [https\://github.com/QuantumNous/new-api/pull/4428](https\://github.com/QuantumNous/new-api/pull/4428)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1](https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.0.13.1.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.Setup.0.13.1.exe) (106.7 MB)
  * [new-api-arm64-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-arm64-v0.13.1) (64.6 MB)
  * [new-api-macos-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-macos-v0.13.1) (83.2 MB)
  * [new-api-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1) (66.9 MB)
  * [new-api-v0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1.exe) (68.6 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.tar.gz)
</Callout>

***

## v0.13.0

<Callout type="note" title="正式版本 · 發佈於 2026-04-24 14:09:21 (中國時間)">
  ### 重點更新

  此版本支援基於 `expr` 表達式的階梯計費，管理員可設定複雜動態規則。例如 `tokens <= 128000 ? 0.002 : 0.004`，系統會在用量低於 128K Token 時使用較低價格，超過後使用較高價格。

  ### 新增功能

  * 計費系統支援求值 `expr` 表達式，提供可設定預設的動態階梯價格（#4409）。
  * 新增工具價格設定介面，改善工具呼叫額度計算。
  * 管理員儲值帳單顯示使用者 ID，便於追蹤（#4349）。
  * 權杖表新增最後使用時間列（#4372）。
  * 放寬金鑰列長度限制，以遷移更長的舊版權杖（#4401）。

  ### 問題修復

  * 確保計價邏輯僅對影像模型應用 N 倍率（#4412）。
  * 階梯計費結算正確保留文字工具附加費（#4162）。
  * 修正 `gpt-5.5` 模型的補全倍率（#4414）。
  * 修復模型價格介面使用的顯示型別（#4426）。
  * 修復階梯編輯器和結算邏輯中的執行時崩潰及邊界問題。
  * 更新管道測試，正確支援和評估階梯計費模型。

  ### 改進

  * 新增豆包 Seed 1.8 預設價格階梯，改善折扣計算。
  * 將 Card 元件替換為 div，以提高整體版面配置一致性。
  * 內部計費計算使用每單位額度，提高精度。

  ***

  ### 變更內容

  * fix(channel-test)：支援階梯計費模型測試，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4145](https\://github.com/QuantumNous/new-api/pull/4145)
  * 在管理員儲值帳單中顯示使用者 ID，由 @uskyu 提交於 [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * 增加權杖最後使用時間，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/4372](https\://github.com/QuantumNous/new-api/pull/4372)
  * chore(deps)：將 github.com/jackc/pgx/v5 從 5.9.0 升級到 5.9.2，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/4397](https\://github.com/QuantumNous/new-api/pull/4397)
  * chore(deps-dev)：將 /electron 的 @xmldom/xmldom 從 0.8.12 升級到 0.8.13，由 @dependabot\[bot] 提交於 [https\://github.com/QuantumNous/new-api/pull/4399](https\://github.com/QuantumNous/new-api/pull/4399)
  * 放寬金鑰列長度，相容舊版遷移，由 @XiaoAI1024 提交於 [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * fix(billing)：階梯結算保留文字工具附加費，由 @yyhhyyyyyy 提交於 [https\://github.com/QuantumNous/new-api/pull/4162](https\://github.com/QuantumNous/new-api/pull/4162)
  * feat：計費系統支援階梯價格表達式，由 @Calcium-Ion 提交於 [https\://github.com/QuantumNous/new-api/pull/4409](https\://github.com/QuantumNous/new-api/pull/4409)
  * fix(image)：僅對影像模型使用 N 倍率，由 @xyfacai 提交於 [https\://github.com/QuantumNous/new-api/pull/4412](https\://github.com/QuantumNous/new-api/pull/4412)
  * fix：修正 gpt-5.5 補全倍率，由 @jingx8885 提交於 [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)
  * fix：模型價格使用正確顯示型別，由 @feitianbubu 提交於 [https\://github.com/QuantumNous/new-api/pull/4426](https\://github.com/QuantumNous/new-api/pull/4426)

  ### 新貢獻者

  * @uskyu 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * @XiaoAI1024 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * @jingx8885 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0](https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.0.13.0.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.Setup.0.13.0.exe) (106.8 MB)
  * [new-api-arm64-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-arm64-v0.13.0) (64.6 MB)
  * [new-api-macos-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-macos-v0.13.0) (83.2 MB)
  * [new-api-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0) (66.9 MB)
  * [new-api-v0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0.exe) (68.6 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.tar.gz)
</Callout>

***

## v0.12.15

<Callout type="note" title="正式版本 · 發佈於 2026-04-22 23:04:03 (中國時間)">
  #### 新增功能

  * 支援 Waffo Pay 帳戶儲值和付款流程（#4089）。

  #### 問題修復

  * 修復儲值卡介面部群組件失效（#4388）。

  #### 改進

  * 支援 Gemini 的 `IncludeServerSideToolInvocations` 設定，位於 `ToolConfig`，提高新版 Gemini 工具呼叫相容性（#4311）。
  * 通過重新整理自動禁用管道憑證、自動串流測試及優化用量彈窗，改善 Codex 管道可靠性和易用性（#4324）。

  ***

  ### 變更內容

  * fix(gemini)：ToolConfig 新增 IncludeServerSideToolInvocations 欄位，由 @KoellM 提交於 [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * refactor：付款流程，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4089](https\://github.com/QuantumNous/new-api/pull/4089)
  * fix(topup)：匯入儲值卡缺失的 Tag，由 @gaoren002 提交於 `#4388`
  * chore：優化 Codex 用量彈窗版面配置，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4386](https\://github.com/QuantumNous/new-api/pull/4386)
  * fix：Codex 自動測試使用串流，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4325](https\://github.com/QuantumNous/new-api/pull/4325)
  * fix：重新整理自動禁用管道的 Codex 憑證，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4324](https\://github.com/QuantumNous/new-api/pull/4324)
  * fix：修改 passkey 時要求正確驗證，由 @seefs001 提交於 [https\://github.com/QuantumNous/new-api/pull/4393](https\://github.com/QuantumNous/new-api/pull/4393)

  ### 新貢獻者

  * @KoellM 首次貢獻於 [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * @gaoren002 首次貢獻於 `#4388`

  **完整變更記錄**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15](https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15)

  **下載資源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-linux.txt) (172 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-macos.txt) (89 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-windows.txt) (87 B)
  * [New-API-App.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.0.12.15.exe) (106.3 MB)
  * [New-API-App.Setup.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.Setup.0.12.15.exe) (106.6 MB)
  * [new-api-arm64-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-arm64-v0.12.15) (63.7 MB)
  * [new-api-macos-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-macos-v0.12.15) (82.0 MB)
  * [new-api-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15) (66.0 MB)
  * [new-api-v0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15.exe) (67.7 MB)
  * [原始碼（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.zip)
  * [原始碼（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.tar.gz)
</Callout>

***