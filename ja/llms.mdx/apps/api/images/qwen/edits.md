# Qwen 画像編集

## インターフェースの説明

`POST /v1/images/edits`、本文は JSON です。例では当サイトのゲートウェイ `https://api.dwchainless.com` を使用し、`API_KEY` には当サイトのキーを使います。リクエスト本文は Qwen ネイティブの `model`、`input.messages`、`parameters` 構造をそのまま使い、返却は統一して `data[]` です。

画像編集では content に image 項目と 1 つのテキスト修正指示を入れ、multipart の file フィールドは使用しません。

## リクエストパラメータ

| フィールド                              | 型         | 必須  | 説明                                                               |
| ---------------------------------- | --------- | --- | ---------------------------------------------------------------- |
| model                              | string    | はい  | qwen-image-2.0-pro、または当サイトのチャネルが対応する具体的なバージョン。                   |
| input.messages                     | object\[] | はい  | 単一の user メッセージをちょうど 1 項目。                                        |
| input.messages\[].role             | string    | はい  | 固定で user。                                                        |
| input.messages\[].content\[].text  | string    | はい  | 中国語または英語の指示。1 ターンにつき text 項目を 1 つだけ。                             |
| input.messages\[].content\[].image | string    | はい  | 1 枚または複数枚の参照画像のアクセス可能な URL / data URL。入力数とピクセル制限はモデルのバージョンによります。 |
| parameters.size                    | string    | いいえ | 幅 × 高さ、例：2048 × 2048。2.0 シリーズは総画素数が 512×512 から 2048×2048 の範囲。    |
| parameters.n                       | integer   | いいえ | 既定は 1。2.0 シリーズは 1〜6 に対応。                                         |
| parameters.negative\_prompt        | string    | いいえ | 望まない内容。最大 500 文字。                                                |
| parameters.prompt\_extend          | boolean   | いいえ | 既定は true。肯定プロンプトを自動拡張。                                           |
| parameters.watermark               | boolean   | いいえ | 明示的な透かしを入れるかどうか。適用される合成コンテンツの表示要件に従います。                          |

### 画像仕様：1K・2K・4K

K は解像度の一般的な略称で、ファイルサイズではなく、品質パラメータでもありません。実際の幅と高さはモデルと比率によって変わります。同じ比率で辺を 2 倍にすると、総画素数は 4 倍になります。以下は用語解説のみで、すべてのモデルで使用できるサイズとして直接扱うことはできません。

Qwen では `parameters.size` にモデルが許可する幅と高さを指定し、形式は `2048*2048` のように書きます。`2K` を直接指定するのではありません。2.0 シリーズには総画素数の制限もあり、下の 4K 正方形の図はそのサイズを送信できることを意味しません。

| 解像度の呼称 | 一般的な画素数の目安（モデルの対応を保証するものではありません）      |
| ------ | ------------------------------------- |
| 1K     | 両辺とも ≤ 1024 ピクセル。例：1024×1024。         |
| 2K     | 長辺が > 1024 かつ ≤ 2048 ピクセル。例：1280×720。 |
| 4K     | いずれかの辺が > 2048 ピクセル。例：2560×1440。      |

当サイトの画像単位の課金区分は別のルールであり、上記の用語解説の例をそのまま料金基準に当てはめることはできません。 [画像仕様と課金ルール](/simidoc/ja/apps/api/images)。

## 戻り値

| フィールド                   | 説明                                                |
| ----------------------- | ------------------------------------------------- |
| `created`               | レスポンス生成のタイムスタンプ。                                  |
| `data[].url`            | 生成画像の URL。有効期限はチャネルが決めるため、速やかにダウンロードまたは転存してください。  |
| `data[].b64_json`       | 一部のチャネルは純粋な Base64 を返します。存在する場合はそのままデコードして保存できます。 |
| `data[].revised_prompt` | チャネルが書き換えたプロンプト。存在しない場合があります。                     |
| `error` / `message`     | 失敗時のエラーコードと説明。                                    |

