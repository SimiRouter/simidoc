# Tạo ảnh xAI Grok

## Tổng quan

Giao diện tạo ảnh của xAI Grok dùng đường dẫn và phong bì phản hồi của OpenAI Images, nhưng tham số yêu cầu là trường gốc của xAI\: dùng `aspect_ratio` và `resolution` để chỉ định khung hình thay vì `size`. Mặc định trả về đồng bộ, cũng có thể bật `deferred` rồi thăm dò tác vụ.

| Việc bạn cần làm        | Đầu vào                     | Đầu ra                    | Điểm cuối                                       |
| ----------------------- | --------------------------- | ------------------------- | ----------------------------------------------- |
| Tạo ảnh từ văn bản      | `prompt`                    | Ảnh mới                   | `POST https://api.x.ai/v1/images/generations`   |
| Tạo nhiều ảnh một lần   | `prompt` + `n` (1–10)       | Nhiều ảnh                 | Như trên                                        |
| Tạo nền rồi lấy kết quả | `prompt` + `deferred: true` | `request_id`, rồi thăm dò | Như trên, thăm dò `GET /v1/images/{request_id}` |
| Chỉnh sửa ảnh có sẵn    | `prompt` + ảnh              | Ảnh đã chỉnh sửa          | `POST https://api.x.ai/v1/images/edits`         |

## Khái niệm cốt lõi

* **`aspect_ratio` thay thế `size`**\: giao diện không nhận `size` và `style` của OpenAI. Khung hình do `aspect_ratio` điều khiển, các giá trị thường dùng gồm `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `2:3`, `3:2`, `21:9` và `auto`.
* **`resolution` điều khiển bậc độ phân giải**\: nhận `1k` hoặc `2k`, mặc định `1k`. Đây là bậc chứ không phải giá trị pixel; chiều rộng cao thực tế trong cùng bậc do `aspect_ratio` quyết định.
* **`quality` chỉ có hiệu lực với mô hình 2.0**\: có thể chọn `low`, `medium`, `auto`; `auto` hiện được xử lý như `low` khi tạo và như `medium` khi chỉnh sửa.
* **Mặc định đồng bộ, `deferred` cho phép bất đồng bộ**\: yêu cầu đồng bộ trả trực tiếp `data[]`; sau khi đặt `deferred: true` trả ngay `request_id`, rồi thăm dò `GET /v1/images/{request_id}`. Tác vụ trì hoãn chỉ hỗ trợ `response_format: "url"`, kết quả giữ 24 giờ.
* **URL là tạm thời**\: khi `response_format` là `url` (mặc định), địa chỉ ảnh trả về sẽ hết hạn; khi cần lưu lâu dài hãy tải xuống kịp thời, hoặc chuyển sang `b64_json`.
* **Tính phí theo ảnh**\: `n` là số ảnh tạo trong một yêu cầu, phạm vi 1–10. `usage.cost_in_usd_ticks` trong phản hồi cho biết thông tin chi phí của yêu cầu đó, quyết toán thực tế theo hóa đơn của trang này.

## Thông số và năng lực

| ID mô hình               | Bậc độ phân giải | Tỷ lệ khung hình                                                                                                           | Ảnh tham chiếu                                                               | Định dạng trả về      |
| ------------------------ | ---------------- | -------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------- |
| `grok-imagine-image-2.0` | `1k`, `2k`       | `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `2:1`, `1:2`, `19.5:9`, `9:19.5`, `20:9`, `9:20`, `21:9`, `5:2`, `auto` | Giao diện tạo không nhận ảnh tham chiếu; chỉnh sửa đi qua `/v1/images/edits` | `url` hoặc `b64_json` |

`grok-2-image` là tên mô hình cũ, tài liệu giao diện chính thức hiện hành dùng `grok-imagine-image-2.0`. Trước khi gọi, hãy xác nhận ID mô hình mà kênh của trang này thực tế cung cấp từ [Mô hình và giá](https://api.dwchainless.com/vi/pricing/), không sao chép trực tiếp tên trong hướng dẫn cũ.

## Quy trình gọi

1. **Chuẩn bị khóa**\: tạo Key trên bảng điều khiển xAI, header yêu cầu dùng `Authorization: Bearer $XAI_API_KEY`.
2. **Xác nhận mô hình**\: đối chiếu `grok-imagine-image-2.0` hoặc mô hình tương đương do kênh cung cấp tại [Mô hình và giá](https://api.dwchainless.com/vi/pricing/).
3. **Chọn khung hình**\: đặt `aspect_ratio` và `resolution`; không gửi `size`.
4. **Gửi yêu cầu**\: gửi JSON đến `/v1/images/generations`. Khi dự đoán thời gian dài, thêm `deferred: true`.
5. **Đọc kết quả**\: phản hồi đồng bộ lấy `data[].url` hoặc `data[].b64_json`; tác vụ trì hoãn thăm dò đến `done` rồi mới lấy `data[]`.
6. **Lưu và nghiệm thu**\: tải ảnh trước khi URL hết hạn, kiểm tra tệp có mở được không, kích thước và nội dung, rồi đối chiếu nhật ký sử dụng.

## Mô phỏng lệnh gọi

Bản tin dưới đây là minh họa, không phải phản hồi tài khoản thật; URL và con số chi phí đã được cắt ngắn hoặc chỉ để minh họa.

Yêu cầu đồng bộ\:

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "response_format": "url"
}
```

Phản hồi thành công đồng bộ\:

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

Yêu cầu tác vụ trì hoãn\:

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "deferred": true
}
```

Phản hồi minh họa sau khi gửi\:

```json
{
  "request_id": "req_example_01"
}
```

Phản hồi minh họa khi thăm dò hoàn tất (HTTP 200; đang xử lý trả 202, thất bại trả `error.code` và `error.message`)\:

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

## Kết nối và phiên

* **Base URL**\: `https://api.x.ai/v1`. Điểm cuối tạo là `/v1/images/generations`, điểm cuối chỉnh sửa là `/v1/images/edits`.
* **Xác thực**\: `Authorization: Bearer $XAI_API_KEY`. OpenAI SDK có thể đặt `base_url` thành `https://api.x.ai/v1` để dùng lại, nhưng trường yêu cầu vẫn điền theo tài liệu xAI.
* **Khác biệt với OpenAI**\: đường dẫn và phong bì `data[]` tương tự, nhưng `size`, `style` không được hỗ trợ; thay bằng `aspect_ratio`, `resolution`, `quality`. Giới hạn `n` là 10.
* **Tác vụ trì hoãn**\: `deferred` chỉ hỗ trợ đầu ra URL, sau khi gửi thăm dò `GET /v1/images/{request_id}`; kết quả giữ 24 giờ, quá hạn phải tạo lại.
* **Gọi qua cổng của trang này**\: đổi địa chỉ yêu cầu thành `https://api.dwchainless.com/v1/images/generations`, xác thực bằng khóa của trang này; ID mô hình và việc chuyển tham số theo kênh.
* **Quá thời gian**\: tạo đồng bộ thường hoàn tất trong một yêu cầu, máy khách vẫn nên để thời gian chờ đủ; khi thời gian không kiểm soát được hoặc tạo hàng loạt, ưu tiên dùng `deferred`, không gửi lại mù quáng sau khi quá thời gian.

## Tham khảo chính thức

* [Năng lực tạo ảnh xAI](https\://docs.x.ai/developers/model-capabilities/images/generation)
* [Tham khảo REST API Images xAI](https\://docs.x.ai/developers/rest-api-reference/inference/images)