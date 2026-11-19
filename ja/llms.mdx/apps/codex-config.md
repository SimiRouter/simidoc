# Codex CLI の設定

この例では API Key を `config.toml` に直接指定します。スクリプトはユーザー用 `config.toml` とローカルの `models.json` を扱い、`auth.json` は作成・変更しません。

スクリプトは 2 つの URL と 1 つの API Key を使用します。

* **推論 Base URL**：`https://api.dwchainless.com/v1`。Codex のリクエスト用に `model_providers.simirouter.base_url` へ書き込みます。
* **モデルカタログ URL**：`https://api.dwchainless.com/v1/models`。同じ API Key を Bearer として使い、OpenAI 形式の一覧をローカルの `~/.codex/models.json` に変換して `model_catalog_json` を設定します。推論用の 2 つ目のエンドポイントではありません。
* **API Key**：同じ SimiRouter の Key を両方の URL で使用します。スクリプトは固定された 2 つの URL への Bearer 認証にのみ使用し、ドキュメントや他の場所には書き込みません。

カタログには有効な Key が必要です。モデルやコンテキスト長などの基本メタデータは応答に基づき、確認できないツールや推論機能を変換処理で追加しません。

* **Linux / macOS**：`~/.codex/config.toml`
* **Windows**：`%USERPROFILE%\.codex\config.toml`

## 方法 1：ワンクリック設定スクリプト（任意。実行前に内容を確認）

リポジトリには Bash と PowerShell のスクリプトがあります。実行前に Codex CLI または Codex デスクトップ版をインストールして起動し、スクリプトをダウンロードして内容を確認してからローカルファイルを実行してください。

* [Bash スクリプトをダウンロード（CDN）](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [Bash スクリプトをダウンロード（GitHub Raw 予備）](https\://raw.githubusercontent.com/SimiRouter/simidoc/cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [PowerShell スクリプトをダウンロード（CDN）](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)
* [PowerShell スクリプトをダウンロード（GitHub Raw 予備）](https\://raw.githubusercontent.com/SimiRouter/simidoc/cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)

macOS / Linux はターミナルで実行します。

<Callout type="warn" title="">
  以下の手順は上記の CDN または GitHub Raw リンクからスクリプトを保存しますが、ネットワークの応答をそのまま実行しません。保存したローカルファイルを確認してから実行してください。
  スクリプトは API Key を `experimental_bearer_token`（`config.toml` 内）に書き込みます。`auth.json` は作成・変更しません。設定ファイルは平文の秘密情報として扱ってください。
</Callout>

```bash
# Download the script from the public script link above, then review it.
less ./codex-simirouter-setup.sh
bash ./codex-simirouter-setup.sh
```

Windows は PowerShell で実行します。

```powershell
# Download the script from the public script link above, then review it.
$script = Join-Path (Get-Location) 'codex-simirouter-setup.ps1'
Get-Content -LiteralPath $script
& powershell -File $script
```

<Callout type="info" title="">
  PowerShell 5.1 と PowerShell 7 はどちらも実行前にファイルを保存するため、API Key の入力前に内容を確認できます。PowerShell 7 では最後の `powershell` を `pwsh` に置き換えてください。
</Callout>

実行後、メニューから使用するモデルを選択します。初回は API Key（`sk-` で始まる SimiRouter コンソールで取得した Key）の入力が求められます。

スクリプトは次の処理を順番に行います（Bash 版には Python 3.11 以降が必要です）。

* **既存設定のバックアップ**：`config.toml` のスナップショットを `~/.codex/backup-simirouter/` に保存し、復元には `RESTORE` の明示入力を求めます。
* **モデルカタログの同期**：同じ Key でカタログ URL を取得し、モデル ID と基本メタデータを `~/.codex/models.json` に変換して `model_catalog_json` を設定します。
* **`config.toml` の変更**：トップレベルの `model_provider`、`model`、`model_catalog_json` と、`[model_providers.simirouter]` 内の `base_url`、`wire_api`、`experimental_bearer_token` を更新し、その他の内容は可能な限り保持します。
* **ファイル保護**：ディレクトリと設定ファイルを現在のユーザーだけが読めるよう試みます。OS が拒否した場合は警告を表示します。
* **検証**：Bash 版は Python 3.11 以降で TOML とカタログ JSON を検証してからファイルを置き換えます。`auth.json` は検証・変更せず、実際の推論 API 呼び出し成功も主張しません。

<Callout type="info" title="">
  再実行してモデルを切り替えたり、「デフォルト設定を復元」でバックアップからインストール前の状態に戻したりできます。
</Callout>

## 方法 2：Linux / macOS の手動設定（代替）

変更前に、既存の `config.toml` と `auth.json` をそれぞれバックアップしてください。`~/.codex` ディレクトリ全体の移動や作り直しは、履歴、セッション、他の設定に影響するため避けます。プロバイダーとモデルのフィールドだけをマージし、ファイル全体を上書きしたり、同名 TOML テーブルを重複追加したりしないでください。既存の MCP、承認、サンドボックス、プロジェクト信頼設定を保持します。

### `~/.codex/config.toml`

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
model_catalog_json = "~/.codex/models.json"

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

`model_catalog_json` は `https://api.dwchainless.com/v1/models` から生成したローカルカタログを指します。手動設定では同じ Key でこの URL を取得し、Codex の `models.json` 形式で保存してください。OpenAI の `data` 一覧をそのまま Codex カタログとして使うことはできません。

このファイルは平文トークンを含みます。コミットや共有をしないでください。Linux / macOS では保存後にアクセスを制限します。

```bash
chmod 600 ~/.codex/config.toml
```

### `auth.json`（他の認証方式で必要な場合のみ）

上の例は設定内トークンだけで認証が可能であり、別途 `auth.json` を作成・上書きする必要はありません。以下の JSON は、そのファイルを必要とする他の認証方式の参考例です。現在の Codex バージョンの要件に合う方式を 1 つ選び、認証エラーを隠すために混在させないでください。

```json
{
  "OPENAI_API_KEY": "PASTE_API_KEY_HERE"
}
```

## Windows の設定

### PowerShell

ディレクトリを作成して設定ファイルを開きます。

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex" | Out-Null
notepad "$env:USERPROFILE\.codex\config.toml"
```

### CMD

```cmd
if not exist "%USERPROFILE%\.codex" mkdir "%USERPROFILE%\.codex"
notepad "%USERPROFILE%\.codex\config.toml"
```

既存設定をバックアップし、上の TOML のプロバイダーとモデルのフィールドを `config.toml` にマージして保存します。無関係な設定を上書きしないでください。この例は設定内トークンを使用するため、別途 `auth.json` を作成・上書きする必要はありません。Windows では Key を含むファイルのアクセス権を現在のユーザーに制限してください。

## 起動の検証

```bash
codex
```

<Callout type="warn" title="">
  Windows での `config.toml` と `auth.json` のパスは `%USERPROFILE%\.codex\` です。正しい場所に保存されていることを確認してください。
</Callout>