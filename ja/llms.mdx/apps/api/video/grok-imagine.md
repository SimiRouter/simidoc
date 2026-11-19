# Grok Imagine 動画

## 概要

Grok Imagine は xAI の非同期動画インターフェースを使用します。`POST /v1/videos/generations` でタスクを送信して `request_id` を受け取り、`GET /v1/videos/{request_id}` でポーリングします。テキストプロンプトだけで動画を生成でき、`image` を提供すると画像から動画生成、参考画像やキーフレームを提供すると参考動画生成になります。

| やりたいこと     | 入力                                            | 出力            | エンドポイント                       |
| ---------- | --------------------------------------------- | ------------- | ----------------------------- |
| テキストから動画生成 | `prompt`、長さ、画角、解像度                            | `request_id`  | `POST /v1/videos/generations` |
| 画像から動画生成   | `image` + 任意の `prompt`                        | `request_id`  | 同じエンドポイント                     |
| 参考素材から動画生成 | `prompt` + `reference_images` または `keyframes` | `request_id`  | 同じエンドポイント                     |
| タスクを照会     | `request_id`                                  | 状態、動画 URL、使用量 | `GET /v1/videos/{request_id}` |

## 中核となる概念

* **タスクのライフサイクル**：照会状態は `pending`、`done`、`failed` のみです。`pending` のとき `progress` は 0〜99、`done` のときは 100、`failed` のときは省略される場合があります。
* **`request_id` はポーリングの識別子**：冪等キーではありません。送信がタイムアウトしても「レスポンスを受け取っていない」という理由だけでタスクが未作成と判断せず、存在する可能性のある `request_id` を保存して先に照会してください。
* **ポーリングの間隔**：公式ドキュメントは固定間隔を定めていません。クライアントは 5〜10 秒間隔を使い、全体の待機上限を設定できます。`failed` になったら直ちに停止します。
* **長さと画角**：`duration` の範囲は 1〜15 秒、既定は 8 秒です。画像から動画生成では `aspect_ratio` は無視され、画角は入力画像に従います。`resolution` の既定は `480p` で、`grok-imagine-video-1.5` はネイティブ 1080p に対応します。
* **音声スイッチ**：能力ページには `generate_audio` が記載され、既定は `true` です。`false` にすると無音を要求します。REST リファレンスにはこのフィールドが個別に記載されていないため、実際の可用性はインターフェースの戻り値に従います。
* **課金単位**：照会レスポンスの `usage.cost_in_usd_ticks` は、このタスクのコストカウントです。具体的な換算、単価、失敗時の精算はベンダーの価格ページに従います。

## 仕様と能力

| 指標     | 確認済みの値                                                                             |
| ------ | ---------------------------------------------------------------------------------- |
| モデル ID | `grok-imagine-video-1.5`、`grok-imagine-video-1.5-lite`、`grok-imagine-video`        |
| 解像度    | `480p`（既定）、`720p`、`1080p`。`grok-imagine-video-1.5` はネイティブ 1080p                    |
| アスペクト比 | `1:1`、`16:9`（既定）、`9:16`、`4:3`、`3:4`、`3:2`、`2:3`、`21:9`、`5:2`。画像から動画生成ではこのフィールドを無視  |
| 長さ     | 1〜15 秒、既定は 8 秒。既存動画の編集時はカスタム長さを受け付けない                                              |
| 音声     | `generate_audio` の既定は `true`。`false` で無音を要求。能力ページの説明に従う                            |
| 参照素材   | `image` 先頭フレーム、`reference_images` 参考画像、`keyframes` 最大 4 個、`last_frame` 末尾フレーム（1.5） |
| 画像入力   | 公開 URL、Base64 data URI、xAI Files API の `file_id`。JPEG、PNG、WebP                     |
| 課金計量   | `usage.cost_in_usd_ticks`。単価はベンダーの価格ページに従う                                         |

