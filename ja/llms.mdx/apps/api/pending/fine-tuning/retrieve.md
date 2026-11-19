# 学習タスク詳細

学習状態、設定、出力モデル、失敗詳細を読み取ります。

**SimiRouter は現在この API に未対応です。以下は OpenAI 公式リファレンスで、接続先は `api.openai.com`。OpenAI プロジェクトのキーが必要で、SimiRouter Key は使用できません。**

## API の説明

* **メソッド**：`GET`
* **API アドレス**：`/v1/fine_tuning/jobs/{fine_tuning_job_id}`
* **認証**：`Authorization: Bearer $OPENAI_API_KEY`
* **リクエスト型**：本文なし。

現在のスナップショットを同期返却し、学習終了を待ちません。適切な間隔で照会し、`succeeded`のみ学習成功、`failed`では `error`，`cancelled`はキャンセル済み。

## リクエストパラメータ

| パラメータ                | 型         | 必須 | 説明                                                |
| -------------------- | --------- | -- | ------------------------------------------------- |
| `fine_tuning_job_id` | string、パス | はい | タスク ID。コードは `OPENAI_FINE_TUNING_JOB_ID` から読み取ります。 |

## 戻り値

| フィールド              | 型                 | 説明                                                                                             |
| ------------------ | ----------------- | ---------------------------------------------------------------------------------------------- |
| `id` / `object`    | string            | タスク ID。オブジェクト型は `fine_tuning.job`。                                                             |
| `model`            | string            | 学習に使用する基礎モデル。                                                                                  |
| `status`           | string            | `validating_files`、`queued`、`running`、`pausing`、`paused`、`succeeded`、`failed` または `cancelled`。 |
| `created_at`       | integer           | 作成時刻。Unix 秒。                                                                                   |
| `finished_at`      | integer / null    | 完了時刻。未終了時は空。                                                                                   |
| `estimated_finish` | integer / null、任意 | 完了予測時刻。保証ではありません。                                                                              |
| `fine_tuned_model` | string / null     | 出力モデル ID。未生成時は空。                                                                               |
| `training_file`    | string            | 学習ファイル ID。                                                                                     |
| `validation_file`  | string / null     | 検証ファイル ID。未指定時は空。                                                                              |
| `result_files`     | string\[]         | 公式 Files API から取得可能な結果ファイル ID。                                                                 |
| `trained_tokens`   | integer / null    | 課金対象の学習 token 数。処理中は空の場合があります。                                                                 |
| `error`            | object / null     | 失敗詳細。`code`、`message`、`param` を含み、パラメータエラー以外では `param` は空の場合があります。                             |
| `organization_id`  | string            | タスク所属組織。                                                                                       |
| `seed`             | integer / null    | 今回のランダムシード。                                                                                    |
| `method`           | object / null、任意  | 学習方法と対応設定。                                                                                     |
| `hyperparameters`  | object / null、任意  | 教師あり学習の互換ハイパーパラメータ。                                                                            |
| `integrations`     | array / null、任意   | 有効化された外部指標連携。                                                                                  |
| `metadata`         | object / null、任意  | タスクの独自メタデータ。                                                                                   |

応答例（主要項目のみ、実タスクではありません）：

```json
{
  "id": "ftjob-demo",
  "object": "fine_tuning.job",
  "model": "selected-base-model",
  "created_at": 1793491200,
  "finished_at": null,
  "fine_tuned_model": null,
  "status": "queued",
  "training_file": "file-training",
  "validation_file": null,
  "result_files": [],
  "trained_tokens": null,
  "error": null,
  "organization_id": "org-demo",
  "seed": null,
  "method": {
    "type": "supervised"
  },
  "metadata": {}
}
```

## コード例

実行環境：Python 3、Node.js 20+、curl、Go 1.20+。各言語の例をそれぞれ `.py`、`.cjs`、`.sh`、`.go` ファイルとして保存して実行します。

次を設定します：`OPENAI_API_KEY` と `OPENAI_FINE_TUNING_JOB_ID`。

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
    job_id = required("OPENAI_FINE_TUNING_JOB_ID")
    job_id_encoded = urllib.parse.quote(job_id, safe="")
    request = urllib.request.Request(
        f"https://api.openai.com/v1/fine_tuning/jobs/{job_id_encoded}",
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
      const job_id = required("OPENAI_FINE_TUNING_JOB_ID");
      const jobId = encodeURIComponent(job_id);
      const response = await fetch(`https://api.openai.com/v1/fine_tuning/jobs/${jobId}`, {
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
    : "${OPENAI_FINE_TUNING_JOB_ID:?请设置 OPENAI_FINE_TUNING_JOB_ID}"
    [[ "$OPENAI_FINE_TUNING_JOB_ID" =~ ^[A-Za-z0-9_:-]+$ ]] || { printf '%s\n' '资源 ID 格式错误' >&2; exit 1; }
    curl "https://api.openai.com/v1/fine_tuning/jobs/${OPENAI_FINE_TUNING_JOB_ID}" \
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
    	"net/url"
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
    	job_id := required("OPENAI_FINE_TUNING_JOB_ID")
    	target := fmt.Sprintf("https://api.openai.com/v1/fine_tuning/jobs/%s", url.PathEscape(job_id))
    	req, err := http.NewRequest("GET", target, nil)
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

* [OpenAI 学習タスク取得](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/retrieve)
* [OpenAI エラーコード](https\://developers.openai.com/api/docs/guides/error-codes)