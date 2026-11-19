# 查询 Seedance 视频任务

## 接口说明

`GET https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/{id}`，鉴权 `Authorization: Bearer $ARK_API_KEY`。本页为火山方舟官方协议，不与网关通用视频状态混用。

## 请求参数

| 字段     | 类型     | 必填 | 说明                          |
| ------ | ------ | -- | --------------------------- |
| id（路径） | string | 是  | 创建返回的 cgt- 任务 ID；属于同一账户/区域。 |

没有 JSON 正文。任务 ID 一般有效 7 天；新创建的部分 Draft 任务有独立有效期，不能依赖任务接口永久存档。

## 返回值

| 字段                                                      | 说明                                                 |
| ------------------------------------------------------- | -------------------------------------------------- |
| `id` / `model`                                          | 任务 ID 和模型版本。                                       |
| `status`                                                | queued、running、succeeded、failed、expired、cancelled。 |
| `content.video_url`                                     | 成功后的结果链接，有效期通常 24 小时，及时保存。                         |
| `content.last_frame_url`                                | 请求返回尾帧并支持时的图像 URL。                                 |
| `error.code` / `error.message`                          | 失败原因，可能为空。                                         |
| `created_at` / `updated_at`                             | Unix 秒时间戳。                                         |
| `usage`                                                 | 任务计量，按模型返回。                                        |
| `duration` / `ratio` / `resolution` / `framespersecond` | 实际视频规格。                                            |
| `seed` / `service_tier` / `execution_expires_after`     | 执行配置与复现线索。                                         |

```json
{"id":"cgt-example","model":"doubao-seedance-2-5-260628","status":"succeeded","content":{"video_url":"https://example.com/video.mp4"},"error":null,"created_at":1780000000,"updated_at":1780000120}
```

只在 succeeded 且 video\_url 非空时下载；failed、expired、cancelled 立即停止轮询。示例 URL 仅说明字段。

## 代码调用

设置 `ARK_API_KEY` 和 `TASK_ID`；`TASK_ID` 必须为创建接口返回的真实任务 ID。Python 3、Node.js 18 或更新版本和 Go 示例只使用标准库。curl 示例另需 Python 3 安全编码路径。建议每5～10秒查询一次，并由应用设置总等待上限；示例只查询一次。

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

## 错误码

| HTTP 状态               | 含义与处理                                   |
| --------------------- | --------------------------------------- |
| 400 / 422             | 请求字段、文件格式或模型参数不合法，修正后再提交。               |
| 401                   | API Key 缺失、无效或已过期。                      |
| 403                   | 当前项目或模型没有权限。                            |
| 404                   | 模型、路由或任务不存在，检查地址与资源归属。                  |
| 413 / 415             | 上传过大或媒体类型不受支持。                          |
| 429                   | 速率或配额限制，区分余额不足与可退避重试的限流。                |
| 500 / 502 / 503 / 504 | 服务或上游异常，保留请求 ID；创建任务超时时先检查是否已受理，避免重复生成。 |

火山错误对象使用 `error.code`、`error.message`，并保留请求 ID。查询 HTTP 成功仍需检查任务 status 与任务 error。

## 官方参考

[火山方舟查询任务](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)。