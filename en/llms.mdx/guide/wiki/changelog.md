# Changelog

<Callout type="warn" title="Release Information · Data Updated 2026-8-12 18:48:26">
  For the complete release history, visit [GitHub Releases](https\://github.com/QuantumNous/new-api/releases). This page is not live data; the last sync time appears in this notice title. When upstream publishes faster than this page, upstream is authoritative.
</Callout>

## v1.0.0-rc.24

<Callout type="info" title="Latest record on this page · Published 2026-08-07 17:47:48 (China Time)">
  ### Release\: v1.0.0-rc.24

  #### New Features

  * Added user critical rate limiting middleware for access token and affiliate transfer routes to enhance security and stability.
  * Refined the categorization of fetched models in channels to improve organization and retrieval.

  #### Bug Fixes

  * Resolved an issue with redemption code quotas experiencing precision loss, ensuring accurate credit allocation (#6685).
  * Addressed an HTTP/2 transport issue where upstream stream resets could prevent transparent retries by correctly setting `Request.GetBody` in the relay (#6249).
  * Ensured Claude and Gemini endpoints are tested with the native request format for improved compatibility.

  #### Other

  * Enhanced the release synchronization workflow with optional file syncing capabilities in CI.

  ***

  ### What's Changed

  * fix(relay)\: set Request.GetBody so the HTTP/2 transport can transparently retry after an upstream stream reset by @BlockchainHe in [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * feat(channels)\: refine fetched model categorization by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6632](https\://github.com/QuantumNous/new-api/pull/6632)
  * fix\: test Claude/Gemini endpoints with native request format by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6698](https\://github.com/QuantumNous/new-api/pull/6698)
  * fix\: Fix precision loss in redemption code credit amounts (#6680) by @lihu-001 in [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  ### New Contributors

  * @BlockchainHe made their first contribution in [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * @lihu-001 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-arm64-v1.0.0-rc.24) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-macos-v1.0.0-rc.24) (132.6 MB)
  * [new-api-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24) (113.2 MB)
  * [new-api-v1.0.0-rc.24.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24.exe) (115.1 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.tar.gz)
</Callout>

***

## v1.0.0-rc.23

<Callout type="note" title="Stable Release · Published 2026-08-01 23:25:04 (China Time)">
  Highlights\: This release expands provider and channel compatibility with New API channels, DeepSeek Responses API support, zstd request decompression, and automatic group routing. It also improves operational accuracy with stream visibility in logs, more reliable tiered-retry billing, and upstream Bedrock cancellation when clients disconnect.

  ### New Features

  * Added New API channel support with Gemini-to-OpenAI streaming conversion, Advanced Custom Responses Compact handling, and multipart image edit support (#6559).
  * Added DeepSeek Responses API support (#6562).
  * Added automatic group selection for request routing (#6590).
  * Added per-channel HTTP transport controls so administrators can tune connection behavior per channel.
  * Added support for zstd-compressed requests (#6545).
  * Log owners can now see whether a request was streamed (#6558).

  ### Bug Fixes

  * Qwen `thinking_budget` is now preserved when requests are relayed (#5836).
  * Tiered retry billing now settles usage against the final selected group, including group-switch retries (#6570).
  * Bedrock requests are now cancelled when clients disconnect, reducing wasted upstream work (#6589).

  ### Improvements

  * Public header navigation links now use a consistent font size (#6557).

  ***

  ### What's Changed

  * refactor\: extract protocol conversion layer into standalone relaykit module by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/6369](https\://github.com/QuantumNous/new-api/pull/6369)
  * fix\: Parameterize slow-query and error SQL logs by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6493](https\://github.com/QuantumNous/new-api/pull/6493)
  * feat(oidc)\: Support custom display names for OIDC sign-in by @mrchi in [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * fix\: preserve Qwen thinking\_budget passthrough by @wxwwt in [https\://github.com/QuantumNous/new-api/pull/5836](https\://github.com/QuantumNous/new-api/pull/5836)
  * feat\: support zstd request decompression by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6545](https\://github.com/QuantumNous/new-api/pull/6545)
  * feat(logs)\: expose stream status to log owners by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6558](https\://github.com/QuantumNous/new-api/pull/6558)
  * fix(relay)\: preserve multipart image edits for New API channels by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6559](https\://github.com/QuantumNous/new-api/pull/6559)
  * fix(oauth)\: stop treating a foreign window\.opener as a bind flow by @neimaravila in [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * style\: unify public header nav link font size to 14px (text-sm) by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6557](https\://github.com/QuantumNous/new-api/pull/6557)
  * feat\: deepseek responses api by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6562](https\://github.com/QuantumNous/new-api/pull/6562)
  * fix(billing)\: settle tiered retries with final group by @faithleysath in [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)
  * fix(billing)\: harden tiered retry group-switch billing (follow-up to #6518) by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/6570](https\://github.com/QuantumNous/new-api/pull/6570)
  * fix(aws)\: cancel Bedrock requests on client disconnect by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/6589](https\://github.com/QuantumNous/new-api/pull/6589)
  * Feat/auto group by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/6590](https\://github.com/QuantumNous/new-api/pull/6590)

  ### New Contributors

  * @mrchi made their first contribution in [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * @neimaravila made their first contribution in [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * @faithleysath made their first contribution in [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-arm64-v1.0.0-rc.23) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-macos-v1.0.0-rc.23) (132.6 MB)
  * [new-api-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23) (113.2 MB)
  * [new-api-v1.0.0-rc.23.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23.exe) (115.0 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.tar.gz)
</Callout>

***

## v1.0.0-rc.22

<Callout type="note" title="Stable Release · Published 2026-07-26 21:19:04 (China Time)">
  This release expands channel and model administration with upstream model discovery, new Gemini image models, configurable billing options, and Sub2API support. It also improves reliability across streaming, pricing, refunds, user management, and admin UI workflows.

  ### New Features

  * Channels can now discover available models from advanced custom and Codex-compatible upstreams (#6184).
  * Added support for the latest Gemini image GA models (#6371).
  * Added configurable tool pricing with Sub2API channel support and alpha-search billing.
  * OpenAI Realtime GA models are now available with improved routing compatibility (#6032).

  ### Bug Fixes

  * Responses-to-Chat streaming no longer emits duplicate tool calls (#6225).
  * Creating a model with an existing name no longer clears its saved pricing (#6365).
  * The unset-price models view now lists only models available from the selected channels (#6126).
  * Very large user quota values are now handled without overflow (#6134).
  * User list sorting now works correctly with paginated results (#6194).
  * MiniMax models are now correctly associated with the MiniMax vendor (#6164).
  * Playground model group selectors now handle auto-group listings and long options correctly (#6163).
  * Task refunds are no longer duplicated during concurrent status updates (#6074).
  * Top-up amount fields can now be cleared completely while editing (#6473).
  * Channel inline priority updates are more reliable (#6415).

  ### Improvements

  * Admin JSON editing now has a more consistent experience and avoids UI issues that could hide content (#6421).
  * Users page search is debounced to reduce unnecessary requests and improve responsiveness (#6474).
  * Proxy-backed channel requests are more compatible and stable (#6157).
  * Upstream error logs now provide more useful fallback details when providers return unclear errors (#6431).

  ***

  ### What's Changed

  * fix\: list only channel models in unset price models tab by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6126](https\://github.com/QuantumNous/new-api/pull/6126)
  * fix\: purge authentication data on hard user deletion by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6168](https\://github.com/QuantumNous/new-api/pull/6168)
  * fix(users)\: prevent large quota values from overflowing by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6134](https\://github.com/QuantumNous/new-api/pull/6134)
  * fix\: infer MiniMax vendor for MiniMax models by @fux-dev in [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * fix\: add server-side sorting to user list, prevent client-side sort on paged data by @DawnMoon1542 in [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * fix(data-table)\: update table body immediately when toggling columns by @DawnMoon1542 in [https\://github.com/QuantumNous/new-api/pull/6253](https\://github.com/QuantumNous/new-api/pull/6253)
  * fix\: prevent duplicate tool calls in Responses-to-Chat streaming by @nikuleo in [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * feat(channel)\: support Codex upstream model discovery by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6184](https\://github.com/QuantumNous/new-api/pull/6184)
  * feat\: support upstream model fetch for advanced custom channels by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5971](https\://github.com/QuantumNous/new-api/pull/5971)
  * refactor(auth)\: replace dashboard sessions with stateless tokens and session control by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/6329](https\://github.com/QuantumNous/new-api/pull/6329)
  * fix\: Stop sending the realtime beta marker when relaying gpt-realtime GA models by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6032](https\://github.com/QuantumNous/new-api/pull/6032)
  * fix(playground)\: prevent model group option stretching by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6120](https\://github.com/QuantumNous/new-api/pull/6120)
  * perf(data-table)\: optimize action column width allocation by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6135](https\://github.com/QuantumNous/new-api/pull/6135)
  * fix(web)\: show used quota for unlimited API keys by @RedwindA in [https\://github.com/QuantumNous/new-api/pull/6224](https\://github.com/QuantumNous/new-api/pull/6224)
  * fix(channel)\: improve proxy client compatibility and cache lifecycle by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/6157](https\://github.com/QuantumNous/new-api/pull/6157)
  * fix(playground)\: resolve auto group model listing by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6163](https\://github.com/QuantumNous/new-api/pull/6163)
  * fix\: prevent duplicate suno task refunds via cas status update by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6074](https\://github.com/QuantumNous/new-api/pull/6074)
  * chore(github)\: migrate issue templates to required forms by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6452](https\://github.com/QuantumNous/new-api/pull/6452)
  * fix(github)\: restore issue form visibility by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6454](https\://github.com/QuantumNous/new-api/pull/6454)
  * fix\: log response body when parsed upstream error message is empty by @bigsongeth in [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)
  * fix\: prevent model create from wiping existing pricing for same name by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6365](https\://github.com/QuantumNous/new-api/pull/6365)
  * fix(web/channel)\: stabilize inline priority updates by @RedwindA in [https\://github.com/QuantumNous/new-api/pull/6415](https\://github.com/QuantumNous/new-api/pull/6415)
  * perf(json-editor)\: unify admin JSON editing experience by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6421](https\://github.com/QuantumNous/new-api/pull/6421)
  * feat\: add gemini-3-pro-image and gemini-3.1-flash-image GA models by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6371](https\://github.com/QuantumNous/new-api/pull/6371)
  * feat\: support Tencent TokenHub API key via OpenAI-compatible protocol by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6232](https\://github.com/QuantumNous/new-api/pull/6232)
  * fix\: allow topup amount input to be fully cleared by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6473](https\://github.com/QuantumNous/new-api/pull/6473)
  * fix\: debounce users page search input by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6474](https\://github.com/QuantumNous/new-api/pull/6474)

  ### New Contributors

  * @fux-dev made their first contribution in [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * @DawnMoon1542 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * @nikuleo made their first contribution in [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * @bigsongeth made their first contribution in [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-arm64-v1.0.0-rc.22) (109.9 MB)
  * [new-api-macos-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-macos-v1.0.0-rc.22) (132.4 MB)
  * [new-api-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22) (113.0 MB)
  * [new-api-v1.0.0-rc.22.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22.exe) (114.9 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.tar.gz)
</Callout>

***

## v1.0.0-rc.21

<Callout type="note" title="Stable Release · Published 2026-07-11 23:01:26 (China Time)">
  ### Highlights

  The headline change is GPT-5.6 cache write billing\: OpenAI `cache_write_tokens` are now charged at the cache-creation rate, with accounting safeguards around cached and uncached prompt tokens. This release also improves pricing workflows, Playground controls, channel table usability, and billing/logging reliability.

  ### New Features

  * Added GPT-5.6 cache write billing support, charging OpenAI `cache_write_tokens` at the cache-creation rate while keeping cached and uncached prompt token accounting consistent.
  * Pricing pages now support group-aware dynamic calculations and avoid showing sample-only special groups (#5906).
  * Model pricing settings now include an Unset Price Models tab plus status and sync filters, making it easier to find and configure models without prices (#6124).
  * The Playground now includes request parameter panels for chat and generation tuning, so users can adjust model behavior directly in the UI (#6044).
  * Channel lists now support manual column resizing and keep resized tables filling the available width (#5948).
  * Logs now show stream timing metrics and task detail views for clearer troubleshooting.
  * Added enhanced text protocol conversion and advanced custom routing capabilities for more flexible channel routing (#5825).

  ### Bug Fixes

  * Browser translation can no longer corrupt React-rendered pages (#5963).
  * Custom model names that differ only by case can now be added consistently, including from multi-select controls (#6061).
  * Billing now handles quota pre-consumption and image-stream disconnect edge cases more accurately.
  * Subscription reset handling is more reliable under concurrent updates (#6057).
  * Codex response passthrough fields now sync correctly (#6018).
  * Playground model selector lists now stay synchronized after model changes.
  * Custom home iframes can trigger top navigation after a user action as intended (#5955).
  * Restored paste behavior for default channel connection settings.

  ### Improvements

  * Upstream price sync tables in model pricing now load and render more efficiently (#6092).
  * Refined table badges, pricing layouts, sync dialogs, and default theme styling for a cleaner admin UI.
  * Font assets now resolve correctly across workspace layouts.

  ***

  ### What's Changed

  * fix(web)\: prevent browser translation from mutating React roots by @cat0825 in [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)
  * feat(web)\: Support manually resizing columns in the channel list by @zuiho-kai in [https\://github.com/QuantumNous/new-api/pull/5948](https\://github.com/QuantumNous/new-api/pull/5948)
  * fix(web)\: let channel table fill available width by @zuiho-kai in [https\://github.com/QuantumNous/new-api/pull/6031](https\://github.com/QuantumNous/new-api/pull/6031)
  * chore\: remove dead files resurrected by v1.0 launch commit by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6041](https\://github.com/QuantumNous/new-api/pull/6041)
  * fix\: use GORM v2 row locking for subscription resets by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6057](https\://github.com/QuantumNous/new-api/pull/6057)
  * feat(playground)\: add playground parameter settings panel by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6044](https\://github.com/QuantumNous/new-api/pull/6044)
  * fix\: allow adding model names that differ only by case in multi-select by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6061](https\://github.com/QuantumNous/new-api/pull/6061)
  * fix\: remove sample special usable groups leaking into pricing page by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5906](https\://github.com/QuantumNous/new-api/pull/5906)
  * perf(model-pricing)\: optimize upstream price sync tables by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6092](https\://github.com/QuantumNous/new-api/pull/6092)
  * fix(web)\: allow user-activated top navigation for custom home iframe by @Heykode in [https\://github.com/QuantumNous/new-api/pull/5955](https\://github.com/QuantumNous/new-api/pull/5955)
  * chore(deps)\: bump golang.org/x/crypto from 0.51.0 to 0.52.0 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/6096](https\://github.com/QuantumNous/new-api/pull/6096)
  * fix\: sync codex responses passthrough fields by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6018](https\://github.com/QuantumNous/new-api/pull/6018)
  * feat\: enhance text protocol conversion and advanced custom routing by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5825](https\://github.com/QuantumNous/new-api/pull/5825)
  * feat\: add unset price models tab to model pricing settings by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6124](https\://github.com/QuantumNous/new-api/pull/6124)

  ### New Contributors

  * @cat0825 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-arm64-v1.0.0-rc.21) (129.6 MB)
  * [new-api-macos-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-macos-v1.0.0-rc.21) (152.2 MB)
  * [new-api-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21) (132.8 MB)
  * [new-api-v1.0.0-rc.21.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21.exe) (134.6 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.tar.gz)
</Callout>

***

## v1.0.0-rc.20

<Callout type="note" title="Stable Release · Published 2026-07-07 21:46:39 (China Time)">
  ### Highlights

  This release adds GPT-5.6 pricing support and stale instance cleanup tools for administrators. It also fixes several quota and pricing edge cases, including wallet reward transfers and decimal ratio input.

  ### New Features

  * Added token pricing support for GPT-5.6 models.
  * Added system-info actions for cleaning up stale instances. (#5953)

  ### Bug Fixes

  * Wallet reward transfers now respect the configured quota unit instead of using an incorrect fixed unit. (#5808)
  * Group ratio fields now allow decimal values such as `0.05` to be typed normally. (#5995)
  * Tiered pricing now uses a default token estimate during pre-consumption, improving quota calculation for affected pricing rules.

  ***

  ### What's Changed

  * fix\: Preserve intermediate decimal input in the group Ratio field and fix entering 0.05 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5995](https\://github.com/QuantumNous/new-api/pull/5995)
  * feat(system-info)\: add stale instance cleanup actions by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5953](https\://github.com/QuantumNous/new-api/pull/5953)
  * fix(wallet)\: honor configured quota units for reward transfers by @A-Words in [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  ### New Contributors

  * @A-Words made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-arm64-v1.0.0-rc.20) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-macos-v1.0.0-rc.20) (151.7 MB)
  * [new-api-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20) (132.4 MB)
  * [new-api-v1.0.0-rc.20.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20.exe) (134.2 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.tar.gz)
</Callout>

***

## v1.0.0-rc.19-i18nfix.2

<Callout type="note" title="Stable Release · Published 2026-07-07 14:06:07 (China Time)">
  Fix i18n error

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-linux.txt) (200 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-macos.txt) (103 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-windows.txt) (101 B)
  * [new-api-arm64-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-arm64-v1.0.0-rc.19-i18nfix.2) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-macos-v1.0.0-rc.19-i18nfix.2) (151.7 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2) (132.4 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2.exe) (134.2 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.tar.gz)
</Callout>

***

## v1.0.0-rc.19

<Callout type="note" title="Stable Release · Published 2026-07-07 13:19:27 (China Time)">
  ### New Features

  * Admins can now reset subscription quotas and review quota saturation events for auditing, making quota management easier (#5952).
  * Added Traditional Chinese (zh-TW) localization for the new UI (#5942).

  ### Bug Fixes

  * Fixed billing quota calculations for very large quotas so limits are applied correctly.

  ***

  ### What's Changed

  * Localized new ui to zh-TW by @MeowTechOpenSource in [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)
  * feat(subscription)\: add admin quota reset actions by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5952](https\://github.com/QuantumNous/new-api/pull/5952)

  ### New Contributors

  * @MeowTechOpenSource made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-arm64-v1.0.0-rc.19) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-macos-v1.0.0-rc.19) (151.7 MB)
  * [new-api-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19) (132.4 MB)
  * [new-api-v1.0.0-rc.19.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19.exe) (134.2 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.tar.gz)
</Callout>

***

## v1.0.0-rc.18

<Callout type="note" title="Stable Release · Published 2026-07-07 01:16:57 (China Time)">
  Billing quota handling is more reliable in this release, with stricter quantity validation to prevent incorrect quota calculations.

  **Bug Fixes**

  * Improved billing quantity validation so quota and usage calculations handle invalid or extreme values more reliably.

  ***

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-arm64-v1.0.0-rc.18) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-macos-v1.0.0-rc.18) (151.4 MB)
  * [new-api-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18) (132.0 MB)
  * [new-api-v1.0.0-rc.18.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18.exe) (133.9 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.tar.gz)
</Callout>

***

## v1.0.0-rc.17

<Callout type="note" title="Stable Release · Published 2026-07-06 22:37:46 (China Time)">
  ### Highlights

  This release improves channel testing, redemption management, theme handling, and several web UI flows. It also fixes usage reporting, classic web builds, streaming disconnect handling, and quota/video duration calculations.

  ### New Features

  * Redemption management now supports status filtering and cleanup actions for easier administration.
  * Group ratio editing is easier to use, with clearer visibility behavior and more robust JSON input handling.
  * Redeem failures now show clearer messages so users can understand what went wrong.

  ### Bug Fixes

  * AI Elements integrations now read nested usage data so token usage is reported correctly.
  * Classic web builds now complete successfully again (#5892).
  * Field passthrough controls now appear correctly for Codex channels (#5902).
  * Home iframes now stay in sync with the selected theme and language (#5917).
  * Custom HTML rendered inside Shadow DOM now follows light and dark mode changes correctly (#5890).
  * Logged-in users are now redirected away from the sign-up page consistently with the login and classic themes (#5910).
  * Streaming responses no longer continue writing after the client disconnects (#5710).
  * Quota settlement and Ali video duration handling were corrected after task balance settlement (#5923).
  * Build date generation no longer fails when DNS lookup fails (#5945).

  ### Improvements

  * Channel and model test dialogs are more compact and easier to operate (#5886).
  * Dynamic pricing details now use styling consistent with the log details dialog (#5905).
  * Mobile user cards have been refined for better readability and layout.
  * Legacy top-up warning text is clearer and easier to understand (#5855).

  ***

  ### What's Changed

  * chore(deps-dev)\: bump tmp from 0.2.5 to 0.2.7 in /electron by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5147](https\://github.com/QuantumNous/new-api/pull/5147)
  * chore(web)\: update default web dependencies by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5884](https\://github.com/QuantumNous/new-api/pull/5884)
  * perf(web)\: refine channel test dialog interactions by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5886](https\://github.com/QuantumNous/new-api/pull/5886)
  * fix(classic)\: fix classic web build failures by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5892](https\://github.com/QuantumNous/new-api/pull/5892)
  * fix(channels)\: show field passthrough controls for Codex by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5902](https\://github.com/QuantumNous/new-api/pull/5902)
  * fix\: align dynamic pricing style with log details dialog sections by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5905](https\://github.com/QuantumNous/new-api/pull/5905)
  * fix\: Optimize quota after task balance settlement and Alibaba video duration by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5923](https\://github.com/QuantumNous/new-api/pull/5923)
  * fix(web)\: sync home iframe theme and language by @guoruqiang in [https\://github.com/QuantumNous/new-api/pull/5917](https\://github.com/QuantumNous/new-api/pull/5917)
  * fix(web)\: Fix light/dark styling of custom HTML rendered in an isolated Shadow DOM by @olwater in [https\://github.com/QuantumNous/new-api/pull/5890](https\://github.com/QuantumNous/new-api/pull/5890)
  * fix(web)\: Add a signed-in redirect guard to registration, consistent with sign-in and the classic theme (#5908) by @Heykode in [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * feat\: optimize legacy top-up warning banner copy (#5851) by @Gravirei in [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)
  * fix\: avoid stale stream writes after client disconnect by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5710](https\://github.com/QuantumNous/new-api/pull/5710)
  * Fix/build date dns error by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5945](https\://github.com/QuantumNous/new-api/pull/5945)

  ### New Contributors

  * @Heykode made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * @Gravirei made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-arm64-v1.0.0-rc.17) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-macos-v1.0.0-rc.17) (151.4 MB)
  * [new-api-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17) (132.0 MB)
  * [new-api-v1.0.0-rc.17.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17.exe) (133.8 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.tar.gz)
</Callout>

***

## v1.0.0-rc.16

<Callout type="note" title="Stable Release · Published 2026-07-03 15:41:42 (China Time)">
  **Highlights**

  This release expands model and media compatibility with Responses/Chat interoperability, Doubao Seedance 2.0 updates, and Wan2.7 i2v media mapping. It also improves the web experience around Playground rendering, channel management, page state retention, and graceful restarts.

  **New Features**

  * Added Responses API to Chat compatibility so providers and clients using either format can interoperate more reliably (#5787).
  * Expanded Doubao Seedance 2.0 support with material asset APIs, resolution-aware billing, video-input billing, 4K billing, and new request options (#5824).
  * Added Wan2.7 image-to-video media mapping support (#4984).
  * Added graceful shutdown support to reduce interrupted replies and avoid losing cached panel data during restarts (#4258).
  * Improved channel management with a clearer layout and a more capable advanced custom route editor.

  **Bug Fixes**

  * Fixed the model pricing tiered expression editor so it refreshes correctly when switching between models (#5752).
  * Fixed async task usage logs so usage is attributed to the node that initiated the task (#5684).
  * Fixed theme switching so the app returns to the home page instead of landing on a 404 route (#5612).
  * Fixed custom HTML and Markdown rendering so content keeps consistent styling and spacing, including isolated HTML views (#5795).
  * Fixed page state resets when switching tabs within the same route, including dashboard time ranges (#5796).
  * Fixed channel status filters so they persist across page navigation (#5863).
  * Fixed Ollama non-streaming tool call handling (#5865).
  * Fixed Waffo product information and webhook behavior (#5704).

  **Improvements**

  * Improved the Playground chat experience and Markdown rendering (#5217).
  * Streamlined table actions and destructive confirmation dialogs for a cleaner web UI (#5645).
  * Improved ClickHouse log filtering for LIKE queries.
  * Optimized the frontend build pipeline for faster web builds (#5786).

  ***

  ### What's Changed

  * chore(deps)\: bump dompurify from 3.4.5 to 3.4.11 in /web/default by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5718](https\://github.com/QuantumNous/new-api/pull/5718)
  * fix(ci)\: install classic workspace dependencies for releases by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5719](https\://github.com/QuantumNous/new-api/pull/5719)
  * perf(web)\: streamline table actions and destructive dialogs by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5645](https\://github.com/QuantumNous/new-api/pull/5645)
  * fix\: add Waffo goods info and webhook SDK update by @zhongyuanzhao-alt in [https\://github.com/QuantumNous/new-api/pull/5704](https\://github.com/QuantumNous/new-api/pull/5704)
  * fix(model-pricing)\: refresh tiered expression editor when switching models by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5752](https\://github.com/QuantumNous/new-api/pull/5752)
  * fix\: sync bun.lock with dompurify 3.4.11 to restore frozen-lockfile build by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5738](https\://github.com/QuantumNous/new-api/pull/5738)
  * fix(theme)\: Reset to the home page after changing frontend themes to avoid routing 404 errors by @zhangzhichaolove in [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * fix(task)\: attribute async task usage log to the initiating node by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5684](https\://github.com/QuantumNous/new-api/pull/5684)
  * feat\: add Casbin admin permissions by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5755](https\://github.com/QuantumNous/new-api/pull/5755)
  * feat(playground)\: improve Playground chat experience and Markdown rendering by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5217](https\://github.com/QuantumNous/new-api/pull/5217)
  * fix(auth)\: align password validation copy by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5759](https\://github.com/QuantumNous/new-api/pull/5759)
  * fix(web)\: render custom HTML and Markdown content consistently by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5760](https\://github.com/QuantumNous/new-api/pull/5760)
  * fix(openai)\: harden Chat-to-Responses compatibility by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5772](https\://github.com/QuantumNous/new-api/pull/5772)
  * feat\: support Responses to Chat by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5787](https\://github.com/QuantumNous/new-api/pull/5787)
  * feat\: Support resolution-based pricing for doubao-seedance-2-0-260128 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5300](https\://github.com/QuantumNous/new-api/pull/5300)
  * feat\: support doubao seedance 2.0 safety\_identifier/priority and 4k billing by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5824](https\://github.com/QuantumNous/new-api/pull/5824)
  * fix(web)\: Fix filtered custom HTML styles and incorrect layout spacing by @olwater in [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * feat\: support Wan2.7 i2v media mapping by @wxwwt in [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * perf(web)\: optimize web Rsbuild and Tailwind build pipeline by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5786](https\://github.com/QuantumNous/new-api/pull/5786)
  * fix(makefile)\: run only default web dev server from dev-web by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5794](https\://github.com/QuantumNous/new-api/pull/5794)
  * fix(web)\: inject app styles into isolated HTML by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5860](https\://github.com/QuantumNous/new-api/pull/5860)
  * fix\: preserve route state when switching same-route tabs (dashboard time range resets) by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5796](https\://github.com/QuantumNous/new-api/pull/5796)
  * Support graceful shutdown to avoid interrupted responses and lost dashboard cache data on restart by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4258](https\://github.com/QuantumNous/new-api/pull/4258)
  * fix\: only treat 401 as session expiry in default theme auth guard by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5872](https\://github.com/QuantumNous/new-api/pull/5872)
  * fix\: persist channel status filter across page navigation by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5863](https\://github.com/QuantumNous/new-api/pull/5863)
  * chore(deps)\: bump golang.org/x/net from 0.50.0 to 0.55.0 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5862](https\://github.com/QuantumNous/new-api/pull/5862)
  * chore(deps)\: bump golang.org/x/image from 0.38.0 to 0.41.0 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5873](https\://github.com/QuantumNous/new-api/pull/5873)
  * fix\: handle ollama non-stream tool calls by @stevenjoezhang in [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  ### New Contributors

  * @zhangzhichaolove made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * @olwater made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * @wxwwt made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * @stevenjoezhang made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-arm64-v1.0.0-rc.16) (127.4 MB)
  * [new-api-macos-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-macos-v1.0.0-rc.16) (149.8 MB)
  * [new-api-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16) (130.5 MB)
  * [new-api-v1.0.0-rc.16.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16.exe) (132.3 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.tar.gz)
</Callout>

***

## v1.0.0-rc.15

<Callout type="note" title="Stable Release · Published 2026-06-24 21:00:04 (China Time)">
  ### Highlights

  This release adds several operations-focused controls, including passive channel monitoring, ClickHouse-backed log storage, system task execution, and instance visibility. It also improves frontend reliability and polish across usage logs, markdown rendering, channel selection, and optional wallet UI behavior.

  ### New Features

  * Added passive channel monitoring mode for checking channel health without actively disrupting traffic (#5592).
  * Added support for storing logs in ClickHouse for deployments that need scalable log storage and querying (#5663).
  * Added a system task runner with persistent cleanup progress tracking for long-running maintenance jobs (#5680).
  * Added a system instance information panel to make deployment/node status easier to inspect (#5716).
  * Added a user token limit configuration section in system settings (#5678).
  * Added channel testing controls for environment selection and asynchronous polling delay configuration.
  * Default node names now fall back to the machine hostname when `NODE_NAME` is not set (#5659).

  ### Bug Fixes

  * Usage logs now show provider icons correctly for CN models (#5631).
  * Corrected the Stepfun provider display name (#5636).
  * Fixed SMTP compatibility with STARTTLS mode and NTLM authentication (#5426).
  * Fixed classic theme build failures related to timezone date handling (#5676).
  * Improved markdown rendering and expanded syntax support in the web UI (#5689).
  * Fixed channel card selection state so the UI stays in sync with the selected channel (#5700).
  * Hid the wallet entry from the profile dropdown when the wallet module is disabled (#5708).

  ### Improvements

  * Simplified log cleanup behavior as part of the new ClickHouse logging and system task maintenance flow.

  ***

  ### What's Changed

  * fix(usage-logs)\: show provider icons for CN models (align with classic frontend) by @DeliciousBuding in [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * fix\: StepFun -> Stepfun by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5636](https\://github.com/QuantumNous/new-api/pull/5636)
  * feat\: add passive channel monitoring mode by @exherb in [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)
  * feat\: default node name to hostname when NODE\_NAME unset by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5659](https\://github.com/QuantumNous/new-api/pull/5659)
  * feat\: support ClickHouse log database by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5663](https\://github.com/QuantumNous/new-api/pull/5663)
  * fix\: support SMTP STARTTLS mode and NTLM auth by @bensonfx in [https\://github.com/QuantumNous/new-api/pull/5426](https\://github.com/QuantumNous/new-api/pull/5426)
  * chore(deps)\: bump github.com/ClickHouse/ch-go from 0.58.2 to 0.65.0 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5664](https\://github.com/QuantumNous/new-api/pull/5664)
  * fix\: date-fns-tz classic theme build error by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5676](https\://github.com/QuantumNous/new-api/pull/5676)
  * feat\: add system task runner by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5680](https\://github.com/QuantumNous/new-api/pull/5680)
  * feat\: add system instance info panel by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5716](https\://github.com/QuantumNous/new-api/pull/5716)
  * fix(web)\: replace default markdown renderer and expand syntax support by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5689](https\://github.com/QuantumNous/new-api/pull/5689)
  * fix(web)\: sync channel card selection state by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5700](https\://github.com/QuantumNous/new-api/pull/5700)
  * fix(web)\: hide wallet entry in profile dropdown when wallet module disabled by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5708](https\://github.com/QuantumNous/new-api/pull/5708)
  * feat(system-settings)\: add user token limit configuration section by @RedwindA in [https\://github.com/QuantumNous/new-api/pull/5678](https\://github.com/QuantumNous/new-api/pull/5678)

  ### New Contributors

  * @DeliciousBuding made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * @exherb made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-arm64-v1.0.0-rc.15) (131.4 MB)
  * [new-api-macos-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-macos-v1.0.0-rc.15) (153.3 MB)
  * [new-api-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15) (134.2 MB)
  * [new-api-v1.0.0-rc.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15.exe) (136.0 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.tar.gz)
</Callout>

***

## v1.0.0-rc.14

<Callout type="note" title="Stable Release · Published 2026-06-20 22:15:42 (China Time)">
  ### Highlights

  This release adds a new dashboard traffic flow Sankey chart for visualizing token routing and flow patterns, with interactive highlighting, persistent filters, and limits to keep large graphs readable. Channel management also gets a faster, cleaner card layout for easier browsing and reduced UI re-rendering.

  ### New Features

  * Added a dashboard traffic flow Sankey chart to help admins understand token flow and routing behavior at a glance (#5465).
  * Added routing reliability management for better control and visibility over routing behavior.

  ### Gallery

  | Traffic flow chart                                                                                                          | Channel management card layout                                                                                        |
  | --------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
  | ![Channel management card layout example](https\://github.com/user-attachments/assets/e0d82bd4-e052-4518-9fac-1144c0bd0721) | ![Image from Gallery release notes](https\://github.com/user-attachments/assets/2ab5e6e6-f4f7-44f5-9abd-7191ed30e7aa) |

  ### Bug Fixes

  * Fixed log filtering by login type in the new frontend (#5620).
  * Fixed the billing history dialog layout so pagination no longer overlaps the list (#5627).
  * Fixed model pricing entries that could not be deleted from the visual pricing list (#5628).
  * Fixed repeated database column migrations running again after restarts (#5361, #5616).

  ### Improvements

  * Improved the channel management card layout and reduced unnecessary re-renders for a smoother experience.
  * Simplified the model list for easier scanning and management.
  * Updated channel icons for better visual consistency.

  ***

  ### What's Changed

  * fix\: stop repeated allow\_balance\_pay column migration on restart by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5361](https\://github.com/QuantumNous/new-api/pull/5361)
  * fix\: stop repeated allow\_wallet\_overflow column migration on restart by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5616](https\://github.com/QuantumNous/new-api/pull/5616)
  * feat(dashboard)\: Add a Sankey chart for token traffic flow by @Quaternijkon in [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)
  * fix(log)\: Fix login-type (type=7) filtering in the new frontend logs by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5620](https\://github.com/QuantumNous/new-api/pull/5620)
  * fix(wallet)\: Fix pagination overlapping the list in the billing history dialog (#5624) by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5627](https\://github.com/QuantumNous/new-api/pull/5627)
  * fix(model-pricing)\: Fix model pricing list items that cannot be deleted (#5623) by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5628](https\://github.com/QuantumNous/new-api/pull/5628)

  ### New Contributors

  * @Quaternijkon made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-arm64-v1.0.0-rc.14) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-macos-v1.0.0-rc.14) (142.3 MB)
  * [new-api-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14) (125.4 MB)
  * [new-api-v1.0.0-rc.14.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14.exe) (127.1 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.tar.gz)
</Callout>

***

## v1.0.0-rc.13

<Callout type="note" title="Stable Release · Published 2026-06-19 20:28:34 (China Time)">
  v1.0.0-rc.13 focuses on a more polished and responsive frontend experience, especially around channel management and data-heavy pages. The channel page now supports a card-style display with improved mobile layouts, while logs, metrics, endpoint selection, date picking, and usage views received UI/UX refinements.

  ### New Features

  * Added a reusable card/table view toggle for data tables, including a new card layout that makes channel and table-heavy pages easier to browse on different screen sizes.
  * Added locale-aware number formatting so numeric values are displayed more naturally for users in different regions.

  ### Improvements

  * Improved the channel page card layout with a clearer left/right structure and better mobile handling for small screens.
  * Refined logs, metrics, endpoint selection, date picker, toolbar controls, and model drawer interfaces for a cleaner and more consistent UI/UX.
  * Updated the Codex usage interface for better readability and usability (#5595).
  * Reduced unnecessary data refreshes when returning focus to the browser window, improving frontend performance.
  * Updated frontend branding copy and visual styling for a more consistent product experience.

  ### Bug Fixes

  * Improved timestamp precision in drawing-related displays by including milliseconds where needed.

  ***

  ### What's Changed

  * chore(web)\: enforce default frontend oxc quality checks by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5585](https\://github.com/QuantumNous/new-api/pull/5585)
  * refactor\: codex usage ui by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5595](https\://github.com/QuantumNous/new-api/pull/5595)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-arm64-v1.0.0-rc.13) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-macos-v1.0.0-rc.13) (142.2 MB)
  * [new-api-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13) (125.3 MB)
  * [new-api-v1.0.0-rc.13.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13.exe) (127.0 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.tar.gz)
</Callout>

***

## v1.0.0-rc.12

<Callout type="note" title="Stable Release · Published 2026-06-18 20:34:16 (China Time)">
  Highlights\: This release introduces AdvancedCustom channels for more flexible custom routing, makes channel batch testing easier to act on, and expands model marketplace performance monitoring with clearer success-rate and latency insights.

  ### New Features

  * Added AdvancedCustom channels with improved custom route matching for more flexible provider and model routing (#5590).
  * Enhanced channel model batch testing with complete test execution, refreshed status updates, clearer results, failed-model deletion, and copying selected models (#5532).
  * Expanded model marketplace performance monitoring with uptime calculations, recent success rates, success-rate grading, and compact latency/throughput displays.
  * Added persistent table preferences so page size and column visibility are remembered across navigation and sessions (#5403).

  ### Bug Fixes

  * Fixed tool-call handling so empty `arguments` values still preserve the expected `tool_use` block (#5543).
  * Fixed the CC Switch model selector so model choices display and update correctly (#5515).
  * Fixed several UI clipping and overflow issues in lists, data tables, usage log details, and custom home iframes (#5510, #5536, #5533, #5545).

  ### Improvements

  * Improved payment and recharge UI with clearer payment method buttons, icons, and minimum top-up information.
  * Improved subscription plan presentation with purchase descriptions, wallet overflow handling, and downgrade group support.
  * Refined settings, overview setup guide, wallet/profile interactions, and log statistic card layouts for better readability.

  ### Breaking Changes

  * Subscription product option and catalog endpoints now use `GET`, which may require client integrations to update their request method.
  * Removed the “All” period option from rankings filters.

  ***

  ### What's Changed

  * fix(web)\: prevent list cell text and badge overflow by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5510](https\://github.com/QuantumNous/new-api/pull/5510)
  * fix(keys)\: refresh API key form options by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5512](https\://github.com/QuantumNous/new-api/pull/5512)
  * fix\: fix CC Switch model selector by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5515](https\://github.com/QuantumNous/new-api/pull/5515)
  * fix(data-table)\: capture row selection state in memo comparison by @RedwindA in [https\://github.com/QuantumNous/new-api/pull/5524](https\://github.com/QuantumNous/new-api/pull/5524)
  * fix(channels)\: refresh channel test dialog status by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5517](https\://github.com/QuantumNous/new-api/pull/5517)
  * fix\: restore custom home iframe viewport height by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5545](https\://github.com/QuantumNous/new-api/pull/5545)
  * fix(web)\: prevent usage log details dialog from clipping bottom content by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5533](https\://github.com/QuantumNous/new-api/pull/5533)
  * fix\: aws ak/sk context management by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5547](https\://github.com/QuantumNous/new-api/pull/5547)
  * test\: clean up reward-hacking backend tests by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5563](https\://github.com/QuantumNous/new-api/pull/5563)
  * fix\: Preserve tool\_use blocks when tool-call arguments are empty by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5543](https\://github.com/QuantumNous/new-api/pull/5543)
  * fix\: complete channel model batch testing by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5532](https\://github.com/QuantumNous/new-api/pull/5532)
  * feat\: Persist table page size across navigation and sessions (#5377) by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5403](https\://github.com/QuantumNous/new-api/pull/5403)
  * fix(data-table)\: prevent component cell clipping by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5536](https\://github.com/QuantumNous/new-api/pull/5536)
  * fix(oauth)\: clear bindings when hard deleting users by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5582](https\://github.com/QuantumNous/new-api/pull/5582)
  * feat\: advanced custom channel by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5590](https\://github.com/QuantumNous/new-api/pull/5590)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-arm64-v1.0.0-rc.12) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-macos-v1.0.0-rc.12) (142.1 MB)
  * [new-api-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12) (125.3 MB)
  * [new-api-v1.0.0-rc.12.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12.exe) (127.0 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.tar.gz)
</Callout>

***

## v1.0.0-rc.11

<Callout type="note" title="Stable Release · Published 2026-06-13 16:15:40 (China Time)">
  Highlights\: This release adds support for Claude Opus 4.8, improves OpenAI image API compatibility, and makes the model pricing editor and data-heavy tables easier to use. It also fixes several UI, quota display, relay compatibility, and provider-specific issues.

  ### New Features

  * Added support for Claude Opus 4.8 (#5177).
  * Added an option to control whether channel stickiness is cleared when a channel is disabled (#5306).
  * Added a subscription balance redemption toggle for more flexible balance handling.
  * Added user ID visibility on the profile page (#5317).
  * Added support for streaming image relay and image edits in the OpenAI images API (#4608).

  ### Bug Fixes

  * Forms now focus the first validation error after submission, making errors easier to find and correct (#5163).
  * Fixed custom cc-switch names being reset after losing focus (#5170).
  * Fixed custom model icons not staying in sync in pricing views (#5224).
  * Fixed advanced channel validation errors so they are shown without incorrectly expanding unrelated settings (#5239).
  * Fixed quota and balance displays so currency conversion updates both the unit and the displayed value (#5296).
  * Fixed Dify remote-image handling in file-based requests (#5134).
  * Fixed model resolution for video generation task lookups (#5133).
  * Improved Anthropic-compatible GLM relay behavior to avoid compatibility failures (#5307).
  * Narrowed OpenAI o-series model adaptation to avoid applying it to unsupported models (#5293).
  * Fixed multiselect popovers so they respect the active theme (#5328).
  * Fixed Kimi K2.6 temperature normalization (#5390).
  * Added support for filtering deleted users by status (#5464).
  * Fixed deployment settings loading so they are only fetched on the deployments page (#5466).

  ### Improvements

  * Improved admin log and batch update performance for smoother large-scale operations (#5116).
  * Improved the model pricing editor with clearer layouts, better draft saving, reusable JSON editing, and support for six-decimal pricing steps (#5275).
  * Improved channel search responsiveness with debouncing and better IME input handling (#5393).
  * Improved frontend table rendering, pinned columns, table layout, and badge display (#5405).
  * Improved dialog sizing and footer layout across the frontend (#5346).
  * Simplified public page hero copy for a cleaner landing page (#5339).

  ***

  ### What's Changed

  * fix(web)\: improve form validation error focus by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5163](https\://github.com/QuantumNous/new-api/pull/5163)
  * feat(keys/cc-switch-dialog)\: Fix custom cc-switch names resetting when the field loses focus by @GnezIew in [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * fix(model)\: correct idx\_created\_at\_id index column order to (created\_at, id) by @realRoc in [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * perf\: order admin logs by created\_at to use composite index by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5116](https\://github.com/QuantumNous/new-api/pull/5116)
  * chore(deps)\: bump axios from 1.15.2 to 1.16.0 in /web/classic by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5185](https\://github.com/QuantumNous/new-api/pull/5185)
  * feat\: support claude-opus-4-8 by @hjxwz123 in [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * fix(pricing)\: sync custom model icons by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5224](https\://github.com/QuantumNous/new-api/pull/5224)
  * chore(web)\: centralize shared frontend dependency versions by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5227](https\://github.com/QuantumNous/new-api/pull/5227)
  * feat(web)\: support classic Rsbuild dev and build by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5232](https\://github.com/QuantumNous/new-api/pull/5232)
  * fix(channels)\: reveal advanced validation errors by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5239](https\://github.com/QuantumNous/new-api/pull/5239)
  * docs\: refine issue templates by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5271](https\://github.com/QuantumNous/new-api/pull/5271)
  * fix\: Fix balance display changing the unit without converting the value by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5296](https\://github.com/QuantumNous/new-api/pull/5296)
  * fix(dify)\: initialize file pointer before remote-image field assignment by @Pluviobyte in [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * fix(distributor)\: resolve model for GET /v1/video/generations/\:task\_id by @Pluviobyte in [https\://github.com/QuantumNous/new-api/pull/5133](https\://github.com/QuantumNous/new-api/pull/5133)
  * fix\: add relay idle connection timeout config by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5309](https\://github.com/QuantumNous/new-api/pull/5309)
  * feat\: Allow configuration of whether channel stickiness is cleared when a channel is disabled by @GuangYiDing in [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * fix(relay)\: fix Anthropic-compatible compatibility for GLM (avoid chunked encoding) by @Chen011214 in [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * fix\: limit anonymous request body by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5244](https\://github.com/QuantumNous/new-api/pull/5244)
  * fix(i18n)\: clarify thinking adapter copy by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5242](https\://github.com/QuantumNous/new-api/pull/5242)
  * fix\: Narrow the adaptation scope for OpenAI o-series models by @USER-HFC in [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * fix\: reuse stream scanner buffer in channel handlers by @xujiantop-crypto in [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * feat(web)\: show user id on profile page by @P2K0 in [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * perf(model-pricing)\: improve model pricing editor UX by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5275](https\://github.com/QuantumNous/new-api/pull/5275)
  * perf(web)\: simplify public page hero copy by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5339](https\://github.com/QuantumNous/new-api/pull/5339)
  * perf(web)\: improve frontend dialog layout and sizing by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5346](https\://github.com/QuantumNous/new-api/pull/5346)
  * fix\: respect theme for multiselect combobox popover by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5328](https\://github.com/QuantumNous/new-api/pull/5328)
  * fix\: align mobile usage log cost badge by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5161](https\://github.com/QuantumNous/new-api/pull/5161)
  * fix\: support six-decimal steps in model pricing editor by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5332](https\://github.com/QuantumNous/new-api/pull/5332)
  * fix(openai)\: support streaming image relay and image edit for images API by @gaoren002 in `#4608`
  * perf(web)\: add debounce channel search and skip during IME composition by @QAbot-zh in [https\://github.com/QuantumNous/new-api/pull/5393](https\://github.com/QuantumNous/new-api/pull/5393)
  * fix\: normalize kimi k2.6 temperature by @bensonfx in [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)
  * perf(web)\: improve frontend table rendering and pinned columns/UI table by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5405](https\://github.com/QuantumNous/new-api/pull/5405)
  * perf(data-table)\: improve data table layout and badge display by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5460](https\://github.com/QuantumNous/new-api/pull/5460)
  * feat(audit)\: add localized security audit logs by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5462](https\://github.com/QuantumNous/new-api/pull/5462)
  * chore\: update Codex channel by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5461](https\://github.com/QuantumNous/new-api/pull/5461)
  * fix\: add deleted user status filter by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5464](https\://github.com/QuantumNous/new-api/pull/5464)
  * fix\: only fetch deployment settings on deployments page by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5466](https\://github.com/QuantumNous/new-api/pull/5466)

  ### New Contributors

  * @GnezIew made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * @realRoc made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * @hjxwz123 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * @Pluviobyte made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * @GuangYiDing made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * @Chen011214 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * @USER-HFC made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * @xujiantop-crypto made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * @P2K0 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * @bensonfx made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-arm64-v1.0.0-rc.11) (84.8 MB)
  * [new-api-macos-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-macos-v1.0.0-rc.11) (103.8 MB)
  * [new-api-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11) (87.2 MB)
  * [new-api-v1.0.0-rc.11.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11.exe) (88.9 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.tar.gz)
</Callout>

***

## v1.0.0-rc.10

<Callout type="note" title="Stable Release · Published 2026-05-26 22:20:13 (China Time)">
  ### Highlights

  v1.0.0-rc.10 focuses on UI polish, relay reliability, and admin workflow fixes. It adds new theme options and subscription balance purchases while tightening logs, channel behavior, webhooks, payments, and provider tool-call handling.

  ### New Features

  * New theme customization options add Anthropic and Simple Large presets, configurable serif typography, and an extra-large scaling option.
  * Subscription billing now supports balance purchases.

  ### Bug Fixes

  * Automatically disabled channels are no longer selected for new requests, and channel actions no longer show duplicate notifications (#4983).
  * Tool-call relays between Gemini and Claude are more reliable, including concurrent tool calls (#5095).
  * Image relay requests now apply the requested quality setting correctly (#5103).
  * Usage log filters now match exact values unless a wildcard is explicitly used, and very large upstream errors are shortened to keep logs usable (#5097).
  * Webhook processing now completes more reliably (#5047).
  * Waffo payment settings now save consistently and hide legacy options (#5110).
  * System Settings now detects unsaved changes correctly and handles numeric inputs without invalid values.

  ### Improvements

  * Large media relay requests now use less memory, improving stability under load.
  * System Settings and channel creation/editing pages have clearer, more compact layouts with improved controls.
  * Usage logs and the default web UI are easier to use on mobile and easier to scan, with better table spacing, badges, charts, and dark-mode readability.
  * The homepage hero section has been refreshed with a cleaner two-column layout and updated copy.

  ***

  ### What's Changed

  * 🐛 fix(channel)\: evict auto-disabled multi-key channels from cache by @t0ng7u in [https\://github.com/QuantumNous/new-api/pull/4983](https\://github.com/QuantumNous/new-api/pull/4983)
  * \[BugFix] fix webhook process by @Hill-waffo in [https\://github.com/QuantumNous/new-api/pull/5047](https\://github.com/QuantumNous/new-api/pull/5047)
  * fix(payment)\: hide classic Waffo Pancake settings by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5085](https\://github.com/QuantumNous/new-api/pull/5085)
  * fix(relay)\: correct image quality parameter handling by @lanfunoe in [https\://github.com/QuantumNous/new-api/pull/5103](https\://github.com/QuantumNous/new-api/pull/5103)
  * fix\: truncate oversized upstream error logs by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5083](https\://github.com/QuantumNous/new-api/pull/5083)
  * fix\: Remove the fcIdx -1 offset to fix key collisions in concurrent tool calls by @learner-i in [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)
  * fix\:gemini to claude tool\_use err by @nekohy in [https\://github.com/QuantumNous/new-api/pull/5041](https\://github.com/QuantumNous/new-api/pull/5041)
  * fix\: handle paginated API key search response by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5014](https\://github.com/QuantumNous/new-api/pull/5014)
  * fix\: prevent duplicate channel action toasts by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5015](https\://github.com/QuantumNous/new-api/pull/5015)
  * fix\: consolidate Waffo payment settings save flow by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5110](https\://github.com/QuantumNous/new-api/pull/5110)
  * fix\: use actual user id for channel tests by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5109](https\://github.com/QuantumNous/new-api/pull/5109)
  * fix\: keep usage log filters exact unless wildcard is explicit by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5097](https\://github.com/QuantumNous/new-api/pull/5097)

  ### New Contributors

  * @learner-i made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-linux.txt) (180 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-arm64-v1.0.0-rc.10) (82.8 MB)
  * [new-api-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10) (85.3 MB)
  * [new-api-v1.0.0-rc.10.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10.exe) (86.9 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.tar.gz)
</Callout>

***

## v1.0.0-rc.8

<Callout type="note" title="Stable Release · Published 2026-05-22 16:25:46 (China Time)">
  #### Highlights

  This release adds Waffo Pancake gateway support with admin catalog/product binding and focuses on polishing admin/API behavior. It also improves model metadata and pricing consistency, channel-test diagnostics, dashboard/reporting filters, and request-processing efficiency.

  #### New Features

  * Added Waffo Pancake gateway support with admin catalog/product binding (#4935).

  #### Bug Fixes

  * Dashboard content now follows configured visibility settings consistently (#4975).
  * Performance metric summaries now include only active groups (#4976).
  * Model pricing displays are now normalized to avoid inconsistent values (#4985).
  * Model ownership metadata is now resolved from active channels for more accurate model listings (#4416).
  * Default frontend links now point to the correct routes (#5016).
  * Restored the previous usage-log filtering behavior to avoid regressions from the earlier filter change.

  #### Improvements

  * Channel tests now show clearer failure details when checks fail (#4988).
  * Reduced request-processing overhead to improve performance under load (#5009).

  ***

  ### What's Changed

  * fix\: expose param override audits for sensitive message fields by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4974](https\://github.com/QuantumNous/new-api/pull/4974)
  * fix\: respect dashboard content visibility settings by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4975](https\://github.com/QuantumNous/new-api/pull/4975)
  * fix\: filter perf metrics summary by active groups by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4976](https\://github.com/QuantumNous/new-api/pull/4976)
  * fix\: improve channel test failure details UX by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4988](https\://github.com/QuantumNous/new-api/pull/4988)
  * fix\: normalize model pricing display drift by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4985](https\://github.com/QuantumNous/new-api/pull/4985)
  * fix\: resolve model owned\_by from active channels by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4416](https\://github.com/QuantumNous/new-api/pull/4416)
  * perf\: optimize request metadata extraction and disabled field filtering by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5009](https\://github.com/QuantumNous/new-api/pull/5009)
  * fix\: update default frontend hardcoded route links by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5016](https\://github.com/QuantumNous/new-api/pull/5016)
  * Fix Turnstile verification not appearing on registration after switching to the new frontend by @JunXiaoRuo in [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * \[Feature Request] Waffo Pancake gateway — full integration with subscription support + admin catalog binding flow by @Hill-waffo in [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)
  * fix\: enforce Waffo subscription compliance and product ID update by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5038](https\://github.com/QuantumNous/new-api/pull/5038)

  ### New Contributors

  * @JunXiaoRuo made their first contribution in [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * @Hill-waffo made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-arm64-v1.0.0-rc.8) (82.4 MB)
  * [new-api-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8) (84.8 MB)
  * [new-api-v1.0.0-rc.8.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8.exe) (86.5 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.tar.gz)
</Callout>

***

## v1.0.0-rc.7

<Callout type="note" title="Stable Release · Published 2026-05-19 16:54:08 (China Time)">
  #### New Features

  * Added support for `request_header` key source (#4903).

  #### Bug Fixes

  * Batch fixed multiple UI issues in the default web interface (#4880, #4893, #4817, #4877, #4898, #4876).
  * Addressed an issue where channel remarks could not be cleared (#4886).
  * Corrected the filtering behavior for usage logs (#4883).
  * Fixed validation for unlimited API key quotas in the web interface (#4881).
  * Enforced access control on header navigation for public modules (#4889).
  * Applied group filters correctly to channel list queries (#4847, #4885).
  * Fixed an ambiguity issue with column names during `PerfMetric` upserts (#4684).
  * Added missing analytics placeholders to the default theme (#4928).
  * Fixed forgot password form submission by properly typing the button (#4910).
  * Normalized the layout of model detail tabs in the web interface (#4938).
  * Fixed user creation and deletion handling in the management panel (#4818).
  * Gated the sign-up link on the login page based on registration settings (#4871).
  * Updated pagination button labels in the ModelCardGrid (#4675).
  * Localized the reset password confirmation message (#4769).
  * Made recharge preset selections visible in dark mode (#4897).
  * Fixed an issue where the API info color dot showed the wrong color due to a semantic token mismatch (#4824).
  * Corrected silent failures when saving API info with invalid colors (#4823).
  * Used the correct `aff_code` field name in registration payloads (#4965).
  * Made the faceted filter popover width adaptive in data tables (#4966).
  * Resolved stale form linkage issues when submitting keys (#4967).

  #### Improvements

  * Improved performance by avoiding eager formatting in debug log calls (#4929).

  ***

  ### What's Changed

  * fix\: allow clearing channel remark by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4886](https\://github.com/QuantumNous/new-api/pull/4886)
  * fix\: correct usage logs filtering by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4883](https\://github.com/QuantumNous/new-api/pull/4883)
  * fix(web)\: handle unlimited API key quota validation by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4881](https\://github.com/QuantumNous/new-api/pull/4881)
  * fix\: enforce header nav access control for public modules by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4889](https\://github.com/QuantumNous/new-api/pull/4889)
  * fix\: GetAllChannels ignores group filter parameter by @draftgo in [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * fix\: qualify column names in PerfMetric upsert to avoid PG ambiguity by @SAY-5 in [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * fix\: apply group filter to channel list queries by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4885](https\://github.com/QuantumNous/new-api/pull/4885)
  * feat\: support request\_header key source by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4903](https\://github.com/QuantumNous/new-api/pull/4903)
  * fix\: Fix language and text display issues in the new UI by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/4876](https\://github.com/QuantumNous/new-api/pull/4876)
  * fix\: add umami & ga4 placeholder in index.html of default theme by @NitroRCr in [https\://github.com/QuantumNous/new-api/pull/4928](https\://github.com/QuantumNous/new-api/pull/4928)
  * perf\: avoid eager formatting in debug log calls by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4929](https\://github.com/QuantumNous/new-api/pull/4929)
  * fix\: add type="submit" to forgot password form button by @lihan3238 in [https\://github.com/QuantumNous/new-api/pull/4910](https\://github.com/QuantumNous/new-api/pull/4910)
  * fix(web)\: normalize model detail tabs layout by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4938](https\://github.com/QuantumNous/new-api/pull/4938)
  * fix(user)\: fix user create and delete handling in management panel by @bugmaker2 in [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * fix(auth)\: expose register\_enabled in /api/status and gate sign-up link on login page by @Gnonymous in [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * fix(web/default)\: clarify pagination button labels in ModelCardGrid by @ellisfan in [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * fix(auth)\: localize reset password confirmation by @neow021 in [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * fix(web/default/wallet)\: make recharge preset selection visible in dark mode by @xinnyu in [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)
  * fix(web/default)\: api-info color dot shows wrong color due to semantic token mismatch by @Micah-Zheng in [https\://github.com/QuantumNous/new-api/pull/4824](https\://github.com/QuantumNous/new-api/pull/4824)
  * fix(web/default)\: api-info save silently fails when color is invalid or result unchecked by @Micah-Zheng in [https\://github.com/QuantumNous/new-api/pull/4823](https\://github.com/QuantumNous/new-api/pull/4823)
  * fix(auth)\: use aff\_code field name in registration payload (#4945) by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4965](https\://github.com/QuantumNous/new-api/pull/4965)
  * fix(data-table)\: make faceted filter popover width adaptive (#4905) by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4966](https\://github.com/QuantumNous/new-api/pull/4966)
  * fix(keys)\: call submit handler directly to avoid stale form linkage (#4858) by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4967](https\://github.com/QuantumNous/new-api/pull/4967)

  ### New Contributors

  * @draftgo made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * @SAY-5 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * @bugmaker2 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * @Gnonymous made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * @ellisfan made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * @neow021 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * @xinnyu made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-arm64-v1.0.0-rc.7) (82.3 MB)
  * [new-api-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7) (84.6 MB)
  * [new-api-v1.0.0-rc.7.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7.exe) (86.3 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.tar.gz)
</Callout>

***

## v1.0.0-rc.6

<Callout type="note" title="Stable Release · Published 2026-05-13 22:29:13 (China Time)">
  ### Highlights

  This release improves observability by recording upstream request IDs in logs and adds a compliance confirmation step for paid features. If your `logs` table is large, pre-apply the `upstream_request_id` column and index with online DDL before upgrading to avoid a potentially long migration.

  ### New Features

  * Added upstream request ID tracking in request logs for easier upstream call tracing, while avoiding unintended response header overrides.
  * Added a compliance confirmation step before paid features can be used.

  ### Bug Fixes

  * Fixed the channel combobox so focusing it no longer hides valid channel options (#4829).

  ### Other

  * Upgrade notice\: the `logs` table now includes a new `upstream_request_id` column and index; on large installations, run the appropriate online DDL below before upgrading to avoid a long or blocking automatic migration.

  MySQL / InnoDB\:

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

  PostgreSQL 11+\:

  ```sql
  -- 1. Add the column without rewriting the table on PG 11+.
  ALTER TABLE logs
    ADD COLUMN IF NOT EXISTS upstream_request_id VARCHAR(128) NOT NULL DEFAULT '';

  -- 2. Add the index concurrently to avoid blocking reads and writes.
  CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_logs_upstream_request_id
    ON logs (upstream_request_id);
  ```

  ***

  ### What's Changed

  * chore(deps)\: bump axios from 1.15.0 to 1.15.2 in /web/classic by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/4634](https\://github.com/QuantumNous/new-api/pull/4634)
  * chore(deps-dev)\: bump ip-address from 10.1.0 to 10.2.0 in /electron by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/4811](https\://github.com/QuantumNous/new-api/pull/4811)
  * Fix incomplete channel list display by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4829](https\://github.com/QuantumNous/new-api/pull/4829)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-arm64-v1.0.0-rc.6) (82.3 MB)
  * [new-api-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6) (84.6 MB)
  * [new-api-v1.0.0-rc.6.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6.exe) (86.3 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.tar.gz)
</Callout>

***

## v1.0.0-rc.5

<Callout type="note" title="Stable Release · Published 2026-05-12 16:53:57 (China Time)">
  ### Highlights

  The default dashboard has been refreshed with built-in model performance metrics and a clearer health view. This release also adds DeepChat deeplink support and fixes several default UI, wallet, playground, and ratio-display regressions.

  ### New Features

  * Dashboard overview has been redesigned and now includes model performance metrics with a clearer performance health panel.
  * DeepChat deeplinks are now supported, making it easier to open supported chat links directly in DeepChat. (#4668)

  ### Bug Fixes

  * Top-up gateway availability now uses the correct top-up configuration, so wallet payment options are shown accurately. (#4599)
  * Group ratio displays now honor configured group-to-group ratio settings. (#4772)
  * Default UI dropdown menu items now trigger their selection handlers reliably. (#4787)
  * The playground now handles legacy classic-format messages without failing. (#4650)
  * Default frontend pages now avoid several v1 UI regressions, including stray empty description areas and layout issues. (#4802)

  ### Improvements

  * The default web UI and charts now follow shared theme presets for more consistent colors, controls, and corner radii.
  * Docker images now include project and third-party license notices for easier compliance review. (#4739)

  ***

  ### What's Changed

  * feat\: add DeepChat deeplink support by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4668](https\://github.com/QuantumNous/new-api/pull/4668)
  * fix\: exclude THIRD-PARTY-LICENSES.md from .dockerignore for Docker build by @yeying-xingchen in [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * fix(wallet)\: read topup gateway flags from topupInfo instead of status by @ImogeneOctaviap794 in [https\://github.com/QuantumNous/new-api/pull/4599](https\://github.com/QuantumNous/new-api/pull/4599)
  * fix(web/default)\: use getUserGroups for ratio display to respect GroupGroupRatio by @Micah-Zheng in [https\://github.com/QuantumNous/new-api/pull/4772](https\://github.com/QuantumNous/new-api/pull/4772)
  * fix(default)\: support DropdownMenuItem onSelect by @lihan3238 in [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)
  * fix(web/default)\: guard playground messages against legacy classic shape by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4650](https\://github.com/QuantumNous/new-api/pull/4650)
  * fix\: defaut ui triage by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4802](https\://github.com/QuantumNous/new-api/pull/4802)

  ### New Contributors

  * @yeying-xingchen made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * @lihan3238 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-arm64-v1.0.0-rc.5) (82.1 MB)
  * [new-api-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5) (84.5 MB)
  * [new-api-v1.0.0-rc.5.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5.exe) (86.2 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.tar.gz)
</Callout>

***

## v1.0.0-rc.4

<Callout type="note" title="Stable Release · Published 2026-05-06 22:25:59 (China Time)">
  ### Highlights

  OpenAI image editing is more reliable\: image edit requests now preserve reference image data and related metadata, preventing edits from losing their intended context (#4646). This release also adds model performance badges and fixes several billing and dropdown UI issues.

  ### New Features

  * Added model performance badges to model lists so users can compare available models at a glance.

  ### Bug Fixes

  * Fixed OpenAI image edit requests so reference images and related edit metadata are preserved when forwarded (#4646).
  * Fixed billing settings forms so top-up and billing configuration inputs behave more reliably.
  * Fixed dropdown and select controls so options render and select correctly after the UI component update (#4655).

  ### Breaking Changes

  * Integrations should now read the top-up link from the top-up information API instead of the status API.

  ### Gallery

  | Model availability rankings                                                                                           | Refreshed pricing and settings UI                                                                                     |
  | --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
  | ![Image from Gallery release notes](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Image from Gallery release notes](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### What's Changed

  * fix\: preserve OpenAI image edit reference fields by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4646](https\://github.com/QuantumNous/new-api/pull/4646)
  * fix\: migrate select to Base UI items API by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4655](https\://github.com/QuantumNous/new-api/pull/4655)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-arm64-v1.0.0-rc.4) (82.0 MB)
  * [new-api-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4) (84.4 MB)
  * [new-api-v1.0.0-rc.4.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4.exe) (86.1 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.tar.gz)
</Callout>

***

## v1.0.0-rc.3

<Callout type="note" title="Stable Release · Published 2026-05-06 18:43:33 (China Time)">
  ### Highlights

  v1.0.0-rc.3 adds a new model rankings experience with model availability and performance visibility, making it easier to compare reliability before choosing routes or providers. This release also refreshes key default UI areas, including pricing/settings pages and table controls.

  ### New Features

  * Added a model rankings dashboard with real availability and performance data so users can compare model reliability at a glance (#4633).

  ### Improvements

  * Refreshed the default web UI with Base UI components, updated theme presets, and cleaner table toolbar interactions (#4633).
  * Reorganized the system settings pricing interface to make pricing configuration easier to scan and manage.

  ### Bug Fixes

  * Fixed channel table sorting so server-side sorting now works correctly (#4600).
  * Corrected subscription payment information display in the default UI.

  ### Gallery

  | Model availability rankings                                                                                           | Refreshed pricing and settings UI                                                                                     |
  | --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
  | ![Image from Gallery release notes](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Image from Gallery release notes](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### What's Changed

  * feat(web/default)\: unified UI overhaul — Base UI migration, theme presets, rankings dashboard, and table toolbar refactor by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4633](https\://github.com/QuantumNous/new-api/pull/4633)
  * feat\: collect model performance metrics by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4635](https\://github.com/QuantumNous/new-api/pull/4635)
  * fix\: enable channel table server-side sorting by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4600](https\://github.com/QuantumNous/new-api/pull/4600)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-arm64-v1.0.0-rc.3) (81.9 MB)
  * [new-api-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3) (84.4 MB)
  * [new-api-v1.0.0-rc.3.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3.exe) (86.1 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.tar.gz)
</Callout>

***

## v1.0.0-rc.2

<Callout type="note" title="Stable Release · Published 2026-04-30 20:42:48 (China Time)">
  ### Highlights

  v1.0.0-rc.2 officially opens up switching between the new and classic frontend, making it easier to test the redesigned UI, compare workflows, and fall back instantly when needed. This RC also refreshes key console pages and fixes several web issues affecting email binding, tiered pricing, API key grouping, and custom Vertex base URLs.

  ### New Features

  * Added a built-in switch between the new and classic frontend, so teams can adopt the redesigned UI gradually without losing access to the previous workflow.

  ### Improvements

  * Refreshed the web console with redesigned pricing pages, more consistent dashboard and log controls, better table and analytics filtering, smoother navigation, and improved mobile responsiveness.

  ### Bug Fixes

  * Fixed email binding in the redesigned frontend so the action completes correctly (#4551).
  * Fixed tiered pricing number input behavior so editing values is more reliable (#4536).
  * Fixed tiered pricing display issues that could cause values and labels to appear incorrectly (#4530).
  * Fixed API key grouping in the default web theme so keys appear under the expected groups (#4548).
  * Fixed custom Vertex base URLs so requests route correctly when a gateway prefix is configured (#4200).

  ### Gallery

  | Refreshed pricing page                                                                                      | Dashboard and analytics controls                                                                                      |
  | ----------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
  | ![Refreshed pricing page](https\://github.com/user-attachments/assets/8d403155-27ac-407d-b0ae-8815034c66a7) | ![Dashboard and analytics controls](https\://github.com/user-attachments/assets/caa73f0a-13d2-47fc-ab7d-0ffb4e7b6194) |

  ### What's Changed

  * fix\: Fix API key grouping in the default theme by @Micah-Zheng in [https\://github.com/QuantumNous/new-api/pull/4548](https\://github.com/QuantumNous/new-api/pull/4548)
  * bug fix\: Fix email binding in the new frontend by @SHLE1 in [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)
  * fix\: improve tiered pricing number input editing by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4536](https\://github.com/QuantumNous/new-api/pull/4536)
  * fix(vertex)\: honor custom base\_url as gateway prefix by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4200](https\://github.com/QuantumNous/new-api/pull/4200)
  * fix(web)\: Fix tiered pricing display errors caused by Base64 decoding failures and mismatched tags by @wans10 in [https\://github.com/QuantumNous/new-api/pull/4530](https\://github.com/QuantumNous/new-api/pull/4530)

  ### New Contributors

  * @SHLE1 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-arm64-v1.0.0-rc.2) (76.5 MB)
  * [new-api-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2) (78.9 MB)
  * [new-api-v1.0.0-rc.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2.exe) (80.6 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.tar.gz)
</Callout>

***

## v1.0.0-rc.1

<Callout type="note" title="Stable Release · Published 2026-04-29 20:15:01 (China Time)">
  v1.0.0-rc.1 is the first release candidate for the upcoming 1.0 release, and its main focus is the brand-new v1 frontend rebuilt from the ground up for a cleaner, faster, and more capable admin experience.

  This RC refreshes the interface across navigation, configuration, analytics, and logs, making day-to-day management much easier as the project moves toward the final v1 launch.

  ![Image from v1.0.0-rc.1 release notes](https\://github.com/user-attachments/assets/f3f8ed32-e0c5-4cfb-94a3-da0f357b62ab)

  ### New Features

  * Introduced the rebuilt v1 frontend with modern navigation and layouts, a visual channel editor for parameter overrides, and easier access to system settings and theme switching (#4265).

  ### Improvements

  * Upgraded dashboards and charts with clearer model analytics, better data sorting, and more informative tooltips for easier usage analysis.
  * Improved usage logs with log type indicators, usernames and avatars, and cleaner tables that make activity easier to scan.
  * Polished shared layouts, tables, and form styling across the default frontend for a cleaner and more consistent experience.

  ### Bug Fixes

  * Fixed themes loaded from the database so the selected frontend theme now applies correctly at runtime (#4518).
  * Fixed forwarded requests so empty reasoning fields are preserved instead of being silently dropped (#4520).
  * Fixed required-field markers so forms more consistently show which inputs are mandatory (#4533).

  ***

  ### What's Changed

  * 🚀 feat\: launch v1.0 — next-generation frontend built from the ground up by @t0ng7u in [https\://github.com/QuantumNous/new-api/pull/4265](https\://github.com/QuantumNous/new-api/pull/4265)
  * fix\: Fix empty Message.ReasoningContent/Reasoning content being silently dropped during request forwarding by @heimoshuiyu in [https\://github.com/QuantumNous/new-api/pull/4520](https\://github.com/QuantumNous/new-api/pull/4520)
  * fix\: sync theme to runtime when loaded from database by @Micah-Zheng in [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  ### New Contributors

  * @Micah-Zheng made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-arm64-v1.0.0-rc.1) (76.4 MB)
  * [new-api-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1) (78.8 MB)
  * [new-api-v1.0.0-rc.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1.exe) (80.5 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.tar.gz)
</Callout>

***

## v1.0.0-alpha.1 - License boundary release

<Callout type="note" title="Prerelease · Published 2026-04-28 14:26:06 (China Time)">
  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1](https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1)

  **Downloads**

  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.tar.gz)
</Callout>

***

## v0.13.2

<Callout type="note" title="Stable Release · Published 2026-04-27 22:11:42 (China Time)">
  ### New Features

  * Model sync now detects upstream models more accurately, refreshes pricing automatically from provider pricing endpoints, shows removed upstream models in the fetch-models dialog, and keeps pricing available during sync delays (#4452).
  * User records now include account creation and last login timestamps for easier auditing and administration (#4450).
  * Added configurable model matching for Ali native Messages APIs, making it easier to route requests to compatible upstream models (#4468).

  ### Bug Fixes

  * Tool calls now accept raw JSON argument payloads, improving compatibility with providers that return tool arguments as JSON objects (#4469).
  * Configuration updates now handle JSON object fields more reliably, preventing some settings from being saved incorrectly.

  ### Improvements

  * Retry messages now clearly explain when a channel was skipped because affinity is disabled (#4453).

  ***

  ### What's Changed

  * fix(channel)\: load model mapping during upstream model checks by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4437](https\://github.com/QuantumNous/new-api/pull/4437)
  * feat\: sync upstream pricing from pricing endpoint by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4452](https\://github.com/QuantumNous/new-api/pull/4452)
  * fix\: clarify affinity disabled channel retry message by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4453](https\://github.com/QuantumNous/new-api/pull/4453)
  * feat\: configure native messages model matching for ali by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4468](https\://github.com/QuantumNous/new-api/pull/4468)
  * fix\: support raw JSON response tool arguments by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4469](https\://github.com/QuantumNous/new-api/pull/4469)
  * feat\: show removed upstream models in fetch models modal by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4470](https\://github.com/QuantumNous/new-api/pull/4470)
  * Add user creation time and last sign-in time by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4450](https\://github.com/QuantumNous/new-api/pull/4450)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2](https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.0.13.2.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.Setup.0.13.2.exe) (106.8 MB)
  * [new-api-arm64-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-arm64-v0.13.2) (64.6 MB)
  * [new-api-macos-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-macos-v0.13.2) (83.2 MB)
  * [new-api-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2) (67.0 MB)
  * [new-api-v0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2.exe) (68.6 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.tar.gz)
</Callout>

***

## v0.13.1-patch.1

<Callout type="note" title="Stable Release · Published 2026-04-25 13:27:23 (China Time)">
  ### Highlights

  This patch adds support for using `len` in tier conditions and the LLM prompt helper, making it easier to build rules based on prompt length.

  ### New Features

  * Added a `len` variable to tier conditions and the LLM prompt helper so you can define rules based on prompt length.

  ***

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-linux.txt) (186 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-macos.txt) (96 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-windows.txt) (94 B)
  * [new-api-arm64-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-arm64-v0.13.1-patch.1) (64.6 MB)
  * [new-api-macos-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-macos-v0.13.1-patch.1) (83.2 MB)
  * [new-api-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1) (66.9 MB)
  * [new-api-v0.13.1-patch.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1.exe) (68.6 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.tar.gz)
</Callout>

***

## v0.13.1

<Callout type="note" title="Stable Release · Published 2026-04-24 22:20:58 (China Time)">
  #### New Features

  * Added support for handling DeepSeek V4 reasoning suffixes (#4428)

  #### Bug Fixes

  * Fixed an issue where tiered billing models were excluded from the model listing (#4431)

  ***

  ### What's Changed

  * fix\: include tiered billing models in model listing by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4431](https\://github.com/QuantumNous/new-api/pull/4431)
  * feat\: implement DeepSeek V4 reasoning suffix handling and tests by @HynoR in [https\://github.com/QuantumNous/new-api/pull/4428](https\://github.com/QuantumNous/new-api/pull/4428)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1](https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.0.13.1.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.Setup.0.13.1.exe) (106.7 MB)
  * [new-api-arm64-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-arm64-v0.13.1) (64.6 MB)
  * [new-api-macos-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-macos-v0.13.1) (83.2 MB)
  * [new-api-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1) (66.9 MB)
  * [new-api-v0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1.exe) (68.6 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.tar.gz)
</Callout>

***

## v0.13.0

<Callout type="note" title="Stable Release · Published 2026-04-24 14:09:21 (China Time)">
  ### Highlights

  This release introduces powerful support for `expr` expression-based tiered billing, allowing administrators to configure complex, dynamic pricing rules. A simple use case for this feature is a pricing expression like `tokens <= 128000 ? 0.002 : 0.004`, where the system will automatically apply a lower rate for usage under 128K tokens and a higher rate for anything above that threshold.

  ### New Features

  * Introduces support for evaluating `expr` expressions in the billing system, enabling dynamic tiered pricing with configurable presets (#4409).
  * Adds a UI for tool pricing settings and improves tool call quota calculations.
  * Displays the user ID in admin top-up bills for easier tracking (#4349).
  * Adds a 'last used time' column to the tokens table (#4372).
  * Relaxes token key column length requirements to support the migration of longer legacy token keys (#4401).

  ### Bug Fixes

  * Ensures the pricing calculation logic only applies the N ratio to image models (#4412).
  * Preserves text tool surcharges properly during tiered billing settlement (#4162).
  * Corrects the completion ratio configuration for the `gpt-5.5` model (#4414).
  * Fixes the model pricing UI to use the correct display type (#4426).
  * Resolves runtime crashes and edge cases within the tiered pricing editor and settlement logic.
  * Updates channel testing to properly support and evaluate tiered billing models.

  ### Improvements

  * Adds preset pricing tiers for Doubao Seed 1.8 to enhance discount calculations.
  * Replaces Card components with divs to improve overall layout consistency.
  * Updates internal billing calculations to use quota per unit for better accuracy.

  ***

  ### What's Changed

  * fix(channel-test)\: support tiered billing model tests by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4145](https\://github.com/QuantumNous/new-api/pull/4145)
  * Show user IDs in administrator top-up billing records by @uskyu in [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * Add the last-used timestamp for tokens by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4372](https\://github.com/QuantumNous/new-api/pull/4372)
  * chore(deps)\: bump github.com/jackc/pgx/v5 from 5.9.0 to 5.9.2 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/4397](https\://github.com/QuantumNous/new-api/pull/4397)
  * chore(deps-dev)\: bump @xmldom/xmldom from 0.8.12 to 0.8.13 in /electron by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/4399](https\://github.com/QuantumNous/new-api/pull/4399)
  * Relax token key column length for legacy migration compatibility by @XiaoAI1024 in [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * fix(billing)\: preserve text tool surcharges in tiered settlement by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4162](https\://github.com/QuantumNous/new-api/pull/4162)
  * feat\: support for tiered billing expressions in the billing system by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4409](https\://github.com/QuantumNous/new-api/pull/4409)
  * fix(image)\: only price image model use N ratio by @xyfacai in [https\://github.com/QuantumNous/new-api/pull/4412](https\://github.com/QuantumNous/new-api/pull/4412)
  * fix\: correct gpt-5.5 completion ratio by @jingx8885 in [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)
  * fix\: model pricing use correct display type by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4426](https\://github.com/QuantumNous/new-api/pull/4426)

  ### New Contributors

  * @uskyu made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * @XiaoAI1024 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * @jingx8885 made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0](https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.0.13.0.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.Setup.0.13.0.exe) (106.8 MB)
  * [new-api-arm64-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-arm64-v0.13.0) (64.6 MB)
  * [new-api-macos-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-macos-v0.13.0) (83.2 MB)
  * [new-api-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0) (66.9 MB)
  * [new-api-v0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0.exe) (68.6 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.tar.gz)
</Callout>

***

## v0.12.15

<Callout type="note" title="Stable Release · Published 2026-04-22 23:04:03 (China Time)">
  #### New Features

  * Added Waffo Pay support for account top-ups and payment workflows (#4089).

  #### Bug Fixes

  * Fixed a recharge card issue in the top-up flow that could break parts of the card interface (#4388).

  #### Improvements

  * Added support for Gemini's `IncludeServerSideToolInvocations` setting in `ToolConfig`, improving compatibility with newer Gemini tool-calling behavior (#4311).
  * Improved Codex channel reliability and usability by refreshing credentials for auto-disabled channels, using streaming for automatic tests, and refining the usage modal (#4324).

  ***

  ### What's Changed

  * fix(gemini)\: add IncludeServerSideToolInvocations field to ToolConfig by @KoellM in [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * rafactor\: payment by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4089](https\://github.com/QuantumNous/new-api/pull/4089)
  * fix(topup)\: import missing Tag in recharge card by @gaoren002 in `#4388`
  * chore\: refine codex usage modal layout by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4386](https\://github.com/QuantumNous/new-api/pull/4386)
  * fix\: use stream for codex auto test by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4325](https\://github.com/QuantumNous/new-api/pull/4325)
  * fix\: refresh codex credentials for auto-disabled channels by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4324](https\://github.com/QuantumNous/new-api/pull/4324)
  * fix\: require proper verification for passkey changes by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4393](https\://github.com/QuantumNous/new-api/pull/4393)

  ### New Contributors

  * @KoellM made their first contribution in [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * @gaoren002 made their first contribution in `#4388`

  **Full Changelog**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15](https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15)

  **Downloads**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-linux.txt) (172 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-macos.txt) (89 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-windows.txt) (87 B)
  * [New-API-App.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.0.12.15.exe) (106.3 MB)
  * [New-API-App.Setup.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.Setup.0.12.15.exe) (106.6 MB)
  * [new-api-arm64-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-arm64-v0.12.15) (63.7 MB)
  * [new-api-macos-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-macos-v0.12.15) (82.0 MB)
  * [new-api-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15) (66.0 MB)
  * [new-api-v0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15.exe) (67.7 MB)
  * [Source code (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.zip)
  * [Source code (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.tar.gz)
</Callout>

***