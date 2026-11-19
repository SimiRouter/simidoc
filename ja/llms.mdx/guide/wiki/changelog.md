# 更新履歴

<Callout type="warn" title="バージョン履歴 · データ更新日時 2026-8-12 18:48:26">
  すべての履歴は [GitHub Releases ページ](https\://github.com/QuantumNous/new-api/releases)をご覧ください。本ページはリアルタイムのデータではなく、最終同期日時はこの注意書きのタイトルに表示されます。上流の公開が本ページより新しい場合は上流を優先してください。
</Callout>

## v1.0.0-rc.24

<Callout type="info" title="本ページの最新記録 · 2026-08-07 17:47:48 公開（中国時間）">
  ### リリース： v1.0.0-rc.24

  #### 新機能

  * アクセストークンと紹介報酬の移転ルートに、重要操作向けのレート制限ミドルウェアを追加し、安全性と安定性を向上しました。
  * チャネルで取得したモデルの分類を改善し、整理と検索を容易にしました。

  #### 不具合修正

  * 引き換えコードの残高精度が失われる問題を修正し、正しく残高を割り当てるようにしました（#6685）。
  * 中継で適切に設定するフィールドは `Request.GetBody` です。これにより、上流ストリームのリセット後に HTTP/2 トランスポートが透過的な再試行を行えない問題を修正しました（#6249）。
  * Claude と Gemini のエンドポイントをネイティブリクエスト形式でテストし、互換性を改善しました。

  #### その他

  * CI のリリース同期処理に任意のファイル同期機能を追加しました。

  ***

  ### 変更内容

  * fix(relay)\: Request.GetBody を設定し、上流ストリームのリセット後に HTTP/2 が透過的に再試行できるよう修正 by @BlockchainHe in [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * feat(channels)\: 取得したモデルの分類を改善 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6632](https\://github.com/QuantumNous/new-api/pull/6632)
  * fix\: Claude/Gemini エンドポイントをネイティブ形式でテスト by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6698](https\://github.com/QuantumNous/new-api/pull/6698)
  * fix\: 引き換えコードの残高精度低下を修正（#6680）by @lihu-001 in [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  ### 新規コントリビューター

  * @BlockchainHe の初回貢献：[https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * @lihu-001 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-arm64-v1.0.0-rc.24) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-macos-v1.0.0-rc.24) (132.6 MB)
  * [new-api-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24) (113.2 MB)
  * [new-api-v1.0.0-rc.24.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24.exe) (115.1 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.tar.gz)
</Callout>

***

## v1.0.0-rc.23

<Callout type="note" title="正式版 · 2026-08-01 23:25:04 公開（中国時間）">
  主な変更：New API チャネル、DeepSeek Responses API、zstd リクエスト展開、自動グループルーティングを追加し、プロバイダーとチャネルの互換性を拡大しました。ログのストリーム表示、段階的再試行の課金、クライアント切断時の Bedrock キャンセルも改善しました。

  ### 新機能

  * Gemini から OpenAI へのストリーミング変換、Advanced Custom Responses Compact 処理、multipart 画像編集を備えた New API チャネルを追加しました（#6559）。
  * DeepSeek Responses API に対応しました（#6562）。
  * リクエストルーティングの自動グループ選択を追加しました（#6590）。
  * チャネルごとの HTTP トランスポート制御を追加し、接続動作を調整できるようにしました。
  * zstd 圧縮リクエストに対応しました（#6545）。
  * ログの所有者が、リクエストがストリーミングだったか確認できるようになりました（#6558）。

  ### 不具合修正

  * Qwen `thinking_budget` を中継時に保持するようにしました（#5836）。
  * 段階的再試行の課金を、グループ切り替え再試行も含め、最終的に選択したグループで精算するようにしました（#6570）。
  * クライアント切断時に Bedrock リクエストをキャンセルし、不要な上流処理を減らしました（#6589）。

  ### 改善

  * 公開ヘッダーのナビゲーションリンクの文字サイズを統一しました（#6557）。

  ***

  ### 変更内容

  * refactor\: プロトコル変換層を独立した relaykit モジュールに抽出 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/6369](https\://github.com/QuantumNous/new-api/pull/6369)
  * fix\: 遅いクエリ／SQL エラーログをパラメーター化 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6493](https\://github.com/QuantumNous/new-api/pull/6493)
  * feat(oidc)\: OIDC ログインの表示名をカスタマイズ可能に by @mrchi in [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * fix\: Qwen thinking\_budget の透過転送を保持 by @wxwwt in [https\://github.com/QuantumNous/new-api/pull/5836](https\://github.com/QuantumNous/new-api/pull/5836)
  * feat\: zstd リクエスト展開に対応 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6545](https\://github.com/QuantumNous/new-api/pull/6545)
  * feat(logs)\: ログ所有者にストリーム状態を表示 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6558](https\://github.com/QuantumNous/new-api/pull/6558)
  * fix(relay)\: New API チャネルで multipart 画像編集を保持 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6559](https\://github.com/QuantumNous/new-api/pull/6559)
  * fix(oauth)\: 別オリジンの window\.opener を紐づけ処理と誤認しないよう修正 by @neimaravila in [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * style\: 公開ヘッダーリンクを 14px（text-sm）に統一 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6557](https\://github.com/QuantumNous/new-api/pull/6557)
  * feat\: DeepSeek Responses API に対応 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6562](https\://github.com/QuantumNous/new-api/pull/6562)
  * fix(billing)\: 段階的再試行を最終グループで精算 by @faithleysath in [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)
  * fix(billing)\: グループ切り替え再試行の課金を強化（#6518 の追補）by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/6570](https\://github.com/QuantumNous/new-api/pull/6570)
  * fix(aws)\: クライアント切断時に Bedrock リクエストをキャンセル by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/6589](https\://github.com/QuantumNous/new-api/pull/6589)
  * feat\: 自動グループ選択 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/6590](https\://github.com/QuantumNous/new-api/pull/6590)

  ### 新規コントリビューター

  * @mrchi の初回貢献：[https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * @neimaravila の初回貢献：[https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * @faithleysath の初回貢献：[https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-arm64-v1.0.0-rc.23) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-macos-v1.0.0-rc.23) (132.6 MB)
  * [new-api-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23) (113.2 MB)
  * [new-api-v1.0.0-rc.23.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23.exe) (115.0 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.tar.gz)
</Callout>

***

## v1.0.0-rc.22

<Callout type="note" title="正式版 · 2026-07-26 21:19:04 公開（中国時間）">
  上流モデル検出、新しい Gemini 画像モデル、設定可能な課金、Sub2API により、チャネルとモデルの管理機能を拡大しました。ストリーミング、料金、返金、ユーザー管理、管理画面の信頼性も改善しました。

  ### 新機能

  * Advanced Custom と Codex 互換の上流から、利用可能なモデルを検出できるようになりました（#6184）。
  * 最新の Gemini 画像 GA モデルに対応しました（#6371）。
  * Sub2API チャネルと alpha-search 課金を含む、設定可能なツール料金を追加しました。
  * OpenAI Realtime GA モデルに対応し、ルーティング互換性を改善しました（#6032）。

  ### 不具合修正

  * Responses から Chat へのストリーミング変換で、ツール呼び出しが重複しないよう修正しました（#6225）。
  * 既存名のモデルを作成しても、保存済み料金を消去しないよう修正しました（#6365）。
  * 未設定料金モデルの表示を、選択チャネルで利用可能なモデルに限定しました（#6126）。
  * 非常に大きいユーザー残高をオーバーフローせず処理するよう修正しました（#6134）。
  * ページ分割されたユーザー一覧でも正しく並べ替えられるよう修正しました（#6194）。
  * MiniMax モデルを正しい MiniMax プロバイダーに関連付けました（#6164）。
  * Playground のモデルグループ選択で、自動グループ一覧と長い選択肢を正しく処理するよう修正しました（#6163）。
  * タスク状態の並行更新で返金が重複しないよう修正しました（#6074）。
  * チャージ金額を編集中に完全に消去できるよう修正しました（#6473）。
  * チャネルのインライン優先度更新を安定させました（#6415）。

  ### 改善

  * 管理画面の JSON 編集を統一し、内容が隠れる UI の問題を修正しました（#6421）。
  * ユーザー検索にデバウンスを導入し、不要なリクエストを減らしました（#6474）。
  * プロキシ経由のチャネルリクエストの互換性と安定性を改善しました（#6157）。
  * 上流のエラーが不明確な場合、ログに代替の詳細情報を記録するよう改善しました（#6431）。

  ***

  ### 変更内容

  * fix\: 未設定料金タブにチャネル内のモデルだけを表示 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6126](https\://github.com/QuantumNous/new-api/pull/6126)
  * fix\: ユーザー完全削除時に認証情報も消去 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6168](https\://github.com/QuantumNous/new-api/pull/6168)
  * fix(users)\: 大きい残高のオーバーフローを防止 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6134](https\://github.com/QuantumNous/new-api/pull/6134)
  * fix\: MiniMax モデルのプロバイダー判定を修正 by @fux-dev in [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * fix\: ユーザー一覧をサーバー側でソートし、ページ内のみのソートを防止 by @DawnMoon1542 in [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * fix(data-table)\: 列切り替え時に表を即時更新 by @DawnMoon1542 in [https\://github.com/QuantumNous/new-api/pull/6253](https\://github.com/QuantumNous/new-api/pull/6253)
  * fix\: Responses から Chat への変換でツール呼び出しの重複を防止 by @nikuleo in [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * feat(channel)\: Codex 上流のモデル検出に対応 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6184](https\://github.com/QuantumNous/new-api/pull/6184)
  * feat\: Advanced Custom チャネルの上流モデル取得に対応 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5971](https\://github.com/QuantumNous/new-api/pull/5971)
  * refactor(auth)\: ダッシュボードのセッションをステートレストークンとセッション制御に置換 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/6329](https\://github.com/QuantumNous/new-api/pull/6329)
  * fix\: gpt-realtime の GA モデルへの中継で realtime beta 識別子を送信しないよう修正 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6032](https\://github.com/QuantumNous/new-api/pull/6032)
  * fix(playground)\: モデルグループ選択肢の過度な伸長を防止 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6120](https\://github.com/QuantumNous/new-api/pull/6120)
  * perf(data-table)\: 操作列の幅配分を最適化 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6135](https\://github.com/QuantumNous/new-api/pull/6135)
  * fix(web)\: 無制限 API Key の使用済み残高を表示 by @RedwindA in [https\://github.com/QuantumNous/new-api/pull/6224](https\://github.com/QuantumNous/new-api/pull/6224)
  * fix(channel)\: プロキシクライアントの互換性とキャッシュ寿命を改善 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/6157](https\://github.com/QuantumNous/new-api/pull/6157)
  * fix(playground)\: 自動グループのモデル一覧を修正 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6163](https\://github.com/QuantumNous/new-api/pull/6163)
  * fix\: CAS 状態更新で Suno タスクの重複返金を防止 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6074](https\://github.com/QuantumNous/new-api/pull/6074)
  * chore(github)\: Issue テンプレートを必須フォームへ移行 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6452](https\://github.com/QuantumNous/new-api/pull/6452)
  * fix(github)\: Issue フォームの表示を復元 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6454](https\://github.com/QuantumNous/new-api/pull/6454)
  * fix\: 上流エラー解析結果が空ならレスポンス本文を記録 by @bigsongeth in [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)
  * fix\: 同名モデル作成時に既存料金を消去しないよう修正 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6365](https\://github.com/QuantumNous/new-api/pull/6365)
  * fix(web/channel)\: インライン優先度更新を安定化 by @RedwindA in [https\://github.com/QuantumNous/new-api/pull/6415](https\://github.com/QuantumNous/new-api/pull/6415)
  * perf(json-editor)\: 管理画面の JSON 編集体験を統一 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6421](https\://github.com/QuantumNous/new-api/pull/6421)
  * feat\: gemini-3-pro-image と gemini-3.1-flash-image の GA モデルを追加 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6371](https\://github.com/QuantumNous/new-api/pull/6371)
  * feat\: OpenAI 互換プロトコルで Tencent TokenHub API Key に対応 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6232](https\://github.com/QuantumNous/new-api/pull/6232)
  * fix\: チャージ金額を完全消去可能に by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6473](https\://github.com/QuantumNous/new-api/pull/6473)
  * fix\: ユーザー検索入力をデバウンス by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6474](https\://github.com/QuantumNous/new-api/pull/6474)

  ### 新規コントリビューター

  * @fux-dev の初回貢献：[https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * @DawnMoon1542 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * @nikuleo の初回貢献：[https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * @bigsongeth の初回貢献：[https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-arm64-v1.0.0-rc.22) (109.9 MB)
  * [new-api-macos-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-macos-v1.0.0-rc.22) (132.4 MB)
  * [new-api-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22) (113.0 MB)
  * [new-api-v1.0.0-rc.22.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22.exe) (114.9 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.tar.gz)
</Callout>

***

## v1.0.0-rc.21

<Callout type="note" title="正式版 · 2026-07-11 23:01:26 公開（中国時間）">
  ### 主な変更

  主な変更は GPT-5.6 のキャッシュ書き込み課金です。OpenAI の `cache_write_tokens` をキャッシュ作成料金で課金し、キャッシュ済み／未キャッシュの入力 Token の計上を保護します。料金、Playground、チャネル表、課金・ログの信頼性も改善しました。

  ### 新機能

  * GPT-5.6 のキャッシュ書き込み課金に対応し、OpenAI の `cache_write_tokens` をキャッシュ作成料金で計上し、入力 Token のキャッシュ区分との整合性を保持します。
  * 料金ページにグループ別の動的計算を追加し、サンプル用の特殊グループを表示しないよう修正しました（#5906）。
  * モデル料金設定に未設定料金モデルのタブと状態・同期フィルターを追加しました（#6124）。
  * Playground にチャットと生成のパラメーターパネルを追加し、画面からモデル動作を調整できるようにしました（#6044）。
  * チャネル表の列幅を手動調整でき、変更後も利用可能な幅を満たすようにしました（#5948）。
  * ログにストリームの時間指標とタスク詳細を追加しました。
  * テキストプロトコル変換と Advanced Custom ルーティングを強化しました（#5825）。

  ### 不具合修正

  * ブラウザー翻訳が React の表示を破損しないよう修正しました（#5963）。
  * 大文字・小文字だけが異なるモデル名を、複数選択でも一貫して追加できるよう修正しました（#6061）。
  * 事前残高消費と画像ストリーム切断時の課金処理を改善しました。
  * 並行更新時のサブスクリプションリセットを安定させました（#6057）。
  * Codex Responses の透過転送フィールドを正しく同期するよう修正しました（#6018）。
  * Playground のモデル変更後に、選択一覧が同期するよう修正しました。
  * カスタムホームの iframe で、ユーザー操作による上位ナビゲーションを許可しました（#5955）。
  * デフォルトのチャネル接続設定で貼り付け動作を復元しました。

  ### 改善

  * 上流料金の同期表の読み込みと描画を効率化しました（#6092）。
  * 表のバッジ、料金配置、同期ダイアログ、デフォルトテーマを調整しました。
  * ワークスペース構成が異なる場合のフォント参照を修正しました。

  ***

  ### 変更内容

  * fix(web)\: ブラウザー翻訳による React ルートの変更を防止 by @cat0825 in [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)
  * feat(web)\: チャネル一覧の列幅を手動調整可能に by @zuiho-kai in [https\://github.com/QuantumNous/new-api/pull/5948](https\://github.com/QuantumNous/new-api/pull/5948)
  * fix(web)\: チャネル表を利用可能な幅に合わせる by @zuiho-kai in [https\://github.com/QuantumNous/new-api/pull/6031](https\://github.com/QuantumNous/new-api/pull/6031)
  * chore\: v1.0 公開コミットで復活した不要ファイルを削除 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6041](https\://github.com/QuantumNous/new-api/pull/6041)
  * fix\: サブスクリプションリセットで GORM v2 の行ロックを使用 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6057](https\://github.com/QuantumNous/new-api/pull/6057)
  * feat(playground)\: パラメーター設定パネルを追加 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6044](https\://github.com/QuantumNous/new-api/pull/6044)
  * fix\: 複数選択で大文字・小文字だけが異なるモデル名を追加可能に by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6061](https\://github.com/QuantumNous/new-api/pull/6061)
  * fix\: 料金ページへのサンプル用特殊グループの露出を防止 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5906](https\://github.com/QuantumNous/new-api/pull/5906)
  * perf(model-pricing)\: 上流料金同期表を最適化 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/6092](https\://github.com/QuantumNous/new-api/pull/6092)
  * fix(web)\: カスタムホーム iframe のユーザー操作による上位遷移を許可 by @Heykode in [https\://github.com/QuantumNous/new-api/pull/5955](https\://github.com/QuantumNous/new-api/pull/5955)
  * chore(deps)\: /electron の golang.org/x/crypto を 0.51.0 から 0.52.0 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/6096](https\://github.com/QuantumNous/new-api/pull/6096)
  * fix\: Codex Responses の透過転送フィールドを同期 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/6018](https\://github.com/QuantumNous/new-api/pull/6018)
  * feat\: テキストプロトコル変換と Advanced Custom ルーティングを強化 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5825](https\://github.com/QuantumNous/new-api/pull/5825)
  * feat\: モデル料金設定に未設定料金モデルのタブを追加 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/6124](https\://github.com/QuantumNous/new-api/pull/6124)

  ### 新規コントリビューター

  * @cat0825 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-arm64-v1.0.0-rc.21) (129.6 MB)
  * [new-api-macos-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-macos-v1.0.0-rc.21) (152.2 MB)
  * [new-api-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21) (132.8 MB)
  * [new-api-v1.0.0-rc.21.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21.exe) (134.6 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.tar.gz)
</Callout>

***

## v1.0.0-rc.20

<Callout type="note" title="正式版 · 2026-07-07 21:46:39 公開（中国時間）">
  ### 主な変更

  GPT-5.6 の料金と、管理者向けの古いインスタンス整理を追加しました。ウォレットの報酬移転、小数倍率など、残高・料金の境界条件も修正しました。

  ### 新機能

  * GPT-5.6 モデルの Token 料金に対応しました。
  * システム情報に古いインスタンスの整理操作を追加しました（#5953）。

  ### 不具合修正

  * ウォレットの報酬移転で、固定単位ではなく設定済みの残高単位を使用するよう修正しました（#5808）。
  * グループ倍率に、たとえば `0.05` のような小数値を通常どおり入力できるよう修正しました（#5995）。
  * 段階料金の事前消費でデフォルト Token 推定値を使用し、対象規則の残高計算を改善しました。

  ***

  ### 変更内容

  * fix\: グループ倍率 Ratio 入力の小数中間状態を保持し、0.05 が入力できない問題を修正 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5995](https\://github.com/QuantumNous/new-api/pull/5995)
  * feat(system-info)\: 古いインスタンスの整理操作を追加 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5953](https\://github.com/QuantumNous/new-api/pull/5953)
  * fix(wallet)\: 報酬移転で設定済みの残高単位を使用 by @A-Words in [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  ### 新規コントリビューター

  * @A-Words の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-arm64-v1.0.0-rc.20) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-macos-v1.0.0-rc.20) (151.7 MB)
  * [new-api-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20) (132.4 MB)
  * [new-api-v1.0.0-rc.20.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20.exe) (134.2 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.tar.gz)
</Callout>

***

## v1.0.0-rc.19-i18nfix.2

<Callout type="note" title="正式版 · 2026-07-07 14:06:07 公開（中国時間）">
  国際化エラーを修正

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-linux.txt) (200 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-macos.txt) (103 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-windows.txt) (101 B)
  * [new-api-arm64-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-arm64-v1.0.0-rc.19-i18nfix.2) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-macos-v1.0.0-rc.19-i18nfix.2) (151.7 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2) (132.4 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2.exe) (134.2 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.tar.gz)
</Callout>

***

## v1.0.0-rc.19

<Callout type="note" title="正式版 · 2026-07-07 13:19:27 公開（中国時間）">
  ### 新機能

  * 管理者がサブスクリプション残高をリセットし、飽和イベントを監査できるようになりました（#5952）。
  * 新 UI に繁体字中国語（zh-TW）を追加しました（#5942）。

  ### 不具合修正

  * 非常に大きい残高の課金計算を修正し、制限が正しく適用されるようにしました。

  ***

  ### 変更内容

  * 新 UI を zh-TW に翻訳 by @MeowTechOpenSource in [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)
  * feat(subscription)\: 管理者の残高リセット操作を追加 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5952](https\://github.com/QuantumNous/new-api/pull/5952)

  ### 新規コントリビューター

  * @MeowTechOpenSource の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-arm64-v1.0.0-rc.19) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-macos-v1.0.0-rc.19) (151.7 MB)
  * [new-api-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19) (132.4 MB)
  * [new-api-v1.0.0-rc.19.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19.exe) (134.2 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.tar.gz)
</Callout>

***

## v1.0.0-rc.18

<Callout type="note" title="正式版 · 2026-07-07 01:16:57 公開（中国時間）">
  数量検証を厳格化し、誤った残高計算を防ぐことで課金の信頼性を高めました。

  **不具合修正**

  * 無効な値や極端な値をより適切に処理するよう、課金数量の検証を改善しました。

  ***

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-arm64-v1.0.0-rc.18) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-macos-v1.0.0-rc.18) (151.4 MB)
  * [new-api-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18) (132.0 MB)
  * [new-api-v1.0.0-rc.18.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18.exe) (133.9 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.tar.gz)
</Callout>

***

## v1.0.0-rc.17

<Callout type="note" title="正式版 · 2026-07-06 22:37:46 公開（中国時間）">
  ### 主な変更

  チャネルテスト、引き換え管理、テーマ、各種 Web 操作を改善しました。使用量、classic のビルド、ストリーミング切断、残高と動画時間の計算も修正しました。

  ### 新機能

  * 引き換え管理に状態フィルターと整理操作を追加しました。
  * グループ倍率の編集で、表示制御を明確にし、JSON 入力処理を強化しました。
  * 引き換え失敗時のメッセージを明確にしました。

  ### 不具合修正

  * AI Elements でネストされた使用量を読み取り、Token 使用量を正しく表示するよう修正しました。
  * classic Web のビルド失敗を修正しました（#5892）。
  * Codex チャネルにフィールド透過転送の制御を正しく表示しました（#5902）。
  * ホームの iframe を選択したテーマと言語に同期しました（#5917）。
  * Shadow DOM 内のカスタム HTML がライト／ダークの変更に追従するよう修正しました（#5890）。
  * ログイン済みユーザーを登録ページからリダイレクトする処理を統一しました（#5910）。
  * クライアント切断後にストリームへ書き込み続けないよう修正しました（#5710）。
  * タスクの差額精算後の残高と Alibaba 動画時間の処理を修正しました（#5923）。
  * DNS 検索失敗時のビルド日時生成を修正しました（#5945）。

  ### 改善

  * チャネルとモデルのテスト画面をコンパクトにしました（#5886）。
  * 動的料金の詳細をログ詳細ダイアログと同じスタイルにしました（#5905）。
  * モバイルのユーザーカードの読みやすさと配置を改善しました。
  * 旧チャージ警告を明確にしました（#5855）。

  ***

  ### 変更内容

  * chore(deps-dev)\: /electron の tmp を 0.2.5 から 0.2.7 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5147](https\://github.com/QuantumNous/new-api/pull/5147)
  * chore(web)\: デフォルト Web の依存関係を更新 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5884](https\://github.com/QuantumNous/new-api/pull/5884)
  * perf(web)\: チャネルテスト画面の操作を改善 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5886](https\://github.com/QuantumNous/new-api/pull/5886)
  * fix(classic)\: classic Web のビルド失敗を修正 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5892](https\://github.com/QuantumNous/new-api/pull/5892)
  * fix(channels)\: Codex にフィールド透過転送の制御を表示 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5902](https\://github.com/QuantumNous/new-api/pull/5902)
  * fix\: 動的料金のスタイルをログ詳細と統一 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5905](https\://github.com/QuantumNous/new-api/pull/5905)
  * fix\: タスク差額精算後の quota と Alibaba 動画の長さを最適化 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5923](https\://github.com/QuantumNous/new-api/pull/5923)
  * fix(web)\: ホーム iframe のテーマと言語を同期 by @guoruqiang in [https\://github.com/QuantumNous/new-api/pull/5917](https\://github.com/QuantumNous/new-api/pull/5917)
  * fix(web)\: Shadow DOM 分離レンダリングでカスタム HTML のライト／ダークが反映されない問題を修正 by @olwater in [https\://github.com/QuantumNous/new-api/pull/5890](https\://github.com/QuantumNous/new-api/pull/5890)
  * fix(web)\: 登録ページにログイン済みリダイレクトガードを追加し、ログインページ／classic テーマと統一（#5908）by @Heykode in [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * feat\: 旧チャージ警告バナーを改善（#5851）by @Gravirei in [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)
  * fix\: クライアント切断後の古いストリーム書き込みを防止 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5710](https\://github.com/QuantumNous/new-api/pull/5710)
  * fix\: ビルド日時の DNS エラーを修正 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5945](https\://github.com/QuantumNous/new-api/pull/5945)

  ### 新規コントリビューター

  * @Heykode の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * @Gravirei の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-arm64-v1.0.0-rc.17) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-macos-v1.0.0-rc.17) (151.4 MB)
  * [new-api-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17) (132.0 MB)
  * [new-api-v1.0.0-rc.17.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17.exe) (133.8 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.tar.gz)
</Callout>

***

## v1.0.0-rc.16

<Callout type="note" title="正式版 · 2026-07-03 15:41:42 公開（中国時間）">
  **主な変更**

  Responses/Chat 互換性、Doubao Seedance 2.0、Wan2.7 i2v のメディア対応を拡大しました。Playground、チャネル管理、ページ状態保持、正常終了の処理も改善しました。

  **新機能**

  * Responses API から Chat への互換変換を追加しました（#5787）。
  * Doubao Seedance 2.0 に素材 API、解像度別課金、動画入力課金、4K 課金、新しいリクエスト項目を追加しました（#5824）。
  * Wan2.7 の画像から動画生成のメディアマッピングに対応しました（#4984）。
  * 正常終了に対応し、再起動時の応答中断とパネルキャッシュ消失を減らしました（#4258）。
  * チャネル管理の配置と Advanced Custom ルートエディターを改善しました。

  **不具合修正**

  * モデル切り替え時に段階料金の式エディターが更新されるよう修正しました（#5752）。
  * 非同期タスクの使用ログを開始元ノードに帰属させるよう修正しました（#5684）。
  * テーマ切り替え後に 404 ではなくホームへ移動するよう修正しました（#5612）。
  * 分離された HTML 表示も含め、カスタム HTML と Markdown のスタイルと余白を統一しました（#5795）。
  * 同じルートのタブ切り替えで、ダッシュボードの期間などがリセットされる問題を修正しました（#5796）。
  * 画面遷移後もチャネル状態フィルターを保持しました（#5863）。
  * Ollama の非ストリーミングのツール呼び出しを修正しました（#5865）。
  * Waffo の商品情報と Webhook 動作を修正しました（#5704）。

  **改善**

  * Playground のチャットと Markdown 表示を改善しました（#5217）。
  * 表の操作と破壊的操作の確認画面を簡素化しました（#5645）。
  * ClickHouse の LIKE ログ検索を改善しました。
  * フロントエンドのビルド処理を高速化しました（#5786）。

  ***

  ### 変更内容

  * chore(deps)\: /web/default の dompurify を 3.4.5 から 3.4.11 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5718](https\://github.com/QuantumNous/new-api/pull/5718)
  * fix(ci)\: リリース時に classic の依存関係をインストール by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5719](https\://github.com/QuantumNous/new-api/pull/5719)
  * perf(web)\: 表操作と破壊的操作ダイアログを簡素化 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5645](https\://github.com/QuantumNous/new-api/pull/5645)
  * fix\: Waffo 商品情報と Webhook SDK を更新 by @zhongyuanzhao-alt in [https\://github.com/QuantumNous/new-api/pull/5704](https\://github.com/QuantumNous/new-api/pull/5704)
  * fix(model-pricing)\: モデル切り替え時に段階式エディターを更新 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5752](https\://github.com/QuantumNous/new-api/pull/5752)
  * fix\: bun.lock を dompurify 3.4.11 と同期し固定ロックのビルドを修復 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5738](https\://github.com/QuantumNous/new-api/pull/5738)
  * fix(theme)\: フロントエンドのテーマ切り替え後にホームへ戻し、ルート 404 を回避 by @zhangzhichaolove in [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * fix(task)\: 非同期タスク使用ログを開始元ノードに帰属 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5684](https\://github.com/QuantumNous/new-api/pull/5684)
  * feat\: Casbin 管理者権限を追加 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5755](https\://github.com/QuantumNous/new-api/pull/5755)
  * feat(playground)\: チャットと Markdown 表示を改善 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5217](https\://github.com/QuantumNous/new-api/pull/5217)
  * fix(auth)\: パスワード検証の説明を統一 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5759](https\://github.com/QuantumNous/new-api/pull/5759)
  * fix(web)\: カスタム HTML と Markdown の表示を統一 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5760](https\://github.com/QuantumNous/new-api/pull/5760)
  * fix(openai)\: Chat から Responses への互換性を強化 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5772](https\://github.com/QuantumNous/new-api/pull/5772)
  * feat\: Responses から Chat に対応 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5787](https\://github.com/QuantumNous/new-api/pull/5787)
  * feat\: doubao-seedance-2-0-260128 の解像度別課金に対応 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5300](https\://github.com/QuantumNous/new-api/pull/5300)
  * feat\: Doubao Seedance 2.0 の safety\_identifier/priority と 4k 課金に対応 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5824](https\://github.com/QuantumNous/new-api/pull/5824)
  * fix(web)\: カスタム HTML のスタイル除去と余白の異常を修正 by @olwater in [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * feat\: Wan2.7 i2v のメディアマッピングに対応 by @wxwwt in [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * perf(web)\: Rsbuild と Tailwind のビルド処理を最適化 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5786](https\://github.com/QuantumNous/new-api/pull/5786)
  * fix(makefile)\: dev-web でデフォルト Web 開発サーバーのみ起動 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5794](https\://github.com/QuantumNous/new-api/pull/5794)
  * fix(web)\: 分離 HTML にアプリのスタイルを注入 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5860](https\://github.com/QuantumNous/new-api/pull/5860)
  * fix\: 同一ルートのタブ切り替えで状態を保持（期間リセットを修正）by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5796](https\://github.com/QuantumNous/new-api/pull/5796)
  * サービスの正常終了に対応し、再起動による応答中断とパネルのキャッシュ消失を防止 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4258](https\://github.com/QuantumNous/new-api/pull/4258)
  * fix\: デフォルトテーマの認証ガードで 401 のみ期限切れ扱いに by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5872](https\://github.com/QuantumNous/new-api/pull/5872)
  * fix\: 遷移後もチャネル状態フィルターを保持 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5863](https\://github.com/QuantumNous/new-api/pull/5863)
  * chore(deps)\: golang.org/x/net を 0.50.0 から 0.55.0 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5862](https\://github.com/QuantumNous/new-api/pull/5862)
  * chore(deps)\: golang.org/x/image を 0.38.0 から 0.41.0 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5873](https\://github.com/QuantumNous/new-api/pull/5873)
  * fix\: Ollama の非ストリーミングのツール呼び出しを処理 by @stevenjoezhang in [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  ### 新規コントリビューター

  * @zhangzhichaolove の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * @olwater の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * @wxwwt の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * @stevenjoezhang の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-arm64-v1.0.0-rc.16) (127.4 MB)
  * [new-api-macos-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-macos-v1.0.0-rc.16) (149.8 MB)
  * [new-api-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16) (130.5 MB)
  * [new-api-v1.0.0-rc.16.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16.exe) (132.3 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.tar.gz)
</Callout>

***

## v1.0.0-rc.15

<Callout type="note" title="正式版 · 2026-06-24 21:00:04 公開（中国時間）">
  ### 主な変更

  受動的なチャネル監視、ClickHouse ログ、システムタスク実行、インスタンス情報などの運用機能を追加しました。使用ログ、Markdown、チャネル選択、ウォレット UI の信頼性も改善しました。

  ### 新機能

  * 通信を能動的に妨げず状態を確認する受動的チャネル監視を追加しました（#5592）。
  * 大規模なログ保存・検索向けに ClickHouse 対応を追加しました（#5663）。
  * 長い保守処理の整理進捗を永続化するシステムタスク実行機能を追加しました（#5680）。
  * デプロイやノードの状態を確認するインスタンス情報パネルを追加しました（#5716）。
  * システム設定にユーザートークン制限を追加しました（#5678）。
  * チャネルテストに環境選択と非同期ポーリング間隔の設定を追加しました。
  * デフォルトのノード名は、`NODE_NAME` が未設定の場合にホスト名を使用します（#5659）。

  ### 不具合修正

  * 使用ログに CN モデルのプロバイダーアイコンを正しく表示しました（#5631）。
  * Stepfun の表示名を修正しました（#5636）。
  * SMTP の STARTTLS と NTLM 認証の互換性を修正しました（#5426）。
  * タイムゾーン日付処理に関する classic ビルド失敗を修正しました（#5676）。
  * Web UI の Markdown 表示と構文対応を拡大しました（#5689）。
  * チャネルカードの選択状態を実際の選択と同期しました（#5700）。
  * ウォレット無効時にプロフィールメニューの項目を非表示にしました（#5708）。

  ### 改善

  * ClickHouse とシステムタスク保守に合わせてログ整理を簡素化しました。

  ***

  ### 変更内容

  * fix(usage-logs)\: CN モデルのプロバイダーアイコンを classic と統一 by @DeliciousBuding in [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * fix\: StepFun を Stepfun に修正 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5636](https\://github.com/QuantumNous/new-api/pull/5636)
  * feat\: 受動的チャネル監視を追加 by @exherb in [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)
  * feat\: NODE\_NAME 未設定時はホスト名を使用 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5659](https\://github.com/QuantumNous/new-api/pull/5659)
  * feat\: ClickHouse ログ DB に対応 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5663](https\://github.com/QuantumNous/new-api/pull/5663)
  * fix\: SMTP STARTTLS と NTLM 認証に対応 by @bensonfx in [https\://github.com/QuantumNous/new-api/pull/5426](https\://github.com/QuantumNous/new-api/pull/5426)
  * chore(deps)\: github.com/ClickHouse/ch-go を 0.58.2 から 0.65.0 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5664](https\://github.com/QuantumNous/new-api/pull/5664)
  * fix\: date-fns-tz の classic ビルドエラーを修正 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5676](https\://github.com/QuantumNous/new-api/pull/5676)
  * feat\: システムタスク実行機能を追加 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5680](https\://github.com/QuantumNous/new-api/pull/5680)
  * feat\: システムインスタンス情報パネルを追加 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5716](https\://github.com/QuantumNous/new-api/pull/5716)
  * fix(web)\: Markdown レンダラーを置換し、構文対応を拡大 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5689](https\://github.com/QuantumNous/new-api/pull/5689)
  * fix(web)\: チャネルカードの選択状態を同期 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5700](https\://github.com/QuantumNous/new-api/pull/5700)
  * fix(web)\: ウォレット無効時にプロフィールの項目を非表示 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5708](https\://github.com/QuantumNous/new-api/pull/5708)
  * feat(system-settings)\: ユーザートークン制限を追加 by @RedwindA in [https\://github.com/QuantumNous/new-api/pull/5678](https\://github.com/QuantumNous/new-api/pull/5678)

  ### 新規コントリビューター

  * @DeliciousBuding の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * @exherb の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-arm64-v1.0.0-rc.15) (131.4 MB)
  * [new-api-macos-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-macos-v1.0.0-rc.15) (153.3 MB)
  * [new-api-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15) (134.2 MB)
  * [new-api-v1.0.0-rc.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15.exe) (136.0 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.tar.gz)
</Callout>

***

## v1.0.0-rc.14

<Callout type="note" title="正式版 · 2026-06-20 22:15:42 公開（中国時間）">
  ### 主な変更

  ダッシュボードに Token の経路と流れを可視化するサンキー図を追加しました。ハイライト、フィルター保持、大規模グラフの表示制限に対応します。チャネル管理のカード配置も高速化し、再描画を減らしました。

  ### 新機能

  * 管理者が Token の流れを確認できるサンキー図を追加しました（#5465）。
  * ルーティング動作の制御と可視化を行う信頼性管理を追加しました。

  ### 画面例

  | トラフィックのフロー図                                                                                           | チャネル管理のカード表示                                                                                     |
  | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
  | ![チャネル管理カードのレイアウト例](https\://github.com/user-attachments/assets/e0d82bd4-e052-4518-9fac-1144c0bd0721) | ![リリースノートの画面例](https\://github.com/user-attachments/assets/2ab5e6e6-f4f7-44f5-9abd-7191ed30e7aa) |

  ### 不具合修正

  * 新フロントエンドのログイン種別によるログ絞り込みを修正しました（#5620）。
  * 課金履歴のページネーションと一覧の重なりを修正しました（#5627）。
  * 料金一覧で項目を削除できない問題を修正しました（#5628）。
  * 再起動のたびに DB 列の移行が再実行される問題を修正しました（#5361、#5616）。

  ### 改善

  * チャネル管理カードの配置を改善し、不要な再描画を削減しました。
  * モデル一覧を整理し、確認と管理を容易にしました。
  * チャネルアイコンの表示を統一しました。

  ***

  ### 変更内容

  * fix\: 再起動時の allow\_balance\_pay 列の重複移行を防止 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5361](https\://github.com/QuantumNous/new-api/pull/5361)
  * fix\: 再起動時の allow\_wallet\_overflow 列の重複移行を防止 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5616](https\://github.com/QuantumNous/new-api/pull/5616)
  * feat(dashboard)\: token 流量を確認するサンキー図を追加。add traffic flow sankey chart by @Quaternijkon in [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)
  * fix(log)\: 新フロントエンドのログでログイン種別（type=7）の絞り込みが機能しない問題を修正 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5620](https\://github.com/QuantumNous/new-api/pull/5620)
  * fix(wallet)\: 課金履歴モーダルのページネーションと一覧の重なりを修正（#5624）by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5627](https\://github.com/QuantumNous/new-api/pull/5627)
  * fix(model-pricing)\: モデル料金一覧の項目を削除できない問題を修正（#5623）by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5628](https\://github.com/QuantumNous/new-api/pull/5628)

  ### 新規コントリビューター

  * @Quaternijkon の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-arm64-v1.0.0-rc.14) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-macos-v1.0.0-rc.14) (142.3 MB)
  * [new-api-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14) (125.4 MB)
  * [new-api-v1.0.0-rc.14.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14.exe) (127.1 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.tar.gz)
</Callout>

***

## v1.0.0-rc.13

<Callout type="note" title="正式版 · 2026-06-19 20:28:34 公開（中国時間）">
  v1.0.0-rc.13 は、チャネル管理やデータ量の多い画面の操作性を改善します。カード表示とモバイル配置を追加し、ログ、指標、エンドポイント、日付、使用量の UI を調整しました。

  ### 新機能

  * 表とカードの切り替えを追加し、画面サイズに合わせた閲覧を容易にしました。
  * 地域に応じた数値書式を追加しました。

  ### 改善

  * チャネルカードの左右構成と小画面の扱いを改善しました。
  * ログ、指標、エンドポイント選択、日付、ツールバー、モデルドロワーの UI を統一しました。
  * Codex 使用量画面の可読性と操作性を改善しました（#5595）。
  * ブラウザーへ戻った際の不要なデータ更新を減らしました。
  * フロントエンドのブランド文言と表示を統一しました。

  ### 不具合修正

  * 画像生成関連の時刻表示に、必要に応じてミリ秒を含めました。

  ***

  ### 変更内容

  * chore(web)\: デフォルトフロントエンドに oxc 品質検査を適用 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5585](https\://github.com/QuantumNous/new-api/pull/5585)
  * refactor\: Codex 使用量 UI を整理 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5595](https\://github.com/QuantumNous/new-api/pull/5595)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-arm64-v1.0.0-rc.13) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-macos-v1.0.0-rc.13) (142.2 MB)
  * [new-api-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13) (125.3 MB)
  * [new-api-v1.0.0-rc.13.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13.exe) (127.0 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.tar.gz)
</Callout>

***

## v1.0.0-rc.12

<Callout type="note" title="正式版 · 2026-06-18 20:34:16 公開（中国時間）">
  主な変更：AdvancedCustom チャネルによる柔軟なルーティング、一括モデルテスト、成功率・遅延を示すモデル市場の監視を追加しました。

  ### 新機能

  * ルート照合を改善した AdvancedCustom チャネルを追加しました（#5590）。
  * 一括モデルテストの実行、状態更新、結果表示、失敗モデル削除、選択モデルコピーを強化しました（#5532）。
  * モデル市場に稼働率、直近成功率、成功率ランク、遅延・スループットの簡潔な表示を追加しました。
  * 表のページ件数と列表示を、遷移やセッションをまたいで保持しました（#5403）。

  ### 不具合修正

  * ツール呼び出しで、空の `arguments` でも必要な `tool_use` ブロックを保持しました（#5543）。
  * CC Switch のモデル選択欄の表示と更新を修正しました（#5515）。
  * 一覧、表、使用ログ詳細、ホーム iframe の切り欠きやはみ出しを修正しました（#5510、#5536、#5533、#5545）。

  ### 改善

  * 支払い方法のボタン、アイコン、最低チャージ額の表示を改善しました。
  * 購入説明、残高超過、ダウングレードグループに関するプラン表示を改善しました。
  * 設定、初回ガイド、ウォレット／プロフィール、ログ統計カードの配置を改善しました。

  ### 互換性に影響する変更

  * サブスクリプションの商品選択肢とカタログのエンドポイントは `GET` を使用します。クライアントのリクエストメソッド更新が必要な場合があります。
  * ランキングの期間から「すべて」を削除しました。

  ***

  ### 変更内容

  * fix(web)\: 一覧セルの文字とバッジのはみ出しを防止 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5510](https\://github.com/QuantumNous/new-api/pull/5510)
  * fix(keys)\: API Key フォームの選択肢を更新 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5512](https\://github.com/QuantumNous/new-api/pull/5512)
  * fix\: CC Switch のモデル選択を修正 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5515](https\://github.com/QuantumNous/new-api/pull/5515)
  * fix(data-table)\: memo 比較に行選択状態を含める by @RedwindA in [https\://github.com/QuantumNous/new-api/pull/5524](https\://github.com/QuantumNous/new-api/pull/5524)
  * fix(channels)\: チャネルテスト画面の状態を更新 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5517](https\://github.com/QuantumNous/new-api/pull/5517)
  * fix\: カスタムホーム iframe の高さを復元 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5545](https\://github.com/QuantumNous/new-api/pull/5545)
  * fix(web)\: 使用ログ詳細の下部内容の切り欠きを防止 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5533](https\://github.com/QuantumNous/new-api/pull/5533)
  * fix\: AWS AK/SK のコンテキスト管理を修正 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5547](https\://github.com/QuantumNous/new-api/pull/5547)
  * test\: 報酬ハッキングにつながるバックエンドテストを整理 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5563](https\://github.com/QuantumNous/new-api/pull/5563)
  * fix\: ツール呼び出しの arguments が空でも tool\_use ブロックを保持 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5543](https\://github.com/QuantumNous/new-api/pull/5543)
  * fix\: チャネルモデルの一括テストを完成 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5532](https\://github.com/QuantumNous/new-api/pull/5532)
  * feat\: 表のページ件数を永続化し、画面遷移／セッションをまたいで保持（#5377）by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5403](https\://github.com/QuantumNous/new-api/pull/5403)
  * fix(data-table)\: セル内コンポーネントの切り欠きを防止 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5536](https\://github.com/QuantumNous/new-api/pull/5536)
  * fix(oauth)\: ユーザー完全削除時に紐づけを消去 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5582](https\://github.com/QuantumNous/new-api/pull/5582)
  * feat\: Advanced Custom チャネルを追加 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5590](https\://github.com/QuantumNous/new-api/pull/5590)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-arm64-v1.0.0-rc.12) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-macos-v1.0.0-rc.12) (142.1 MB)
  * [new-api-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12) (125.3 MB)
  * [new-api-v1.0.0-rc.12.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12.exe) (127.0 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.tar.gz)
</Callout>

***

## v1.0.0-rc.11

<Callout type="note" title="正式版 · 2026-06-13 16:15:40 公開（中国時間）">
  主な変更：Claude Opus 4.8 と OpenAI 画像 API の互換性を追加・改善し、モデル料金エディターと大規模な表の操作性を高めました。UI、残高表示、中継、プロバイダー固有の問題も修正しました。

  ### 新機能

  * Claude Opus 4.8 に対応しました（#5177）。
  * チャネル無効化時にスティッキー状態を解除するか選べるようにしました（#5306）。
  * サブスクリプション残高引き換えの切り替えを追加しました。
  * プロフィールにユーザー ID を表示しました（#5317）。
  * OpenAI Images API のストリーミング中継と画像編集に対応しました（#4608）。

  ### 不具合修正

  * フォーム送信後、最初の検証エラーにフォーカスするよう改善しました（#5163）。
  * cc-switch の独自名がフォーカスを失うとリセットされる問題を修正しました（#5170）。
  * 料金表示でカスタムモデルアイコンが同期しない問題を修正しました（#5224）。
  * 高度なチャネル検証エラーを表示し、無関係な設定を展開しないよう修正しました（#5239）。
  * 通貨換算で単位と残高値の両方を更新するよう修正しました（#5296）。
  * Dify のファイル型リクエストでリモート画像の処理を修正しました（#5134）。
  * 動画生成タスク照会のモデル解決を修正しました（#5133）。
  * Anthropic 互換の GLM 中継動作を改善しました（#5307）。
  * OpenAI o シリーズの適用範囲を限定しました（#5293）。
  * 複数選択のポップオーバーが現在のテーマに従うよう修正しました（#5328）。
  * Kimi K2.6 の temperature 正規化を修正しました（#5390）。
  * 削除済みユーザーの状態フィルターを追加しました（#5464）。
  * デプロイ設定をデプロイページでのみ取得するよう修正しました（#5466）。

  ### 改善

  * 管理ログと一括更新の性能を改善しました（#5116）。
  * モデル料金エディターの配置、下書き保存、再利用可能な JSON 編集、小数 6 桁の刻みを改善しました（#5275）。
  * チャネル検索にデバウンスと IME 入力処理を追加しました（#5393）。
  * 表の描画、固定列、配置、バッジを改善しました（#5405）。
  * ダイアログのサイズとフッター配置を改善しました（#5346）。
  * 公開ページのヒーロー文言を簡潔にしました（#5339）。

  ***

  ### 変更内容

  * fix(web)\: フォーム検証エラーへのフォーカスを改善 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5163](https\://github.com/QuantumNous/new-api/pull/5163)
  * feat(keys/cc-switch-dialog)\: カスタム cc-switch 名がフォーカスを失うとリセットされる問題を修正 by @GnezIew in [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * fix(model)\: idx\_created\_at\_id の列順を (created\_at, id) に修正 by @realRoc in [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * perf\: 管理ログを created\_at 順にし複合インデックスを使用 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5116](https\://github.com/QuantumNous/new-api/pull/5116)
  * chore(deps)\: /web/classic の axios を 1.15.2 から 1.16.0 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/5185](https\://github.com/QuantumNous/new-api/pull/5185)
  * feat\: claude-opus-4-8 に対応 by @hjxwz123 in [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * fix(pricing)\: カスタムモデルアイコンを同期 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5224](https\://github.com/QuantumNous/new-api/pull/5224)
  * chore(web)\: 共通依存関係のバージョンを集約 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5227](https\://github.com/QuantumNous/new-api/pull/5227)
  * feat(web)\: classic の Rsbuild 開発とビルドに対応 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5232](https\://github.com/QuantumNous/new-api/pull/5232)
  * fix(channels)\: 高度な検証エラーを表示 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5239](https\://github.com/QuantumNous/new-api/pull/5239)
  * docs\: Issue テンプレートを改善 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5271](https\://github.com/QuantumNous/new-api/pull/5271)
  * fix\: 残高表示で単位だけが切り替わり数値が変わらない問題を修正 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/5296](https\://github.com/QuantumNous/new-api/pull/5296)
  * fix(dify)\: リモート画像の割り当て前にファイルポインターを初期化 by @Pluviobyte in [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * fix(distributor)\: GET /v1/video/generations/\:task\_id のモデルを解決 by @Pluviobyte in [https\://github.com/QuantumNous/new-api/pull/5133](https\://github.com/QuantumNous/new-api/pull/5133)
  * fix\: 中継のアイドル接続タイムアウト設定を追加 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5309](https\://github.com/QuantumNous/new-api/pull/5309)
  * feat\: チャネル無効化後にチャネルのスティッキー状態を解除するか設定可能に by @GuangYiDing in [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * fix(relay)\: チャンク転送を避け GLM の Anthropic 互換性を修正 by @Chen011214 in [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * fix\: 匿名リクエストの本体サイズを制限 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5244](https\://github.com/QuantumNous/new-api/pull/5244)
  * fix(i18n)\: 思考アダプターの説明を明確化 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5242](https\://github.com/QuantumNous/new-api/pull/5242)
  * fix\: OpenAI o シリーズのモデル適用範囲を限定 by @USER-HFC in [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * fix\: チャネルハンドラーでストリームスキャナーのバッファを再利用 by @xujiantop-crypto in [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * feat(web)\: プロフィールにユーザー ID を表示 by @P2K0 in [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * perf(model-pricing)\: 料金エディターの操作性を改善 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5275](https\://github.com/QuantumNous/new-api/pull/5275)
  * perf(web)\: 公開ページのヒーロー文言を簡素化 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5339](https\://github.com/QuantumNous/new-api/pull/5339)
  * perf(web)\: ダイアログの配置とサイズを改善 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5346](https\://github.com/QuantumNous/new-api/pull/5346)
  * fix\: 複数選択ポップオーバーでテーマを反映 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5328](https\://github.com/QuantumNous/new-api/pull/5328)
  * fix\: モバイルの使用ログ課金バッジを整列 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5161](https\://github.com/QuantumNous/new-api/pull/5161)
  * fix\: 料金エディターで小数 6 桁の刻みに対応 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5332](https\://github.com/QuantumNous/new-api/pull/5332)
  * fix(openai)\: Images API のストリーミング中継と編集に対応 by @gaoren002 in `#4608`
  * perf(web)\: チャネル検索をデバウンスし IME 変換中は停止 by @QAbot-zh in [https\://github.com/QuantumNous/new-api/pull/5393](https\://github.com/QuantumNous/new-api/pull/5393)
  * fix\: Kimi K2.6 の temperature を正規化 by @bensonfx in [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)
  * perf(web)\: 表の描画と固定列の UI を改善 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5405](https\://github.com/QuantumNous/new-api/pull/5405)
  * perf(data-table)\: 表の配置とバッジ表示を改善 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/5460](https\://github.com/QuantumNous/new-api/pull/5460)
  * feat(audit)\: ローカライズされたセキュリティ監査ログを追加 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/5462](https\://github.com/QuantumNous/new-api/pull/5462)
  * chore\: Codex チャネルを更新 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5461](https\://github.com/QuantumNous/new-api/pull/5461)
  * fix\: 削除済みユーザーの状態フィルターを追加 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5464](https\://github.com/QuantumNous/new-api/pull/5464)
  * fix\: デプロイページでのみ設定を取得 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5466](https\://github.com/QuantumNous/new-api/pull/5466)

  ### 新規コントリビューター

  * @GnezIew の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * @realRoc の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * @hjxwz123 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * @Pluviobyte の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * @GuangYiDing の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * @Chen011214 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * @USER-HFC の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * @xujiantop-crypto の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * @P2K0 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * @bensonfx の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-arm64-v1.0.0-rc.11) (84.8 MB)
  * [new-api-macos-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-macos-v1.0.0-rc.11) (103.8 MB)
  * [new-api-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11) (87.2 MB)
  * [new-api-v1.0.0-rc.11.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11.exe) (88.9 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.tar.gz)
</Callout>

***

## v1.0.0-rc.10

<Callout type="note" title="正式版 · 2026-05-26 22:20:13 公開（中国時間）">
  ### 主な変更

  v1.0.0-rc.10 は UI、中継の信頼性、管理作業を改善します。テーマと残高によるプラン購入を追加し、ログ、チャネル、Webhook、支払い、ツール呼び出しを強化しました。

  ### 新機能

  * Anthropic と Simple Large のプリセット、セリフ体設定、特大スケールを追加しました。
  * サブスクリプションを残高で購入できるようになりました。

  ### 不具合修正

  * 自動無効化チャネルを新規リクエストに選ばず、操作通知の重複も防止しました（#4983）。
  * 並行呼び出しを含め、Gemini と Claude 間のツール中継を安定化しました（#5095）。
  * 画像中継に要求した品質設定を正しく適用しました（#5103）。
  * ワイルドカード明示時以外は使用ログを完全一致で検索し、巨大な上流エラーは短縮しました（#5097）。
  * Webhook 処理の信頼性を改善しました（#5047）。
  * Waffo 支払い設定の保存を安定させ、旧項目を非表示にしました（#5110）。
  * システム設定の未保存変更検出と数値入力を修正しました。

  ### 改善

  * 大きなメディア中継のメモリー消費を削減しました。
  * システム設定とチャネル作成・編集画面をコンパクトに整理しました。
  * モバイルの使用ログ、表の余白、バッジ、図、ダーク表示の可読性を改善しました。
  * ホームのヒーローを 2 列配置にし、文言を更新しました。

  ***

  ### 変更内容

  * 🐛 fix(channel)\: 自動無効化された複数 Key チャネルをキャッシュから除去 by @t0ng7u in [https\://github.com/QuantumNous/new-api/pull/4983](https\://github.com/QuantumNous/new-api/pull/4983)
  * \[BugFix] Webhook 処理を修正 by @Hill-waffo in [https\://github.com/QuantumNous/new-api/pull/5047](https\://github.com/QuantumNous/new-api/pull/5047)
  * fix(payment)\: 旧 Waffo Pancake 設定を非表示 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5085](https\://github.com/QuantumNous/new-api/pull/5085)
  * fix(relay)\: 画像品質パラメーターの処理を修正 by @lanfunoe in [https\://github.com/QuantumNous/new-api/pull/5103](https\://github.com/QuantumNous/new-api/pull/5103)
  * fix\: 巨大な上流エラーログを短縮 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5083](https\://github.com/QuantumNous/new-api/pull/5083)
  * fix\: fcIdx の -1 オフセットを除去し、並行ツール呼び出しのキー衝突を修正 by @learner-i in [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)
  * fix\: Gemini から Claude への tool\_use エラーを修正 by @nekohy in [https\://github.com/QuantumNous/new-api/pull/5041](https\://github.com/QuantumNous/new-api/pull/5041)
  * fix\: ページ分割された API Key 検索結果を処理 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5014](https\://github.com/QuantumNous/new-api/pull/5014)
  * fix\: チャネル操作通知の重複を防止 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5015](https\://github.com/QuantumNous/new-api/pull/5015)
  * fix\: Waffo 支払い設定の保存を統合 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5110](https\://github.com/QuantumNous/new-api/pull/5110)
  * fix\: チャネルテストで実ユーザー ID を使用 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5109](https\://github.com/QuantumNous/new-api/pull/5109)
  * fix\: ワイルドカード明示時以外は使用ログを完全一致で検索 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5097](https\://github.com/QuantumNous/new-api/pull/5097)

  ### 新規コントリビューター

  * @learner-i の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-linux.txt) (180 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-arm64-v1.0.0-rc.10) (82.8 MB)
  * [new-api-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10) (85.3 MB)
  * [new-api-v1.0.0-rc.10.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10.exe) (86.9 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.tar.gz)
</Callout>

***

## v1.0.0-rc.8

<Callout type="note" title="正式版 · 2026-05-22 16:25:46 公開（中国時間）">
  #### 主な変更

  管理者によるカタログ・商品紐づけを備えた Waffo Pancake を追加しました。管理 API、モデル情報、料金、テスト診断、ダッシュボード、リクエスト処理も改善しました。

  #### 新機能

  * サブスクリプションと管理者カタログ・商品紐づけを備えた Waffo Pancake を追加しました（#4935）。

  #### 不具合修正

  * ダッシュボードの内容を設定済みの表示制御に合わせました（#4975）。
  * 性能指標の集計を有効グループに限定しました（#4976）。
  * 料金表示を正規化して不一致を防止しました（#4985）。
  * 有効チャネルからモデル所有者情報を解決しました（#4416）。
  * デフォルトフロントエンドのリンク先を修正しました（#5016）。
  * 以前の使用ログ検索動作を復元し、変更による回帰を防止しました。

  #### 改善

  * チャネルテストの失敗理由を明確にしました（#4988）。
  * リクエスト処理の負荷を削減しました（#5009）。

  ***

  ### 変更内容

  * fix\: 機密メッセージ項目のパラメーター上書き監査を表示 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4974](https\://github.com/QuantumNous/new-api/pull/4974)
  * fix\: ダッシュボード内容の表示設定を反映 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4975](https\://github.com/QuantumNous/new-api/pull/4975)
  * fix\: 性能指標集計を有効グループに限定 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4976](https\://github.com/QuantumNous/new-api/pull/4976)
  * fix\: チャネルテスト失敗詳細の操作性を改善 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4988](https\://github.com/QuantumNous/new-api/pull/4988)
  * fix\: モデル料金の表示ずれを正規化 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4985](https\://github.com/QuantumNous/new-api/pull/4985)
  * fix\: 有効チャネルからモデルの owned\_by を解決 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4416](https\://github.com/QuantumNous/new-api/pull/4416)
  * perf\: リクエストメタデータ取得と無効フィールド除去を最適化 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5009](https\://github.com/QuantumNous/new-api/pull/5009)
  * fix\: デフォルトフロントエンドの固定ルートリンクを更新 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/5016](https\://github.com/QuantumNous/new-api/pull/5016)
  * 新フロントエンドへの切り替えで Turnstile 有効時に登録ページの認証が表示されない問題を修正 by @JunXiaoRuo in [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * \[Feature Request] Waffo Pancake にサブスクリプションと管理者カタログ紐づけを統合 by @Hill-waffo in [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)
  * fix\: Waffo サブスクリプションの要件と商品 ID 更新を適用 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/5038](https\://github.com/QuantumNous/new-api/pull/5038)

  ### 新規コントリビューター

  * @JunXiaoRuo の初回貢献：[https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * @Hill-waffo の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-arm64-v1.0.0-rc.8) (82.4 MB)
  * [new-api-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8) (84.8 MB)
  * [new-api-v1.0.0-rc.8.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8.exe) (86.5 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.tar.gz)
</Callout>

***

## v1.0.0-rc.7

<Callout type="note" title="正式版 · 2026-05-19 16:54:08 公開（中国時間）">
  #### 新機能

  * 対応を追加した項目は `request_header` の Key ソースです（#4903）。

  #### 不具合修正

  * デフォルト Web UI の複数の問題を修正しました（#4880、#4893、#4817、#4877、#4898、#4876）。
  * チャネルの備考を消去できない問題を修正しました（#4886）。
  * 使用ログのフィルター動作を修正しました（#4883）。
  * 無制限 API Key の残高検証を修正しました（#4881）。
  * 公開モジュールのヘッダーナビゲーションにアクセス制御を適用しました（#4889）。
  * チャネル一覧にグループフィルターを適用しました（#4847、#4885）。
  * 列名の曖昧さが生じる処理を修正：`PerfMetric` upserts (#4684).
  * デフォルトテーマに不足していた解析用プレースホルダーを追加しました（#4928）。
  * パスワード再設定フォームのボタン型を修正しました（#4910）。
  * モデル詳細タブの配置を統一しました（#4938）。
  * 管理画面のユーザー作成・削除を修正しました（#4818）。
  * 登録設定に応じてログインページの登録リンクを制御しました（#4871）。
  * ModelCardGrid のページ送りボタンの文言を更新しました（#4675）。
  * パスワード再設定の確認メッセージを翻訳しました（#4769）。
  * ダークモードでチャージ定額選択を見やすくしました（#4897）。
  * 意味的な色トークンの不一致による API 情報の点の色を修正しました（#4824）。
  * 無効な色で API 情報を保存した際の無通知失敗を修正しました（#4823）。
  * 登録ペイロードで正しい `aff_code` フィールド名を使用しました（#4965）。
  * 表の複合フィルターポップオーバーの幅を適応化しました（#4966）。
  * Key 送信時の古いフォーム紐づけを修正しました（#4967）。

  #### 改善

  * デバッグログの不要な事前整形を避け、性能を改善しました（#4929）。

  ***

  ### 変更内容

  * fix\: チャネル備考を消去可能に by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4886](https\://github.com/QuantumNous/new-api/pull/4886)
  * fix\: 使用ログの絞り込みを修正 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4883](https\://github.com/QuantumNous/new-api/pull/4883)
  * fix(web)\: 無制限 API Key の残高検証を処理 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4881](https\://github.com/QuantumNous/new-api/pull/4881)
  * fix\: 公開モジュールのヘッダーナビゲーションにアクセス制御 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4889](https\://github.com/QuantumNous/new-api/pull/4889)
  * fix\: GetAllChannels のグループフィルター無視を修正 by @draftgo in [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * fix\: PerfMetric upsert の列名を修飾し PostgreSQL の曖昧さを防止 by @SAY-5 in [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * fix\: チャネル一覧にグループフィルターを適用 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4885](https\://github.com/QuantumNous/new-api/pull/4885)
  * feat\: request\_header Key ソースに対応 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4903](https\://github.com/QuantumNous/new-api/pull/4903)
  * fix\: 新 UI の言語と文言表示の問題を修正 by @QuentinHsu in [https\://github.com/QuantumNous/new-api/pull/4876](https\://github.com/QuantumNous/new-api/pull/4876)
  * fix\: デフォルトテーマの index.html に umami と ga4 のプレースホルダーを追加 by @NitroRCr in [https\://github.com/QuantumNous/new-api/pull/4928](https\://github.com/QuantumNous/new-api/pull/4928)
  * perf\: デバッグログの不要な事前整形を回避 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4929](https\://github.com/QuantumNous/new-api/pull/4929)
  * fix\: パスワード再設定ボタンに type="submit" を追加 by @lihan3238 in [https\://github.com/QuantumNous/new-api/pull/4910](https\://github.com/QuantumNous/new-api/pull/4910)
  * fix(web)\: モデル詳細タブの配置を統一 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4938](https\://github.com/QuantumNous/new-api/pull/4938)
  * fix(user)\: 管理画面のユーザー作成・削除を修正 by @bugmaker2 in [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * fix(auth)\: /api/status に register\_enabled を公開し登録リンクを制御 by @Gnonymous in [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * fix(web/default)\: ModelCardGrid のページ送り文言を明確化 by @ellisfan in [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * fix(auth)\: パスワード再設定の確認を翻訳 by @neow021 in [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * fix(web/default/wallet)\: ダーク時のチャージ定額選択を可視化 by @xinnyu in [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)
  * fix(web/default)\: 意味トークン不一致による API 情報の点の色を修正 by @Micah-Zheng in [https\://github.com/QuantumNous/new-api/pull/4824](https\://github.com/QuantumNous/new-api/pull/4824)
  * fix(web/default)\: 無効な色や未確認結果による無通知の保存失敗を修正 by @Micah-Zheng in [https\://github.com/QuantumNous/new-api/pull/4823](https\://github.com/QuantumNous/new-api/pull/4823)
  * fix(auth)\: 登録ペイロードに aff\_code を使用（#4945）by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4965](https\://github.com/QuantumNous/new-api/pull/4965)
  * fix(data-table)\: 複合フィルターの幅を適応化（#4905）by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4966](https\://github.com/QuantumNous/new-api/pull/4966)
  * fix(keys)\: 送信ハンドラーを直接呼び、古いフォーム紐づけを回避（#4858）by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4967](https\://github.com/QuantumNous/new-api/pull/4967)

  ### 新規コントリビューター

  * @draftgo の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * @SAY-5 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * @bugmaker2 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * @Gnonymous の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * @ellisfan の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * @neow021 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * @xinnyu の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-arm64-v1.0.0-rc.7) (82.3 MB)
  * [new-api-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7) (84.6 MB)
  * [new-api-v1.0.0-rc.7.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7.exe) (86.3 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.tar.gz)
</Callout>

***

## v1.0.0-rc.6

<Callout type="note" title="正式版 · 2026-05-13 22:29:13 公開（中国時間）">
  ### 主な変更

  上流リクエスト ID のログ記録と有料機能のコンプライアンス確認を追加しました。`logs` テーブルが大きい場合、更新前にオンライン DDL で `upstream_request_id` 列とインデックスを追加し、長時間の移行を避けてください。

  ### 新機能

  * 上流リクエスト ID をログに記録し、意図しないレスポンスヘッダー上書きを避けながら追跡を容易にしました。
  * 有料機能の利用前にコンプライアンス確認を追加しました。

  ### 不具合修正

  * チャネル選択欄のフォーカス時に有効な候補が隠れる問題を修正しました（#4829）。

  ### その他

  * 更新時の注意：`logs` テーブルに新しい `upstream_request_id` 列とインデックスを追加します。大規模環境では以下の適切なオンライン DDL を事前実行し、長時間またはブロッキングする自動移行を避けてください。

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

  ### 変更内容

  * chore(deps)\: /web/classic の axios を 1.15.0 から 1.15.2 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/4634](https\://github.com/QuantumNous/new-api/pull/4634)
  * chore(deps-dev)\: /electron の ip-address を 10.1.0 から 10.2.0 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/4811](https\://github.com/QuantumNous/new-api/pull/4811)
  * チャネル一覧がすべて表示されない問題を修正 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4829](https\://github.com/QuantumNous/new-api/pull/4829)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-arm64-v1.0.0-rc.6) (82.3 MB)
  * [new-api-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6) (84.6 MB)
  * [new-api-v1.0.0-rc.6.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6.exe) (86.3 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.tar.gz)
</Callout>

***

## v1.0.0-rc.5

<Callout type="note" title="正式版 · 2026-05-12 16:53:57 公開（中国時間）">
  ### 主な変更

  ダッシュボードにモデル性能指標と明確な稼働状態を追加しました。DeepChat のディープリンクにも対応し、UI、ウォレット、Playground、倍率表示の回帰を修正しました。

  ### 新機能

  * 概要画面を再設計し、モデル性能指標と稼働状態を明確に表示しました。
  * DeepChat ディープリンクで、対応するチャットを直接開けるようにしました（#4668）。

  ### 不具合修正

  * 正しいチャージ設定から支払い経路の利用可否を取得しました（#4599）。
  * グループ間倍率の設定を表示に反映しました（#4772）。
  * デフォルト UI のメニュー選択ハンドラーを修正しました（#4787）。
  * Playground で旧 classic 形式のメッセージを処理しました（#4650）。
  * 空の説明領域や配置など、v1 UI の回帰を修正しました（#4802）。

  ### 改善

  * 共通テーマプリセットで色、操作部品、角丸を統一しました。
  * Docker イメージにプロジェクトと第三者のライセンス通知を追加しました（#4739）。

  ***

  ### 変更内容

  * feat\: DeepChat ディープリンクに対応 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4668](https\://github.com/QuantumNous/new-api/pull/4668)
  * fix\: Docker ビルドの .dockerignore から THIRD-PARTY-LICENSES.md を除外 by @yeying-xingchen in [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * fix(wallet)\: status でなく topupInfo から支払い経路のフラグを取得 by @ImogeneOctaviap794 in [https\://github.com/QuantumNous/new-api/pull/4599](https\://github.com/QuantumNous/new-api/pull/4599)
  * fix(web/default)\: getUserGroups で GroupGroupRatio を表示に反映 by @Micah-Zheng in [https\://github.com/QuantumNous/new-api/pull/4772](https\://github.com/QuantumNous/new-api/pull/4772)
  * fix(default)\: DropdownMenuItem の onSelect に対応 by @lihan3238 in [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)
  * fix(web/default)\: Playground の旧 classic メッセージを保護 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4650](https\://github.com/QuantumNous/new-api/pull/4650)
  * fix\: デフォルト UI の不具合を整理 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4802](https\://github.com/QuantumNous/new-api/pull/4802)

  ### 新規コントリビューター

  * @yeying-xingchen の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * @lihan3238 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-arm64-v1.0.0-rc.5) (82.1 MB)
  * [new-api-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5) (84.5 MB)
  * [new-api-v1.0.0-rc.5.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5.exe) (86.2 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.tar.gz)
</Callout>

***

## v1.0.0-rc.4

<Callout type="note" title="正式版 · 2026-05-06 22:25:59 公開（中国時間）">
  ### 主な変更

  OpenAI 画像編集で参照画像とメタデータを保持し、文脈の欠落を防ぎました（#4646）。モデル性能バッジを追加し、課金設定と選択 UI も修正しました。

  ### 新機能

  * モデル一覧に性能バッジを追加しました。

  ### 不具合修正

  * 画像編集の転送時に参照画像とメタデータを保持しました（#4646）。
  * チャージと課金設定のフォーム入力を安定させました。
  * UI 更新後のドロップダウンと選択肢の描画・選択を修正しました（#4655）。

  ### 互換性に影響する変更

  * チャージリンクは status API ではなくチャージ情報 API から取得してください。

  ### 画面例

  | モデルの利用可能性ランキング                                                                                   | 更新された料金・設定 UI                                                                                    |
  | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
  | ![リリースノートの画面例](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![リリースノートの画面例](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### 変更内容

  * fix\: OpenAI 画像編集の参照フィールドを保持 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4646](https\://github.com/QuantumNous/new-api/pull/4646)
  * fix\: Select を Base UI items API に移行 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4655](https\://github.com/QuantumNous/new-api/pull/4655)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-arm64-v1.0.0-rc.4) (82.0 MB)
  * [new-api-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4) (84.4 MB)
  * [new-api-v1.0.0-rc.4.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4.exe) (86.1 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.tar.gz)
</Callout>

***

## v1.0.0-rc.3

<Callout type="note" title="正式版 · 2026-05-06 18:43:33 公開（中国時間）">
  ### 主な変更

  v1.0.0-rc.3 は、利用可能性と性能を比較できるモデルランキングを追加します。料金・設定、表操作などの UI も更新しました。

  ### 新機能

  * 実際の利用可能性と性能データを示すモデルランキングを追加しました（#4633）。

  ### 改善

  * Base UI、テーマプリセット、整理された表ツールバーで UI を更新しました（#4633）。
  * システムの料金設定を整理しました。

  ### 不具合修正

  * チャネル表のサーバー側ソートを修正しました（#4600）。
  * デフォルト UI のプラン支払い情報を修正しました。

  ### 画面例

  | モデルの利用可能性ランキング                                                                                   | 更新された料金・設定 UI                                                                                    |
  | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
  | ![リリースノートの画面例](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![リリースノートの画面例](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### 変更内容

  * feat(web/default)\: UI を全面更新 — Base UI、テーマ、ランキング、表ツールバー by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4633](https\://github.com/QuantumNous/new-api/pull/4633)
  * feat\: モデル性能指標を収集 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4635](https\://github.com/QuantumNous/new-api/pull/4635)
  * fix\: チャネル表のサーバー側ソートを有効化 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4600](https\://github.com/QuantumNous/new-api/pull/4600)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-arm64-v1.0.0-rc.3) (81.9 MB)
  * [new-api-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3) (84.4 MB)
  * [new-api-v1.0.0-rc.3.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3.exe) (86.1 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.tar.gz)
</Callout>

***

## v1.0.0-rc.2

<Callout type="note" title="正式版 · 2026-04-30 20:42:48 公開（中国時間）">
  ### 主な変更

  v1.0.0-rc.2 は新旧フロントエンドの切り替えを公開し、新 UI の試用と旧手順への復帰を容易にします。メール紐づけ、段階課金、Key グループ、Vertex の URL も修正しました。

  ### 新機能

  * 新旧フロントエンドの切り替えを追加しました。

  ### 改善

  * 料金、ダッシュボード、ログ、表、分析、ナビゲーション、モバイルの表示を更新しました。

  ### 不具合修正

  * 新 UI のメール紐づけ処理を修正しました（#4551）。
  * 段階料金の数値入力を修正しました（#4536）。
  * 段階料金の値とラベルの表示を修正しました（#4530）。
  * デフォルトテーマの API Key グループ表示を修正しました（#4548）。
  * カスタム Vertex URL にゲートウェイプレフィックスを反映しました（#4200）。

  ### 画面例

  | 更新された料金ページ                                                                                                  | ダッシュボードと分析操作                                                                                                          |
  | ----------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
  | ![Refreshed pricing page](https\://github.com/user-attachments/assets/8d403155-27ac-407d-b0ae-8815034c66a7) | ![Dashboard and analytics controls](https\://github.com/user-attachments/assets/caa73f0a-13d2-47fc-ab7d-0ffb4e7b6194) |

  ### 変更内容

  * fix\: デフォルトテーマの API Key グループの動作を修正 by @Micah-Zheng in [https\://github.com/QuantumNous/new-api/pull/4548](https\://github.com/QuantumNous/new-api/pull/4548)
  * bug fix\: 新フロントエンドのメール紐づけエラーを修正 by @SHLE1 in [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)
  * fix\: 段階料金の数値入力を改善 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4536](https\://github.com/QuantumNous/new-api/pull/4536)
  * fix(vertex)\: カスタム base\_url をゲートウェイプレフィックスとして使用 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4200](https\://github.com/QuantumNous/new-api/pull/4200)
  * fix(web)\: 段階課金の Base64 デコード失敗とタグ不一致による表示エラーを修正 by @wans10 in [https\://github.com/QuantumNous/new-api/pull/4530](https\://github.com/QuantumNous/new-api/pull/4530)

  ### 新規コントリビューター

  * @SHLE1 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-arm64-v1.0.0-rc.2) (76.5 MB)
  * [new-api-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2) (78.9 MB)
  * [new-api-v1.0.0-rc.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2.exe) (80.6 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.tar.gz)
</Callout>

***

## v1.0.0-rc.1

<Callout type="note" title="正式版 · 2026-04-29 20:15:01 公開（中国時間）">
  v1.0.0-rc.1 は 1.0 の最初のリリース候補で、管理作業を整理・高速化する新しい v1 フロントエンドを中心とします。

  最終 v1 に向け、ナビゲーション、設定、分析、ログの UI を刷新しました。

  ![v1.0.0-rc.1 リリースノートの画像](https\://github.com/user-attachments/assets/f3f8ed32-e0c5-4cfb-94a3-da0f357b62ab)

  ### 新機能

  * ナビゲーション、パラメーター上書き用の視覚チャネル編集、システム設定・テーマ切り替えを備えた v1 を追加しました（#4265）。

  ### 改善

  * モデル分析、ソート、ツールチップを改善し、ダッシュボードと図を更新しました。
  * ログ種別、ユーザー名、アバター、整理された表で使用ログを改善しました。
  * 共通配置、表、フォームの表示を統一しました。

  ### 不具合修正

  * DB から読み込んだテーマを実行時に正しく適用しました（#4518）。
  * 転送時に空の推論フィールドを破棄せず保持しました（#4520）。
  * フォームの必須表示を統一しました（#4533）。

  ***

  ### 変更内容

  * 🚀 feat\: v1.0 を公開 — 一から構築した次世代フロントエンド by @t0ng7u in [https\://github.com/QuantumNous/new-api/pull/4265](https\://github.com/QuantumNous/new-api/pull/4265)
  * fix\: 転送時に空の Message.ReasoningContent/Reasoning が黙って破棄される問題を修正 by @heimoshuiyu in [https\://github.com/QuantumNous/new-api/pull/4520](https\://github.com/QuantumNous/new-api/pull/4520)
  * fix\: DB から読んだテーマを実行環境へ同期 by @Micah-Zheng in [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  ### 新規コントリビューター

  * @Micah-Zheng の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-arm64-v1.0.0-rc.1) (76.4 MB)
  * [new-api-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1) (78.8 MB)
  * [new-api-v1.0.0-rc.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1.exe) (80.5 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.tar.gz)
</Callout>

***

## v1.0.0-alpha.1 — ライセンス境界のリリース

<Callout type="note" title="プレリリース版 · 2026-04-28 14:26:06 公開（中国時間）">
  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1](https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1)

  **ダウンロード**

  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.tar.gz)
</Callout>

***

## v0.13.2

<Callout type="note" title="正式版 · 2026-04-27 22:11:42 公開（中国時間）">
  ### 新機能

  * 上流モデル検出、料金エンドポイントからの自動同期、削除済みモデル表示、同期遅延中の料金保持を改善しました（#4452）。
  * ユーザーの作成・最終ログイン時刻を記録しました（#4450）。
  * Alibaba ネイティブ Messages API にモデル照合設定を追加しました（#4468）。

  ### 不具合修正

  * ツール引数の生 JSON に対応しました（#4469）。
  * JSON オブジェクトの設定更新を安定させました。

  ### 改善

  * アフィニティ無効でチャネルをスキップした際の再試行説明を明確にしました（#4453）。

  ***

  ### 変更内容

  * fix(channel)\: 上流モデル検査でモデルマッピングを読み込み by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4437](https\://github.com/QuantumNous/new-api/pull/4437)
  * feat\: 料金エンドポイントから上流料金を同期 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4452](https\://github.com/QuantumNous/new-api/pull/4452)
  * fix\: アフィニティ無効チャネルの再試行説明を明確化 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4453](https\://github.com/QuantumNous/new-api/pull/4453)
  * feat\: Alibaba ネイティブ Messages のモデル照合を設定可能に by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4468](https\://github.com/QuantumNous/new-api/pull/4468)
  * fix\: ツール応答引数の生 JSON に対応 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4469](https\://github.com/QuantumNous/new-api/pull/4469)
  * feat\: モデル取得画面に削除済み上流モデルを表示 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4470](https\://github.com/QuantumNous/new-api/pull/4470)
  * ユーザーの作成日時と最終ログイン日時を追加 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4450](https\://github.com/QuantumNous/new-api/pull/4450)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2](https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.0.13.2.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.Setup.0.13.2.exe) (106.8 MB)
  * [new-api-arm64-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-arm64-v0.13.2) (64.6 MB)
  * [new-api-macos-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-macos-v0.13.2) (83.2 MB)
  * [new-api-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2) (67.0 MB)
  * [new-api-v0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2.exe) (68.6 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.tar.gz)
</Callout>

***

## v0.13.1-patch.1

<Callout type="note" title="正式版 · 2026-04-25 13:27:23 公開（中国時間）">
  ### 主な変更

  このパッチは、段階条件と LLM プロンプトヘルパーでの `len` の利用を追加し、プロンプト長に基づく規則を作りやすくします。

  ### 新機能

  * `len` 変数を段階条件と LLM プロンプトヘルパーに追加し、プロンプト長による規則を定義できます。

  ***

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-linux.txt) (186 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-macos.txt) (96 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-windows.txt) (94 B)
  * [new-api-arm64-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-arm64-v0.13.1-patch.1) (64.6 MB)
  * [new-api-macos-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-macos-v0.13.1-patch.1) (83.2 MB)
  * [new-api-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1) (66.9 MB)
  * [new-api-v0.13.1-patch.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1.exe) (68.6 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.tar.gz)
</Callout>

***

## v0.13.1

<Callout type="note" title="正式版 · 2026-04-24 22:20:58 公開（中国時間）">
  #### 新機能

  * DeepSeek V4 の推論サフィックス処理に対応しました（#4428）

  #### 不具合修正

  * 段階課金モデルが一覧から除外される問題を修正しました（#4431）

  ***

  ### 変更内容

  * fix\: モデル一覧に段階課金モデルを含める by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4431](https\://github.com/QuantumNous/new-api/pull/4431)
  * feat\: DeepSeek V4 推論サフィックスの処理とテストを実装 by @HynoR in [https\://github.com/QuantumNous/new-api/pull/4428](https\://github.com/QuantumNous/new-api/pull/4428)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1](https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.0.13.1.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.Setup.0.13.1.exe) (106.7 MB)
  * [new-api-arm64-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-arm64-v0.13.1) (64.6 MB)
  * [new-api-macos-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-macos-v0.13.1) (83.2 MB)
  * [new-api-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1) (66.9 MB)
  * [new-api-v0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1.exe) (68.6 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.tar.gz)
</Callout>

***

## v0.13.0

<Callout type="note" title="正式版 · 2026-04-24 14:09:21 公開（中国時間）">
  ### 主な変更

  このリリースは `expr` 式による段階課金に対応し、複雑で動的な料金規則を設定できます。たとえば料金式 `tokens <= 128000 ? 0.002 : 0.004` により、128K Token 未満に低い料金、それ以上に高い料金を自動適用できます。

  ### 新機能

  * 課金システムでの `expr` 式の評価に対応し、プリセットを備えた動的な段階料金を利用できます（#4409）。
  * ツール料金設定 UI を追加し、ツール呼び出しの残高計算を改善しました。
  * 管理者のチャージ明細にユーザー ID を表示しました（#4349）。
  * トークン表に最終使用日時を追加しました（#4372）。
  * 旧トークンの移行に向け、Key 列の長さ要件を緩和しました（#4401）。

  ### 不具合修正

  * N 倍率を画像モデルだけに適用しました（#4412）。
  * 段階料金精算でテキストツールの追加料金を保持しました（#4162）。
  * 補完倍率を修正したモデルは `gpt-5.5` です（#4414）。
  * モデル料金 UI の表示型を修正しました（#4426）。
  * 段階料金エディターと精算ロジックのクラッシュや境界条件を修正しました。
  * 段階課金モデルのチャネルテストを更新しました。

  ### 改善

  * Doubao Seed 1.8 の料金段階プリセットを追加しました。
  * Card を div に置き換えて配置を統一しました。
  * 単位当たりの残高を使い、課金計算を改善しました。

  ***

  ### 変更内容

  * fix(channel-test)\: 段階課金モデルのテストに対応 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4145](https\://github.com/QuantumNous/new-api/pull/4145)
  * 管理者のチャージ明細にユーザー ID を表示 by @uskyu in [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * トークンの最終使用日時を追加 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4372](https\://github.com/QuantumNous/new-api/pull/4372)
  * chore(deps)\: github.com/jackc/pgx/v5 を 5.9.0 から 5.9.2 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/4397](https\://github.com/QuantumNous/new-api/pull/4397)
  * chore(deps-dev)\: /electron の @xmldom/xmldom を 0.8.12 から 0.8.13 に更新 by @dependabot\[bot] in [https\://github.com/QuantumNous/new-api/pull/4399](https\://github.com/QuantumNous/new-api/pull/4399)
  * 旧移行の互換性のためトークン Key 列の長さを緩和 by @XiaoAI1024 in [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * fix(billing)\: 段階精算でテキストツールの追加料金を保持 by @yyhhyyyyyy in [https\://github.com/QuantumNous/new-api/pull/4162](https\://github.com/QuantumNous/new-api/pull/4162)
  * feat\: 課金システムに段階料金式を追加 by @Calcium-Ion in [https\://github.com/QuantumNous/new-api/pull/4409](https\://github.com/QuantumNous/new-api/pull/4409)
  * fix(image)\: 画像モデルだけに N 倍率を使用 by @xyfacai in [https\://github.com/QuantumNous/new-api/pull/4412](https\://github.com/QuantumNous/new-api/pull/4412)
  * fix\: gpt-5.5 の補完倍率を修正 by @jingx8885 in [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)
  * fix\: モデル料金の表示型を修正 by @feitianbubu in [https\://github.com/QuantumNous/new-api/pull/4426](https\://github.com/QuantumNous/new-api/pull/4426)

  ### 新規コントリビューター

  * @uskyu の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * @XiaoAI1024 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * @jingx8885 の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0](https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.0.13.0.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.Setup.0.13.0.exe) (106.8 MB)
  * [new-api-arm64-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-arm64-v0.13.0) (64.6 MB)
  * [new-api-macos-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-macos-v0.13.0) (83.2 MB)
  * [new-api-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0) (66.9 MB)
  * [new-api-v0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0.exe) (68.6 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.tar.gz)
</Callout>

***

## v0.12.15

<Callout type="note" title="正式版 · 2026-04-22 23:04:03 公開（中国時間）">
  #### 新機能

  * チャージと決済に Waffo Pay を追加しました（#4089）。

  #### 不具合修正

  * チャージカードの表示を破損する問題を修正しました（#4388）。

  #### 改善

  * Gemini の `IncludeServerSideToolInvocations` setting in `ToolConfig` に対応し、新しいツール呼び出し動作との互換性を改善しました（#4311）。
  * 自動無効化チャネルの認証情報更新、テストのストリーミング化、使用量画面の改善で Codex の信頼性を高めました（#4324）。

  ***

  ### 変更内容

  * fix(gemini)\: ToolConfig に IncludeServerSideToolInvocations を追加 by @KoellM in [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * refactor\: 支払い処理を整理 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4089](https\://github.com/QuantumNous/new-api/pull/4089)
  * fix(topup)\: チャージカードの不足した Tag を import by @gaoren002 in `#4388`
  * chore\: Codex 使用量画面の配置を改善 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4386](https\://github.com/QuantumNous/new-api/pull/4386)
  * fix\: Codex 自動テストにストリーミングを使用 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4325](https\://github.com/QuantumNous/new-api/pull/4325)
  * fix\: 自動無効化チャネルの Codex 認証情報を更新 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4324](https\://github.com/QuantumNous/new-api/pull/4324)
  * fix\: パスキー変更時に適切な確認を要求 by @seefs001 in [https\://github.com/QuantumNous/new-api/pull/4393](https\://github.com/QuantumNous/new-api/pull/4393)

  ### 新規コントリビューター

  * @KoellM の初回貢献：[https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * @gaoren002 の初回貢献：`#4388`

  **全変更履歴**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15](https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15)

  **ダウンロード**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-linux.txt) (172 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-macos.txt) (89 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-windows.txt) (87 B)
  * [New-API-App.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.0.12.15.exe) (106.3 MB)
  * [New-API-App.Setup.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.Setup.0.12.15.exe) (106.6 MB)
  * [new-api-arm64-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-arm64-v0.12.15) (63.7 MB)
  * [new-api-macos-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-macos-v0.12.15) (82.0 MB)
  * [new-api-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15) (66.0 MB)
  * [new-api-v0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15.exe) (67.7 MB)
  * [ソースコード（zip）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.zip)
  * [ソースコード（tar.gz）](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.tar.gz)
</Callout>

***