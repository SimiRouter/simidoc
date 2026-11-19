# Tạo video DashScope (Wan / HappyHorse)

## Tổng quan

Wan và HappyHorse đều là các họ mô hình tạo video trên nền tảng Bailian của Alibaba Cloud, dùng chung một bộ giao thức bất đồng bộ DashScope\: điểm cuối gửi, header `X-DashScope-Async`, đường dẫn truy vấn tác vụ, chuỗi trạng thái và trường kết quả đều giống nhau. Chỉ khác ở ba chỗ\: ID mô hình, cấu trúc đầu vào và tham số khung hình.

| Việc bạn cần làm                                            | Đầu vào                                                     | Đầu ra                     | Điểm cuối                                                     |
| ----------------------------------------------------------- | ----------------------------------------------------------- | -------------------------- | ------------------------------------------------------------- |
| Tạo video từ văn bản (Wan)                                  | Lời nhắc, `parameters.size`, `duration`                     | `task_id`                  | `POST /api/v1/services/aigc/video-generation/video-synthesis` |
| Tạo video từ ảnh khung đầu (Wan)                            | Lời nhắc, `input.img_url`, `parameters.resolution`          | `task_id`                  | Cùng điểm cuối gửi                                            |
| Tạo video từ văn bản (HappyHorse)                           | Lời nhắc, `resolution`, `ratio`, `duration`                 | `task_id`                  | Cùng điểm cuối gửi                                            |
| Tạo video từ ảnh khung đầu hoặc ảnh tham chiếu (HappyHorse) | `input.media` chứa `first_frame` hoặc 1–9 `reference_image` | `task_id`                  | Cùng điểm cuối gửi                                            |
| Truy vấn tác vụ                                             | `task_id`                                                   | `task_status`, `video_url` | `GET /api/v1/tasks/{task_id}`                                 |

## Khái niệm cốt lõi

* **Vòng đời tác vụ**\: `PENDING → RUNNING → SUCCEEDED`, trạng thái kết thúc thất bại là `FAILED`, ngoài ra còn `CANCELED` và `UNKNOWN`. Chỉ khi `SUCCEEDED` mới đọc `output.video_url`.
* **Hai ID có vai trò khác nhau**\: `output.task_id` dùng để truy vấn tác vụ; `request_id` chỉ dùng để truy vết một yêu cầu HTTP. Khi gỡ lỗi cần giữ cả hai.
* **Nhịp thăm dò**\: tài liệu chính thức khuyến nghị truy vấn mỗi 15 giây. ID tác vụ và URL kết quả đều có hiệu lực 24 giờ; sau khi hết hạn, truy vấn sẽ trả về `UNKNOWN`.
* **Cấu trúc đầu vào phân biệt theo họ mô hình**\: tạo video từ ảnh của Wan dùng `input.img_url`; HappyHorse dùng mảng `input.media`, mỗi phần tử có `type` (`first_frame` hoặc `reference_image`) và `url`. Hai cấu trúc không thể thay thế nhau.
* **Tham số khung hình phân biệt theo họ mô hình**\: tạo video từ văn bản của Wan dùng `parameters.size` (`宽*高`, ví dụ `1280*720`), tạo video từ ảnh của Wan dùng `parameters.resolution` (`480P`, `720P`, `1080P`); tạo video từ văn bản và từ ảnh tham chiếu của HappyHorse dùng `parameters.ratio` (ví dụ `16:9`), tạo video từ ảnh khung đầu bám theo ảnh khung đầu.
* **Âm thanh chỉ có ở một số thế hệ Wan**\: Wan2.6 và Wan2.5 mặc định tạo nhạc hoặc hiệu ứng âm thanh khớp với hình ảnh, cũng có thể dùng `input.audio_url` để cung cấp WAV, MP3; Wan2.2 và Wan2.1 mặc định xuất video không tiếng. Tài liệu HappyHorse không có tham số đầu vào hay đầu ra âm thanh.
* **Tính phí theo số giây đầu ra**\: `usage.duration` trong phản hồi truy vấn là thời lượng video đầu ra. Đơn giá, cách quyết toán tác vụ thất bại và quy tắc hoàn tiền theo trang giá và hóa đơn của nhà cung cấp.

## Thông số và năng lực

Giá trị của Wan\:

