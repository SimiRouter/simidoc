# Truy vấn Kling ảnh thành video

## Tổng quan API

`GET https://api-singapore.klingai.com/tasks` và `Authorization: Bearer $KLING_API_KEY`. Kling mới chữ/ảnh dùng cùng truy vấn, không nối `/v1/videos/.../{id}`.

## Tham số yêu cầu

| Trường                      | Kiểu   | Bắt buộc | Mô tả                                                        |
| --------------------------- | ------ | -------- | ------------------------------------------------------------ |
| task\_ids (query)           | string | Chọn một | ID hệ thống, nhiều ID cách dấu phẩy.                         |
| external\_task\_ids (query) | string | Chọn một | options.external\_task\_id lúc tạo, nhiều giá trị cách phẩy. |

Không cùng hai query, không thân JSON. Đặt `TASK_ID` bằng giá trị trả khi tạo `data.id`.

## Phản hồi

| Trường                            | Mô tả                                                    |
| --------------------------------- | -------------------------------------------------------- |
| `code` / `message` / `request_id` | Trạng thái/ID theo dõi, chỉ code=0 mới đọc data.         |
| `data[]`                          | Mảng tác vụ khớp truy vấn.                               |
| `data[].id` / `external_id`       | ID hệ thống/tùy chỉnh.                                   |
| `data[].status`                   | submitted, processing, succeeded, failed.                |
| `data[].message`                  | Lý do lỗi.                                               |
| `data[].outputs[]`                | Phân video/image/audio theo type, không task\_result cũ. |
| `outputs[].url` / `watermark_url` | URL video và bản watermark nếu có.                       |
| `outputs[].duration`              | Thời lượng giây.                                         |
| `create_time` / `update_time`     | Thời gian Unix mili giây.                                |
| `billing[]`                       | Thông tin đơn vị tính phí tác vụ.                        |

```json
{"code":0,"message":"Success","request_id":"request_example","data":[{"id":"task_example","status":"succeeded","outputs":[{"type":"video","url":"https://example.com/video.mp4","duration":"5"}]}]}
```

Chỉ tải status=succeeded và type=video hợp lệ. Link có chống hotlink/hạn lưu, tải sớm; lỗi dừng. HTTP thành công nhưng data=\[] cần kiểm ID/tài khoản, không thành công tạo.

## Ví dụ mã

Đặt `KLING_API_KEY` và `TASK_ID`; `TASK_ID` phải ID thật từ tạo. Python 3, Node.js 18+, Go chuẩn. curl dùng `--data-urlencode` mã query. Khuyên mỗi 5–10 giây, đặt tổng thời gian tối đa; ví dụ chỉ truy vấn một lần.

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

## Mã lỗi

| HTTP / mã nghiệp vụ                | Mô tả                                           |
| ---------------------------------- | ----------------------------------------------- |
| 200 / 0                            | Yêu cầu thành công; video hoàn tất theo status. |
| 400 / 1201                         | Sai tham số, đọc message.                       |
| 404 / 1202, 1203                   | Sai phương thức hoặc thiếu mô hình/tài nguyên.  |
| 401                                | Khóa hoặc JWT cũ không hợp lệ.                  |
| 400 / 1300, 1301                   | Chính sách/an toàn, sửa nội dung không lặp mù.  |
| 429 / 1302, 1303, 1304             | Giới hạn tốc độ, đồng thời hoặc IP.             |
| 500 / 5000; 503 / 5001; 504 / 5002 | Lỗi/timeout, giữ request\_id.                   |

HTTP 200 không là nghiệp vụ thành công; kiểm code=0 rồi data.

## Tham khảo chính thức

[Truy vấn Kling chính thức](https\://kling.ai/document-api/apiReference/model/imageToVideo).