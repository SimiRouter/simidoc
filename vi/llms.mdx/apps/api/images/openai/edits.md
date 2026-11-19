# Chỉnh ảnh và ảnh thành ảnh

## Tổng quan API

`POST /v1/images/edits` nhận ảnh, chỉ dẫn và trả ảnh sửa; thay nền, đổi phong cách, thêm/xóa phần tử, ghép ảnh.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

Hỗ trợ tham chiếu JSON images\[] và tải lên multipart. Ví dụ truyền URL HTTPS của ảnh mà máy chủ có thể truy cập qua JSON `images[].image_url`; không dùng multipart.

## Bắt đầu nhanh

1. **Chuẩn bị cấu hình**\: tạo khóa tại [Quản lý khóa API](https://api.dwchainless.com/keys) và sao chép ID mô hình ảnh hỗ trợ chỉnh sửa từ [Mô hình và giá](https://api.dwchainless.com/vi/pricing/).
2. **Chuẩn bị ảnh tham chiếu**\: dùng URL ảnh HTTPS mà máy chủ truy cập được, hoặc tải tệp cục bộ qua multipart; không trộn cả hai trong cùng một yêu cầu.
3. **Gửi yêu cầu**\: gửi đến `https://api.dwchainless.com/v1/images/edits` nội dung có `model`, `prompt` và tham chiếu ảnh; header dùng `Authorization: Bearer $API_KEY`.
4. **Đọc và xác nhận**\: chỉ thành công khi HTTP 2xx và `data[]` không rỗng; giải mã `data[].b64_json` hoặc tải `data[].url`, rồi kiểm tra tệp, kích thước và nội dung.

Lần gọi đầu nên chỉ sửa một ảnh, không dùng streaming; khi đã chạy được, hãy thêm ảnh tham chiếu hoặc bật streaming.

## Tham số yêu cầu

| Trường               | Kiểu    | Bắt buộc       | Mô tả                                                                                                                                                      |
| -------------------- | ------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                | string  | Có (cổng)      | Chọn rõ mô hình ảnh hỗ trợ sửa, không dựa mặc định hãng.                                                                                                   |
| images               | array   | Có (JSON)      | Danh sách ảnh tham chiếu; GPT Image gốc tối đa 16, mô hình có thể chặt hơn.                                                                                |
| images\[].image\_url | string  | Có điều kiện   | URL HTTPS hoặc data\:image/...;base64,...; ví dụ trong trang dùng URL HTTPS.                                                                               |
| images\[].file\_id   | string  | Có điều kiện   | ID Files chính thức, chọn nó hoặc image\_url; không mặc định cổng hỗ trợ.                                                                                  |
| prompt               | string  | Có             | Nêu rõ nội dung đổi và giữ.                                                                                                                                |
| mask                 | object  | Không          | JSON tham chiếu mask.image\_url/mask.file\_id; quy tắc tùy mô hình.                                                                                        |
| image / image\[]     | file    | Có (multipart) | Một/nhiều trường ảnh multipart, không trộn JSON images.                                                                                                    |
| mask (multipart)     | file    | Không          | Mask PNG vùng trong suốt là vùng sửa; khớp kích thước nguồn và mô hình.                                                                                    |
| input\_fidelity      | string  | Không          | Chỉ mô hình hỗ trợ, không mọi thế hệ GPT Image nhận.                                                                                                       |
| n                    | integer | Không          | Số ảnh, GPT Image gốc 1–10; ví dụ 1.                                                                                                                       |
| size                 | string  | Không          | Dạng gốc OpenAI là WIDTHxHEIGHT (rộng và cao chia hết cho 16, tỷ lệ 1\:3–3\:1) hoặc auto; SimiRouter cũng nhận tỷ lệ kèm resolution, giới hạn tùy mô hình. |
| resolution           | string  | Không          | Trường mở rộng của SimiRouter\: mức 1k, 2k hoặc 4k dùng cùng tỷ lệ, không phải giá trị pixel; API OpenAI gốc không có trường này.                          |
| aspect\_ratio        | string  | Không          | Trường mở rộng của SimiRouter\: tỷ lệ riêng như 3\:4; tỷ lệ trong size được ưu tiên.                                                                       |
| quality              | string  | Không          | auto, low, medium, high; vài mô hình mới có xhigh, max.                                                                                                    |
| output\_format       | string  | Không          | png, jpeg (ví dụ) hoặc webp; schema chính thức còn có gif và svg khi mô hình và quyền dự án hỗ trợ.                                                        |
| output\_compression  | integer | Không          | Nén JPEG/WebP 0–100, không dùng PNG.                                                                                                                       |
| background           | string  | Không          | auto, opaque, transparent; trong suốt cần mô hình hỗ trợ và PNG/WebP.                                                                                      |
| moderation           | string  | Không          | auto hoặc low hỗ trợ; không đảm bảo qua chính sách nội dung.                                                                                               |
| response\_format     | string  | Không          | Một số mô hình tương thích nhận url hoặc b64\_json; GPT Image gốc không dùng.                                                                              |
| stream               | boolean | Không          | true dùng SSE ảnh.                                                                                                                                         |
| partial\_images      | integer | Không          | stream=true yêu cầu 0–3 ảnh trung gian, vẫn chờ sự kiện cuối.                                                                                              |

Chọn JSON hoặc multipart; để client tạo boundary Content-Type. Mask không đảm bảo sửa từng pixel, cần người kiểm.

## Chọn cách truyền ảnh

Có bốn cách truyền ảnh tham chiếu; chọn một theo môi trường và không trộn chúng trong cùng một yêu cầu\:

| Cách                | Trường                             | Khi nào dùng                                      |
| ------------------- | ---------------------------------- | ------------------------------------------------- |
| JSON URL            | `images[].image_url`               | Ảnh đã công khai, máy chủ truy cập trực tiếp được |
| JSON Base64         | `images[].image_url` dạng data URL | Ảnh nhỏ và không muốn lộ địa chỉ công khai        |
| tệp multipart       | `image` hoặc `image[]`             | Tệp cục bộ, do client tải lên trực tiếp           |
| ID tài nguyên Files | `images[].file_id`                 | Đã tải qua Files chính thức và cổng hỗ trợ ID đó  |

Yêu cầu JSON dùng `Content-Type: application/json`; với multipart, client phải tạo boundary trong `Content-Type`, không viết tay.

### Cấu trúc JSON

Ví dụ JSON dùng trực tiếp URL HTTPS mà máy chủ truy cập được.

```json
{
  "model": "gpt-image-2",
  "images": [
    {
      "image_url": "https://example.com/reference.png"
    }
  ],
  "prompt": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

### Cấu trúc multipart

Một ảnh tham chiếu cục bộ dùng trường `image`; nhiều ảnh dùng `image[]` và mô tả lần lượt vai trò từng ảnh\:

```bash
API_URL="https://api.dwchainless.com/v1/images/edits"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -F "model=gpt-image-2" \
  -F "prompt=保留主体和构图，将背景改为浅蓝色。" \
  -F "image=@reference.png" \
  -F "size=1024x1024" \
  -F "n=1"
```

## Viết prompt chỉnh sửa

Prompt chỉnh sửa phải nêu cả phần giữ và phần đổi; chỉ viết “đổi sang màu nước” dễ khiến mô hình vẽ lại toàn bộ khung hình. Hãy tổ chức theo “giữ + đổi + ràng buộc”\:

| Tình huống                | Trọng tâm prompt                                   | Ví dụ                                                                 |
| ------------------------- | -------------------------------------------------- | --------------------------------------------------------------------- |
| Giữ nguyên người/hàng hóa | Nêu rõ chủ thể, tư thế, bố cục và chữ không đổi    | Giữ tư thế và trang phục của người, chỉ đổi nền thành xanh nhạt.      |
| Đổi phong cách            | Nêu phong cách đích và bố cục cần giữ              | Đổi sang minh họa màu nước, giữ bố cục và vị trí chủ thể ban đầu.     |
| Sửa cục bộ                | Chỉ rõ vùng sửa; dùng `mask` nếu mô hình hỗ trợ    | Chỉ sửa chiếc cốc ở góc dưới bên trái, giữ nguyên phần còn lại.       |
| Ghép nhiều ảnh            | Nêu vai trò từng ảnh, quan hệ chủ thể, bố cục cuối | Ảnh đầu là người, ảnh thứ hai là bối cảnh; đặt người ở giữa bối cảnh. |

“Giữ nguyên” là mục tiêu, không phải bảo đảm từng pixel; chi tiết người, hàng hóa và chữ có thể thay đổi, nội dung liên quan đến danh tính hoặc thương hiệu phải được kiểm tra thủ công. Nền trong suốt cần mô hình hỗ trợ `background: transparent` và xuất PNG hoặc WebP.

## Kích thước và định dạng

`size` ghi kích thước pixel mà mô hình cho phép, như `1024x1024`; `quality` điều khiển chất lượng, `output_format` điều khiển mã hóa PNG/JPEG/WebP. Kích thước kết quả chỉnh sửa do `size` quyết định (mặc định `auto` để mô hình chọn), không bắt buộc khớp ảnh tham chiếu.

Các mức tính phí 1K, 2K, 4K theo ảnh của trang và cách gọi độ phân giải của hãng là hai bộ quy tắc khác nhau; ba cách viết size, bảng tra 14 tỷ lệ và giới hạn tính phí xem tại [Thông số ảnh và quy tắc tính phí](/simidoc/vi/apps/api/images).

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

Base64 PNG tối thiểu chỉ cấu trúc. data\[].url trả về có thể hết hạn; không gắn API Key khi tải ảnh. Sửa luồng dùng image\_edit.partial\_image và image\_edit.completed; chỉ sự kiện cuối mới xác nhận hoàn tất. Ảnh thành ảnh không đảm bảo giữ nguyên từng pixel người, hàng hóa, chữ.

## Ví dụ mã

Điền `API_URL` và `API_KEY` ở đầu mã; ví dụ dùng `gpt-image-2`. `API_URL` là URL yêu cầu đầy đủ, mặc định trỏ tới cổng `https://api.dwchainless.com`. `IMAGE_URL` là URL HTTPS của ảnh mà máy chủ có thể truy cập. Các ví dụ chỉ dùng thư viện chuẩn, gửi một yêu cầu và in JSON trả về; không tự động lưu ảnh.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "images": [{"image_url": "https://example.com/reference.png"}],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        images: [
          {
            image_url: 'https://example.com/reference.png',
          },
        ],
        prompt: '保留主体和构图，将背景改为浅蓝色。',
        size: '1024x1024',
        n: 1,
      }),
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
        "model": "gpt-image-2",
        "images": [
          {
            "image_url": "https://example.com/reference.png"
          }
        ],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
        apiURL := "https://api.dwchainless.com/v1/images/edits"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "images": [
                {
                    "image_url": "https://example.com/reference.png"
                }
            ],
            "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
