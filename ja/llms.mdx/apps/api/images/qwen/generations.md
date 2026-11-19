# Qwen 画像生成

## インターフェースの説明

`POST /v1/images/generations`、本文は JSON です。例では当サイトのゲートウェイ `https://api.dwchainless.com` を使用し、`API_KEY` には当サイトのキーを使います。リクエスト本文は Qwen ネイティブの `model`、`input.messages`、`parameters` 構造をそのまま使い、返却は統一して `data[]` です。

テキストから画像生成では text の content 項目だけが必要です。入力テキストで構図、視覚スタイル、描画したい文字を記述します。

## リクエストパラメータ

| フィールド                             | 型         | 必須  | 説明                                                            |
| --------------------------------- | --------- | --- | ------------------------------------------------------------- |
| model                             | string    | はい  | qwen-image-2.0-pro、または当サイトのチャネルが対応する具体的なバージョン。                |
| input.messages                    | object\[] | はい  | 単一の user メッセージをちょうど 1 項目。                                     |
| input.messages\[].role            | string    | はい  | 固定で user。                                                     |
| input.messages\[].content\[].text | string    | はい  | 中国語または英語の指示。1 ターンにつき text 項目を 1 つだけ。                          |
| parameters.size                   | string    | いいえ | 幅 × 高さ、例：2048 × 2048。2.0 シリーズは総画素数が 512×512 から 2048×2048 の範囲。 |
| parameters.n                      | integer   | いいえ | 既定は 1。2.0 シリーズは 1〜6 に対応。                                      |
| parameters.negative\_prompt       | string    | いいえ | 望まない内容。最大 500 文字。                                             |
| parameters.prompt\_extend         | boolean   | いいえ | 既定は true。肯定プロンプトを自動拡張。                                        |
| parameters.watermark              | boolean   | いいえ | 明示的な透かしを入れるかどうか。適用される合成コンテンツの表示要件に従います。                       |

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
{"created":1760000000,"data":[{"url":"https://example.com/generated.png","b64_json":null,"revised_prompt":"..."}]}
```

## コード呼び出し

コードの先頭で `API_URL`、`API_KEY` を設定します。`API_URL` には当サイトのゲートウェイアドレス `https://api.dwchainless.com/v1/images/generations` を、`API_KEY` には当サイトのキーを使い、モデルの可用性は[モデルと料金](https://api.dwchainless.com/ja/pricing/)に従います。例は標準ライブラリのみを使い、1 回リクエストを送って返却 JSON を表示します。画像の自動ダウンロードや保存は行いません。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/generations"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "qwen-image-2.0-pro",
      "input": {
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "text": "生成一张浅蓝色背景的活动海报，不要文字。"
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
    const API_URL = 'https://api.dwchainless.com/v1/images/generations';
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
                  text: '生成一张浅蓝色背景的活动海报，不要文字。'
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
    API_URL="https://api.dwchainless.com/v1/images/generations"
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
                  "text": "生成一张浅蓝色背景的活动海报，不要文字。"
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
        apiURL := "https://api.dwchainless.com/v1/images/generations"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "qwen-image-2.0-pro",
            "input": {
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "text": "生成一张浅蓝色背景的活动海报，不要文字。"
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
Read this Qwen image protocol page and its generation reference first. Use the
existing API_KEY and API_URL from this site's gateway; never print, paste, commit,
or store the key in source files. Use the documented qwen-image-2.0-pro model only
after checking availability and pricing. For this one approved request, POST once
to /v1/images/generations with the native Qwen body: one user message, one text
content item, parameters.n=1 and size=1024*1024 if supported. Image brief: a calm
blue library with a small robot reading, watercolor illustration, no lettering.
Print the returned JSON and inspect data[].url or data[].b64_json; report the final
image URL without forwarding the API key. JSON or a URL alone is not a saved image.
Do not switch model/provider, increase size/count, write files, install remote
skills, or automatically retry an error or timeout. Ask before another paid request.
```

## エラーコード

| エラー                    | 対処                                       |
| ---------------------- | ---------------------------------------- |
| 400 / InvalidParameter | JSON、content 構造、画像仕様、size、モデル対応パラメータを確認。 |
| 401                    | 当サイトの API Key が存在し、有効で、帰属が正しいか確認。        |
| 403 / 404              | モデル権限、チャネル、リソースが存在するか確認。                 |
| 429                    | レート制限または枠不足。原因を確認してからバックオフして再試行。         |
| 5xx                    | サービス異常。リクエスト識別子を記録し、無制限の繰り返し生成を避ける。      |

## 公式リファレンス

[Qwen-Image 生成](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api)、[百錬のエラーコード](https\://www.alibabacloud.com/help/en/model-studio/error-code)。