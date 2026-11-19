# Codex CLI のインストール

## macOS / Linux

OpenAI は独立したインストーラーを提供しています。

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex --version
```

このコマンドは公式スクリプトをダウンロードして実行します。管理環境では先に内容を確認するか、公式ドキュメントに従い組織が承認したパッケージ管理方式を使用してください。

## Windows

Windows はネイティブターミナルでも、WSL の Linux ツールチェーンでもインストール可能です。方法とサンドボックスの対応状況は [OpenAI Windows ドキュメント](https\://learn.chatgpt.com/docs/windows/windows-sandbox)。

npm を使用する場合は、Node.js 公式の説明に従って互換バージョンを用意してから実行します。

```powershell
npm install -g @openai/codex
codex --version
```

WSL では WSL 内にインストール・設定し、`%USERPROFILE%` 配下の Windows 設定と Linux の `~/.codex` を混同しないでください。問題解決のために安全対策を無効にしたり、無条件で管理者権限を使用したりしないでください。

## 設定と検証

1. [Codex CLI の設定](/simidoc/ja/apps/codex-config)に従ってマージする設定は `config.toml` のプロバイダーとモデルのフィールドです。変更前に元ファイルをバックアップします。
2. プロジェクトディレクトリで `codex` を実行します。
3. デフォルトの承認とサンドボックスを維持し、ファイルの説明を依頼してから、SimiRouter の使用ログでリクエストを確認します。

`codex --version` はコマンド実行の検証です。画面に入れることは API 接続済みを意味しません。`~/.codex` ディレクトリ全体を上書きし、履歴や他の設定を失わないようにしてください。

## 公式資料

* [OpenAI Codex CLI](https\://learn.chatgpt.com/docs/codex/cli)
* [OpenAI Windows サンドボックスの説明](https\://learn.chatgpt.com/docs/windows/windows-sandbox)