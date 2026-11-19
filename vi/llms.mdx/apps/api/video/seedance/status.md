# Truy vấn Seedance

## Tổng quan API

`GET https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/{id}`, xác thực `Authorization: Bearer $ARK_API_KEY`. Giao thức Ark chính thức, không trộn trạng thái video cổng chung.

## Tham số yêu cầu

| Trường         | Kiểu   | Bắt buộc | Mô tả                                |
| -------------- | ------ | -------- | ------------------------------------ |
| id (đường dẫn) | string | Có       | ID cgt- từ tạo, cùng tài khoản/vùng. |

Không JSON. ID thường 7 ngày; vài Draft mới có hạn riêng, không dùng tác vụ lưu trữ vĩnh viễn.

## Phản hồi

| Trường                                                  | Mô tả                                                   |
| ------------------------------------------------------- | ------------------------------------------------------- |
| `id` / `model`                                          | ID và phiên bản mô hình.                                |
| `status`                                                | queued, running, succeeded, failed, expired, cancelled. |
| `content.video_url`                                     | Link kết quả thành công thường 24 giờ, lưu sớm.         |
| `content.last_frame_url`                                | URL khung cuối khi yêu cầu và hỗ trợ.                   |
| `error.code` / `error.message`                          | Lý do lỗi có thể rỗng.                                  |
| `created_at` / `updated_at`                             | Thời gian Unix giây.                                    |
| `usage`                                                 | Mức dùng tùy mô hình.                                   |
| `duration` / `ratio` / `resolution` / `framespersecond` | Thông số video thực.                                    |
| `seed` / `service_tier` / `execution_expires_after`     | Cấu hình và thông tin tái lập.                          |

```json
{"id":"cgt-example","model":"doubao-seedance-2-5-260628","status":"succeeded","content":{"video_url":"https://example.com/video.mp4"},"error":null,"created_at":1780000000,"updated_at":1780000120}
```

Chỉ tải succeeded và video\_url có; failed/expired/cancelled dừng. URL minh họa trường.

## Ví dụ mã

Đặt `ARK_API_KEY` và `TASK_ID`; `TASK_ID` phải ID tạo thật. Python 3, Node.js 18+, Go chuẩn; curl cần Python 3 mã đường dẫn. Poll 5–10 giây, tổng thời gian tối đa; ví dụ một lần.

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

## Mã lỗi

| Trạng thái HTTP       | Ý nghĩa và xử lý                                                                                            |
| --------------------- | ----------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Trường, định dạng tệp hoặc tham số không hợp lệ; sửa rồi gửi lại.                                           |
| 401                   | Khóa API thiếu, không hợp lệ hoặc hết hạn.                                                                  |
| 403                   | Không có quyền dự án hoặc mô hình.                                                                          |
| 404                   | Mô hình, tuyến hoặc tác vụ không tồn tại; kiểm tra địa chỉ và sở hữu tài nguyên.                            |
| 413 / 415             | Tệp quá lớn hoặc loại phương tiện không hỗ trợ.                                                             |
| 429                   | Giới hạn tốc độ/hạn mức; phân biệt thiếu số dư với giới hạn có thể thử lại.                                 |
| 500 / 502 / 503 / 504 | Lỗi dịch vụ/thượng nguồn. Giữ ID yêu cầu; nếu tạo tác vụ hết hạn, kiểm tra đã nhận chưa để tránh tạo trùng. |

Lỗi Volcengine dùng `error.code`, `error.message`, giữ ID. HTTP truy vấn thành công vẫn kiểm status/error.

## Tham khảo chính thức

[Ark truy vấn tác vụ](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh).