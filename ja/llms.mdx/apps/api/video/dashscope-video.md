# DashScope 動画生成（Wan / HappyHorse）

## 概要

Wan と HappyHorse はどちらも Alibaba Cloud Model Studio 上の動画生成モデルファミリーであり、同じ DashScope 非同期プロトコルを共有しています。送信エンドポイント、`X-DashScope-Async` ヘッダー、タスク照会パス、ステータス文字列、結果フィールドはすべて同じです。違いは 3 点だけです。モデル ID、入力構造、画角パラメータです。

| やりたいこと                           | 入力                                                          | 出力                        | エンドポイント                                                       |
| -------------------------------- | ----------------------------------------------------------- | ------------------------- | ------------------------------------------------------------- |
| テキストから動画を生成（Wan）                 | プロンプト、`parameters.size`、`duration`                          | `task_id`                 | `POST /api/v1/services/aigc/video-generation/video-synthesis` |
| 先頭フレーム画像から動画を生成（Wan）             | プロンプト、`input.img_url`、`parameters.resolution`               | `task_id`                 | 同じ送信エンドポイント                                                   |
| テキストから動画を生成（HappyHorse）          | プロンプト、`resolution`、`ratio`、`duration`                       | `task_id`                 | 同じ送信エンドポイント                                                   |
| 先頭フレームまたは参照画像から動画を生成（HappyHorse） | `input.media` 内の `first_frame`、または 1〜9 枚の `reference_image` | `task_id`                 | 同じ送信エンドポイント                                                   |
| タスクを照会                           | `task_id`                                                   | `task_status`、`video_url` | `GET /api/v1/tasks/{task_id}`                                 |

## 中核となる概念

* **タスクのライフサイクル**：`PENDING → RUNNING → SUCCEEDED`、失敗の終端状態は `FAILED`、ほかに `CANCELED` と `UNKNOWN` があります。`SUCCEEDED` の場合にのみ `output.video_url` を読み取ります。
* **2 つの ID は役割が異なる**：`output.task_id` はタスク照会に使い、`request_id` は 1 回の HTTP リクエストの追跡にのみ使います。トラブルシューティングでは両方を保存してください。
* **ポーリングの間隔**：公式は 15 秒ごとの照会を推奨しています。タスク ID と結果 URL の有効期間はいずれも 24 時間で、期限を過ぎた照会は `UNKNOWN` を返します。
* **入力構造はモデルファミリーごとに異なる**：Wan の画像から動画生成は `input.img_url` を使います。HappyHorse は `input.media` 配列を使い、各要素に `type`（`first_frame` または `reference_image`）と `url` を持ちます。2 つの構造は相互に置き換えられません。
* **画角パラメータはモデルファミリーごとに異なる**：Wan のテキストから動画生成は `parameters.size`（`宽*高`、例：`1280*720`）、Wan の画像から動画生成は `parameters.resolution`（`480P`、`720P`、`1080P`）を使います。HappyHorse のテキストから動画生成と参照画像から動画生成は `parameters.ratio`（例：`16:9`）を使い、先頭フレームからの画像から動画生成は先頭フレーム画像に従います。
* **音声は一部の Wan 世代のみ**：Wan2.6 と Wan2.5 は映像に合った音楽や効果音を既定で生成し、`input.audio_url` で WAV、MP3 を指定することもできます。Wan2.2 と Wan2.1 は既定で無音の動画を出力します。HappyHorse のドキュメントには音声入力・出力パラメータはありません。
* **課金は出力秒数で計量**：照会レスポンスの `usage.duration` は出力動画の長さです。単価、失敗タスクの精算、返金規則はベンダーの価格ページと請求に従います。

## 仕様と能力

Wan の値：

