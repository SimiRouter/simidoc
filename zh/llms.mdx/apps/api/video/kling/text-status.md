# 查询 Kling 文生视频任务

## 接口说明

`GET https://api-singapore.klingai.com/tasks`，使用 `Authorization: Bearer $KLING_API_KEY`。Kling 新版文生/图生视频使用同一任务查询，不再拼接 `/v1/videos/.../{id}`。

## 请求参数

| 字段                         | 类型     | 必填  | 说明                                         |
| -------------------------- | ------ | --- | ------------------------------------------ |
| task\_ids（query）           | string | 二选一 | 系统任务 ID，多个以逗号分隔。                           |
| external\_task\_ids（query） | string | 二选一 | 创建时 options.external\_task\_id 的值，多个以逗号分隔。 |

两种查询参数不能同时传，没有 JSON 正文。设置 `TASK_ID` 为创建接口返回的 `data.id`。

## 返回值

| 字段                                | 说明                                               |
| --------------------------------- | ------------------------------------------------ |
| `code` / `message` / `request_id` | 业务状态与追踪标识，code=0 才解析 data。                       |
| `data[]`                          | 与查询条件匹配的任务数组。                                    |
| `data[].id` / `external_id`       | 系统 ID 与自定义 ID。                                   |
| `data[].status`                   | submitted、processing、succeeded、failed。           |
| `data[].message`                  | 失败原因。                                            |
| `data[].outputs[]`                | 按 type 区分 video/image/audio 等，不是旧版 task\_result。 |
| `outputs[].url` / `watermark_url` | video 结果 URL 与可用的水印版本。                           |
| `outputs[].duration`              | 输出视频秒数。                                          |
| `create_time` / `update_time`     | Unix 毫秒时间戳。                                      |
| `billing[]`                       | 任务返回的扣费单位等信息。                                    |

```json
{"code":0,"message":"Success","request_id":"request_example","data":[{"id":"task_example","status":"succeeded","outputs":[{"type":"video","url":"https://example.com/video.mp4","duration":"5"}]}]}
```

只在 status=succeeded 且存在 type=video 的有效输出时下载。链接带防盗链/保留期限，及时保存；失败时停止轮询。HTTP 成功但 data=\[] 应检查 ID 和账号，不能当生成成功。

## 代码调用

设置 `KLING_API_KEY` 和 `TASK_ID`；`TASK_ID` 必须为创建接口返回的真实任务 ID。Python 3、Node.js 18 或更新版本和 Go 示例只使用标准库。curl 使用 `--data-urlencode` 编码查询参数。建议每5～10秒查询一次，并由应用设置总等待上限；示例只查询一次。

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

## 错误码

| HTTP / 业务码                       | 说明                      |
| -------------------------------- | ----------------------- |
| 200 / 0                          | 请求成功，生成是否完成仍看任务 status。 |
| 400 / 1201                       | 参数错误，读取 message。        |
| 404 / 1202、1203                  | 方法错误或模型/资源不存在。          |
| 401                              | API Key 或旧版 JWT 无效。     |
| 400 / 1300、1301                  | 平台策略或内容安全限制，修正内容，不盲目重试。 |
| 429 / 1302、1303、1304             | 速率、并发或 IP 策略限制。         |
| 500 / 5000；503 / 5001；504 / 5002 | 服务错误或超时，保留 request\_id。 |

HTTP 200 不等于业务成功；首先检查 code=0，再读 data。

## 官方参考

[Kling 官方任务查询](https\://kling.ai/document-api/apiReference/model/textToVideo)。