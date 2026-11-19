# OpenAI 埋め込み

**SimiRouter は現在この API に未対応です。以下は OpenAI 公式直接接続の参考です。**

## API の説明

`POST https://api.openai.com/v1/embeddings`，`Content-Type: application/json`，`Authorization: Bearer $OPENAI_API_KEY`。1要求で完全なベクトルを返し、SSE には対応しません。

## リクエストパラメータ

| フィールド            | 型                             | 必須  | 説明                                                             |
| ---------------- | ----------------------------- | --- | -------------------------------------------------------------- |
| model            | string                        | はい  | text-embedding-3-small、text-embedding-3-large など利用可能な埋め込みモデル。  |
| input            | string / string\[] / token 配列 | はい  | 非空のテキストまたは token。配列最大2048項目、1入力8192 tokens、1要求合計300000 tokens。 |
| dimensions       | integer                       | いいえ | 正の整数。text-embedding-3 と対応する後継モデルは次元短縮可能。                       |
| encoding\_format | string                        | いいえ | float（既定）は浮動小数点配列、base64 はエンコード文字列。                            |
| user             | string                        | いいえ | 個人の平文情報を含めないエンドユーザー識別子。                                        |

## 戻り値

| フィールド                                        | 説明                                     |
| -------------------------------------------- | -------------------------------------- |
| `object`                                     | list。                                  |
| `data[].object`                              | embedding。                             |
| `data[].index`                               | 対応する入力配列位置。                            |
| `data[].embedding`                           | encoding\_format に応じたベクトル配列または Base64。 |
| `model`                                      | 使用モデル。                                 |
| `usage.prompt_tokens` / `usage.total_tokens` | token 集計。                              |

以下は中間要素を省略した構造例です：

```json
{"object":"list","data":[{"object":"embedding","index":0,"embedding":[0.01,-0.02]}],"model":"text-embedding-3-small","usage":{"prompt_tokens":3,"total_tokens":3}}
```

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

次を設定します：`OPENAI_API_KEY`。同期バッチ入力の例で、index が2つの入力に対応します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/embeddings'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'text-embedding-3-small', 'input': ['语义搜索', '文档检索'], 'encoding_format': 'float'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/embeddings";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
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
    curl "https://api.openai.com/v1/embeddings" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "text-embedding-3-small",
        "input": [
          "语义搜索",
          "文档检索"
        ],
        "encoding_format": "float"
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
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/embeddings", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

エラー本文の `error.message`、`error.type`、`error.code` は HTTP ステータスより具体的な原因を示します。このインターフェースは同期リクエストです。タスク ID やポーリング段階はありません。エラー本文を埋め込み結果として扱わないでください。

## 公式資料

[OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings/methods/create)、[Embeddings guide](https\://developers.openai.com/api/docs/guides/embeddings)。