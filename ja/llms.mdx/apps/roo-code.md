# サードパーティープラグイン設定（VS Code Roo）

Roo Code はカスタム OpenAI 互換プロバイダーに対応しています。SimiRouter への接続には、サービスのアドレス、API Key、モデル ID だけを設定し、モデルのローカルデプロイは不要です。

## Roo Code の設定

1. Roo Code をインストールし、拡張機能の設定を開きます。
2. **API Provider** を **OpenAI Compatible** に設定します。
3. 以下を入力します。

| フィールド    | 内容                                           |
| -------- | -------------------------------------------- |
| Base URL | `https://api.dwchainless.com/v1`             |
| API Key  | SimiRouter [API Key 管理](https://api.dwchainless.com/keys)で作成した Key      |
| Model ID | [モデル一覧](https://api.dwchainless.com/ja/pricing/)から完全なモデル ID をコピー。大文字と小文字を区別 |

4. モデルの実際の機能に応じて、コンテキストウィンドウ、出力上限、画像入力を設定します。他モデルの固定値を流用しないでください。Roo Code は常にネイティブのツール呼び出しを使用し、個別の切り替えはありません。
5. 保存後に短いメッセージを送信し、SimiRouter の [使用ログ](https://api.dwchainless.com/usage-logs/common)で呼び出しを確認します。

## API テスト

クライアント外で使える完全な Python、Node.js、curl、Go のテスト例は [API スクリプトによる接続](/simidoc/ja/apps/api-script) を参照してください。テストとプラグインで同じモデル ID と Key の権限を使用します。テキストリクエストが 1 回成功しても、ツールや画像機能が結合テスト済みとはいえません。

## よくあるエラー

* **401**：Key が完全で有効であり、余分な空白がないか確認。
* **404**：最終 URL に `/v1` が重複していないか確認し、モデル ID を照合。
* **モデルを利用できない**：モデル、グループ、Key の権限を確認し、エラー本文から調査。
* **パラメーターが未対応**：現在のモデルに適用できないパラメーター、特にサンプリング、推論強度、出力長の設定を無効化。

プラグインのデフォルトのツール承認設定を維持してください。信頼できないプロジェクトに自動実行権限を与えず、Key を含む設定画面を公開しないでください。

## 公式資料

[Roo Code：OpenAI Compatible プロバイダー](https\://roocodeinc.github.io/Roo-Code/providers/openai-compatible/)。