```json
{"created":1760000000,"data":[{"url":"https://example.com/edited.png","b64_json":null,"revised_prompt":"..."}]}
```

## コード呼び出し

コードの先頭で `API_URL`、`API_KEY` を設定します。`API_URL` には当サイトのゲートウェイアドレス `https://api.dwchainless.com/v1/images/edits` を、`API_KEY` には当サイトのキーを使います。例は標準ライブラリのみを使い、1 回リクエストを送って返却 JSON を表示します。画像の自動ダウンロードや保存は行いません。

`IMAGE_URL` には、権限を取得済みでクラウドからアクセスできる実際の HTTP(S) 画像アドレスを設定します。コードは URL の形式だけを確認し、画像がダウンロード可能であることやチャネルの形式制限を満たすことを証明しません。ローカルパス、localhost、ログインが必要な Web ページ、偽のリンクは使用しないでください。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "qwen-image-2.0-pro",
      "input": {
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "image": "https://example.com/reference.png"
              },
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              }
            ]
          }
        ]
      },
      "parameters": {
        "size": "1024*1024",
        "n": 1
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'qwen-image-2.0-pro',
        input: {
          messages: [
            {
              role: 'user',
              content: [
                {
                  image: 'https://example.com/reference.png'
                },
                {
                  text: '保留主体和构图，将背景改为浅蓝色。'
                }
              ]
            }
          ]
        },
        parameters: {
          size: '1024*1024',
          n: 1
        }
      })
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
        "model": "qwen-image-2.0-pro",
        "input": {
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "image": "https://example.com/reference.png"
                },
                {
                  "text": "保留主体和构图，将背景改为浅蓝色。"
                }
              ]
            }
          ]
        },
        "parameters": {
          "size": "1024*1024",
          "n": 1
        }
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
            "model": "qwen-image-2.0-pro",
            "input": {
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "image": "https://example.com/reference.png"
                            },
                            {
                                "text": "保留主体和构图，将背景改为浅蓝色。"
                            }
                        ]
                    }
                ]
            },
            "parameters": {
                "size": "1024*1024",
                "n": 1
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

ローカル実行と返却結果の確認ができるエージェントに、以下のタスクをコピーしてください。まず[このプロトコルの設定](/simidoc/ja/apps/api/images/qwen)に従って、サンプルコードに API\_URL、API\_KEY を直接記入し、model 名を確認します。キーをプロンプトに書き込まないでください。

```text
Read this Qwen image protocol page and its editing reference first. Use the existing
API_KEY and API_URL from this site's gateway; never reveal the key or switch the
existing connection. Verify qwen-image-2.0-pro supports the edit. Use only the
authorized cloud-readable image in IMAGE_URL; do not upload unrelated local files or
publish a file. POST once to /v1/images/edits with the native Qwen body: one user
message containing that image item and one text instruction: keep the subject and
layout; change only the background to pale blue. Set parameters.n=1 and size=1024*1024
only if supported. Do not use OpenAI multipart or mask fields. Check the completed
business result, inspect data[].url or data[].b64_json without forwarding the API key,
and report it. Do not write files, change model/size/count/provider, install remote
skills, or retry automatically. If any step fails or the requested edit is not met,
report a redacted error instead of claiming success.
```

## エラーコード

| エラー                    | 対処                                     |
| ---------------------- | -------------------------------------- |
| 400 / InvalidParameter | content 構造、画像仕様、出力 size、モデル対応パラメータを確認。 |
| 401                    | 当サイトの API Key が存在し、有効で、帰属が正しいか確認。      |
| 403 / 404              | モデル権限、チャネル、リソースが存在するか確認。               |
| 429                    | レート制限または枠不足。原因を確認してからバックオフして再試行。       |
| 5xx                    | サービス異常。リクエスト識別子を記録し、無制限の繰り返し生成を避ける。    |

## 公式リファレンス

[Qwen-Image 編集](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api)、[百錬のエラーコード](https\://www.alibabacloud.com/help/en/model-studio/error-code)。