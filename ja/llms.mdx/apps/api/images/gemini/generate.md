# Gemini 画像生成

## API の説明

`POST /v1beta/models/{model}:generateContent` は対応する Gemini モデルで画像を生成し、出力には文字と画像が交互に含まれる場合があります。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $API_KEY` です。Google への公式直接接続先は `https://generativelanguage.googleapis.com`、通常は `x-goog-api-key: $GEMINI_API_KEY` を使用し、ゲートウェイの Bearer Key ではありません。アクセス可能で目的の入力形式に対応するモデルを選択してください。

本ページは GenerateContent REST を使用します。Google Interactions の画像処理に使う input、steps、response\_format と、こちらの contents、candidates、generationConfig は異なるため混在させないでください。

## リクエストパラメータ

| フィールド                                    | 型      | 必須  | 説明                                                        |
| ---------------------------------------- | ------ | --- | --------------------------------------------------------- |
| model（パス）                                | string | はい  | generateContent と画像出力の両方に対応する Gemini 画像モデル。テキスト専用は使用しません。 |
| contents                                 | array  | はい  | メッセージ配列。テキストから画像生成は通常1つの user メッセージ。                      |
| contents\[].role                         | string | いいえ | user。複数ターン履歴のモデル応答は model。                                |
| contents\[].parts\[].text                | string | はい  | 画像の説明または編集指示。                                             |
| generationConfig.responseModalities      | array  | いいえ | 例：\["TEXT","IMAGE"]。テキストと画像を要求。利用できる組み合わせはモデル依存。          |
| generationConfig.imageConfig.aspectRatio | string | いいえ | 対応時は 1\:1、16\:9、9\:16 などの比率。                              |
| generationConfig.imageConfig.imageSize   | string | いいえ | 対応時に1K、2K、4Kなどを指定。選択モデルと一致が必要で、全画像モデル対応ではありません。           |

不要な任意設定は省略します。テキスト専用に imageConfig を足しても画像能力は得られません。新しい出力設定と旧画像モデルでは対応範囲が異なるため、ここでは responseModalities の明確な例を使用します。

### 画像仕様：1K・2K・4K

K は解像度の一般的な呼称で、ファイル容量や品質設定ではありません。実際の縦横サイズはモデルと縦横比に依存します。同じ縦横比で両辺を2倍にすると、総画素数は4倍になります。以下は用語の説明であり、全モデルで使用可能なサイズではありません。

対応モデルでは、Gemini の `generationConfig.imageConfig.imageSize` に `1K`・`2K`・`4K` を、`generationConfig.imageConfig.aspectRatio` に縦横比を指定します。実際の縦横サイズは選択したモデルの仕様で確認してください。

| 解像度の呼称 | 一般的な画素数の例（モデルの対応を保証しません）            |
| ------ | ----------------------------------- |
| 1K     | 1024×1024 · 一辺が約千画素の水準              |
| 2K     | 2048×2048 · 一辺が約二千画素の水準             |
| 4K     | 4096×4096 / 3840×2160 · 一辺が約四千画素の水準 |

本サイトの画像単位の課金区分は別の規則です。この解像度の例をそのまま料金の基準にしないでください。 [画像仕様と課金規則](/simidoc/ja/apps/api/images)。

### リクエスト例

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。"
        }
      ]
    }
  ],
  "generationConfig": {
    "responseModalities": [
      "TEXT",
      "IMAGE"
    ]
  }
}
```

## 戻り値

| フィールド                          | 型       | 説明                                       |
| ------------------------------ | ------- | ---------------------------------------- |
| candidates\[]                  | array   | 候補一覧。安全フィルタにより空の場合があります。                 |
| candidates\[].content.parts\[] | array   | 順序付きのテキスト、画像、思考断片。先頭だけを読まないでください。        |
| parts\[].text                  | string  | 説明文。存在するかはモデルが決定。                        |
| parts\[].inlineData.mimeType   | string  | image/png、image/jpeg など画像の実 MIME。        |
| parts\[].inlineData.data       | string  | 純粋な Base64 画像データ。data\: 接頭辞なし。           |
| parts\[].thought               | boolean | 任意の思考フラグ。thought=true の中間画像を最終画像と扱いません。  |
| parts\[].thoughtSignature      | string  | 任意の不透明署名。複数ターン編集ではそのまま保持し、自作・変更しません。     |
| candidates\[].finishReason     | string  | STOP は正常完了。MAX\_TOKENS、SAFETY などは区別して処理。 |
| promptFeedback                 | object  | 任意の入力ブロック情報。                             |
| usageMetadata                  | object  | 入力、候補、思考、合計 Token 用量。モデルに応じて存在。          |

以下の Base64 は最小 PNG の構造例で、上記プロンプトから実際に生成した画像ではありません。

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "已根据描述生成图片。"
          },
          {
            "inlineData": {
              "mimeType": "image/png",
              "data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
            }
          }
        ]
      },
      "finishReason": "STOP"
    }
  ]
}
```