Read this OpenAI image protocol page and its editing reference first. Set API_KEY,
MODEL, and API_URL directly in the example; use the configured SimiRouter request URL;
never reveal the key or change the existing connection. Use only the authorized HTTPS
image URL in IMAGE_URL. Use POST /v1/images/edits with JSON images[]; do not set
multipart Content-Type or send local files. Keep the subject and layout; change only the
background to pale blue. Request one PNG at 1024x1024 with stream=false only if the
selected model supports it. Print the returned JSON and inspect data[].b64_json; do not
write an image file. Confirm that data[].b64_json contains non-empty Base64 data and
report any unmet requirement. Do not upload unrelated files, change
size/count/model/provider, install remote skills, or retry automatically after an error
or timeout. Ask before another paid request.
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

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn có/bằng HTTP. Cổng có thể lỗi trước hãng. Ảnh sai, MIME lệch, mask sai cỡ, tham số không hỗ trợ cần sửa, không gửi lặp.

Chỉnh sửa có thể mất từ hàng chục giây đến vài phút; hãy đặt thời gian chờ phía máy khách đủ lớn, vì yêu cầu treo không đồng nghĩa thất bại. Sau khi hết thời gian chờ, đứt luồng hoặc gặp 5xx, trước hết xác nhận yêu cầu đã thực thi chưa rồi mới thử lại, tránh tạo ảnh và tính phí trùng. Khi bị từ chối do chính sách nội dung (thường 400), hãy sửa prompt hoặc ảnh tham chiếu thay vì thử lại nguyên trạng.

## Tham khảo chính thức

* [OpenAI Create image edit](https\://developers.openai.com/api/reference/resources/images/methods/edit)
* [Tạo và chỉnh ảnh OpenAI](https\://developers.openai.com/api/docs/guides/image-generation)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)