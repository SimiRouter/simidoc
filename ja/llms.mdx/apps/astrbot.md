# AstrBot の設定

AstrBot は複数のメッセージプラットフォームに対応するオープンソース AI アシスタントです。このチュートリアルでは OpenAI 互換プロトコルで SimiRouter に接続します。

## プロバイダーの追加

1. AstrBot をインストールして起動します。インストール手順は [AstrBot 公式ドキュメント](https\://docs.astrbot.app/) を参照してください。
2. SimiRouter の [API Key 管理](https://api.dwchainless.com/keys)からキーを作成します。
3. AstrBot 管理パネルの **Providers → Chat Completion** を開き、**Add** をクリックして、**OpenAI Compatible** を選択します。旧バージョンでは「モデルプロバイダー → 新規追加 → OpenAI」と表示される場合があります。
4. 次のフィールドに入力し、保存します。

| フィールド        | 内容                                            |
| ------------ | --------------------------------------------- |
| プロバイダー名      | `SimiRouter`                                  |
| API Base URL | `https://api.dwchainless.com/v1`              |
| API Key      | SimiRouter API Key                            |
| Model        | [モデル一覧](https://api.dwchainless.com/ja/pricing/)から、アカウントで利用可能な完全なモデル ID をコピー |

クリックする項目は **Save and Fetch Models** です。モデルを取得し、モデル右側の `+` で追加して有効にします。また、**Custom Model** からモデル ID を手動で入力することもできます。

## デフォルトのチャットモデルの設定

**Config → AI → Model** を開き、**Chat Model** を追加したモデルに設定し、設定を保存します。**Test Model** または短いメッセージの送信でテストし、SimiRouter の [使用ログ](https://api.dwchainless.com/usage-logs/common)で呼び出しを確認します。

画像理解とツール呼び出しは、AstrBot、選択モデル、チャネルのすべてが対応している必要があります。テキスト対話の成功は、すべての拡張機能が利用できることを意味しません。

## 公式資料

* [AstrBot モデルプロバイダー設定](https\://docs.astrbot.app/en/providers/llm.html)
* [AstrBot モデルサービス接続](https\://docs.astrbot.app/en/providers/start.html)