# ファイル一覧

現在のプロジェクトでアクセス可能なファイルをページング照会します。

**SimiRouter は現在この API に未対応です。以下は OpenAI 公式リファレンスで、接続先は `api.openai.com`。OpenAI プロジェクトのキーが必要で、SimiRouter Key は使用できません。**

## API の説明

* **メソッド**：`GET`
* **API アドレス**：`/v1/files`
* **認証**：`Authorization: Bearer $OPENAI_API_KEY`
* **リクエスト型**：本文なし。

現在ページの JSON を同期返却。`has_more=true` の場合は次ページ要求が必要で、1回で全件は返りません。

## リクエストパラメータ

| パラメータ     | 型           | 必須  | 説明                                 |
| --------- | ----------- | --- | ---------------------------------- |
| `after`   | string、クエリ  | いいえ | 前ページ末尾のファイル ID。                    |
| `limit`   | integer、クエリ | いいえ | 1ページ1～10000件、既定10000。例は20。         |
| `order`   | string、クエリ  | いいえ | 作成時刻順：`asc` または `desc`、既定は `desc`。 |
| `purpose` | string、クエリ  | いいえ | 指定用途だけを返します。                       |

## 戻り値

| フィールド                  | 型             | 説明                     |
| ---------------------- | ------------- | ---------------------- |
| `object`               | string        | 一覧型。通常 `list`。         |
| `data`                 | FileObject\[] | 現在ページのファイル。下記オブジェクト項目。 |
| `first_id` / `last_id` | string        | 現在ページ先頭・末尾のファイル ID。    |
| `has_more`             | boolean       | 次ページがあるか。              |

| フィールド            | 型                    | 説明                                                                              |
| ---------------- | -------------------- | ------------------------------------------------------------------------------- |
| `id`             | string               | 後続要求で参照するファイル ID。                                                               |
| `object`         | string               | 固定値は `file`。                                                                    |
| `bytes`          | integer / null       | ファイルサイズ（バイト）。未取得時は null の場合があります。                                               |
| `created_at`     | integer              | 作成時刻。Unix 秒。                                                                    |
| `filename`       | string               | アップロード時のファイル名。                                                                  |
| `purpose`        | string               | ファイル用途。例：`fine-tune`、`user_data`。生成結果ファイルでは `fine-tune-results` などを使用する場合があります。 |
| `expires_at`     | integer / null、任意    | 有効期限。Unix 秒。未設定時は空の場合があります。                                                     |
| `status`         | string、非推奨           | 旧状態フィールド：`uploaded`、`processed` または `error`。利用先 API 自身の処理状態の代わりにしないでください。       |
| `status_details` | string / null、任意、非推奨 | 旧状態の説明。学習データ検証エラーはタスクの `error` を確認します。                                          |

```json
{
  "object": "list",
  "data": [
    {
      "id": "file-demo",
      "object": "file",
      "bytes": 4096,
      "created_at": 1793491200,
      "filename": "training.jsonl",
      "purpose": "fine-tune",
      "expires_at": null
    }
  ],
  "first_id": "file-demo",
  "last_id": "file-demo",
  "has_more": false
}
```

## コード例

実行環境：Python 3、Node.js 20+、curl、Go 1.20+。各言語の例をそれぞれ `.py`、`.cjs`、`.sh`、`.go` ファイルとして保存して実行します。

次を設定します：`OPENAI_API_KEY` を読みます。例は最初の20件を取得し、次ページには前ページの `last_id` を `after` クエリとして指定します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    def required(name):
        value = os.environ.get(name)
        if not value:
            raise SystemExit(f"请设置 {name}")
        return value

    key = required("OPENAI_API_KEY")

    request = urllib.request.Request(
        "https://api.openai.com/v1/files?limit=20&order=desc",
        method="GET",
        data=None,
        headers={"Authorization": "Bearer " + key},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = response.read()
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    print(json.dumps(json.loads(result), ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    function required(name) {
      const value = process.env[name];
      if (!value) throw new Error(`请设置 ${name}`);
      return value;
    }
    async function main() {
      const key = required("OPENAI_API_KEY");

      const response = await fetch("https://api.openai.com/v1/files?limit=20&order=desc", {
        method: "GET",
        headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(JSON.stringify(await response.json(), null, 2));
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"

    curl "https://api.openai.com/v1/files?limit=20&order=desc" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request GET \
      --header "Authorization: Bearer $OPENAI_API_KEY"
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
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func required(name string) string {
    	value := os.Getenv(name)
    	if value == "" {
    		log.Fatal("请设置 " + name)
    	}
    	return value
    }
    func main() {
    	key := required("OPENAI_API_KEY")

    	req, err := http.NewRequest("GET", "https://api.openai.com/v1/files?limit=20&order=desc", nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 120 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	result, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, result)
    	}
    	fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## エラーコード

以下は OpenAI 公式直接接続の一般的な HTTP エラーで、SimiRouter の対応状況ではありません。

| HTTP ステータスコード | 意味                      | 対処                                            |
| ------------- | ----------------------- | --------------------------------------------- |
| `400`         | パラメータ、ファイル用途、資源状態が要件不適合 | 次を読み取り、`error.message` と `error.param`修正後に再送。 |
| `401`         | キーがない、または無効             | OpenAI キーと所属プロジェクトを確認。                        |
| `403`         | プロジェクト・資源へのアクセス不可       | プロジェクト、組織、ロール権限を確認。                           |
| `404`         | ファイル、タスク、モデルが存在しない      | ID を確認し、資源所属プロジェクトのキーを使用。                     |
| `429`         | レート制限または残高不足            | レートと残高を区別。前者はバックオフ、後者は再送しません。                 |
| `500` / `503` | サーバー異常・一時利用不可           | ID を保持し、書き込みは作成済みか確認して重複アップロード・学習を防ぎます。       |

失敗応答には通常 `error.message`、`error.type`、`error.param` と `error.code` が含まれます。フィールドが空の場合もあります。

## 公式資料

* [OpenAI ファイル一覧](https\://developers.openai.com/api/reference/resources/files/methods/list)
* [OpenAI エラーコード](https\://developers.openai.com/api/docs/guides/error-codes)