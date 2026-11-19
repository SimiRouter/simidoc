# Video PixVerse

## Tổng quan

PixVerse OpenAPI chính thức dùng yêu cầu HTTP thông thường để gửi tác vụ tạo bất đồng bộ; tạo thành công trả về `video_id`, sau đó dùng chính ID này để truy vấn trạng thái và lấy địa chỉ video. Tạo video từ văn bản và tạo video từ ảnh là hai điểm vào; tạo từ ảnh phải tải ảnh lên trước, lấy `img_id` rồi mới gửi.

| Việc bạn cần làm        | Đầu vào                                                           | Đầu ra                                  | Điểm cuối                                 |
| ----------------------- | ----------------------------------------------------------------- | --------------------------------------- | ----------------------------------------- |
| Tạo video từ văn bản    | Lời nhắc, thời lượng, `quality`, `aspect_ratio`                   | `video_id`                              | `POST /openapi/v2/video/text/generate`    |
| Tạo video từ ảnh        | `img_id` của ảnh đã tải lên (hoặc `img_ids` của mẫu) kèm lời nhắc | `video_id`                              | `POST /openapi/v2/video/img/generate`     |
| Truy vấn kết quả tác vụ | `video_id`                                                        | Trạng thái, URL video, thông số thực tế | `GET /openapi/v2/video/result/{video_id}` |
| Tải ảnh lên             | Tệp ảnh                                                           | `img_id`                                | `POST /openapi/v2/image/upload`           |

## Khái niệm cốt lõi

* **Vòng đời tác vụ**\: tạo trả về `ErrCode=0` và `video_id`, chỉ biểu thị tác vụ đã được tiếp nhận. Trạng thái truy vấn `1` là hoàn thành, `5` là đang tạo, `7` là kiểm duyệt nội dung thất bại, `8` là tạo thất bại; `1`, `7`, `8` đều là trạng thái kết thúc.
* **Hai ID có mục đích khác nhau**\: `video_id` là định danh tác vụ nghiệp vụ, dùng để truy vấn và tải xuống; `Ai-trace-id` là UUID phải tạo mới cho mỗi yêu cầu, chỉ dùng để truy vết, không phải khóa idempotent, dùng lại có thể tạo thêm một tác vụ khác.
* **Nhịp thăm dò**\: hãng khuyến nghị truy vấn mỗi 3–5 giây. Máy khách phải đặt giới hạn tổng thời gian chờ; khi vào `7` hoặc `8` thì dừng ngay, không tiếp tục thử lại cùng tác vụ.
* **Đơn vị tính phí**\: `Resp.credits` trong phản hồi tạo là credits mà tác vụ này tiêu thụ. Đơn giá thực tế, gói và quy tắc hoàn tiền căn cứ vào trang giá của hãng và hóa đơn tài khoản.
* **Kiểm soát khung hình và thời lượng riêng**\: tạo từ văn bản dùng `quality` để chỉ định bậc độ rõ nét và `aspect_ratio` để chỉ định khung hình; tạo từ ảnh không có trường `aspect_ratio`, khung hình do ảnh đầu vào hoặc mẫu quyết định. Giá trị hợp lệ của `duration` thay đổi theo mô hình, không thể chỉ điền theo phạm vi 1–15 của giao diện.

## Thông số và năng lực

| Chỉ số           | Giá trị đã xác minh                                                                                            |
| ---------------- | -------------------------------------------------------------------------------------------------------------- |
| ID mô hình       | `v6-max`, `c1`, `v6`, `v5.6`, `v5.5`, `v5`, `v5-fast`, `v4.5`, `v4`, `v3.5`; `v5-fast` cần quyền tài khoản     |
| Độ phân giải     | `quality`\: `360p`, `540p`, `720p`, `1080p`                                                                    |
| Tỷ lệ khung hình | Tạo từ văn bản\: `16:9`, `9:16`, `4:3`, `3:4`, `1:1`, `2:3`, `3:2`, `21:9`; tạo từ ảnh\: không có trường này   |
| Thời lượng       | Phạm vi giao diện 1–15 giây; C1, V6 là 1–15 giây, V5.5, V5.6 là 5, 8 hoặc 10 giây, mô hình cũ là 5 hoặc 8 giây |
| Âm thanh         | Công tắc boolean `generate_audio_switch`, mặc định `false`; V5.5, V5.6, V6, C1 hỗ trợ âm thanh gốc             |
| Ảnh tham chiếu   | Tạo từ ảnh phải tải lên trước để lấy `img_id`; tác vụ mẫu dùng `img_ids` cùng `template_id`                    |
| Đơn vị tính phí  | Phản hồi tạo trả `Resp.credits`, đơn giá theo trang giá của hãng                                               |

Khi chọn, trước hết xem thế hệ mô hình, sau đó xem `quality` và `duration`. `quality` chỉ quyết định bậc pixel đầu ra, không thay đổi khung hình; `aspect_ratio` chỉ quyết định hình dạng, pixel cuối cùng do cả hai cùng quyết định. Tạo từ ảnh không có trường `aspect_ratio`, đừng sao chép nguyên nội dung yêu cầu tạo từ văn bản, khung hình do ảnh đầu vào hoặc mẫu quyết định. `Resp.credits` trong phản hồi tạo phù hợp để ghi ngân sách; khoản trừ thực tế và hoàn tiền vẫn căn cứ vào hóa đơn tài khoản.

