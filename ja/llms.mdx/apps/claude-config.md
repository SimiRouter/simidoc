# Claude CLI の設定

Claude Code は環境変数で API ゲートウェイに接続します。まず環境変数を設定し、次に `claude` を実行して起動します。

## Linux / macOS

```bash
export ANTHROPIC_AUTH_TOKEN="PASTE_API_KEY_HERE"
export ANTHROPIC_BASE_URL="https://api.dwchainless.com"

# 可选：自定义默认模型映射（不配置也可正常使用）
export ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-6-astra"
export ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-terra"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-luna"
```

## Windows CMD

```cmd
set ANTHROPIC_AUTH_TOKEN=PASTE_API_KEY_HERE
set ANTHROPIC_BASE_URL=https://api.dwchainless.com

:: 可选：自定义默认模型映射（不配置也可正常使用）
set ANTHROPIC_DEFAULT_OPUS_MODEL=gpt-6-astra
set ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-5.6-terra
set ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-5.6-luna
```

## Windows PowerShell

```powershell
$env:ANTHROPIC_AUTH_TOKEN="PASTE_API_KEY_HERE"
$env:ANTHROPIC_BASE_URL="https://api.dwchainless.com"

# 可选：自定义默认模型映射（不配置也可正常使用）
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-6-astra"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-terra"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-luna"
```

## 起動の検証

環境変数の設定後、ターミナルで実行します。

```bash
claude
```

短いメッセージを送信し、SimiRouter の使用ログで対応するモデルとリクエストを確認します。対話画面を開くだけでは API 接続を確認できません。

## 公式資料

[Claude Code ゲートウェイ接続ドキュメント](https\://code.claude.com/docs/en/llm-gateway)にゲートウェイへの接続方法が説明されています。`ANTHROPIC_BASE_URL` はルートアドレスであり、クライアントが `/v1/messages` を追加します。重複して `/v1` を付けないでください。モデルのマッピングは、現在のチャネルが対応する必要があります。