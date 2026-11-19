# Tạo ảnh hội thoại

## Tổng quan API

`POST /v1/responses` khai báo image\_generation trong tools, mô hình chính gọi công cụ sinh ảnh. model chính là hội thoại; cấu hình mô hình ảnh theo hỗ trợ chính thức hiện tại.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

OpenAI gốc dùng Responses image\_generation, không quy ước link Markdown từ Chat thường. Hãng tương thích trả link qua Chat là mở rộng, không chuẩn OpenAI.

## Tham số yêu cầu

| Trường                               | Kiểu            | Bắt buộc | Mô tả                                                                          |
| ------------------------------------ | --------------- | -------- | ------------------------------------------------------------------------------ |
| model                                | string          | Có       | Mô hình Responses chính hỗ trợ image\_generation.                              |
| input                                | string / array  | Có       | Lời nhắc chữ; sửa có thể input\_image.                                         |
| tools\[].type                        | string          | Có       | image\_generation.                                                             |
| tools\[].output\_format              | string          | Không    | png, jpeg, webp; ví dụ png.                                                    |
| tools\[].size / quality / background | string          | Không    | Kích thước, chất lượng, nền khi công cụ hỗ trợ.                                |
| tool\_choice                         | string / object | Không    | auto để mô hình quyết định; ép công cụ theo định dạng hỗ trợ.                  |
| previous\_response\_id               | string          | Không    | Tiếp phản hồi được lưu, cần cùng ngữ cảnh truy cập; cổng không truy vấn chung. |
| stream                               | boolean         | Không    | true dùng luồng sự kiện Responses.                                             |

### Ví dụ yêu cầu

```json
{
  "model": "gpt-5.5",
  "input": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。",
  "tools": [
    {
      "type": "image_generation",
      "model": "gpt-image-2",
      "output_format": "png"
    }
  ],
  "stream": false
}
```

## Phản hồi

| Trường                      | Kiểu          | Mô tả                                                 |
| --------------------------- | ------------- | ----------------------------------------------------- |
| id / status                 | string        | ID và trạng thái cuối; completed mới đầy đủ.          |
| output\[].type              | string        | Kết quả image\_generation\_call, có thể thêm message. |
| output\[].id / status       | string        | ID gọi ảnh và trạng thái công cụ.                     |
| output\[].result            | string        | Base64 ảnh cuối, không data\[].b64\_json.             |
| output\[].revised\_prompt   | string        | Lời nhắc sửa lại công cụ dùng khi hỗ trợ.             |
| output\[].content\[].text   | string        | Lời giải thích tùy chọn trong message.                |
| usage                       | object        | Mức dùng mô hình chính; phí ảnh không chỉ token chữ.  |
| error / incomplete\_details | object / null | Lý do lỗi/chưa đủ.                                    |

```json
{
  "id": "resp_image_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ig_example",
      "type": "image_generation_call",
      "status": "completed",
      "result": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "error": null,
  "incomplete_details": null
}
```

Base64 PNG tối thiểu chỉ cấu trúc. Sửa tiếp gửi input\_image với chỉ dẫn mới hoặc previous\_response\_id khi hỗ trợ giữ ngữ cảnh. ID phản hồi không là tệp chung qua kênh.

## Ví dụ mã

Điền `API_URL` và `API_KEY` ở đầu mã; ví dụ dùng `gpt-5.5` làm mô hình chính và `gpt-image-2` làm mô hình công cụ ảnh. `API_URL` là URL yêu cầu đầy đủ, mặc định trỏ tới cổng `https://api.dwchainless.com`. Các ví dụ chỉ dùng thư viện chuẩn, gửi một yêu cầu và in JSON trả về; không tự động lưu ảnh.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/responses"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
      "tools": [
        {
          "type": "image_generation",
          "model": "gpt-image-2"
        }
      ]
    }
    request = urllib.request.Request(
        API_URL,
        data=json.dumps(body).encode(),
        method="POST",
        headers={
            "Authorization": "Bearer " + API_KEY,
            "Content-Type": "application/json",
        },
    )
    print(urllib.request.urlopen(request).read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const API_URL = 'https://api.dwchainless.com/v1/responses';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        input: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。',
        tools: [
          {
            type: 'image_generation',
            model: 'gpt-image-2'
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/responses"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
        "tools": [
          {
            "type": "image_generation",
            "model": "gpt-image-2"
          }
        ]
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/responses"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
            "tools": [
                {
                    "type": "image_generation",
                    "model": "gpt-image-2"
                }
            ]
        }`)
        request, _ := http.NewRequest("POST", apiURL, bytes.NewReader(body))
        request.Header.Set("Authorization", "Bearer "+apiKey)
        request.Header.Set("Content-Type", "application/json")
        response, _ := http.DefaultClient.Do(request)
        defer response.Body.Close()
        result, _ := io.ReadAll(response.Body)
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

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn có/bằng HTTP. Cổng có thể lỗi trước hãng. completed không image\_generation\_call.result có thể chỉ chữ; kiểm chọn công cụ và mục, không giả ảnh.

## Tham khảo chính thức

* [Tạo ảnh hội thoại OpenAI](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)