# Hiểu video

Hiểu video nhận video có, trả tóm tắt, cảnh, trình tự, đáp án; không tạo mới theo prompt. Ba hãng có video nhưng định dạng, tham chiếu, xác thực khác.

## Hãng và giao thức

| Tài liệu                      | Mô hình ví dụ chính thức | Đầu vào video                                              | Yêu cầu/phản hồi                                                |
| ----------------------------- | ------------------------ | ---------------------------------------------------------- | --------------------------------------------------------------- |
| [Hiểu video Dots](/simidoc/vi/apps/api/video/understanding/dots)     | `dots3-note-prev`        | Dịch vụ đọc được `video_url.url`                           | Mảng Chat Completions, chữ cuối tại `choices[].message.content` |
| [Hiểu video Kimi](/simidoc/vi/apps/api/video/understanding/kimi)     | `kimi-k3`                | Base64 video data URL hoặc Moonshot `ms://` tham chiếu tệp | Mảng Chat Completions, chữ cuối tại `choices[].message.content` |
| [Hiểu video Gemini](/simidoc/vi/apps/api/video/understanding/gemini) | `gemini-3.8-flash`       | Video nội tuyến/URI Google hỗ trợ                          | Trang dùng Interactions, chữ tại `steps[].content[]`            |

Dots video dùng chính thức `api-key` header; Kimi Bearer; Gemini `x-goog-api-key`. Dots/Kimi có `video_url` là mở rộng hãng, không chuẩn video mọi OpenAI tương thích. Cùng đường dẫn `/v1/chat/completions` không đủ hoán payload.

## Đồng bộ, luồng và tham chiếu

* **Không luồng**\: HTTP chờ chữ đầy đủ, không ID tác vụ tạo video.
* **Truyền luồng**\: SSE chữ tăng dần, trước sự kiện đầu có thể tải/giải/phân tích video. Không tải camera liên tục hay bảo đảm chữ ngay.
* **Tham chiếu tệp**\: tải lên hãng rồi tham chiếu phân tích; tải xong chưa phân tích xong, ID không dùng lẫn hãng.
* **Yêu cầu song song**\: client gửi yêu cầu độc lập, hạn mức/ngữ cảnh/dùng riêng, không là tham số “song song” trong thân.

## Chuẩn bị đầu vào

Video phải có quyền. Link tệp công khai, trang chia sẻ, đường dẫn máy, Base64 khác nhau, theo giao thức. Trang chia sẻ Xiaohongshu/khác không link video tải được; đăng nhập/chống hotlink có thể không đọc.

Độ dài, độ phân giải, lấy khung, kích thước ảnh hưởng thời gian/token/phí; xem hãng. Mốc/sự kiện đối chiếu gốc, không chứng cứ từng khung hay căn chỉnh cưỡng bức.

## Tích hợp SimiRouter

Trang con dùng khóa hãng trực tiếp. Qua SimiRouter cần ID đầy đủ khả dụng, ánh xạ video và tham chiếu tệp. Hãng hỗ trợ không là nền tảng liên thông đã thử. Khóa hãng/SimiRouter không chung.

## Tham khảo chính thức

* [Dots\: đầu vào video](https\://dots.ai/platform/docs#video-input)
* [Kimi K3 bắt đầu nhanh](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart) và [Mô hình thị giác](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Google\: hiểu video](https\://ai.google.dev/gemini-api/docs/video-understanding)