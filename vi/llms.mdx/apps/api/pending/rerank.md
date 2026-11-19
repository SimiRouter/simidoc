# Xếp hạng lại tài liệu

## Tổng quan API

Xếp hạng lại so query với tài liệu, trả index/điểm theo liên quan, không sinh trả lời hay vector. Khả dụng SimiRouter `/v1/rerank` cần xác nhận kênh; dưới chỉ minh họa **Cohere chính thức** `POST https://api.cohere.com/v2/rerank` và `Authorization: Bearer $COHERE_API_KEY`.

## Tham số yêu cầu

| Trường                | Kiểu      | Bắt buộc | Mô tả                                                                                                          |
| --------------------- | --------- | -------- | -------------------------------------------------------------------------------------------------------------- |
| model                 | string    | Có       | Ví dụ rerank-v5.0-pro, dùng mô hình tài khoản đã mở.                                                           |
| query                 | string    | Có       | Truy vấn tìm kiếm.                                                                                             |
| documents             | string\[] | Có       | Mảng văn bản ứng viên; chính thức khuyên tối đa 1000 mỗi lần. Có thể chuyển dữ liệu cấu trúc thành chuỗi YAML. |
| top\_n                | integer   | Không    | Ít nhất 1, bỏ để trả toàn bộ.                                                                                  |
| max\_tokens\_per\_doc | integer   | Không    | Mặc định 4096, tài liệu dài bị cắt.                                                                            |
| relevant\_spans       | object    | Không    | v5 trở lên có thể trả khoảng chữ liên quan.                                                                    |
| priority              | integer   | Không    | 0–999, mặc định 0; số nhỏ ưu tiên cao.                                                                         |

Cohere v2 documents là mảng chuỗi, không trộn đối tượng chưa định nghĩa; `return_documents` thuộc phiên bản khác, không gửi trong ví dụ này.

## Phản hồi

`results[]` được xếp theo liên quan\: `index` trỏ chỉ số tài liệu gốc, `relevance_score` là điểm liên quan; bật và hỗ trợ thì trả `relevant_spans[]`. Điểm không là độ đúng hay xác suất thống nhất so giữa mô hình. `meta.billed_units` ghi nhận mức dùng.

```json
{"results":[{"index":1,"relevance_score":0.95},{"index":0,"relevance_score":0.12}],"id":"request_example","meta":{"api_version":{"version":"2"}}}
```

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Đặt Cohere chính thức `COHERE_API_KEY`. Ví dụ top\_n dương, không query hay tài liệu rỗng.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.cohere.com/v2/rerank'
    headers = {'Authorization': 'Bearer ' + os.environ['COHERE_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'rerank-v5.0-pro', 'query': '法国首都是哪里？', 'documents': ['柏林是德国首都。', '巴黎是法国首都。'], 'top_n': 2}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.cohere.com/v2/rerank";
      const headers = { "Authorization": "Bearer " + process.env.COHERE_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.cohere.com/v2/rerank" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $COHERE_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "rerank-v5.0-pro",
        "query": "法国首都是哪里？",
        "documents": [
          "柏林是德国首都。",
          "巴黎是法国首都。"
        ],
        "top_n": 2
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
    }`)
      req, err := http.NewRequest("POST", "https://api.cohere.com/v2/rerank", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("COHERE_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Mã lỗi

| Trạng thái HTTP       | Mô tả                                                       |
| --------------------- | ----------------------------------------------------------- |
| 400 / 422             | Tham số hoặc đầu vào mô hình không chấp nhận.               |
| 401 / 498             | Xác thực thất bại hoặc token không hợp lệ.                  |
| 403 / 404             | Không đủ quyền hoặc thiếu tài nguyên.                       |
| 429                   | Giới hạn tốc độ, kiểm tra hạn mức và lùi thời gian hữu hạn. |
| 499                   | Ứng dụng đã đóng yêu cầu.                                   |
| 500 / 501 / 503 / 504 | Lỗi nội bộ, chưa triển khai hoặc timeout; giữ ID yêu cầu.   |

## Tham khảo chính thức

[Cohere Rerank v2](https\://docs.cohere.com/reference/rerank).