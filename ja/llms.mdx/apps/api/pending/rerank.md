# 文書の再ランキング

## API の説明

再ランキングは query と候補文書を比較し、関連度順の index とスコアを返します。回答や埋め込みベクトルは生成しません。SimiRouter の `/v1/rerank` の利用可否はチャネル確認が必要です。以下は **Cohere 公式** `POST https://api.cohere.com/v2/rerank`、認証は `Authorization: Bearer $COHERE_API_KEY` を使用します。

## リクエストパラメータ

| フィールド                 | 型         | 必須  | 説明                                              |
| --------------------- | --------- | --- | ----------------------------------------------- |
| model                 | string    | はい  | 例：rerank-v5.0-pro。開通済みモデルを使用。                   |
| query                 | string    | はい  | 検索クエリ。                                          |
| documents             | string\[] | はい  | 候補テキスト配列。公式は一度に1000件以下を推奨。構造化内容は YAML 文字列化できます。 |
| top\_n                | integer   | いいえ | 最低1。省略すると全結果を返します。                              |
| max\_tokens\_per\_doc | integer   | いいえ | 既定4096。長文書は切り詰め。                                |
| relevant\_spans       | object    | いいえ | v5 以降の対応モデルで関連テキスト範囲を返せます。                      |
| priority              | integer   | いいえ | 0～999、既定0。小さいほど優先度が高い。                          |

Cohere v2 の documents は文字列配列です。未定義のオブジェクトを混在させないでください。`return_documents` は別バージョンのため、本例では送信しません。

## 戻り値

`results[]` は関連度順で、`index` は元文書の添字、`relevance_score` は関連度スコアです。対応時に有効にすると `relevant_spans[]` を返します。スコアは正解率でもモデル間共通の確率でもありません。`meta.billed_units` は用量を記録します。

```json
{"results":[{"index":1,"relevance_score":0.95},{"index":0,"relevance_score":0.12}],"id":"request_example","meta":{"api_version":{"version":"2"}}}
```

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

Cohere 公式の `COHERE_API_KEY` を設定します。top\_n は正数を使い、query と文書を空にしないでください。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.cohere.com/v2/rerank'
    headers = {'Authorization': 'Bearer ' + os.environ['COHERE_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'rerank-v5.0-pro', 'query': '法国首都是哪里？', 'documents': ['柏林是德国首都。', '巴黎是法国首都。'], 'top_n': 2}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.cohere.com/v2/rerank";
      const headers = { "Authorization": "Bearer " + process.env.COHERE_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
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
    curl "https://api.cohere.com/v2/rerank" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $COHERE_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "rerank-v5.0-pro",
        "query": "法国首都是哪里？",
        "documents": [
          "柏林是德国首都。",
          "巴黎是法国首都。"
        ],
        "top_n": 2
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
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
    }`)
      req, err := http.NewRequest("POST", "https://api.cohere.com/v2/rerank", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("COHERE_API_KEY"))
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

| HTTP ステータス            | 説明                             |
| --------------------- | ------------------------------ |
| 400 / 422             | 引数またはモデルが受け付けない入力。             |
| 401 / 498             | 認証失敗または無効な token。              |
| 403 / 404             | 権限不足またはリソースなし。                 |
| 429                   | レート制限。割り当て確認と回数制限付きバックオフ。      |
| 499                   | クライアントが接続を閉じました。               |
| 500 / 501 / 503 / 504 | 内部エラー、未実装、タイムアウト。リクエスト ID を保持。 |

## 公式資料

[Cohere Rerank v2](https\://docs.cohere.com/reference/rerank)。