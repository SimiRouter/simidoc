# Tải tệp

Tải tệp máy, lấy ID cho API OpenAI khác.

**SimiRouter chưa hỗ trợ. Tham khảo OpenAI chính thức tại `api.openai.com`, cần khóa dự án OpenAI, không SimiRouter.**

## Tổng quan API

* **Phương thức**\: `POST`
* **Địa chỉ API**\: `/v1/files`
* **Xác thực**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Loại yêu cầu**\: `multipart/form-data`.

HTTP trả đối tượng tệp, không hoàn thành huấn luyện/Batch/chỉ mục. Một tệp 512 MB; Batch riêng 200 MB, tinh chỉnh phải JSONL. Để client tạo boundary.

## Tham số yêu cầu

| Tham số         | Kiểu   | Bắt buộc | Mô tả                                                                                                                              |
| --------------- | ------ | -------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `file`          | binary | Có       | Tệp thực, không tên dạng chuỗi.                                                                                                    |
| `purpose`       | string | Có       | Mục đích\: `assistants`, `batch`, `fine-tune`, `vision`, `user_data` hoặc `evals`.                                                 |
| `expires_after` | object | Không    | Chính sách hết hạn; `anchor` luôn `created_at`, `seconds` từ 3600–2592000. Không đặt thì batch 30 ngày; khác giữ đến xóa thủ công. |

## Phản hồi

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

Ví dụ phản hồi, ID/thời gian chỉ minh họa\:

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

## Ví dụ mã

Yêu cầu Python 3, Node.js 20+, curl hoặc Go 1.20+. Lưu ví dụ thành `.py`, `.cjs`, `.sh`, `.go` rồi chạy.

Ví dụ tải JSONL tinh chỉnh. Đặt trước `OPENAI_API_KEY` và `INPUT_FILE`; dữ liệu phải khớp phương pháp. Tải không bắt đầu huấn luyện.

Ví dụ nạp tệp bộ nhớ để minh họa multipart; tệp lớn nên tải theo luồng.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.request
    import uuid
    from pathlib import Path

    key = os.environ.get("OPENAI_API_KEY")
    source = os.environ.get("INPUT_FILE")
    if not key or not source:
        raise SystemExit("请设置 OPENAI_API_KEY 和 INPUT_FILE")
    path = Path(source)
    if not path.is_file() or path.stat().st_size == 0:
        raise SystemExit("INPUT_FILE 必须是非空的本地文件")
    boundary = "upload-" + uuid.uuid4().hex
    body = (
        f'--{boundary}\r\nContent-Disposition: form-data; name="purpose"\r\n\r\nfine-tune\r\n'
        f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="training.jsonl"\r\n'
        'Content-Type: application/jsonl\r\n\r\n'
    ).encode() + path.read_bytes() + f"\r\n--{boundary}--\r\n".encode()
    request = urllib.request.Request(
        "https://api.openai.com/v1/files", method="POST", data=body,
        headers={"Authorization": "Bearer " + key,
                 "Content-Type": "multipart/form-data; boundary=" + boundary},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            print(json.dumps(json.load(response), ensure_ascii=False, indent=2))
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile, stat } = require("node:fs/promises");
    const { basename } = require("node:path");
    async function main() {
      const key = process.env.OPENAI_API_KEY;
      const path = process.env.INPUT_FILE;
      if (!key || !path) throw new Error("请设置 OPENAI_API_KEY 和 INPUT_FILE");
      const info = await stat(path);
      if (!info.isFile() || info.size === 0) throw new Error("INPUT_FILE 必须是非空的本地文件");
      const form = new FormData();
      form.append("purpose", "fine-tune");
      form.append("file", new Blob([await readFile(path)], { type: "application/jsonl" }), basename(path));
      const response = await fetch("https://api.openai.com/v1/files", {
        method: "POST", headers: { Authorization: `Bearer ${key}` }, body: form,
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.json());
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"
    : "${INPUT_FILE:?请设置 INPUT_FILE 为训练集的本地路径}"
    [[ -f "$INPUT_FILE" && -s "$INPUT_FILE" ]] || { printf '%s\n' 'INPUT_FILE 必须是非空的本地文件' >&2; exit 1; }
    curl --fail-with-body --connect-timeout 15 --max-time 120 --request POST \
      "https://api.openai.com/v1/files" \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --form "purpose=fine-tune" \
      --form "file=@${INPUT_FILE};type=application/jsonl"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"bytes"
    	"fmt"
    	"io"
    	"log"
    	"mime/multipart"
    	"net/http"
    	"os"
    	"path/filepath"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func main() {
    	key, path := os.Getenv("OPENAI_API_KEY"), os.Getenv("INPUT_FILE")
    	if key == "" || path == "" {
    		log.Fatal("请设置 OPENAI_API_KEY 和 INPUT_FILE")
    	}
    	file, err := os.Open(path)
    	check(err)
    	defer file.Close()
    	info, err := file.Stat()
    	check(err)
    	if !info.Mode().IsRegular() || info.Size() == 0 {
    		log.Fatal("INPUT_FILE 必须是非空的本地文件")
    	}
    	var body bytes.Buffer
    	form := multipart.NewWriter(&body)
    	check(form.WriteField("purpose", "fine-tune"))
    	part, err := form.CreateFormFile("file", filepath.Base(path))
    	check(err)
    	_, err = io.Copy(part, file)
    	check(err)
    	check(form.Close())
    	req, err := http.NewRequest("POST", "https://api.openai.com/v1/files", &body)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	req.Header.Set("Content-Type", form.FormDataContentType())
    	response, err := (&http.Client{Timeout: 120 * time.Second}).Do(req)
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

* [OpenAI tải tệp](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [Mã lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)