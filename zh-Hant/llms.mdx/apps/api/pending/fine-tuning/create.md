# 建立微調任務

提交訓練集和基礎模型設定，在 OpenAI 建立非同步微調任務。

**SimiRouter 暫不支援此介面。以下為 OpenAI 官方 API 參考，呼叫位址為 `api.openai.com`，需要 OpenAI 項目的金鑰，不能使用 SimiRouter Key。**

OpenAI 正在停止自助式微調：新使用者無法建立任務，符合資格的既有使用者也只能建立至 **2027 年 1 月 6 日**，除非基礎模型更早停用。提交前請查看[官方淘汰時間表](https\://developers.openai.com/api/docs/deprecations)。

## 介面說明

* **方法**：`POST`
* **介面位址**：`/v1/fine_tuning/jobs`
* **身分驗證**：`Authorization: Bearer $OPENAI_API_KEY`
* **請求型別**：`application/json`。

建立請求回傳任務物件，訓練隨後在伺服器端執行。`200`或`queued`不代表訓練成功；使用[取得任務詳情](/simidoc/zh-Hant/apps/api/pending/fine-tuning/retrieve)查詢最終 `status`，使用[取得事件](/simidoc/zh-Hant/apps/api/pending/fine-tuning/events)查看進度。路徑為 `/v1/fine_tuning/jobs`，不是舊版 `/v1/fine-tunes`。

## 請求參數

| 參數                                  | 型別             | 必填 | 說明                                                                               |
| ----------------------------------- | -------------- | -- | -------------------------------------------------------------------------------- |
| `model`                             | string         | 是  | 支援對應微調方法的基礎模型 ID。                                                                |
| `training_file`                     | string         | 是  | 以 `purpose=fine-tune` 上傳的JSONL訓練集檔案ID。                                           |
| `validation_file`                   | string / null  | 否  | 獨立驗證集的檔案 ID，資料不要與訓練集重複。                                                          |
| `method`                            | object         | 否  | `type` 為 `supervised`、`dpo` 或 `reinforcement`，並填寫同名設定物件；方法必須與模型相容。               |
| `method.supervised.hyperparameters` | object         | 否  | `batch_size`：auto或1～256；`learning_rate_multiplier`：auto或正數；`n_epochs`：auto或1～50。 |
| `method.dpo.hyperparameters`        | object         | 否  | DPO訓練超參數，包含 `beta`；不要直接套用監督訓練的資料格式。                                              |
| `method.reinforcement`              | object         | 否  | 強化微調設定，包含 `grader` 與該方法的超參數。                                                     |
| `suffix`                            | string / null  | 否  | 產出模型名稱的自訂後綴，最多64字元。                                                              |
| `seed`                              | integer / null | 否  | 隨機種子；相同種子不構成完全可重複的保證。                                                            |
| `metadata`                          | object / null  | 否  | 最多16對鍵值；鍵最長64字元，值最長512字元。                                                        |
| `integrations`                      | array / null   | 否  | 外部訓練指標整合，例如帶項目名的 `wandb` 設定。                                                     |
| `hyperparameters`                   | object，已棄用     | 否  | 舊頂層寫法，新增設定應放到 `method` 中。                                                        |

請求主體範例中的模型和檔案 ID 是結構範例，實際呼叫須使用所屬項目的資源。

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

## 回傳值

| 欄位                 | 型別                | 說明                                                                                           |
| ------------------ | ----------------- | -------------------------------------------------------------------------------------------- |
| `id` / `object`    | string            | 任務 ID；物件型別固定為 `fine_tuning.job`。                                                             |
| `model`            | string            | 用於訓練的基礎模型。                                                                                   |
| `status`           | string            | `validating_files`、`queued`、`running`、`pausing`、`paused`、`succeeded`、`failed` 或 `cancelled`。 |
| `created_at`       | integer           | 建立時間，Unix 秒級時間戳。                                                                             |
| `finished_at`      | integer / null    | 完成時間；未結束時為空。                                                                                 |
| `estimated_finish` | integer / null，選用 | 預計結束時間，不是完成保證。                                                                               |
| `fine_tuned_model` | string / null     | 產出的模型 ID；尚未產出時為空。                                                                            |
| `training_file`    | string            | 訓練集檔案 ID。                                                                                    |
| `validation_file`  | string / null     | 驗證集檔案 ID；未設定時為空。                                                                             |
| `result_files`     | string\[]         | 結果檔案 ID，可透過官方 Files API 下載。                                                                  |
| `trained_tokens`   | integer / null    | 訓練處理的計費 token 數；進行中可能為空。                                                                     |
| `error`            | object / null     | 失敗詳情，包括 `code`、`message`、`param`；非參數錯誤的 `param` 可為空。                                         |
| `organization_id`  | string            | 任務所屬組織。                                                                                      |
| `seed`             | integer / null    | 本次訓練使用的隨機種子。                                                                                 |
| `method`           | object / null，選用  | 微調方法及對應設定。                                                                                   |
| `hyperparameters`  | object / null，選用  | 監督微調的超參數相容欄位。                                                                                |
| `integrations`     | array / null，選用   | 啟用的外部指標整合。                                                                                   |
| `metadata`         | object / null，選用  | 任務自訂鍵值資訊。                                                                                    |

回應範例（只展示核心欄位，非實際任務）：

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

## 程式碼範例

執行要求：Python 3、Node.js 20 或更新版本、curl、Go 1.20 或更新版本。各語言範例分別儲存為 `.py`、`.cjs`、`.sh`、`.go` 檔案後執行。

設定 `OPENAI_API_KEY`、`OPENAI_FINE_TUNING_MODEL` 和 `OPENAI_TRAINING_FILE_ID`。curl 範例使用 Python 3 生成 JSON。基礎模型必須在官方項目中開放微調。訓練會產生費用；只在確定資料、方法和預算後執行，不要把建立任務用於連線能力測試。

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

## 錯誤碼

以下為 OpenAI 官方直連請求的常見 HTTP 錯誤，不是 SimiRouter 的支援狀態。

| HTTP 狀態碼      | 含義                | 處理方式                                       |
| ------------- | ----------------- | ------------------------------------------ |
| `400`         | 參數、檔案用途或資源狀態不符合要求 | 讀取 `error.message` 和 `error.param`，修正後再提交。 |
| `401`         | 金鑰無效或缺失           | 檢查 OpenAI 金鑰及其所屬項目。                        |
| `403`         | 無權存取項目或資源         | 檢查項目、組織和角色權限。                              |
| `404`         | 檔案、任務或模型不存在       | 核對 ID，並使用資源所屬項目的金鑰。                        |
| `429`         | 速率限制或額度不足         | 區分限流與額度錯誤；限流時退避，額度不足時不要重複提交。               |
| `500` / `503` | 伺服器端異常或暫不可用       | 保留請求 ID；寫入請求先核對是否已建立資源，避免重複上傳或重複訓練。        |

非成功回應通常包含 `error.message`、`error.type`、`error.param` 和 `error.code`；欄位可能為空。

## 官方參考

* [OpenAI 建立微調任務](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/create)
* [OpenAI 模型優化指南](https\://developers.openai.com/api/docs/guides/model-optimization)
* [OpenAI 錯誤碼](https\://developers.openai.com/api/docs/guides/error-codes)