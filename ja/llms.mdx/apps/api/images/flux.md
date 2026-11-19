# BFL FLUX 画像生成

## 概要

Black Forest Labs（BFL）の FLUX API は「タスク送信 + 結果ポーリング」の非同期モデルを採用しています。送信リクエストはタスク ID と `polling_url` のみを返し、画像生成が完了してからポーリング結果で署名付き URL を読み取ります。

| やりたいこと         | 入力                        | 出力                        | エンドポイント                                         |
| -------------- | ------------------------- | ------------------------- | ----------------------------------------------- |
| テキストから画像を生成    | `prompt`、`width`、`height` | タスクの `id` と `polling_url` | `POST https://api.bfl.ai/v1/flux-pro-1.1`       |
| 比率に応じてワイド画像を生成 | `prompt`、`aspect_ratio`   | タスクの `id` と `polling_url` | `POST https://api.bfl.ai/v1/flux-pro-1.1-ultra` |
| 参考画像から生成または編集  | `prompt` + `input_image`  | タスクの `id` と `polling_url` | `POST https://api.bfl.ai/v1/flux-2-pro` など      |
| 最終画像を取得        | `polling_url`             | `result.sample` の署名付き URL | `GET {polling_url}`                             |

## 中核となる概念

* **寸法は `width` / `height` で指定する**：FLUX 1.1 pro の幅と高さの範囲は 256〜1440 で、32 の倍数でなければなりません。解像度区分でも `size` 文字列でもありません。
* **Ultra は `aspect_ratio` を使用**：`/v1/flux-pro-1.1-ultra` には幅と高さのフィールドがなく、`aspect_ratio` を使用します（既定は `16:9`、ドキュメントの説明範囲は `21:9` から `9:21`）。
* **`seed` は再現性を制御する**：同じプロンプト、パラメータ、`seed` を異なる設定の比較に使用します。モデルやバージョンをまたいで同じ画面が得られる保証はありません。
* **`steps` / `guidance` は一部モデルのみ**：FLUX.2 flex は `steps`（1〜50）と `guidance`（1.5〜10.0）に対応し、FLUX 1.1 pro にはこの 2 つのフィールドがありません。
* **送信と結果は 2 回のリクエスト**：送信は `id`、`polling_url`、任意の `cost` を返します。`Ready` になるまでポーリングしてから `result.sample` で画像を取得します。処理中は `Pending`、失敗やコンテンツ審査では対応する状態が返ります。
* **署名付き URL の有効期間は約 10 分**：`result.sample` はすぐに期限切れになるため、速やかにダウンロードして転送保存し、このアドレスを長期的な公開画像リンクとして扱わないでください。

## 仕様と能力

| エンドポイント                  | 寸法の制御                                                | 参考画像                                           | その他の主なフィールド                                                       | 返却形式                        |
| ------------------------ | ---------------------------------------------------- | ---------------------------------------------- | ----------------------------------------------------------------- | --------------------------- |
| `/v1/flux-pro-1.1`       | `width`、`height`：256〜1440、32 の倍数。既定は 1024×768        | `image_prompt`（Base64、Flux Redux スタイルの参考）      | `seed`、`prompt_upsampling`、`safety_tolerance` 0〜6、`output_format` | ポーリング後に `result.sample` を取得 |
| `/v1/flux-pro-1.1-ultra` | `width` / `height` なし。`aspect_ratio` を使用し、既定は `16:9` | `image_prompt`、`image_prompt_strength` 0.0〜1.0 | `seed`、`prompt_upsampling`、`raw`、`safety_tolerance` 0〜6           | 同上                          |
| `/v1/flux-2-pro`         | `width`、`height`：最小 64、ドキュメントに上限の記載なし                | `input_image` から `input_image_8`、最大 8 枚        | `seed`、`safety_tolerance` 0〜7、`output_format`                     | 同上                          |
| `/v1/flux-2-flex`        | `width`、`height`：最小 64、ドキュメントに上限の記載なし                | `input_image` から `input_image_8`、最大 8 枚        | `steps` 1〜50、`guidance` 1.5〜10.0、`seed`、`output_format`           | 同上                          |

`output_format` は `jpeg`、`png`、`webp` を選択でき、既定は `jpeg` です。表に上限が記載されていないエンドポイントは、対応するエンドポイントの OpenAPI schema に従ってください。あるエンドポイントの幅と高さの制限を別のエンドポイントに適用しないでください。

