# Gemini 形式のモデル一覧

## API の説明

`GET /v1beta/models` は Gemini 形式のモデル一覧を返します。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。Google への公式直接接続先は `https://generativelanguage.googleapis.com`、通常は `x-goog-api-key: $GEMINI_API_KEY` を使用し、ゲートウェイの Bearer Key ではありません。アクセス可能で目的の入力形式に対応するモデルを選択してください。

ゲートウェイ一覧は主にモデル名の取得用であり、Google ネイティブの完全な機能カタログではありません。

## リクエストパラメータ

ゲートウェイの一覧リクエストは本文不要で、ページング値も要求しません。Google ネイティブ models.list は pageSize（既定50、最大1000）と pageToken に対応しますが、現在のゲートウェイは全体一覧を返し、同等のページング・メタデータを保証しません。

| フィールド                | 型                      | 必須        | 説明                                        |
| -------------------- | ---------------------- | --------- | ----------------------------------------- |
| Authorization        | header string          | はい        | ゲートウェイ Key の Bearer。公式直接接続では Google Key。  |
| pageSize / pageToken | query integer / string | ネイティブのみ任意 | 公式ネイティブ一覧のページング用。ゲートウェイによる処理を前提にしないでください。 |

## 戻り値

| フィールド                                        | 型              | 説明                                                             |
| -------------------------------------------- | -------------- | -------------------------------------------------------------- |
| models                                       | array          | モデル一覧。空の場合があります。                                               |
| models\[].name                               | string         | モデルリソース名。公式は通常 models/\{id}、ゲートウェイは ID を直接返す場合があります。           |
| models\[].displayName                        | string         | 表示名。                                                           |
| nextPageToken                                | string / null  | 公式の次ページトークン。ゲートウェイはページングなしを示す null の場合があります。                   |
| models\[].version / description              | string / null  | 公式で提供されるバージョン・説明。ゲートウェイでは省略または null の場合があります。                  |
| models\[].inputTokenLimit / outputTokenLimit | integer / null | 公式で提供される入出力制限。欠落値から推測しないでください。                                 |
| models\[].supportedGenerationMethods         | array / null   | 公式で提供される generateContent などのメソッド名。ゲートウェイでは省略または null の場合があります。 |

```json
{
  "models": [
    {
      "name": "MODEL_ID",
      "displayName": "MODEL_ID"
    }
  ],
  "nextPageToken": null
}
```

上記はゲートウェイの簡略構造例です。name をパスに使う前に、先頭の models/ を 1 回だけ削除します。models.list が成功しても、generateContent は権限、機能、割り当てなどで失敗する場合があります。

## コード例

`SIMIROUTER_API_KEY` を設定します。既定のゲートウェイアドレスを変更する場合は、`SIMIROUTER_BASE_URL` にバージョン部分を含まないルートアドレスを指定します。どの例もリクエスト本文のない GET を送信します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1beta/models'
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
      const endpoint = "/v1beta/models";
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
    curl "${BASE_URL%/}/v1beta/models" \
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
      endpoint := "/v1beta/models"
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

| HTTP ステータス | 意味または各社のエラー型               | 対処                                      |
| ---------- | -------------------------- | --------------------------------------- |
| 400        | `INVALID_ARGUMENT` など      | JSON、モデルパラメータ、メディア MIME、入力長を確認します。      |
| 403        | `PERMISSION_DENIED`        | キー、プロジェクト権限、地域、請求上の制限を確認します。            |
| 404        | `NOT_FOUND`                | モデル名と API バージョンを確認します。                  |
| 429        | `RESOURCE_EXHAUSTED`       | レートと割り当てを確認し、再試行可能な場合のみ回数制限付きでバックオフします。 |
| 500 / 503  | `INTERNAL` / `UNAVAILABLE` | リクエスト識別子を記録し、回数制限付きの再試行または後で再実行します。     |

Google のネイティブエラーオブジェクトには `error.code`（HTTP 数値）、`error.status`（列挙名）、`error.message` が含まれ、追加で `details` が含まれる場合があります。ゲートウェイが提供元到達前に認証、ルーティング、残高エラーを返すこともあります。HTTP 数値だけで上流由来と判断せず、内部照会の HTTP 200、success=false の業務エラーも確認してください。

## 公式資料

* [Google Models API](https\://ai.google.dev/api/models)
* [Google モデルカタログ](https\://ai.google.dev/gemini-api/docs/models)
* [Google トラブルシューティング](https\://ai.google.dev/gemini-api/docs/troubleshooting)