| Chỉ số                       | Giá trị đã xác minh                                                                                                                                                                                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Mô hình tạo video từ văn bản | `wan2.6-t2v`, `wan2.5-t2v-preview`, `wan2.2-t2v-plus`, `wan2.1-t2v-turbo`, `wan2.1-t2v-plus`                                                                                                                                                                 |
| Mô hình tạo video từ ảnh     | `wan2.6-i2v`, `wan2.6-i2v-flash`, `wan2.5-i2v-preview`, `wan2.2-i2v-plus`, `wan2.2-i2v-flash`, `wan2.1-i2v-turbo`, `wan2.1-i2v-plus`                                                                                                                         |
| Độ phân giải                 | Tạo video từ văn bản dùng `size`\: `832*480`, `480*832`, `624*624`, `1280*720`, `720*1280`, `960*960`, `1088*832`, `832*1088`, `1920*1080`, `1080*1920`, `1440*1440`, `1632*1248`, `1248*1632`; tạo video từ ảnh dùng `resolution`\: `480P`, `720P`, `1080P` |
| Thời lượng                   | `wan2.6-t2v` là 2–15 giây; `wan2.5-t2v-preview` là 5 hoặc 10 giây; tạo video từ văn bản của `wan2.2`, `wan2.1` cố định 5 giây; `wan2.1-i2v-turbo` hỗ trợ 3, 4, 5 giây                                                                                        |
| Âm thanh                     | Wan2.6, Wan2.5 tự động tạo nhạc hoặc hiệu ứng âm thanh; `audio_url` hỗ trợ WAV, MP3, 3–30 giây, tối đa 15 MB; Wan2.2, Wan2.1 mặc định không tiếng                                                                                                            |
| Tư liệu tham chiếu           | Tạo video từ ảnh dùng `input.img_url`, hỗ trợ URL công khai hoặc Base64; ảnh rộng cao 240–8000 pixel, Wan2.6/2.5 tối đa 20 MB                                                                                                                                |

Giá trị của HappyHorse\:

| Chỉ số           | Giá trị đã xác minh                                                                                                                                                                                       |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ID mô hình       | `happyhorse-1.1-t2v`, `happyhorse-1.0-t2v`, `happyhorse-1.1-i2v`, `happyhorse-1.1-r2v`                                                                                                                    |
| Độ phân giải     | `480P`, `720P`, `1080P`, mặc định `1080P`                                                                                                                                                                 |
| Tỷ lệ khung hình | Tạo video từ văn bản và từ ảnh tham chiếu\: `16:9` (mặc định), `9:16`, `1:1`, `4:3`, `3:4`, `4:5`, `5:4`, `9:21`, `21:9`; tạo video từ ảnh bám theo khung đầu, cho phép từ 1\:2.5 đến 2.5\:1              |
| Thời lượng       | 3–15 giây, mặc định 5 giây; phạm vi này được nêu rõ trong tài liệu của `happyhorse-1.0-t2v`, tạo video từ ảnh và tạo video từ ảnh tham chiếu, tài liệu `happyhorse-1.1-t2v` không nêu phạm vi             |
| Ảnh tham chiếu   | Tạo video từ ảnh dùng 1 ảnh khung đầu, cạnh ngắn nhất ít nhất 300 pixel; tạo video từ ảnh tham chiếu dùng 1–9 ảnh, cạnh ngắn nhất ít nhất 400 pixel; mỗi ảnh tối đa 20 MB; định dạng JPEG, JPG, PNG, WEBP |
| Tham số khác     | `watermark` mặc định `true`, khi bật sẽ hiển thị HappyHorse ở góc dưới bên phải; `seed` trong khoảng 0–2147483647                                                                                         |

`size` của Wan là pixel cụ thể, `resolution` là bậc, hai loại phục vụ các điểm cuối khác nhau\: tạo video từ văn bản 1080P dọc phải ghi `1080*1920`, không được ghi `1080P`; tạo video từ ảnh thì ngược lại, chỉ chấp nhận `480P`, `720P`, `1080P`. Tạo video từ ảnh khung đầu của HappyHorse không đọc `ratio`, tỷ lệ đầu ra do ảnh quyết định. Tạo video từ văn bản của Wan2.2 và Wan2.1 cố định 5 giây; tăng `duration` sẽ không nhận được đoạn dài hơn. Wan2.6 và Wan2.5 tự động tạo rãnh âm thanh; nếu hạ nguồn không cần âm thanh thì nên loại bỏ ở hậu kỳ, hoặc xác nhận trước mô hình có cung cấp tham số tắt hay không. Khi số ảnh tham chiếu là 1–9, `[Image N]` trong lời nhắc phải khớp thứ tự `media`; sai thứ tự sẽ tham chiếu nhầm ảnh.

## Quy trình gọi

1. Tạo khóa API trên Alibaba Cloud Bailian. Mô hình, địa chỉ yêu cầu và khóa phải thuộc cùng một khu vực; gọi khác khu vực sẽ thất bại.
2. Chọn họ mô hình và chế độ\: tạo từ văn bản/ảnh của Wan, hoặc tạo từ văn bản/khung đầu/ảnh tham chiếu của HappyHorse. Cấu trúc đầu vào khác nhau, không thể dùng lại cùng một thân yêu cầu.
3. Gửi JSON đến `POST /api/v1/services/aigc/video-generation/video-synthesis` kèm `Authorization: Bearer`, `Content-Type: application/json` và `X-DashScope-Async: enable`.
4. Lưu `output.task_id` và `request_id`. Việc tạo trả về `PENDING` chỉ có nghĩa đã xếp hàng thành công.
5. Gọi `GET /api/v1/tasks/{task_id}` mỗi 15 giây. Sau `SUCCEEDED` đọc `output.video_url`; khi `FAILED` đọc `output.code` và `output.message`.
6. Tải xuống và chuyển lưu video trong vòng 24 giờ. Sau khi tác vụ hết hạn không thể truy vấn nữa, URL kết quả cũng không thể tiếp tục phụ thuộc.