| 指標            | 確認済みの値                                                                                                                                                                                                        |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| テキストから動画生成モデル | `wan2.6-t2v`、`wan2.5-t2v-preview`、`wan2.2-t2v-plus`、`wan2.1-t2v-turbo`、`wan2.1-t2v-plus`                                                                                                                      |
| 画像から動画生成モデル   | `wan2.6-i2v`、`wan2.6-i2v-flash`、`wan2.5-i2v-preview`、`wan2.2-i2v-plus`、`wan2.2-i2v-flash`、`wan2.1-i2v-turbo`、`wan2.1-i2v-plus`                                                                                |
| 解像度           | テキストから動画生成 `size`：`832*480`、`480*832`、`624*624`、`1280*720`、`720*1280`、`960*960`、`1088*832`、`832*1088`、`1920*1080`、`1080*1920`、`1440*1440`、`1632*1248`、`1248*1632`；画像から動画生成 `resolution`：`480P`、`720P`、`1080P` |
| 長さ            | `wan2.6-t2v` は 2〜15 秒、`wan2.5-t2v-preview` は 5 秒または 10 秒、`wan2.2`、`wan2.1` のテキストから動画生成は固定 5 秒、`wan2.1-i2v-turbo` は 3、4、5 秒に対応                                                                                 |
| 音声            | Wan2.6、Wan2.5 は音楽や効果音を自動生成、`audio_url` は WAV、MP3、3〜30 秒、最大 15 MB に対応。Wan2.2、Wan2.1 は既定で無音                                                                                                                     |
| 参照素材          | 画像から動画生成は `input.img_url` を使用し、パブリック URL または Base64 に対応。画像の幅と高さは 240〜8000 ピクセル、Wan2.6/2.5 は最大 20 MB                                                                                                           |

HappyHorse の値：

| 指標        | 確認済みの値                                                                                                                       |
| --------- | ---------------------------------------------------------------------------------------------------------------------------- |
| モデル ID    | `happyhorse-1.1-t2v`、`happyhorse-1.0-t2v`、`happyhorse-1.1-i2v`、`happyhorse-1.1-r2v`                                          |
| 解像度       | `480P`、`720P`、`1080P`、既定は `1080P`                                                                                            |
| アスペクト比    | テキストから動画生成と参照画像から動画生成：`16:9`（既定）、`9:16`、`1:1`、`4:3`、`3:4`、`4:5`、`5:4`、`9:21`、`21:9`；画像から動画生成は先頭フレームに従い、1\:2.5 から 2.5\:1 まで許可 |
| 長さ        | 3〜15 秒、既定は 5 秒。この範囲は `happyhorse-1.0-t2v`、画像から動画生成、参照画像から動画生成のドキュメントに明記されており、`happyhorse-1.1-t2v` のドキュメントには範囲の記載がありません       |
| 参照画像      | 画像から動画生成は先頭フレーム 1 枚、最短辺 300 ピクセル以上。参照画像から動画生成は 1〜9 枚、最短辺 400 ピクセル以上。1 枚あたり最大 20 MB。形式は JPEG、JPG、PNG、WEBP                     |
| その他のパラメータ | `watermark` の既定は `true` で、有効時は右下に HappyHorse を表示。`seed` の範囲は 0〜2147483647                                                    |

Wan の `size` は具体的なピクセル、`resolution` は段階区分であり、両者は異なるエンドポイントに対応します。テキストから動画生成の 1080P 縦画面は `1080*1920` と記述し、`1080P` とは記述できません。画像から動画生成は逆で、`480P`、`720P`、`1080P` のみを受け付けます。HappyHorse の先頭フレームからの画像から動画生成は `ratio` を読み取らず、出力比率は画像で決まります。Wan2.2 と Wan2.1 のテキストから動画生成は 5 秒固定で、`duration` を延ばしてもより長いクリップは得られません。Wan2.6 と Wan2.5 は音声トラックを自動生成するため、下流で音声が不要な場合は後処理で削除するか、モデルに無効化パラメータがあるかを先に確認してください。参照画像が 1〜9 枚の場合、プロンプト内の `[Image N]` は `media` の順序と一致している必要があり、順序を誤ると参照画像を間違えて指定します。

## 呼び出しフロー

1. Alibaba Cloud Model Studio で API キーを作成します。モデル、リクエストアドレス、キーは同じリージョンに属している必要があり、リージョンをまたぐ呼び出しは失敗します。
2. モデルファミリーとモードを選択します。Wan のテキストから動画生成／画像から動画生成、または HappyHorse のテキストから動画生成／先頭フレームからの画像から動画生成／参照画像から動画生成です。入力構造が異なるため、同じリクエスト本文を流用できません。
3. `POST /api/v1/services/aigc/video-generation/video-synthesis` に JSON を送信し、`Authorization: Bearer`、`Content-Type: application/json`、`X-DashScope-Async: enable` を付けます。
4. `output.task_id` と `request_id` を保存します。作成時に返る `PENDING` はキュー登録に成功したことだけを示します。
5. 15 秒ごとに `GET /api/v1/tasks/{task_id}` を呼び出します。`SUCCEEDED` 後は `output.video_url` を読み取り、`FAILED` の場合は `output.code` と `output.message` を読み取ります。
6. 24 時間以内に動画をダウンロードして転送保存します。タスクの有効期限が切れると照会できなくなり、結果 URL にも依存できなくなります。

