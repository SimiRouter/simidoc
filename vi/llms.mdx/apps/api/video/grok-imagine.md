# Video Grok Imagine

## Tổng quan

Grok Imagine dùng giao diện video bất đồng bộ của xAI\: `POST /v1/videos/generations` gửi tác vụ và trả về `request_id`, sau đó thăm dò bằng `GET /v1/videos/{request_id}`. Lời nhắc văn bản có thể tạo video trực tiếp; khi cung cấp `image` thì chuyển sang tạo từ ảnh, khi cung cấp ảnh tham chiếu hoặc khung hình chính thì chuyển sang tạo từ tham chiếu.

| Việc bạn cần làm        | Đầu vào                                        | Đầu ra                             | Điểm cuối                     |
| ----------------------- | ---------------------------------------------- | ---------------------------------- | ----------------------------- |
| Tạo video từ văn bản    | `prompt`, thời lượng, khung hình, độ phân giải | `request_id`                       | `POST /v1/videos/generations` |
| Tạo video từ ảnh        | `image` + `prompt` tùy chọn                    | `request_id`                       | Cùng điểm cuối                |
| Tạo video từ tham chiếu | `prompt` + `reference_images` hoặc `keyframes` | `request_id`                       | Cùng điểm cuối                |
| Truy vấn tác vụ         | `request_id`                                   | Trạng thái, URL video, mức sử dụng | `GET /v1/videos/{request_id}` |

## Khái niệm cốt lõi

* **Vòng đời tác vụ**\: trạng thái truy vấn chỉ có `pending`, `done`, `failed`. Khi `pending`, `progress` nằm trong 0–99, khi `done` là 100, khi `failed` có thể bị lược bỏ.
* **`request_id` là định danh thăm dò**\: nó không phải khóa idempotent. Sau khi gửi quá thời gian, không thể dựa vào “không nhận được phản hồi” để kết luận tác vụ chưa được tạo; trước tiên hãy giữ và truy vấn `request_id` có thể tồn tại.
* **Nhịp thăm dò**\: tài liệu hãng không quy định khoảng cách cố định. Máy khách có thể dùng khoảng cách 5–10 giây và đặt giới hạn tổng thời gian chờ; sau `failed` dừng ngay.
* **Thời lượng và khung hình**\: `duration` trong phạm vi 1–15 giây, mặc định 8 giây; tạo từ ảnh sẽ bỏ qua `aspect_ratio`, khung hình theo ảnh đầu vào. `resolution` mặc định `480p`, `grok-imagine-video-1.5` hỗ trợ 1080p gốc.
* **Công tắc âm thanh**\: trang năng lực có liệt kê `generate_audio`, mặc định `true`, đặt `false` để yêu cầu im lặng; tham khảo REST không liệt kê riêng trường này, tính khả dụng thực tế theo phản hồi giao diện.
* **Đơn vị tính phí**\: `usage.cost_in_usd_ticks` trong phản hồi truy vấn là bộ đếm chi phí của tác vụ này; cách quy đổi cụ thể, đơn giá và quyết toán thất bại theo trang giá của hãng.

## Thông số và năng lực

