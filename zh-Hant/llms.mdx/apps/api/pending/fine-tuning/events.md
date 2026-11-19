# 取得微調任務事件

分頁讀取微調任務的記錄訊息和訓練指標。

**SimiRouter 暫不支援此介面。以下為 OpenAI 官方 API 參考，呼叫位址為 `api.openai.com`，需要 OpenAI 項目的金鑰，不能使用 SimiRouter Key。**

## 介面說明

* **方法**：`GET`
* **介面位址**：`/v1/fine_tuning/jobs/{fine_tuning_job_id}/events`
* **身分驗證**：`Authorization: Bearer $OPENAI_API_KEY`
* **請求型別**：無請求主體。

回傳普通JSON分頁清單，不是SSE訂閱。事件訊息用於診斷，任務最終成功與否仍應查詢[任務詳情](/simidoc/zh-Hant/apps/api/pending/fine-tuning/retrieve)的 `status`。

## 請求參數

| 參數                   | 型別        | 必填 | 說明                                         |
| -------------------- | --------- | -- | ------------------------------------------ |
| `fine_tuning_job_id` | string，路徑 | 是  | 任務ID；程式碼通過 `OPENAI_FINE_TUNING_JOB_ID` 讀取。 |

| 參數      | 型別         | 必填 | 說明           |
| ------- | ---------- | -- | ------------ |
| `after` | string，查詢  | 否  | 上一頁最後一個事件ID。 |
| `limit` | integer，查詢 | 否  | 每頁事件數量，預設20。 |

## 回傳值

| 欄位                  | 型別               | 說明                           |
| ------------------- | ---------------- | ---------------------------- |
| `object`            | string           | 固定為 `list`。                  |
| `has_more`          | boolean          | 是否有後續頁。                      |
| `data`              | array            | 目前頁事件。                       |
| `data[].id`         | string           | 事件ID，用於分頁。                   |
| `data[].object`     | string           | 固定為 `fine_tuning.job.event`。 |
| `data[].created_at` | integer          | 事件時間，Unix秒級時間戳。              |
| `data[].level`      | string           | `info`、`warn`或`error`。       |
| `data[].message`    | string           | 可讀的事件描述。                     |
| `data[].type`       | string，選用        | `message`或`metrics`。         |
| `data[].data`       | object / null，選用 | 事件附加資料；指標欄位取決於事件型別。          |

```json
{
  "object": "list",
  "data": [{
    "id": "ft-event-demo",
    "object": "fine_tuning.job.event",
    "created_at": 1793491200,
    "level": "info",
    "message": "Training started",
    "type": "message",
    "data": null
  }],
  "has_more": false
}
```

## 程式碼範例

執行要求：Python 3、Node.js 20 或更新版本、curl、Go 1.20 或更新版本。各語言範例分別儲存為 `.py`、`.cjs`、`.sh`、`.go` 檔案後執行。

設定 `OPENAI_API_KEY` 和 `OPENAI_FINE_TUNING_JOB_ID`。下一頁使用目前頁最後一個事件的ID作為`after`。

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
        f"https://api.openai.com/v1/fine_tuning/jobs/{job_id_encoded}/events?limit=20",
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
      const response = await fetch(`https://api.openai.com/v1/fine_tuning/jobs/${jobId}/events?limit=20`, {
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
    curl "https://api.openai.com/v1/fine_tuning/jobs/${OPENAI_FINE_TUNING_JOB_ID}/events?limit=20" \
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
    	target := fmt.Sprintf("https://api.openai.com/v1/fine_tuning/jobs/%s/events?limit=20", url.PathEscape(job_id))
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

* [OpenAI 微調任務事件](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/list_events)
* [OpenAI 錯誤碼](https\://developers.openai.com/api/docs/guides/error-codes)