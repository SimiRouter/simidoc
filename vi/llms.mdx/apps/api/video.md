# Video

Video gồm **tạo** và **hiểu**\: tạo tổng hợp video mới từ văn bản/tư liệu tham chiếu; hiểu trích xuất tóm tắt, sự kiện và câu trả lời dạng văn bản từ video có sẵn. Hai bên hoàn toàn khác nhau về yêu cầu, thời gian và đầu ra.

## Tổng quan

| Năng lực                     | Đầu vào                   | Đầu ra                           | Thời gian điển hình            |
| ---------------------------- | ------------------------- | -------------------------------- | ------------------------------ |
| Tạo video từ văn bản         | Lời nhắc                  | Tệp video hoặc địa chỉ tải xuống | Vài chục giây đến vài phút     |
| Tạo video từ ảnh             | Ảnh khung đầu + lời nhắc  | Tệp video                        | Vài chục giây đến vài phút     |
| Điều khiển khung đầu và cuối | Ảnh khung đầu, khung cuối | Video được kiểm soát hai đầu     | Vài phút                       |
| Hiểu video                   | Video + câu hỏi           | Tóm tắt hoặc câu trả lời văn bản | Liên quan đến thời lượng video |

## Khái niệm cốt lõi

* **Độ phân giải**\: phổ biến 480p, 720p, 1080p. Nó quyết định độ rõ nét và ảnh hưởng trực tiếp đến thời gian tạo và giá; bản nháp hoặc bản xem trước thường chỉ hỗ trợ độ phân giải thấp hơn.
* **Tỷ lệ khung hình**\: `16:9` ngang, `9:16` dọc, `1:1` vuông. Tỷ lệ cùng độ phân giải quyết định pixel thực tế, ví dụ 1080p dọc là `1080x1920`.
* **Tốc độ khung hình (fps)**\: số khung hình mỗi giây, phổ biến 24 hoặc 30. Tăng fps làm tệp lớn hơn, tạo chậm hơn, không nhất thiết khiến chuyển động tự nhiên hơn.
* **Thời lượng**\: số giây của một đoạn video, mỗi mô hình có giới hạn riêng. Một số mô hình hỗ trợ dùng số khung hình thay cho thời lượng; khi gửi đồng thời, thứ tự ưu tiên cần xác nhận theo mô tả giao diện.
* **Tư liệu tham chiếu**\: hình ảnh dùng cho khung đầu, khung cuối hoặc tham chiếu phong cách; mức hỗ trợ video và âm thanh tham chiếu khác nhau rất nhiều giữa các mô hình, không được mặc định là có.
* **Trạng thái tác vụ**\: ID trả về khi tạo chỉ biểu thị đã tiếp nhận. Thành công thật sự phải xem trạng thái cuối của giao diện truy vấn và địa chỉ đầu ra hợp lệ; trạng thái kiểu `done` không phải lúc nào cũng đồng nghĩa thành công.

Giá trị khả dụng và giới hạn của các thông số này do phiên bản mô hình quyết định; xem bảng tham số yêu cầu của từng trang con để biết chi tiết; không áp trường của phiên bản này cho phiên bản khác.

## Mô tả giao diện

| Năng lực            | Chế độ                                 | Giao thức chính thức                             | Tài liệu                                          |
| ------------------- | -------------------------------------- | ------------------------------------------------ | ------------------------------------------------- |
| Tạo Seedance        | Tạo bất đồng bộ → truy vấn → tải xuống | Volcano Ark contents/generations/tasks           | [Seedance](/simidoc/vi/apps/api/video/seedance)                            |
| Tạo Kling           | Tạo bất đồng bộ → truy vấn/gọi lại     | Giao thức tác vụ mới Kling 3.0                   | [Kling](/simidoc/vi/apps/api/video/kling)                                  |
| Tạo Jimeng          | Gửi bất đồng bộ → truy vấn             | Volcano Vision CVSync2Async, chữ ký AK/SK        | [Jimeng (chờ kết nối)](/simidoc/vi/apps/api/video/jimeng)                  |
| Tham khảo Sora      | Videos API chính thức đã đóng          | Chỉ giữ tham khảo cấu trúc giao diện             | [Sora](/simidoc/vi/apps/api/video/sora)                                    |
| Tạo Veo             | Tạo bất đồng bộ operation → thăm dò    | Gemini API `predictLongRunning`                  | [Veo](/simidoc/vi/apps/api/video/veo)                                      |
| Tạo PixVerse        | Tạo bất đồng bộ → truy vấn             | PixVerse OpenAPI v2                              | [PixVerse](/simidoc/vi/apps/api/video/pixverse)                            |
| Tạo video DashScope | Tạo bất đồng bộ → truy vấn             | DashScope video-synthesis                        | [DashScope (Wan / HappyHorse)](/simidoc/vi/apps/api/video/dashscope-video) |
| Tạo Grok Imagine    | Tạo bất đồng bộ → truy vấn             | xAI `/v1/videos`                                 | [Grok Imagine](/simidoc/vi/apps/api/video/grok-imagine)                    |
| Hiểu video          | Yêu cầu đa phương thức → văn bản / SSE | Dots, Kimi Chat Completions; Gemini Interactions | [Hiểu video](/simidoc/vi/apps/api/video/understanding)                     |

