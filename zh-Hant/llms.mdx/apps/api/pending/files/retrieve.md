# 取得檔案資訊

查詢一個 OpenAI 檔案的元資料，不下載檔案內容。

**SimiRouter 暫不支援此介面。以下為 OpenAI 官方 API 參考，呼叫位址為 `api.openai.com`，需要 OpenAI 項目的金鑰，不能使用 SimiRouter Key。**

## 介面說明

* **方法**：`GET`
* **介面位址**：`/v1/files/{file_id}`
* **身分驗證**：`Authorization: Bearer $OPENAI_API_KEY`
* **請求型別**：無請求主體。

同步回傳 JSON。下載原始位元組使用[取得檔案內容](/simidoc/zh-Hant/apps/api/pending/files/content)。

## 請求參數

| 參數        | 型別        | 必填 | 說明                |
| --------- | --------- | -- | ----------------- |
| `file_id` | string，路徑 | 是  | OpenAI 項目中的檔案 ID。 |

## 回傳值

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

回應範例（ID 與時間僅用於說明結構）：

```json
{
  "id": "file-demo",
  "object": "file",
  "bytes": 4096,
  "created_at": 1793491200,
  "filename": "training.jsonl",
  "purpose": "fine-tune",
  "expires_at": null
}
```

## 程式碼範例

執行要求：Python 3、Node.js 20 或更新版本、curl、Go 1.20 或更新版本。各語言範例分別儲存為 `.py`、`.cjs`、`.sh`、`.go` 檔案後執行。

設定 `OPENAI_API_KEY` 和 `OPENAI_FILE_ID`。

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
    file_id = required("OPENAI_FILE_ID")
    file_id_encoded = urllib.parse.quote(file_id, safe="")
    request = urllib.request.Request(
        f"https://api.openai.com/v1/files/{file_id_encoded}",
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
      const file_id = required("OPENAI_FILE_ID");
      const fileId = encodeURIComponent(file_id);
      const response = await fetch(`https://api.openai.com/v1/files/${fileId}`, {
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
    : "${OPENAI_FILE_ID:?请设置 OPENAI_FILE_ID}"
    [[ "$OPENAI_FILE_ID" =~ ^[A-Za-z0-9_:-]+$ ]] || { printf '%s\n' '资源 ID 格式错误' >&2; exit 1; }
    curl "https://api.openai.com/v1/files/${OPENAI_FILE_ID}" \
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
    	file_id := required("OPENAI_FILE_ID")
    	target := fmt.Sprintf("https://api.openai.com/v1/files/%s", url.PathEscape(file_id))
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

* [OpenAI 取得檔案](https\://developers.openai.com/api/reference/resources/files/methods/retrieve)
* [OpenAI 錯誤碼](https\://developers.openai.com/api/docs/guides/error-codes)