# Chỉnh ảnh và ảnh thành ảnh Gemini

## Tổng quan API

`POST /v1beta/models/{model}:generateContent` nhận chỉ dẫn cùng ảnh trong parts để chỉnh, ảnh thành ảnh, đổi phong cách/nền hay ghép ảnh. Không có đường dẫn Gemini gốc riêng `/images/edits`.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $API_KEY`. Google trực tiếp dùng `https://generativelanguage.googleapis.com`, thường với `x-goog-api-key: $GEMINI_API_KEY`, không phải khóa Bearer cổng. Chọn mô hình có quyền và hỗ trợ khả năng cần dùng.

Chỉ tải ảnh có quyền xử lý. Không bảo đảm giữ chính xác từng pixel danh tính, chữ, nhãn hiệu, sản phẩm; kiểm nội dung quan trọng trước dùng.

## Tham số yêu cầu

| Trường                                   | Kiểu   | Bắt buộc                      | Mô tả                                                                             |
| ---------------------------------------- | ------ | ----------------------------- | --------------------------------------------------------------------------------- |
| model (đường dẫn)                        | string | Có                            | Mô hình ảnh Gemini hỗ trợ generateContent và đầu ra ảnh, không mô hình chữ thuần. |
| contents                                 | array  | Có                            | Danh sách tin; văn bản thành ảnh thường một user.                                 |
| contents\[].role                         | string | Không                         | user; lịch sử trả lời mô hình dùng model.                                         |
| contents\[].parts\[].text                | string | Có                            | Mô tả ảnh hoặc chỉ dẫn sửa.                                                       |
| generationConfig.responseModalities      | array  | Không                         | Như \["TEXT","IMAGE"] để yêu cầu chữ và ảnh; tổ hợp tùy mô hình.                  |
| generationConfig.imageConfig.aspectRatio | string | Không                         | Khi hỗ trợ có thể dùng tỷ lệ 1\:1, 16\:9, 9\:16 khi hỗ trợ.                       |
| generationConfig.imageConfig.imageSize   | string | Không                         | 1K, 2K, 4K khi hỗ trợ, phải khớp mô hình; không phải mọi mô hình ảnh đều có.      |
| contents\[].parts\[].inlineData          | object | Có (ảnh tham chiếu nội tuyến) | Part riêng với text, có mimeType/data.                                            |
| inlineData.mimeType                      | string | Có                            | MIME ảnh thực, như image/png, image/jpeg, image/webp.                             |
| inlineData.data                          | string | Có                            | Base64 thuần tệp, không data\:.                                                   |
| contents\[].parts\[].fileData            | object | Có điều kiện                  | Thay nội tuyến bằng fileUri/mimeType có quyền hãng đọc.                           |

Một ảnh một Part; thêm Part cho nhiều tham chiếu, mô tả mục đích từng ảnh. Số ảnh, độ phân giải, nhất quán nhiều lượt tùy mô hình; không một số áp mọi Gemini.

### Thông số ảnh\: 1K, 2K và 4K

K là cách gọi độ phân giải, không phải dung lượng tệp hay tham số chất lượng. Kích thước thực phụ thuộc mô hình và tỷ lệ khung hình. Với cùng tỷ lệ, tăng gấp đôi hai cạnh làm số pixel tăng bốn lần. Các ví dụ chỉ giải thích thuật ngữ, không phải kích thước mọi mô hình đều chấp nhận.

Khi mô hình hỗ trợ, Gemini dùng `generationConfig.imageConfig.imageSize` để chọn `1K`, `2K` hoặc `4K`, và dùng `generationConfig.imageConfig.aspectRatio` cho tỷ lệ. Tra mô hình đã chọn để biết kích thước thực.

| Tên mức độ phân giải | Ví dụ kích thước phổ biến (không bảo đảm mô hình hỗ trợ) |
| -------------------- | -------------------------------------------------------- |
| 1K                   | 1024×1024 · Khoảng một nghìn pixel mỗi cạnh              |
| 2K                   | 2048×2048 · Khoảng hai nghìn pixel mỗi cạnh              |
| 4K                   | 4096×4096 / 3840×2160 · Khoảng bốn nghìn pixel mỗi cạnh  |

Các mức tính phí theo ảnh của trang có quy tắc riêng; không dùng các ví dụ độ phân giải này làm chuẩn tính phí. [Thông số ảnh và quy tắc tính phí](/simidoc/vi/apps/api/images).

### Cấu trúc yêu cầu

