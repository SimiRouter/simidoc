# 列出微調任務

分頁查詢 OpenAI 組織中目前金鑰可見的微調任務。

**SimiRouter 暫不支援此介面。以下為 OpenAI 官方 API 參考，呼叫位址為 `api.openai.com`，需要 OpenAI 項目的金鑰，不能使用 SimiRouter Key。**

## 介面說明

* **方法**：`GET`
* **介面位址**：`/v1/fine_tuning/jobs`
* **身分驗證**：`Authorization: Bearer $OPENAI_API_KEY`
* **請求型別**：無請求主體。

同步分頁查詢，不啟動或等待訓練。任務狀態的含義與[取得任務詳情](/simidoc/zh-Hant/apps/api/pending/fine-tuning/retrieve)相同。

## 請求參數

| 參數         | 型別               | 必填 | 說明                                                                          |
| ---------- | ---------------- | -- | --------------------------------------------------------------------------- |
| `after`    | string，查詢        | 否  | 上頁最後一個任務ID。                                                                 |
| `limit`    | integer，查詢       | 否  | 每頁任務數量，預設20。                                                                |
| `metadata` | object / null，查詢 | 否  | 使用 `metadata[key]=value` 過濾；`metadata=null` 選擇未設定 metadata 的任務。這兩種形式不要同時使用。 |

## 回傳值

| 欄位         | 型別               | 說明                                |
| ---------- | ---------------- | --------------------------------- |
| `object`   | string           | 固定為 `list`。                       |
| `data`     | FineTuningJob\[] | 目前頁的任務物件。                         |
| `has_more` | boolean          | 是否還有下一頁；下一頁以目前頁最後一個任務ID作為`after`。 |

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

```json
{
  "object": "list",
  "data": [
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
  ],
  "has_more": false
}
```

## 程式碼範例

執行要求：Python 3、Node.js 20 或更新版本、curl、Go 1.20 或更新版本。各語言範例分別儲存為 `.py`、`.cjs`、`.sh`、`.go` 檔案後執行。

設定 `OPENAI_API_KEY`。範例取得前20條；若 `has_more=true`，將 `data` 最後一個物件的 `id` 填入下一頁的 `after`。

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
        "https://api.openai.com/v1/fine_tuning/jobs?limit=20",
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

      const response = await fetch("https://api.openai.com/v1/fine_tuning/jobs?limit=20", {
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

    curl "https://api.openai.com/v1/fine_tuning/jobs?limit=20" \
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

    	req, err := http.NewRequest("GET", "https://api.openai.com/v1/fine_tuning/jobs?limit=20", nil)
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

* [OpenAI 微調任務清單](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/list)
* [OpenAI 錯誤碼](https\://developers.openai.com/api/docs/guides/error-codes)