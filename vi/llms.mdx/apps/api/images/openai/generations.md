# Tạo ảnh

## Tổng quan API

`POST /v1/images/generations` tạo một hoặc nhiều ảnh theo prompt.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

Trang dùng GPT Image. Mô hình tương thích của hãng khác có thể khác kích thước, chất lượng, định dạng; không coi khác biệt là cùng chuẩn chính thức.

## Bắt đầu nhanh

1. **Chuẩn bị cấu hình**\: tạo khóa tại [Quản lý khóa API](https://api.dwchainless.com/keys) và sao chép ID mô hình hỗ trợ Images API từ [Mô hình và giá](https://api.dwchainless.com/vi/pricing/).
2. **Gửi yêu cầu**\: gửi JSON đến `https://api.dwchainless.com/v1/images/generations` với header `Authorization: Bearer $API_KEY`; thân yêu cầu phải có ít nhất `model` và `prompt`.
3. **Đọc kết quả**\: chỉ thành công khi HTTP 2xx và `data[]` không rỗng; giải mã và lưu `data[].b64_json` của GPT Image.
4. **Xác nhận hoàn tất**\: kiểm tra tệp mở được và đúng kích thước yêu cầu, rồi đối chiếu nhật ký sử dụng.

Yêu cầu tối thiểu như sau; sau khi hoạt động, điều chỉnh số lượng, kích thước hoặc streaming\:

```bash
API_URL="https://api.dwchainless.com/v1/images/generations"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
    "n": 1,
    "size": "1024x1024",
    "output_format": "png"
  }'
```

## Tham số yêu cầu

Thân yêu cầu JSON.

| Trường              | Kiểu    | Bắt buộc | Mô tả                                                                                                                                                      |
| ------------------- | ------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model               | string  | Có       | ID mô hình ảnh hỗ trợ Images API.                                                                                                                          |
| prompt              | string  | Có       | Mô tả rõ chủ thể, bố cục, phong cách, chữ.                                                                                                                 |
| n                   | integer | Không    | Số ảnh, GPT Image gốc 1–10; ví dụ 1.                                                                                                                       |
| size                | string  | Không    | Dạng gốc OpenAI là WIDTHxHEIGHT (rộng và cao chia hết cho 16, tỷ lệ 1\:3–3\:1) hoặc auto; SimiRouter cũng nhận tỷ lệ kèm resolution, giới hạn tùy mô hình. |
| resolution          | string  | Không    | Trường mở rộng của SimiRouter\: mức 1k, 2k hoặc 4k dùng cùng tỷ lệ, không phải giá trị pixel; API OpenAI gốc không có trường này.                          |
| aspect\_ratio       | string  | Không    | Trường mở rộng của SimiRouter\: tỷ lệ riêng như 3\:4; tỷ lệ trong size được ưu tiên.                                                                       |
| quality             | string  | Không    | auto, low, medium, high; vài mô hình mới có xhigh, max.                                                                                                    |
| output\_format      | string  | Không    | png, jpeg (ví dụ) hoặc webp; schema chính thức còn có gif và svg khi mô hình và quyền dự án hỗ trợ.                                                        |
| output\_compression | integer | Không    | Nén JPEG/WebP 0–100, không dùng PNG.                                                                                                                       |
| background          | string  | Không    | auto, opaque, transparent; trong suốt cần mô hình hỗ trợ và PNG/WebP.                                                                                      |
| moderation          | string  | Không    | auto hoặc low hỗ trợ; không đảm bảo qua chính sách nội dung.                                                                                               |
| response\_format    | string  | Không    | Một số mô hình tương thích nhận url hoặc b64\_json; GPT Image gốc không dùng.                                                                              |
| stream              | boolean | Không    | true dùng SSE ảnh.                                                                                                                                         |
| partial\_images     | integer | Không    | stream=true yêu cầu 0–3 ảnh trung gian, vẫn chờ sự kiện cuối.                                                                                              |

GPT Image trả Base64 trực tiếp, không nên dựa vào response\_format=url/b64\_json cũ. Một số mô hình tương thích có thể dùng trường này để chọn URL hoặc Base64, tùy tài liệu mô hình và phản hồi thực tế. style=vivid/natural cũng không dùng, ghi phong cách trong prompt.

### Ví dụ yêu cầu

```json
{
  "model": "gpt-image-2",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，柔和蓝金色调，不要文字。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

## Kích thước và định dạng

K là cách gọi độ phân giải, không phải dung lượng tệp hay tham số chất lượng. Kích thước thực phụ thuộc mô hình và tỷ lệ khung hình. Với cùng tỷ lệ, tăng gấp đôi hai cạnh làm số pixel tăng bốn lần. Các ví dụ chỉ giải thích thuật ngữ, không phải kích thước mọi mô hình đều chấp nhận.

OpenAI dùng `size` để đặt kích thước mô hình hỗ trợ như `1024x1024`, không phải chuỗi `1K`; `quality` và `output_format` điều khiển chất lượng và định dạng riêng biệt.

| Tên mức độ phân giải | Ví dụ kích thước phổ biến (không bảo đảm mô hình hỗ trợ) |
| -------------------- | -------------------------------------------------------- |
| 1K                   | 1024×1024 · Khoảng một nghìn pixel mỗi cạnh              |
| 2K                   | 2048×2048 · Khoảng hai nghìn pixel mỗi cạnh              |
| 4K                   | 4096×4096 / 3840×2160 · Khoảng bốn nghìn pixel mỗi cạnh  |

Các mức tính phí theo ảnh của trang có quy tắc riêng; không dùng các ví dụ độ phân giải này làm chuẩn tính phí. [Thông số ảnh và quy tắc tính phí](/simidoc/vi/apps/api/images).

### Ba cách viết size

Một số cổng tương thích OpenAI còn nhận tỷ lệ kèm độ phân giải hoặc kích thước tự động; việc có hiệu lực tùy mô hình và cổng kết nối, nếu không được hỗ trợ hãy quay lại pixel rõ ràng.

| Cách viết                   | Đoạn yêu cầu                       | Ghi chú                                                  |
| --------------------------- | ---------------------------------- | -------------------------------------------------------- |
| Pixel rõ ràng (khuyến nghị) | `{"size":"1536x2048"}`             | Trực tiếp nhất; tránh sai lệch quy đổi đặt trước.        |
| Tỷ lệ + độ phân giải        | `{"size":"3:4","resolution":"2k"}` | Dùng đặt trước 2K, 3\:4; resolution chỉ nhận 1k, 2k, 4k. |
| Kích thước tự động          | `{"size":"auto"}`                  | Mô hình chọn rộng và cao; không cam kết pixel cố định.   |

* Tỷ lệ trong size được ưu tiên hơn aspect\_ratio riêng; pixel rõ ràng hoặc auto được ưu tiên hơn đặt trước tỷ lệ.
* Ghi mức trong resolution; không gửi size=2k. Dùng chữ x thường làm dấu phân cách.
* Với gpt-image-2, giới hạn chính thức cho kích thước tùy ý là 3840×2160; tổ hợp lớn hơn như 4096×4096 thường trả lỗi tham số. Dòng 4K chỉ minh họa mức, không bảo đảm kích thước đó dùng được.
* Bảng tra 14 tỷ lệ phổ biến ở 1K, 2K và 4K xem tại [Thông số ảnh và quy tắc tính phí](/simidoc/vi/apps/api/images).

## Phản hồi

| Trường                                               | Kiểu    | Mô tả                                                                      |
| ---------------------------------------------------- | ------- | -------------------------------------------------------------------------- |
| created                                              | integer | Thời gian tạo Unix giây.                                                   |
| data\[]                                              | array   | Danh sách kết quả, không mặc định có mục đầu.                              |
| data\[].b64\_json                                    | string  | Byte ảnh Base64, GPT Image dùng định dạng này.                             |
| data\[].url                                          | string  | Chỉ mô hình tương thích trả URL; không trường bắt buộc GPT Image.          |
| data\[].revised\_prompt                              | string  | Lời nhắc sửa của mô hình cũ/tương thích, không bắt buộc GPT Image.         |
| output\_format / size / quality / background         | string  | Cấu hình đầu ra hiệu lực tùy chọn.                                         |
| usage                                                | object  | Dữ liệu sử dụng tùy chọn; sự có mặt và chi tiết tùy dịch vụ/mô hình.       |
| usage.input\_tokens / output\_tokens / total\_tokens | integer | Nếu có\: token vào, ra, tổng.                                              |
| usage.input\_tokens\_details                         | object  | Chi tiết tùy chọn như image\_tokens, text\_tokens.                         |
| X-Request-Id                                         | string  | Header phản hồi, không phải trường JSON; giữ lại để hỗ trợ hoặc chẩn đoán. |

data\[].url trả về có thể hết hạn; không gắn API Key khi tải ảnh. Base64 PNG tối thiểu chỉ cấu trúc, không kết quả thật lời nhắc.

```json
{
  "created": 1760000000,
  "data": [
    {
      "b64_json": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "output_format": "png"
}
```

### Sinh luồng

Mô hình hỗ trợ stream=true\: image\_generation.partial\_image là xem trước, completed là ảnh cuối và usage. Ảnh phần không là cuối; đứt chưa completed không đánh dấu xong. Không trả ID tác vụ nền polling chung.

## Ví dụ mã

Điền `API_URL` và `API_KEY` ở đầu mã; ví dụ dùng `gpt-image-2`. `API_URL` là URL yêu cầu đầy đủ, mặc định trỏ tới cổng `https://api.dwchainless.com`. Các ví dụ chỉ dùng thư viện chuẩn, gửi một yêu cầu và in JSON trả về; không tự động lưu ảnh.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/generations"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1,
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
    const API_URL = 'https://api.dwchainless.com/v1/images/generations';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        prompt: '一只小机器人在图书馆阅读，水彩插画，不要文字。',
        size: '1024x1024',
        n: 1,
      }),
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/generations"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/images/generations"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
            "size": "1024x1024",
            "n": 1
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

Sao chép tác vụ này cho tác tử có công cụ chạy cục bộ và kiểm tra phản hồi. Trước tiên điền trực tiếp API\_URL, API\_KEY và MODEL theo [cấu hình giao thức này](/simidoc/vi/apps/api/images/openai). Không đưa khóa vào lời nhắc.

```text
Read this OpenAI image protocol page and its generation reference first. Use the
SimiRouter request URL in API_URL (default gateway https://api.dwchainless.com) and the
image model in MODEL. Set API_KEY directly in the example; never print, paste, commit,
or store it in source files. For this one approved request, use POST
/v1/images/generations with n=1, size=1024x1024, stream=false and output_format=png only
after verifying the model supports these parameters. Image brief: a calm blue library
with a small robot reading, watercolor illustration, no lettering. Print the returned
JSON and inspect data[].b64_json; do not write an image file. Confirm that
data[].b64_json contains non-empty Base64 data before reporting completion. Do not
install remote skills, switch providers/models/billing groups, increase size/count,
write files, or retry after timeout or ambiguous failure without approval. If the
request or validation fails, report a redacted error, not success.
```

## Mã lỗi

| Trạng thái HTTP | Ý nghĩa hoặc loại lỗi hãng                      | Cách xử lý                                                                                              |
| --------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| 400             | Yêu cầu không hợp lệ                            | Kiểm tra trường bắt buộc, JSON, tham số và độ dài ngữ cảnh.                                             |
| 401             | Xác thực thất bại                               | Kiểm tra khóa có, hợp lệ và thuộc đúng dịch vụ.                                                         |
| 403 / 404       | Không có quyền / không có tài nguyên            | Kiểm tra quyền mô hình, ID và URL.                                                                      |
| 413             | Thân yêu cầu hoặc ảnh quá lớn                   | Ưu tiên URL ảnh; giảm kích thước Base64 hoặc kích thước ảnh.                                            |
| 429             | Giới hạn tốc độ hoặc hạn mức                    | Theo thân phản hồi phân biệt giới hạn tốc độ với thiếu hạn mức; thử lại không giải quyết thiếu hạn mức. |
| 500 / 502 / 503 | Lỗi máy chủ / upstream bận / tạm không khả dụng | Giữ ID yêu cầu, lùi thời gian giới hạn cho lỗi tạm.                                                     |

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn có/bằng HTTP. Cổng có thể lỗi trước hãng. data rỗng, thiếu ảnh hoặc chỉ xem trước không đủ tuyên bố hoàn tất dù HTTP 200.

Tạo và chỉnh sửa có thể mất từ hàng chục giây đến vài phút; hãy đặt thời gian chờ phía máy khách đủ lớn, vì yêu cầu treo không đồng nghĩa thất bại. Sau khi hết thời gian chờ, đứt luồng hoặc gặp 5xx, trước hết xác nhận yêu cầu đã thực thi chưa rồi mới thử lại, tránh tạo ảnh và tính phí trùng. Khi bị từ chối do chính sách nội dung (thường 400), hãy sửa prompt hoặc ảnh tham chiếu thay vì thử lại nguyên trạng.

## Tham khảo chính thức

* [OpenAI Create image](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [Hướng dẫn tạo ảnh OpenAI](https\://developers.openai.com/api/docs/guides/image-generation)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)