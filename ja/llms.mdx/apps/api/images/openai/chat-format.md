# 会話形式の画像生成

## API の説明

`POST /v1/responses` は tools に image\_generation を宣言し、対応主モデルが入力に基づき画像を生成します。主 model は会話モデルで、画像ツールのモデル設定は公式の現行範囲に従います。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $API_KEY` です。OpenAI への公式直接接続先は `https://api.openai.com` で、同じ Bearer 認証でも OpenAI のキーに置き換える必要があります。アクセス可能で目的の機能に対応するモデルを選択してください。

OpenAI ネイティブ会話画像生成は Responses の image\_generation で、通常 Chat Completions が Markdown 画像リンクを返す規約ではありません。互換提供元の Chat 画像リンクは拡張であり、OpenAI 標準とは記載しません。

## リクエストパラメータ

| フィールド                                | 型               | 必須  | 説明                                            |
| ------------------------------------ | --------------- | --- | --------------------------------------------- |
| model                                | string          | はい  | image\_generation 対応の Responses 主モデル。         |
| input                                | string / array  | はい  | テキスト指示。編集時は input\_image を含められます。             |
| tools\[].type                        | string          | はい  | image\_generation。                            |
| tools\[].output\_format              | string          | いいえ | png、jpeg、webp。例は png。                         |
| tools\[].size / quality / background | string          | いいえ | 対応するサイズ、品質、背景設定。                              |
| tool\_choice                         | string / object | いいえ | auto はモデルが判断。強制選択はそのツールの対応形式に従います。            |
| previous\_response\_id               | string          | いいえ | 保持された上流応答を継続。同一のアクセス可能文脈が必要で、汎用照会 API はありません。 |
| stream                               | boolean         | いいえ | true で Responses イベントストリーム。                   |

### リクエスト例

```json
{
  "model": "gpt-5.5",
  "input": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。",
  "tools": [
    {
      "type": "image_generation",
      "model": "gpt-image-2",
      "output_format": "png"
    }
  ],
  "stream": false
}
```

## 戻り値

| フィールド                       | 型             | 説明                                                     |
| --------------------------- | ------------- | ------------------------------------------------------ |
| id / status                 | string        | 応答 ID と終状態。completed のみ完全完了。                           |
| output\[].type              | string        | 画像結果は image\_generation\_call。message も同時に存在する場合があります。 |
| output\[].id / status       | string        | 画像呼び出し ID と実行状態。                                       |
| output\[].result            | string        | 最終画像の Base64。data\[].b64\_json ではありません。                |
| output\[].revised\_prompt   | string        | 対応時に画像ツールの書き換えプロンプトを返します。                              |
| output\[].content\[].text   | string        | message 項目に含まれる場合がある説明。                                |
| usage                       | object        | 主モデル用量。画像ツール料金をテキスト Token のみと考えないでください。                |
| error / incomplete\_details | object / null | 失敗と不完全の理由。                                             |

```json
{
  "id": "resp_image_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ig_example",
      "type": "image_generation_call",
      "status": "completed",
      "result": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "error": null,
  "incomplete_details": null
}
```

Base64 は最小 PNG の構造例です。再編集は input\_image と新指示を送るか、対応し文脈保持されたサービスで previous\_response\_id を使用します。任意の応答 ID をチャネル横断の汎用ファイルと扱いません。

## コード例

コード冒頭で `API_URL` と `API_KEY` を設定し。例ではメインモデルに `gpt-5.5`、画像ツールモデルに `gpt-image-2` を使用します。`API_URL` は完全なリクエスト URL で、既定はゲートウェイ `https://api.dwchainless.com` です。例は標準ライブラリのみを使用し、1 回リクエストを送って返却 JSON を標準出力に表示します。画像の自動保存は行いません。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/responses"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
      "tools": [
        {
          "type": "image_generation",
          "model": "gpt-image-2"
        }
      ]
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
    const API_URL = 'https://api.dwchainless.com/v1/responses';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        input: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。',
        tools: [
          {
            type: 'image_generation',
            model: 'gpt-image-2'
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/responses"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
        "tools": [
          {
            "type": "image_generation",
            "model": "gpt-image-2"
          }
        ]
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/responses"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
            "tools": [
                {
                    "type": "image_generation",
                    "model": "gpt-image-2"
                }
            ]
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

## エラーコード

| HTTP ステータス | 意味または各社のエラー型   | 対処                                      |
| ---------- | -------------- | --------------------------------------- |
| 400        | 無効なリクエスト       | 必須項目、JSON、モデルパラメータ、文脈長を確認。              |
| 401        | 認証失敗           | キーの存在、有効性、所属を確認。                        |
| 403 / 404  | アクセス拒否／リソースなし  | モデル権限、リソース ID、URL を確認。                  |
| 429        | レートまたは割り当て制限   | 応答本文でレート制限と残高不足を区別します。残高不足は再試行では解消しません。 |
| 500 / 503  | サービスエラー／一時利用不可 | リクエスト識別子を保持し、一時障害のみ回数制限付きでバックオフ。        |

OpenAI のネイティブエラーには通常 `error.message`、`error.type`、`error.param`、`error.code` が含まれます。`param`、`code` は `null` の場合があり、常に存在することや HTTP 状態との一致は仮定しません。上流到達前のゲートウェイエラーもあります。主応答 completed でも image\_generation\_call.result がなければ文字のみの場合があり、ツール選択と戻り項目を調べ、画像結果を偽装しません。

## 公式資料

* [OpenAI 会話形式画像生成](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI エラー処理](https\://developers.openai.com/api/docs/guides/error-codes)