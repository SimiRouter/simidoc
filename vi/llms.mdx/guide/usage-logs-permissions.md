# Quyền nhật ký sử dụng và nhật ký kiểm toán

Hướng dẫn này giải thích phạm vi hiển thị theo vai trò trong Nhật ký sử dụng và Nhật ký kiểm toán, cũng như cách xác định kênh thực tế đã xử lý yêu cầu.

## Nhật ký sử dụng

### Quản trị viên cấp cao

Quản trị viên cấp cao có thể xem đầy đủ nhật ký của mọi người dùng. Mở [Nhật ký sử dụng](https://api.dwchainless.com/usage-logs/common), chọn **Chỉ lỗi** trong bộ lọc loại để hiển thị các lần gọi lỗi của mọi người dùng. Bộ lọc vẫn giữ lỗi xảy ra trong lúc thử lại, ngay cả khi yêu cầu cuối cùng thành công.

Cột kênh cho biết kênh thực tế đã xử lý yêu cầu. Khi kiểm tra định tuyến, hãy dùng kênh, mô hình, trạng thái và ID yêu cầu trong nhật ký thay vì chỉ dựa vào tên mô hình hiển thị trong ứng dụng.

### Quản trị viên

Quản trị viên chỉ có thể xem nhật ký yêu cầu, nạp tiền, thao tác quản trị và lần gọi lỗi của chính mình. Tham số tên người dùng, vai trò hoặc URL không thể mở rộng phạm vi này. Quản trị viên không có bộ lọc **Chỉ lỗi** toàn cục, nhưng bản ghi lỗi của chính họ vẫn hiển thị theo quyền.

### Người dùng thông thường

Người dùng thông thường chỉ có thể xem nhật ký yêu cầu, nạp tiền và thao tác quản trị của chính mình. Họ không thể xem nhật ký lỗi hoặc nhật ký của người khác.

## Nhật ký kiểm toán

Quản trị viên cấp cao có thể xem sự kiện kiểm toán của mọi người dùng và lọc theo tên người dùng. Quản trị viên và người dùng thông thường chỉ xem được sự kiện của tài khoản đang xác thực; tham số trang không thể mở rộng quyền phía máy chủ.

## Cập nhật trạng thái kênh

Sự kiện kiểm toán `channel.status_update` có nghĩa là **cập nhật trạng thái kênh**. Sự kiện này ghi lại thao tác thủ công trên một kênh. Mã hiện tại chấp nhận trạng thái đích là bật hoặc tắt thủ công; `changed=false` nghĩa là yêu cầu thành công nhưng trạng thái kênh không thay đổi. Thao tác hàng loạt dùng `channel.status_update_batch`. Hãy xem chi tiết sự kiện, người thao tác và thời gian để biết thao tác cụ thể.

## Xử lý sự cố

1. Xác nhận khoảng thời gian và ID yêu cầu.
2. Khi điều tra lỗi toàn cục, quản trị viên cấp cao nên chọn **Chỉ lỗi**.
3. Kiểm tra kênh, mô hình và trạng thái thực tế thay vì chỉ dựa vào nhãn ứng dụng.
4. Với hết thời gian, phản hồi 5xx hoặc luồng bị ngắt, hãy xem nhật ký và ID yêu cầu trước khi thử lại để tránh tính phí trùng.