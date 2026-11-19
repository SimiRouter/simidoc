# Nhúng OpenAI

**SimiRouter chưa hỗ trợ, dưới tham khảo OpenAI trực tiếp.**

## Tổng quan API

`POST https://api.openai.com/v1/embeddings`, `Content-Type: application/json`, `Authorization: Bearer $OPENAI_API_KEY`. Một yêu cầu trả vector đầy đủ, không SSE.

## Tham số yêu cầu

| Trường           | Kiểu                            | Bắt buộc | Mô tả                                                                               |
| ---------------- | ------------------------------- | -------- | ----------------------------------------------------------------------------------- |
| model            | string                          | Có       | Mô hình khả dụng như text-embedding-3-small/large.                                  |
| input            | string / string\[] / mảng token | Có       | Chữ/token không rỗng; tối đa 2048 mục, 8192 token mỗi đầu vào, 300000 tổng yêu cầu. |
| dimensions       | integer                         | Không    | Số nguyên dương, text-embedding-3 và mô hình sau hỗ trợ giảm chiều.                 |
| encoding\_format | string                          | Không    | float (mặc định) trả mảng thực, base64 trả chuỗi mã hóa.                            |
| user             | string                          | Không    | ID người dùng không có thông tin cá nhân thuần.                                     |

## Phản hồi

| Trường                                       | Mô tả                                          |
| -------------------------------------------- | ---------------------------------------------- |
| `object`                                     | list.                                          |
| `data[].object`                              | embedding.                                     |
| `data[].index`                               | Vị trí mảng đầu vào.                           |
| `data[].embedding`                           | Mảng vector/chuỗi Base64 tùy encoding\_format. |
| `model`                                      | Mô hình dùng.                                  |
| `usage.prompt_tokens` / `usage.total_tokens` | Thống kê token.                                |

Bỏ phần giữa vector để minh họa cấu trúc\:

```json
{"object":"list","data":[{"object":"embedding","index":0,"embedding":[0.01,-0.02]}],"model":"text-embedding-3-small","usage":{"prompt_tokens":3,"total_tokens":3}}
```

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Đặt `OPENAI_API_KEY`. Ví dụ lô đồng bộ, index khớp hai đầu vào.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/embeddings'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'text-embedding-3-small', 'input': ['语义搜索', '文档检索'], 'encoding_format': 'float'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/embeddings";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
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
    curl "https://api.openai.com/v1/embeddings" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "text-embedding-3-small",
        "input": [
          "语义搜索",
          "文档检索"
        ],
        "encoding_format": "float"
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
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/embeddings", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

Các trường `error.message`, `error.type` và `error.code` trong thân lỗi cho biết nguyên nhân cụ thể hơn mã HTTP. Giao diện này là yêu cầu đồng bộ\: không có ID tác vụ hay giai đoạn thăm dò. Không bao giờ coi nội dung lỗi là kết quả embedding.

## Tham khảo chính thức

[OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings/methods/create), [Embeddings guide](https\://developers.openai.com/api/docs/guides/embeddings).