## Quy trình yêu cầu

1. Yêu cầu tạo trả về ID tác vụ, chỉ biểu thị đã tiếp nhận, không có nghĩa video đã được tạo.
2. Dùng giao diện truy vấn tác vụ của cùng hãng/kênh; nên đặt khoảng cách vài giây và đặt giới hạn tổng thời gian chờ, kết thúc ngay khi thất bại, hết hạn hoặc bị hủy.
3. Chỉ tải xuống khi trạng thái cuối là thành công và có đầu ra video hợp lệ. Lưu ID tác vụ gốc, ID yêu cầu và lý do thất bại, tránh chỉ ghi “HTTP 200”.
4. URL kết quả thường có thời hạn hiệu lực, cần chuyển lưu kịp thời. Không được dùng liên kết tải xuống làm địa chỉ lưu trữ vĩnh viễn.

Tạo video thường không phải SSE; thăm dò trạng thái không phải luồng video thời gian thực. Khả năng về âm thanh, độ phân giải, thời lượng, khung đầu và cuối và nhiều tham chiếu được phân biệt theo phiên bản mô hình; không thể áp trường của một phiên bản cho mọi mô hình video.

## Mô phỏng lệnh gọi

Dưới đây lấy giao thức Seedance làm ví dụ, minh họa ba giai đoạn tạo, tiếp nhận và truy vấn; nội dung chỉ là minh họa, địa chỉ và xác thực thuộc kết nối trực tiếp chính thức của Volcano Ark.

Yêu cầu tạo chỉ gửi lời nhắc và thông số video\:

```json
{
  "model": "doubao-seedance-2-5-260628",
  "content": [
    { "type": "text", "text": "海边日落，镜头缓慢推进" }
  ],
  "resolution": "720p",
  "ratio": "16:9",
  "duration": 5
}
```

Tạo thành công chỉ trả về ID tác vụ, không phải video\:

```json
{"id":"cgt-example"}
```

Chỉ được coi là hoàn tất khi truy vấn đến trạng thái cuối và có địa chỉ kết quả\:

```json
{
  "id": "cgt-example",
  "status": "succeeded",
  "content": { "video_url": "https://example.com/video.mp4" },
  "error": null
}
```

Khi trạng thái là `queued` hoặc `running`, tiếp tục chờ; khi là `failed`, `expired`, `cancelled`, dừng thăm dò ngay và lưu `error`. Tạo video không có gia tăng SSE, kết quả chỉ có thể lấy qua thăm dò hoặc gọi lại.

## Địa chỉ hãng và SimiRouter

Các trang con trong mục này trình bày trường và quy trình theo **giao thức chính thức của hãng**. Trước hết hãy xem phần thân yêu cầu, đường dẫn và trường trạng thái trong ví dụ là tài liệu tham khảo cho kết nối trực tiếp tới hãng; chỉ dùng địa chỉ cổng `https://api.dwchainless.com` và khóa SimiRouter khi trang đó xác nhận rõ ánh xạ qua cổng. SimiRouter có mở mô hình cùng tên hay không, dùng đường dẫn nào và ánh xạ trường ra sao phải căn cứ vào danh sách mô hình của tài khoản và cấu hình kênh hiện tại. Không gửi yêu cầu của hãng tới cổng chỉ bằng cách thay tên miền.

Khóa của hãng, AK/SK của Volcano và khóa SimiRouter không tương thích với nhau. Nếu kênh không có ánh xạ rõ ràng, đừng chỉ thay tên miền rồi bắt đầu tạo có phí.

## Tham khảo chính thức

* [Volcano Ark\: Tạo tác vụ tạo video](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)
* [Volcano Ark\: Truy vấn tác vụ tạo video](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)
* [Giao diện tạo video Jimeng](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh)
* [Kling tạo video từ văn bản](https\://kling.ai/document-api/apiReference/model/textToVideo)
* [OpenAI Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)