## Quy trình gọi

1. Tạo API Key trên nền tảng mở PixVerse. Yêu cầu dùng header `API-KEY`, không ghi nó vào lời nhắc hay kho mã nguồn.
2. Tạo từ ảnh trước tiên gọi `POST /openapi/v2/image/upload` để tải ảnh lên, lưu `Resp.img_id` trong phản hồi; tạo từ văn bản bỏ qua bước này.
3. Gửi JSON đến điểm cuối tạo tương ứng. Trường bắt buộc là `model`, `prompt`, `duration`, `quality`; tạo từ văn bản còn cần `aspect_ratio`. Mỗi yêu cầu tạo `Ai-trace-id` mới.
4. Lưu `Resp.video_id` trong phản hồi tạo. Đừng coi `ErrCode=0` là video đã được tạo.
5. Gọi điểm cuối truy vấn mỗi 3–5 giây. Chỉ tải xuống khi `status=1` và `Resp.url` truy cập được; `status=7` sửa nội dung rồi mới quyết định có thử lại, `status=8` giữ `Ai-trace-id` để điều tra.
6. Chuyển lưu video vào lưu trữ của bạn. Chính sách truy cập và thời hạn của URL kết quả theo mô tả của hãng, không coi đó là địa chỉ công khai vĩnh viễn.

## Mô phỏng lệnh gọi

Các bản tin dưới đây chỉ dùng để minh họa cấu trúc trường; ID tác vụ, credits và URL đều là giá trị minh họa, không phải dữ liệu tài khoản thật.

Tạo tác vụ tạo video từ văn bản\:

```json
{
  "model": "v6-max",
  "prompt": "示例：海边日落，一艘白色帆船缓慢驶过，镜头平稳。",
  "duration": 5,
  "quality": "720p",
  "aspect_ratio": "16:9",
  "seed": 20260804,
  "generate_audio_switch": false
}
```

Tạo thành công chỉ trả về ID tác vụ và credits đã tiêu thụ\:

```json
{
  "ErrCode": 0,
  "ErrMsg": "Success",
  "Resp": {
    "video_id": 900000000000001,
    "credits": 12
  }
}
```

Truy vấn thấy `status=1` mới có địa chỉ tải xuống\:

```json
{
  "ErrCode": 0,
  "ErrMsg": "Success",
  "Resp": {
    "id": 900000000000001,
    "status": 1,
    "url": "https://example.com/demo-pixverse.mp4",
    "duration": 5,
    "quality": "720p",
    "aspect_ratio": "16:9",
    "outputWidth": 1280,
    "outputHeight": 720,
    "has_audio": false,
    "credits": 12
  }
}
```

Khi `status=5` tiếp tục thăm dò; `status=7` hoặc `status=8` kết thúc ngay và ghi lý do thất bại từ `ErrMsg`, `Error.Message` và `Ai-trace-id`.

## Kết nối và phiên

* **Địa chỉ cơ sở**\: `https://app-api.pixverse.ai`. Tạo và truy vấn đều nằm dưới `/openapi/v2/`.
* **Header xác thực**\: `API-KEY: PASTE_API_KEY_HERE`; `Content-Type: application/json`; mỗi yêu cầu thêm một `Ai-trace-id` mới.
* **Hai bộ địa chỉ**\: kết nối trực tiếp dùng `https://app-api.pixverse.ai`, header xác thực là `API-KEY`; chỉ dùng `https://api.dwchainless.com` và `Authorization: Bearer` cùng khóa của trang này khi kênh xác nhận rõ ánh xạ qua cổng này; không thể chỉ đổi địa chỉ và xác thực. Kênh SimiRouter có ánh xạ các đường dẫn này hay chuyển sang giao thức video thống nhất phụ thuộc cấu hình kênh; không thể chỉ đổi tên miền rồi giả định các trường tương thích.
* **Quá thời gian và idempotent**\: yêu cầu tạo quá thời gian không có nghĩa máy chủ chưa tiếp nhận. Trước tiên truy vấn theo `video_id` đã lưu, xác nhận không tồn tại rồi mới thử lại; không liên tục gửi cùng lời nhắc để “thúc tiến độ”.
* **Đánh giá lỗi**\: HTTP 200 cũng có thể kèm `ErrCode` khác 0. Lỗi nghiệp vụ phải đọc `ErrCode`, `ErrMsg` và `Error.Type`, `Error.Param` tùy chọn, không chỉ nhìn mã trạng thái HTTP.

## Tham khảo chính thức

* [PixVerse Quick Start](https\://docs.platform.pixverse.ai/quick-start-2394985m0)
* [API tạo video từ văn bản PixVerse](https\://docs.platform.pixverse.ai/text-to-video-generation-13016634e0)
* [API tạo video từ ảnh PixVerse](https\://docs.platform.pixverse.ai/image-to-video-generation-13016633e0)
* [Truy vấn trạng thái tác vụ PixVerse](https\://docs.platform.pixverse.ai/query-task-status-43051212e0)