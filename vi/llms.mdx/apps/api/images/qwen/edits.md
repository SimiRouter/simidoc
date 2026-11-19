# Chỉnh ảnh Qwen

## Tổng quan API

`POST /v1/images/edits`, thân yêu cầu là JSON. Ví dụ dùng gateway của trang này `https://api.dwchainless.com`, `API_KEY` dùng khóa của trang này; thân yêu cầu giữ cấu trúc gốc Qwen `model`, `input.messages`, `parameters`, phản hồi thống nhất là `data[]`.

Chỉnh sửa ảnh đặt mục image và một chỉ dẫn chữ trong content, không dùng trường file của multipart.

## Tham số yêu cầu

| Trường                             | Kiểu      | Bắt buộc | Mô tả                                                                                                                       |
| ---------------------------------- | --------- | -------- | --------------------------------------------------------------------------------------------------------------------------- |
| model                              | string    | Có       | qwen-image-2.0-pro hoặc phiên bản cụ thể do kênh của trang này hỗ trợ.                                                      |
| input.messages                     | object\[] | Có       | Một tin nhắn user một lượt, đúng một mục.                                                                                   |
| input.messages\[].role             | string    | Có       | Cố định user.                                                                                                               |
| input.messages\[].content\[].text  | string    | Có       | Chỉ dẫn tiếng Trung hoặc tiếng Anh, mỗi lượt chỉ đặt một mục text.                                                          |
| input.messages\[].content\[].image | string    | Có       | URL / data URL của một hoặc nhiều ảnh tham chiếu có thể truy cập; số lượng đầu vào và giới hạn pixel tùy phiên bản mô hình. |
| parameters.size                    | string    | Không    | Rộng × cao, như 2048 × 2048; dòng 2.0 có tổng pixel trong khoảng 512×512 đến 2048×2048.                                     |
| parameters.n                       | integer   | Không    | Mặc định 1; dòng 2.0 hỗ trợ 1–6.                                                                                            |
| parameters.negative\_prompt        | string    | Không    | Nội dung không muốn xuất hiện, tối đa 500 ký tự.                                                                            |
| parameters.prompt\_extend          | boolean   | Không    | Mặc định true, tự động mở rộng lời nhắc dương.                                                                              |
| parameters.watermark               | boolean   | Không    | Có thêm watermark hiển thị hay không; cần tuân theo yêu cầu gắn nhãn nội dung tổng hợp áp dụng.                             |

### Thông số ảnh\: 1K, 2K, 4K

K là cách gọi tắt phổ biến của độ phân giải, không phải dung lượng tệp và cũng không biểu thị tham số chất lượng. Chiều rộng và cao thực tế thay đổi theo mô hình và tỷ lệ; với cùng tỷ lệ, cạnh tăng gấp đôi thì tổng pixel gấp bốn. Phần dưới chỉ để giải thích thuật ngữ, không thể trực tiếp coi là kích thước khả dụng của mọi mô hình.

Qwen dùng `parameters.size` để điền chiều rộng và cao mà mô hình cho phép, định dạng như `2048*2048`, không phải điền trực tiếp `2K`. Dòng 2.0 còn có giới hạn tổng pixel; hình minh họa ảnh vuông 4K bên dưới không có nghĩa là có thể gửi kích thước đó.

| Cách gọi độ phân giải | Minh họa pixel thường gặp (không phải cam kết mô hình hỗ trợ) |
| --------------------- | ------------------------------------------------------------- |
| 1K                    | Cả hai cạnh đều ≤ 1024 pixel; như 1024×1024.                  |
| 2K                    | Cạnh dài nhất > 1024 và ≤ 2048 pixel; như 1280×720.           |
| 4K                    | Một trong hai cạnh > 2048 pixel; như 2560×1440.               |

Bậc tính phí theo số ảnh của trang này là bộ quy tắc khác, không thể áp dụng trực tiếp các minh họa phổ thông trên làm chuẩn thu phí. [Thông số ảnh và quy tắc tính phí](/simidoc/vi/apps/api/images).

## Giá trị trả về

| Trường                  | Mô tả                                                                                        |
| ----------------------- | -------------------------------------------------------------------------------------------- |
| `created`               | Dấu thời gian phản hồi được tạo.                                                             |
| `data[].url`            | URL ảnh được tạo; thời hạn hiệu lực do kênh quyết định, hãy tải xuống hoặc lưu trữ kịp thời. |
| `data[].b64_json`       | Một số kênh trả Base64 thuần; khi có thể giải mã trực tiếp và lưu.                           |
| `data[].revised_prompt` | Lời nhắc sau khi kênh viết lại; có thể không tồn tại.                                        |
| `error` / `message`     | Mã lỗi và mô tả khi thất bại.                                                                |

