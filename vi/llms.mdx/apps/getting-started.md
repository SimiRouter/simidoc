# Tạo khóa SimiRouter

Hướng dẫn đăng ký, đăng nhập, tạo khóa và gọi lần đầu. Người có tài khoản đăng nhập trực tiếp; thao tác ứng dụng và tham số API nằm trong tài liệu tương ứng.

## 1. Đăng ký hoặc đăng nhập SimiRouter

Truy cập [Trang đăng ký](https://api.dwchainless.com/sign-up) để tạo tài khoản; người có tài khoản có thể [Đăng nhập](https://api.dwchainless.com/sign-in). Phương thức và việc mở đăng ký theo trang hiện tại.

Đăng nhập và mở [Ví](https://api.dwchainless.com/wallet), xác nhận đủ hạn mức và mô hình nằm trong quyền nhóm tài khoản, khóa. Khi cần nạp hoặc dùng mã đổi, làm theo hướng dẫn trên trang ví; gói, hạn mức nhận và thời hạn hiển thị tại đó. Không thanh toán trùng.

## 2. Tạo khóa API

Mở [Quản lý khóa API](https://api.dwchainless.com/keys) rồi chọn “Tạo khóa”. Đặt nhóm, quyền mô hình, hạn mức, thời hạn theo nhu cầu; đọc mô tả tùy chọn chưa rõ trước khi lưu và sao chép.

![Trang quản lý khóa API và mục tạo khóa](/simidoc/assets/start/start5.png)

<Callout type="warn" title="Bảo vệ khóa">
  Khóa API cấp quyền gọi. Không để trong kho công khai, ảnh hay nhật ký, không gửi cho ứng dụng không tin cậy. Thu hồi và tạo lại ngay nếu nghi lộ.
</Callout>

## 3. Phân biệt ba thông tin kết nối

| Thông tin              | Mục đích                   | Lưu ý                                                                                           |
| ---------------------- | -------------------------- | ----------------------------------------------------------------------------------------------- |
| Địa chỉ API / Base URL | Quyết định nơi gửi yêu cầu | Theo hướng dẫn ứng dụng; một số cần `/v1`, số khác cần địa chỉ gốc. Không thêm trùng đường dẫn. |
| API Key                | Xác thực quyền gọi         | Dùng khóa vừa tạo, không phải mật khẩu đăng nhập.                                               |
| Tên mô hình            | Chọn mô hình gọi           | Trong [Danh mục mô hình](https://api.dwchainless.com/vi/pricing/) để sao chép ID đầy đủ; tên, nhóm và quyền phải khớp.         |

Địa chỉ, khóa và tên mô hình là ba trường độc lập; không ghép khóa vào URL.

## 4. Chọn ứng dụng đang dùng

* [Codex desktop](/simidoc/vi/apps/codex-desktop)\: quy trình lập trình desktop.
* [Codex CLI](/simidoc/vi/apps/installation/codex-cli)\: cài và kết nối dòng lệnh.
* [Claude Code](/simidoc/vi/apps/installation/claude-code)\: cài đặt, môi trường và sử dụng.
* [WorkBuddy](/simidoc/vi/apps/workbuddy)\: mô hình tùy chỉnh desktop.
* [Tập lệnh API](/simidoc/vi/apps/api-script)\: tích hợp chương trình riêng qua ví dụ yêu cầu.

Mỗi ứng dụng có trường và giao thức khác nhau. Theo hướng dẫn riêng, không dùng nguyên tệp cấu hình của ứng dụng khác.

## 5. Thử quy mô nhỏ và đối chiếu nhật ký

Sau khi lưu cấu hình, gửi yêu cầu ngắn rồi mở [Nhật ký sử dụng](https://api.dwchainless.com/usage-logs/common) để kiểm tra thời gian, mô hình, trạng thái và mức dùng. Quản trị viên cấp cao xem được nhật ký toàn cục; quản trị viên xem được yêu cầu, nạp tiền, thao tác quản lý và lỗi của mình; người dùng thường chỉ xem yêu cầu, nạp tiền và thao tác quản lý của mình, không xem được nhật ký lỗi. Xem xu hướng tại [Bảng dữ liệu](https://api.dwchainless.com/dashboard).

Mô hình trả lời chỉ chứng minh yêu cầu đã có kết quả, không xác nhận định tuyến thực. Khi lỗi, kiểm tra địa chỉ, khóa, ID đầy đủ và quyền nhóm rồi chẩn đoán bằng lỗi, ID yêu cầu. Chỉ gửi hỗ trợ dữ liệu đã che, không kèm khóa.