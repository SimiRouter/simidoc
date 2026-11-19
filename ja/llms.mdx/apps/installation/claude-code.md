# Claude Code CLI のインストール

Claude Code は macOS、Linux、ネイティブ Windows、WSL に対応します。ネイティブインストーラーは Node.js 不要です。npm でインストールする場合のみ、要件を満たす Node.js が必要です。

## macOS / Linux / WSL

Bash または Zsh で公式インストールコマンドを実行します。

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
```

このコマンドは公式スクリプトをダウンロードして実行します。管理環境では先に内容を確認するか、組織が承認した方法を使用してください。`sudo` で実行しないでください。

## Windows PowerShell

```powershell
irm https://claude.ai/install.ps1 | iex
claude --version
```

管理者権限は不要です。ネイティブ Windows で Git for Windows は任意で、Bash ツールが必要な場合にインストールします。WSL は WSL ターミナルで Linux 用コマンドを使用し、PowerShell で Linux クライアントを設定しないでください。

## 設定と起動

1. [Claude CLI の設定](/simidoc/ja/apps/claude-config)に従い、SimiRouter のアドレスと Key を設定します。
2. 使用するプロジェクトディレクトリで `claude` を実行します。
3. 権限確認を維持し、ファイルの説明など低リスクの操作を依頼してから、SimiRouter の使用ログを確認します。

`claude --version` はインストール済みであることだけを検証し、モデル API への接続は証明しません。インストールの問題を理由にウイルス対策を無効化したり、システム全体の安全性を下げたりしないでください。

## 公式資料

[Anthropic：Claude Code のインストールとシステム要件](https\://code.claude.com/docs/en/setup)。