```json
{"created":1760000000,"data":[{"url":"https://example.com/edited.png","b64_json":null,"revised_prompt":"..."}]}
```

## Gọi bằng mã

Điền `API_URL`, `API_KEY` ở đầu mã. `API_URL` dùng địa chỉ gateway của trang này `https://api.dwchainless.com/v1/images/edits`, `API_KEY` dùng khóa của trang này. Ví dụ chỉ dùng thư viện chuẩn, gửi một yêu cầu và in JSON trả về, không tự động tải hoặc lưu ảnh.

Đặt `IMAGE_URL` là địa chỉ ảnh HTTP(S) thật đã được cấp quyền và truy cập được từ đám mây. Mã chỉ kiểm tra dạng URL, không chứng minh ảnh tải được hoặc đã đáp ứng giới hạn định dạng của kênh; không dùng đường dẫn máy cục bộ, localhost, trang web cần đăng nhập hay liên kết giả.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "qwen-image-2.0-pro",
      "input": {
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "image": "https://example.com/reference.png"
              },
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              }
            ]
          }
        ]
      },
      "parameters": {
        "size": "1024*1024",
        "n": 1
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'qwen-image-2.0-pro',
        input: {
          messages: [
            {
              role: 'user',
              content: [
                {
                  image: 'https://example.com/reference.png'
                },
                {
                  text: '保留主体和构图，将背景改为浅蓝色。'
                }
              ]
            }
          ]
        },
        parameters: {
          size: '1024*1024',
          n: 1
        }
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/edits"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "qwen-image-2.0-pro",
        "input": {
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "image": "https://example.com/reference.png"
                },
                {
                  "text": "保留主体和构图，将背景改为浅蓝色。"
                }
              ]
            }
          ]
        },
        "parameters": {
          "size": "1024*1024",
          "n": 1
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/images/edits"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "qwen-image-2.0-pro",
            "input": {
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "image": "https://example.com/reference.png"
                            },
                            {
                                "text": "保留主体和构图，将背景改为浅蓝色。"
                            }
                        ]
                    }
                ]
            },
            "parameters": {
                "size": "1024*1024",
                "n": 1
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

Sao chép tác vụ bên dưới cho tác tử có khả năng thực thi cục bộ và kiểm tra kết quả trả về; trước tiên theo [cấu hình giao thức này](/simidoc/vi/apps/api/images/qwen) điền trực tiếp API\_URL, API\_KEY trong mã ví dụ, và xác nhận tên model. Không đưa khóa vào lời nhắc.

```text
Read this Qwen image protocol page and its editing reference first. Use the existing
API_KEY and API_URL from this site's gateway; never reveal the key or switch the
existing connection. Verify qwen-image-2.0-pro supports the edit. Use only the
authorized cloud-readable image in IMAGE_URL; do not upload unrelated local files or
publish a file. POST once to /v1/images/edits with the native Qwen body: one user
message containing that image item and one text instruction: keep the subject and
layout; change only the background to pale blue. Set parameters.n=1 and size=1024*1024
only if supported. Do not use OpenAI multipart or mask fields. Check the completed
business result, inspect data[].url or data[].b64_json without forwarding the API key,
and report it. Do not write files, change model/size/count/provider, install remote
skills, or retry automatically. If any step fails or the requested edit is not met,
report a redacted error instead of claiming success.
```

## Mã lỗi

| Lỗi                    | Xử lý                                                                            |
| ---------------------- | -------------------------------------------------------------------------------- |
| 400 / InvalidParameter | Kiểm tra cấu trúc content, thông số ảnh, size đầu ra và tham số mô hình hỗ trợ.  |
| 401                    | Kiểm tra API Key của trang này có tồn tại, hợp lệ và đúng quyền sở hữu.          |
| 403 / 404              | Kiểm tra quyền mô hình, kênh và tài nguyên có tồn tại.                           |
| 429                    | Giới hạn tốc độ hoặc thiếu hạn mức, xác nhận nguyên nhân rồi thử lại với độ trễ. |
| 5xx                    | Dịch vụ bất thường, ghi lại mã nhận diện yêu cầu; tránh tạo lặp vô hạn.          |

## Tham khảo chính thức

[Chỉnh Qwen-Image](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api), [Mã lỗi Model Studio](https\://www.alibabacloud.com/help/en/model-studio/error-code).