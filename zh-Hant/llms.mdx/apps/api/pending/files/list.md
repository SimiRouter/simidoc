# 列出檔案

分頁查詢目前 OpenAI 項目中可存取的檔案。

**SimiRouter 暫不支援此介面。以下為 OpenAI 官方 API 參考，呼叫位址為 `api.openai.com`，需要 OpenAI 項目的金鑰，不能使用 SimiRouter Key。**

## 介面說明

* **方法**：`GET`
* **介面位址**：`/v1/files`
* **身分驗證**：`Authorization: Bearer $OPENAI_API_KEY`
* **請求型別**：無請求主體。

同步回傳目前頁JSON；`has_more=true`時需要後續分頁請求，單次呼叫不會自動回傳全部檔案。

## 請求參數

| 參數        | 型別         | 必填 | 說明                                |
| --------- | ---------- | -- | --------------------------------- |
| `after`   | string，查詢  | 否  | 上一頁最後一個檔案的 ID。                    |
| `limit`   | integer，查詢 | 否  | 每頁1～10000條，預設10000；範例使用20。        |
| `order`   | string，查詢  | 否  | 按建立時間排序：`asc` 或 `desc`，預設 `desc`。 |
| `purpose` | string，查詢  | 否  | 只回傳指定用途的檔案。                       |

## 回傳值

| 欄位                     | 型別            | 說明               |
| ---------------------- | ------------- | ---------------- |
| `object`               | string        | 清單型別，通常為 `list`。 |
| `data`                 | FileObject\[] | 目前頁檔案；物件欄位如下。    |
| `first_id` / `last_id` | string        | 目前頁首尾檔案 ID。      |
| `has_more`             | boolean       | 是否還有下一頁。         |

| 欄位               | 型別                   | 說明                                                                  |
| ---------------- | -------------------- | ------------------------------------------------------------------- |
| `id`             | string               | 檔案 ID，供後續請求引用。                                                      |
| `object`         | string               | 固定為 `file`。                                                         |
| `bytes`          | integer / null       | 檔案大小，單位為位元組；尚未取得大小時可能為 null。                                        |
| `created_at`     | integer              | 建立時間，Unix 秒級時間戳。                                                    |
| `filename`       | string               | 上傳時的檔名。                                                             |
| `purpose`        | string               | 檔案用途，例如 `fine-tune`、`user_data`；生成的結果檔案可能使用 `fine-tune-results` 等值。 |
| `expires_at`     | integer / null，選用    | 過期時間，Unix 秒級時間戳；未設定過期策略時可能為空。                                       |
| `status`         | string，已棄用           | 舊狀態欄位：`uploaded`、`processed` 或 `error`。不要用它替代消費端點自身的處理狀態。           |
| `status_details` | string / null，選用，已棄用 | 舊狀態說明；微調資料驗證錯誤應讀取任務的 `error`。                                       |

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

## 程式碼範例

執行要求：Python 3、Node.js 20 或更新版本、curl、Go 1.20 或更新版本。各語言範例分別儲存為 `.py`、`.cjs`、`.sh`、`.go` 檔案後執行。

設定 `OPENAI_API_KEY`。範例取得前20條；下一頁將上頁 `last_id` 作為 `after` 查詢參數。

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

* [OpenAI 檔案清單](https\://developers.openai.com/api/reference/resources/files/methods/list)
* [OpenAI 錯誤碼](https\://developers.openai.com/api/docs/guides/error-codes)