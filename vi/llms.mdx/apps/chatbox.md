# Cấu hình Chatbox AI

Hướng dẫn dùng giao diện desktop Chatbox AI 1.21.1 và nhà cung cấp tích hợp **OpenAI** để kết nối SimiRouter. Tên và vị trí có thể khác theo phiên bản; ảnh bên dưới minh họa giao diện tiếng Trung.

<Callout type="warn" title="Bảo vệ khóa API">
  Khóa API là thông tin xác thực; không chia sẻ hay để lộ trong ảnh công khai. Kiểm tra kết nối và trò chuyện có thể phát sinh phí; hãy xác nhận hạn mức và giá mô hình trước.
</Callout>

## Chuẩn bị

1. Truy cập [Trang chính thức Chatbox AI](https\://chatboxai.app/) để tải và cài ứng dụng.
2. Đăng nhập SimiRouter, tại [Quản lý khóa API](https://api.dwchainless.com/keys) tạo hoặc sao chép khóa và xác nhận quyền cùng hạn mức dùng mô hình mục tiêu.

![Trang quản lý khóa API SimiRouter với thông tin khóa đã che](/simidoc/assets/chatbox/03a-create-api-key.png)

## Cấu hình kết nối

### 1. Mở cài đặt và chọn nhà cung cấp

Trong cửa sổ Chatbox, nhấp ở góc dưới bên trái **Cài đặt**.

![Mở cài đặt Chatbox](/simidoc/assets/chatbox/01-open-settings.png)

Mở **Nhà cung cấp mô hình** rồi chọn **OpenAI**. Hướng dẫn dùng khóa API, không cần OAuth. Thao tác thay đổi cấu hình nhà cung cấp OpenAI; hãy ghi lại cấu hình cũ nếu đang kết nối dịch vụ khác để tránh ghi đè.

![Chọn OpenAI trong nhà cung cấp mô hình](/simidoc/assets/chatbox/02-select-openai.png)

### 2. Nhập khóa API và máy chủ

| Mục cấu hình              | Giá trị                                           |
| ------------------------- | ------------------------------------------------- |
| Khóa API                  | Dán khóa SimiRouter vừa sao chép                  |
| Máy chủ API               | `https://api.dwchainless.com`                     |
| Xem trước địa chỉ yêu cầu | `https://api.dwchainless.com/v1/chat/completions` |

Điền máy chủ như bảng và giữ đường dẫn API mặc định; không nối thêm đường dẫn giao diện. Nếu từng tùy chỉnh đường dẫn, khôi phục mặc định rồi kiểm tra địa chỉ xem trước.

![Nhập khóa API và máy chủ cho nhà cung cấp OpenAI](/simidoc/assets/chatbox/03b-fill-api-fields.png)

### 3. Lấy và thêm mô hình

Trong phần mô hình, nhấp **Lấy**, tìm rồi nhấp bên phải mô hình **+** để thêm. Nếu không lấy được danh sách, dùng **Tạo mới** để nhập chính xác ID khả dụng. Không phải mọi mô hình trong danh sách đều được mở cho khóa hiện tại; kiểm tra quyền tài khoản.

![Tìm và thêm mô hình](/simidoc/assets/chatbox/04-add-models.png)

### 4. Kiểm tra kết nối và trò chuyện

Với mô hình muốn dùng, nhấp **Kiểm tra**. Dù báo “Kết nối thành công”, hãy gửi tin nhắn ngắn để xác minh hội thoại thật. Một số mô hình chỉ hỗ trợ văn bản; kiểm tra ảnh hay công cụ thất bại không nhất thiết khiến văn bản không dùng được.

![Kết quả kiểm tra kết nối mô hình ví dụ](/simidoc/assets/chatbox/05-check-success.png)

Đóng cài đặt, nhấp **Hội thoại mới**, chọn mô hình vừa thêm thuộc nhóm OpenAI cạnh ô nhập và gửi tin nhắn ngắn. Sau khi nhận phản hồi, đối chiếu yêu cầu và mô hình thực trong nhật ký SimiRouter.

![Tạo hội thoại và chọn mô hình vừa thêm](/simidoc/assets/chatbox/06-new-chat-select-model.png)

## Câu hỏi thường gặp

* **Không lấy được mô hình\:** Kiểm tra mạng, máy chủ và khóa; hoặc thêm thủ công ID chính xác.
* **401 hoặc lỗi xác thực\:** Kiểm tra khóa đầy đủ, hợp lệ, không có khoảng trắng; tạo lại nếu cần.
* **404 hoặc lỗi đường dẫn\:** Kiểm tra địa chỉ xem trước, khôi phục đường dẫn mặc định để tránh nối trùng.
* **Không có mô hình hoặc không trò chuyện được\:** Kiểm tra ID thực, quyền khóa, hạn mức và mô hình đã chọn.
* **Ảnh hoặc công cụ thất bại\:** Kiểm tra mô hình và giao diện có hỗ trợ không; nếu chỉ cần văn bản, thử riêng yêu cầu văn bản.

Tham khảo\: [Xử lý địa chỉ và đường dẫn OpenAI trong Chatbox](https\://github.com/chatboxai/chatbox/blob/main/src/shared/utils/llm_utils.ts).