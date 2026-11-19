# DeepSeek Harness の設定

DeepSeek Harness（`dsh`）は DeepSeek AI のオープンソースエージェントフレームワークです。SimiRouter をカスタムプロバイダーとして設定すると、Harness の Web UI と headless タスクで SimiRouter のモデルを使用できます。

## 前提条件

開始前に以下を用意してください。

* SimiRouter アカウントと API Key
* Node.js と `npx`
* macOS、Linux、Windows のターミナル
* エージェントに操作させるプロジェクトディレクトリ

## インストールと起動

エージェントに操作させるプロジェクトディレクトリに移動し、実行します。

```bash
npx @deepseek-ai/dsh web
```

Web UI のデフォルトアドレスは `http://127.0.0.1:3080` です。起動ディレクトリは既定のファイルシステム位置にすぎず、新しい Web UI はワークスペースを自動選択しません。画面でこのディレクトリを追加してください。選択するまでセッションの入力欄は使用できません。

ポートを変更する場合：

```bash
npx @deepseek-ai/dsh web --port 8080
```

## Web UI で SimiRouter を設定（推奨）

### 1. モデル設定を開く

DeepSeek Harness Web UI で **Settings → Models** を開きます。

![DeepSeek Harness のモデル設定を開く](/simidoc/assets/deepseek-harness/open-model-settings.png)

### 2. カスタムプロバイダーを追加

選択する項目は **Add a custom provider**を選び、以下を入力します。

| フィールド        | 入力内容                             |
| ------------ | -------------------------------- |
| Provider ID  | `simirouter`                     |
| Display name | `SimiRouter`                     |
| Base URL     | `https://api.dwchainless.com/v1` |
| API protocol | `openai-completions`             |
| API key      | 自分の SimiRouter API Key           |

![SimiRouter カスタムプロバイダー設定の入力](/simidoc/assets/deepseek-harness/custom-provider-form.png)

<Callout type="warn" title="">
  Provider ID はセッション、デフォルトモデル、認証情報から参照されるため、保存後に直接改名できません。小文字を使用し、`simirouter` のまま維持してください。
</Callout>

### 3. モデルを取得

対象の **Model catalog** 内の **Fetch available models**をクリックします。Harness は現在の Base URL と API Key でモデル一覧を取得します。

必要なモデルを選択して保存します。自動取得に失敗した場合は、手動でモデル ID を入力できます。例：`gpt-6-astra`。モデル名は現在の API Key グループが実際に利用できる名前と一致させてください。

![SimiRouter プロバイダーに追加するモデルを選択](/simidoc/assets/deepseek-harness/select-provider-models.png)

### 4. モデルを選択

保存後は入力欄付近のモデル選択欄で **SimiRouter** を見つけ、使用するモデルを選びます。そのモデルは新しいセッションのデフォルトになります。すでにリクエストを送信した既存セッションは元のモデルを使用し続けます。

![DeepSeek Harness で SimiRouter モデルを選択](/simidoc/assets/deepseek-harness/model-picker.png)

## Profile Patch で設定

Web Profile の高度なプロバイダー設定は `$DSH_HOME/profiles/web/cordis.patch.yml`（デフォルトの場所は `~/.dsh/profiles/web/cordis.patch.yml`）を使用します。編集前に元ファイルをバックアップし、以下のプラグイン設定をマージしてください。既存のプラグインやプロバイダーを上書きしないでください。

```yaml
- id: llm-pi-ai
  config:
    providers:
      simirouter:
        displayName: SimiRouter
        apiKeyEnv: SIMIROUTER_API_KEY
        api: openai-completions
        baseURL: https://api.dwchainless.com/v1
        models:
          - id: MODEL_ID
```

置き換える項目は `MODEL_ID` です。完全なモデル ID を指定し、Harness の起動環境に `SIMIROUTER_API_KEY` を設定します。Web UI 起動後、モデル選択欄で SimiRouter モデルを選びます。この設定は Web Profile 用であり、他の Profile が自動継承するとは限りません。

## 設定の検証

1. Web UI を開きます。既定は `http://127.0.0.1:3080` で、起動時に `--port` を指定した場合はそのポートを使用します。
2. モデル選択欄に **SimiRouter** と保存済みモデルが表示されることを確認します。
3. 新しいセッションで短いテストメッセージを送信します。
4. SimiRouter の使用ログで、リクエスト時刻、モデル、消費量を確認します。

## Headless モード

Headless Profile はデフォルトで Web の管理対象認証情報ストレージを無効にするため、画面に保存した Key が自動的に反映されるとは限りません。Headless 用の Profile に同じプロバイダーを設定し、起動環境から API Key を渡す必要があります。設定説明は [DeepSeek Harness Headless の認証情報説明](https\://github.com/deepseek-ai/deepseek-harness/blob/master/packages/bundle/headless/README.md#credentials)。

## よくある質問

### `MISSING_CREDENTIAL`

Harness が `SIMIROUTER_API_KEY` を見つけられません。**Settings → Models** で API Key を保存し直すか、起動プロセスのターミナルに同名の環境変数を設定してください。

### `UNKNOWN_MODEL`

現在のモデルが、現在の Profile 内の `simirouter` の `models` 一覧にありません。モデルを再取得するか、正しいモデル ID を手動で追加してください。

### モデル取得または対話で 401 が発生

* API Key が完全で有効であり、余分な空白がないか確認します。
* Base URL が `https://api.dwchainless.com/v1` であることを確認します。
* 現在の API Key グループで選択モデルを使用できることを確認します。

### リクエストが SimiRouter を通らない

追加したものが **custom provider** で、Provider ID が `simirouter` であることを確認します。組み込みの DeepSeek、OpenAI、Anthropic プロバイダーは、それぞれの公式エンドポイントを使用し続けます。

### デフォルトモデルの変更が反映されない

新しいセッションでテストしてください。リクエスト送信済みのセッションは、記録済みのモデルを保持します。

## 公式資料

* [DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness)
* [DeepSeek Harness モデル設定ガイド](https\://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/providers.zh.md)