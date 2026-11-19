# Tham khảo API

SimiRouter xác thực bằng khóa API và chuyển yêu cầu theo mô hình, nhóm, kênh. API tương thích và API gốc có thể khác địa chỉ, xác thực, cấu trúc tham số; không trộn chỉ bằng cách đổi tên miền.

## Tổng quan

API được tổ chức theo ba lớp\: chọn khả năng (văn bản, hình ảnh, video, âm thanh, công cụ, danh sách mô hình), chọn giao thức (tương thích OpenAI, Gemini gốc, Claude Messages), rồi đối chiếu tham số trên trang API. Ba hình thức gọi quyết định cách viết yêu cầu\:

| Hình thức             | Đặc điểm                                  | API tiêu biểu                        |
| --------------------- | ----------------------------------------- | ------------------------------------ |
| Đồng bộ               | Một kết nối trả kết quả đầy đủ            | Danh sách mô hình, tạo ảnh, phiên âm |
| Phát trực tuyến (SSE) | Một kết nối trả sự kiện theo từng phần    | Chat, hiểu ảnh, gọi công cụ          |
| Tác vụ bất đồng bộ    | Trả mã tác vụ, sau đó truy vấn trạng thái | Tạo video, tinh chỉnh chính thức     |

Hết thời gian hoặc ngắt kết nối ở máy khách không nhất thiết hủy tác vụ phía trên. Kiểm tra tác vụ và mức dùng trước khi gửi lại yêu cầu tạo.

## Chuẩn bị tích hợp

