# OpenAI 形式のモデル一覧

## API の説明

`GET /v1/models` は現在の Key から見えるモデル一覧を返します。設定画面のモデル選択に使用できますが、すべてのモダリティ、ツール、残高、リアルタイムの稼働を保証しません。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。OpenAI への公式直接接続先は `https://api.openai.com` で、同じ Bearer 認証でも OpenAI のキーに置き換える必要があります。アクセス可能で目的の機能に対応するモデルを選択してください。

Bearer 認証だけを送信し、x-api-key や x-goog-api-key を混用しないでください。別の応答形式が選ばれる可能性があります。

## リクエストパラメータ

この一覧リクエストには JSON 本文も必須クエリもありません。

| フィールド         | 型             | 必須 | 説明                        |
| ------------- | ------------- | -- | ------------------------- |
| Authorization | header string | はい | Bearer の後にゲートウェイ Key を指定。 |

## 戻り値

| フィールド                             | 型                      | 説明                                                                                    |
| --------------------------------- | ---------------------- | ------------------------------------------------------------------------------------- |
| object                            | string                 | list。                                                                                 |
| data                              | array                  | モデル一覧。空も許容。                                                                           |
| data\[].id                        | string                 | 生成 API で使用するモデル ID。                                                                   |
| data\[].object                    | string                 | model。                                                                                |
| data\[].created                   | integer                | Unix 秒時刻。ゲートウェイのメタデータはモデル公開日とは限りません。                                                  |
| data\[].owned\_by                 | string                 | モデル所属ラベル。実際に特定の提供元へルーティングされた証明にはなりません。                                                |
| success                           | boolean                | ゲートウェイが追加する業務結果フラグ。OpenAI 標準ではありません。                                                  |
| `data[].context_length`           | integer                | ゲートウェイが返すコンテキスト長（Token 数）です。未設定の場合はプラットフォームの既定値が使われます。モデルのドキュメントとエンドポイントの制限を確認してください。 |
| `data[].supported_endpoint_types` | `array<string>` / null | ゲートウェイが返すエンドポイントの種類です。接続先を選ぶ際の参考にしてください。                                              |

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

空配列も正しい一覧なので、data\[0] を直接参照しないでください。グループ照会失敗では HTTP 200 かつ success=false/message が返る場合があり、業務失敗を判別する必要があります。OpenAI 公式には GET /v1/models/\{model} もありますが、一覧メタデータは完全な機能説明ではありません。

## コード例

`SIMIROUTER_API_KEY` を設定します。既定のゲートウェイアドレスを変更する場合は、`SIMIROUTER_BASE_URL` にバージョン部分を含まないルートアドレスを指定します。どの例もリクエスト本文のない GET を送信します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1/models'
    request = urllib.request.Request(base + path, method="GET",
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
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const endpoint = "/v1/models";
      const response = await fetch(base + endpoint, { method: "GET",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
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
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    curl "${BASE_URL%/}/v1/models" \
      --fail-with-body \
      --max-time 120 \
      -X GET \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      endpoint := "/v1/models"
      req, err := http.NewRequest("GET", base + endpoint, nil); if err != nil { log.Fatal(err) }
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

OpenAI のネイティブエラーには通常 `error.message`、`error.type`、`error.param`、`error.code` が含まれます。`param`、`code` は `null` の場合があり、常に存在する、または HTTP 状態と等しいとは限りません。ゲートウェイが提供元到達前に認証、ルーティング、残高エラーを返すこともあります。HTTP 数値だけで上流由来と判断せず、success=false の業務エラーも確認します。HTTP 通信の成功とは別です。

## 公式資料

* [OpenAI List models](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [OpenAI Retrieve model](https\://developers.openai.com/api/reference/resources/models/methods/retrieve)
* [OpenAI エラー処理](https\://developers.openai.com/api/docs/guides/error-codes)