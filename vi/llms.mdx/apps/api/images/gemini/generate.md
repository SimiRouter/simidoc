# Tạo ảnh Gemini

## Tổng quan API

`POST /v1beta/models/{model}:generateContent` dùng mô hình Gemini có đầu ra ảnh; kết quả có thể xen chữ và ảnh.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $API_KEY`. Google trực tiếp dùng `https://generativelanguage.googleapis.com`, thường với `x-goog-api-key: $GEMINI_API_KEY`, không phải khóa Bearer cổng. Chọn mô hình có quyền và hỗ trợ khả năng cần dùng.

Trang dùng GenerateContent REST. Interactions cũng có tạo ảnh nhưng input, steps, response\_format khác contents, candidates, generationConfig; không trộn.

## Tham số yêu cầu

| Trường                                   | Kiểu   | Bắt buộc | Mô tả                                                                             |
| ---------------------------------------- | ------ | -------- | --------------------------------------------------------------------------------- |
| model (đường dẫn)                        | string | Có       | Mô hình ảnh Gemini hỗ trợ generateContent và đầu ra ảnh, không mô hình chữ thuần. |
| contents                                 | array  | Có       | Danh sách tin; văn bản thành ảnh thường một user.                                 |
| contents\[].role                         | string | Không    | user; lịch sử trả lời mô hình dùng model.                                         |
| contents\[].parts\[].text                | string | Có       | Mô tả ảnh hoặc chỉ dẫn sửa.                                                       |
| generationConfig.responseModalities      | array  | Không    | Như \["TEXT","IMAGE"] để yêu cầu chữ và ảnh; tổ hợp tùy mô hình.                  |
| generationConfig.imageConfig.aspectRatio | string | Không    | Khi hỗ trợ có thể dùng tỷ lệ 1\:1, 16\:9, 9\:16 khi hỗ trợ.                       |
| generationConfig.imageConfig.imageSize   | string | Không    | 1K, 2K, 4K khi hỗ trợ, phải khớp mô hình; không phải mọi mô hình ảnh đều có.      |

Bỏ tùy chọn thừa; thêm imageConfig không cấp khả năng ảnh cho mô hình chữ. Cấu hình đầu ra mới và hỗ trợ mô hình cũ có thể khác; giữ ví dụ responseModalities rõ.

### Thông số ảnh\: 1K, 2K và 4K

K là cách gọi độ phân giải, không phải dung lượng tệp hay tham số chất lượng. Kích thước thực phụ thuộc mô hình và tỷ lệ khung hình. Với cùng tỷ lệ, tăng gấp đôi hai cạnh làm số pixel tăng bốn lần. Các ví dụ chỉ giải thích thuật ngữ, không phải kích thước mọi mô hình đều chấp nhận.

Khi mô hình hỗ trợ, Gemini dùng `generationConfig.imageConfig.imageSize` để chọn `1K`, `2K` hoặc `4K`, và dùng `generationConfig.imageConfig.aspectRatio` cho tỷ lệ. Tra mô hình đã chọn để biết kích thước thực.

| Tên mức độ phân giải | Ví dụ kích thước phổ biến (không bảo đảm mô hình hỗ trợ) |
| -------------------- | -------------------------------------------------------- |
| 1K                   | 1024×1024 · Khoảng một nghìn pixel mỗi cạnh              |
| 2K                   | 2048×2048 · Khoảng hai nghìn pixel mỗi cạnh              |
| 4K                   | 4096×4096 / 3840×2160 · Khoảng bốn nghìn pixel mỗi cạnh  |

Các mức tính phí theo ảnh của trang có quy tắc riêng; không dùng các ví dụ độ phân giải này làm chuẩn tính phí. [Thông số ảnh và quy tắc tính phí](/simidoc/vi/apps/api/images).

### Ví dụ yêu cầu

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。"
        }
      ]
    }
  ],
  "generationConfig": {
    "responseModalities": [
      "TEXT",
      "IMAGE"
    ]
  }
}
```

## Phản hồi

| Trường                         | Kiểu    | Mô tả                                                            |
| ------------------------------ | ------- | ---------------------------------------------------------------- |
| candidates\[]                  | array   | Ứng viên, có thể rỗng do an toàn.                                |
| candidates\[].content.parts\[] | array   | Các phần chữ, ảnh, suy nghĩ có thứ tự; không chỉ lấy đầu.        |
| parts\[].text                  | string  | Lời giải thích, có hay không tùy mô hình.                        |
| parts\[].inlineData.mimeType   | string  | MIME ảnh thực như image/png/jpeg.                                |
| parts\[].inlineData.data       | string  | Base64 ảnh thuần, không data\:.                                  |
| parts\[].thought               | boolean | Cờ suy nghĩ tùy chọn; ảnh trung gian thought=true không là cuối. |
| parts\[].thoughtSignature      | string  | Chữ ký mờ tùy chọn; giữ nguyên nhiều lượt, không tự tạo/sửa.     |
| candidates\[].finishReason     | string  | STOP hoàn tất; MAX\_TOKENS, SAFETY xử lý riêng.                  |
| promptFeedback                 | object  | Thông tin chặn đầu vào tùy chọn.                                 |
| usageMetadata                  | object  | Token vào, ứng viên, suy nghĩ, tổng tùy mô hình.                 |

Base64 dưới là PNG tối thiểu minh họa cấu trúc, không kết quả thật lời nhắc.

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "已根据描述生成图片。"
          },
          {
            "inlineData": {
              "mimeType": "image/png",
              "data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
            }
          }
        ]
      },
      "finishReason": "STOP"
    }
  ]
}
```

