# 即夢 / Volcengine Ark 画像生成

## 概要

Volcengine Ark の画像生成インターフェースは Seedream シリーズのモデル（`doubao-seedream-*`）を使用し、テキストまたは参考画像から画像を生成します。リクエストは 1 回で送信し、同期的に `data[]` を返します。一部のモデルはストリーミングや一括生成にも対応しています。

| やりたいこと      | 入力                   | 出力    | エンドポイント                                                            |
| ----------- | -------------------- | ----- | ------------------------------------------------------------------ |
| テキストから画像を生成 | `prompt`             | 新しい画像 | `POST https://ark.cn-beijing.volces.com/api/v3/images/generations` |
| 参考画像から生成・編集 | `prompt` + `image`   | 新しい画像 | 同上                                                                 |
| 複数枚を一括生成    | `prompt` + 一括生成パラメータ | 複数の画像 | 同上                                                                 |

## 中核となる概念

* **`size` には 2 つの書き方がある**：解像度区分（例えば `2K`）または明示的なピクセル（例えば `2048x2048`）です。区分はモデルのプリセットであり、固定の幅と高さではありません。同じ区分でも実際の寸法はモデルとプロンプト内の画角の記述で決まります。
* **参考画像は `image` に置く**：HTTP(S) URL または `data:image/...;base64,...` を使用できます。配列を渡すと複数画像の参考になり、枚数の上限はモデルごとに変わります。
* **`watermark` は既定で有効**：既定の `true` では画像に「AI 生成」の表示を追加します。透かしなしで出力する場合は明示的に `false` を渡し、用途が適用される合成コンテンツ表示の要件に適合することを確認してください。
* **同期返却**：通常のリクエストはそのまま `data[]` を待ちます。`stream` は Seedream 5.0 lite、4.5、4.0 など一部のモデルのみで利用でき、ストリーミングパラメータを追加しても他のモデルが非同期タスクになるわけではありません。
* **1 枚単位の課金**：課金は生成枚数に関係します。`sequential_image_generation` の一括出力は実際に生成された画像の枚数で累積され、失敗項目は `data[].error` で個別に返されます。

## 仕様と能力

| モデル ID                            | `size` 区分と上限                                              | 参考画像    | 出力形式                                      |
| --------------------------------- | --------------------------------------------------------- | ------- | ----------------------------------------- |
| `doubao-seedream-5-5-261028`      | `1K`、`1.5K`、`2K` または `WxH`。ピクセル 921600〜4624220、比率 1/16〜16 | 最大 10 枚 | `url` / `b64_json`。`png` が既定で、`jpeg` にも対応 |
| `doubao-seedream-5-0-lite-260128` | `2K`、`3K`、`4K` または `WxH`。ピクセル 3686400〜16777216、比率 1/16〜16 | 最大 14 枚 | `url` / `b64_json`。`png` / `jpeg`         |
| `doubao-seedream-4-5-251128`      | `2K`、`4K` または `WxH`。ピクセル 3686400〜16777216、比率 1/16〜16      | 最大 14 枚 | `url` / `b64_json`。`png` / `jpeg`         |
| `doubao-seedream-4-0-250828`      | `1K`、`2K`、`4K` または `WxH`。ピクセル 921600〜16777216、比率 1/16〜16  | 最大 14 枚 | `url` / `b64_json`。`png` / `jpeg`         |

ピクセル上限は総ピクセル数で計算され、例えば 16777216 ピクセルは 4096×4096 に相当します。モデル ID はバージョンごとに更新されるため、呼び出し前に Volcengine Ark のモデルカタログと[モデルと料金](https://api.dwchainless.com/ja/pricing/)で確認してください。`model` には推論エンドポイント ID（`ep-...`）を指定することもできます。

## 呼び出しフロー

1. **キーを準備**：Volcengine Ark コンソールで API キーを作成し、リクエストヘッダーで `Authorization: Bearer $ARK_API_KEY` を使用します。
2. **モデルとサイズを選択**：モデルが対応する `size` 区分またはピクセル範囲を確認し、参考画像が必要か決定します。
3. **JSON リクエストを送信**：`/api/v3/images/generations` に `model`、`prompt` を送信し、必要に応じて `image`、`size`、`response_format`、`watermark` を追加します。
4. **`data[]` を読み取る**：`response_format` が `url` の場合は `data[].url`（有効期間 24 時間）を取得し、`b64_json` の場合は `data[].b64_json` をデコードします。
5. **保存して検証**：ファイルが開けるか、実際の寸法と内容を確認します。一括生成では `data[].error` を 1 項目ずつ確認し、HTTP ステータスだけを見ないでください。
6. **費用を確認**：使用ログでモデル、枚数、課金を確認します。一括出力は実際に成功した生成枚数で計算されます。

## シミュレーション呼び出し

以下のメッセージは例示であり、実際のアカウントの戻り値ではありません。URL と Base64 は省略され、数値は現在の価格を表しません。

リクエスト：

```json
{
  "model": "doubao-seedream-5-5-261028",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "size": "2K",
  "response_format": "url",
  "watermark": true
}
```

成功レスポンス（同期）：

```json
{
  "created": 1763366400,
  "model": "doubao-seedream-5-5-261028",
  "data": [
    {
      "url": "https://example.com/generated-image.png",
      "size": "2048x2048",
      "output_format": "png"
    }
  ]
}
```

画像が生成されなかった場合はトップレベルの `error` が返ります。一括生成で個々の画像が失敗した場合、失敗項目は `data[].error` 内に `code` と `message` を返します。

## 接続とセッション

* **ベース URL**：`https://ark.cn-beijing.volces.com/api/v3`。
* **認証**：`Authorization: Bearer $ARK_API_KEY`。キーはリクエストヘッダーにのみ置き、プロンプトやソースコードに書き込まないでください。
* **OpenAI Images との違い**：パスは `/api/v3/images/generations` で、`/v1/images/generations` ではありません。`quality` パラメータはありません。`size` には `1K`、`2K` などの区分を直接書けます。`data[].url` または `data[].b64_json` を返します。
* **当サイトのゲートウェイ経由で呼び出す場合**：リクエストアドレスを `https://api.dwchainless.com/v1/images/generations` に変更し、認証には当サイトのキーを使用します。リクエスト本文がそのまま透過されるか、モデル ID が利用可能かはチャネルと[モデルと料金](https://api.dwchainless.com/ja/pricing/)に従います。
* **タイムアウト**：同期生成は数十秒続く場合があり、クライアントのタイムアウトは通常のテキストリクエストより明らかに長くする必要があります。タイムアウト後はまず呼び出しログを確認し、画像と費用がすでに発生していないかを確認してから再試行するか判断してください。
* **一括とストリーミング**：`sequential_image_generation` と `stream` は一部のモデルのみ対応しています。同時に有効化する場合は、最終完了イベントまたは完全な `data[]` で検証し、中間結果を完了画像として数えないでください。

## 公式リファレンス

* [Volcengine Ark 画像生成 API](https\://docs.volcengine.com/docs/82379/1541523)
* [Volcengine Ark の Base URL と認証](https\://docs.volcengine.com/docs/ark/base-url-and-authentication)
* [Seedream シリーズの画像生成と編集](https\://docs.volcengine.com/docs/lake-ai-service/image-generation-and-editing-doubao-seed-ream-series-models?lang=en)