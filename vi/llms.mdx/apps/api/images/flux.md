# Tạo ảnh BFL FLUX

## Tổng quan

FLUX API của Black Forest Labs (BFL) dùng mô hình bất đồng bộ “gửi tác vụ + thăm dò kết quả”. Yêu cầu gửi chỉ trả về ID tác vụ và `polling_url`, sau khi tạo ảnh xong mới đọc URL có chữ ký từ kết quả thăm dò.

| Việc bạn cần làm                     | Đầu vào                     | Đầu ra                           | Điểm cuối                                           |
| ------------------------------------ | --------------------------- | -------------------------------- | --------------------------------------------------- |
| Tạo ảnh từ văn bản                   | `prompt`, `width`, `height` | `id` và `polling_url` của tác vụ | `POST https://api.bfl.ai/v1/flux-pro-1.1`           |
| Tạo ảnh khổ rộng theo tỷ lệ          | `prompt`, `aspect_ratio`    | `id` và `polling_url` của tác vụ | `POST https://api.bfl.ai/v1/flux-pro-1.1-ultra`     |
| Tạo từ ảnh tham chiếu hoặc chỉnh sửa | `prompt` + `input_image`    | `id` và `polling_url` của tác vụ | `POST https://api.bfl.ai/v1/flux-2-pro` và tương tự |
| Lấy ảnh cuối cùng                    | `polling_url`               | URL có chữ ký `result.sample`    | `GET {polling_url}`                                 |

## Khái niệm cốt lõi

* **Kích thước dùng `width` / `height`**\: phạm vi rộng cao của FLUX 1.1 pro là 256–1440 và phải là bội số của 32. Đây không phải bậc độ phân giải, cũng không phải chuỗi `size`.
* **Ultra dùng `aspect_ratio`**\: `/v1/flux-pro-1.1-ultra` không có trường rộng cao, thay bằng `aspect_ratio` (mặc định `16:9`, tài liệu mô tả phạm vi `21:9` đến `9:21`).
* **`seed` điều khiển khả năng tái lập**\: cùng lời nhắc, tham số và `seed` dùng để so sánh các thiết lập khác nhau; nó không bảo đảm nhận được cùng hình ảnh giữa các mô hình hoặc phiên bản.
* **`steps` / `guidance` chỉ xuất hiện ở một số mô hình**\: FLUX.2 flex hỗ trợ `steps` (1–50) và `guidance` (1.5–10.0); FLUX 1.1 pro không có hai trường này.
* **Gửi và kết quả là hai yêu cầu**\: gửi trả về `id`, `polling_url` và `cost` tùy chọn; thăm dò đến `Ready` rồi mới lấy ảnh từ `result.sample`, khi đang xử lý là `Pending`, thất bại hoặc kiểm duyệt nội dung sẽ trả trạng thái tương ứng.
* **URL có chữ ký có thời hạn khoảng 10 phút**\: `result.sample` hết hạn rất nhanh, phải tải xuống và chuyển lưu kịp thời, không coi địa chỉ đó là liên kết ảnh công khai lâu dài.

## Thông số và năng lực

| Điểm cuối                | Điều khiển kích thước                                              | Ảnh tham chiếu                                      | Trường chính khác                                                    | Định dạng trả về                |
| ------------------------ | ------------------------------------------------------------------ | --------------------------------------------------- | -------------------------------------------------------------------- | ------------------------------- |
| `/v1/flux-pro-1.1`       | `width`, `height`\: 256–1440, bội số của 32; mặc định 1024×768     | `image_prompt` (Base64, tham chiếu kiểu Flux Redux) | `seed`, `prompt_upsampling`, `safety_tolerance` 0–6, `output_format` | Thăm dò rồi lấy `result.sample` |
| `/v1/flux-pro-1.1-ultra` | Không có `width` / `height`; dùng `aspect_ratio`, mặc định `16:9`  | `image_prompt`, `image_prompt_strength` 0.0–1.0     | `seed`, `prompt_upsampling`, `raw`, `safety_tolerance` 0–6           | Như trên                        |
| `/v1/flux-2-pro`         | `width`, `height`\: tối thiểu 64, tài liệu không nêu giới hạn trên | `input_image` đến `input_image_8`, tối đa 8 ảnh     | `seed`, `safety_tolerance` 0–7, `output_format`                      | Như trên                        |
| `/v1/flux-2-flex`        | `width`, `height`\: tối thiểu 64, tài liệu không nêu giới hạn trên | `input_image` đến `input_image_8`, tối đa 8 ảnh     | `steps` 1–50, `guidance` 1.5–10.0, `seed`, `output_format`           | Như trên                        |

`output_format` có thể chọn `jpeg`, `png`, `webp`, mặc định `jpeg`. Các điểm cuối không nêu giới hạn trong bảng thì theo OpenAPI schema của điểm cuối tương ứng; không áp giới hạn rộng cao của điểm cuối này cho điểm cuối khác.

