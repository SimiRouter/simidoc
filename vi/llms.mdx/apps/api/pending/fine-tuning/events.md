# Lấy sự kiện tinh chỉnh

Đọc phân trang nhật ký và chỉ số huấn luyện.

**SimiRouter chưa hỗ trợ. Tham khảo OpenAI chính thức tại `api.openai.com`, cần khóa dự án OpenAI, không SimiRouter.**

## Tổng quan API

* **Phương thức**\: `GET`
* **Địa chỉ API**\: `/v1/fine_tuning/jobs/{fine_tuning_job_id}/events`
* **Xác thực**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Loại yêu cầu**\: không thân.

Trả JSON phân trang, không SSE. Sự kiện chẩn đoán, cuối vẫn kiểm [chi tiết tác vụ](/simidoc/vi/apps/api/pending/fine-tuning/retrieve) ở `status`.

## Tham số yêu cầu

| Tham số              | Kiểu              | Bắt buộc | Mô tả                                              |
| -------------------- | ----------------- | -------- | -------------------------------------------------- |
| `fine_tuning_job_id` | string, đường dẫn | Có       | ID tác vụ, mã đọc qua `OPENAI_FINE_TUNING_JOB_ID`. |

| Tham số | Kiểu              | Bắt buộc | Mô tả                              |
| ------- | ----------------- | -------- | ---------------------------------- |
| `after` | string, truy vấn  | Không    | ID sự kiện cuối trang trước.       |
| `limit` | integer, truy vấn | Không    | Số sự kiện mỗi trang, mặc định 20. |

## Phản hồi

| Trường              | Kiểu                    | Mô tả                                    |
| ------------------- | ----------------------- | ---------------------------------------- |
| `object`            | string                  | Luôn `list`.                             |
| `has_more`          | boolean                 | Có trang tiếp không.                     |
| `data`              | array                   | Sự kiện trang hiện tại.                  |
| `data[].id`         | string                  | ID sự kiện cho phân trang.               |
| `data[].object`     | string                  | Luôn `fine_tuning.job.event`.            |
| `data[].created_at` | integer                 | Thời gian sự kiện Unix giây.             |
| `data[].level`      | string                  | `info`, `warn` hoặc `error`.             |
| `data[].message`    | string                  | Mô tả dễ đọc.                            |
| `data[].type`       | string, tùy chọn        | `message` hoặc `metrics`.                |
| `data[].data`       | object / null, tùy chọn | Dữ liệu thêm; trường chỉ số tùy sự kiện. |

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

## Ví dụ mã

Yêu cầu Python 3, Node.js 20+, curl hoặc Go 1.20+. Lưu ví dụ thành `.py`, `.cjs`, `.sh`, `.go` rồi chạy.

Đặt `OPENAI_API_KEY` và `OPENAI_FINE_TUNING_JOB_ID`. Trang sau dùng ID sự kiện cuối hiện tại làm `after`.

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

## Mã lỗi

Lỗi HTTP thường của OpenAI trực tiếp, không là trạng thái hỗ trợ SimiRouter.

| Mã HTTP       | Ý nghĩa                                   | Cách xử lý                                                                       |
| ------------- | ----------------------------------------- | -------------------------------------------------------------------------------- |
| `400`         | Tham số, mục đích tệp hoặc trạng thái sai | Đọc `error.message` và `error.param`, sửa trước gửi lại.                         |
| `401`         | Khóa thiếu hoặc không hợp lệ              | Kiểm khóa OpenAI và dự án.                                                       |
| `403`         | Không quyền dự án/tài nguyên              | Kiểm dự án, tổ chức, vai trò.                                                    |
| `404`         | Tệp, tác vụ, mô hình không có             | Kiểm ID và dùng khóa dự án sở hữu.                                               |
| `429`         | Giới hạn tốc độ/thiếu hạn mức             | Phân biệt tốc độ và hạn mức; lùi khi tốc độ, không gửi lặp nếu thiếu hạn mức.    |
| `500` / `503` | Lỗi máy chủ/tạm không có                  | Giữ ID; trước lặp ghi, xem đã tạo tài nguyên chưa để tránh tải/huấn luyện trùng. |

Lỗi thường có `error.message`, `error.type`, `error.param` và `error.code` ; trường có thể rỗng.

## Tham khảo chính thức

* [Sự kiện tinh chỉnh OpenAI](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/list_events)
* [Mã lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)