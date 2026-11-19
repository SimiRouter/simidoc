# Factory Droid CLI のインストールと設定

Droid CLI は自分の API Key によるモデル設定に対応しています。個人のカスタムモデルはローカル設定に保存されるものであり、Factory のホスト型 Web 版やモバイル版も同じモデルを使用するとは限りません。

## インストール

macOS / Linux：

```bash
curl -fsSL https://app.factory.ai/cli | sh
droid --version
```

Windows PowerShell：

```powershell
irm https://app.factory.ai/cli/windows | iex
droid --version
```

上のコマンドは公式インストールスクリプトを実行します。実行前に提供元を確認し、管理環境では組織の要件に従ってください。インストールのために無条件で安全対策ソフトを無効化したり、グローバル実行ポリシーを緩めたりしないでください。起動後にログインを求められた場合は、クライアントの指示に従います。

## SimiRouter モデルを追加

1. 起動するコマンドは `droid` です。次に `/settings` を実行して **Custom models** を開きます。または `/model` 内の **Manage custom models** を開きます。
2. クリックする項目は **Add model** から、汎用 Chat Completions プロバイダーを選択します。
3. 以下を設定して保存します。

| フィールド        | 内容                               |
| ------------ | -------------------------------- |
| Provider     | `generic-chat-completion-api`    |
| Base URL     | `https://api.dwchainless.com/v1` |
| API Key      | SimiRouter API Key               |
| Model        | アカウントで利用可能な完全なモデル ID             |
| Display name | 例：`SimiRouter`。表示専用              |

## 設定ファイルを使用

次の配列をマージすることもできます。`~/.factory/settings.json` の `customModels` 配列を編集する前にバックアップし、既存項目と他の設定を保持してください。

```json
{
  "customModels": [
    {
      "model": "MODEL_ID",
      "displayName": "SimiRouter",
      "baseUrl": "https://api.dwchainless.com/v1",
      "apiKey": "${SIMIROUTER_API_KEY}",
      "provider": "generic-chat-completion-api"
    }
  ]
}
```

`MODEL_ID` を実際のモデル ID に置き換え、Droid の起動環境に `SIMIROUTER_API_KEY` を設定します。`${SIMIROUTER_API_KEY}` は Droid が対応する環境変数参照です。公開される実際の Key に置き換えないでください。

現在の設定は `settings.json` と camelCase フィールドを使用します。旧版の `config.json` の項目は初回起動時に移行される場合があり、その後は `settings.json` を編集します。旧サードパーティー設定スクリプトで設定を上書きし続けないでください。

## 検証

対象の `/model` 内の **Custom Models** 内の SimiRouter モデルを選択し、ファイルの説明など低リスクのタスクを依頼してから、SimiRouter の使用ログで実モデルと使用量を確認します。出力上限、画像入力、ツール呼び出しは選択モデルに応じて設定し、他モデルの固定の機能値を流用しないでください。

## 公式資料

* [Factory Droid CLI クイックスタート](https\://docs.factory.com/droid-cli/quickstart)
* [Factory カスタムモデル（BYOK）](https\://docs.factory.com/model-independence/byok)