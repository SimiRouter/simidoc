# Video Veo (mô hình xem trước trên Gemini API đã ngừng)

## Tổng quan

Veo tạo video qua long-running operation của Gemini API\: trước tiên gọi `predictLongRunning` để khởi động tác vụ, lấy tên operation, rồi thăm dò operation đó, sau khi hoàn tất tải MP4 từ URI tệp trong phản hồi.

**Các mô hình xem trước như `veo-3.1-generate-preview`, `veo-3.1-fast-generate-preview` trên Gemini API đã ngừng hoạt động từ ngày 2026-10-22.** Trang này giữ cấu trúc giao thức để tham khảo khi hiểu các lệnh gọi đã có và khi di chuyển; hiện không thể coi điểm cuối này là giao diện sản xuất khả dụng. Có thể di chuyển sang `gemini-omni-1.2-flash`, hoặc dùng mô hình GA trên Gemini Enterprise Agent Platform.

| Việc bạn cần làm    | Đầu vào                                             | Đầu ra                   | Điểm cuối                                           |
| ------------------- | --------------------------------------------------- | ------------------------ | --------------------------------------------------- |
| Khởi động tạo video | Lời nhắc, khung đầu, khung cuối hoặc ảnh tham chiếu | Tên operation            | `POST /v1beta/models/{MODEL_ID}:predictLongRunning` |
| Truy vấn thao tác   | Tên operation                                       | `done`, kết quả hoặc lỗi | `GET /v1beta/{operation_name}`                      |
| Tải video           | URI tệp trong kết quả                               | Byte MP4                 | `GET {video.uri}`                                   |

## Khái niệm cốt lõi

* **Operation không phải ID tác vụ**\: phản hồi tạo trả về `name`, ví dụ `models/veo-3.1-generate-preview/operations/...`. Thăm dò, đọc kết quả và điều tra lỗi đều dùng tên đầy đủ này.
* **Điều kiện hoàn tất là `done: true`**\: `done: false` chỉ biểu thị vẫn đang xử lý. Khi `done: true` còn phải kiểm tra có `error` hay không, và `response.generateVideoResponse.generatedSamples[0].video.uri` có rỗng hay không.
* **Phạm vi thời gian**\: hãng cho biết thời gian tạo tối thiểu 11 giây, cao nhất 6 phút. Có thể thăm dò với khoảng cách 10–15 giây và đặt giới hạn tổng thời gian chờ phía máy khách.
* **Thời lượng và độ phân giải liên kết**\: thời lượng chỉ có ba bậc 4, 6, 8 giây. Khi dùng 1080p, 4k, ảnh tham chiếu hoặc nối dài video, thời lượng phải là 8 giây; không thể đổi yêu cầu 4 giây trực tiếp thành 1080p.
* **Âm thanh được tạo cùng mô hình**\: tài liệu Gemini API mô tả âm thanh luôn bật, không có công tắc `generateAudio` riêng. Lời nhắc có thể viết lời thoại, hiệu ứng âm thanh và âm thanh môi trường.
* **Tính phí phân biệt theo nền tảng**\: Gemini API và Agent Platform là hai hệ thống tính phí và hạn mức riêng, đơn giá theo trang giá của hãng. Sau khi mô hình xem trước ngừng hoạt động, không còn phát sinh phí gọi mới.

## Thông số và năng lực

| Chỉ số             | Mô hình xem trước Gemini API                                                                                                                                                                             | Mô hình GA Agent Platform                                                                        |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| ID mô hình         | `veo-3.1-generate-preview`, `veo-3.1-fast-generate-preview`, `veo-3.1-lite-generate-preview`; `veo-3.0-generate-001`, `veo-3.0-fast-generate-001`. Tài liệu Gemini API đánh dấu các ID này là Deprecated | `veo-3.1-generate-001`, `veo-3.1-fast-generate-001` (GA); `veo-3.1-lite-generate-001` là Preview |
| Độ phân giải       | Mặc định `720p`; `1080p` và `4k` chỉ với 8 giây                                                                                                                                                          | Mô hình tiêu chuẩn xuất `720p`, `1080p`, `4K`; mô hình Fast xuất `720p`, `1080p`                 |
| Tỷ lệ khung hình   | `16:9`, `9:16`                                                                                                                                                                                           | `16:9`, `9:16`                                                                                   |
| Thời lượng         | `4`, `6`, `8` giây                                                                                                                                                                                       | `4`, `6`, `8` giây; chế độ ảnh tham chiếu chỉ 8 giây                                             |
| Âm thanh           | Tạo gốc, luôn bật                                                                                                                                                                                        | Bảng năng lực có liệt kê tạo âm thanh                                                            |
| Tư liệu tham chiếu | `image` khung đầu, `lastFrame` khung cuối, tối đa 3 `referenceImages`                                                                                                                                    | Ảnh tham chiếu tài sản, khung đầu và cuối                                                        |
| Nối dài video      | Mỗi lần thêm 7 giây, tối đa 20 lần; đầu vào tối đa 141 giây, đầu ra tối đa 148 giây; chỉ 720p                                                                                                            | Hỗ trợ năng lực nối dài, tham số theo tài liệu nền tảng                                          |

