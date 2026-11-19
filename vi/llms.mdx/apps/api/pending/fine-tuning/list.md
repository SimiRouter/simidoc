# Liệt kê tinh chỉnh

Phân trang tác vụ mà khóa hiện tại thấy trong tổ chức OpenAI.

**SimiRouter chưa hỗ trợ. Tham khảo OpenAI chính thức tại `api.openai.com`, cần khóa dự án OpenAI, không SimiRouter.**

## Tổng quan API

* **Phương thức**\: `GET`
* **Địa chỉ API**\: `/v1/fine_tuning/jobs`
* **Xác thực**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Loại yêu cầu**\: không thân.

Truy vấn đồng bộ, không khởi/chờ huấn luyện. Ý nghĩa trạng thái như [Lấy chi tiết tác vụ](/simidoc/vi/apps/api/pending/fine-tuning/retrieve).

## Tham số yêu cầu

| Tham số    | Kiểu                    | Bắt buộc | Mô tả                                                                                            |
| ---------- | ----------------------- | -------- | ------------------------------------------------------------------------------------------------ |
| `after`    | string, truy vấn        | Không    | ID tác vụ cuối trang trước.                                                                      |
| `limit`    | integer, truy vấn       | Không    | Số tác vụ trang, mặc định 20.                                                                    |
| `metadata` | object / null, truy vấn | Không    | Dùng `metadata[key]=value` lọc; `metadata=null` chọn tác vụ không metadata. Không cùng hai cách. |

## Phản hồi

| Trường     | Kiểu             | Mô tả                                             |
| ---------- | ---------------- | ------------------------------------------------- |
| `object`   | string           | Luôn `list`.                                      |
| `data`     | FineTuningJob\[] | Đối tượng tác vụ trang hiện tại.                  |
| `has_more` | boolean          | Có trang tiếp; dùng ID cuối hiện tại làm `after`. |

| Trường             | Kiểu                     | Mô tả                                                                                                 |
| ------------------ | ------------------------ | ----------------------------------------------------------------------------------------------------- |
| `id` / `object`    | string                   | ID tác vụ, loại đối tượng luôn `fine_tuning.job`.                                                     |
| `model`            | string                   | Mô hình nền huấn luyện.                                                                               |
| `status`           | string                   | `validating_files`, `queued`, `running`, `pausing`, `paused`, `succeeded`, `failed` hoặc `cancelled`. |
| `created_at`       | integer                  | Thời gian tạo Unix giây.                                                                              |
| `finished_at`      | integer / null           | Thời gian xong, rỗng nếu chưa kết thúc.                                                               |
| `estimated_finish` | integer / null, tùy chọn | Ước tính xong, không bảo đảm.                                                                         |
| `fine_tuned_model` | string / null            | ID mô hình sinh ra, chưa có thì rỗng.                                                                 |
| `training_file`    | string                   | ID tệp huấn luyện.                                                                                    |
| `validation_file`  | string / null            | ID kiểm định, không đặt thì rỗng.                                                                     |
| `result_files`     | string\[]                | ID kết quả tải qua Files API chính thức.                                                              |
| `trained_tokens`   | integer / null           | Token huấn luyện tính phí, đang chạy có thể rỗng.                                                     |
| `error`            | object / null            | Chi tiết lỗi gồm `code`, `message`, `param`; lỗi không tham số có `param` có thể rỗng.                |
| `organization_id`  | string                   | Tổ chức sở hữu.                                                                                       |
| `seed`             | integer / null           | Hạt giống dùng lần huấn luyện.                                                                        |
| `method`           | object / null, tùy chọn  | Phương pháp tinh chỉnh và cấu hình.                                                                   |
| `hyperparameters`  | object / null, tùy chọn  | Trường tương thích siêu tham số giám sát.                                                             |
| `integrations`     | array / null, tùy chọn   | Tích hợp chỉ số ngoài đã bật.                                                                         |
| `metadata`         | object / null, tùy chọn  | Metadata khóa/giá trị tùy chỉnh.                                                                      |

```json
{
  "object": "list",
  "data": [
    {
      "id": "ftjob-demo",
      "object": "fine_tuning.job",
      "model": "selected-base-model",
      "created_at": 1793491200,
      "finished_at": null,
      "fine_tuned_model": null,
      "status": "queued",
      "training_file": "file-training",
      "validation_file": null,
      "result_files": [],
      "trained_tokens": null,
      "error": null,
      "organization_id": "org-demo",
      "seed": null,
      "method": {
        "type": "supervised"
      },
      "metadata": {}
    }
  ],
  "has_more": false
}
```

## Ví dụ mã

Yêu cầu Python 3, Node.js 20+, curl hoặc Go 1.20+. Lưu ví dụ thành `.py`, `.cjs`, `.sh`, `.go` rồi chạy.

Đặt `OPENAI_API_KEY`. Ví dụ lấy 20 đầu; nếu `has_more=true`, đặt `data` thì lấy đối tượng cuối trong `id` và dùng giá trị này cho tham số trang sau `after`.

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
        "https://api.openai.com/v1/fine_tuning/jobs?limit=20",
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

      const response = await fetch("https://api.openai.com/v1/fine_tuning/jobs?limit=20", {
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

    curl "https://api.openai.com/v1/fine_tuning/jobs?limit=20" \
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

    	req, err := http.NewRequest("GET", "https://api.openai.com/v1/fine_tuning/jobs?limit=20", nil)
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

* [Danh sách tinh chỉnh OpenAI](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs/methods/list)
* [Mã lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)