## Mô phỏng lệnh gọi

Dưới đây là bản tin minh họa; ID tác vụ, ID yêu cầu, URL và mức sử dụng đều không phải dữ liệu tài khoản thật.

Yêu cầu tạo video từ văn bản của Wan\:

```json
{
  "model": "wan2.5-t2v-preview",
  "input": {
    "prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "parameters": {
    "size": "1280*720",
    "duration": 5,
    "prompt_extend": true,
    "watermark": false,
    "seed": 20260804
  }
}
```

Yêu cầu tạo video từ ảnh khung đầu của HappyHorse\:

```json
{
  "model": "happyhorse-1.1-i2v",
  "input": {
    "prompt": "示例：让画面中的帆船缓慢向前移动。",
    "media": [
      {
        "type": "first_frame",
        "url": "https://example.com/demo-first-frame.png"
      }
    ]
  },
  "parameters": {
    "resolution": "720P",
    "duration": 5,
    "watermark": false,
    "seed": 20260804
  }
}
```

Phản hồi tạo thành công của hai họ mô hình có cấu trúc giống nhau, chỉ trả về trạng thái xếp hàng\:

```json
{
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "PENDING"
  },
  "request_id": "demo-request-0001"
}
```

Truy vấn đến trạng thái kết thúc thành công\:

```json
{
  "request_id": "demo-request-0001",
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "SUCCEEDED",
    "video_url": "https://example.com/demo-video.mp4",
    "orig_prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "usage": {
    "duration": 5,
    "output_video_duration": 5,
    "video_count": 1,
    "SR": 720
  }
}
```

`PENDING`, `RUNNING` tiếp tục chờ; `FAILED`, `CANCELED` dừng ngay và lưu `output.code` và `output.message`; `UNKNOWN` trước tiên xác nhận tác vụ đã vượt quá 24 giờ hay chưa.

## Kết nối và phiên

* **Địa chỉ cơ sở**\: `https://{WorkspaceId}.{region}.maas.aliyuncs.com`. Singapore, Hoa Kỳ, Bắc Kinh, Frankfurt, Tokyo dùng máy chủ khu vực khác nhau; đường dẫn gửi và truy vấn giống nhau.
* **Header xác thực**\: `Authorization: Bearer PASTE_API_KEY_HERE`; tạo tác vụ bắt buộc thêm `X-DashScope-Async: enable`, thiếu header này sẽ nhận lỗi gọi đồng bộ.
* **Hai bộ địa chỉ**\: kết nối trực tiếp dùng `https://{WorkspaceId}.{region}.maas.aliyuncs.com`; chỉ dùng `https://api.dwchainless.com` và `Authorization: Bearer` cùng khóa của trang này khi kênh xác nhận rõ ánh xạ qua cổng này; không thể chỉ đổi địa chỉ và xác thực. Nếu kênh SimiRouter thực hiện đóng gói thống nhất, `task_id`, chuỗi trạng thái và trường kết quả có thể bị viết lại; căn cứ theo tài liệu kênh.
* **Quá thời gian và idempotent**\: sau khi gửi quá thời gian, trước tiên lưu và truy vấn `task_id` có thể đã được tạo, không được lặp lại gửi ngay. Bản thân yêu cầu thăm dò có thể thử lại, nhưng phải đặt giới hạn tổng thời gian chờ.
* **Lưu kết quả**\: `video_url` là địa chỉ tải xuống có thời hạn. Khi cần dùng lâu dài, sau khi tải xuống hãy chuyển mã hoặc chuyển lưu, không được ghi URL của nhà cung cấp trực tiếp vào cơ sở dữ liệu sản phẩm như tài nguyên vĩnh viễn.

## Tham khảo chính thức

* [Tham khảo API tạo video từ văn bản Wan](https\://www.alibabacloud.com/help/en/model-studio/legacy-wan-text-to-video-api-reference)
* [Tham khảo API tạo video từ ảnh Wan](https\://www.alibabacloud.com/help/en/model-studio/image-to-video-api-reference)
* [Mô tả mô hình Wan2.5 tạo video từ ảnh](https\://www.alibabacloud.com/help/en/model-studio/wan2-5-i2v)
* [API tạo video từ văn bản HappyHorse](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-text-to-video-api-reference)
* [API tạo video từ ảnh khung đầu HappyHorse](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-image-to-video-api-reference)
* [API tạo video từ ảnh tham chiếu HappyHorse](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-reference-to-video-api-reference)