# Cấu hình tiện ích bên thứ ba (VS Code Roo)

Roo Code hỗ trợ nhà cung cấp tương thích OpenAI tùy chỉnh. Chỉ cần địa chỉ, khóa và ID mô hình SimiRouter; không cần triển khai mô hình cục bộ.

## Cấu hình Roo Code

1. Cài Roo Code và mở cài đặt tiện ích.
2. Thay **API Provider** thành **OpenAI Compatible**.
3. Điền các thông tin\:

| Trường   | Nội dung                                                                    |
| -------- | --------------------------------------------------------------------------- |
| Base URL | `https://api.dwchainless.com/v1`                                            |
| API Key  | Khóa tạo tại SimiRouter [Quản lý khóa API](https://api.dwchainless.com/keys)                           |
| Model ID | Từ [Danh mục mô hình](https://api.dwchainless.com/vi/pricing/) để sao chép ID đầy đủ, phân biệt hoa thường |

4. Đặt cửa sổ ngữ cảnh, giới hạn đầu ra và đầu vào hình ảnh theo khả năng thực của mô hình, không sao chép số cố định của mô hình khác. Roo Code luôn dùng gọi công cụ gốc, không có công tắc riêng.
5. Lưu, gửi tin nhắn ngắn rồi kiểm tra SimiRouter [Nhật ký sử dụng](https://api.dwchainless.com/usage-logs/common) để xác minh lệnh gọi.

## Kiểm tra API

Ví dụ Python, Node.js, curl và Go hoàn chỉnh độc lập với ứng dụng tại [Tích hợp API bằng script](/simidoc/vi/apps/api-script) . Dùng cùng ID mô hình và quyền khóa trong thử nghiệm và tiện ích. Một yêu cầu văn bản thành công chưa xác minh công cụ hoặc ảnh.

## Lỗi thường gặp

* **401**\: kiểm tra khóa đầy đủ, hợp lệ, không có khoảng trắng thừa.
* **404**\: kiểm tra URL cuối có lặp `/v1` và kiểm tra ID mô hình.
* **Mô hình không khả dụng**\: kiểm tra quyền mô hình, nhóm và khóa theo nội dung lỗi.
* **Tham số không hỗ trợ**\: tắt tham số không phù hợp, đặc biệt lấy mẫu, mức suy luận và giới hạn đầu ra.

Giữ cơ chế duyệt công cụ mặc định. Không cho dự án không đáng tin tự thực thi và không công khai ảnh cài đặt chứa khóa.

## Tham khảo chính thức

[Roo Code\: nhà cung cấp OpenAI Compatible](https\://roocodeinc.github.io/Roo-Code/providers/openai-compatible/).