# Web 検索ツール

## API の説明

`POST /v1/responses` は tools に OpenAI の web\_search を宣言し、対応モデルに検索、閲覧、引用付き回答を行わせます。検索は独立した汎用の `/search` エンドポイントでも、すべての Chat モデルが使える関数名でもありません。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。OpenAI への公式直接接続先は `https://api.openai.com` で、同じ Bearer 認証でも OpenAI のキーに置き換える必要があります。アクセス可能で目的の機能に対応するモデルを選択してください。

`{"type":"web_search"}` は Responses 用です。通常の Chat Completions の tools に直接入れないでください。Chat の汎用ツールは function で、公式 Chat 検索の専用モデル・web\_search\_options とは異なるプロトコルです。

## リクエストパラメータ

| フィールド                             | 型               | 必須  | 説明                                                                         |
| --------------------------------- | --------------- | --- | -------------------------------------------------------------------------- |
| model                             | string          | はい  | Responses web\_search 対応モデル。                                               |
| input                             | string / array  | はい  | 質問と必要な背景。                                                                  |
| tools\[].type                     | string          | はい  | web\_search。                                                               |
| tools\[].search\_context\_size    | string          | いいえ | 対応時に low、medium、high の検索文脈を選択。                                             |
| tools\[].filters.allowed\_domains | array           | いいえ | 対応時に許可ドメインを限定。プロトコル接頭辞なし。                                                  |
| tools\[].user\_location           | object          | いいえ | type=approximate、country、city、region、timezone などの概略位置。正確な私的所在地は送信しないでください。 |
| tool\_choice                      | string / object | いいえ | auto はモデル判断、required はツール呼び出しを要求。                                          |
| include                           | array           | いいえ | web\_search\_call.action.sources で全出典一覧を要求可能。                              |
| stream                            | boolean         | いいえ | true で Responses SSE。                                                      |

### リクエスト例

```json
{
  "model": "MODEL_ID",
  "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
  "tools": [
    {
      "type": "web_search"
    }
  ],
  "stream": false
}
```

## 戻り値

| フィールド                                    | 型               | 説明                                    |
| ---------------------------------------- | --------------- | ------------------------------------- |
| output\[].type=web\_search\_call         | object          | 検索・閲覧ツール呼び出し。その存在だけで最終回答の完全性は保証されません。 |
| web\_search\_call.status                 | string          | ツール実行状態。                              |
| web\_search\_call.action                 | object          | search、open\_page、find などの動作とクエリ・URL。 |
| output\[].type=message                   | object          | モデルの最終メッセージ。                          |
| content\[].type / text                   | string          | output\_text 項目の本文。                   |
| content\[].annotations\[]                | array           | 引用一覧。通常 url\_citation。                |
| annotations\[].url / title               | string          | 出典 URL とタイトル。                         |
| annotations\[].start\_index / end\_index | integer         | 引用対象のテキスト範囲。                          |
| status / error / incomplete\_details     | string / object | 応答終状態と失敗・不完全理由。                       |
| usage                                    | object          | モデル Token 用量。検索の追加料金なしとは限りません。        |

```json
{
  "id": "resp_search_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ws_example",
      "type": "web_search_call",
      "status": "completed",
      "action": {
        "type": "search",
        "query": "site:developers.openai.com Responses API"
      }
    },
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "Responses API 支持有类型的输入输出以及工具调用。",
          "annotations": [
            {
              "type": "url_citation",
              "start_index": 0,
              "end_index": 36,
              "title": "Responses API",
              "url": "https://developers.openai.com/api/docs/guides/responses"
            }
          ]
        }
      ]
    }
  ]
}
```

回答表示には明確なクリック可能な引用と出典表示を付けます。Web はデータであり、ページの命令を実行したり認証情報を漏らしたりしないでください。検索結果は古い、矛盾する場合があり、高リスク判断は原資料を確認します。

## コード例

次を設定します：`SIMIROUTER_API_KEY`、`SIMIROUTER_MODEL`；`SIMIROUTER_BASE_URL` で既定のゲートウェイアドレスを変更できます。末尾に `/v1` を追加しないでください。Python 3、Node.js 18+、Go は標準ライブラリのみを使用します。curl 例の JSON は Python 3 で安全にエンコードします。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/responses'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      if (!process.env.SIMIROUTER_MODEL) throw new Error("请设置 SIMIROUTER_MODEL");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const body = {
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = "/v1/responses";
      const response = await fetch(base + endpoint, { method: "POST",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/responses" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "bytes"
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/responses"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
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

OpenAI のネイティブエラーには通常 `error.message`、`error.type`、`error.param`、`error.code` が含まれます。`param`、`code` は `null` の場合があり、常に存在することや HTTP 状態との一致を仮定しません。ゲートウェイが提供元到達前に認証、ルート、残高エラーを返す場合もあります。HTTP 200 でも検索状態、最終回答状態、引用の有無を区別し、出典なしで事実確認済みと宣言しないでください。

## 公式資料

* [OpenAI Web 検索](https\://developers.openai.com/api/docs/guides/tools-web-search)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI エラー処理](https\://developers.openai.com/api/docs/guides/error-codes)