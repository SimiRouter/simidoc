# Cấu hình Hermes

## Chuẩn bị

1. Đã cài Hermes và khởi động bình thường.
2. Đã tạo API Key khả dụng trong bảng điều khiển SimiRouter.
3. Đã cài CC Switch.

<Callout type="info" title="">
  Nếu chưa cài CC Switch, hãy đọc [hướng dẫn cài đặt và nhập cấu hình CC Switch](/simidoc/vi/apps/cc-switch).
</Callout>

## Cấu hình Hermes trong CC Switch

1. Trong CC Switch, chọn **Hermes** ở danh sách ứng dụng bên trái; bản cũ dùng tab phía trên.

![Chọn thẻ Hermes trong CC Switch](/simidoc/assets/hermers/h1.png)

2. Nhấp **Thêm**, thêm nhà cung cấp tùy chỉnh, sau đó quay lại thẻ Hermes và chọn bật.

![Thêm và điền thông số nhà cung cấp](/simidoc/assets/hermers/h2.png)

3. Mở terminal, nhập `hermes desktop` để chạy ứng dụng desktop rồi gửi tin nhắn thử ngắn.`--skip-build` chỉ dành môi trường phát triển đã có bản dựng desktop, không dùng lần khởi chạy đầu.

![Lưu và bật nhà cung cấp](/simidoc/assets/hermers/h4.png)

4. Bạn cũng có thể chạy `hermes --tui` trong terminal để dùng chế độ TUI. Gửi tin nhắn ngắn và đối chiếu bản ghi yêu cầu tương ứng trong bảng điều khiển SimiRouter; chỉ mở được TUI chưa chứng minh đã kết nối mô hình thành công.

![Lưu và bật nhà cung cấp](/simidoc/assets/hermers/h5.png)

## Câu hỏi thường gặp

* `baseUrl` thiếu `/v1`\: nguyên nhân thường gặp nhất khiến danh sách mô hình không trả về.
* ID mô hình không khớp\: tên phải khớp hoàn toàn với mô hình thực tế được cung cấp.
* Vẫn lỗi xác thực hoặc không khả dụng\: kiểm tra API Key và nhà cung cấp thuộc cùng môi trường.

## Tham khảo chính thức

[Tham khảo CLI Hermes desktop](https\://hermes-agent.nousresearch.com/docs/user-guide/desktop#cli-reference-hermes-desktop).