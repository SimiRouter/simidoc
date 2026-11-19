# API リファレンス

SimiRouter は API Key でリクエストを認証し、モデル、グループ、チャネルに応じて呼び出しを転送します。互換 API と各社のネイティブ API では、アドレス、認証方式、パラメータ構造が異なる場合があるため、ドメインだけを変更して混用しないでください。

## 概要

API は三層で構成されます。まず能力（テキスト、画像、動画、音声、ツール、モデル一覧）を選び、次にプロトコル（OpenAI 互換、Gemini ネイティブ、Claude Messages）を選び、最後に各 API ページでパラメータを確認します。呼び出し形態は次の三つです。

| 形態           | 特徴                    | 代表的な API           |
| ------------ | --------------------- | ------------------ |
| 同期           | 1 つの接続で完全な結果を返す       | モデル一覧、画像生成、音声文字起こし |
| ストリーミング（SSE） | 1 つの接続でイベントを分割して返す    | チャット、画像理解、ツール呼び出し  |
| 非同期タスク       | タスク ID を返し、後から状態を照会する | 動画生成、公式のファインチューニング |

クライアントのタイムアウトや切断は、上流タスクのキャンセルを意味しません。生成リクエストを再送する前に、タスクと利用記録を確認してください。

## 接続の準備

