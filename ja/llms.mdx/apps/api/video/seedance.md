# Seedance 動画

## API の説明

Seedance は、テキストから動画生成と、モデルが許可する画像・動画・音声の参照入力に対応しています。Volcengine Ark の公式フローは、非同期タスクの作成、状態照会、成功後のダウンロードです。

| 操作 | 公式パス                                          | 文書                 |
| -- | --------------------------------------------- | ------------------ |
| 作成 | `POST /api/v3/contents/generations/tasks`     | [タスクの作成](/simidoc/ja/apps/api/video/seedance/create) |
| 照会 | `GET /api/v3/contents/generations/tasks/{id}` | [タスクの照会](/simidoc/ja/apps/api/video/seedance/status) |

公式ベース URL は `https://ark.cn-beijing.volces.com`、認証は `ARK_API_KEY` による Bearer 認証。`/v1/video/generations` はゲートウェイの互換パスであり、Volcengine Ark の公式アドレスではありません。チャネルが明示的にマッピングを提供する場合のみ使用し、id/status を別メーカーの形式に自動変換しないでください。

状態は `queued → running → succeeded` で、失敗の終了状態は failed、expired、cancelled です。SSE や Realtime ではありません。音声付き動画、参照素材、長さ、解像度の対応範囲はモデルのバージョンによって決まります。

## 公式資料

[動画タスクの作成](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)、[タスクの照会](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)、[動画チュートリアル](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh)。