既定の `480p` はプレビューに適しており、`720p` と `1080p` は生成時間とコストが増えます。画像から動画生成は `aspect_ratio` を無視し、画角は `image` で決まります。横長か縦長かを制御する場合は、入力画像を準備する段階で処理してください。`duration` の既定は 8 秒ですが、実際の所要時間はキューイングの影響も受けるため、長さだけで見積もることはできません。`generate_audio` は能力ページに説明があり REST リファレンスには個別記載がないため、接続前に短いリクエストで現在のモデルがこのフィールドを受け付けるか検証してください。

## 呼び出しフロー

1. xAI コンソールで API キーを作成し、以降のリクエストで `Authorization: Bearer` を使用します。
2. 生成方式を選択します。`prompt` のみならテキストから動画生成、`image` を加えると画像から動画生成、`reference_images`、`keyframes`、`last_frame` を加えると参考素材からの動画生成です。
3. `POST https://api.x.ai/v1/videos/generations` を呼び出し、対象モデルに応じて `duration`、`aspect_ratio`、`resolution`、音声スイッチを設定します。
4. レスポンスの `request_id` を保存します。作成の成功はタスクが受理されたことだけを示します。
5. `GET https://api.x.ai/v1/videos/{request_id}` を `status` が `done` または `failed` になるまでポーリングします。
6. `done` 後に `video.url` をダウンロードします。自分のオブジェクトストレージへ書き込む場合は、リクエストで `output.upload_url` または `storage_options` を使用することもできます。`failed` 時は `error.code` と `error.message` を読み取ります。

## シミュレーション呼び出し

以下は例示メッセージです。`request_id`、URL、使用量は実際のアカウントのデータではありません。

作成リクエスト：

```json
{
  "model": "grok-imagine-video-1.5",
  "prompt": "示例：夜晚的霓虹街道，镜头缓慢前推。",
  "duration": 6,
  "aspect_ratio": "16:9",
  "resolution": "720p",
  "generate_audio": true
}
```

作成に成功するとポーリング識別子が返ります：

```json
{
  "request_id": "demo-request-0001"
}
```

照会で成功の終端状態に到達：

```json
{
  "status": "done",
  "progress": 100,
  "model": "grok-imagine-video-1.5",
  "video": {
    "url": "https://example.com/demo-grok-imagine.mp4",
    "duration": 6,
    "respect_moderation": true
  }
}
```

`pending` ではポーリングを続けます。`failed` では停止して `error` を読み取ります。`video.respect_moderation` が `false` の場合、URL が空になることがあり、再生可能な結果として扱えません。

## 接続とセッション

* **ベースアドレス**：`https://api.x.ai`。生成、照会、編集、延長はそれぞれ `/v1/videos/generations`、`/v1/videos/{request_id}`、`/v1/videos/edits`、`/v1/videos/extensions` です。
* **認証ヘッダー**：`Authorization: Bearer PASTE_API_KEY_HERE`。リクエスト本文は JSON です。
* **2 組のアドレス**：直接接続では `https://api.x.ai` を使います。`https://api.dwchainless.com` と `Authorization: Bearer` および当サイトのキーは、チャネルがこのゲートウェイへのマッピングを明示的に確認した場合だけ使用します。アドレスと認証を置き換えるだけでは不十分です。SimiRouter のチャネルが `/v1/videos/*` を公開するか、`request_id` と状態フィールドを保持するかはチャネルのマッピングで決まります。
* **タイムアウトと冪等性**：公開された冪等キーはありません。送信がタイムアウトした後は、既知の `request_id` を先に照会し、タスクが存在しないことを確認してから再試行してください。待機を避けるために同じプロンプトを並行送信しないでください。
* **結果の保存**：`video.url` は一時アドレスで、ドキュメントにはファイル出力と有効期限のフィールドも記載されています。製品側では先にダウンロードまたは転送保存してから、長期的なリンクを外部へ提供してください。

## 公式リファレンス

* [xAI：Grok Imagine 動画生成](https\://docs.x.ai/developers/model-capabilities/video/generation)
* [xAI：動画 REST API リファレンス](https\://docs.x.ai/developers/rest-api-reference/inference/videos)
* [xAI：画像から動画生成](https\://docs.x.ai/developers/model-capabilities/video/image-to-video)