1. 次の手順に従い、[SimiRouter Key の登録](/simidoc/ja/apps/getting-started)からキーを作成します。
2. [モデル一覧](https://api.dwchainless.com/ja/pricing/)で、現在のアカウントが利用できる完全なモデル ID を選択します。
3. 個別の API ページでサービスのアドレス、リクエスト形式、モデル要件を確認します。SimiRouter の API ルートは `https://api.dwchainless.com`；`/v1` または `/v1beta` は API パスに応じて決まります。
4. キーは環境変数またはサーバー側のシークレットストレージに保存します。実際のリクエストには料金が発生する場合があります。ブラウザーのフロントエンドや公開コードにキーを含めないでください。

[API スクリプトによる接続](/simidoc/ja/apps/api-script)には、テキストリクエストを一度送信する Python、Node.js、curl、Go の完全な例があります。

## サービスアドレス

ベンダー API に直接接続する前に、パス、認証、モデル ID、リクエストのフィールドを確認してください。両方が同じプロトコルを使い、エンドポイントのページに互換性が明記されている場合に限り、同じリクエスト構造を利用できます。

| サービス                            | アドレス                                         | 認証                                       |
| ------------------------------- | -------------------------------------------- | ---------------------------------------- |
| SimiRouter ゲートウェイ               | `https://api.dwchainless.com`                | `Authorization: Bearer` と SimiRouter Key |
| Google Gemini API（AI Studio キー） | `https://generativelanguage.googleapis.com`  | `x-goog-api-key`                         |
| Google Vertex AI                | `https://{region}-aiplatform.googleapis.com` | OAuth アクセストークン                           |
| OpenAI                          | `https://api.openai.com`                     | `Authorization: Bearer` と OpenAI Key     |
| Anthropic                       | `https://api.anthropic.com`                  | `x-api-key`                              |
| xAI                             | `https://api.x.ai`                           | `Authorization: Bearer`                  |
| 火山方舟                            | `https://ark.cn-beijing.volces.com/api/v3`   | `Authorization: Bearer`                  |
| Alibaba Cloud DashScope         | `https://dashscope.aliyuncs.com`             | `Authorization: Bearer` と DashScope Key  |

ローカルデバッグではゲートウェイのアドレスに `http://127.0.0.1:3001` を使用します。ベンダーのキーと SimiRouter Key は互換性がないため、アドレスを置き換えるときは認証も併せて置き換えてください。

## 機能一覧

| 機能                                       | 内容                                                                             | 呼び出し方式                                            |
| ---------------------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------------- |
| [チャット](/simidoc/ja/apps/api/chat)                           | Chat Completions、Responses、Claude Messages、Gemini コンテンツ生成                      | 非ストリーミングは完全な応答を待機し、ストリーミングは SSE イベントを順次受信         |
| [画像](/simidoc/ja/apps/api/images)                           | 画像生成、編集、参照画像からの生成、画像認識。OpenAI、Gemini、Qwen、即夢、Grok、FLUX プロトコルに対応                | プロトコルに応じて画像データ、URL、テキストを返します。ストリーミング対応は個別 API を参照 |
| [動画](/simidoc/ja/apps/api/video)                            | Seedance、Kling、Veo、PixVerse、Wan、Happy Horse、Grok Imagine の生成プロトコルと動画理解。即夢は接続予定 | 動画生成は通常タスクを送信してから結果を照会。動画理解はマルチモーダルコンテンツ API を使用  |
| [音声](/simidoc/ja/apps/api/audio)                            | OpenAI、Gemini、MiMo の音声入出力                                                      | ファイルリクエスト、音声バイナリ、ストリームイベントでは応答パーサーを使い分けます         |
| [音声合成](/simidoc/ja/apps/api/audio/speech)                   | テキスト読み上げ                                                                       | 音声ファイル、またはモデルが対応するストリームイベントを返します                  |
| [音声文字起こし](/simidoc/ja/apps/api/audio/transcriptions)        | 音声を元の言語のテキストへ変換                                                                | 音声をアップロードして文字起こし結果を取得                             |
| [音声翻訳](/simidoc/ja/apps/api/audio/translations)             | 音声を英語テキストへ変換                                                                   | アップロードした音声の英語テキストを返します。翻訳音声の出力ではありません             |
| [音楽（未対応）](/simidoc/ja/apps/api/music)                       | Google Lyria の公式呼び出し例                                                          | Google 公式の直接接続リファレンスのみ                            |
| [埋め込み（未対応）](/simidoc/ja/apps/api/pending/embeddings)        | OpenAI、Gemini の公式ベクトル API リファレンス                                               | 各社公式の直接接続リファレンスのみ                                 |
| [再ランキング](/simidoc/ja/apps/api/pending/rerank)               | 文書の関連度による並べ替え                                                                  | ページ記載の各社プロトコルで呼び出します                              |
| [リアルタイム音声](/simidoc/ja/apps/api/pending/realtime)           | OpenAI Realtime プロトコル                                                          | 双方向のリアルタイム接続。通常の HTTP 音声ファイルリクエストではありません          |
| [ツール](/simidoc/ja/apps/api/tools)                           | Function Calling、Web 検索                                                        | モデルからツール呼び出しが返されたら、種類に応じて実行し結果を返します               |
| [コンテンツモデレーション](/simidoc/ja/apps/api/pending/moderations)    | テキストと画像の安全性分類                                                                  | カテゴリ判定とスコアを返します                                   |
| [モデルの取得](/simidoc/ja/apps/api/models)                       | OpenAI 形式と Gemini 形式のモデル一覧                                                     | モデル識別子を返します。一覧表示はすべての機能の利用許可を意味しません               |
| [ファイル認識](/simidoc/ja/apps/api/upload)                       | ファイル内容を対応するマルチモーダルモデルへ渡します                                                     | 独立した Files API とは異なります                            |
| [ファインチューニング（未対応）](/simidoc/ja/apps/api/pending/fine-tuning) | 公式ファインチューニングプロトコルの参考資料                                                         | OpenAI 公式の直接接続リファレンスのみ                            |
| [Files API（未対応）](/simidoc/ja/apps/api/pending/files)        | 公式ファイル管理 API の参考資料                                                             | OpenAI 公式の直接接続リファレンスのみ                            |

## API 説明の読み方

各ページでは、リクエストメソッド、パラメーター、レスポンスのフィールド、コード例、エラー、公式リファレンスを説明します。ゲートウェイの例では SimiRouter キーを使い、直接接続の例ではベンダーの認証情報を使います。「未対応」と記載された機能にはベンダーへの直接接続の参考情報のみを掲載しています。