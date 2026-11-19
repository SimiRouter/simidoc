# Cấu hình Cherry Studio

Cherry Studio là ứng dụng AI desktop hỗ trợ nhiều nhà cung cấp. Các bước sau dùng khóa API SimiRouter.

* Trang chính thức\: [https\://cherry-ai.com](https\://cherry-ai.com/)
* Tải xuống\: [https\://cherry-ai.com/download](https\://cherry-ai.com/download)
* Tài liệu chính thức\: [https\://docs.cherry-ai.com](https\://docs.cherry-ai.com)

## Kết nối SimiRouter

### Cách 1\: Mở từ trang khóa

1. Cài và mở Cherry Studio, tìm khóa muốn dùng trên trang SimiRouter [Quản lý khóa API](https://api.dwchainless.com/keys).
2. Nhấp bên phải khóa **…** rồi chọn **Cherry Studio** và cho phép trình duyệt mở ứng dụng.
3. Trong Cherry Studio, kiểm tra địa chỉ API, khóa và mô hình đã nhập. Địa chỉ phải là `https://api.dwchainless.com`. Lưu rồi chọn mô hình tài khoản được phép dùng.

### Cách 2\: Cấu hình thủ công

1. Mở [Quản lý khóa API](https://api.dwchainless.com/keys) để sao chép khóa API; cũng có thể lấy địa chỉ qua “Sao chép thông tin kết nối” trong **…** bên phải khóa.
2. Mở Cherry Studio **Cài đặt → Dịch vụ mô hình** rồi chọn **New API**. Điền địa chỉ API `https://api.dwchainless.com` và dán khóa vừa sao chép.
3. Nhấp “Quản lý” để thêm hoặc chọn mô hình khả dụng, bật nhà cung cấp rồi quay lại trò chuyện.

![Minh họa cài địa chỉ API và khóa Cherry Studio](/simidoc/assets/cherry_studio/simirouter-provider.png)

<Callout type="warn" title="Bảo vệ khóa">
  Không để khóa trong ảnh công khai hoặc chia sẻ với ứng dụng không đáng tin. Sau tin nhắn thử ngắn, đối chiếu mô hình và lệnh gọi trong nhật ký SimiRouter.
</Callout>

## Vẽ ảnh trong Cherry Studio

1. Thêm mô hình tạo ảnh mà tài khoản được phép dùng và Cherry Studio hỗ trợ định dạng API.![Trang thêm mô hình tạo ảnh Cherry Studio](/simidoc/assets/cherry_studio/add_paint_models.png)

2. Chọn mô hình trên trang tạo ảnh, nhập lời nhắc rồi kiểm tra kết quả.![Trang tạo ảnh Cherry Studio và ô lời nhắc](/simidoc/assets/cherry_studio/paint.png)