| Chỉ số             | Giá trị đã xác minh                                                                                       |
| ------------------ | --------------------------------------------------------------------------------------------------------- |
| ID mô hình         | `grok-imagine-video-1.5`, `grok-imagine-video-1.5-lite`, `grok-imagine-video`                             |
| Độ phân giải       | `480p` (mặc định), `720p`, `1080p`; `grok-imagine-video-1.5` là 1080p gốc                                 |
| Tỷ lệ khung hình   | `1:1`, `16:9` (mặc định), `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `21:9`, `5:2`; tạo từ ảnh bỏ qua trường này |
| Thời lượng         | 1–15 giây, mặc định 8 giây; khi chỉnh sửa video có sẵn không nhận thời lượng tùy chỉnh                    |
| Âm thanh           | `generate_audio` mặc định `true`, `false` yêu cầu im lặng; theo mô tả trang năng lực                      |
| Tư liệu tham chiếu | `image` khung đầu, `reference_images` ảnh tham chiếu, `keyframes` tối đa 4, `last_frame` khung cuối (1.5) |
| Đầu vào ảnh        | URL công khai, Base64 data URI, hoặc `file_id` của xAI Files API; JPEG, PNG, WebP                         |
| Đơn vị tính phí    | `usage.cost_in_usd_ticks`, đơn giá theo trang giá của hãng                                                |

`480p` mặc định phù hợp để xem trước, `720p` và `1080p` sẽ tăng thời gian tạo và chi phí. Tạo từ ảnh bỏ qua `aspect_ratio`, khung hình do `image` quyết định; muốn kiểm soát ngang hay dọc thì xử lý khi chuẩn bị ảnh đầu vào. `duration` mặc định 8 giây, thời gian thực tế còn chịu ảnh hưởng của xếp hàng, không thể chỉ ước lượng theo thời lượng. `generate_audio` có mô tả trên trang năng lực nhưng tham khảo REST không liệt kê riêng; trước khi kết nối hãy dùng một yêu cầu ngắn để xác minh mô hình hiện tại có nhận trường này không.

## Quy trình gọi

1. Tạo API Key trên bảng điều khiển xAI, các yêu cầu sau dùng `Authorization: Bearer`.
2. Chọn cách tạo\: chỉ gửi `prompt` là tạo từ văn bản; thêm `image` là tạo từ ảnh; thêm `reference_images`, `keyframes` hoặc `last_frame` là tạo từ tham chiếu.
3. Gọi `POST https://api.x.ai/v1/videos/generations`, đặt `duration`, `aspect_ratio`, `resolution` và công tắc âm thanh theo mô hình đích.
4. Lưu `request_id` trong phản hồi. Tạo thành công chỉ có nghĩa tác vụ đã được tiếp nhận.
5. Thăm dò `GET https://api.x.ai/v1/videos/{request_id}` cho đến khi `status` là `done` hoặc `failed`.
6. Sau `done` tải `video.url`; nếu cần ghi vào lưu trữ đối tượng của mình, cũng có thể dùng `output.upload_url` hoặc `storage_options` trong yêu cầu. Khi `failed` đọc `error.code` và `error.message`.

## Mô phỏng lệnh gọi

Dưới đây là bản tin minh họa; `request_id`, URL và mức sử dụng đều không phải dữ liệu tài khoản thật.

Yêu cầu tạo\:

```json
{
  "model": "grok-imagine-video-1.5",
  "prompt": "示例：夜晚的霓虹街道，镜头缓慢前推。",
  "duration": 6,
  "aspect_ratio": "16:9",
  "resolution": "720p",
  "generate_audio": true
}
```

Tạo thành công trả về định danh thăm dò\:

```json
{
  "request_id": "demo-request-0001"
}
```

Truy vấn đến trạng thái kết thúc thành công\:

```json
{
  "status": "done",
  "progress": 100,
  "model": "grok-imagine-video-1.5",
  "video": {
    "url": "https://example.com/demo-grok-imagine.mp4",
    "duration": 6,
    "respect_moderation": true
  }
}
```

Khi `pending` tiếp tục thăm dò; khi `failed` dừng và đọc `error`. Khi `video.respect_moderation` là `false`, URL có thể rỗng, không được coi là kết quả phát được.

## Kết nối và phiên

* **Địa chỉ cơ sở**\: `https://api.x.ai`. Tạo, truy vấn, chỉnh sửa và nối dài lần lượt là `/v1/videos/generations`, `/v1/videos/{request_id}`, `/v1/videos/edits`, `/v1/videos/extensions`.
* **Header xác thực**\: `Authorization: Bearer PASTE_API_KEY_HERE`, nội dung yêu cầu là JSON.
* **Hai bộ địa chỉ**\: kết nối trực tiếp dùng `https://api.x.ai`; chỉ dùng `https://api.dwchainless.com` và `Authorization: Bearer` cùng khóa của trang này khi kênh xác nhận rõ ánh xạ qua cổng này; không thể chỉ đổi địa chỉ và xác thực. Kênh SimiRouter có mở `/v1/videos/*`, có giữ `request_id` và trường trạng thái hay không do ánh xạ kênh quyết định.
* **Quá thời gian và idempotent**\: không có khóa idempotent công khai. Sau khi gửi quá thời gian, trước tiên truy vấn `request_id` đã biết, xác nhận tác vụ không tồn tại rồi mới thử lại; không gửi đồng thời cùng lời nhắc để né thời gian chờ.
* **Lưu kết quả**\: `video.url` là địa chỉ tạm thời, tài liệu cũng cung cấp trường đầu ra tệp và thời gian hết hạn. Phía sản phẩm nên tải xuống hoặc chuyển lưu trước, rồi mới cung cấp liên kết lâu dài ra ngoài.

## Tham khảo chính thức

* [xAI\: Tạo video Grok Imagine](https\://docs.x.ai/developers/model-capabilities/video/generation)
* [xAI\: Tham khảo REST API video](https\://docs.x.ai/developers/rest-api-reference/inference/videos)
* [xAI\: Tạo video từ ảnh](https\://docs.x.ai/developers/model-capabilities/video/image-to-video)