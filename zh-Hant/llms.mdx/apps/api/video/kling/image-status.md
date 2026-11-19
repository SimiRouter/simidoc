# 查詢 Kling 圖生影片任務

## 介面說明

`GET https://api-singapore.klingai.com/tasks`，使用 `Authorization: Bearer $KLING_API_KEY`。Kling 新版文生/圖生影片使用同一任務查詢，不再串接 `/v1/videos/.../{id}`。

## 請求參數

| 欄位                         | 型別     | 必填  | 說明                                         |
| -------------------------- | ------ | --- | ------------------------------------------ |
| task\_ids（query）           | string | 二選一 | 系統任務 ID，多個以逗號分隔。                           |
| external\_task\_ids（query） | string | 二選一 | 建立時 options.external\_task\_id 的值，多個以逗號分隔。 |

兩種查詢參數不能同時傳，沒有 JSON 本文。設定 `TASK_ID` 為建立介面回傳的 `data.id`。

## 回傳值

| 欄位                                | 說明                                               |
| --------------------------------- | ------------------------------------------------ |
| `code` / `message` / `request_id` | 業務狀態與追蹤識別碼，code=0 才解析 data。                      |
| `data[]`                          | 與查詢條件匹配的任務陣列。                                    |
| `data[].id` / `external_id`       | 系統 ID 與自訂 ID。                                    |
| `data[].status`                   | submitted、processing、succeeded、failed。           |
| `data[].message`                  | 失敗原因。                                            |
| `data[].outputs[]`                | 按 type 區分 video/image/audio 等，不是舊版 task\_result。 |
| `outputs[].url` / `watermark_url` | video 結果 URL 與可用的水印版本。                           |
| `outputs[].duration`              | 輸出影片秒數。                                          |
| `create_time` / `update_time`     | Unix 毫秒時間戳。                                      |
| `billing[]`                       | 任務回傳的扣費單位等資訊。                                    |

```json
{"code":0,"message":"Success","request_id":"request_example","data":[{"id":"task_example","status":"succeeded","outputs":[{"type":"video","url":"https://example.com/video.mp4","duration":"5"}]}]}
```

只在 status=succeeded 且存在 type=video 的有效輸出時下載。連結帶防盜鏈/保留期限，及時儲存；失敗時停止輪詢。HTTP 成功但 data=\[] 應檢查 ID 和帳號，不能當生成成功。

## 程式碼範例

設定 `KLING_API_KEY` 和 `TASK_ID`；`TASK_ID` 必須為建立介面回傳的真實任務 ID。Python 3、Node.js 18 或更新版本和 Go 範例只使用標準函式庫。curl 使用 `--data-urlencode` 編碼查詢參數。建議每5～10秒查詢一次，並由應用設定總等待上限；範例只查詢一次。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    key = os.environ.get("KLING_API_KEY")
    task_id = os.environ.get("TASK_ID")
    if not key or not task_id or not task_id.strip():
        raise SystemExit("请设置 KLING_API_KEY 和 TASK_ID")
    url = "https://api-singapore.klingai.com/tasks?" + urllib.parse.urlencode({"task_ids": task_id})
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
      const key = process.env.KLING_API_KEY;
      const taskId = process.env.TASK_ID;
      if (!key || !taskId?.trim()) throw new Error("请设置 KLING_API_KEY 和 TASK_ID");
      const url = new URL("https://api-singapore.klingai.com/tasks");
      url.searchParams.set("task_ids", taskId);
      const response = await fetch(url, {
        method: "GET", headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(180000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${KLING_API_KEY:?请设置 KLING_API_KEY}"
    : "${TASK_ID:?请设置 TASK_ID 为创建接口返回的真实任务 ID}"
    [[ "$TASK_ID" =~ [^[:space:]] ]] || { printf '%s\n' 'TASK_ID 不能为空白' >&2; exit 1; }
    curl "https://api-singapore.klingai.com/tasks" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      --get \
      --data-urlencode "task_ids=$TASK_ID" \
      --header "Authorization: Bearer $KLING_API_KEY"
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
    	key, taskID := os.Getenv("KLING_API_KEY"), os.Getenv("TASK_ID")
    	if key == "" || strings.TrimSpace(taskID) == "" {
    		log.Fatal("请设置 KLING_API_KEY 和 TASK_ID")
    	}
    	query := url.Values{"task_ids": []string{taskID}}
    	endpoint := "https://api-singapore.klingai.com/tasks?" + query.Encode()
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

| HTTP / 業務碼                       | 說明                      |
| -------------------------------- | ----------------------- |
| 200 / 0                          | 請求成功，生成是否完成仍看任務 status。 |
| 400 / 1201                       | 參數錯誤，讀取 message。        |
| 404 / 1202、1203                  | 方法錯誤或模型/資源不存在。          |
| 401                              | API Key 或舊版 JWT 無效。     |
| 400 / 1300、1301                  | 平台策略或內容安全限制，修正內容，不盲目重試。 |
| 429 / 1302、1303、1304             | 速率、並行或 IP 策略限制。         |
| 500 / 5000；503 / 5001；504 / 5002 | 服務錯誤或逾時，保留 request\_id。 |

HTTP 200 不等於業務成功；首先檢查 code=0，再讀 data。

## 官方參考

[Kling 官方任務查詢](https\://kling.ai/document-api/apiReference/model/imageToVideo)。