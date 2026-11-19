# Danh sách mô hình định dạng Gemini

## Tổng quan API

`GET /v1beta/models` trả danh sách định dạng Gemini.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. Google trực tiếp dùng `https://generativelanguage.googleapis.com`, thường với `x-goog-api-key: $GEMINI_API_KEY`, không phải khóa Bearer cổng. Chọn mô hình có quyền và hỗ trợ khả năng cần dùng.

Danh sách cổng chủ yếu tìm tên mô hình, không phải danh mục khả năng đầy đủ Google.

## Tham số yêu cầu

Yêu cầu cổng không có thân hay tham số phân trang bắt buộc. Google models.list hỗ trợ pageSize (mặc định 50, tối đa 1000), pageToken; cổng trả toàn bộ, không bảo đảm phân trang/siêu dữ liệu tương đương.

| Trường               | Kiểu                   | Bắt buộc     | Mô tả                                                                |
| -------------------- | ---------------------- | ------------ | -------------------------------------------------------------------- |
| Authorization        | header string          | Có           | Khóa cổng Bearer; kết nối Google trực tiếp dùng khóa Google.         |
| pageSize / pageToken | query integer / string | Tùy chọn gốc | Chỉ phân trang danh sách gốc chính thức; không phụ thuộc cổng xử lý. |

## Phản hồi

| Trường                                       | Kiểu           | Mô tả                                                              |
| -------------------------------------------- | -------------- | ------------------------------------------------------------------ |
| models                                       | array          | Danh sách mô hình có thể rỗng.                                     |
| models\[].name                               | string         | Tên tài nguyên thường models/\{id}, cổng có thể trả ID thuần.      |
| models\[].displayName                        | string         | Tên dễ đọc.                                                        |
| nextPageToken                                | string / null  | Token trang sau chính thức; cổng có thể null nếu không phân trang. |
| models\[].version / description              | string / null  | Phiên bản, mô tả chính thức; cổng có thể thiếu/null.               |
| models\[].inputTokenLimit / outputTokenLimit | integer / null | Giới hạn vào/ra chính thức, không suy đoán từ trường thiếu.        |
| models\[].supportedGenerationMethods         | array / null   | Tên phương thức như generateContent; cổng có thể thiếu/null.       |

```json
{
  "models": [
    {
      "name": "MODEL_ID",
      "displayName": "MODEL_ID"
    }
  ],
  "nextPageToken": null
}
```

Trên là cấu trúc rút gọn cổng. Trước dùng name trong đường dẫn, chỉ bỏ một tiền tố models/. models.list thành công không bảo đảm generateContent vì quyền, khả năng, hạn mức.

## Ví dụ mã

Đặt `SIMIROUTER_API_KEY`. Để thay địa chỉ gốc mặc định của cổng, đặt `SIMIROUTER_BASE_URL` thành địa chỉ không có hậu tố phiên bản. Tất cả ví dụ gửi yêu cầu GET không có phần thân.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1beta/models'
    request = urllib.request.Request(base + path, method="GET",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const endpoint = "/v1beta/models";
      const response = await fetch(base + endpoint, { method: "GET",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    curl "${BASE_URL%/}/v1beta/models" \
      --fail-with-body \
      --max-time 120 \
      -X GET \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY"
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
      "strings"
      "time"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      endpoint := "/v1beta/models"
      req, err := http.NewRequest("GET", base + endpoint, nil); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Mã lỗi

| Trạng thái HTTP | Ý nghĩa hoặc loại lỗi hãng         | Cách xử lý                                                                  |
| --------------- | ---------------------------------- | --------------------------------------------------------------------------- |
| 400             | `INVALID_ARGUMENT` và lỗi tương tự | Kiểm tra JSON, tham số, MIME phương tiện và độ dài đầu vào.                 |
| 403             | `PERMISSION_DENIED`                | Kiểm tra khóa, quyền dự án, vùng hoặc giới hạn thanh toán.                  |
| 404             | `NOT_FOUND`                        | Kiểm tra tên mô hình và phiên bản API.                                      |
| 429             | `RESOURCE_EXHAUSTED`               | Kiểm tra tốc độ, hạn mức; lùi thời gian số lần giới hạn nếu có thể thử lại. |
| 500 / 503       | `INTERNAL` / `UNAVAILABLE`         | Ghi ID yêu cầu, thử lại có giới hạn hoặc sau đó.                            |

Đối tượng lỗi Google gồm `error.code` (mã HTTP), `error.status` (tên enum), `error.message` và có thể có `details`. Cổng có thể lỗi xác thực, tuyến, hạn mức trước hãng; mã HTTP không chứng minh nguồn lỗi. Truy vấn nội bộ có thể HTTP 200 với success=false; kiểm tra cả cấu trúc.

## Tham khảo chính thức

* [Google Models API](https\://ai.google.dev/api/models)
* [Danh mục mô hình Google](https\://ai.google.dev/gemini-api/docs/models)
* [Khắc phục sự cố Google](https\://ai.google.dev/gemini-api/docs/troubleshooting)