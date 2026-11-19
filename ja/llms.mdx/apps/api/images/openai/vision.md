# 画像理解

## API の説明

`POST /v1/chat/completions` は1つの user メッセージに質問と画像を組み合わせ、文字分析を返します。画像理解は生成・編集ではありません。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $API_KEY` です。OpenAI への公式直接接続先は `https://api.openai.com` で、同じ Bearer 認証でも OpenAI のキーに置き換える必要があります。アクセス可能で目的の機能に対応するモデルを選択してください。

読み取り可能な HTTPS URL または実画像バイトを含む data URL を使用できます。本例はアクセス可能な HTTPS 画像 URL を使用します。

## リクエストパラメータ

| フィールド                       | 型       | 必須   | 説明                                                        |
| --------------------------- | ------- | ---- | --------------------------------------------------------- |
| model                       | string  | はい   | 視覚入力対応のチャットモデル。                                           |
| messages\[].role            | string  | はい   | 画像メッセージは user。                                            |
| messages\[].content         | array   | はい   | 最低限、質問と画像項目を含めます。                                         |
| content\[].type=text / text | string  | 条件付き | 質問テキスト項目。                                                 |
| content\[].type=image\_url  | string  | 条件付き | 画像項目の宣言。                                                  |
| image\_url.url              | string  | はい   | HTTPS URL または data\:image/\{format};base64,...。ローカルパスは不可。 |
| image\_url.detail           | string  | いいえ  | auto、low、high などモデル対応の細部設定。                               |
| max\_completion\_tokens     | integer | いいえ  | 出力 Token 上限。                                              |
| stream                      | boolean | いいえ  | true で Chat SSE。                                          |

PNG、JPEG、WebP などは対応 MIME を使用し、枚数、ピクセル、本文容量もモデル条件を満たします。GIF アニメ、動画、任意バイナリを image/png に変更するだけでは利用できません。

### リクエスト構造

```json
{
  "model": "gpt-5.5",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "描述图片中的主要物体，并指出无法确定的细节。"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/png;base64,BASE64_IMAGE_BYTES",
            "detail": "auto"
          }
        }
      ]
    }
  ],
  "max_completion_tokens": 512,
  "stream": false
}
```

## 戻り値

| フィールド                          | 型                | 説明                                                                     |
| ------------------------------ | ---------------- | ---------------------------------------------------------------------- |
| id / object                    | string           | 応答 ID。object=chat.completion。                                          |
| created / model                | integer / string | 作成時刻（Unix 秒）と応答モデル。                                                    |
| choices\[]                     | array            | 候補応答配列。各 index が位置を示します。                                               |
| choices\[].message.role        | string           | assistant。                                                             |
| choices\[].message.content     | string / null    | テキスト応答。ツール呼び出しや拒否時は空の場合があり、リクエスト失敗とは限りません。                             |
| choices\[].message.tool\_calls | array            | アプリが実行する関数呼び出し。arguments は JSON 文字列なので解析・検証が必要。                        |
| choices\[].message.refusal     | string / null    | 存在する場合の拒否情報。                                                           |
| choices\[].finish\_reason      | string           | stop は正常終了、length は上限到達、tool\_calls はツール呼び出し、content\_filter はフィルタリング。 |
| usage.prompt\_tokens           | integer          | 入力 Token。                                                              |
| usage.completion\_tokens       | integer          | 推論 Token を含む場合がある生成 Token。                                             |
| usage.total\_tokens            | integer          | 入力と生成 Token の合計。                                                       |
| usage.\*\_tokens\_details      | object           | cached\_tokens、reasoning\_tokens など任意の用量内訳。                            |

```json
{
  "id": "chatcmpl_vision_example",
  "object": "chat.completion",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "图中可见一张桌子和一个杯子，杯内物品无法确认。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 280,
    "completion_tokens": 30,
    "total_tokens": 310
  }
}
```

複数画像は image\_url 項目を追加し、比較する順序・目的を文字で示します。ストリームは Chat delta.content を連結します。小文字、精密計数、身元、高リスク判断は視覚結果だけに依存しないでください。

## コード例

コード冒頭で `API_URL` と `API_KEY` を設定し。例では `gpt-5.5` を使用します。`API_URL` は完全なリクエスト URL で、既定はゲートウェイ `https://api.dwchainless.com` です。`IMAGE_URL` はサーバーからアクセスできる HTTPS 画像 URL です。例は標準ライブラリのみを使用し、1 回リクエストを送って返却 JSON を標準出力に表示します。画像の自動保存は行いません。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/chat/completions"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "描述图片中的主要物体。"
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "https://example.com/reference.png"
              }
            }
          ]
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
    const API_URL = 'https://api.dwchainless.com/v1/chat/completions';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: '描述图片中的主要物体。'
              },
              {
                type: 'image_url',
                image_url: {
                  url: 'https://example.com/reference.png'
                }
              }
            ]
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/chat/completions"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "描述图片中的主要物体。"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "https://example.com/reference.png"
                }
              }
            ]
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
        apiURL := "https://api.dwchainless.com/v1/chat/completions"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "描述图片中的主要物体。"
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": "https://example.com/reference.png"
                            }
                        }
                    ]
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

OpenAI のネイティブエラーには通常 `error.message`、`error.type`、`error.param`、`error.code` が含まれます。`param`、`code` は `null` の場合があり、常に存在する、または HTTP ステータスと等しいとは限りません。ゲートウェイが各社に届く前に認証、ルーティング、残高エラーを返す場合があります。HTTP 数値だけで上流由来と判断しないでください。

## 公式資料

* [OpenAI 画像と視覚](https\://developers.openai.com/api/docs/guides/images-vision)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI エラー処理](https\://developers.openai.com/api/docs/guides/error-codes)