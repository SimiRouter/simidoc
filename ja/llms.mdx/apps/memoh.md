# Memoh の設定

Memoh は独立した作業環境と長期記憶に対応するオープンソースのマルチエージェントプラットフォームです。チャットモデルと音声・文字起こしモデルはクライアントのタイプが異なり、同一のプロトコル設定を共用できません。

## Memoh のインストール

[Memoh 公式デプロイ手順](https\://docs.memoh.ai/self-hosted/docker)に従い、現行版をインストールします。初回ログイン後はアカウントのセキュリティ設定を行い、旧チュートリアルのデフォルトパスワードを使い続けないでください。

## プロバイダーの追加

1. SimiRouter の [API Key 管理](https://api.dwchainless.com/keys)からキーを作成します。
2. Memoh 設定サイドバーの **Models** ページを開き、**Add Provider** を選択します。
3. OpenAI Chat Completions テンプレートを使用するか、カスタムプロバイダーを作成します。

| フィールド       | 内容                               |
| ----------- | -------------------------------- |
| Name        | `SimiRouter`                     |
| Client Type | `openai-completions`             |
| Base URL    | `https://api.dwchainless.com/v1` |
| API Key     | SimiRouter API Key               |

`openai-responses` は Responses プロトコル、`openai-completions` は Chat Completions に対応します。名前だけで後者を旧テキスト補完 API と判断しないでください。OAuth ログインは SimiRouter API Key プロバイダーの代わりにはなりません。

## モデルを追加して有効化

プロバイダー詳細で **Import Models** をクリックしてインポートするか、アカウントで利用可能なモデル ID を手動入力します。一括インポートしたモデルは初期状態で無効の場合があります。モデルのスイッチを有効にし、ボット設定でチャットモデルを選択してください。

短いメッセージを送信し、SimiRouter の [使用ログ](https://api.dwchainless.com/usage-logs/common)で対応するリクエストを確認します。Memoh の記憶や検索などには、追加のプロバイダーが必要な場合があります。SimiRouter は現在、埋め込み連携に未対応であり、チャットモデルをベクトルモデルの代わりに使用できません。

## 公式資料

* [Memoh のプロバイダーとモデル](https\://docs.memoh.ai/integrations/providers/llm)
* [Memoh プロジェクト](https\://github.com/felinics/Memoh)