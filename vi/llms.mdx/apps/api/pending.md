# Khả năng khác và tham khảo chờ tích hợp

Mục này tập hợp các giao diện chưa được mở như khả năng chung của SimiRouter\: nhúng, tệp, tinh chỉnh, Realtime, kiểm duyệt và xếp hạng lại. Khác biệt giữa chúng với các khả năng đã mở không nằm ở độ khó giao thức, mà ở việc cổng kết nối có cung cấp định tuyến, xác thực và tính phí hay không.

## Tổng quan

Hãy xem trạng thái trước, rồi mới quyết định có viết mã hay không. Cùng nằm trong mục này không có nghĩa là cùng trạng thái.

| Trạng thái            | Ý nghĩa                                                                                | Hiện tại có thể làm gì                                                                      |
| --------------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Rõ ràng không hỗ trợ  | Cổng kết nối không cung cấp khả năng này và cũng sẽ không khả dụng chỉ vì đổi tên miền | Chỉ có thể tham khảo theo cách kết nối trực tiếp của hãng, dùng khóa của hãng               |
| Tạm thời không hỗ trợ | Hiện chưa mở, bản thân giao thức ổn định                                               | Xác minh theo tham khảo kết nối trực tiếp của hãng, đừng viết như lệnh gọi qua cổng kết nối |
| Cần xác nhận kênh     | Khả dụng phụ thuộc cấu hình tài khoản và kênh                                          | Xác nhận mô hình và định tuyến trước, rồi mới quyết định có phụ thuộc hay không             |

## Khái niệm cốt lõi

* **Tham khảo kết nối trực tiếp**\: địa chỉ và xác thực trong ví dụ của mục này thuộc về hãng. Đổi `api.openai.com` thành tên miền cổng kết nối không có nghĩa là khả năng khả dụng; đường dẫn, ánh xạ trường và quyền đều cần kênh hỗ trợ rõ ràng.
* **Thuộc về khóa**\: khóa của hãng và khóa SimiRouter không tương thích. Ví dụ kết nối trực tiếp phải dùng khóa của hãng tương ứng, không được điền khóa cổng kết nối vào.
* **Thuộc về tài nguyên**\: ID tệp, ID tác vụ, ID phiên đều do dự án hoặc tổ chức tạo ra chúng nắm giữ, không thể dùng lại trực tiếp giữa các hãng hoặc dự án.
* **Trạng thái và tính phí**\: tác vụ bất đồng bộ trả về ID trước, rồi mới truy vấn trạng thái; tạo thành công không đồng nghĩa thực thi thành công, hủy tác vụ cũng không có nghĩa mức dùng đã phát sinh được hoàn lại.

## Danh sách khả năng

| Phân loại    | Trạng thái SimiRouter              | Bản chất giao thức                                           | Tham khảo                            |
| ------------ | ---------------------------------- | ------------------------------------------------------------ | ------------------------------------ |
| Nhúng        | Tạm thời không hỗ trợ              | Trả vector đồng bộ, tác vụ lô độc lập                        | [Nhúng](/simidoc/vi/apps/api/pending/embeddings)                |
| Quản lý tệp  | Không hỗ trợ                       | Tải lên, danh sách, metadata, tải xuống và xóa               | [Tệp](/simidoc/vi/apps/api/pending/files)                       |
| Tinh chỉnh   | Không hỗ trợ                       | Tạo tác vụ huấn luyện bất đồng bộ, trạng thái và sự kiện     | [Tinh chỉnh](/simidoc/vi/apps/api/pending/fine-tuning)          |
| Realtime     | Cần xác nhận kênh chuyên dụng      | Phiên trạng thái WebRTC / WebSocket                          | [Realtime](/simidoc/vi/apps/api/pending/realtime)               |
| Kiểm duyệt   | Cần xác nhận mô hình và định tuyến | Phân loại an toàn đồng bộ, không phải bảo đảm lọc trò chuyện | [Kiểm duyệt nội dung](/simidoc/vi/apps/api/pending/moderations) |
| Xếp hạng lại | Cần xác nhận mô hình và định tuyến | Xếp hạng mức liên quan tài liệu đồng bộ                      | [Xếp hạng lại](/simidoc/vi/apps/api/pending/rerank)             |

Giao diện âm nhạc xem thêm [Âm nhạc (không hỗ trợ)](/simidoc/vi/apps/api/music). Phiên thời gian thực, tài nguyên tải lên và tác vụ huấn luyện thường liên quan đến quyền, lưu trữ và chi phí bổ sung; trước khi tích hợp ứng dụng nên xác định rõ chính sách lưu giữ và xóa dữ liệu.