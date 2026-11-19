# Liệt kê tệp

Liệt kê tệp có quyền trong dự án hiện tại, phân trang.

**SimiRouter chưa hỗ trợ. Tham khảo OpenAI chính thức tại `api.openai.com`, cần khóa dự án OpenAI, không SimiRouter.**

## Tổng quan API

* **Phương thức**\: `GET`
* **Địa chỉ API**\: `/v1/files`
* **Xác thực**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Loại yêu cầu**\: không thân.

Trả JSON trang hiện tại đồng bộ; `has_more=true` cần trang tiếp; một lệnh không tự trả tất cả.

## Tham số yêu cầu

| Tham số   | Kiểu              | Bắt buộc | Mô tả                                                        |
| --------- | ----------------- | -------- | ------------------------------------------------------------ |
| `after`   | string, truy vấn  | Không    | ID tệp cuối trang trước.                                     |
| `limit`   | integer, truy vấn | Không    | 1–10000 mỗi trang, mặc định 10000; ví dụ 20.                 |
| `order`   | string, truy vấn  | Không    | Sắp theo thời gian tạo\: `asc` hoặc `desc`, mặc định `desc`. |
| `purpose` | string, truy vấn  | Không    | Chỉ tệp đúng mục đích.                                       |

## Phản hồi

| Trường                 | Kiểu          | Mô tả                                |
| ---------------------- | ------------- | ------------------------------------ |
| `object`               | string        | Loại danh sách, thường `list`.       |
| `data`                 | FileObject\[] | Tệp trang hiện tại, trường bên dưới. |
| `first_id` / `last_id` | string        | ID đầu/cuối trang.                   |
| `has_more`             | boolean       | Có trang tiếp không.                 |

| Trường           | Kiểu                                | Mô tả                                                                                           |
| ---------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------- |
| `id`             | string                              | ID tệp cho yêu cầu sau.                                                                         |
| `object`         | string                              | Luôn `file`.                                                                                    |
| `bytes`          | integer / null                      | Kích thước byte; có thể null khi chưa biết.                                                     |
| `created_at`     | integer                             | Thời gian tạo Unix giây.                                                                        |
| `filename`       | string                              | Tên khi tải.                                                                                    |
| `purpose`        | string                              | Mục đích như `fine-tune`, `user_data`; kết quả có thể dùng `fine-tune-results` và giá trị khác. |
| `expires_at`     | integer / null, tùy chọn            | Hết hạn Unix giây, có thể rỗng khi không chính sách.                                            |
| `status`         | string, đã bỏ dùng                  | Trạng thái cũ\: `uploaded`, `processed` hoặc `error`. Không thay trạng thái xử lý API tiêu thụ. |
| `status_details` | string / null, tùy chọn, đã bỏ dùng | Mô tả cũ; lỗi kiểm dữ liệu tinh chỉnh đọc ở `error`.                                            |

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

## Ví dụ mã

Yêu cầu Python 3, Node.js 20+, curl hoặc Go 1.20+. Lưu ví dụ thành `.py`, `.cjs`, `.sh`, `.go` rồi chạy.

Đặt `OPENAI_API_KEY`. Ví dụ lấy 20 đầu; trang tiếp dùng của trang trước `last_id` làm `after` tham số truy vấn.

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

* [Danh sách tệp OpenAI](https\://developers.openai.com/api/reference/resources/files/methods/list)
* [Mã lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)