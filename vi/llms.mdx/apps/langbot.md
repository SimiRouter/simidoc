# Cấu hình LangBot

LangBot lưu kết nối trong nhà cung cấp để mô hình tham chiếu. Nhà cung cấp tương thích OpenAI kết nối mô hình SimiRouter.

## Tạo nhà cung cấp và mô hình

1. Nhấn [Tài liệu chính thức LangBot](https\://docs.langbot.app/) để cài và khởi chạy ứng dụng.
2. Mở SimiRouter [Quản lý khóa API](https://api.dwchainless.com/keys) để sao chép khóa.
3. Thêm mô hình trò chuyện trên trang mô hình LangBot; chọn hoặc tạo nhà cung cấp tương thích OpenAI.
4. Cấu hình kết nối\:

| Trường                 | Nội dung                                 |
| ---------------------- | ---------------------------------------- |
| Base URL / URL yêu cầu | `https://api.dwchainless.com/v1`         |
| API Key                | SimiRouter API Key                       |
| Tên mô hình            | ID mô hình đầy đủ khả dụng cho tài khoản |

Mô hình kế thừa địa chỉ và khóa của nhà cung cấp. Chỉ bật thị giác hay công cụ nếu mô hình thực hỗ trợ; công tắc không cấp khả năng còn thiếu.

## Gắn pipeline

Chọn mô hình vừa thêm trong pipeline rồi lưu. Gửi tin nhắn qua chế độ gỡ lỗi hoặc bot đã gắn, rồi mở SimiRouter [Nhật ký sử dụng](https://api.dwchainless.com/usage-logs/common) để đối chiếu thời gian, mô hình và mức dùng.

## Kho tri thức và nhúng (không hỗ trợ)

Kho tri thức LangBot cần mô hình nhúng. SimiRouter hiện không hỗ trợ tích hợp nhúng; cấu hình trò chuyện không phải dịch vụ vector. Dùng nhà cung cấp nhúng khác được LangBot hỗ trợ hoặc phương án tích hợp theo tài liệu chính thức.

## Tham khảo chính thức

[Cấu hình mô hình LangBot](https\://docs.langbot.app/zh/usage/models/readme) giải thích quan hệ nhà cung cấp, mô hình trò chuyện, mô hình nhúng và pipeline.