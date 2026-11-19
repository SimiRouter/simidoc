# Gemini 埋め込み

**SimiRouter は現在この API に未対応です。以下は Google 公式直接接続の参考です。** 例では Google AI Studio の Gemini API キーを使用します。Vertex AI のリクエストパス、プロジェクト設定、認証は Google Cloud のドキュメントに従ってください。

## API の説明

`POST https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent`、認証は `x-goog-api-key: $GEMINI_API_KEY`。例はテキスト入力です。Gemini Embedding 2 は対応するマルチモーダル内容も処理しますが、旧テキスト埋め込みに同じ機能を当てはめないでください。

## リクエストパラメータ

| フィールド                                   | 型         | 必須  | 説明                                                |
| --------------------------------------- | --------- | --- | ------------------------------------------------- |
| model（パス）                               | string    | はい  | models/gemini-embedding-2。利用可能な埋め込みモデルが必要。        |
| content                                 | object    | はい  | 埋め込む Content。テキストは parts\[].text。                 |
| content.parts                           | object\[] | はい  | テキスト、または対応する inline\_data / file\_data マルチモーダル項目。 |
| embedContentConfig                      | object    | いいえ | 埋め込み設定。対応項目はモデル版と API Reference に従います。            |
| embedContentConfig.outputDimensionality | integer   | いいえ | 対応する出力次元数。索引とクエリ側で一致させます。                         |

`gemini-embedding-2` は `embedContentConfig.taskType` / `title` に対応していません。検索タスクでは入力テキストに接頭辞を付けます。

* クエリ：`task: search result | query: {content}`
* ドキュメント：`title: {title} | text: {content}`（タイトルなしは `title: none`）
* 対称タスク：`task: {task} | query: {content}`

`taskType` / `title` は `gemini-embedding-001` のみで使用します。`gemini-embedding-2` はこれらのフィールドに対応しないため、上記の入力プレフィックスを使い、未定義のフィールド処理に依存しないでください。embedding-2 と embedding-001 のベクトル空間は互換性がないため、インデックスとクエリで同じモデルを使用してください。

旧トップレベルの `taskType`、`title`、`outputDimensionality` は旧設定です。SDK は config オブジェクトを使い、snake\_case と HTTP JSON の camelCase を混在させないでください。

## 戻り値

1回の同期要求で `embedding.values` 浮動小数点配列を返します。`batchEmbedContents` は requests 配列を受け取り、`embeddings[]` を入力順に返します。非同期の `asyncBatchEmbedContent` は長時間タスクを返し、状態と出力ファイルの管理が必要です。本ページの同期要求とは異なります。

```json
{"embedding":{"values":[0.01,-0.02,0.03]}}
```

ベクトルは抜粋です。次元短縮時の正規化はモデル資料に従い、最初の3値を完全なベクトルと扱いません。

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

先に `GEMINI_API_KEY` を設定します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent'
    headers = {'x-goog-api-key': os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'models/gemini-embedding-2', 'content': {'parts': [{'text': 'task: search result | query: 如何让文档检索理解语义？'}]}}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent";
      const headers = { "x-goog-api-key": process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "models/gemini-embedding-2",
        "content": {
          "parts": [
            {
              "text": "task: search result | query: 如何让文档检索理解语义？"
            }
          ]
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent", body); check(err)
      req.Header.Set("x-goog-api-key", os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## エラーコード

| HTTP ステータス            | 意味と対処                                                                  |
| --------------------- | ---------------------------------------------------------------------- |
| 400                   | リクエスト項目またはモデルパラメータが不正。修正してから再送してください。                                  |
| 401                   | API Key がない、無効、または期限切れ。                                                |
| 403                   | 現在のプロジェクトまたはモデルへの権限がありません。                                             |
| 404                   | モデルまたはルートが存在しません。アドレスとモデル ID を確認してください。                                |
| 429                   | レートまたは割り当て制限。残高不足とバックオフ可能な制限を区別してください。                                 |
| 500 / 502 / 503 / 504 | サービスまたは上流異常。リクエスト ID を保持して一時的な障害は間隔を空けて再試行し、同じ有料リクエストを無制限に繰り返さないでください。 |

Google のエラーオブジェクトは `error.code`、`error.status`、`error.message` を使用します。HTTP の数字だけで発生元を判断しないでください。このインターフェースは同期リクエストです。タスク ID やポーリング段階はありません。エラー本文を埋め込み結果として扱わないでください。

## 公式資料

[Google Embeddings guide](https\://ai.google.dev/gemini-api/docs/embeddings)、[Embedding API](https\://ai.google.dev/api/embeddings)。