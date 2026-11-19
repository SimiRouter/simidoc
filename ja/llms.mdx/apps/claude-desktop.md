# Claude Desktop の設定

CC Switch の**モデルマッピング**を使用すると、Claude Desktop でメニュー名を選択し、CC Switch が SimiRouter 上の対応する実モデルにリクエストを転送できます。以下は macOS の画面に基づく手順です。OS やソフトウェアのバージョンによって画面の名称が多少異なる場合があります。

## 事前準備

1. 新しいバージョンの Claude Desktop をインストールして起動します。
2. 対応する **Claude Desktop** の [CC Switch](https\://github.com/farion1231/cc-switch/releases/latest) をインストールして開きます。
3. SimiRouter にログインし、[API Key 管理](https://api.dwchainless.com/keys)ページで利用可能な API Key を作成またはコピーします。設定するモデルをその Key で利用できることを確認してください。

<Callout type="info" title="">
  API Key は呼び出し用の認証情報です。厳重に管理し、公開スクリーンショットや他人との共有を避けてください。モデル名と利用権限は SimiRouter コンソールで確認してください。
</Callout>

## CC Switch でモデルマッピングを設定

### 1. Claude Desktop のカスタムプロバイダーを追加

CC Switch の左側で **Claude Desktop** を開き、**プロバイダーを追加**を選び、次に **カスタム設定**を選択します。Claude Code ではなく Claude Desktop を選んでいることを確認してください。

![CC Switch で Claude Desktop のカスタムプロバイダーを追加](/simidoc/assets/claude-desktop/cc-switch-add-provider.png)

### 2. 接続情報とモデルマッピングを入力

カスタム設定ページで以下を入力します。

| フィールド      | 入力内容                                                  |
| ---------- | ----------------------------------------------------- |
| 名前         | `SimiRouter`。任意の名前にも変更可能                              |
| API Key    | コピーした SimiRouter API Key                              |
| リクエスト先アドレス | `https://api.dwchainless.com`。末尾に `/` や `/v1` を追加しません |
| 接続方式       | 選択する項目は **モデルマッピング**                                  |
| 上流形式       | 選択する項目は **Anthropic Messages（ネイティブ）**                 |

下部の**モデルマッピング**で、使用するロールに「メニュー表示名」と「実際のリクエストモデル」を入力します。例：

| モデルのロール | メニュー表示名             | 実際のリクエストモデル   |
| ------- | ------------------- | ------------- |
| Sonnet  | `claude-sonnet-5-5` | `gpt-6-astra` |
| Opus    | `claude-opus-5-5`   | `gpt-6-astra` |
| Haiku   | `claude-haiku-5-5`  | `gpt-6.1-sol` |

**メニュー表示名は Claude Desktop 内の名前にすぎず、実際に呼び出されるのは右列の「実際のリクエストモデル」です。** たとえば、表示名が `claude-sonnet-5-5` の選択肢を選んだ場合、上の例で実際にリクエストされるのは `gpt-6-astra` であり、Claude Sonnet ではありません。アカウント権限に合わせて、SimiRouter で利用できる正確なモデル ID に置き換えてください。表示名を識別しやすい名前にすることもできます。ロール一覧はバージョンによって異なる場合があります。画面に従ってください。

スクリーンショット内の `1M` はクライアントにコンテキスト機能を申告するための選択肢です。**例で選択されていることだけを理由に、そのまま設定しないでください**。実際のモデルと API の両方が対応する場合のみ選択します。入力後は **追加** をクリックします。

![CC Switch でモデルマッピングを入力。メニュー表示名と実際のリクエストモデルは別の列に配置](/simidoc/assets/claude-desktop/cc-switch-model-mapping.png)

スクリーンショットの API Key は非表示です。実際の設定では自分の Key を入力してください。

### 3. 接続を確認してルーティングを有効化

1. プロバイダー一覧に戻り、SimiRouter カード右側の **… → 接続テスト**をクリックして結果を確認します。
2. 正常に接続できたら、SimiRouter カード右側の有効化ボタン（▶）をクリックし、画面の指示に従ってルーティングを有効にします。カードに **ルーティング中**と表示されると、そのプロバイダーが選択済みです。
3. CC Switch とローカルルーティングサービスを起動したままにしてください。ルーティングの切り替えやモデルマッピングの変更後は、Claude Desktop を完全に終了して再起動し、設定を読み直します。

![プロバイダーメニューで接続テストを選択](/simidoc/assets/claude-desktop/cc-switch-test-connection.png)

![SimiRouter プロバイダーにルーティング中と表示](/simidoc/assets/claude-desktop/cc-switch-routing.png)

### 4. Claude Desktop の開発者モードを有効化

**Claude Desktop デスクトップ版**を開き、上部メニューバーで **Help → Troubleshooting → Enable Developer Mode** を選択します。すでに有効な場合は省略できます。

![Claude Desktop の Help メニューで開発者モードを有効化](/simidoc/assets/claude-desktop/claude-enable-developer-mode.png)

### 5. CC Switch の推論設定を確認

1. Claude Desktop 左下のアカウントメニューから **Inference configuration** を選択して、**Configure third-party inference** を開きます。
2. 右上の設定一覧で、選択されている項目が **CC Switch** であることを確認します。複数の設定がある場合は CC Switch を選択してください。**applied** と表示されている場合は適用済みです。未適用の変更がある場合は、画面に従って **Apply Changes** をクリックします。
3. 対象の **Connection** ページで **Test Connection** をクリックします。緑色の成功表示が出たら、設定ウィンドウを閉じます。

![アカウントメニューから Inference configuration を開く](/simidoc/assets/claude-desktop/claude-inference-menu.png)

![サードパーティー推論設定で CC Switch が選択され、適用済みであることを確認](/simidoc/assets/claude-desktop/claude-cc-switch-profile.png)

スクリーンショット内のゲートウェイ Key は非表示です。CC Switch が自動設定した値を維持し、空にしないでください。

<Callout type="info" title="">
  CC Switch 設定内のゲートウェイアドレスはローカルルーターを指し、手順 2 で入力する SimiRouter のリクエスト先とは異なります。通常、ゲートウェイアドレスやゲートウェイ Key を手動で変更する必要はありません。接続テストの成功は接続確認の通過のみを意味し、実際のモデル呼び出しの代わりにはなりません。
</Callout>

### 6. モデルを選択して検証

1. 新しいチャットを作成し、入力欄横のモデルメニューで設定した**メニュー表示名**を選び、短いメッセージを送信します。実際の呼び出しは課金される場合があります。
2. 応答後は SimiRouter コンソールの呼び出し履歴で、リクエスト時刻、**実際のモデル**、使用量を確認します。モデルの自己紹介や Claude Desktop の表示名から、実際に呼び出したモデルを証明することはできません。

## よくある質問

### Claude Desktop または開発者モードが見つからない

* Claude Desktop に対応する新しい CC Switch を使用し、左側で **Claude Desktop** を選択してください。
* Claude Desktop の **Help → Troubleshooting** で **Enable Developer Mode** を有効にします。項目が見つからない場合はクライアントを更新してください。

### CC Switch 設定が見えない、またはモデルが更新されない

* SimiRouter カードに **ルーティング中** と表示され、CC Switch とローカルルーティングサービスが起動していることを確認します。
* Claude Desktop を完全終了して再起動し、左下の **Inference configuration** の設定を確認します。バージョンによっては **Developer → Configure third-party inference** から開く場合もあります。
* モデルマッピングの「メニュー表示名」が入力済みで、**CC Switch** 設定が選択されていることを確認します。マッピング変更やプロバイダー切り替え後は Claude Desktop を再起動してください。

### 接続テストに失敗する、または対話でエラーになる

* CC Switch 内の API Key が完全で有効であり、リクエスト先が `https://api.dwchainless.com` であることを確認します。
* 選択されている **Anthropic Messages（ネイティブ）** 上流形式と、ネットワークおよびローカルルーティングサービスの状態を確認します。
* 「実際のリクエストモデル」の ID、Key のグループ、モデル権限を確認します。メニュー表示名だけを確認しないでください。
* エラー内容に応じて、アカウント残高とモデル互換性を確認します。接続テストの通過は、すべてのモデルや機能の利用を保証するものではありません。

## その他の設定方法

### 任意：従来の直接接続設定

以下は従来の直接接続手順であり、現在のクライアントで再検証していません。フィールドや画面が変更されている可能性があります。上記の CC Switch 手順で設定済みの場合は不要です。直接接続モードでのモデル利用可否は、クライアントの実際の対応状況に従います。

まず **Help → Troubleshooting** で開発者モードを有効にしてから、次の手順を実行します。

1. 上部メニューバーで **Developer → Configure third-party inference** を開きます。
2. 以下の表に従って設定します。

| フィールド                 | 入力内容                                                              |
| --------------------- | ----------------------------------------------------------------- |
| Base URL              | `https://api.dwchainless.com`                                     |
| API Key               | 自分の SimiRouter API Key。例：`sk-...`                                 |
| Authentication method | 選択する項目は `x-api-key`                                               |
| Provider / API format | この選択肢が表示される場合は、`Anthropic-compatible`、`custom gateway` または類似項目を選択 |

<Callout type="warn" title="">
  Claude Desktop の Base URL には `https://api.dwchainless.com` を入力します。これは Claude Desktop のサードパーティー推論設定用アドレスです。Claude CLI ドキュメント内の `ANTHROPIC_BASE_URL` 環境変数の書き方をそのままコピーしないでください。
</Callout>

3. **Apply locally** を選び、このコンピューターに設定を保存します。
4. クライアントの指示に従い、ログインまたは Claude Desktop の起動を続行します。

## 公式資料

* [CC Switch：Claude Desktop 設定説明](https\://github.com/farion1231/cc-switch-website/blob/main/public/docs/en/2-providers/2.6-claude-desktop.md)
* [Anthropic Docs：Claude Cowork のサードパーティープラットフォーム設定](https\://claude.com/docs/third-party/claude-desktop/overview)