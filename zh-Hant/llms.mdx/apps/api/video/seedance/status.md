# 查詢 Seedance 影片任務

## 介面說明

`GET https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/{id}`，身分驗證 `Authorization: Bearer $ARK_API_KEY`。本頁為火山方舟官方通訊協定，不與閘道通用影片狀態混用。

## 請求參數

| 欄位     | 型別     | 必填 | 說明                          |
| ------ | ------ | -- | --------------------------- |
| id（路徑） | string | 是  | 建立回傳的 cgt- 任務 ID；屬於同一帳戶/區域。 |

沒有 JSON 本文。任務 ID 一般有效 7 天；新建立的部分 Draft 任務有獨立有效期，不能依賴任務介面永久存檔。

## 回傳值

| 欄位                                                      | 說明                                                 |
| ------------------------------------------------------- | -------------------------------------------------- |
| `id` / `model`                                          | 任務 ID 和模型版本。                                       |
| `status`                                                | queued、running、succeeded、failed、expired、cancelled。 |
| `content.video_url`                                     | 成功後的結果連結，有效期通常 24 小時，及時儲存。                         |
| `content.last_frame_url`                                | 請求回傳尾影格並支援時的影像 URL。                                |
| `error.code` / `error.message`                          | 失敗原因，可能為空。                                         |
| `created_at` / `updated_at`                             | Unix 秒時間戳。                                         |
| `usage`                                                 | 任務計量，按模型回傳。                                        |
| `duration` / `ratio` / `resolution` / `framespersecond` | 實際影片規格。                                            |
| `seed` / `service_tier` / `execution_expires_after`     | 執行設定與復現線索。                                         |

```json
{"id":"cgt-example","model":"doubao-seedance-2-5-260628","status":"succeeded","content":{"video_url":"https://example.com/video.mp4"},"error":null,"created_at":1780000000,"updated_at":1780000120}
```

只在 succeeded 且 video\_url 非空時下載；failed、expired、cancelled 立即停止輪詢。範例 URL 僅說明欄位。

## 程式碼範例

設定 `ARK_API_KEY` 和 `TASK_ID`；`TASK_ID` 必須為建立介面回傳的真實任務 ID。Python 3、Node.js 18 或更新版本和 Go 範例只使用標準函式庫。curl 範例另需 Python 3 安全編碼路徑。建議每5～10秒查詢一次，並由應用設定總等待上限；範例只查詢一次。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    key = os.environ.get("ARK_API_KEY")
    task_id = os.environ.get("TASK_ID")
    if not key or not task_id or not task_id.strip():
        raise SystemExit("请设置 ARK_API_KEY 和 TASK_ID")
    url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + urllib.parse.quote(task_id, safe="")
    request = urllib.request.Request(url, headers={"Authorization": "Bearer " + key}, method="GET")
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            print(json.dumps(json.load(response), ensure_ascii=False, indent=2))
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const key = process.env.ARK_API_KEY;
      const taskId = process.env.TASK_ID;
      if (!key || !taskId?.trim()) throw new Error("请设置 ARK_API_KEY 和 TASK_ID");
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + encodeURIComponent(taskId);
      const response = await fetch(url, {
        method: "GET", headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(180000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${ARK_API_KEY:?请设置 ARK_API_KEY}"
    : "${TASK_ID:?请设置 TASK_ID 为创建接口返回的真实任务 ID}"
    TASK_PATH=$(python3 - <<'PY_TASK'
    import os, urllib.parse
    task_id = os.environ["TASK_ID"]
    if not task_id.strip():
        raise SystemExit("TASK_ID 不能为空白")
    print(urllib.parse.quote(task_id, safe=""))
    PY_TASK
    )
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/${TASK_PATH}" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      --header "Authorization: Bearer $ARK_API_KEY"
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
    	"strings"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func main() {
    	key, taskID := os.Getenv("ARK_API_KEY"), os.Getenv("TASK_ID")
    	if key == "" || strings.TrimSpace(taskID) == "" {
    		log.Fatal("请设置 ARK_API_KEY 和 TASK_ID")
    	}
    	endpoint := "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + url.PathEscape(taskID)
    	req, err := http.NewRequest("GET", endpoint, nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 180 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	data, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, data)
    	}
    	fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## 錯誤碼

| HTTP 狀態               | 含義與處理                                   |
| --------------------- | --------------------------------------- |
| 400 / 422             | 請求欄位、檔案格式或模型參數不合法，修正後再提交。               |
| 401                   | API Key 缺失、無效或已過期。                      |
| 403                   | 目前項目或模型沒有權限。                            |
| 404                   | 模型、路由或任務不存在，檢查位址與資源歸屬。                  |
| 413 / 415             | 上傳過大或媒體型別不受支援。                          |
| 429                   | 速率或配額限制，區分餘額不足與可退避重試的限流。                |
| 500 / 502 / 503 / 504 | 服務或上游異常，保留請求 ID；建立任務逾時時先檢查是否已受理，避免重複生成。 |

火山錯誤物件使用 `error.code`、`error.message`，並保留請求 ID。查詢 HTTP 成功仍需檢查任務 status 與任務 error。

## 官方參考

[火山方舟查詢任務](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)。