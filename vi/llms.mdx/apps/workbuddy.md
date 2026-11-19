# Hướng dẫn WorkBuddy

<Callout type="info" title="Phạm vi">
  Dành cho WorkBuddy desktop có chức năng “Cấu hình mô hình tùy chỉnh”. Mục và cài đặt có thể khác theo phiên bản; theo giao diện thực tế.
</Callout>

## Điều kiện tiên quyết

Trước khi cấu hình, xác nhận\:

* Đã cài, chạy WorkBuddy và thấy mục “Cấu hình mô hình tùy chỉnh”.
* Đã đăng ký SimiRouter và tạo khóa trên trang “Khóa API” của bảng điều khiển.
* Đã xác định ID mô hình đầy đủ, khóa có quyền truy cập và hạn mức.

[Mở quản lý khóa API](https\://api.dwchainless.com/keys)

## Các bước cấu hình

### 1. Mở “Cấu hình mô hình tùy chỉnh”

Trong hội thoại WorkBuddy, nhấp tên mô hình góc dưới bên phải ô nhập rồi chọn **“Cấu hình mô hình tùy chỉnh”**.

![Mở “Cấu hình mô hình tùy chỉnh” từ danh sách](/simidoc/assets/workbuddy/open-custom-model.png)

Trên trang quản lý, nhấp **“Thêm mô hình”**. Nếu hộp thoại đã mở, sang bước tiếp theo.

### 2. Đặt nhà cung cấp thành “Tùy chỉnh”

Trong cửa sổ thêm mô hình, mở danh sách **“Nhà cung cấp”**, cuộn xuống nhóm “Khác” và chọn **“Tùy chỉnh”**.

![Chọn “Tùy chỉnh” trong nhóm “Khác” của danh sách](/simidoc/assets/workbuddy/select-custom-provider.png)

Xác nhận trường nhà cung cấp hiển thị **“Tùy chỉnh”**.

### 3. Điền địa chỉ, khóa API và tên mô hình

Điền thông tin cơ bản\:

| Mục cấu hình | Giá trị                                           |
| ------------ | ------------------------------------------------- |
| Nhà cung cấp | Tùy chỉnh                                         |
| Địa chỉ API  | `https://api.dwchainless.com/v1/chat/completions` |
| API Key      | Khóa API tạo trong SimiRouter                     |
| Tên mô hình  | ID mô hình đầy đủ muốn gọi                        |

**Địa chỉ API\:** Sao chép toàn bộ địa chỉ trong bảng, giữ phần cuối `/v1/chat/completions`.

\*\*API Key\: \*\* Chỉ dán khóa, không thêm `Bearer`, dấu ngoặc kép hay chú thích; xóa khoảng trắng đầu cuối.

**Tên mô hình\:** Sao chép ID đầy đủ từ mô hình SimiRouter hiện có, không dùng mô tả tiếng Trung, biệt danh hay tên dòng chưa đầy đủ. Xác nhận khóa được gọi mô hình đó.

### 4. Đặt tùy chọn nâng cao

Lần đầu nên giữ mặc định đầu vào, đầu ra; tùy chọn khác theo khả năng mô hình và kênh.

| Mục cấu hình          | Cài đặt khuyến nghị                                                                          |
| --------------------- | -------------------------------------------------------------------------------------------- |
| Gọi công cụ           | Chỉ bật khi cần tác vụ công cụ và cả mô hình, kênh đều hỗ trợ.                               |
| Đầu vào ảnh           | Bật khi cần xử lý ảnh và mô hình cùng kênh hỗ trợ.                                           |
| Chế độ suy nghĩ       | Theo hướng dẫn mô hình; lần đầu có thể để tắt.                                               |
| Giao thức tùy chỉnh   | Để tắt nếu không có yêu cầu rõ ràng.                                                         |
| Mức suy luận (nếu có) | Giữ mặc định ban đầu, chỉ chỉnh khi có nhu cầu cụ thể.                                       |
| Đầu vào / đầu ra      | Giữ “Dùng mặc định nhà cung cấp”; trước khi sửa thủ công, kiểm tra giới hạn mô hình và kênh. |

![Biểu mẫu mô hình tùy chỉnh\: địa chỉ, khóa, tên và tùy chọn nâng cao](/simidoc/assets/workbuddy/custom-model-form.png)

*Ảnh minh họa nhãn tiếng Trung. Điền khóa riêng và ID mô hình thực theo hướng dẫn.*

### 5. Kiểm tra, lưu và chọn mô hình

Điền xong nhấp **“Kiểm tra kết nối”** để kiểm tra, rồi nhấp **“Lưu”**. Nếu thất bại, xem phần vấn đề thường gặp bên dưới.

Trở lại hội thoại WorkBuddy, mở danh sách mô hình góc dưới bên phải. **Chọn mô hình tùy chỉnh vừa thêm** rồi gửi tin nhắn ngắn, ví dụ\:

```text
请只回复：连接成功。
```

Sau phản hồi bình thường, đối chiếu thời gian và mô hình trong nhật ký SimiRouter.

Khi trò chuyện cơ bản hoạt động, thử riêng công cụ, ảnh hoặc chế độ suy nghĩ cần dùng.

## Câu hỏi thường gặp

Đọc toàn bộ thông báo lỗi trước, sau đó theo bảng.

| Vấn đề                                     | Cách chẩn đoán                                                                        |
| ------------------------------------------ | ------------------------------------------------------------------------------------- |
| Không có “Cấu hình mô hình tùy chỉnh”      | Kiểm tra phiên bản có hỗ trợ và đã mở danh sách mô hình góc dưới bên phải hội thoại.  |
| Kiểm tra hoặc gửi tin thất bại             | Theo lỗi, kiểm tra từng mục địa chỉ, khóa, ID mô hình, quyền và hạn mức.              |
| Đã lưu nhưng hội thoại vẫn dùng mô hình cũ | Trở lại hội thoại và chọn mô hình tùy chỉnh vừa lưu.                                  |
| Lỗi sau khi bật ảnh hoặc suy nghĩ          | Khôi phục cấu hình hoạt động gần nhất, rồi kiểm tra mô hình và kênh hỗ trợ tính năng. |
| Lỗi hội thoại hoặc đầu ra dài              | Kiểm tra giới hạn mô hình và kênh; rút ngắn đầu vào hoặc giảm đầu ra theo lỗi.        |

Khi cần hỗ trợ, cung cấp **Phiên bản WorkBuddy, ID mô hình, thời điểm yêu cầu và toàn bộ lỗi**.

<Callout type="warn" title="Bảo mật khóa">
  Giữ kín khóa. Che toàn bộ khóa trước khi gửi ảnh, nhật ký hoặc lỗi; không chia sẻ công khai.
</Callout>

## Tham khảo chính thức

[Cấu hình mô hình tùy chỉnh WorkBuddy](https\://www.codebuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Model).