## Quy trình gọi

1. **Chuẩn bị khóa**\: tạo API Key trên bảng điều khiển BFL, header yêu cầu dùng `x-key: $BFL_API_KEY`, không phải `Authorization: Bearer`.
2. **Chọn điểm cuối**\: theo năng lực mô hình chọn `/v1/flux-pro-1.1`, `/v1/flux-pro-1.1-ultra` hoặc điểm cuối `/v1/flux-*` khác.
3. **Gửi tác vụ**\: gửi JSON, đặt `prompt`, trường kích thước, `output_format` và `seed` tùy chọn.
4. **Lưu `polling_url`**\: đọc `id` và `polling_url` từ phản hồi, không tự ghép địa chỉ thăm dò.
5. **Thăm dò đến `Ready`**\: dùng cùng `x-key` yêu cầu `polling_url`; khi `Pending` tiếp tục chờ, khi `Error` hoặc trạng thái kiểm duyệt thì dừng và ghi lý do.
6. **Tải và nghiệm thu**\: tải `result.sample` trước khi URL có chữ ký hết hạn, kiểm tra tệp có mở được không, kích thước và nội dung, rồi đối chiếu `cost` và nhật ký sử dụng.

## Mô phỏng lệnh gọi

Bản tin dưới đây là minh họa, không phải phản hồi tài khoản thật; ID tác vụ, URL và con số chi phí chỉ dùng để giải thích cấu trúc.

Yêu cầu gửi\:

```json
{
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "width": 1024,
  "height": 768,
  "seed": 42,
  "output_format": "jpeg",
  "safety_tolerance": 2
}
```

Phản hồi gửi thành công (bất đồng bộ, chưa tạo ảnh)\:

```json
{
  "id": "task_example_01",
  "polling_url": "https://api.bfl.ai/v1/get_result?id=task_example_01",
  "cost": 0.04
}
```

Phản hồi thăm dò hoàn tất (`status` là `Ready`)\:

```json
{
  "id": "task_example_01",
  "status": "Ready",
  "progress": 1,
  "result": {
    "sample": "https://delivery.example.bfl.ai/sample/image.jpeg"
  }
}
```

Trong lúc thăm dò còn có thể thấy các trạng thái `Pending`, `Error`, `Request Moderated`, `Content Moderated`. Khi kiểm duyệt không qua, `result` có thể là `null`, lý do nằm trong `details`.

## Kết nối và phiên

* **Base URL**\: `https://api.bfl.ai`; cũng cung cấp `https://api.eu.bfl.ai` và `https://api.us.bfl.ai`. Dùng điểm vào nào thì thăm dò đúng `polling_url` mà phản hồi trả về.
* **Xác thực**\: `x-key: $BFL_API_KEY`. Đây là khác biệt rõ nhất so với giao diện kiểu OpenAI, không đặt Key vào header `Authorization`.
* **Hoàn toàn bất đồng bộ**\: yêu cầu gửi không trả ảnh, chỉ trả `id` và `polling_url`; phải gửi thêm một `GET` mới có kết quả.
* **Khác biệt với OpenAI**\: không có điểm cuối `/v1/images/generations`, cũng không có trường `size`, `quality`, `n`; kích thước do `width` / `height` hoặc `aspect_ratio` điều khiển.
* **Gọi lại thay thăm dò**\: yêu cầu có thể mang `webhook_url` và `webhook_secret`, để BFL gọi lại khi hoàn tất; khi dùng gọi lại vẫn phải xác minh chữ ký và xử lý sự kiện thất bại.
* **Gọi qua cổng của trang này**\: đổi địa chỉ thành `https://api.dwchainless.com`, xác thực bằng khóa của trang này; FLUX là tác vụ bất đồng bộ, việc cổng có chuyển tiếp `polling_url` và header `x-key` hay không theo kênh, khi chưa mở thì kết nối trực tiếp theo địa chỉ chính thức ở trên.
* **Gọi qua cổng của trang này**\: địa chỉ yêu cầu và cách xác thực theo mô tả kênh của trang này; trường trên trang này là giao thức gốc của BFL, trước khi kết nối cổng hãy xác nhận mô hình khả dụng và phạm vi chuyển tham số.
* **Quá thời gian**\: yêu cầu gửi nên trả về nhanh, sau khi quá thời gian có thể kiểm tra trước tác vụ đã được tạo chưa; thăm dò nên cách khoảng 0.5 giây, đặt giới hạn tổng thời gian chờ theo mô hình và độ dài hàng đợi, không thử lại vô hạn.

## Tham khảo chính thức

* [BFL bắt đầu nhanh\: Tạo ảnh từ văn bản](https\://docs.bfl.ai/quick_start/generating_images)
* [Đặc tả OpenAPI của BFL](https\://api.bfl.ai/openapi.json)
* [Toàn văn tài liệu API BFL](https\://docs.bfl.ai/llms-full.txt)