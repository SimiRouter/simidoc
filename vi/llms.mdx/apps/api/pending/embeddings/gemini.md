# Nhúng Gemini

**SimiRouter chưa hỗ trợ API này. Dưới tham khảo Google trực tiếp.** Ví dụ dùng khóa Gemini API từ Google AI Studio. Với Vertex AI, hãy làm theo tài liệu Google Cloud về đường dẫn yêu cầu, cấu hình dự án và xác thực.

## Tổng quan API

`POST https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent` và `x-goog-api-key: $GEMINI_API_KEY`. Ví dụ chữ; Gemini Embedding 2 còn hỗ trợ đa phương thức theo mô hình, không áp cho nhúng chữ cũ.

## Tham số yêu cầu

| Trường                                  | Kiểu      | Bắt buộc | Mô tả                                                               |
| --------------------------------------- | --------- | -------- | ------------------------------------------------------------------- |
| model (đường dẫn)                       | string    | Có       | models/gemini-embedding-2, phải là mô hình nhúng khả dụng.          |
| content                                 | object    | Có       | Content cần nhúng, chữ parts\[].text.                               |
| content.parts                           | object\[] | Có       | Mục chữ hoặc inline\_data/file\_data đa phương thức mô hình hỗ trợ. |
| embedContentConfig                      | object    | Không    | Cấu hình nhúng theo phiên bản và API Reference.                     |
| embedContentConfig.outputDimensionality | integer   | Không    | Chiều đầu ra hỗ trợ, giữ nhất quán chỉ mục/truy vấn.                |

`gemini-embedding-2` không hỗ trợ `embedContentConfig.taskType` hay `title`. Với truy xuất, hãy thêm tiền tố vào văn bản\:

* Truy vấn\: `task: search result | query: {content}`
* Tài liệu\: `title: {title} | text: {content}`; không có tiêu đề thì dùng `title: none`
* Tác vụ đối xứng\: `task: {task} | query: {content}`

`taskType` và `title` chỉ áp dụng cho `gemini-embedding-001`. `gemini-embedding-2` không hỗ trợ các trường này; hãy dùng tiền tố đầu vào ở trên và không dựa vào cách xử lý trường chưa được định nghĩa. Không gian vector của embedding-2 và embedding-001 không tương thích; chỉ mục và truy vấn phải dùng cùng mô hình.

Các trường cấp đầu `taskType`, `title`, `outputDimensionality` là cấu hình cũ; SDK dùng đối tượng config, không trộn snake\_case với camelCase JSON.

## Phản hồi

Một lần đồng bộ trả `embedding.values` mảng số thực. `batchEmbedContents` nhận mảng requests, trả `embeddings[]` theo thứ tự. Bất đồng bộ `asyncBatchEmbedContent` trả tài nguyên tác vụ dài, quản lý trạng thái/tệp riêng, khác yêu cầu đồng bộ này.

```json
{"embedding":{"values":[0.01,-0.02,0.03]}}
```

Vector chỉ trích ví dụ; giảm chiều thì chuẩn hóa theo mô hình, ba số đầu không là vector đầy đủ.

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Trước tiên đặt `GEMINI_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent'
    headers = {'x-goog-api-key': os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'models/gemini-embedding-2', 'content': {'parts': [{'text': 'task: search result | query: 如何让文档检索理解语义？'}]}}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent";
      const headers = { "x-goog-api-key": process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
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
    curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "models/gemini-embedding-2",
        "content": {
          "parts": [
            {
              "text": "task: search result | query: 如何让文档检索理解语义？"
            }
          ]
        }
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
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent", body); check(err)
      req.Header.Set("x-goog-api-key", os.Getenv("GEMINI_API_KEY"))
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

| Trạng thái HTTP       | Ý nghĩa và xử lý                                                                                                        |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 400                   | Trường yêu cầu hoặc tham số mô hình không hợp lệ; sửa rồi gửi lại.                                                      |
| 401                   | Khóa API thiếu, không hợp lệ hoặc hết hạn.                                                                              |
| 403                   | Không có quyền dự án hoặc mô hình.                                                                                      |
| 404                   | Không tìm thấy mô hình hoặc tuyến; kiểm tra địa chỉ và ID mô hình.                                                      |
| 429                   | Giới hạn tốc độ hoặc hạn mức; phân biệt thiếu số dư với giới hạn có thể thử lại.                                        |
| 500 / 502 / 503 / 504 | Lỗi dịch vụ hoặc thượng nguồn. Giữ ID yêu cầu và chờ trước khi thử lại; không lặp lại vô hạn cùng một yêu cầu tính phí. |

Đối tượng lỗi Google dùng `error.code`, `error.status` và `error.message`; đừng chỉ dựa vào con số HTTP để đoán nguồn. Giao diện này là yêu cầu đồng bộ\: không có ID tác vụ hay giai đoạn thăm dò. Không bao giờ coi nội dung lỗi là kết quả embedding.

## Tham khảo chính thức

[Google Embeddings guide](https\://ai.google.dev/gemini-api/docs/embeddings), [Embedding API](https\://ai.google.dev/api/embeddings).