Thay `BASE64_IMAGE_BYTES` bằng Base64 thuần của ảnh được cấp quyền.

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。"
        },
        {
          "inlineData": {
            "mimeType": "image/png",
            "data": "BASE64_IMAGE_BYTES"
          }
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

Base64 chỉ minh họa. Lưu theo MIME thật. Nhiều lượt thêm toàn model content trước vào lịch sử, giữ thoughtSignature và trường mờ rồi thêm user mới. Không chỉ sao chép byte ảnh bỏ chữ ký hay sửa chúng.

Gemini sửa vùng bằng ngôn ngữ tự nhiên; mask OpenAI không là tham số chung. Cần ràng buộc chính xác thì kiểm đầu vào mô hình, không suy từ tên trường.

## Ví dụ mã

Điền `API_URL` và `API_KEY` ở đầu mã; ví dụ dùng `gemini-3-pro-image`; thay `BASE64_IMAGE_BYTES` bằng Base64 thuần của ảnh được phép dùng (không có tiền tố data\:). `API_URL` là URL yêu cầu đầy đủ, mặc định trỏ tới cổng `https://api.dwchainless.com`. Các ví dụ chỉ dùng thư viện chuẩn, gửi một yêu cầu và in JSON trả về; không tự động lưu ảnh.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY = "PASTE_API_KEY_HERE"
    IMAGE_BASE64 = "BASE64_IMAGE_BYTES"
    body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "保留主体和构图，将背景改为浅蓝色。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": IMAGE_BASE64
              }
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
    const IMAGE_BASE64 = 'BASE64_IMAGE_BYTES';
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
                text: '保留主体和构图，将背景改为浅蓝色。'
              },
              {
                inlineData: {
                  mimeType: 'image/png',
                  data: IMAGE_BASE64
                }
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
    IMAGE_BASE64="BASE64_IMAGE_BYTES"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary @- <<JSON
      {
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              },
              {
                "inlineData": {
                  "mimeType": "image/png",
                  "data": "$IMAGE_BASE64"
                }
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
    JSON
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
                            "text": "保留主体和构图，将背景改为浅蓝色。"
                        },
                        {
                            "inlineData": {
                                "mimeType": "image/png",
                                "data": "BASE64_IMAGE_BYTES"
                            }
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
Read this Gemini protocol page and its image editing reference first. Use the existing
API_KEY, MODEL and configured SimiRouter request URL; never reveal credentials or change
the existing connection. Read only the authorized local image, encode it as pure Base64,
and put it in IMAGE_BASE64. Submit its inlineData Part alongside the text instruction
through POST /v1beta/models/{model}:generateContent. Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. Keep the subject and layout; change only the background to pale blue. Request one
image, non-streaming; use aspectRatio=1:1 and imageSize=1K only if supported. Do not use
OpenAI multipart or mask fields. After the response, read only completed, non-thought
inlineData from parts; decode the Base64 in memory and report any unmet requirement; do
not write an image file. Preserve opaque signatures for later turns. Do not upload
unrelated files, overwrite results, change model/size/count/provider, install remote
skills, or retry automatically. Ask before any additional paid request.
```

## Mã lỗi

| Trạng thái HTTP | Ý nghĩa hoặc loại lỗi hãng         | Cách xử lý                                                                  |
| --------------- | ---------------------------------- | --------------------------------------------------------------------------- |
| 400             | `INVALID_ARGUMENT` và lỗi tương tự | Kiểm tra JSON, tham số, MIME phương tiện và độ dài đầu vào.                 |
| 403             | `PERMISSION_DENIED`                | Kiểm tra khóa, quyền dự án, vùng hoặc giới hạn thanh toán.                  |
| 404             | `NOT_FOUND`                        | Kiểm tra tên mô hình và phiên bản API.                                      |
| 429             | `RESOURCE_EXHAUSTED`               | Kiểm tra tốc độ, hạn mức; lùi thời gian số lần giới hạn nếu có thể thử lại. |
| 500 / 503       | `INTERNAL` / `UNAVAILABLE`         | Ghi ID yêu cầu, thử lại có giới hạn hoặc sau đó.                            |

Đối tượng lỗi Google gồm `error.code` (mã HTTP), `error.status` (tên enum), `error.message` và có thể có `details`. Cổng có thể lỗi trước hãng, mã HTTP không chứng minh nguồn. Từ chối, thiếu ảnh, dừng không STOP và HTTP lỗi cần tách; không dùng ảnh đầu vào giả kết quả sửa.

## Tham khảo chính thức

* [Tạo và sửa ảnh Google](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Hiểu ảnh và đầu vào phương tiện Google](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Khắc phục sự cố Google](https\://ai.google.dev/gemini-api/docs/troubleshooting)