Duyệt parts theo thứ tự, lấy inlineData không thought, chọn đuôi theo mimeType. Không cố định parts\[0]. Chỉ chữ hoặc bị lọc không có ảnh thì báo chưa tạo ảnh.

### Luồng và lô

Mô hình hỗ trợ dùng streamGenerateContent?alt=sse; mảnh ảnh có thể chưa giải riêng được, theo sự kiện mô hình. generateContent đồng bộ không ID polling. Batch Google là dịch vụ bất đồng bộ riêng, không là điểm cuối cổng.

## Ví dụ mã

Điền `API_URL` và `API_KEY` ở đầu mã; ví dụ dùng `gemini-3-pro-image`. `API_URL` là URL yêu cầu đầy đủ, mặc định trỏ tới cổng `https://api.dwchainless.com`. Các ví dụ chỉ dùng thư viện chuẩn, gửi một yêu cầu và in JSON trả về; không tự động lưu ảnh.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
            }
          ]
        }
      ],
      "generationConfig": {
        "responseModalities": [
          "TEXT",
          "IMAGE"
        ]
      }
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
    const API_URL = 'https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。'
              }
            ]
          }
        ],
        generationConfig: {
          responseModalities: [
            'TEXT',
            'IMAGE'
          ]
        }
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
              }
            ]
          }
        ],
        "generationConfig": {
          "responseModalities": [
            "TEXT",
            "IMAGE"
          ]
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "contents": [
                {
                    "role": "user",
                    "parts": [
                        {
                            "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
                        }
                    ]
                }
            ],
            "generationConfig": {
                "responseModalities": [
                    "TEXT",
                    "IMAGE"
                ]
            }
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

## Demo gọi bằng tác tử

Sao chép tác vụ này cho tác tử có công cụ chạy cục bộ và kiểm tra phản hồi. Trước tiên điền trực tiếp API\_URL, API\_KEY và MODEL theo [cấu hình giao thức này](/simidoc/vi/apps/api/images/gemini). Không đưa khóa vào lời nhắc.

```text
Read this Gemini protocol page and the GenerateContent image generation reference first.
Use the configured SimiRouter request URL in API_URL (default gateway
https://api.dwchainless.com) and MODEL. Set API_KEY directly in the example; never
print, paste, commit, or store it in source files. For this one approved task, call POST
/v1beta/models/{model}:generateContent once, non-streaming, Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. with a text Part describing a calm blue library with a small robot reading,
watercolor, no lettering. Request one image; use imageConfig aspectRatio=1:1 and
imageSize=1K only if the model supports them. Do not invent an n parameter or mix
Interactions fields into GenerateContent. After the response, read only completed,
non-thought inlineData from parts; decode the Base64 in memory and report any unmet
requirement; do not write an image file. Do not switch providers/models/billing groups,
increase size/count, write files, install remote skills, or retry an ambiguous failure
without approval. Report a redacted error instead of false success.
```

## Mã lỗi

| Trạng thái HTTP | Ý nghĩa hoặc loại lỗi hãng         | Cách xử lý                                                                  |
| --------------- | ---------------------------------- | --------------------------------------------------------------------------- |
| 400             | `INVALID_ARGUMENT` và lỗi tương tự | Kiểm tra JSON, tham số, MIME phương tiện và độ dài đầu vào.                 |
| 403             | `PERMISSION_DENIED`                | Kiểm tra khóa, quyền dự án, vùng hoặc giới hạn thanh toán.                  |
| 404             | `NOT_FOUND`                        | Kiểm tra tên mô hình và phiên bản API.                                      |
| 429             | `RESOURCE_EXHAUSTED`               | Kiểm tra tốc độ, hạn mức; lùi thời gian số lần giới hạn nếu có thể thử lại. |
| 500 / 503       | `INTERNAL` / `UNAVAILABLE`         | Ghi ID yêu cầu, thử lại có giới hạn hoặc sau đó.                            |

Đối tượng lỗi Google gồm `error.code` (mã HTTP), `error.status` (tên enum), `error.message` và có thể có `details`. Cổng có thể lỗi trước hãng, HTTP không chứng minh nguồn. HTTP 200 không ảnh ngoài thought không được coi tạo ảnh thành công chỉ từ chữ.

## Tham khảo chính thức

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Tạo và sửa ảnh Google](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Danh mục mô hình Google](https\://ai.google.dev/gemini-api/docs/models)
* [Khắc phục sự cố Google](https\://ai.google.dev/gemini-api/docs/troubleshooting)