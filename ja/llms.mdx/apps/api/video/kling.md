# Kling 動画

## API の説明

Kling 公式新版の動画 API は、機能／モデルのパス、settings/options、統一タスク照会を使用します。

| 操作         | 現在の公式 API                                         | 文書                                          |
| ---------- | ------------------------------------------------- | ------------------------------------------- |
| テキストから動画生成 | `POST /text-to-video/kling-3.0`                   | [作成](/simidoc/ja/apps/api/video/kling/text-create) / [照会](/simidoc/ja/apps/api/video/kling/text-status)   |
| 画像から動画生成   | `POST /image-to-video/kling-3.0`                  | [作成](/simidoc/ja/apps/api/video/kling/image-create) / [照会](/simidoc/ja/apps/api/video/kling/image-status) |
| 照会         | `GET /tasks?task_ids=...` または external\_task\_ids | 汎用タスク照会                                     |

本セクションの例は `https://api-singapore.klingai.com` に直接接続し、Kling 公式 API Key による Bearer 認証を使用します。旧アカウントの AK/SK + HS256 JWT は旧版の設計仕様にのみ適用されます。SimiRouter Key や生の SecretKey を Kling Key として使用しないでください。

## 新旧プロトコルは混在不可

旧版の `/v1/videos/text2video`、`/v1/videos/image2video` は model\_name、task\_id、task\_status、succeed を使用します。新版はルート内のモデル、data.id、status、succeeded を使用します。公式には旧エンドポイントの legacy 参考情報もありますが、新版のリクエストに旧版フィールドを追加しないでください。SimiRouter の `/kling/...` はゲートウェイのマッピングです。チャネルのバージョンを確認する必要があり、新しい公式パスにプレフィックスを追加するだけでは利用できません。

生成は非同期処理であり、SSE ではありません。作成後にポーリングまたは callback を受信し、成功の終了状態になってから outputs 内の video 項目を使用します。

## 公式資料

[Kling テキストから動画生成](https\://kling.ai/document-api/apiReference/model/textToVideo)、[画像から動画生成](https\://kling.ai/document-api/apiReference/model/imageToVideo)、[認証](https\://kling.ai/document-api/api/get-started/authentication)。