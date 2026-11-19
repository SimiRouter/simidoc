# Cấu hình AstrBot

AstrBot là trợ lý AI mã nguồn mở hỗ trợ nhiều nền tảng nhắn tin. Hướng dẫn kết nối SimiRouter qua giao thức tương thích OpenAI.

## Thêm nhà cung cấp

1. Cài đặt và khởi chạy AstrBot; xem hướng dẫn tại [Tài liệu chính thức AstrBot](https\://docs.astrbot.app/).
2. Trong SimiRouter, mở [Quản lý khóa API](https://api.dwchainless.com/keys) để tạo khóa.
3. Mở bảng quản trị AstrBot tại **Providers → Chat Completion**, nhấp **Add** rồi chọn **OpenAI Compatible**. Phiên bản cũ có thể hiển thị “Nhà cung cấp mô hình → Thêm → OpenAI”.
4. Điền các trường sau và lưu\:

| Trường           | Nội dung                                                                               |
| ---------------- | -------------------------------------------------------------------------------------- |
| Tên nhà cung cấp | `SimiRouter`                                                                           |
| API Base URL     | `https://api.dwchainless.com/v1`                                                       |
| API Key          | SimiRouter API Key                                                                     |
| Model            | Từ [Danh mục mô hình](https://api.dwchainless.com/vi/pricing/) sao chép ID mô hình đầy đủ mà tài khoản được phép dùng |

Nhấp **Save and Fetch Models** để lấy mô hình; nhấp `+` bên phải mô hình để thêm và bật. Cũng có thể dùng **Custom Model** để nhập ID mô hình thủ công.

## Đặt mô hình trò chuyện mặc định

Mở **Config → AI → Model**, đặt **Chat Model** thành mô hình vừa thêm rồi lưu. Dùng **Test Model** hoặc gửi tin nhắn ngắn để thử, sau đó kiểm tra SimiRouter [Nhật ký sử dụng](https://api.dwchainless.com/usage-logs/common) để xác minh lệnh gọi.

Hiểu hình ảnh và gọi công cụ cần AstrBot, mô hình và kênh cùng hỗ trợ. Trò chuyện văn bản thành công không chứng minh mọi khả năng mở rộng đều dùng được.

## Tham khảo chính thức

* [Cấu hình nhà cung cấp mô hình AstrBot](https\://docs.astrbot.app/en/providers/llm.html)
* [Kết nối dịch vụ mô hình với AstrBot](https\://docs.astrbot.app/en/providers/start.html)