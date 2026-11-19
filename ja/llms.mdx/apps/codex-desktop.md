# CodexApp デスクトップ版の設定

Codex デスクトップ版は API Key ログインに対応し、アプリ内でユーザーレベルの `config.toml` を開けます。以下の設定後、Codex は SimiRouter の Responses 互換 API を通じてリクエストを送信します。

<Callout type="info" title="">
  ログイン画面のフィールド名は引き続き **OpenAI API key** と表示されます。ここには自分の SimiRouter API Key を入力してください。例：`sk-...`。
</Callout>

## 前提条件

開始前に以下を用意してください。

* 最新版の Codex デスクトップ版
* SimiRouter アカウント
* SimiRouter コンソールで作成した API Key
* 設定するモデルを現在のアカウントで利用可能であること

## 設定手順

### 1. API Key でログイン

1. Codex デスクトップ版を開きます。
2. ログインページで **Sign in another way** を選択します。
3. 対象の **OpenAI API key** 入力欄に SimiRouter API Key を入力します。
4. 選択する項目は **Continue** を選んでアプリに入ります。

![Codex デスクトップ版に API Key を入力](/simidoc/assets/codex-desktop/codex-api-key-login.png)

### 2. ユーザーレベルの設定ファイルを開く

1. Codex の設定ページを開きます。
2. 左側で **Configuration** を選択します。
3. **Custom config.toml settings** 内の **User config** を選択します。
4. 選択する項目は **Open config.toml** を選択し、ユーザーレベルの設定ファイルを開きます。

![Codex デスクトップ版でユーザーレベルの config.toml を開く](/simidoc/assets/codex-desktop/codex-user-config.png)

### 3. SimiRouter 設定を記入

編集前に既存の `config.toml` をバックアップしてください。以下のモデルとプロバイダーのフィールドをマージし、ファイル全体を上書きしないでください。既存の MCP、プロジェクト信頼、承認、サンドボックス設定を保持し、同名 TOML テーブルを重複追加しないでください。

```toml
model_provider = "simirouter"
review_model = "gpt-6-astra"
model = "gpt-6-astra"
model_reasoning_effort = "xhigh"
plan_mode_reasoning_effort = "high"
model_reasoning_summary = "auto"
model_verbosity = "high"

suppress_unstable_features_warning = true
web_search = "live"

[model_providers.simirouter]
name = "simirouter"
base_url = "https://api.dwchainless.com/v1"
wire_api = "responses"
stream_idle_timeout_ms = 900000
supports_websockets = false
http_headers = { "x-openai-actor-authorization" = "api.dwchainless.com" }
requires_openai_auth = false
experimental_bearer_token="PASTE_API_KEY_HERE"
```

保存後は Codex デスクトップ版を完全終了し、再起動します。

<Callout type="info" title="">
  この例は `requires_openai_auth = false` と `experimental_bearer_token` でトークンを直接指定します。プレースホルダーを自分の SimiRouter API Key に置き換えてください。この方式では `auth.json` の同時設定は不要で、ログイン処理で保存された Key にも依存しません。`config.toml` には平文の Key が含まれます。コミットや共有は避けてください。Linux / macOS は `chmod 600 ~/.codex/config.toml` でアクセスを制限でき、Windows もファイルのアクセス権を制限してください。既存の承認、サンドボックス、プロジェクト信頼設定を保持し、接続のために安全確認を無効化しないでください。
</Callout>

## 設定の検証

Codex を再起動した後：

1. プロジェクトまたはワークスペースを開きます。
2. まずファイルの説明など、低リスクのタスクを依頼します。
3. SimiRouter の使用ログで、リクエストの時刻、モデル、使用量を確認します。クライアントの表示名やモデルの自己紹介では、実際の経路は証明できません。

## よくある質問

### API Key が無効

* SimiRouter コンソールから完全な API Key をコピーし直します。
* API Key の前後に余分な空白がないか確認します。
* API Key が `sk-` で始まり、現在も有効であることを確認します。

### 設定が反映されない

* 変更したファイルが **User config** から開いた `config.toml` であることを確認します。
* 確認する項目は `model_provider = "simirouter"` と `[model_providers.simirouter]` の名前が完全に一致していることです。
* 保存後は現在のウィンドウを閉じるだけではなく、アプリを完全終了してください。

### モデルまたは接続のエラー

* `base_url` が `https://api.dwchainless.com/v1` であることを確認します。
* `wire_api` が `responses` であることを確認します。
* 現在の API Key のグループで `gpt-6-astra` が利用可能か確認します。別のモデルを使用する場合は、`model` を対応するモデル名に置き換えてください。

手動で `auth.json` を設定する場合、モデルの切り替え、CLI 版の利用については [Codex CLI の設定](/simidoc/ja/apps/codex-config) を参照してください。

## 公式資料

* [OpenAI Codex 設定リファレンス](https\://developers.openai.com/codex/config-reference/)