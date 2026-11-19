# Hiểu ảnh

## Tổng quan API

`POST /v1/chat/completions` kết hợp câu hỏi và ảnh trong user, trả phân tích chữ. Hiểu không phải tạo/sửa.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

Ảnh dùng HTTPS truy cập được hoặc data URL byte thật; ví dụ dùng URL HTTPS truy cập được.

## Tham số yêu cầu

| Trường                      | Kiểu    | Bắt buộc     | Mô tả                                                                    |
| --------------------------- | ------- | ------------ | ------------------------------------------------------------------------ |
| model                       | string  | Có           | Mô hình chat hỗ trợ thị giác.                                            |
| messages\[].role            | string  | Có           | Tin ảnh dùng user.                                                       |
| messages\[].content         | array   | Có           | Ít nhất câu hỏi và mục ảnh.                                              |
| content\[].type=text / text | string  | Có điều kiện | Mục câu hỏi chữ.                                                         |
| content\[].type=image\_url  | string  | Có điều kiện | Khai báo mục ảnh.                                                        |
| image\_url.url              | string  | Có           | HTTPS URL hoặc data\:image/\{format};base64,...; không đường dẫn cục bộ. |
| image\_url.detail           | string  | Không        | Chi tiết auto, low, high theo hỗ trợ.                                    |
| max\_completion\_tokens     | integer | Không        | Giới hạn token đầu ra.                                                   |
| stream                      | boolean | Không        | true trả Chat SSE.                                                       |

PNG/JPEG/WebP dùng đúng MIME, số ảnh/pixel/thân theo mô hình. Không đổi GIF động, video, dữ liệu tùy ý thành image/png.

### Cấu trúc yêu cầu

```json
{
  "model": "gpt-5.5",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "描述图片中的主要物体，并指出无法确定的细节。"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/png;base64,BASE64_IMAGE_BYTES",
            "detail": "auto"
          }
        }
      ]
    }
  ],
  "max_completion_tokens": 512,
  "stream": false
}
```

## Phản hồi

| Trường                         | Kiểu             | Mô tả                                                                                              |
| ------------------------------ | ---------------- | -------------------------------------------------------------------------------------------------- |
| id / object                    | string           | ID phản hồi; object=chat.completion.                                                               |
| created / model                | integer / string | Thời điểm Unix giây và mô hình phản hồi.                                                           |
| choices\[]                     | array            | Danh sách ứng viên, index là vị trí.                                                               |
| choices\[].message.role        | string           | assistant.                                                                                         |
| choices\[].message.content     | string / null    | Chữ trả lời có thể rỗng khi công cụ/từ chối, không tự nghĩa thất bại.                              |
| choices\[].message.tool\_calls | array            | Hàm ứng dụng cần chạy. arguments là chuỗi JSON, phải phân tích và kiểm tra.                        |
| choices\[].message.refusal     | string / null    | Thông tin từ chối nếu có.                                                                          |
| choices\[].finish\_reason      | string           | stop kết thúc thường; length chạm giới hạn; tool\_calls gọi công cụ; content\_filter lọc nội dung. |
| usage.prompt\_tokens           | integer          | Token đầu vào.                                                                                     |
| usage.completion\_tokens       | integer          | Token sinh, có thể gồm suy luận.                                                                   |
| usage.total\_tokens            | integer          | Tổng token đầu vào và sinh.                                                                        |
| usage.\*\_tokens\_details      | object           | Chi tiết tùy chọn như cached\_tokens, reasoning\_tokens.                                           |

```json
{
  "id": "chatcmpl_vision_example",
  "object": "chat.completion",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "图中可见一张桌子和一个杯子，杯内物品无法确认。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 280,
    "completion_tokens": 30,
    "total_tokens": 310
  }
}
```

Nhiều ảnh thêm image\_url, nêu thứ tự/mục tiêu so sánh. Luồng nối delta.content. Không chỉ dựa thị giác cho chữ nhỏ, đếm chính xác, danh tính hay quyết định rủi ro cao.

## Ví dụ mã

Điền `API_URL` và `API_KEY` ở đầu mã; ví dụ dùng `gpt-5.5`. `API_URL` là URL yêu cầu đầy đủ, mặc định trỏ tới cổng `https://api.dwchainless.com`. `IMAGE_URL` là URL HTTPS của ảnh mà máy chủ có thể truy cập. Các ví dụ chỉ dùng thư viện chuẩn, gửi một yêu cầu và in JSON trả về; không tự động lưu ảnh.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/chat/completions"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "描述图片中的主要物体。"
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "https://example.com/reference.png"
              }
            }
          ]
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
    const API_URL = 'https://api.dwchainless.com/v1/chat/completions';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: '描述图片中的主要物体。'
              },
              {
                type: 'image_url',
                image_url: {
                  url: 'https://example.com/reference.png'
                }
              }
            ]
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/chat/completions"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "描述图片中的主要物体。"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "https://example.com/reference.png"
                }
              }
            ]
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
        apiURL := "https://api.dwchainless.com/v1/chat/completions"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "描述图片中的主要物体。"
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": "https://example.com/reference.png"
                            }
                        }
                    ]
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

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn tồn tại hoặc bằng HTTP. Cổng có thể báo xác thực, tuyến, hạn mức trước hãng; mã HTTP không chứng minh lỗi thượng nguồn.

## Tham khảo chính thức

* [Ảnh và thị giác OpenAI](https\://developers.openai.com/api/docs/guides/images-vision)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)