1. Theo [Tạo khóa SimiRouter](/simidoc/vi/apps/getting-started) để tạo khóa.
2. Chọn ID đầy đủ của mô hình mà tài khoản có thể truy cập trong [danh mục mô hình](https://api.dwchainless.com/vi/pricing/).
3. Xác nhận địa chỉ, định dạng và yêu cầu mô hình trên trang API cụ thể. Địa chỉ gốc SimiRouter là `https://api.dwchainless.com`; `/v1` hoặc `/v1beta` do đường dẫn API quyết định.
4. Lưu khóa trong biến môi trường hoặc kho bí mật phía máy chủ. Yêu cầu thật có thể tính phí; không để lộ trong trình duyệt hay mã công khai.

[Tích hợp API bằng script](/simidoc/vi/apps/api-script) cung cấp yêu cầu văn bản đầy đủ bằng Python, Node.js, curl và Go.

## Địa chỉ dịch vụ

Trước khi chuyển sang gọi trực tiếp API của nhà cung cấp, hãy kiểm tra đường dẫn, cách xác thực, ID mô hình và các trường trong yêu cầu. Chỉ giữ nguyên cấu trúc yêu cầu khi hai bên dùng cùng giao thức và trang API xác nhận khả năng tương thích.

| Dịch vụ                            | Địa chỉ                                      | Xác thực                                   |
| ---------------------------------- | -------------------------------------------- | ------------------------------------------ |
| Cổng SimiRouter                    | `https://api.dwchainless.com`                | `Authorization: Bearer` và khóa SimiRouter |
| Google Gemini API (khóa AI Studio) | `https://generativelanguage.googleapis.com`  | `x-goog-api-key`                           |
| Google Vertex AI                   | `https://{region}-aiplatform.googleapis.com` | token truy cập OAuth                       |
| OpenAI                             | `https://api.openai.com`                     | `Authorization: Bearer` và khóa OpenAI     |
| Anthropic                          | `https://api.anthropic.com`                  | `x-api-key`                                |
| xAI                                | `https://api.x.ai`                           | `Authorization: Bearer`                    |
| Volcano Ark                        | `https://ark.cn-beijing.volces.com/api/v3`   | `Authorization: Bearer`                    |
| Alibaba Cloud DashScope            | `https://dashscope.aliyuncs.com`             | `Authorization: Bearer` và khóa DashScope  |

Khi gỡ lỗi cục bộ, dùng `http://127.0.0.1:3001` làm địa chỉ cổng. Khóa của nhà cung cấp và khóa SimiRouter không tương thích; khi thay địa chỉ phải thay cả xác thực.

## Danh mục khả năng

| Chức năng                                          | Nội dung                                                                                                             | Cách gọi                                                                            |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| [Trò chuyện](/simidoc/vi/apps/api/chat)                               | Chat Completions, Responses, Claude Messages và sinh nội dung Gemini                                                 | Không truyền luồng chờ phản hồi đầy đủ; truyền luồng nhận dần sự kiện SSE           |
| [Tạo ảnh](/simidoc/vi/apps/api/images)                                | Tạo, chỉnh sửa, tạo theo ảnh tham chiếu và hiểu ảnh, bao gồm giao thức OpenAI, Gemini, Qwen, Jimeng, Grok và FLUX    | Trả dữ liệu ảnh, URL hoặc văn bản theo giao thức; hỗ trợ truyền luồng theo từng API |
| [Video](/simidoc/vi/apps/api/video)                                   | Giao thức tạo Seedance, Kling, Veo, PixVerse, Wan, Happy Horse và Grok Imagine, cùng hiểu video; Jimeng chờ tích hợp | Tạo video thường gửi tác vụ rồi truy vấn; hiểu video dùng API đa phương thức        |
| [Âm thanh](/simidoc/vi/apps/api/audio)                                | Đầu vào/đầu ra âm thanh OpenAI, Gemini và MiMo                                                                       | Yêu cầu tệp, âm thanh nhị phân hoặc sự kiện luồng cần bộ phân tích riêng            |
| [Tổng hợp giọng nói](/simidoc/vi/apps/api/audio/speech)               | Văn bản thành giọng nói                                                                                              | Trả tệp âm thanh hoặc sự kiện luồng được mô hình hỗ trợ                             |
| [Chép lời giọng nói](/simidoc/vi/apps/api/audio/transcriptions)       | Âm thanh thành văn bản ngôn ngữ gốc                                                                                  | Tải âm thanh lên rồi nhận bản chép                                                  |
| [Dịch âm thanh](/simidoc/vi/apps/api/audio/translations)              | Âm thanh thành văn bản tiếng Anh                                                                                     | Tải âm thanh rồi nhận văn bản Anh, không phải giọng nói đã dịch                     |
| [Âm nhạc (không hỗ trợ)](/simidoc/vi/apps/api/music)                  | Ví dụ chính thức Google Lyria                                                                                        | Chỉ là tài liệu tham khảo kết nối trực tiếp Google                                  |
| [Nhúng (không hỗ trợ)](/simidoc/vi/apps/api/pending/embeddings)       | Tham khảo API vector chính thức OpenAI và Gemini                                                                     | Chỉ là tài liệu tham khảo kết nối trực tiếp của nhà cung cấp                        |
| [Xếp hạng lại](/simidoc/vi/apps/api/pending/rerank)                   | Xếp tài liệu theo độ liên quan                                                                                       | Dùng giao thức nhà cung cấp trên trang                                              |
| [Giọng nói thời gian thực](/simidoc/vi/apps/api/pending/realtime)     | Giao thức OpenAI Realtime                                                                                            | Kết nối hai chiều thời gian thực, không phải yêu cầu HTTP tệp âm thanh thông thường |
| [Công cụ](/simidoc/vi/apps/api/tools)                                 | Gọi hàm và tìm kiếm web                                                                                              | Thực thi theo loại công cụ rồi trả kết quả sau khi mô hình yêu cầu                  |
| [Kiểm duyệt nội dung](/simidoc/vi/apps/api/pending/moderations)       | Phân loại an toàn văn bản và ảnh                                                                                     | Trả phân loại và điểm                                                               |
| [Lấy mô hình](/simidoc/vi/apps/api/models)                            | Danh sách định dạng OpenAI và Gemini                                                                                 | Trả ID; có trong danh sách không nghĩa mọi khả năng đều mở                          |
| [Hiểu tệp](/simidoc/vi/apps/api/upload)                               | Truyền nội dung tệp vào mô hình đa phương thức hỗ trợ                                                                | Khác Files API độc lập                                                              |
| [Tinh chỉnh (không hỗ trợ)](/simidoc/vi/apps/api/pending/fine-tuning) | Tham khảo giao thức tinh chỉnh chính thức                                                                            | Chỉ là tài liệu tham khảo kết nối trực tiếp OpenAI                                  |
| [Files API (không hỗ trợ)](/simidoc/vi/apps/api/pending/files)        | Tham khảo quản lý tệp chính thức                                                                                     | Chỉ là tài liệu tham khảo kết nối trực tiếp OpenAI                                  |

## Đọc hướng dẫn API

Các trang API mô tả phương thức, tham số, trường phản hồi, ví dụ mã, lỗi và tài liệu chính thức. Ví dụ qua cổng dùng khóa SimiRouter. Ví dụ kết nối trực tiếp dùng thông tin xác thực của nhà cung cấp. Các chức năng ghi “không hỗ trợ” chỉ có tài liệu tham khảo kết nối trực tiếp.