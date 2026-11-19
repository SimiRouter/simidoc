# Cấu hình Memoh

Memoh là nền tảng đa tác tử mã nguồn mở với môi trường độc lập và bộ nhớ dài hạn. Mô hình trò chuyện, giọng nói và chép lời dùng loại ứng dụng khác nhau, không chung một cấu hình giao thức.

## Cài Memoh

Nhấn [Hướng dẫn triển khai chính thức Memoh](https\://docs.memoh.ai/self-hosted/docker) để cài bản hiện tại. Thiết lập bảo mật tài khoản sau lần đăng nhập đầu; không dùng mật khẩu mặc định từ hướng dẫn cũ.

## Thêm nhà cung cấp

1. Trong SimiRouter, mở [Quản lý khóa API](https://api.dwchainless.com/keys) để tạo khóa.
2. Trong thanh cài đặt Memoh, mở trang **Models** rồi chọn **Add Provider**.
3. Dùng mẫu OpenAI Chat Completions hoặc tạo nhà cung cấp tùy chỉnh\:

| Trường      | Nội dung                         |
| ----------- | -------------------------------- |
| Name        | `SimiRouter`                     |
| Client Type | `openai-completions`             |
| Base URL    | `https://api.dwchainless.com/v1` |
| API Key     | SimiRouter API Key               |

`openai-responses` dùng Responses; `openai-completions` dùng Chat Completions, không phải bổ sung văn bản cũ dù tên gợi vậy. Đăng nhập OAuth không thay thế nhà cung cấp khóa API SimiRouter.

## Thêm và bật mô hình

Trong chi tiết nhà cung cấp, nhấp **Import Models** để nhập hoặc điền ID khả dụng thủ công. Mô hình nhập hàng loạt có thể mặc định tắt; bật trước rồi chọn trong cài đặt bot.

Gửi tin nhắn ngắn và mở SimiRouter [Nhật ký sử dụng](https://api.dwchainless.com/usage-logs/common) để xác minh. Bộ nhớ, tìm kiếm có thể cần nhà cung cấp bổ sung. SimiRouter chưa hỗ trợ nhúng; mô hình trò chuyện không thay được mô hình vector.

## Tham khảo chính thức

* [Nhà cung cấp và mô hình Memoh](https\://docs.memoh.ai/integrations/providers/llm)
* [Dự án Memoh](https\://github.com/felinics/Memoh)