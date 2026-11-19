# 画像編集・画像から画像生成

## API の説明

`POST /v1/images/edits` は参照画像と編集指示を受け取り、編集後画像を返します。背景、スタイル、要素の追加・削除、複数参照の組み合わせに利用できます。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $API_KEY` です。OpenAI への公式直接接続先は `https://api.openai.com` で、同じ Bearer 認証でも OpenAI のキーに置き換える必要があります。アクセス可能で目的の機能に対応するモデルを選択してください。

JSON の images\[] 参照と multipart アップロードに対応します。例では JSON `images[].image_url` にサーバーからアクセスできる HTTPS 画像 URL を渡し、multipart は使用しません。

## クイックスタート

1. **設定を準備する**\: [API キー管理](https://api.dwchainless.com/keys) でキーを作成し、[モデルと価格](https://api.dwchainless.com/ja/pricing/) から編集対応の画像モデル ID をコピーします。
2. **参照画像を準備する**\: サーバーからアクセスできる HTTPS 画像 URL を使うか、multipart でローカルファイルを送信します。同じリクエストで両方を混在させないでください。
3. **リクエストを送信する**\: `https://api.dwchainless.com/v1/images/edits` に `model`、`prompt`、画像参照を含むリクエストを送信します。ヘッダーは `Authorization: Bearer $API_KEY` です。
4. **結果を読み取り検証する**\: HTTP 2xx かつ `data[]` が空でない場合のみ成功です。`data[].b64_json` をデコードするか `data[].url` をダウンロードし、ファイル、サイズ、内容を確認します。

最初の呼び出しでは 1 枚だけをストリーミングなしで編集し、動作を確認してから参照画像の数やストリーミングを追加してください。

## リクエストパラメータ

| フィールド                | 型       | 必須            | 説明                                                                                                                 |
| -------------------- | ------- | ------------- | ------------------------------------------------------------------------------------------------------------------ |
| model                | string  | はい（ゲートウェイ）    | 編集対応モデルを明示選択し、上流既定値に依存しません。                                                                                        |
| images               | array   | はい（JSON）      | 画像参照一覧。ネイティブ GPT Image は最大16枚で、モデルの制限がより厳しい場合があります。                                                                |
| images\[].image\_url | string  | 条件付き          | HTTPS 画像 URL または data\:image/...;base64,...。このページの例は HTTPS URL を使用します。                                             |
| images\[].file\_id   | string  | 条件付き          | 公式 Files リソース ID。image\_url と択一で、ゲートウェイ利用は仮定不可。                                                                    |
| prompt               | string  | はい            | 変更対象と保持対象を明示。                                                                                                      |
| mask                 | object  | いいえ           | JSON は mask.image\_url または mask.file\_id。マスク規則はモデル依存。                                                              |
| image / image\[]     | file    | はい（multipart） | multipart の1枚以上の画像。JSON images と混在不可。                                                                              |
| mask（multipart）      | file    | いいえ           | 透明領域が編集範囲を示す PNG マスク。元画像サイズとモデル条件を満たす必要があります。                                                                      |
| input\_fidelity      | string  | いいえ           | 対応モデルのみ指定可能。全 GPT Image 世代での対応を仮定しません。                                                                             |
| n                    | integer | いいえ           | 生成枚数。GPT Image ネイティブは1～10、例は1。                                                                                     |
| size                 | string  | いいえ           | OpenAI ネイティブは WIDTHxHEIGHT（幅・高さとも 16 の倍数、比率は 1\:3〜3\:1）または auto。SimiRouter は比率と resolution の組み合わせも受け付け、上限はモデル依存です。 |
| resolution           | string  | いいえ           | SimiRouter 拡張項目：比率と組み合わせる 1k、2k、4k の段階。ピクセル値ではなく、OpenAI ネイティブ API には存在しません。                                        |
| aspect\_ratio        | string  | いいえ           | SimiRouter 拡張項目：3\:4 などの独立した比率。size に比率がある場合は size が優先。                                                            |
| quality              | string  | いいえ           | auto、low、medium、high。一部新モデルは xhigh、max にも対応。                                                                       |
| output\_format       | string  | いいえ           | png、jpeg（例）、webp。公式スキーマには gif と svg もあり、モデルとプロジェクト権限が対応する場合のみ利用できます。                                               |
| output\_compression  | integer | いいえ           | JPEG/WebP 圧縮品質0～100。PNG には使用しません。                                                                                  |
| background           | string  | いいえ           | auto、opaque、transparent。透明には対応モデルと PNG/WebP が必要。                                                                   |
| moderation           | string  | いいえ           | auto、または対応する low。内容ポリシー通過を保証しません。                                                                                  |
| response\_format     | string  | いいえ           | 一部の互換モデルは url または b64\_json に対応。GPT Image ネイティブでは使用しません。                                                           |
| stream               | boolean | いいえ           | true で画像 SSE。                                                                                                      |
| partial\_images      | integer | いいえ           | stream=true で0～3枚の中間画像を要求。最終イベントを待つ必要があります。                                                                        |

JSON と multipart は択一。multipart の Content-Type boundary はクライアントに自動作成させます。マスクによるピクセル単位の正確性は保証されず、最終画像は人が確認します。

## 画像の送信方法を選ぶ

参照画像の渡し方は 4 通りです。実行環境に合わせて 1 つを選び、同じリクエストで混在させないでください。

| 方法             | フィールド                           | 用途                                       |
| -------------- | ------------------------------- | ---------------------------------------- |
| JSON URL       | `images[].image_url`            | 画像が公開されており、サーバーから直接アクセスできる               |
| JSON Base64    | `images[].image_url` の data URL | 画像が小さく、公開 URL を出したくない                    |
| multipart ファイル | `image` または `image[]`           | ローカルファイルをクライアントから直接アップロードする              |
| Files リソース ID  | `images[].file_id`              | 公式 Files でアップロード済みで、ゲートウェイがその ID に対応している |

JSON リクエストは `Content-Type: application/json` を使用します。multipart の `Content-Type` はクライアントが boundary を生成するため、手書きしないでください。

### JSON リクエスト構造

JSON 例はサーバーからアクセスできる HTTPS 画像 URL を直接使用します。

```json
{
  "model": "gpt-image-2",
  "images": [
    {
      "image_url": "https://example.com/reference.png"
    }
  ],
  "prompt": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

### multipart リクエスト構造

ローカルの参照画像が 1 枚なら `image` フィールド、複数なら `image[]` を使い、各画像の用途を順番に説明します。

```bash
API_URL="https://api.dwchainless.com/v1/images/edits"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -F "model=gpt-image-2" \
  -F "prompt=保留主体和构图，将背景改为浅蓝色。" \
  -F "image=@reference.png" \
  -F "size=1024x1024" \
  -F "n=1"
```

## 編集プロンプトの書き方

編集プロンプトは保持する項目と変更する項目を同時に示す必要があります。「水彩にする」とだけ書くと、モデルが画面全体を描き直すことがあります。「保持 + 変更 + 制約」の順で組み立ててください。

| シナリオ       | プロンプトの要点                     | 例                              |
| ---------- | ---------------------------- | ------------------------------ |
| 人物や商品を保持する | 被写体、姿勢、構図、文字を変えないことを明示       | 人物の姿勢と服装を保ち、背景だけを淡い青に変更する。     |
| スタイル変換     | 目標スタイルと保持すべきレイアウトを示す         | 水彩イラスト調に変更し、元の構図と被写体の位置を保つ。    |
| 部分修正       | 変更する領域を指定。対応モデルでは `mask` を併用 | 画面左下のカップだけを変更し、それ以外はそのままにする。   |
| 複数画像の合成    | 各画像の役割、被写体の関係、最終レイアウトを示す     | 1 枚目が人物、2 枚目が背景。人物を背景の中央に配置する。 |

「保持」は目標でありピクセル単位の保証ではありません。人物、商品、文字の細部は変化する可能性があり、身元やブランドに関わる内容は人が確認する必要があります。透明背景にはモデルの `background: transparent` 対応と、PNG または WebP 出力が必要です。

## サイズと形式

`size` にはモデルが許容するピクセル幅と高さ（例：`1024x1024`）を指定します。`quality` は品質、`output_format` は PNG/JPEG/WebP エンコードを制御します。編集結果のサイズは `size` で決まり（省略時は `auto` でモデルが選択）、参照画像と完全に一致する必要はありません。

本サイトの 1K、2K、4K の画像単位課金段階とベンダーの解像度呼称は別の規則です。size の 3 通りの書き方、14 比率の早見表、課金境界は[画像仕様と課金規則](/simidoc/ja/apps/api/images)にまとめています。

## 戻り値

| フィールド                                                | 型       | 説明                                                |
| ---------------------------------------------------- | ------- | ------------------------------------------------- |
| created                                              | integer | 作成時刻。Unix 秒。                                      |
| data\[]                                              | array   | 生成結果一覧。先頭項目の存在を仮定しません。                            |
| data\[].b64\_json                                    | string  | 画像バイナリの Base64。GPT Image はこの形式。                   |
| data\[].url                                          | string  | URL 出力対応の互換モデルのみ。GPT Image 必須フィールドではありません。        |
| data\[].revised\_prompt                              | string  | 一部旧・互換モデルの書き換え指示。GPT Image 必須項目ではありません。           |
| output\_format / size / quality / background         | string  | 任意の実効出力設定。                                        |
| usage                                                | object  | 任意の用量。存在・粒度はモデルとサービス依存。                           |
| usage.input\_tokens / output\_tokens / total\_tokens | integer | 存在時の入力、出力、合計 Token。                               |
| usage.input\_tokens\_details                         | object  | image\_tokens、text\_tokens など任意の内訳。               |
| X-Request-Id                                         | string  | レスポンスヘッダーで JSON フィールドではありません。サポートや調査のために保持してください。 |

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

例の Base64 はフィールド構造を示す最小 PNG です。返される data\[].url には有効期限がある場合があり、画像をダウンロードするときに API Key を付けないでください。ストリーム編集は image\_edit.partial\_image と image\_edit.completed を使用し、最終イベントのみ完了とします。画像から画像への生成は人物、商品、文字の細部のピクセル単位の保持を保証しません。

## コード呼び出し

コード冒頭で `API_URL` と `API_KEY` を設定します。例では `gpt-image-2` を使用します。`API_URL` は完全なリクエスト URL で、既定はゲートウェイ `https://api.dwchainless.com` です。`IMAGE_URL` はサーバーからアクセスできる HTTPS 画像 URL です。例は標準ライブラリのみを使用し、1 回リクエストを送って返却 JSON を標準出力に表示します。画像の自動保存は行いません。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "images": [{"image_url": "https://example.com/reference.png"}],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        images: [
          {
            image_url: 'https://example.com/reference.png',
          },
        ],
        prompt: '保留主体和构图，将背景改为浅蓝色。',
        size: '1024x1024',
        n: 1,
      }),
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/edits"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-image-2",
        "images": [
          {
            "image_url": "https://example.com/reference.png"
          }
        ],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
        apiURL := "https://api.dwchainless.com/v1/images/edits"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "images": [
                {
                    "image_url": "https://example.com/reference.png"
                }
            ],
            "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
