# Danh sách mô hình định dạng OpenAI

## Tổng quan API

`GET /v1/models` trả mô hình khóa hiện tại thấy được. Dùng cho bộ chọn, không chứng minh mọi phương thức, công cụ, hạn mức hay dịch vụ đang khỏe.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

Chỉ Bearer, không trộn x-api-key/x-goog-api-key để tránh kích hoạt định dạng cổng khác.

## Tham số yêu cầu

Không có thân JSON hay tham số truy vấn bắt buộc.

| Trường        | Kiểu          | Bắt buộc | Mô tả                 |
| ------------- | ------------- | -------- | --------------------- |
| Authorization | header string | Có       | Khóa cổng sau Bearer. |

## Phản hồi

| Trường                            | Kiểu                   | Mô tả                                                                                                                                                                 |
| --------------------------------- | ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| object                            | string                 | list.                                                                                                                                                                 |
| data                              | array                  | Danh sách có thể rỗng.                                                                                                                                                |
| data\[].id                        | string                 | ID dùng khi gọi sinh.                                                                                                                                                 |
| data\[].object                    | string                 | model.                                                                                                                                                                |
| data\[].created                   | integer                | Thời điểm Unix giây; không nhất thiết ngày hãng phát hành mô hình.                                                                                                    |
| data\[].owned\_by                 | string                 | Nhãn sở hữu, không chứng minh yêu cầu định tuyến tới hãng đó.                                                                                                         |
| success                           | boolean                | Cờ kết quả nghiệp vụ tùy chọn của cổng, không chuẩn OpenAI.                                                                                                           |
| `data[].context_length`           | integer                | Độ dài ngữ cảnh tính bằng Token do cổng báo cáo. Nếu chưa cấu hình, cổng dùng giá trị mặc định của nền tảng. Hãy kiểm tra tài liệu mô hình và giới hạn của điểm cuối. |
| `data[].supported_endpoint_types` | `array<string>` / null | Các loại điểm cuối do cổng báo cáo. Dùng thông tin này để chọn điểm cuối phù hợp.                                                                                     |

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

Mảng rỗng hợp lệ, không truy cập data\[0] trực tiếp. Lỗi truy vấn nhóm cổng có thể HTTP 200, success=false/message; phải nhận diện lỗi nghiệp vụ. OpenAI có GET /v1/models/\{model}, danh sách không là mô tả khả năng đầy đủ.

## Ví dụ mã

Đặt `SIMIROUTER_API_KEY`. Để thay địa chỉ gốc mặc định của cổng, đặt `SIMIROUTER_BASE_URL` thành địa chỉ không có hậu tố phiên bản. Tất cả ví dụ gửi yêu cầu GET không có phần thân.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1/models'
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
      const endpoint = "/v1/models";
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
    curl "${BASE_URL%/}/v1/models" \
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
      endpoint := "/v1/models"
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

| Trạng thái HTTP | Ý nghĩa hoặc loại lỗi hãng           | Cách xử lý                                                                                              |
| --------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------- |
| 400             | Yêu cầu không hợp lệ                 | Kiểm tra trường bắt buộc, JSON, tham số và độ dài ngữ cảnh.                                             |
| 401             | Xác thực thất bại                    | Kiểm tra khóa có, hợp lệ và thuộc đúng dịch vụ.                                                         |
| 403 / 404       | Không có quyền / không có tài nguyên | Kiểm tra quyền mô hình, ID và URL.                                                                      |
| 429             | Giới hạn tốc độ hoặc hạn mức         | Theo thân phản hồi phân biệt giới hạn tốc độ với thiếu hạn mức; thử lại không giải quyết thiếu hạn mức. |
| 500 / 503       | Lỗi máy chủ / tạm không khả dụng     | Giữ ID yêu cầu, lùi thời gian giới hạn cho lỗi tạm.                                                     |

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn có hoặc bằng HTTP. Cổng có thể lỗi xác thực, tuyến, hạn mức trước hãng; mã HTTP không chứng minh nguồn lỗi. Kiểm tra success=false nghiệp vụ, khác thành công truyền tải HTTP.

## Tham khảo chính thức

* [OpenAI List models](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [OpenAI Retrieve model](https\://developers.openai.com/api/reference/resources/models/methods/retrieve)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)