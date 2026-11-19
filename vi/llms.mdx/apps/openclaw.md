# Cấu hình OpenClaw

## Chuẩn bị

1. Đã cài OpenClaw và khởi động bình thường.
2. Đã tạo API Key khả dụng trong bảng điều khiển SimiRouter.
3. Đã cài CC Switch.

<Callout type="info" title="">
  Nếu chưa cài CC Switch, hãy đọc [hướng dẫn cài đặt và nhập cấu hình CC Switch](/simidoc/vi/apps/cc-switch).
</Callout>

## Cấu hình OpenClaw trong CC Switch

1. Trong CC Switch, chọn **OpenClaw** ở danh sách ứng dụng bên trái; bản cũ dùng tab phía trên.

![Chuyển sang OpenClaw ở đầu CC Switch](/simidoc/assets/cc/cc1.png)

2. Nhấp **Thêm** để thêm nhà cung cấp tùy chỉnh.

![Thêm và điền thông số nhà cung cấp](/simidoc/assets/cc/cc2.png)

3. Lưu và xác nhận nhà cung cấp đã được bật. Chạy `openclaw onboard` trong terminal, rồi làm theo hướng dẫn để hoàn tất cấu hình ban đầu và ghép nối.

![Lưu và bật nhà cung cấp](/simidoc/assets/cc/cc4.png)

4. Gửi tin nhắn ngắn, xác nhận nhận được phản hồi bình thường, rồi đối chiếu bản ghi yêu cầu tương ứng trong bảng điều khiển SimiRouter. Chỉ thấy màn hình cấu hình hoặc khung đỏ trong ảnh chưa chứng minh đã kết nối mô hình thành công.![Lưu và bật nhà cung cấp](/simidoc/assets/cc/cc3.png)

## Câu hỏi thường gặp

* `baseUrl` thiếu `/v1`\: nguyên nhân thường gặp nhất khiến danh sách mô hình không trả về.
* ID mô hình không khớp\: tên phải khớp hoàn toàn với mô hình thực tế được cung cấp.
* Vẫn lỗi xác thực hoặc không khả dụng\: kiểm tra API Key và nhà cung cấp thuộc cùng môi trường.
* Để xem nhật ký chi tiết, chạy tiền cảnh `openclaw gateway --port 18789`.

## Tham khảo chính thức

[Dự án chính thức CC Switch](https\://github.com/farion1231/cc-switch).