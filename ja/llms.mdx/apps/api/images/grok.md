# xAI Grok 画像生成

## 概要

xAI Grok の画像生成インターフェースは OpenAI Images のパスとレスポンスエンベロープを踏襲しますが、リクエストパラメータは xAI ネイティブのフィールドです。画角は `aspect_ratio` と `resolution` で指定し、`size` ではありません。既定では同期的に返し、`deferred` を有効にするとタスクをポーリングできます。

| やりたいこと            | 入力                          | 出力                    | エンドポイント                                       |
| ----------------- | --------------------------- | --------------------- | --------------------------------------------- |
| テキストから画像を生成       | `prompt`                    | 新しい画像                 | `POST https://api.x.ai/v1/images/generations` |
| 1 回で複数枚を生成        | `prompt` + `n`（1〜10）        | 複数の画像                 | 同上                                            |
| バックグラウンド生成後に結果を取得 | `prompt` + `deferred: true` | `request_id`、その後ポーリング | 同上、`GET /v1/images/{request_id}` をポーリング       |
| 既存画像を編集           | `prompt` + 画像               | 編集後の画像                | `POST https://api.x.ai/v1/images/edits`       |

## 中核となる概念

* **`aspect_ratio` が `size` に代わる**：インターフェースは OpenAI の `size` と `style` を受け付けません。画角は `aspect_ratio` で制御し、一般的な値には `1:1`、`16:9`、`9:16`、`4:3`、`3:4`、`2:3`、`3:2`、`21:9`、`auto` があります。
* **`resolution` は解像度区分を制御する**：`1k` または `2k` を取り、既定は `1k` です。これは区分でありピクセル値ではありません。同じ区分でも実際の幅と高さは `aspect_ratio` で決まります。
* **`quality` は 2.0 モデルのみに有効**：`low`、`medium`、`auto` を選択できます。`auto` は生成時には現在 `low` として処理され、編集時には `medium` として処理されます。
* **既定は同期で、`deferred` は任意の非同期**：同期リクエストはそのまま `data[]` を返します。`deferred: true` を設定すると直ちに `request_id` を返し、その後 `GET /v1/images/{request_id}` をポーリングします。遅延タスクは `response_format: "url"` のみに対応し、結果は 24 時間保持されます。
* **URL は一時的**：`response_format` が `url`（既定）の場合、返される画像アドレスは期限切れになります。長期間保存する必要がある場合は速やかにダウンロードするか、`b64_json` に切り替えてください。
* **1 枚単位の課金**：`n` は 1 回のリクエストで生成する枚数で、範囲は 1〜10 です。レスポンスの `usage.cost_in_usd_ticks` はそのリクエストの費用情報を示し、実際の精算は当サイトの請求に従います。

## 仕様と能力

| モデル ID                   | 解像度区分     | アスペクト比                                                                                                      | 参考画像                                              | 返却形式                 |
| ------------------------ | --------- | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------- | -------------------- |
| `grok-imagine-image-2.0` | `1k`、`2k` | `1:1`、`16:9`、`9:16`、`4:3`、`3:4`、`3:2`、`2:3`、`2:1`、`1:2`、`19.5:9`、`9:19.5`、`20:9`、`9:20`、`21:9`、`5:2`、`auto` | 生成インターフェースは参考画像を受け付けない。編集は `/v1/images/edits` を使用 | `url` または `b64_json` |

`grok-2-image` は旧モデル名で、現行の公式インターフェースドキュメントは `grok-imagine-image-2.0` を使用しています。呼び出し前に[モデルと料金](https://api.dwchainless.com/ja/pricing/)で当サイトのチャネルが実際に提供するモデル ID を確認し、古いチュートリアルの名称をそのまま適用しないでください。

## 呼び出しフロー

1. **キーを準備**：xAI コンソールでキーを作成し、リクエストヘッダーで `Authorization: Bearer $XAI_API_KEY` を使用します。
2. **モデルを確認**：[モデルと料金](https://api.dwchainless.com/ja/pricing/)で `grok-imagine-image-2.0` またはチャネルが提供する同等モデルを確認します。
3. **画角を選択**：`aspect_ratio` と `resolution` を設定し、`size` は送信しないでください。
4. **リクエストを送信**：`/v1/images/generations` に JSON を送信します。所要時間が長くなると予想される場合は `deferred: true` を加えます。
5. **結果を読み取る**：同期レスポンスでは `data[].url` または `data[].b64_json` を取得します。遅延タスクは `done` になるまでポーリングしてから `data[]` を取得します。
6. **保存して検証**：URL が期限切れになる前に画像をダウンロードし、ファイルが開けるか、寸法と内容を確認してから使用ログを照合します。

## シミュレーション呼び出し

以下のメッセージは例示であり、実際のアカウントの戻り値ではありません。URL と費用の数値は省略されているか、例示にすぎません。

同期リクエスト：

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "response_format": "url"
}
```

同期成功レスポンス：

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

遅延タスクのリクエスト：

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "deferred": true
}
```

送信後の例示レスポンス：

```json
{
  "request_id": "req_example_01"
}
```

ポーリング完了の例示レスポンス（HTTP 200。処理中は 202、失敗時は `error.code` と `error.message` を返す）：

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

## 接続とセッション

* **ベース URL**：`https://api.x.ai/v1`。生成エンドポイントは `/v1/images/generations`、編集エンドポイントは `/v1/images/edits` です。
* **認証**：`Authorization: Bearer $XAI_API_KEY`。OpenAI SDK は `base_url` を `https://api.x.ai/v1` に設定して再利用できますが、リクエストフィールドは xAI のドキュメントに従って記入します。
* **OpenAI との違い**：パスと `data[]` エンベロープは似ていますが、`size`、`style` はサポートされません。`aspect_ratio`、`resolution`、`quality` で置き換えます。`n` の上限は 10 です。
* **遅延タスク**：`deferred` は URL 出力のみに対応し、送信後は `GET /v1/images/{request_id}` をポーリングします。結果は 24 時間保持され、期限を過ぎると再生成が必要です。
* **当サイトのゲートウェイ経由で呼び出す場合**：リクエストアドレスを `https://api.dwchainless.com/v1/images/generations` に変更し、認証には当サイトのキーを使用します。モデル ID とパラメータの透過はチャネルに従います。
* **タイムアウト**：同期生成は通常 1 回のリクエスト内で完了しますが、クライアントには十分なタイムアウトを設定してください。所要時間が制御できない場合や一括生成では `deferred` を優先し、タイムアウト後にむやみに再送信しないでください。

## 公式リファレンス

* [xAI 画像生成機能](https\://docs.x.ai/developers/model-capabilities/images/generation)
* [xAI Images REST API リファレンス](https\://docs.x.ai/developers/rest-api-reference/inference/images)