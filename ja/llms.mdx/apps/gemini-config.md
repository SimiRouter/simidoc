# Gemini CLI の設定

環境変数を設定し、Gemini CLI の接続先を SimiRouter に変更します。

## macOS / Linux

**一時的な設定（現在のターミナルセッション）：**

```bash
export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
export GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**永続設定（Shell 設定ファイルに追記）：**

```bash
install -d -m 700 ~/.config
umask 077
printf '%s\n' \
  'export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"' \
  'export GEMINI_API_KEY="PASTE_API_KEY_HERE"' > ~/.config/simiroouter.env
chmod 600 ~/.config/simiroouter.env
# Add this line to ~/.zshrc or ~/.bashrc: source ~/.config/simiroouter.env
source ~/.config/simiroouter.env
```

<Callout type="info" title="">
  キーはログインごとに実行されるシェル設定ではなく、権限 `600` の `~/.config/simiroouter.env` に保存します。`source ~/.config/simiroouter.env` を `~/.bashrc` または `~/.zshrc` に追加すると永続化できます。共有マシンでは他ユーザーが読めないようにしてください。
</Callout>

## Windows PowerShell

**一時的な設定：**

```powershell
$env:GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
$env:GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**永続設定（PowerShell プロファイルに追記）：**

```powershell
Add-Content $PROFILE 'Set-Item -Path Env:GOOGLE_GEMINI_BASE_URL -Value "https://api.dwchainless.com"'
Add-Content $PROFILE 'Set-Item -Path Env:GEMINI_API_KEY -Value "PASTE_API_KEY_HERE"'
```

## Windows CMD

**一時的な設定：**

```cmd
set GOOGLE_GEMINI_BASE_URL=https://api.dwchainless.com
set GEMINI_API_KEY=PASTE_API_KEY_HERE
```

**永続設定（現在のユーザー）：**

1. キーを押します：`Win + R`。入力する内容は `sysdm.cpl`。Enter を押します
2. 「詳細設定」→「環境変数」をクリック
3. 「ユーザー環境変数」で「新規」を選び、`GOOGLE_GEMINI_BASE_URL` と `GEMINI_API_KEY` をそれぞれ追加
4. ターミナルを再起動して変数を反映

## 起動の検証

```bash
gemini
```

起動後、API Key 認証を選んで短いメッセージを送信し、SimiRouter の使用ログで呼び出しを確認します。クライアントが開くだけでは API 接続済みとはいえません。

## よくある質問

**エラー表示：`GEMINI_API_KEY` が未設定？**

* 変数名の綴りを確認
* Windows でシステム変数を設定した後は、ターミナルを再起動

**接続がタイムアウトする、またはエラーになる？**

* 確認する項目は `GOOGLE_GEMINI_BASE_URL` の末尾に余分な `/` がないか確認
* ネットワーク接続を確認
* API Key が有効で、期限切れでないことを確認

## 公式資料

[Gemini CLI 設定リファレンス](https\://geminicli.com/docs/reference/configuration/)内の `GOOGLE_GEMINI_BASE_URL` はサービスのルートアドレスを上書きします。SDK が API バージョンとモデルパスを追加するため、ここには `/v1` を追加しません。