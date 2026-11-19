# 画像生成

## API の説明

`POST /v1/images/generations` は prompt から1枚以上の画像を生成します。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $API_KEY` です。OpenAI への公式直接接続先は `https://api.openai.com` で、同じ Bearer 認証でも OpenAI のキーに置き換える必要があります。アクセス可能で目的の機能に対応するモデルを選択してください。

本ページは GPT Image のパラメータを使用します。互換画像モデルはサイズ、品質、応答形式が異なる場合があり、同一の公式標準として扱いません。

## クイックスタート

1. **設定を準備**：[API Key 管理](https://api.dwchainless.com/keys)でキーを作成し、[モデルと料金](https://api.dwchainless.com/ja/pricing/)から Images API 対応のモデル ID をコピーします。
2. **リクエストを送信**：`https://api.dwchainless.com/v1/images/generations` に JSON を送信します。ヘッダーは `Authorization: Bearer $API_KEY`、本文には少なくとも `model` と `prompt` を含めます。
3. **結果を読み取る**：HTTP 2xx かつ `data[]` が空でない場合のみ成功です。GPT Image の `data[].b64_json` をデコードして保存します。
4. **完了を確認**：ファイルが開けることと必要なサイズを確認し、使用ログを照合します。

最小リクエストは次のとおりです。動作を確認したら、枚数、サイズ、ストリーミングを調整してください：

```bash
API_URL="https://api.dwchainless.com/v1/images/generations"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
    "n": 1,
    "size": "1024x1024",
    "output_format": "png"
  }'
```

## リクエストパラメータ

リクエスト本文は JSON。

| フィールド               | 型       | 必須  | 説明                                                                                                                 |
| ------------------- | ------- | --- | ------------------------------------------------------------------------------------------------------------------ |
| model               | string  | はい  | Images API 対応の画像モデル ID。                                                                                            |
| prompt              | string  | はい  | 被写体、構図、スタイル、文字を具体的に記述。                                                                                             |
| n                   | integer | いいえ | 生成枚数。GPT Image ネイティブは1～10、例は1。                                                                                     |
| size                | string  | いいえ | OpenAI ネイティブは WIDTHxHEIGHT（幅・高さとも 16 の倍数、比率は 1\:3〜3\:1）または auto。SimiRouter は比率と resolution の組み合わせも受け付け、上限はモデル依存です。 |
| resolution          | string  | いいえ | SimiRouter 拡張項目：比率と組み合わせる 1k、2k、4k の段階。ピクセル値ではなく、OpenAI ネイティブ API には存在しません。                                        |
| aspect\_ratio       | string  | いいえ | SimiRouter 拡張項目：3\:4 などの独立した比率。size に比率がある場合は size が優先。                                                            |
| quality             | string  | いいえ | auto、low、medium、high。一部新モデルは xhigh、max にも対応。                                                                       |
| output\_format      | string  | いいえ | png、jpeg（例）、webp。公式スキーマには gif と svg もあり、モデルとプロジェクト権限が対応する場合のみ利用できます。                                               |
| output\_compression | integer | いいえ | JPEG/WebP 圧縮品質0～100。PNG には使用しません。                                                                                  |
| background          | string  | いいえ | auto、opaque、transparent。透明には対応モデルと PNG/WebP が必要。                                                                   |
| moderation          | string  | いいえ | auto、または対応する low。内容ポリシー通過を保証しません。                                                                                  |
| response\_format    | string  | いいえ | 一部の互換モデルは url または b64\_json を受理。GPT Image ネイティブでは使用しません。                                                           |
| stream              | boolean | いいえ | true で画像 SSE。                                                                                                      |
| partial\_images     | integer | いいえ | stream=true で0～3枚の中間画像を要求。最終イベントを待つ必要があります。                                                                        |

GPT Image は Base64 を直接返すため、旧 response\_format=url/b64\_json に依存しないでください。一部の互換モデルではこの項目で URL か Base64 を選べますが、有効かどうかはモデルの説明と実際の応答に従います。旧 style=vivid/natural も使用せず、スタイルは prompt に記述します。

### リクエスト例

```json
{
  "model": "gpt-image-2",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，柔和蓝金色调，不要文字。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

## サイズと形式

K は解像度の一般的な呼称で、ファイル容量や品質設定ではありません。実際の縦横サイズはモデルと縦横比に依存します。同じ縦横比で両辺を2倍にすると、総画素数は4倍になります。以下は用語の説明であり、全モデルで使用可能なサイズではありません。

OpenAI の `size` にはモデルが対応する `1024x1024` などの縦横サイズを指定します。`1K` という呼称は指定しません。`quality` と `output_format` は品質と形式を別々に制御します。

| 解像度の呼称 | 一般的な画素数の例（モデルの対応を保証しません）            |
| ------ | ----------------------------------- |
| 1K     | 1024×1024 · 一辺が約千画素の水準              |
| 2K     | 2048×2048 · 一辺が約二千画素の水準             |
| 4K     | 4096×4096 / 3840×2160 · 一辺が約四千画素の水準 |

本サイトの画像単位の課金区分は別の規則です。この解像度の例をそのまま料金の基準にしないでください。 [画像仕様と課金規則](/simidoc/ja/apps/api/images)。

### size の 3 つの書き方

一部の OpenAI 互換ゲートウェイは、明示ピクセルに加えて比率と解像度、または自動サイズも受け付けます。有効かどうかはモデルとゲートウェイに依存し、非対応の場合は明示ピクセルに戻してください。

| 書き方        | リクエスト断片                            | 説明                                          |
| ---------- | ---------------------------------- | ------------------------------------------- |
| 明示ピクセル（推奨） | `{"size":"1536x2048"}`             | 最も分かりやすく、プリセット換算の差を避けられます。                  |
| 比率 + 解像度   | `{"size":"3:4","resolution":"2k"}` | 2K・3\:4 のプリセットを使用。resolution は 1k、2k、4k のみ。 |
| 自動サイズ      | `{"size":"auto"}`                  | モデルが縦横を選び、固定ピクセルは保証されません。                   |

* size に比率を書くと独立した aspect\_ratio より優先され、明示ピクセルまたは auto は比率プリセットより優先されます。
* 区分は resolution に書き、size=2k は送信しません。寸法の区切りには小文字の x を使います。
* gpt-image-2 の任意サイズの公式上限は 3840×2160 です。4096×4096 などの大きな組み合わせは通常パラメータエラーになります。表の 4K は段階の目安で、そのピクセルサイズが必ず使えるわけではありません。
* 14 のよく使う比率の 1K・2K・4K 早見表は[画像仕様と課金規則](/simidoc/ja/apps/api/images)を参照してください。

## 戻り値

| フィールド                                                | 型       | 説明                                          |
| ---------------------------------------------------- | ------- | ------------------------------------------- |
| created                                              | integer | 作成時刻。Unix 秒。                                |
| data\[]                                              | array   | 生成結果一覧。先頭項目の存在を仮定しません。                      |
| data\[].b64\_json                                    | string  | 画像バイナリの Base64。GPT Image はこの形式。             |
| data\[].url                                          | string  | URL 出力対応の互換モデルのみ。GPT Image 必須フィールドではありません。  |
| data\[].revised\_prompt                              | string  | 一部旧・互換モデルの書き換え指示。GPT Image 必須項目ではありません。     |
| output\_format / size / quality / background         | string  | 任意の実効出力設定。                                  |
| usage                                                | object  | 任意の用量。存在・粒度はモデルとサービス依存。                     |
| usage.input\_tokens / output\_tokens / total\_tokens | integer | 存在時の入力、出力、合計 Token。                         |
| usage.input\_tokens\_details                         | object  | image\_tokens、text\_tokens など任意の内訳。         |
| X-Request-Id                                         | string  | 応答ヘッダーで JSON 項目ではありません。サポートや調査のために保持してください。 |

返された data\[].url には有効期限がある場合があります。画像のダウンロード時に API キーを付けないでください。以下の Base64 は最小 PNG の構造例で、上記指示の実生成結果ではありません。

```json
{
  "created": 1760000000,
  "data": [
    {
      "b64_json": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "output_format": "png"
}
```

### ストリーミング生成

対応モデルは stream=true とし、image\_generation.partial\_image で中間プレビュー、image\_generation.completed で最終画像・用量を受信します。プレビューは最終結果ではなく、completed 前の切断は未完了です。汎用ポーリング用のタスク ID は返しません。

## コード例

コード冒頭で `API_URL` と `API_KEY` を設定し。例では `gpt-image-2` を使用します。`API_URL` は完全なリクエスト URL で、既定はゲートウェイ `https://api.dwchainless.com` です。例は標準ライブラリのみを使用し、1 回リクエストを送って返却 JSON を標準出力に表示します。画像の自動保存は行いません。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/generations"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1,
    }
    request = urllib.request.Request(
        API_URL,
        data=json.dumps(body).encode(),
        method="POST",
        headers={
            "Authorization": "Bearer " + API_KEY,
            "Content-Type": "application/json",
        },
    )
    print(urllib.request.urlopen(request).read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const API_URL = 'https://api.dwchainless.com/v1/images/generations';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        prompt: '一只小机器人在图书馆阅读，水彩插画，不要文字。',
        size: '1024x1024',
        n: 1,
      }),
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/generations"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/images/generations"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
            "size": "1024x1024",
            "n": 1
        }`)
        request, _ := http.NewRequest("POST", apiURL, bytes.NewReader(body))
        request.Header.Set("Authorization", "Bearer "+apiKey)
        request.Header.Set("Content-Type", "application/json")
        response, _ := http.DefaultClient.Do(request)
        defer response.Body.Close()
        result, _ := io.ReadAll(response.Body)
        fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## エージェント呼び出し Demo

ローカル実行と応答確認ができるエージェントに、以下のタスクをコピーしてください。まず[この形式の設定](/simidoc/ja/apps/api/images/openai)に従ってAPI\_URL、API\_KEY、MODEL を例に直接記入します。プロンプトにキーを記載しないでください。

```text
Read this OpenAI image protocol page and its generation reference first. Use the
SimiRouter request URL in API_URL (default gateway https://api.dwchainless.com) and the
image model in MODEL. Set API_KEY directly in the example; never print, paste, commit,
or store it in source files. For this one approved request, use POST
/v1/images/generations with n=1, size=1024x1024, stream=false and output_format=png only
after verifying the model supports these parameters. Image brief: a calm blue library
with a small robot reading, watercolor illustration, no lettering. Print the returned
JSON and inspect data[].b64_json; do not write an image file. Confirm that
data[].b64_json contains non-empty Base64 data before reporting completion. Do not
install remote skills, switch providers/models/billing groups, increase size/count,
write files, or retry after timeout or ambiguous failure without approval. If the
request or validation fails, report a redacted error, not success.
```

## エラーコード

| HTTP ステータス      | 意味または各社のエラー型         | 対処                                      |
| --------------- | -------------------- | --------------------------------------- |
| 400             | 無効なリクエスト             | 必須項目、JSON、モデルパラメータ、文脈長を確認。              |
| 401             | 認証失敗                 | キーの存在、有効性、所属を確認。                        |
| 403 / 404       | アクセス拒否／リソースなし        | モデル権限、リソース ID、URL を確認。                  |
| 413             | リクエスト本文または画像が大きすぎる   | 画像 URL を優先し、Base64 サイズや画像寸法を減らします。      |
| 429             | レートまたは割り当て制限         | 応答本文でレート制限と残高不足を区別します。残高不足は再試行では解消しません。 |
| 500 / 502 / 503 | サービスエラー／上流の混雑／一時利用不可 | リクエスト識別子を保持し、一時障害のみ回数制限付きでバックオフ。        |

OpenAI のネイティブエラーには通常 `error.message`、`error.type`、`error.param`、`error.code` が含まれます。`param`、`code` は `null` の場合があり、常に存在することや HTTP 状態との一致は仮定しません。提供元到達前のエラーもあります。data が空、画像欠落、中間プレビューのみなら HTTP 200 だけで完了と宣言しません。

生成と編集は数十秒から数分かかる場合があります。クライアントのタイムアウトを十分に設定してください。要求の滞留は失敗とは限りません。タイムアウト、ストリーム切断、5xx の後は、再試行する前に要求が実行済みか確認し、重複生成や二重課金を避けます。内容ポリシーによる拒否（通常 400）では、そのまま再試行せずプロンプトや参照画像を修正してください。

## 公式資料

* [OpenAI Create image](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [OpenAI 画像生成ガイド](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI エラー処理](https\://developers.openai.com/api/docs/guides/error-codes)