## シミュレーション呼び出し

以下は構造を示すためのサンプルメッセージであり、タスク ID、リクエスト ID、URL、使用量はいずれも実際のアカウントのデータではありません。

Wan のテキストから動画生成の作成リクエスト：

```json
{
  "model": "wan2.5-t2v-preview",
  "input": {
    "prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "parameters": {
    "size": "1280*720",
    "duration": 5,
    "prompt_extend": true,
    "watermark": false,
    "seed": 20260804
  }
}
```

HappyHorse の先頭フレームからの画像から動画生成の作成リクエスト：

```json
{
  "model": "happyhorse-1.1-i2v",
  "input": {
    "prompt": "示例：让画面中的帆船缓慢向前移动。",
    "media": [
      {
        "type": "first_frame",
        "url": "https://example.com/demo-first-frame.png"
      }
    ]
  },
  "parameters": {
    "resolution": "720P",
    "duration": 5,
    "watermark": false,
    "seed": 20260804
  }
}
```

両ファミリーの作成成功レスポンス構造は同一で、キュー状態のみを返します：

```json
{
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "PENDING"
  },
  "request_id": "demo-request-0001"
}
```

照会で成功の終端状態を取得：

```json
{
  "request_id": "demo-request-0001",
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "SUCCEEDED",
    "video_url": "https://example.com/demo-video.mp4",
    "orig_prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "usage": {
    "duration": 5,
    "output_video_duration": 5,
    "video_count": 1,
    "SR": 720
  }
}
```

`PENDING`、`RUNNING` は待機を続け、`FAILED`、`CANCELED` は直ちに停止して `output.code` と `output.message` を保存し、`UNKNOWN` はまずタスクが 24 時間を超えていないか確認します。

## 接続とセッション

* **ベースアドレス**：`https://{WorkspaceId}.{region}.maas.aliyuncs.com`。シンガポール、米国、北京、フランクフルト、東京は異なるリージョンホストを使用し、送信と照会のパスは同じです。
* **認証ヘッダー**：`Authorization: Bearer PASTE_API_KEY_HERE`。タスク作成時は必ず `X-DashScope-Async: enable` を追加してください。このヘッダーがないと同期呼び出しのエラーが返ります。
* **2 組のアドレス**：直接接続では `https://{WorkspaceId}.{region}.maas.aliyuncs.com` を使用し、`https://api.dwchainless.com` と `Authorization: Bearer` および当サイトのキーは、チャネルがこのゲートウェイへのマッピングを明示的に確認した場合だけ使用します。アドレスと認証を置き換えるだけでは不十分です。SimiRouter チャネルが統一的なラッピングを行う場合、`task_id`、ステータス文字列、結果フィールドが書き換えられる可能性があります。チャネルのドキュメントに従ってください。
* **タイムアウトと冪等性**：送信がタイムアウトしたら、まず作成済みの可能性がある `task_id` を保存して照会し、直ちに重複送信しないでください。ポーリングリクエスト自体は再試行できますが、全体の待機上限を設定してください。
* **結果の保存**：`video_url` は有効期限付きのダウンロードアドレスです。長期的に使用する場合は、ダウンロード後にトランスコードまたは転送保存し、ベンダー URL をそのまま製品データベースへ永久リソースとして書き込まないでください。

## 公式リファレンス

* [Wan テキストから動画生成 API リファレンス](https\://www.alibabacloud.com/help/en/model-studio/legacy-wan-text-to-video-api-reference)
* [Wan 画像から動画生成 API リファレンス](https\://www.alibabacloud.com/help/en/model-studio/image-to-video-api-reference)
* [Wan2.5 画像から動画生成モデルの説明](https\://www.alibabacloud.com/help/en/model-studio/wan2-5-i2v)
* [HappyHorse テキストから動画生成 API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-text-to-video-api-reference)
* [HappyHorse 先頭フレーム画像から動画生成 API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-image-to-video-api-reference)
* [HappyHorse 参照画像から動画生成 API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-reference-to-video-api-reference)