# Lấy nội dung tệp

Tải nội dung thô tệp OpenAI đọc được, tệp tải lên hoặc kết quả.

**SimiRouter chưa hỗ trợ. Tham khảo OpenAI chính thức tại `api.openai.com`, cần khóa dự án OpenAI, không SimiRouter.**

## Tổng quan API

* **Phương thức**\: `GET`
* **Địa chỉ API**\: `/v1/files/{file_id}/content`
* **Xác thực**\: `Authorization: Bearer $OPENAI_API_KEY`
* **Loại yêu cầu**\: không thân.

HTTP thường chờ tải xong, không SSE mô hình hay tác vụ bất đồng bộ. Khóa phải cùng dự án; không mọi mục đích tệp cho đọc nội dung.

## Tham số yêu cầu

| Tham số   | Kiểu              | Bắt buộc | Mô tả                |
| --------- | ----------------- | -------- | -------------------- |
| `file_id` | string, đường dẫn | Có       | ID tệp dự án OpenAI. |

## Phản hồi

Thành công trả byte tệp, không JSON có `data`. Chọn đuôi theo định dạng gốc, không giải nhị phân UTF-8. Lỗi vẫn có thể JSON.

| Nội dung        | Mô tả                                                                  |
| --------------- | ---------------------------------------------------------------------- |
| Trạng thái HTTP | Thành công `200`.                                                      |
| Thân phản hồi   | Byte gốc, JSONL phân tích từng dòng.                                   |
| Tên tệp         | Trước tải dùng [Lấy thông tin tệp](/simidoc/vi/apps/api/pending/files/retrieve) để truy vấn `filename`. |

## Ví dụ mã

Yêu cầu Python 3, Node.js 20+, curl hoặc Go 1.20+. Lưu ví dụ thành `.py`, `.cjs`, `.sh`, `.go` rồi chạy.

Đặt `OPENAI_API_KEY` và `OPENAI_FILE_ID`; dùng `OUTPUT_FILE` chỉ đường dẫn ra, mặc định `downloaded-file.bin`. Python/Node.js/Go ghi đè tệp trùng; kiểm đường dẫn trước. curl từ chối ghi đè.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request
    from pathlib import Path

    def required(name):
        value = os.environ.get(name)
        if not value:
            raise SystemExit(f"请设置 {name}")
        return value

    key = required("OPENAI_API_KEY")
    file_id = required("OPENAI_FILE_ID")
    file_id_encoded = urllib.parse.quote(file_id, safe="")
    request = urllib.request.Request(
        f"https://api.openai.com/v1/files/{file_id_encoded}/content",
        method="GET",
        data=None,
        headers={"Authorization": "Bearer " + key},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = response.read()
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    output = Path(os.environ.get("OUTPUT_FILE", "downloaded-file.bin"))
    output.write_bytes(result)
    print(output)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { writeFile } = require("node:fs/promises");
    function required(name) {
      const value = process.env[name];
      if (!value) throw new Error(`请设置 ${name}`);
      return value;
    }
    async function main() {
      const key = required("OPENAI_API_KEY");
      const file_id = required("OPENAI_FILE_ID");
      const fileId = encodeURIComponent(file_id);
      const response = await fetch(`https://api.openai.com/v1/files/${fileId}/content`, {
        method: "GET",
        headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const output = process.env.OUTPUT_FILE || "downloaded-file.bin";
      await writeFile(output, Buffer.from(await response.arrayBuffer()));
      console.log(output);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"
    : "${OPENAI_FILE_ID:?请设置 OPENAI_FILE_ID}"
    [[ "$OPENAI_FILE_ID" =~ ^[A-Za-z0-9_:-]+$ ]] || { printf '%s\n' '资源 ID 格式错误' >&2; exit 1; }
    download=$(mktemp)
    trap 'rm -f "$download"' EXIT
    curl "https://api.openai.com/v1/files/${OPENAI_FILE_ID}/content" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request GET \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --output "$download"
    # 仅在 HTTP 成功后发布文件；不覆盖已有输出。
    ln "$download" "${OUTPUT_FILE:-downloaded-file.bin}"
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
    	file_id := required("OPENAI_FILE_ID")
    	target := fmt.Sprintf("https://api.openai.com/v1/files/%s/content", url.PathEscape(file_id))
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
    	output := os.Getenv("OUTPUT_FILE")
    	if output == "" {
    		output = "downloaded-file.bin"
    	}
    	check(os.WriteFile(output, result, 0600))
    	fmt.Println(output)
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

* [OpenAI lấy nội dung tệp](https\://developers.openai.com/api/reference/resources/files/methods/content)
* [Mã lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)