Read this OpenAI image protocol page and its editing reference first. Set API_KEY,
MODEL, and API_URL directly in the example; use the configured SimiRouter request URL;
never reveal the key or change the existing connection. Use only the authorized HTTPS
image URL in IMAGE_URL. Use POST /v1/images/edits with JSON images[]; do not set
multipart Content-Type or send local files. Keep the subject and layout; change only the
background to pale blue. Request one PNG at 1024x1024 with stream=false only if the
selected model supports it. Print the returned JSON and inspect data[].b64_json; do not
write an image file. Confirm that data[].b64_json contains non-empty Base64 data and
report any unmet requirement. Do not upload unrelated files, change
size/count/model/provider, install remote skills, or retry automatically after an error
or timeout. Ask before another paid request.
```

## エラーコード

| HTTP ステータス      | 意味または各社のエラー型        | 対処                                      |
| --------------- | ------------------- | --------------------------------------- |
| 400             | 無効なリクエスト            | 必須項目、JSON、モデルパラメータ、文脈長を確認。              |
| 401             | 認証失敗                | キーの存在、有効性、所属を確認。                        |
| 403 / 404       | アクセス拒否／リソースなし       | モデル権限、リソース ID、URL を確認。                  |
| 413             | リクエスト本文または画像が大きすぎる  | 画像 URL を優先し、Base64 のサイズや画像の寸法を小さくします。   |
| 429             | レートまたは割り当て制限        | 応答本文でレート制限と残高不足を区別します。残高不足は再試行では解消しません。 |
| 500 / 502 / 503 | サービスエラー／上流混雑／一時利用不可 | リクエスト識別子を保持し、一時障害のみ回数制限付きでバックオフ。        |

OpenAI のネイティブエラーには通常 `error.message`、`error.type`、`error.param`、`error.code` が含まれます。`param`、`code` は `null` の場合があり、常に存在することや HTTP 状態との一致は仮定しません。提供元到達前のエラーもあります。不正画像、MIME 不一致、マスクサイズ不一致、未対応引数は入力エラーのため、反復送信せず修正します。

編集には数十秒から数分かかる場合があります。リクエストが保留中でも失敗とは限らないため、クライアントのタイムアウトを十分に設定してください。タイムアウト、ストリーム切断、5xx の後は、まずリクエストがすでに実行されたかを確認してから再試行し、二重生成や二重課金を避けます。内容ポリシーによる拒否（通常 400）では、同じ内容で再試行せず、プロンプトや参照画像を修正してください。

## 公式資料

* [OpenAI Create image edit](https\://developers.openai.com/api/reference/resources/images/methods/edit)
* [OpenAI 画像生成・編集](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI エラー処理](https\://developers.openai.com/api/docs/guides/error-codes)