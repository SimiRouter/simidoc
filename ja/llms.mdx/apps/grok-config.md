# Grok CLI の設定

Grok CLI ではモデル一覧と推論のアドレスを別々に設定します。`[endpoints].models_base_url` はモデル一覧の取得元であり、推論リクエストの既定ベースでもあります。個々のモデルの `base_url` で上書きできます。片方だけ設定すると、もう片方が公式アドレスのまま残る可能性があるため、両方を確認してください。

設定ファイルのパス：

* **Linux / macOS**：`~/.grok/config.toml`
* **Windows**：`%USERPROFILE%\.grok\config.toml`

## インストール／更新

Linux / macOS：

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
grok update
grok --version
```

Windows（PowerShell）：

```powershell
irm https://x.ai/cli/install.ps1 | iex
```

WinGet でインストールした場合は `winget upgrade` で更新し、`grok update` に依存しないでください。

<Callout type="warn" title="起動時に XAI_API_KEY が必要">
  Grok CLI は起動時のモデル一覧取得で環境変数 `XAI_API_KEY` のみを読み取ります。未設定の場合は設定ファイルの `api_key` に関係なく取得が失敗します。SimiRouter を使うときは同じ Key を環境変数にも設定してください：

  ```bash
  export XAI_API_KEY="PASTE_API_KEY_HERE"
  ```

  Key を Git にコミットするファイルへ書かないでください。継続利用時は権限 `600` の環境ファイルに保存し、`source` で読み込みます。
</Callout>

## 設定ファイルに記入

以下の内容を `~/.grok/config.toml` に記入し、`api_key` を自分の API Key に置き換えます。

```toml
[models]
default = "grok-4.5"

[endpoints]
models_base_url = "https://api.dwchainless.com/v1"

[model."grok-4.5"]
base_url = "https://api.dwchainless.com/v1"
model = "grok-4.5"
name = "Grok 4.5"
api_key = "PASTE_API_KEY_HERE"
api_backend = "responses"
context_window = 500000
supports_backend_search = true

[session]
# 可选：官方默认值为 85；80 会更早触发自动压缩
auto_compact_threshold_percent = 80

[ui]
max_thoughts_width = 120
yolo = false
compact_mode = false
# permission_mode = "always-approve"  # enable only in trusted environments
```

上の UI 設定は表示のみを調整します。思考内容の最大幅は 120、コンパクト表示は無効で、ツール呼び出しの承認は既定のままです。

<Callout type="warn" title="">
  例では `yolo` を無効にし、`permission_mode = "always-approve"` をコメントアウトしています。有効にすると Grok は確認なしでファイル変更とコマンド実行を行うため、**信頼できるプロジェクトと実行環境でのみ使用してください**。
</Callout>

<Callout type="info" title="">
  `api_key` には当サイトの SimiRouter Key が必要です。grok.com の OAuth `refresh_token` は使用できません。インライン Key は平文で保存されます。Linux / macOS は `chmod 600 ~/.grok/config.toml` を実行してください。共有マシンでは公式が対応する `env_key` 方式を推奨します。
</Callout>

## 設定の検証

```bash
grok inspect
grok models
grok --model grok-4.5 --output-format json -p '只输出 YAI_GROK_OK'
```

## 公式資料

* [xAI Grok CLI：カスタムモデル](https\://docs.x.ai/build/overview)
* [xAI Grok CLI：設定リファレンス](https\://docs.x.ai/build/settings)