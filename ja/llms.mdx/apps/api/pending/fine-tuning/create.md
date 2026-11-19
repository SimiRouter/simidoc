# ファインチューニング作成

学習データと基礎モデル設定を送信し、OpenAI で非同期学習タスクを作成します。

**SimiRouter は現在この API に未対応です。以下は OpenAI 公式リファレンスで、接続先は `api.openai.com`。OpenAI プロジェクトのキーが必要で、SimiRouter Key は使用できません。**

OpenAI はセルフサービスのファインチューニングを終了中です。新規ユーザーはタスクを作成できず、対象となる既存ユーザーも基礎モデルが先に終了しない限り **2027年1月6日** までです。送信前に[公式スケジュール](https\://developers.openai.com/api/docs/deprecations)を確認してください。

## API の説明

* **メソッド**：`POST`
* **API アドレス**：`/v1/fine_tuning/jobs`
* **認証**：`Authorization: Bearer $OPENAI_API_KEY`
* **リクエスト型**：`application/json`。

作成要求はタスクオブジェクトを返し、その後サーバーで学習します。`200`または`queued`は学習成功ではありません。[タスク詳細の取得](/simidoc/ja/apps/api/pending/fine-tuning/retrieve)で最終 `status` を照会し、[イベント取得](/simidoc/ja/apps/api/pending/fine-tuning/events)で進捗を確認します。パスは `/v1/fine_tuning/jobs` で、旧 `/v1/fine-tunes` ではありません。

## リクエストパラメータ

| パラメータ                               | 型              | 必須  | 説明                                                                                        |
| ----------------------------------- | -------------- | --- | ----------------------------------------------------------------------------------------- |
| `model`                             | string         | はい  | 選択した学習方式に対応する基礎モデル ID。                                                                    |
| `training_file`                     | string         | はい  | 次の用途で `purpose=fine-tune` アップロードした JSONL 学習ファイル ID。                                       |
| `validation_file`                   | string / null  | いいえ | 独立検証ファイル ID。学習セットと重複させません。                                                                |
| `method`                            | object         | いいえ | `type` は `supervised`、`dpo` または `reinforcement` とし、同名の設定オブジェクトを指定します。方法とモデルの互換性が必要。       |
| `method.supervised.hyperparameters` | object         | いいえ | `batch_size`：auto または1～256。`learning_rate_multiplier`：auto または正数。`n_epochs`：auto または1～50。 |
| `method.dpo.hyperparameters`        | object         | いいえ | DPO ハイパーパラメータ。`beta` を含み、教師あり用データ形式をそのまま流用しません。                                           |
| `method.reinforcement`              | object         | いいえ | 強化学習設定。`grader` と対応ハイパーパラメータを含みます。                                                        |
| `suffix`                            | string / null  | いいえ | 出力モデル名の独自接尾辞。最大64文字。                                                                      |
| `seed`                              | integer / null | いいえ | ランダムシード。同値でも完全再現を保証しません。                                                                  |
| `metadata`                          | object / null  | いいえ | 最大16組。キー64文字、値512文字まで。                                                                    |
| `integrations`                      | array / null   | いいえ | 外部指標連携。プロジェクト名を含む `wandb` 設定など。                                                           |
| `hyperparameters`                   | object、非推奨     | いいえ | 旧トップレベル設定。新規は `method` 内に置きます。                                                            |

本文のモデル・ファイル ID は構造例です。実際には所属プロジェクトの資源を使用します。

```json
{
  "model": "selected-base-model",
  "training_file": "file-training",
  "method": {
    "type": "supervised",
    "supervised": {
      "hyperparameters": {
        "n_epochs": 2
      }
    }
  }
}
```

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

次を設定します：`OPENAI_API_KEY`、`OPENAI_FINE_TUNING_MODEL` と `OPENAI_TRAINING_FILE_ID`。curl は Python 3 で JSON を作成。公式プロジェクトで学習可能なモデルが必要です。学習には料金が発生するためデータ、方法、予算を確認して実行し、接続テストには使用しません。

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
    model = required("OPENAI_FINE_TUNING_MODEL")
    training_file = required("OPENAI_TRAINING_FILE_ID")
    payload = {"model": model, "training_file": training_file}
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        "https://api.openai.com/v1/fine_tuning/jobs",
        method="POST",
        data=data,
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
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
      const model = required("OPENAI_FINE_TUNING_MODEL");
      const training_file = required("OPENAI_TRAINING_FILE_ID");
      const body = JSON.stringify({"model": model, "training_file": training_file});
      const response = await fetch("https://api.openai.com/v1/fine_tuning/jobs", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body,
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
    : "${OPENAI_FINE_TUNING_MODEL:?请设置 OPENAI_FINE_TUNING_MODEL}"
    : "${OPENAI_TRAINING_FILE_ID:?请设置 OPENAI_TRAINING_FILE_ID}"
    payload=$(python3 - <<'JSON'
    import json, os
    print(json.dumps({"model": os.environ["OPENAI_FINE_TUNING_MODEL"], "training_file": os.environ["OPENAI_TRAINING_FILE_ID"]}))
    JSON
    )

    curl "https://api.openai.com/v1/fine_tuning/jobs" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request POST \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --header "Content-Type: application/json" \
      --data "$payload"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"bytes"
    	"encoding/json"
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
    	model := required("OPENAI_FINE_TUNING_MODEL")
    	training_file := required("OPENAI_TRAINING_FILE_ID")
    	payload, err := json.Marshal(map[string]any{"model": model, "training_file": training_file})
    	check(err)
    	req, err := http.NewRequest("POST", "https://api.openai.com/v1/fine_tuning/jobs", bytes.NewReader(payload))
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	req.Header.Set("Content-Type", "application/json")
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

* [OpenAI 学習タスク作成](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/create)
* [OpenAI モデル最適化ガイド](https\://developers.openai.com/api/docs/guides/model-optimization)
* [OpenAI エラーコード](https\://developers.openai.com/api/docs/guides/error-codes)