## 呼び出しフロー

1. **キーを準備**：BFL コンソールで API キーを作成し、リクエストヘッダーで `x-key: $BFL_API_KEY` を使用します。`Authorization: Bearer` ではありません。
2. **エンドポイントを選択**：モデルの能力に応じて `/v1/flux-pro-1.1`、`/v1/flux-pro-1.1-ultra`、その他の `/v1/flux-*` エンドポイントを選択します。
3. **タスクを送信**：JSON を送信し、`prompt`、寸法フィールド、`output_format`、任意の `seed` を設定します。
4. **`polling_url` を保存**：レスポンスから `id` と `polling_url` を読み取り、ポーリングアドレスを自分で組み立てないでください。
5. **`Ready` までポーリング**：同じ `x-key` で `polling_url` をリクエストします。`Pending` では待機を続け、`Error` や審査状態では停止して理由を記録します。
6. **ダウンロードして検証**：署名付き URL が期限切れになる前に `result.sample` をダウンロードし、ファイルが開けるか、寸法と内容を確認してから `cost` と使用ログを照合します。

## シミュレーション呼び出し

以下のメッセージは例示であり、実際のアカウントの戻り値ではありません。タスク ID、URL、費用の数値は構造の説明にのみ使用しています。

送信リクエスト：

```json
{
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "width": 1024,
  "height": 768,
  "seed": 42,
  "output_format": "jpeg",
  "safety_tolerance": 2
}
```

送信成功レスポンス（非同期、画像はまだ未生成）：

```json
{
  "id": "task_example_01",
  "polling_url": "https://api.bfl.ai/v1/get_result?id=task_example_01",
  "cost": 0.04
}
```

ポーリング完了レスポンス（`status` は `Ready`）：

```json
{
  "id": "task_example_01",
  "status": "Ready",
  "progress": 1,
  "result": {
    "sample": "https://delivery.example.bfl.ai/sample/image.jpeg"
  }
}
```

ポーリング中には `Pending`、`Error`、`Request Moderated`、`Content Moderated` などの状態も見られます。審査に通らなかった場合、`result` は `null` になることがあり、理由は `details` に含まれます。

## 接続とセッション

* **ベース URL**：`https://api.bfl.ai`。`https://api.eu.bfl.ai` と `https://api.us.bfl.ai` も提供されています。どの入口を使用しても、レスポンスで返された同じ `polling_url` をポーリングしてください。
* **認証**：`x-key: $BFL_API_KEY`。OpenAI スタイルのインターフェースとの最も明確な違いであり、キーを `Authorization` ヘッダーに入れないでください。
* **完全非同期**：送信リクエストは画像を返さず、`id` と `polling_url` のみを返します。結果を取得するにはさらに `GET` を送信する必要があります。
* **OpenAI との違い**：`/v1/images/generations` エンドポイントがなく、`size`、`quality`、`n` フィールドもありません。寸法は `width` / `height` または `aspect_ratio` で制御します。
* **コールバックによるポーリングの代替**：リクエストに `webhook_url` と `webhook_secret` を含めることができ、BFL が完了時にコールバックします。コールバックを使用する場合も署名を検証し、失敗イベントを処理してください。
* **当サイトのゲートウェイ経由で呼び出す場合**：アドレスを `https://api.dwchainless.com` に置き換え、認証には当サイトのキーを使用します。FLUX は非同期タスクであり、ゲートウェイが `polling_url` と `x-key` ヘッダーを透過するかはチャネルに従います。開放されていない場合は上記の公式アドレスへ直接接続してください。
* **当サイトのゲートウェイ経由で呼び出す場合**：リクエストアドレスと認証方式は当サイトのチャネルの説明に従ってください。本ページのフィールドは BFL ネイティブのプロトコルであり、ゲートウェイに接続する前にモデルの可用性とパラメータの透過範囲を確認してください。
* **タイムアウト**：送信リクエストは速やかに返るはずで、タイムアウト後はタスクが作成済みか先に照会できます。ポーリング間隔は約 0.5 秒を推奨し、全体の待機時間はモデルとキューの長さに応じて上限を設定し、無限に再試行しないでください。

## 公式リファレンス

* [BFL クイックスタート：テキストから画像生成](https\://docs.bfl.ai/quick_start/generating_images)
* [BFL OpenAPI 仕様](https\://api.bfl.ai/openapi.json)
* [BFL API ドキュメント全文](https\://docs.bfl.ai/llms-full.txt)