Độ phân giải và thời lượng không phải lựa chọn độc lập\: 1080p, 4k, ảnh tham chiếu và nối dài đều yêu cầu 8 giây; 4 giây hoặc 6 giây chỉ đi với 720p. Ảnh tham chiếu tối đa 3 ảnh, khung đầu và khung cuối là ràng buộc hình ảnh chứ không phải tham chiếu phong cách. Âm thanh luôn được tạo, không thể tắt bằng tham số. Sau khi di chuyển sang Agent Platform, ID mô hình, xác thực và hạn mức đều đổi hệ thống, không thể chỉ đổi điểm cuối trong bài này sang tên mô hình GA rồi tiếp tục dùng.

## Quy trình gọi

1. Xác nhận nền tảng và thông tin xác thực. Gemini API dùng `x-goog-api-key`; Agent Platform dùng cách xác thực của chính nền tảng, hai bên không thể thay thế nhau.
2. Gửi đến `POST /v1beta/models/{MODEL_ID}:predictLongRunning` với `instances` và `parameters`. Lời nhắc đặt trong `instances[0].prompt`, khung đầu đặt trong `instances[0].image`.
3. Lưu `name` trong phản hồi. Tạo thành công chỉ có nghĩa thao tác đã được thiết lập, không có nghĩa video tải được.
4. Thăm dò `GET /v1beta/{operation_name}` cho đến khi `done: true`. Nếu có `error`, kết thúc theo nội dung lỗi, không tiếp tục chờ.
5. Đọc địa chỉ tải xuống từ `response.generateVideoResponse.generatedSamples[0].video.uri`, mang API Key khi yêu cầu URI đó và cho phép chuyển hướng HTTP.
6. Chuyển lưu tệp vào lưu trữ của bạn. Tài liệu hãng cho biết video tạo được giữ 2 ngày, tham chiếu nối dài sẽ đặt lại thời gian; không phụ thuộc vào URL hãng có hiệu lực lâu dài.

## Mô phỏng lệnh gọi

Dưới đây là minh họa lưu trữ, dùng để giải thích cấu trúc bản tin của Gemini API cũ. Mô hình xem trước đã ngừng hoạt động từ ngày 2026-10-22, hiện không tạo tác vụ mới theo nội dung này; tên operation và URL đều là giá trị minh họa.

Yêu cầu khởi động\:

```json
{
  "instances": [
    {
      "prompt": "示例：海边日落，镜头缓慢推进。"
    }
  ],
  "parameters": {
    "aspectRatio": "16:9",
    "resolution": "720p",
    "numberOfVideos": 1,
    "durationSeconds": 8,
    "personGeneration": "allow_all"
  }
}
```

Phản hồi tạo chỉ có tên thao tác\:

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": false
}
```

Phản hồi thao tác sau khi hoàn tất\:

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": true,
  "response": {
    "generateVideoResponse": {
      "generatedSamples": [
        {
          "video": {
            "uri": "https://example.com/demo-veo.mp4"
          }
        }
      ]
    }
  }
}
```

Khi `done: true` nhưng không có `generatedSamples` hoặc URI rỗng, coi là thất bại và giữ tên operation.

## Kết nối và phiên

* **Địa chỉ cơ sở**\: `https://generativelanguage.googleapis.com/v1beta`.
* **Header xác thực**\: `x-goog-api-key: PASTE_API_KEY_HERE`, đồng thời gửi `Content-Type: application/json`.
* **Hai bộ địa chỉ**\: kết nối trực tiếp Gemini API dùng `https://generativelanguage.googleapis.com/v1beta`, header xác thực là `x-goog-api-key`; chỉ dùng `https://api.dwchainless.com` và `Authorization: Bearer` cùng khóa của trang này khi kênh xác nhận rõ ánh xạ qua cổng này; không thể chỉ đổi địa chỉ và xác thực. Nếu SimiRouter cung cấp mô hình cùng tên, đường dẫn, trường và cách thăm dò do ánh xạ kênh quyết định. Mô hình GA của Agent Platform dùng địa chỉ theo vùng như `https://{region}-aiplatform.googleapis.com` và xác thực dự án, không phải địa chỉ `generativelanguage`, cũng không phải chỉ thay chuỗi tên mô hình.
* **Quá thời gian và idempotent**\: sau khi yêu cầu khởi động quá thời gian, trước tiên kiểm tra operation đã được tạo chưa; lưu `name` quan trọng hơn lưu mã trạng thái HTTP. Không khởi động lại cùng tác vụ chỉ vì thời gian chờ dài.
* **Gợi ý di chuyển**\: hình dạng giao diện của `gemini-omni-1.2-flash` khác `predictLongRunning`, mã thăm dò hiện có có thể phải viết lại. Trước khi di chuyển, căn cứ vào tài liệu di chuyển chính thức và danh sách mô hình khả dụng của tài khoản.

## Tham khảo chính thức

* [Gemini API\: Tạo video Veo](https\://aistudio.google.com/docs/veo)
* [Ghi chú ngừng mô hình xem trước Veo 3.1](https\://aistudio.google.com/docs/models/veo-3.1-generate-preview)
* [Gemini Enterprise Agent Platform\: Veo 3.1](https\://docs.cloud.google.com/gemini-enterprise-agent-platform/models/veo/3-1-generate)