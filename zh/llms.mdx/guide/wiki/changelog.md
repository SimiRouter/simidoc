# 更新日志

<Callout type="warn" title="版本日志信息 · 数据更新于 2026-8-12 18:48:26">
  如需查看全部历史版本，请访问 [GitHub Releases 页面](https\://github.com/QuantumNous/new-api/releases)。本页内容不是实时数据，最近一次同步时间见本提示标题；上游发布节奏快于本页时，以上游为准。
</Callout>

## v1.0.0-rc.24

<Callout type="info" title="本页最新记录 · 发布于 2026-08-07 17:47:48 (中国时间)">
  ### 版本：v1.0.0-rc.24

  #### 新增功能

  * 为访问令牌和推广返利转账路由添加用户关键操作限流中间件，提高安全性与稳定性。
  * 优化渠道中获取模型的分类，便于组织和查找。

  #### 问题修复

  * 修复兑换码额度精度损失，确保准确分配额度（#6685）。
  * 通过正确设置 `Request.GetBody`，修复上游流重置后 HTTP/2 传输无法透明重试的问题（#6249）。
  * 确保 Claude 和 Gemini 端点使用原生请求格式进行测试，提高兼容性。

  #### 其他

  * 增强版本同步工作流，支持在 CI 中选择性同步文件。

  ***

  ### 变更内容

  * fix(relay)：设置 Request.GetBody，使 HTTP/2 在上游流重置后可透明重试，由 @BlockchainHe 提交于 [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * feat(channels)：优化获取模型的分类，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6632](https\://github.com/QuantumNous/new-api/pull/6632)
  * fix：使用原生格式测试 Claude/Gemini 端点，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6698](https\://github.com/QuantumNous/new-api/pull/6698)
  * fix\: 修复兑换码额度精度损失(#6680)，由 @lihu-001 提交于 [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  ### 新贡献者

  * @BlockchainHe 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * @lihu-001 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-arm64-v1.0.0-rc.24) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-macos-v1.0.0-rc.24) (132.6 MB)
  * [new-api-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24) (113.2 MB)
  * [new-api-v1.0.0-rc.24.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24.exe) (115.1 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.tar.gz)
</Callout>

***

## v1.0.0-rc.23

<Callout type="note" title="正式版本 · 发布于 2026-08-01 23:25:04 (中国时间)">
  重点更新：扩展 New API 渠道、DeepSeek Responses API、zstd 请求解压和自动分组路由的兼容性；日志可显示流式状态，阶梯重试计费更可靠，并在客户端断开时取消 Bedrock 上游请求。

  ### 新增功能

  * 支持 New API 渠道，包括 Gemini 转 OpenAI 流式转换、Advanced Custom Responses Compact 处理和 multipart 图像编辑（#6559）。
  * 支持 DeepSeek Responses API（#6562）。
  * 支持请求路由自动选择分组（#6590）。
  * 添加按渠道配置的 HTTP 传输控制，便于调整连接行为。
  * 支持 zstd 压缩请求（#6545）。
  * 日志所属用户现在可以查看请求是否采用流式（#6558）。

  ### 问题修复

  * Qwen `thinking_budget` 现在会在请求转发时保留（#5836）。
  * 阶梯重试计费按最终选择的分组结算，包括重试时切换分组的情况（#6570）。
  * 客户端断开时取消 Bedrock 请求，减少无效上游工作（#6589）。

  ### 改进

  * 统一公共页头导航链接的字号（#6557）。

  ***

  ### 变更内容

  * refactor：将协议转换层提取为独立 relaykit 模块，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/6369](https\://github.com/QuantumNous/new-api/pull/6369)
  * fix\: 慢查询/错误 SQL 日志参数化，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6493](https\://github.com/QuantumNous/new-api/pull/6493)
  * feat(oidc)\: 支持自定义 OIDC 登录显示名称，由 @mrchi 提交于 [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * fix：保留 Qwen thinking\_budget 透传，由 @wxwwt 提交于 [https\://github.com/QuantumNous/new-api/pull/5836](https\://github.com/QuantumNous/new-api/pull/5836)
  * feat：支持 zstd 请求解压，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6545](https\://github.com/QuantumNous/new-api/pull/6545)
  * feat(logs)：向日志所属用户展示流式状态，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6558](https\://github.com/QuantumNous/new-api/pull/6558)
  * fix(relay)：保留 New API 渠道的 multipart 图像编辑，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6559](https\://github.com/QuantumNous/new-api/pull/6559)
  * fix(oauth)：不再将外部 window\.opener 当作绑定流程，由 @neimaravila 提交于 [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * style：将公共页头导航字号统一为 14px（text-sm），由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6557](https\://github.com/QuantumNous/new-api/pull/6557)
  * feat：支持 DeepSeek Responses API，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6562](https\://github.com/QuantumNous/new-api/pull/6562)
  * fix(billing)：阶梯重试按最终分组结算，由 @faithleysath 提交于 [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)
  * fix(billing)：加强阶梯重试切换分组计费（#6518 后续修复），由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/6570](https\://github.com/QuantumNous/new-api/pull/6570)
  * fix(aws)：客户端断开时取消 Bedrock 请求，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/6589](https\://github.com/QuantumNous/new-api/pull/6589)
  * 功能：自动分组，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/6590](https\://github.com/QuantumNous/new-api/pull/6590)

  ### 新贡献者

  * @mrchi 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * @neimaravila 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * @faithleysath 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-arm64-v1.0.0-rc.23) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-macos-v1.0.0-rc.23) (132.6 MB)
  * [new-api-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23) (113.2 MB)
  * [new-api-v1.0.0-rc.23.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23.exe) (115.0 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.tar.gz)
</Callout>

***

## v1.0.0-rc.22

<Callout type="note" title="正式版本 · 发布于 2026-07-26 21:19:04 (中国时间)">
  扩展渠道和模型管理，支持上游模型发现、新版 Gemini 图像模型、可配置计费和 Sub2API；改善流式、价格、退款、用户管理及管理界面的可靠性。

  ### 新增功能

  * 渠道可从高级自定义及 Codex 兼容上游发现可用模型（#6184）。
  * 支持最新 Gemini 图像正式版模型（#6371）。
  * 支持可配置工具价格、Sub2API 渠道和 alpha-search 计费。
  * 支持 OpenAI Realtime 正式版模型，改善路由兼容性（#6032）。

  ### 问题修复

  * 修复 Responses 转 Chat 流式响应重复产生工具调用（#6225）。
  * 创建同名模型不再清空已有价格（#6365）。
  * 未设置价格的模型视图仅列出所选渠道中的可用模型（#6126）。
  * 修复超大用户额度的数值溢出（#6134）。
  * 分页结果中的用户列表排序正常工作（#6194）。
  * 将 MiniMax 模型正确归属到 MiniMax 厂商（#6164）。
  * 修复 Playground 分组选择器的自动分组列表和长选项（#6163）。
  * 并发状态更新不再重复退还任务费用（#6074）。
  * 编辑充值金额时可完全清空输入框（#6473）。
  * 提高渠道行内优先级更新的可靠性（#6415）。

  ### 改进

  * 统一管理端 JSON 编辑体验，避免内容被界面问题隐藏（#6421）。
  * 用户搜索加入防抖，减少无效请求并提高响应速度（#6474）。
  * 改善代理渠道请求的兼容性和稳定性（#6157）。
  * 上游错误不明确时提供更有用的兜底日志（#6431）。

  ***

  ### 变更内容

  * fix：未定价模型列表仅显示渠道可用模型，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6126](https\://github.com/QuantumNous/new-api/pull/6126)
  * fix：永久删除用户时清理认证数据，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6168](https\://github.com/QuantumNous/new-api/pull/6168)
  * fix(users)：防止超大额度溢出，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/6134](https\://github.com/QuantumNous/new-api/pull/6134)
  * fix：识别 MiniMax 模型的厂商归属，由 @fux-dev 提交于 [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * fix：用户列表改为服务端排序，避免仅排序当前页，由 @DawnMoon1542 提交于 [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * fix(data-table)：切换列时立即更新表格内容，由 @DawnMoon1542 提交于 [https\://github.com/QuantumNous/new-api/pull/6253](https\://github.com/QuantumNous/new-api/pull/6253)
  * fix：防止 Responses 转 Chat 流式工具调用重复，由 @nikuleo 提交于 [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * feat(channel)：支持 Codex 上游模型发现，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6184](https\://github.com/QuantumNous/new-api/pull/6184)
  * feat：支持高级自定义渠道获取上游模型，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5971](https\://github.com/QuantumNous/new-api/pull/5971)
  * refactor(auth)：以无状态令牌及会话控制替换面板会话，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/6329](https\://github.com/QuantumNous/new-api/pull/6329)
  * fix\: 中转 gpt-realtime 系列 GA 模型时不再发送 realtime beta 标识，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6032](https\://github.com/QuantumNous/new-api/pull/6032)
  * fix(playground)：防止分组选项被拉伸，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/6120](https\://github.com/QuantumNous/new-api/pull/6120)
  * perf(data-table)：优化操作列宽度分配，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/6135](https\://github.com/QuantumNous/new-api/pull/6135)
  * fix(web)：显示无限额 API Key 的已用额度，由 @RedwindA 提交于 [https\://github.com/QuantumNous/new-api/pull/6224](https\://github.com/QuantumNous/new-api/pull/6224)
  * fix(channel)：改善代理兼容性和缓存生命周期，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/6157](https\://github.com/QuantumNous/new-api/pull/6157)
  * fix(playground)：修复自动分组模型列表，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/6163](https\://github.com/QuantumNous/new-api/pull/6163)
  * fix：通过 CAS 状态更新防止 Suno 任务重复退款，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6074](https\://github.com/QuantumNous/new-api/pull/6074)
  * chore(github)：将议题模板迁移为必填表单，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6452](https\://github.com/QuantumNous/new-api/pull/6452)
  * fix(github)：恢复议题表单可见性，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6454](https\://github.com/QuantumNous/new-api/pull/6454)
  * fix：上游错误消息解析为空时记录响应体，由 @bigsongeth 提交于 [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)
  * fix：创建同名模型时保留已有价格，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6365](https\://github.com/QuantumNous/new-api/pull/6365)
  * fix(web/channel)：稳定行内优先级更新，由 @RedwindA 提交于 [https\://github.com/QuantumNous/new-api/pull/6415](https\://github.com/QuantumNous/new-api/pull/6415)
  * perf(json-editor)：统一管理端 JSON 编辑体验，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/6421](https\://github.com/QuantumNous/new-api/pull/6421)
  * feat：添加 gemini-3-pro-image 和 gemini-3.1-flash-image 正式版模型，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6371](https\://github.com/QuantumNous/new-api/pull/6371)
  * feat：通过 OpenAI 兼容协议支持腾讯 TokenHub API Key，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6232](https\://github.com/QuantumNous/new-api/pull/6232)
  * fix：允许完全清空充值金额输入，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6473](https\://github.com/QuantumNous/new-api/pull/6473)
  * fix：用户搜索输入加入防抖，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6474](https\://github.com/QuantumNous/new-api/pull/6474)

  ### 新贡献者

  * @fux-dev 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * @DawnMoon1542 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * @nikuleo 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * @bigsongeth 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-arm64-v1.0.0-rc.22) (109.9 MB)
  * [new-api-macos-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-macos-v1.0.0-rc.22) (132.4 MB)
  * [new-api-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22) (113.0 MB)
  * [new-api-v1.0.0-rc.22.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22.exe) (114.9 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.tar.gz)
</Callout>

***

## v1.0.0-rc.21

<Callout type="note" title="正式版本 · 发布于 2026-07-11 23:01:26 (中国时间)">
  ### 重点更新

  重点更新为 GPT-5.6 缓存写入计费：OpenAI 的 `cache_write_tokens` 按缓存创建价格计费，并保护缓存及非缓存输入 Token 的计量一致性。同时改进定价流程、Playground 控件、渠道表格以及计费和日志可靠性。

  ### 新增功能

  * 支持 GPT-5.6 缓存写入计费，将 OpenAI 的 `cache_write_tokens` 按缓存创建价格结算，并保持缓存及非缓存输入 Token 计量一致。
  * 定价页面支持按分组动态计算，不再显示仅用于示例的特殊分组（#5906）。
  * 模型价格设置新增未定价模型页及状态、同步筛选，便于查找未定价模型（#6124）。
  * Playground 新增聊天和生成参数面板，可直接调整模型行为（#6044）。
  * 渠道列表支持手动调整列宽，并保持表格填满可用宽度（#5948）。
  * 日志显示流式时间指标和任务详情，便于排错。
  * 增强文本协议转换和高级自定义路由，提高渠道配置灵活性（#5825）。

  ### 问题修复

  * 防止浏览器翻译破坏 React 页面（#5963）。
  * 可一致地添加仅大小写不同的自定义模型名，包括多选控件（#6061）。
  * 改善额度预扣和图像流断连边界的计费处理。
  * 提高并发更新时订阅重置的可靠性（#6057）。
  * 正确同步 Codex Responses 透传字段（#6018）。
  * 模型变更后 Playground 模型选择器保持同步。
  * 自定义首页 iframe 可在用户操作后进行顶层导航（#5955）。
  * 恢复默认渠道连接配置的粘贴行为。

  ### 改进

  * 优化模型价格中上游价格同步表格的加载和渲染（#6092）。
  * 改善表格徽标、价格布局、同步对话框和默认主题样式，使管理界面更清晰。
  * 修复不同工作区布局中的字体资源解析。

  ***

  ### 变更内容

  * fix(web)：防止浏览器翻译修改 React 根节点，由 @cat0825 提交于 [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)
  * feat(web)\: 支持渠道列表手动调整列宽，由 @zuiho-kai 提交于 [https\://github.com/QuantumNous/new-api/pull/5948](https\://github.com/QuantumNous/new-api/pull/5948)
  * fix(web)：渠道表格填满可用宽度，由 @zuiho-kai 提交于 [https\://github.com/QuantumNous/new-api/pull/6031](https\://github.com/QuantumNous/new-api/pull/6031)
  * chore：删除 v1.0 发布提交重新引入的无用文件，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6041](https\://github.com/QuantumNous/new-api/pull/6041)
  * fix：订阅重置使用 GORM v2 行锁，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6057](https\://github.com/QuantumNous/new-api/pull/6057)
  * feat(playground)：添加参数设置面板，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/6044](https\://github.com/QuantumNous/new-api/pull/6044)
  * fix：允许多选添加仅大小写不同的模型名，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6061](https\://github.com/QuantumNous/new-api/pull/6061)
  * fix：移除泄漏到价格页的示例特殊分组，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5906](https\://github.com/QuantumNous/new-api/pull/5906)
  * perf(model-pricing)：优化上游价格同步表格，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/6092](https\://github.com/QuantumNous/new-api/pull/6092)
  * fix(web)：允许用户操作触发自定义首页 iframe 顶层导航，由 @Heykode 提交于 [https\://github.com/QuantumNous/new-api/pull/5955](https\://github.com/QuantumNous/new-api/pull/5955)
  * chore(deps)：将 golang.org/x/crypto 从 0.51.0 升级到 0.52.0，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/6096](https\://github.com/QuantumNous/new-api/pull/6096)
  * fix：同步 Codex Responses 透传字段，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/6018](https\://github.com/QuantumNous/new-api/pull/6018)
  * feat：增强文本协议转换和高级自定义路由，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/5825](https\://github.com/QuantumNous/new-api/pull/5825)
  * feat：模型价格设置添加未定价模型页，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/6124](https\://github.com/QuantumNous/new-api/pull/6124)

  ### 新贡献者

  * @cat0825 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-arm64-v1.0.0-rc.21) (129.6 MB)
  * [new-api-macos-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-macos-v1.0.0-rc.21) (152.2 MB)
  * [new-api-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21) (132.8 MB)
  * [new-api-v1.0.0-rc.21.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21.exe) (134.6 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.tar.gz)
</Callout>

***

## v1.0.0-rc.20

<Callout type="note" title="正式版本 · 发布于 2026-07-07 21:46:39 (中国时间)">
  ### 重点更新

  支持 GPT-5.6 价格和管理端失效实例清理工具；修复钱包奖励转账、分组小数倍率输入等额度与计费边界。

  ### 新增功能

  * 支持 GPT-5.6 模型 Token 价格。
  * 添加系统信息中的失效实例清理操作（#5953）。

  ### 问题修复

  * 钱包奖励转账使用已配置的额度单位，不再使用错误的固定值（#5808）。
  * 分组倍率字段可正常输入 `0.05` 等小数（#5995）。
  * 阶梯计费预扣时使用默认 Token 估算，改善相关规则的额度计算。

  ***

  ### 变更内容

  * fix\: 分组倍率 Ratio 输入框保留小数中间态,修复无法输入 0.05，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5995](https\://github.com/QuantumNous/new-api/pull/5995)
  * feat(system-info)：添加失效实例清理操作，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5953](https\://github.com/QuantumNous/new-api/pull/5953)
  * fix(wallet)：奖励转账遵循配置的额度单位，由 @A-Words 提交于 [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  ### 新贡献者

  * @A-Words 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-arm64-v1.0.0-rc.20) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-macos-v1.0.0-rc.20) (151.7 MB)
  * [new-api-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20) (132.4 MB)
  * [new-api-v1.0.0-rc.20.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20.exe) (134.2 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.tar.gz)
</Callout>

***

## v1.0.0-rc.19-i18nfix.2

<Callout type="note" title="正式版本 · 发布于 2026-07-07 14:06:07 (中国时间)">
  修复国际化错误

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-linux.txt) (200 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-macos.txt) (103 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-windows.txt) (101 B)
  * [new-api-arm64-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-arm64-v1.0.0-rc.19-i18nfix.2) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-macos-v1.0.0-rc.19-i18nfix.2) (151.7 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2) (132.4 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2.exe) (134.2 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.tar.gz)
</Callout>

***

## v1.0.0-rc.19

<Callout type="note" title="正式版本 · 发布于 2026-07-07 13:19:27 (中国时间)">
  ### 新增功能

  * 管理员可重置订阅额度并查看额度饱和事件，便于管理和审计（#5952）。
  * 新界面支持繁体中文 zh-TW（#5942）。

  ### 问题修复

  * 修复超大额度计费计算，确保正确应用限制。

  ***

  ### 变更内容

  * 新界面本地化为 zh-TW，由 @MeowTechOpenSource 提交于 [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)
  * feat(subscription)：添加管理员额度重置操作，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5952](https\://github.com/QuantumNous/new-api/pull/5952)

  ### 新贡献者

  * @MeowTechOpenSource 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-arm64-v1.0.0-rc.19) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-macos-v1.0.0-rc.19) (151.7 MB)
  * [new-api-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19) (132.4 MB)
  * [new-api-v1.0.0-rc.19.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19.exe) (134.2 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.tar.gz)
</Callout>

***

## v1.0.0-rc.18

<Callout type="note" title="正式版本 · 发布于 2026-07-07 01:16:57 (中国时间)">
  通过更严格的数量校验，提高计费额度处理可靠性，避免错误额度计算。

  **问题修复**

  * 改进计费数量校验，更可靠地处理无效或极端的额度和用量。

  ***

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-arm64-v1.0.0-rc.18) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-macos-v1.0.0-rc.18) (151.4 MB)
  * [new-api-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18) (132.0 MB)
  * [new-api-v1.0.0-rc.18.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18.exe) (133.9 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.tar.gz)
</Callout>

***

## v1.0.0-rc.17

<Callout type="note" title="正式版本 · 发布于 2026-07-06 22:37:46 (中国时间)">
  ### 重点更新

  改善渠道测试、兑换管理、主题和多项网页流程；修复用量报告、经典界面构建、流式断连及额度、视频时长计算。

  ### 新增功能

  * 兑换管理支持状态筛选和清理操作，便于管理。
  * 改善分组倍率编辑，优化可见性和 JSON 输入处理。
  * 兑换失败时显示更清晰的错误说明。

  ### 问题修复

  * AI Elements 集成读取嵌套用量，正确报告 Token 消耗。
  * 修复经典网页构建失败（#5892）。
  * Codex 渠道正确显示字段透传控件（#5902）。
  * 首页 iframe 与所选主题、语言保持同步（#5917）。
  * Shadow DOM 中的自定义 HTML 正确响应深浅色切换（#5890）。
  * 已登录用户访问注册页时，与登录及经典主题一致地重定向（#5910）。
  * 客户端断开后停止写入流式响应（#5710）。
  * 修复任务余额结算后的额度结算和阿里视频时长处理（#5923）。
  * DNS 查询失败不再导致构建日期生成失败（#5945）。

  ### 改进

  * 渠道和模型测试对话框更紧凑、更便于操作（#5886）。
  * 动态价格详情与日志详情对话框保持样式一致（#5905）。
  * 改善移动端用户卡片布局和可读性。
  * 优化旧充值警告文案，使其更清晰易懂（#5855）。

  ***

  ### 变更内容

  * chore(deps-dev)：将 /electron 的 tmp 从 0.2.5 升级到 0.2.7，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/5147](https\://github.com/QuantumNous/new-api/pull/5147)
  * chore(web)：更新默认前端依赖，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5884](https\://github.com/QuantumNous/new-api/pull/5884)
  * perf(web)：改善渠道测试对话框交互，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5886](https\://github.com/QuantumNous/new-api/pull/5886)
  * fix(classic)：修复经典网页构建失败，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5892](https\://github.com/QuantumNous/new-api/pull/5892)
  * fix(channels)：为 Codex 显示字段透传控件，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5902](https\://github.com/QuantumNous/new-api/pull/5902)
  * fix：动态价格样式与日志详情分区保持一致，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5905](https\://github.com/QuantumNous/new-api/pull/5905)
  * fix\: 任务差额结算后 quota 和阿里视频时长优化，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5923](https\://github.com/QuantumNous/new-api/pull/5923)
  * fix(web)：同步首页 iframe 的主题和语言，由 @guoruqiang 提交于 [https\://github.com/QuantumNous/new-api/pull/5917](https\://github.com/QuantumNous/new-api/pull/5917)
  * fix(web)\: 修复 Shadow DOM 隔离渲染下自定义 HTML 深浅色失效的问题，由 @olwater 提交于 [https\://github.com/QuantumNous/new-api/pull/5890](https\://github.com/QuantumNous/new-api/pull/5890)
  * fix(web)\: 注册页补充已登录重定向守卫，与登录页 / classic 主题保持一致 (#5908)，由 @Heykode 提交于 [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * feat：优化旧充值警告横幅文案（#5851），由 @Gravirei 提交于 [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)
  * fix：避免客户端断开后的过期流写入，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5710](https\://github.com/QuantumNous/new-api/pull/5710)
  * 修复构建日期的 DNS 错误，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5945](https\://github.com/QuantumNous/new-api/pull/5945)

  ### 新贡献者

  * @Heykode 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * @Gravirei 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-arm64-v1.0.0-rc.17) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-macos-v1.0.0-rc.17) (151.4 MB)
  * [new-api-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17) (132.0 MB)
  * [new-api-v1.0.0-rc.17.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17.exe) (133.8 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.tar.gz)
</Callout>

***

## v1.0.0-rc.16

<Callout type="note" title="正式版本 · 发布于 2026-07-03 15:41:42 (中国时间)">
  **重点更新**

  扩展 Responses/Chat 互转、豆包 Seedance 2.0 更新和 Wan2.7 图生视频媒体映射；改进 Playground 渲染、渠道管理、页面状态保留和优雅重启。

  **新增功能**

  * 支持 Responses API 转 Chat，提高不同协议客户端和供应商的互操作可靠性（#5787）。
  * 扩展豆包 Seedance 2.0，支持素材接口、分辨率计费、视频输入计费、4K 计费及新选项（#5824）。
  * 支持 Wan2.7 图生视频媒体映射（#4984）。
  * 支持优雅停机，减少回复中断和重启时面板缓存丢失（#4258）。
  * 改善渠道管理布局，增强高级自定义路由编辑器。

  **问题修复**

  * 切换模型时正确刷新阶梯价格表达式编辑器（#5752）。
  * 异步任务用量日志归属到发起任务的节点（#5684）。
  * 切换主题后返回首页，不再进入 404 路由（#5612）。
  * 自定义 HTML 和 Markdown 保持一致样式和间距，包括隔离 HTML 视图（#5795）。
  * 修复同路由切换标签时页面状态重置，包括仪表盘时间范围（#5796）。
  * 渠道状态筛选在页面导航后保留（#5863）。
  * 修复 Ollama 非流式工具调用（#5865）。
  * 修复 Waffo 商品信息和 webhook 行为（#5704）。

  **改进**

  * 改善 Playground 聊天体验和 Markdown 渲染（#5217）。
  * 简化表格操作及危险操作确认对话框（#5645）。
  * 改善 ClickHouse 日志 LIKE 查询筛选。
  * 优化前端构建管线，加快网页构建（#5786）。

  ***

  ### 变更内容

  * chore(deps)：将 /web/default 的 dompurify 从 3.4.5 升级到 3.4.11，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/5718](https\://github.com/QuantumNous/new-api/pull/5718)
  * fix(ci)：发布时安装经典工作区依赖，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5719](https\://github.com/QuantumNous/new-api/pull/5719)
  * perf(web)：简化表格操作和危险操作对话框，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5645](https\://github.com/QuantumNous/new-api/pull/5645)
  * fix：添加 Waffo 商品信息并更新 webhook SDK，由 @zhongyuanzhao-alt 提交于 [https\://github.com/QuantumNous/new-api/pull/5704](https\://github.com/QuantumNous/new-api/pull/5704)
  * fix(model-pricing)：切换模型时刷新阶梯表达式编辑器，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5752](https\://github.com/QuantumNous/new-api/pull/5752)
  * fix：同步 bun.lock 与 dompurify 3.4.11，恢复 frozen-lockfile 构建，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5738](https\://github.com/QuantumNous/new-api/pull/5738)
  * fix(theme)\: 切换前端主题后重置到首页，避免路由 404，由 @zhangzhichaolove 提交于 [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * fix(task)：异步任务用量日志归属发起节点，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5684](https\://github.com/QuantumNous/new-api/pull/5684)
  * feat：添加 Casbin 管理员权限，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/5755](https\://github.com/QuantumNous/new-api/pull/5755)
  * feat(playground)：改善聊天体验和 Markdown 渲染，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5217](https\://github.com/QuantumNous/new-api/pull/5217)
  * fix(auth)：统一密码校验文案，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5759](https\://github.com/QuantumNous/new-api/pull/5759)
  * fix(web)：一致地渲染自定义 HTML 和 Markdown，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5760](https\://github.com/QuantumNous/new-api/pull/5760)
  * fix(openai)：加强 Chat 转 Responses 兼容性，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/5772](https\://github.com/QuantumNous/new-api/pull/5772)
  * feat：支持 Responses 转 Chat，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/5787](https\://github.com/QuantumNous/new-api/pull/5787)
  * feat\: doubao-seedance-2-0-260128支持按分辨率区分计费，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5300](https\://github.com/QuantumNous/new-api/pull/5300)
  * feat：支持豆包 Seedance 2.0 safety\_identifier/priority 与 4K 计费，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5824](https\://github.com/QuantumNous/new-api/pull/5824)
  * fix(web)\: 修复自定义 HTML 样式被过滤及排版间距异常的问题，由 @olwater 提交于 [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * feat：支持 Wan2.7 图生视频媒体映射，由 @wxwwt 提交于 [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * perf(web)：优化 Rsbuild 和 Tailwind 构建管线，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5786](https\://github.com/QuantumNous/new-api/pull/5786)
  * fix(makefile)：dev-web 仅启动默认网页开发服务器，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5794](https\://github.com/QuantumNous/new-api/pull/5794)
  * fix(web)：向隔离 HTML 注入应用样式，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5860](https\://github.com/QuantumNous/new-api/pull/5860)
  * fix：同路由切换标签时保留状态，避免仪表盘时间重置，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5796](https\://github.com/QuantumNous/new-api/pull/5796)
  * 支持服务优雅关闭,避免重启回复中断和面板缓存数据丢失，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/4258](https\://github.com/QuantumNous/new-api/pull/4258)
  * fix：默认主题认证守卫仅将 401 视为会话过期，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5872](https\://github.com/QuantumNous/new-api/pull/5872)
  * fix：页面导航后保留渠道状态筛选，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5863](https\://github.com/QuantumNous/new-api/pull/5863)
  * chore(deps)：将 golang.org/x/net 从 0.50.0 升级到 0.55.0，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/5862](https\://github.com/QuantumNous/new-api/pull/5862)
  * chore(deps)：将 golang.org/x/image 从 0.38.0 升级到 0.41.0，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/5873](https\://github.com/QuantumNous/new-api/pull/5873)
  * fix：处理 Ollama 非流式工具调用，由 @stevenjoezhang 提交于 [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  ### 新贡献者

  * @zhangzhichaolove 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * @olwater 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * @wxwwt 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * @stevenjoezhang 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-arm64-v1.0.0-rc.16) (127.4 MB)
  * [new-api-macos-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-macos-v1.0.0-rc.16) (149.8 MB)
  * [new-api-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16) (130.5 MB)
  * [new-api-v1.0.0-rc.16.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16.exe) (132.3 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.tar.gz)
</Callout>

***

## v1.0.0-rc.15

<Callout type="note" title="正式版本 · 发布于 2026-06-24 21:00:04 (中国时间)">
  ### 重点更新

  添加运维控制，包括被动渠道监控、ClickHouse 日志存储、系统任务和实例可见性；改善用量日志、Markdown、渠道选择和可选钱包界面的可靠性。

  ### 新增功能

  * 支持被动渠道监控，在不主动干扰流量的情况下检查健康状态（#5592）。
  * 支持 ClickHouse 日志存储，为大规模存储与查询提供选项（#5663）。
  * 添加系统任务执行器，持久跟踪长时间维护清理的进度（#5680）。
  * 添加系统实例信息面板，便于查看部署和节点状态（#5716）。
  * 系统设置添加用户令牌数量限制配置（#5678）。
  * 渠道测试支持选择环境和配置异步轮询间隔。
  * 未设置 `NODE_NAME` 时，默认节点名使用机器主机名（#5659）。

  ### 问题修复

  * 用量日志正确显示国内模型的厂商图标（#5631）。
  * 修正 Stepfun 厂商显示名称（#5636）。
  * 修复 SMTP STARTTLS 模式和 NTLM 认证兼容性（#5426）。
  * 修复时区日期处理导致的经典主题构建失败（#5676）。
  * 改善网页 Markdown 渲染并扩展语法支持（#5689）。
  * 渠道卡片选中状态与当前渠道保持同步（#5700）。
  * 钱包模块禁用时隐藏个人菜单中的钱包入口（#5708）。

  ### 改进

  * 结合 ClickHouse 日志和系统维护任务简化日志清理。

  ***

  ### 变更内容

  * fix(usage-logs)：为国内模型显示厂商图标，与经典前端一致，由 @DeliciousBuding 提交于 [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * fix：将 StepFun 修正为 Stepfun，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5636](https\://github.com/QuantumNous/new-api/pull/5636)
  * feat：支持被动渠道监控，由 @exherb 提交于 [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)
  * feat：NODE\_NAME 未设置时默认使用主机名，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5659](https\://github.com/QuantumNous/new-api/pull/5659)
  * feat：支持 ClickHouse 日志数据库，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/5663](https\://github.com/QuantumNous/new-api/pull/5663)
  * fix：支持 SMTP STARTTLS 和 NTLM 认证，由 @bensonfx 提交于 [https\://github.com/QuantumNous/new-api/pull/5426](https\://github.com/QuantumNous/new-api/pull/5426)
  * chore(deps)：将 github.com/ClickHouse/ch-go 从 0.58.2 升级到 0.65.0，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/5664](https\://github.com/QuantumNous/new-api/pull/5664)
  * fix：修复 date-fns-tz 经典主题构建错误，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5676](https\://github.com/QuantumNous/new-api/pull/5676)
  * feat：添加系统任务执行器，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/5680](https\://github.com/QuantumNous/new-api/pull/5680)
  * feat：添加系统实例信息面板，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/5716](https\://github.com/QuantumNous/new-api/pull/5716)
  * fix(web)：替换默认 Markdown 渲染器并扩展语法，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5689](https\://github.com/QuantumNous/new-api/pull/5689)
  * fix(web)：同步渠道卡片选中状态，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5700](https\://github.com/QuantumNous/new-api/pull/5700)
  * fix(web)：钱包模块禁用时隐藏个人菜单入口，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5708](https\://github.com/QuantumNous/new-api/pull/5708)
  * feat(system-settings)：添加用户令牌限制配置，由 @RedwindA 提交于 [https\://github.com/QuantumNous/new-api/pull/5678](https\://github.com/QuantumNous/new-api/pull/5678)

  ### 新贡献者

  * @DeliciousBuding 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * @exherb 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-arm64-v1.0.0-rc.15) (131.4 MB)
  * [new-api-macos-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-macos-v1.0.0-rc.15) (153.3 MB)
  * [new-api-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15) (134.2 MB)
  * [new-api-v1.0.0-rc.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15.exe) (136.0 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.tar.gz)
</Callout>

***

## v1.0.0-rc.14

<Callout type="note" title="正式版本 · 发布于 2026-06-20 22:15:42 (中国时间)">
  ### 重点更新

  仪表盘新增流量桑基图，展示 Token 路由和流向，支持交互高亮、持久筛选及大图规模限制。渠道卡片布局更快更清晰，减少不必要的重渲染。

  ### 新增功能

  * 添加仪表盘流量桑基图，便于快速理解 Token 流向和路由行为（#5465）。
  * 添加路由可靠性管理，提高路由行为的控制与可见性。

  ### 界面展示

  | 流量图                                                                                             | 渠道管理卡片布局                                                                                              |
  | ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
  | ![渠道管理卡片布局示例](https\://github.com/user-attachments/assets/e0d82bd4-e052-4518-9fac-1144c0bd0721) | ![Gallery 发布说明中的配图](https\://github.com/user-attachments/assets/2ab5e6e6-f4f7-44f5-9abd-7191ed30e7aa) |

  ### 问题修复

  * 修复新前端按登录类型筛选日志（#5620）。
  * 修复账单历史对话框分页与列表重叠（#5627）。
  * 修复可视化价格列表中部分模型价格无法删除（#5628）。
  * 修复重启后重复执行数据库列迁移（#5361、#5616）。

  ### 改进

  * 改善渠道管理卡片，减少无效重渲染，使体验更流畅。
  * 简化模型列表，便于浏览和管理。
  * 更新渠道图标以保持视觉一致。

  ***

  ### 变更内容

  * fix：停止重启后重复迁移 allow\_balance\_pay 列，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5361](https\://github.com/QuantumNous/new-api/pull/5361)
  * fix：停止重启后重复迁移 allow\_wallet\_overflow 列，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5616](https\://github.com/QuantumNous/new-api/pull/5616)
  * feat(dashboard)\: 增加分流图，查看token流量。add traffic flow sankey chart，由 @Quaternijkon 提交于 [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)
  * fix(log)\: 修复新前端日志按登录类型(type=7)筛选失效，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5620](https\://github.com/QuantumNous/new-api/pull/5620)
  * fix(wallet)\: 修复计费历史弹窗分页与列表重叠 (#5624)，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5627](https\://github.com/QuantumNous/new-api/pull/5627)
  * fix(model-pricing)\: 修复模型定价列表项无法删除 (#5623)，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5628](https\://github.com/QuantumNous/new-api/pull/5628)

  ### 新贡献者

  * @Quaternijkon 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-arm64-v1.0.0-rc.14) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-macos-v1.0.0-rc.14) (142.3 MB)
  * [new-api-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14) (125.4 MB)
  * [new-api-v1.0.0-rc.14.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14.exe) (127.1 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.tar.gz)
</Callout>

***

## v1.0.0-rc.13

<Callout type="note" title="正式版本 · 发布于 2026-06-19 20:28:34 (中国时间)">
  v1.0.0-rc.13 重点改善前端体验与响应速度，尤其是渠道管理和密集数据页面。渠道页支持卡片展示及更好的移动布局，日志、指标、端点选择、日期和用量视图也得到完善。

  ### 新增功能

  * 添加可复用的卡片/表格切换，包括适应不同屏幕的渠道及密集数据卡片布局。
  * 支持按语言区域格式化数字，使各地区用户更易阅读。

  ### 改进

  * 改善渠道卡片左右结构及小屏幕移动布局。
  * 完善日志、指标、端点选择、日期、工具栏和模型抽屉，使界面更统一。
  * 改善 Codex 用量界面的可读性和易用性（#5595）。
  * 减少浏览器窗口重新聚焦时的无效数据刷新，提高前端性能。
  * 统一前端品牌文案和视觉样式。

  ### 问题修复

  * 在需要时显示毫秒，提高绘图相关时间戳精度。

  ***

  ### 变更内容

  * chore(web)：默认前端执行 oxc 质量检查，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5585](https\://github.com/QuantumNous/new-api/pull/5585)
  * refactor：重构 Codex 用量界面，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5595](https\://github.com/QuantumNous/new-api/pull/5595)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-arm64-v1.0.0-rc.13) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-macos-v1.0.0-rc.13) (142.2 MB)
  * [new-api-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13) (125.3 MB)
  * [new-api-v1.0.0-rc.13.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13.exe) (127.0 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.tar.gz)
</Callout>

***

## v1.0.0-rc.12

<Callout type="note" title="正式版本 · 发布于 2026-06-18 20:34:16 (中国时间)">
  重点更新：AdvancedCustom 渠道提供更灵活的自定义路由，渠道批量测试更易操作，模型市场监控提供更清晰的成功率和延迟。

  ### 新增功能

  * 添加 AdvancedCustom 渠道并改善自定义路由匹配（#5590）。
  * 增强模型批量测试，包括完整执行、状态刷新、清晰结果、删除失败模型及复制所选模型（#5532）。
  * 扩展模型市场性能监控，包括可用率、近期成功率、成功率评级和紧凑的延迟/吞吐显示。
  * 持久保存表格偏好，页面大小和列可见性可跨页面、跨会话保留（#5403）。

  ### 问题修复

  * 修复工具调用，使空的 `arguments` 值仍保留预期的 `tool_use` 块（#5543）。
  * 修复 CC Switch 模型选择器，正确显示和更新模型选项（#5515）。
  * 修复列表、表格、用量详情和自定义首页 iframe 的裁切及溢出（#5510、#5536、#5533、#5545）。

  ### 改进

  * 改善支付与充值界面，明确支付方式按钮、图标和最低充值信息。
  * 改善订阅套餐描述、钱包溢出处理和降级分组支持。
  * 优化设置、概览引导、钱包/个人交互及日志统计卡片，提高可读性。

  ### 不兼容变更

  * 订阅产品选项和目录端点现在使用 `GET`，客户端集成可能需要更新请求方法。
  * 从排名筛选中删除“全部”时间范围选项。

  ***

  ### 变更内容

  * fix(web)：防止列表文字和徽标溢出，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5510](https\://github.com/QuantumNous/new-api/pull/5510)
  * fix(keys)：刷新 API Key 表单选项，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5512](https\://github.com/QuantumNous/new-api/pull/5512)
  * fix：修复 CC Switch 模型选择器，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5515](https\://github.com/QuantumNous/new-api/pull/5515)
  * fix(data-table)：memo 比较包含行选择状态，由 @RedwindA 提交于 [https\://github.com/QuantumNous/new-api/pull/5524](https\://github.com/QuantumNous/new-api/pull/5524)
  * fix(channels)：刷新渠道测试对话框状态，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5517](https\://github.com/QuantumNous/new-api/pull/5517)
  * fix：恢复自定义首页 iframe 视口高度，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5545](https\://github.com/QuantumNous/new-api/pull/5545)
  * fix(web)：避免用量详情对话框裁切底部内容，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5533](https\://github.com/QuantumNous/new-api/pull/5533)
  * fix：修复 AWS AK/SK 上下文管理，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5547](https\://github.com/QuantumNous/new-api/pull/5547)
  * test：清理以奖励投机方式通过的后端测试，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5563](https\://github.com/QuantumNous/new-api/pull/5563)
  * fix\: 工具调用 arguments 为空时保留 tool\_use 块，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5543](https\://github.com/QuantumNous/new-api/pull/5543)
  * fix：完整执行渠道模型批量测试，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5532](https\://github.com/QuantumNous/new-api/pull/5532)
  * feat\: 持久化表格每页条数，跨导航/会话记忆 (#5377)，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5403](https\://github.com/QuantumNous/new-api/pull/5403)
  * fix(data-table)：避免组件单元格被裁切，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5536](https\://github.com/QuantumNous/new-api/pull/5536)
  * fix(oauth)：永久删除用户时清理绑定，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5582](https\://github.com/QuantumNous/new-api/pull/5582)
  * feat：高级自定义渠道，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5590](https\://github.com/QuantumNous/new-api/pull/5590)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-arm64-v1.0.0-rc.12) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-macos-v1.0.0-rc.12) (142.1 MB)
  * [new-api-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12) (125.3 MB)
  * [new-api-v1.0.0-rc.12.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12.exe) (127.0 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.tar.gz)
</Callout>

***

## v1.0.0-rc.11

<Callout type="note" title="正式版本 · 发布于 2026-06-13 16:15:40 (中国时间)">
  重点更新：支持 Claude Opus 4.8，改善 OpenAI 图片 API 兼容性、模型价格编辑器和密集数据表格；修复界面、额度显示、转发兼容性及厂商问题。

  ### 新增功能

  * 支持 Claude Opus 4.8（#5177）。
  * 可选择禁用渠道时是否清除渠道亲和性（#5306）。
  * 添加订阅余额兑换开关，提高余额处理灵活性。
  * 个人页显示用户 ID（#5317）。
  * OpenAI 图片 API 支持流式图片转发和图片编辑（#4608）。

  ### 问题修复

  * 提交表单后聚焦第一个校验错误，便于定位和修正（#5163）。
  * 修复 cc-switch 自定义名称失焦后重置（#5170）。
  * 修复价格视图中自定义模型图标不同步（#5224）。
  * 高级渠道校验错误可直接显示，不再错误展开无关设置（#5239）。
  * 修复额度和余额汇率转换，同时更新单位及显示值（#5296）。
  * 修复 Dify 文件请求中的远程图片处理（#5134）。
  * 修复视频生成任务查询的模型解析（#5133）。
  * 改善兼容 Anthropic 的 GLM 转发，避免兼容失败（#5307）。
  * 缩小 OpenAI o 系列适配范围，避免影响不支持的模型（#5293）。
  * 多选弹出框遵循当前主题（#5328）。
  * 修复 Kimi K2.6 温度规范化（#5390）。
  * 支持按状态筛选已删除用户（#5464）。
  * 仅在部署页获取部署设置（#5466）。

  ### 改进

  * 改善管理日志和批量更新性能，使大规模操作更流畅（#5116）。
  * 改善模型价格编辑器布局、草稿保存、JSON 复用及六位小数步长（#5275）。
  * 渠道搜索加入防抖并优化输入法组合输入处理（#5393）。
  * 改善前端表格渲染、固定列、布局及徽标（#5405）。
  * 改善前端对话框尺寸和底部布局（#5346）。
  * 简化公共页主视觉文案，使首页更清晰（#5339）。

  ***

  ### 变更内容

  * fix(web)：改善表单校验错误聚焦，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5163](https\://github.com/QuantumNous/new-api/pull/5163)
  * feat(keys/cc-switch-dialog)\: 修复自定义cc-switch名称失焦后重置问题，由 @GnezIew 提交于 [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * fix(model)：将 idx\_created\_at\_id 索引列顺序修正为 (created\_at, id)，由 @realRoc 提交于 [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * perf：管理日志按 created\_at 排序以利用组合索引，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5116](https\://github.com/QuantumNous/new-api/pull/5116)
  * chore(deps)：将 /web/classic 的 axios 从 1.15.2 升级到 1.16.0，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/5185](https\://github.com/QuantumNous/new-api/pull/5185)
  * feat：支持 claude-opus-4-8，由 @hjxwz123 提交于 [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * fix(pricing)：同步自定义模型图标，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5224](https\://github.com/QuantumNous/new-api/pull/5224)
  * chore(web)：集中管理共享前端依赖版本，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5227](https\://github.com/QuantumNous/new-api/pull/5227)
  * feat(web)：支持经典前端 Rsbuild 开发与构建，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5232](https\://github.com/QuantumNous/new-api/pull/5232)
  * fix(channels)：展示高级校验错误，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5239](https\://github.com/QuantumNous/new-api/pull/5239)
  * docs：改善议题模板，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5271](https\://github.com/QuantumNous/new-api/pull/5271)
  * fix\: 修复余额显示时只切换了单位未切换数值，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/5296](https\://github.com/QuantumNous/new-api/pull/5296)
  * fix(dify)：远程图片字段赋值前初始化文件指针，由 @Pluviobyte 提交于 [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * fix(distributor)：解析 GET /v1/video/generations/\:task\_id 对应模型，由 @Pluviobyte 提交于 [https\://github.com/QuantumNous/new-api/pull/5133](https\://github.com/QuantumNous/new-api/pull/5133)
  * fix：添加转发空闲连接超时配置，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5309](https\://github.com/QuantumNous/new-api/pull/5309)
  * feat\: 支持配置渠道被禁用后是否清空渠道粘性，由 @GuangYiDing 提交于 [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * fix(relay)：修复 GLM Anthropic 兼容模式，避免 chunked 编码，由 @Chen011214 提交于 [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * fix：限制匿名请求体大小，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5244](https\://github.com/QuantumNous/new-api/pull/5244)
  * fix(i18n)：明确思考适配器文案，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5242](https\://github.com/QuantumNous/new-api/pull/5242)
  * fix\: 收窄 OpenAI o 系列模型适配范围，由 @USER-HFC 提交于 [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * fix：渠道处理器复用流扫描缓冲区，由 @xujiantop-crypto 提交于 [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * feat(web)：个人页显示用户 ID，由 @P2K0 提交于 [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * perf(model-pricing)：改善模型价格编辑器体验，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5275](https\://github.com/QuantumNous/new-api/pull/5275)
  * perf(web)：简化公共页主视觉文案，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5339](https\://github.com/QuantumNous/new-api/pull/5339)
  * perf(web)：改善对话框布局和尺寸，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5346](https\://github.com/QuantumNous/new-api/pull/5346)
  * fix：多选组合框弹窗遵循主题，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5328](https\://github.com/QuantumNous/new-api/pull/5328)
  * fix：对齐移动端用量日志费用徽标，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5161](https\://github.com/QuantumNous/new-api/pull/5161)
  * fix：模型价格编辑器支持六位小数步长，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5332](https\://github.com/QuantumNous/new-api/pull/5332)
  * fix(openai)：图片 API 支持流式图片转发与图片编辑，由 @gaoren002 提交于 `#4608`
  * perf(web)：渠道搜索防抖，输入法组合期间跳过搜索，由 @QAbot-zh 提交于 [https\://github.com/QuantumNous/new-api/pull/5393](https\://github.com/QuantumNous/new-api/pull/5393)
  * fix：规范 Kimi K2.6 温度，由 @bensonfx 提交于 [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)
  * perf(web)：改善前端表格渲染及固定列，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5405](https\://github.com/QuantumNous/new-api/pull/5405)
  * perf(data-table)：改善数据表布局和徽标，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/5460](https\://github.com/QuantumNous/new-api/pull/5460)
  * feat(audit)：添加本地化安全审计日志，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/5462](https\://github.com/QuantumNous/new-api/pull/5462)
  * chore：更新 Codex 渠道，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5461](https\://github.com/QuantumNous/new-api/pull/5461)
  * fix：添加已删除用户状态筛选，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5464](https\://github.com/QuantumNous/new-api/pull/5464)
  * fix：仅在部署页获取部署设置，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5466](https\://github.com/QuantumNous/new-api/pull/5466)

  ### 新贡献者

  * @GnezIew 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * @realRoc 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * @hjxwz123 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * @Pluviobyte 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * @GuangYiDing 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * @Chen011214 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * @USER-HFC 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * @xujiantop-crypto 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * @P2K0 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * @bensonfx 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-arm64-v1.0.0-rc.11) (84.8 MB)
  * [new-api-macos-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-macos-v1.0.0-rc.11) (103.8 MB)
  * [new-api-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11) (87.2 MB)
  * [new-api-v1.0.0-rc.11.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11.exe) (88.9 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.tar.gz)
</Callout>

***

## v1.0.0-rc.10

<Callout type="note" title="正式版本 · 发布于 2026-05-26 22:20:13 (中国时间)">
  ### 重点更新

  v1.0.0-rc.10 重点改善界面、转发可靠性和管理流程。新增主题选项与余额购买订阅，并优化日志、渠道行为、Webhook、支付和上游工具调用处理。

  ### 新增功能

  * 主题自定义新增 Anthropic 和 Simple Large 预设，可配置衬线字体及超大缩放。
  * 订阅计费支持余额购买。

  ### 问题修复

  * 自动禁用的渠道不再用于新请求，渠道操作不再重复通知（#4983）。
  * 改善 Gemini 与 Claude 之间工具转发，包括并发工具调用（#5095）。
  * 图片转发正确应用请求的质量设置（#5103）。
  * 用量筛选默认精确匹配，仅显式使用通配符时模糊匹配；超大上游错误会截短以保持日志可读（#5097）。
  * 提高 webhook 处理可靠性（#5047）。
  * 统一 Waffo 支付配置保存，隐藏旧版选项（#5110）。
  * 系统设置正确识别未保存修改，并避免数值输入产生无效值。

  ### 改进

  * 大型媒体转发降低内存消耗，提高负载下稳定性。
  * 系统设置、渠道创建和编辑页更清晰紧凑，控件更完善。
  * 改善用量日志和默认网页的移动体验，包括表格间距、徽标、图表及深色可读性。
  * 首页主视觉采用更清晰的双栏布局并更新文案。

  ***

  ### 变更内容

  * 🐛 fix(channel)：从缓存移除自动禁用的多密钥渠道，由 @t0ng7u 提交于 [https\://github.com/QuantumNous/new-api/pull/4983](https\://github.com/QuantumNous/new-api/pull/4983)
  * \[修复] 修复 webhook 处理流程，由 @Hill-waffo 提交于 [https\://github.com/QuantumNous/new-api/pull/5047](https\://github.com/QuantumNous/new-api/pull/5047)
  * fix(payment)：隐藏旧版 Waffo Pancake 设置，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5085](https\://github.com/QuantumNous/new-api/pull/5085)
  * fix(relay)：修正图片质量参数处理，由 @lanfunoe 提交于 [https\://github.com/QuantumNous/new-api/pull/5103](https\://github.com/QuantumNous/new-api/pull/5103)
  * fix：截短超大上游错误日志，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5083](https\://github.com/QuantumNous/new-api/pull/5083)
  * fix\: 移除 fcIdx -1 偏移，修复并发工具调用撞键问题，由 @learner-i 提交于 [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)
  * fix：修复 Gemini 转 Claude tool\_use 错误，由 @nekohy 提交于 [https\://github.com/QuantumNous/new-api/pull/5041](https\://github.com/QuantumNous/new-api/pull/5041)
  * fix：处理 API Key 搜索分页响应，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5014](https\://github.com/QuantumNous/new-api/pull/5014)
  * fix：避免渠道操作重复提示，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5015](https\://github.com/QuantumNous/new-api/pull/5015)
  * fix：整合 Waffo 支付配置保存流程，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5110](https\://github.com/QuantumNous/new-api/pull/5110)
  * fix：渠道测试使用真实用户 ID，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5109](https\://github.com/QuantumNous/new-api/pull/5109)
  * fix：日志筛选默认精确匹配，除非显式使用通配符，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5097](https\://github.com/QuantumNous/new-api/pull/5097)

  ### 新贡献者

  * @learner-i 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-linux.txt) (180 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-arm64-v1.0.0-rc.10) (82.8 MB)
  * [new-api-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10) (85.3 MB)
  * [new-api-v1.0.0-rc.10.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10.exe) (86.9 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.tar.gz)
</Callout>

***

## v1.0.0-rc.8

<Callout type="note" title="正式版本 · 发布于 2026-05-22 16:25:46 (中国时间)">
  #### 重点更新

  添加 Waffo Pancake 网关及管理端目录/商品绑定；完善管理端和 API、模型元数据和价格一致性、渠道测试诊断、报告筛选及请求效率。

  #### 新增功能

  * 支持 Waffo Pancake 网关及管理端目录/商品绑定（#4935）。

  #### 问题修复

  * 仪表盘内容遵循可见性设置（#4975）。
  * 性能指标汇总仅包含活动分组（#4976）。
  * 规范模型价格显示，避免数值不一致（#4985）。
  * 从活动渠道解析模型归属元数据，提高列表准确性（#4416）。
  * 默认前端链接指向正确路由（#5016）。
  * 恢复原用量日志筛选行为，避免此前修改的回归。

  #### 改进

  * 渠道测试失败时提供更清晰的详情（#4988）。
  * 减少请求处理开销，改善负载下性能（#5009）。

  ***

  ### 变更内容

  * fix：为敏感消息字段展示参数覆盖审计，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4974](https\://github.com/QuantumNous/new-api/pull/4974)
  * fix：遵循仪表盘内容可见性设置，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4975](https\://github.com/QuantumNous/new-api/pull/4975)
  * fix：按活动分组筛选性能汇总，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4976](https\://github.com/QuantumNous/new-api/pull/4976)
  * fix：改善渠道测试失败详情体验，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4988](https\://github.com/QuantumNous/new-api/pull/4988)
  * fix：规范模型价格显示偏差，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4985](https\://github.com/QuantumNous/new-api/pull/4985)
  * fix：从活动渠道解析模型 owned\_by，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4416](https\://github.com/QuantumNous/new-api/pull/4416)
  * perf：优化请求元数据提取和禁用字段过滤，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5009](https\://github.com/QuantumNous/new-api/pull/5009)
  * fix：更新默认前端硬编码路由链接，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/5016](https\://github.com/QuantumNous/new-api/pull/5016)
  * 修复 切换新版前端Turnstile 开启后注册页未显示验证的问题，由 @JunXiaoRuo 提交于 [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * \[功能请求] Waffo Pancake 网关完整集成：支持订阅及管理端目录绑定，由 @Hill-waffo 提交于 [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)
  * fix：落实 Waffo 订阅合规及商品 ID 更新，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/5038](https\://github.com/QuantumNous/new-api/pull/5038)

  ### 新贡献者

  * @JunXiaoRuo 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * @Hill-waffo 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-arm64-v1.0.0-rc.8) (82.4 MB)
  * [new-api-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8) (84.8 MB)
  * [new-api-v1.0.0-rc.8.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8.exe) (86.5 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.tar.gz)
</Callout>

***

## v1.0.0-rc.7

<Callout type="note" title="正式版本 · 发布于 2026-05-19 16:54:08 (中国时间)">
  #### 新增功能

  * 支持 `request_header` 密钥来源（#4903）。

  #### 问题修复

  * 批量修复默认界面问题（#4880、#4893、#4817、#4877、#4898、#4876）。
  * 修复渠道备注无法清空（#4886）。
  * 修复用量日志筛选（#4883）。
  * 修复网页 API Key 无限额度校验（#4881）。
  * 公共模块页头导航应用访问控制（#4889）。
  * 渠道列表查询正确应用分组筛选（#4847、#4885）。
  * 修复 `PerfMetric` upsert 中的列名歧义（#4684）。
  * 默认主题添加缺失的分析统计占位符（#4928）。
  * 为忘记密码表单按钮设置正确类型，修复提交（#4910）。
  * 规范模型详情标签布局（#4938）。
  * 修复管理面板用户创建和删除（#4818）。
  * 登录页注册链接遵循注册设置（#4871）。
  * 更新 ModelCardGrid 分页按钮说明（#4675）。
  * 本地化重置密码确认消息（#4769）。
  * 深色模式下可见充值预设选中状态（#4897）。
  * 修复语义颜色变量不匹配导致 API 信息色点颜色错误（#4824）。
  * 修复 API 信息保存时无效颜色造成的静默失败（#4823）。
  * 注册载荷使用正确的 `aff_code` 字段（#4965）。
  * 数据表分面筛选弹窗宽度自适应（#4966）。
  * 修复密钥提交时过期表单关联（#4967）。

  #### 改进

  * 避免调试日志提前格式化，提高性能（#4929）。

  ***

  ### 变更内容

  * fix：允许清空渠道备注，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4886](https\://github.com/QuantumNous/new-api/pull/4886)
  * fix：修正用量日志筛选，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4883](https\://github.com/QuantumNous/new-api/pull/4883)
  * fix(web)：处理 API Key 无限额度校验，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4881](https\://github.com/QuantumNous/new-api/pull/4881)
  * fix：公共模块页头导航应用访问控制，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4889](https\://github.com/QuantumNous/new-api/pull/4889)
  * fix：修复 GetAllChannels 忽略分组筛选参数，由 @draftgo 提交于 [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * fix：限定 PerfMetric upsert 列名，避免 PostgreSQL 歧义，由 @SAY-5 提交于 [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * fix：渠道列表查询应用分组筛选，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4885](https\://github.com/QuantumNous/new-api/pull/4885)
  * feat：支持 request\_header 密钥来源，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4903](https\://github.com/QuantumNous/new-api/pull/4903)
  * fix\: 修复新 UI 语言与文案显示问题，由 @QuentinHsu 提交于 [https\://github.com/QuantumNous/new-api/pull/4876](https\://github.com/QuantumNous/new-api/pull/4876)
  * fix：默认主题 index.html 添加 umami 和 ga4 占位符，由 @NitroRCr 提交于 [https\://github.com/QuantumNous/new-api/pull/4928](https\://github.com/QuantumNous/new-api/pull/4928)
  * perf：避免调试日志提前格式化，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4929](https\://github.com/QuantumNous/new-api/pull/4929)
  * fix：忘记密码按钮添加 type="submit"，由 @lihan3238 提交于 [https\://github.com/QuantumNous/new-api/pull/4910](https\://github.com/QuantumNous/new-api/pull/4910)
  * fix(web)：规范模型详情标签布局，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4938](https\://github.com/QuantumNous/new-api/pull/4938)
  * fix(user)：修复管理面板用户创建和删除，由 @bugmaker2 提交于 [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * fix(auth)：/api/status 暴露 register\_enabled，并控制登录页注册链接，由 @Gnonymous 提交于 [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * fix(web/default)：明确 ModelCardGrid 分页按钮说明，由 @ellisfan 提交于 [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * fix(auth)：本地化重置密码确认消息，由 @neow021 提交于 [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * fix(web/default/wallet)：深色模式显示充值预设选中状态，由 @xinnyu 提交于 [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)
  * fix(web/default)：修复语义变量不匹配引起 API 信息色点错误，由 @Micah-Zheng 提交于 [https\://github.com/QuantumNous/new-api/pull/4824](https\://github.com/QuantumNous/new-api/pull/4824)
  * fix(web/default)：修复无效颜色或未检查结果时 API 信息静默保存失败，由 @Micah-Zheng 提交于 [https\://github.com/QuantumNous/new-api/pull/4823](https\://github.com/QuantumNous/new-api/pull/4823)
  * fix(auth)：注册载荷使用 aff\_code 字段（#4945），由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/4965](https\://github.com/QuantumNous/new-api/pull/4965)
  * fix(data-table)：分面筛选弹窗宽度自适应（#4905），由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/4966](https\://github.com/QuantumNous/new-api/pull/4966)
  * fix(keys)：直接调用提交处理器，避免过期表单关联（#4858），由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/4967](https\://github.com/QuantumNous/new-api/pull/4967)

  ### 新贡献者

  * @draftgo 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * @SAY-5 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * @bugmaker2 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * @Gnonymous 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * @ellisfan 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * @neow021 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * @xinnyu 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-arm64-v1.0.0-rc.7) (82.3 MB)
  * [new-api-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7) (84.6 MB)
  * [new-api-v1.0.0-rc.7.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7.exe) (86.3 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.tar.gz)
</Callout>

***

## v1.0.0-rc.6

<Callout type="note" title="正式版本 · 发布于 2026-05-13 22:29:13 (中国时间)">
  ### 重点更新

  通过在日志中记录上游请求 ID 改善可观测性，并在付费功能前添加合规确认。如果 `logs` 表较大，请在升级前以在线 DDL 预先添加 `upstream_request_id` 列及索引，避免迁移耗时过长。

  ### 新增功能

  * 日志支持跟踪上游请求 ID，便于追踪调用，且避免意外覆盖响应头。
  * 使用付费功能前添加合规确认步骤。

  ### 问题修复

  * 修复渠道组合选择框聚焦后隐藏有效选项（#4829）。

  ### 其他

  * 升级提示：`logs` 表新增 `upstream_request_id` 列及索引；大规模部署应在升级前执行下方对应的在线 DDL，避免自动迁移长时间阻塞。

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

  ### 变更内容

  * chore(deps)：将 /web/classic 的 axios 从 1.15.0 升级到 1.15.2，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/4634](https\://github.com/QuantumNous/new-api/pull/4634)
  * chore(deps-dev)：将 /electron 的 ip-address 从 10.1.0 升级到 10.2.0，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/4811](https\://github.com/QuantumNous/new-api/pull/4811)
  * 修复渠道列表显示不全问题，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/4829](https\://github.com/QuantumNous/new-api/pull/4829)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-arm64-v1.0.0-rc.6) (82.3 MB)
  * [new-api-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6) (84.6 MB)
  * [new-api-v1.0.0-rc.6.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6.exe) (86.3 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.tar.gz)
</Callout>

***

## v1.0.0-rc.5

<Callout type="note" title="正式版本 · 发布于 2026-05-12 16:53:57 (中国时间)">
  ### 重点更新

  默认仪表盘更新，集成模型性能指标及清晰的健康视图；支持 DeepChat 深度链接，修复默认界面、钱包、Playground 和倍率显示回归。

  ### 新增功能

  * 重新设计仪表盘概览，集成模型性能指标及更清晰的健康面板。
  * 支持 DeepChat 深度链接，可直接打开兼容的聊天链接（#4668）。

  ### 问题修复

  * 充值网关可用性读取正确充值配置，准确展示支付选项（#4599）。
  * 分组倍率显示遵循分组间倍率设置（#4772）。
  * 默认界面下拉菜单可靠触发选择处理器（#4787）。
  * Playground 可正常处理旧版经典格式消息（#4650）。
  * 修复默认界面多项 v1 回归，包括空描述区域及布局问题（#4802）。

  ### 改进

  * 默认网页及图表采用共享主题预设，统一颜色、控件及圆角。
  * Docker 镜像包含项目和第三方许可证说明，便于合规审查（#4739）。

  ***

  ### 变更内容

  * feat：支持 DeepChat 深度链接，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4668](https\://github.com/QuantumNous/new-api/pull/4668)
  * fix：Docker 构建时不再通过 .dockerignore 排除 THIRD-PARTY-LICENSES.md，由 @yeying-xingchen 提交于 [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * fix(wallet)：从 topupInfo 而非 status 读取充值网关标志，由 @ImogeneOctaviap794 提交于 [https\://github.com/QuantumNous/new-api/pull/4599](https\://github.com/QuantumNous/new-api/pull/4599)
  * fix(web/default)：通过 getUserGroups 显示倍率并遵循 GroupGroupRatio，由 @Micah-Zheng 提交于 [https\://github.com/QuantumNous/new-api/pull/4772](https\://github.com/QuantumNous/new-api/pull/4772)
  * fix(default)：支持 DropdownMenuItem onSelect，由 @lihan3238 提交于 [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)
  * fix(web/default)：兼容 Playground 旧版经典消息结构，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/4650](https\://github.com/QuantumNous/new-api/pull/4650)
  * fix：修复默认界面问题，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/4802](https\://github.com/QuantumNous/new-api/pull/4802)

  ### 新贡献者

  * @yeying-xingchen 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * @lihan3238 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-arm64-v1.0.0-rc.5) (82.1 MB)
  * [new-api-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5) (84.5 MB)
  * [new-api-v1.0.0-rc.5.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5.exe) (86.2 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.tar.gz)
</Callout>

***

## v1.0.0-rc.4

<Callout type="note" title="正式版本 · 发布于 2026-05-06 22:25:59 (中国时间)">
  ### 重点更新

  OpenAI 图像编辑更可靠：请求保留参考图和相关元数据，避免丢失编辑上下文（#4646）；添加模型性能徽标，修复计费及下拉界面问题。

  ### 新增功能

  * 模型列表添加性能徽标，便于快速比较可用模型。

  ### 问题修复

  * OpenAI 图像编辑转发保留参考图及相关元数据（#4646）。
  * 修复计费设置表单，使充值及计费配置输入更可靠。
  * 修复界面组件更新后下拉及选择控件的显示和选中（#4655）。

  ### 不兼容变更

  * 集成现在应从充值信息 API 而非状态 API 读取充值链接。

  ### 界面展示

  | 模型可用性排名                                                                                               | 更新后的价格和设置界面                                                                                           |
  | ----------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
  | ![Gallery 发布说明中的配图](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Gallery 发布说明中的配图](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### 变更内容

  * fix：保留 OpenAI 图像编辑参考字段，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4646](https\://github.com/QuantumNous/new-api/pull/4646)
  * fix：选择控件迁移到 Base UI items API，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4655](https\://github.com/QuantumNous/new-api/pull/4655)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-arm64-v1.0.0-rc.4) (82.0 MB)
  * [new-api-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4) (84.4 MB)
  * [new-api-v1.0.0-rc.4.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4.exe) (86.1 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.tar.gz)
</Callout>

***

## v1.0.0-rc.3

<Callout type="note" title="正式版本 · 发布于 2026-05-06 18:43:33 (中国时间)">
  ### 重点更新

  v1.0.0-rc.3 添加模型排名，展示可用性和性能，便于在选择路由或供应商前比较可靠性。同时更新默认界面的价格、设置页和表格控件。

  ### 新增功能

  * 添加模型排名仪表盘，展示真实可用性和性能数据以比较可靠性（#4633）。

  ### 改进

  * 默认界面更新为 Base UI 组件及新主题预设，改善表格工具栏交互（#4633）。
  * 重新组织系统价格设置，便于浏览和管理。

  ### 问题修复

  * 修复渠道表格的服务端排序（#4600）。
  * 修复默认界面的订阅支付信息显示。

  ### 界面展示

  | 模型可用性排名                                                                                               | 更新后的价格和设置界面                                                                                           |
  | ----------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
  | ![Gallery 发布说明中的配图](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Gallery 发布说明中的配图](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### 变更内容

  * feat(web/default)：统一界面重构，迁移 Base UI、主题、排名面板和表格工具栏，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/4633](https\://github.com/QuantumNous/new-api/pull/4633)
  * feat：采集模型性能指标，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/4635](https\://github.com/QuantumNous/new-api/pull/4635)
  * fix：启用渠道表格服务端排序，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4600](https\://github.com/QuantumNous/new-api/pull/4600)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-arm64-v1.0.0-rc.3) (81.9 MB)
  * [new-api-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3) (84.4 MB)
  * [new-api-v1.0.0-rc.3.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3.exe) (86.1 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.tar.gz)
</Callout>

***

## v1.0.0-rc.2

<Callout type="note" title="正式版本 · 发布于 2026-04-30 20:42:48 (中国时间)">
  ### 重点更新

  v1.0.0-rc.2 正式开放新版与经典前端切换，便于测试新界面、比较工作流程，并在需要时快速切回。该候选版本还更新控制台核心页面，修复邮箱绑定、阶梯价格、API Key 分组和自定义 Vertex 基础地址问题。

  ### 新增功能

  * 内置新旧前端切换，使团队可逐步采用新界面并保留原有工作流。

  ### 改进

  * 更新控制台价格页、仪表盘和日志控件，改善表格分析筛选、导航及移动端适配。

  ### 问题修复

  * 修复新版前端邮箱绑定（#4551）。
  * 修复阶梯价格数字输入，提高编辑可靠性（#4536）。
  * 修复阶梯价格数值和标签显示异常（#4530）。
  * 修复默认主题 API Key 分组，使密钥显示于正确分组（#4548）。
  * 修复 Vertex 自定义基址在配置网关前缀时的路由（#4200）。

  ### 界面展示

  | 更新后的价格页面                                                                                      | 仪表盘和分析控件                                                                                      |
  | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
  | ![更新后的价格页面](https\://github.com/user-attachments/assets/8d403155-27ac-407d-b0ae-8815034c66a7) | ![仪表盘和分析控件](https\://github.com/user-attachments/assets/caa73f0a-13d2-47fc-ab7d-0ffb4e7b6194) |

  ### 变更内容

  * fix\: 修复默认主题 API 密钥分组行为，由 @Micah-Zheng 提交于 [https\://github.com/QuantumNous/new-api/pull/4548](https\://github.com/QuantumNous/new-api/pull/4548)
  * bug fix\: 新版前端email绑定错误，由 @SHLE1 提交于 [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)
  * fix：改善阶梯价格数值编辑，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4536](https\://github.com/QuantumNous/new-api/pull/4536)
  * fix(vertex)：将自定义 base\_url 作为网关前缀，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4200](https\://github.com/QuantumNous/new-api/pull/4200)
  * fix(web)\: 修复阶梯计费 Base64 解码失败与标签不匹配导致的显示错误，由 @wans10 提交于 [https\://github.com/QuantumNous/new-api/pull/4530](https\://github.com/QuantumNous/new-api/pull/4530)

  ### 新贡献者

  * @SHLE1 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-arm64-v1.0.0-rc.2) (76.5 MB)
  * [new-api-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2) (78.9 MB)
  * [new-api-v1.0.0-rc.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2.exe) (80.6 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.tar.gz)
</Callout>

***

## v1.0.0-rc.1

<Callout type="note" title="正式版本 · 发布于 2026-04-29 20:15:01 (中国时间)">
  v1.0.0-rc.1 是 1.0 的首个候选版本，重点是从头重建 v1 前端，提供更清晰、更快速、更完善的管理体验。

  此候选版更新导航、配置、分析和日志，在迈向 v1 正式版时简化日常管理。

  ![v1.0.0-rc.1 发布说明中的配图](https\://github.com/user-attachments/assets/f3f8ed32-e0c5-4cfb-94a3-da0f357b62ab)

  ### 新增功能

  * 推出重建的 v1 前端，包含现代导航布局、可视化参数覆盖编辑器，以及更易访问的系统设置和主题切换（#4265）。

  ### 改进

  * 升级仪表盘和图表，提供更清晰的模型分析、数据排序及提示。
  * 完善用量日志类型标志、用户名、头像和表格，提高浏览效率。
  * 统一默认前端共享布局、表格和表单样式。

  ### 问题修复

  * 从数据库加载的主题可正确应用到运行时（#4518）。
  * 转发请求保留空思考字段，不再静默丢弃（#4520）。
  * 修复必填字段标记，明确展示必须填写的输入（#4533）。

  ***

  ### 变更内容

  * 🚀 feat：发布 v1.0，从头构建下一代前端，由 @t0ng7u 提交于 [https\://github.com/QuantumNous/new-api/pull/4265](https\://github.com/QuantumNous/new-api/pull/4265)
  * fix\: 修复 Message.ReasoningContent/Reasoning 空思考内容在请求转发时被静默丢弃，由 @heimoshuiyu 提交于 [https\://github.com/QuantumNous/new-api/pull/4520](https\://github.com/QuantumNous/new-api/pull/4520)
  * fix：数据库加载主题后同步到运行时，由 @Micah-Zheng 提交于 [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  ### 新贡献者

  * @Micah-Zheng 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-arm64-v1.0.0-rc.1) (76.4 MB)
  * [new-api-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1) (78.8 MB)
  * [new-api-v1.0.0-rc.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1.exe) (80.5 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.tar.gz)
</Callout>

***

## v1.0.0-alpha.1 — 许可证边界版本

<Callout type="note" title="预发布版本 · 发布于 2026-04-28 14:26:06 (中国时间)">
  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1](https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1)

  **下载资源**

  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.tar.gz)
</Callout>

***

## v0.13.2

<Callout type="note" title="正式版本 · 发布于 2026-04-27 22:11:42 (中国时间)">
  ### 新增功能

  * 模型同步更准确地发现上游，自动从价格端点刷新价格，显示已移除上游模型，并在同步延迟时保持价格可用（#4452）。
  * 用户记录包含账户创建和最后登录时间，便于审计管理（#4450）。
  * 阿里原生 Messages API 支持可配置模型匹配，便于路由到兼容上游（#4468）。

  ### 问题修复

  * 工具调用接受原始 JSON 参数，提高与返回 JSON 对象供应商的兼容性（#4469）。
  * 配置更新更可靠地处理 JSON 对象字段，避免错误保存。

  ### 改进

  * 重试信息明确说明因亲和性禁用而跳过渠道（#4453）。

  ***

  ### 变更内容

  * fix(channel)：检查上游模型时加载模型映射，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4437](https\://github.com/QuantumNous/new-api/pull/4437)
  * feat：从价格端点同步上游价格，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4452](https\://github.com/QuantumNous/new-api/pull/4452)
  * fix：明确亲和性禁用时的重试信息，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4453](https\://github.com/QuantumNous/new-api/pull/4453)
  * feat：阿里原生 Messages 支持模型匹配配置，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4468](https\://github.com/QuantumNous/new-api/pull/4468)
  * fix：支持原始 JSON 响应工具参数，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4469](https\://github.com/QuantumNous/new-api/pull/4469)
  * feat：获取模型弹窗显示已移除上游模型，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4470](https\://github.com/QuantumNous/new-api/pull/4470)
  * 增加用户创建时间和最后登录时间，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/4450](https\://github.com/QuantumNous/new-api/pull/4450)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2](https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.0.13.2.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.Setup.0.13.2.exe) (106.8 MB)
  * [new-api-arm64-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-arm64-v0.13.2) (64.6 MB)
  * [new-api-macos-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-macos-v0.13.2) (83.2 MB)
  * [new-api-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2) (67.0 MB)
  * [new-api-v0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2.exe) (68.6 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.tar.gz)
</Callout>

***

## v0.13.1-patch.1

<Callout type="note" title="正式版本 · 发布于 2026-04-25 13:27:23 (中国时间)">
  ### 重点更新

  此补丁支持在阶梯条件和 LLM 提示词助手中使用 `len`，便于按提示词长度定义规则。

  ### 新增功能

  * 为阶梯条件和 LLM 提示词助手添加 `len` 变量，以按提示词长度定义规则。

  ***

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-linux.txt) (186 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-macos.txt) (96 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-windows.txt) (94 B)
  * [new-api-arm64-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-arm64-v0.13.1-patch.1) (64.6 MB)
  * [new-api-macos-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-macos-v0.13.1-patch.1) (83.2 MB)
  * [new-api-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1) (66.9 MB)
  * [new-api-v0.13.1-patch.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1.exe) (68.6 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.tar.gz)
</Callout>

***

## v0.13.1

<Callout type="note" title="正式版本 · 发布于 2026-04-24 22:20:58 (中国时间)">
  #### 新增功能

  * 支持处理 DeepSeek V4 思考后缀（#4428）

  #### 问题修复

  * 修复阶梯计费模型未包含在模型列表中（#4431）

  ***

  ### 变更内容

  * fix：模型列表包含阶梯计费模型，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4431](https\://github.com/QuantumNous/new-api/pull/4431)
  * feat：实现并测试 DeepSeek V4 思考后缀，由 @HynoR 提交于 [https\://github.com/QuantumNous/new-api/pull/4428](https\://github.com/QuantumNous/new-api/pull/4428)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1](https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.0.13.1.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.Setup.0.13.1.exe) (106.7 MB)
  * [new-api-arm64-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-arm64-v0.13.1) (64.6 MB)
  * [new-api-macos-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-macos-v0.13.1) (83.2 MB)
  * [new-api-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1) (66.9 MB)
  * [new-api-v0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1.exe) (68.6 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.tar.gz)
</Callout>

***

## v0.13.0

<Callout type="note" title="正式版本 · 发布于 2026-04-24 14:09:21 (中国时间)">
  ### 重点更新

  此版本支持基于 `expr` 表达式的阶梯计费，管理员可配置复杂动态规则。例如 `tokens <= 128000 ? 0.002 : 0.004`，系统会在用量低于 128K Token 时使用较低价格，超过后使用较高价格。

  ### 新增功能

  * 计费系统支持求值 `expr` 表达式，提供可配置预设的动态阶梯价格（#4409）。
  * 添加工具价格设置界面，改善工具调用额度计算。
  * 管理员充值账单显示用户 ID，便于追踪（#4349）。
  * 令牌表添加最后使用时间列（#4372）。
  * 放宽密钥列长度限制，以迁移更长的旧版令牌（#4401）。

  ### 问题修复

  * 确保计价逻辑仅对图像模型应用 N 倍率（#4412）。
  * 阶梯计费结算正确保留文本工具附加费（#4162）。
  * 修正 `gpt-5.5` 模型的补全倍率（#4414）。
  * 修复模型价格界面使用的显示类型（#4426）。
  * 修复阶梯编辑器和结算逻辑中的运行时崩溃及边界问题。
  * 更新渠道测试，正确支持和评估阶梯计费模型。

  ### 改进

  * 添加豆包 Seed 1.8 预设价格阶梯，改善折扣计算。
  * 将 Card 组件替换为 div，以提高整体布局一致性。
  * 内部计费计算使用每单位额度，提高精度。

  ***

  ### 变更内容

  * fix(channel-test)：支持阶梯计费模型测试，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4145](https\://github.com/QuantumNous/new-api/pull/4145)
  * 在管理员充值账单中显示用户 ID，由 @uskyu 提交于 [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * 增加令牌最后使用时间，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/4372](https\://github.com/QuantumNous/new-api/pull/4372)
  * chore(deps)：将 github.com/jackc/pgx/v5 从 5.9.0 升级到 5.9.2，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/4397](https\://github.com/QuantumNous/new-api/pull/4397)
  * chore(deps-dev)：将 /electron 的 @xmldom/xmldom 从 0.8.12 升级到 0.8.13，由 @dependabot\[bot] 提交于 [https\://github.com/QuantumNous/new-api/pull/4399](https\://github.com/QuantumNous/new-api/pull/4399)
  * 放宽密钥列长度，兼容旧版迁移，由 @XiaoAI1024 提交于 [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * fix(billing)：阶梯结算保留文本工具附加费，由 @yyhhyyyyyy 提交于 [https\://github.com/QuantumNous/new-api/pull/4162](https\://github.com/QuantumNous/new-api/pull/4162)
  * feat：计费系统支持阶梯价格表达式，由 @Calcium-Ion 提交于 [https\://github.com/QuantumNous/new-api/pull/4409](https\://github.com/QuantumNous/new-api/pull/4409)
  * fix(image)：仅对图像模型使用 N 倍率，由 @xyfacai 提交于 [https\://github.com/QuantumNous/new-api/pull/4412](https\://github.com/QuantumNous/new-api/pull/4412)
  * fix：修正 gpt-5.5 补全倍率，由 @jingx8885 提交于 [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)
  * fix：模型价格使用正确显示类型，由 @feitianbubu 提交于 [https\://github.com/QuantumNous/new-api/pull/4426](https\://github.com/QuantumNous/new-api/pull/4426)

  ### 新贡献者

  * @uskyu 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * @XiaoAI1024 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * @jingx8885 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0](https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.0.13.0.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.Setup.0.13.0.exe) (106.8 MB)
  * [new-api-arm64-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-arm64-v0.13.0) (64.6 MB)
  * [new-api-macos-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-macos-v0.13.0) (83.2 MB)
  * [new-api-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0) (66.9 MB)
  * [new-api-v0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0.exe) (68.6 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.tar.gz)
</Callout>

***

## v0.12.15

<Callout type="note" title="正式版本 · 发布于 2026-04-22 23:04:03 (中国时间)">
  #### 新增功能

  * 支持 Waffo Pay 账户充值和支付流程（#4089）。

  #### 问题修复

  * 修复充值卡界面部分组件失效（#4388）。

  #### 改进

  * 支持 Gemini 的 `IncludeServerSideToolInvocations` 设置，位于 `ToolConfig`，提高新版 Gemini 工具调用兼容性（#4311）。
  * 通过刷新自动禁用渠道凭据、自动流式测试及优化用量弹窗，改善 Codex 渠道可靠性和易用性（#4324）。

  ***

  ### 变更内容

  * fix(gemini)：ToolConfig 添加 IncludeServerSideToolInvocations 字段，由 @KoellM 提交于 [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * refactor：支付流程，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4089](https\://github.com/QuantumNous/new-api/pull/4089)
  * fix(topup)：导入充值卡缺失的 Tag，由 @gaoren002 提交于 `#4388`
  * chore：优化 Codex 用量弹窗布局，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4386](https\://github.com/QuantumNous/new-api/pull/4386)
  * fix：Codex 自动测试使用流式，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4325](https\://github.com/QuantumNous/new-api/pull/4325)
  * fix：刷新自动禁用渠道的 Codex 凭据，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4324](https\://github.com/QuantumNous/new-api/pull/4324)
  * fix：修改 passkey 时要求正确验证，由 @seefs001 提交于 [https\://github.com/QuantumNous/new-api/pull/4393](https\://github.com/QuantumNous/new-api/pull/4393)

  ### 新贡献者

  * @KoellM 首次贡献于 [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * @gaoren002 首次贡献于 `#4388`

  **完整变更记录**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15](https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15)

  **下载资源**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-linux.txt) (172 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-macos.txt) (89 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-windows.txt) (87 B)
  * [New-API-App.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.0.12.15.exe) (106.3 MB)
  * [New-API-App.Setup.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.Setup.0.12.15.exe) (106.6 MB)
  * [new-api-arm64-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-arm64-v0.12.15) (63.7 MB)
  * [new-api-macos-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-macos-v0.12.15) (82.0 MB)
  * [new-api-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15) (66.0 MB)
  * [new-api-v0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15.exe) (67.7 MB)
  * [源代码（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.zip)
  * [源代码（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.tar.gz)
</Callout>

***