# Thiết lập Claude Desktop

Dùng CC Switch **Ánh xạ mô hình** để chọn tên menu trong Claude Desktop, còn CC Switch chuyển yêu cầu tới mô hình thực tương ứng trên SimiRouter. Quy trình dùng macOS; tên giao diện có thể khác theo hệ thống hoặc phiên bản.

## Chuẩn bị

1. Cài và mở phiên bản Claude Desktop mới.
2. Cài [CC Switch](https\://github.com/farion1231/cc-switch/releases/latest) có hỗ trợ **Claude Desktop**, rồi mở.
3. Đăng nhập SimiRouter, tại [Quản lý khóa API](https://api.dwchainless.com/keys) tạo hoặc sao chép khóa hợp lệ. Xác nhận quyền dùng mô hình cần cấu hình.

<Callout type="info" title="">
  Khóa API là thông tin xác thực; giữ kín, không để trong ảnh công khai hay chia sẻ. Tên mô hình và quyền khả dụng theo bảng điều khiển SimiRouter.
</Callout>

## Cấu hình ánh xạ mô hình qua CC Switch

### 1. Thêm nhà cung cấp Claude Desktop tùy chỉnh

Ở bên trái CC Switch, chọn **Claude Desktop**, nhấp **Thêm nhà cung cấp** rồi chọn **Cấu hình tùy chỉnh**. Chọn Claude Desktop, không phải Claude Code.

![Thêm nhà cung cấp Claude Desktop tùy chỉnh trong CC Switch](/simidoc/assets/claude-desktop/cc-switch-add-provider.png)

### 2. Điền kết nối và ánh xạ mô hình

Điền tại trang cấu hình tùy chỉnh\:

| Trường                 | Giá trị                                                       |
| ---------------------- | ------------------------------------------------------------- |
| Tên                    | `SimiRouter` hoặc tên tùy chọn                                |
| API Key                | Khóa API SimiRouter vừa sao chép                              |
| Địa chỉ yêu cầu        | `https://api.dwchainless.com`, không thêm cuối `/` hoặc `/v1` |
| Kiểu kết nối           | Chọn **Ánh xạ mô hình**                                       |
| Định dạng thượng nguồn | Chọn **Anthropic Messages (gốc)**                             |

Trong **Ánh xạ mô hình**, điền “Tên hiển thị menu” và “Mô hình yêu cầu thực” cho từng vai trò cần dùng. Ví dụ\:

| Vai trò mô hình | Tên hiển thị menu   | Mô hình yêu cầu thực |
| --------------- | ------------------- | -------------------- |
| Sonnet          | `claude-sonnet-5-5` | `gpt-6-astra`        |
| Opus            | `claude-opus-5-5`   | `gpt-6-astra`        |
| Haiku           | `claude-haiku-5-5`  | `gpt-6.1-sol`        |

**Tên menu chỉ là nhãn trong Claude Desktop; mô hình thực được gọi nằm ở cột bên phải.** Ví dụ, khi chọn mục hiển thị `claude-sonnet-5-5`, ví dụ trên thực sự gọi `gpt-6-astra`, không phải Claude Sonnet. Thay bằng ID SimiRouter chính xác mà tài khoản được phép dùng; tên hiển thị có thể đặt dễ nhận biết. Danh sách vai trò thay đổi theo phiên bản.

Trong ảnh, tùy chọn `1M` chỉ khai báo khả năng ngữ cảnh cho ứng dụng. **Không sao chép trạng thái đã chọn một cách máy móc**; chỉ bật khi mô hình thực và giao diện cùng hỗ trợ. Điền xong nhấp **Thêm**.

![Hai cột ánh xạ CC Switch\: tên hiển thị menu và mô hình thực](/simidoc/assets/claude-desktop/cc-switch-model-mapping.png)

Khóa API trong ảnh đã ẩn; khi cấu hình hãy dùng khóa của bạn.

### 3. Kiểm tra và bật định tuyến

1. Trở lại danh sách, bên phải thẻ SimiRouter nhấp **… → Kiểm tra kết nối** để xem kết quả.
2. Sau khi kiểm tra thành công, nhấp nút bật (▶) bên phải thẻ SimiRouter và làm theo hướng dẫn. Thẻ hiển thị **Đang định tuyến** nghĩa là nhà cung cấp đã được chọn.
3. Giữ CC Switch và bộ định tuyến cục bộ chạy. Sau khi đổi định tuyến hoặc ánh xạ, thoát hoàn toàn rồi mở lại Claude Desktop để nạp cấu hình.

![Chọn Kiểm tra kết nối trong menu nhà cung cấp](/simidoc/assets/claude-desktop/cc-switch-test-connection.png)

![Nhà cung cấp SimiRouter hiển thị Đang định tuyến](/simidoc/assets/claude-desktop/cc-switch-routing.png)

### 4. Bật chế độ nhà phát triển Claude Desktop

Mở **Ứng dụng Claude Desktop** và chọn **Help → Troubleshooting → Enable Developer Mode** trên thanh menu trên cùng. Nếu đã bật, có thể bỏ qua.

![Bật chế độ nhà phát triển từ menu Help của Claude Desktop](/simidoc/assets/claude-desktop/claude-enable-developer-mode.png)

### 5. Kiểm tra cấu hình suy luận CC Switch

1. Mở menu tài khoản ở góc dưới bên trái Claude Desktop, chọn **Inference configuration** rồi mở **Configure third-party inference**.
2. Kiểm tra danh sách cấu hình ở góc trên bên phải, xác nhận chọn **CC Switch**. Nếu có nhiều cấu hình, chọn CC Switch. Trạng thái **applied** nghĩa là đã áp dụng; nếu còn thay đổi chưa áp dụng, nhấp theo hướng dẫn **Apply Changes**.
3. Trong **Connection**, tại trang nhấp **Test Connection**. Khi hiện thông báo xanh thành công, đóng cửa sổ cài đặt.

![Mở Inference configuration từ menu tài khoản](/simidoc/assets/claude-desktop/claude-inference-menu.png)

![Xác nhận hồ sơ suy luận bên thứ ba đã chọn và áp dụng CC Switch](/simidoc/assets/claude-desktop/claude-cc-switch-profile.png)

Khóa cổng trong ảnh đã ẩn; giữ giá trị CC Switch tự cấu hình, không xóa.

<Callout type="info" title="">
  Địa chỉ cổng trong CC Switch trỏ tới bộ định tuyến trên máy, khác địa chỉ SimiRouter ở bước 2; thường không cần sửa địa chỉ hay khóa cổng thủ công. Kiểm tra kết nối thành công không thay thế một lệnh gọi mô hình thật.
</Callout>

### 6. Chọn mô hình và xác minh

1. Tạo hội thoại, trong menu mô hình cạnh ô nhập chọn **Tên hiển thị menu** đã cấu hình và gửi tin nhắn ngắn. Lệnh gọi thật có thể phát sinh phí.
2. Sau khi nhận phản hồi, trong nhật ký SimiRouter đối chiếu thời điểm yêu cầu, **mô hình thực** và lượng sử dụng. Mô hình tự nhận danh tính hay tên hiển thị Claude Desktop không chứng minh mô hình thực được gọi.

## Câu hỏi thường gặp

### Không thấy Claude Desktop hoặc chế độ nhà phát triển

* Dùng CC Switch bản mới hỗ trợ Claude Desktop, ở bên trái chọn **Claude Desktop**.
* Trong Claude Desktop, mở **Help → Troubleshooting** rồi bật **Enable Developer Mode**; nếu không thấy mục, thử cập nhật ứng dụng.

### Không thấy cấu hình CC Switch hoặc mô hình chưa cập nhật

* Xác nhận thẻ SimiRouter hiển thị **Đang định tuyến** và giữ CC Switch cùng bộ định tuyến cục bộ chạy.
* Thoát hoàn toàn rồi mở lại Claude Desktop, kiểm tra ở góc dưới bên trái **Inference configuration** cấu hình. Một số phiên bản cũng có thể dùng **Developer → Configure third-party inference** để mở trang.
* Xác nhận ánh xạ đã điền tên hiển thị menu và đã chọn hồ sơ **CC Switch**. Khởi động lại Claude Desktop sau khi đổi ánh xạ hoặc nhà cung cấp.

### Kiểm tra kết nối hoặc trò chuyện thất bại

* Kiểm tra khóa CC Switch đầy đủ, hợp lệ và địa chỉ yêu cầu là `https://api.dwchainless.com`.
* Xác nhận đã chọn **Anthropic Messages (gốc)** làm định dạng thượng nguồn; kiểm tra mạng và bộ định tuyến cục bộ.
* Kiểm tra ID “Mô hình yêu cầu thực”, nhóm khóa và quyền mô hình, không chỉ tên menu.
* Theo lỗi để kiểm tra hạn mức và tương thích mô hình. Kiểm tra kết nối thành công không đảm bảo mọi mô hình hay chức năng đều dùng được.

## Cách cấu hình khác

### Tùy chọn\: cấu hình kết nối trực tiếp cũ

Các bước trực tiếp cũ được giữ lại nhưng chưa xác minh lại trên phiên bản hiện tại; trường và giao diện có thể đổi. Nếu đã dùng CC Switch bên trên, không cần lặp lại. Khả năng mô hình trong chế độ trực tiếp theo ứng dụng hỗ trợ thực tế.

Trước tiên bật chế độ nhà phát triển trong **Help → Troubleshooting** rồi\:

1. Trên thanh menu, chọn **Developer → Configure third-party inference**.
2. Điền theo bảng\:

| Trường                | Giá trị                                                                              |
| --------------------- | ------------------------------------------------------------------------------------ |
| Base URL              | `https://api.dwchainless.com`                                                        |
| API Key               | SimiRouter API Key của bạn, ví dụ `sk-...`                                           |
| Authentication method | Chọn `x-api-key`                                                                     |
| Provider / API format | Nếu có tùy chọn này, chọn `Anthropic-compatible`, `custom gateway` hoặc mục tương tự |

<Callout type="warn" title="">
  Base URL của Claude Desktop phải là `https://api.dwchainless.com`. Đây là địa chỉ cấu hình suy luận bên thứ ba của Claude Desktop; không sao chép trực tiếp cách đặt biến môi trường `ANTHROPIC_BASE_URL` từ hướng dẫn Claude CLI vào đây.
</Callout>

3. Chọn **Apply locally** để lưu cấu hình trên máy hiện tại.
4. Tiếp tục đăng nhập hoặc khởi động theo hướng dẫn của ứng dụng.

## Tham khảo chính thức

* [CC Switch\: hướng dẫn cấu hình Claude Desktop](https\://github.com/farion1231/cc-switch-website/blob/main/public/docs/en/2-providers/2.6-claude-desktop.md)
* [Anthropic Docs\: Thiết lập Claude Cowork với nền tảng bên thứ ba](https\://claude.com/docs/third-party/claude-desktop/overview)