parts を順に走査し、thought でない inlineData を MIME に合う拡張子で保存します。parts\[0] が画像とは限りません。テキストのみ・フィルタ済みの場合は画像なしと報告します。

### ストリーミングとバッチ

対応モデルは streamGenerateContent?alt=sse を使えますが、画像断片が単独デコード可能な最終ファイルとは限りません。モデルのイベント形式に従います。generateContent 自体は同期で照会タスクを返さず、Google Batch は独立した非同期サービスです。

## コード例

コード冒頭で `API_URL` と `API_KEY` を設定し。例では `gemini-3-pro-image` を使用します。`API_URL` は完全なリクエスト URL で、既定はゲートウェイ `https://api.dwchainless.com` です。例は標準ライブラリのみを使用し、1 回リクエストを送って返却 JSON を標準出力に表示します。画像の自動保存は行いません。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
            }
          ]
        }
      ],
      "generationConfig": {
        "responseModalities": [
          "TEXT",
          "IMAGE"
        ]
      }
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
    const API_URL = 'https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。'
              }
            ]
          }
        ],
        generationConfig: {
          responseModalities: [
            'TEXT',
            'IMAGE'
          ]
        }
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
              }
            ]
          }
        ],
        "generationConfig": {
          "responseModalities": [
            "TEXT",
            "IMAGE"
          ]
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "contents": [
                {
                    "role": "user",
                    "parts": [
                        {
                            "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
                        }
                    ]
                }
            ],
            "generationConfig": {
                "responseModalities": [
                    "TEXT",
                    "IMAGE"
                ]
            }
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

ローカル実行と応答確認ができるエージェントに、以下のタスクをコピーしてください。まず[この形式の設定](/simidoc/ja/apps/api/images/gemini)に従ってAPI\_URL、API\_KEY、MODEL を例に直接記入します。プロンプトにキーを記載しないでください。

```text
Read this Gemini protocol page and the GenerateContent image generation reference first.
Use the configured SimiRouter request URL in API_URL (default gateway
https://api.dwchainless.com) and MODEL. Set API_KEY directly in the example; never
print, paste, commit, or store it in source files. For this one approved task, call POST
/v1beta/models/{model}:generateContent once, non-streaming, Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. with a text Part describing a calm blue library with a small robot reading,
watercolor, no lettering. Request one image; use imageConfig aspectRatio=1:1 and
imageSize=1K only if the model supports them. Do not invent an n parameter or mix
Interactions fields into GenerateContent. After the response, read only completed,
non-thought inlineData from parts; decode the Base64 in memory and report any unmet
requirement; do not write an image file. Do not switch providers/models/billing groups,
increase size/count, write files, install remote skills, or retry an ambiguous failure
without approval. Report a redacted error instead of false success.
```

## エラーコード

| HTTP ステータス | 意味または各社のエラー型               | 対処                                      |
| ---------- | -------------------------- | --------------------------------------- |
| 400        | `INVALID_ARGUMENT` など      | JSON、モデルパラメータ、メディア MIME、入力長を確認します。      |
| 403        | `PERMISSION_DENIED`        | キー、プロジェクト権限、地域、請求上の制限を確認します。            |
| 404        | `NOT_FOUND`                | モデル名と API バージョンを確認します。                  |
| 429        | `RESOURCE_EXHAUSTED`       | レートと割り当てを確認し、再試行可能な場合のみ回数制限付きでバックオフします。 |
| 500 / 503  | `INTERNAL` / `UNAVAILABLE` | リクエスト識別子を記録し、回数制限付きの再試行または後で再実行します。     |

Google のネイティブエラーオブジェクトには `error.code`（HTTP 数値）、`error.status`（列挙名）、`error.message` が含まれ、追加で `details` が含まれる場合があります。ゲートウェイが提供元到達前に認証、ルート、残高エラーを返す場合があります。HTTP 数値だけで由来を判断せず、HTTP 200 でも非 thought 画像がなければ画像生成成功としないでください。

## 公式資料

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 画像生成・編集](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Google モデルカタログ](https\://ai.google.dev/gemini-api/docs/models)
* [Google トラブルシューティング](https\://ai.google.dev/gemini-api/docs/troubleshooting)