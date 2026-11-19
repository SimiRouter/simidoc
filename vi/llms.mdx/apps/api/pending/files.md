# Files API (không hỗ trợ)

Files API là giao diện quản lý tài nguyên tệp của OpenAI. Sau khi tải lên sẽ nhận ID tệp, có thể được tinh chỉnh, xử lý hàng loạt hoặc các điểm cuối chính thức khác chấp nhận ID tệp tham chiếu. Nó không đồng nghĩa với khả năng mô hình nhận dạng nội dung tệp.

**SimiRouter chưa hỗ trợ Files API. Trang giữ mô tả và ví dụ OpenAI trực tiếp, bắt buộc khóa dự án OpenAI.**

## Tổng quan

Files API giải quyết bài toán "tải lên một lần, tham chiếu nhiều lần"\: tệp tồn tại trước như một tài nguyên độc lập, sau đó được các điểm cuối như tinh chỉnh, xử lý hàng loạt lấy theo ID. Nó phù hợp với tập huấn luyện, thân yêu cầu xử lý hàng loạt và tư liệu cần đọc lặp lại; tệp đính kèm trong một cuộc hội thoại đơn lẻ không đi qua bộ giao diện này mà được truyền trực tiếp trong yêu cầu.

| Tình huống sử dụng                  | Dấu hiệu khi tải lên       | Sau khi tải lên còn phải làm gì                  |
| ----------------------------------- | -------------------------- | ------------------------------------------------ |
| Dữ liệu huấn luyện có giám sát      | `purpose=fine-tune`        | Tạo tác vụ huấn luyện và thăm dò trạng thái      |
| Yêu cầu hoặc đầu ra hàng loạt       | `purpose=batch`            | Tạo tác vụ xử lý hàng loạt và thăm dò trạng thái |
| Các điểm cuối khác chấp nhận ID tệp | Theo yêu cầu của điểm cuối | Lấy tài liệu của điểm cuối đó làm chuẩn          |

## Khái niệm cốt lõi

* **ID tệp và phạm vi**\: ID thuộc dự án hoặc tổ chức tạo ra nó, không thể dùng lại giữa các nhà cung cấp hoặc dự án; điền ID tệp của một dịch vụ khác vào yêu cầu OpenAI sẽ nhận 404 hoặc 403.
* **purpose quyết định mục đích**\: `purpose` khi tải lên cho biết dữ liệu dành cho ai dùng (như `fine-tune`, `batch`), các điểm cuối tiêu thụ còn tự kiểm tra định dạng, kích thước và số dòng.
* **Vòng đời**\: tải lên thành công chỉ có nghĩa tài nguyên đã tồn tại; huấn luyện hoặc xử lý hàng loạt đã hoàn tất hay chưa phải tra trạng thái tác vụ tương ứng, không thể dựa vào kết quả tải lên để phán đoán.
* **Tách nội dung và metadata**\: `filename`, `bytes`, `status` trong đối tượng tệp là metadata; nội dung mà mô hình nhìn thấy do điểm cuối tiêu thụ đọc, hai bên không tự động đồng bộ.

## Giao diện và cách thực thi

| Thao tác                                       | Yêu cầu chính thức                | Cách thực thi                                    |
| ---------------------------------------------- | --------------------------------- | ------------------------------------------------ |
| [Tải tệp lên (không hỗ trợ)](/simidoc/vi/apps/api/pending/files/upload)         | `POST /v1/files`                  | Tải lên multipart, trả về đối tượng tệp đồng bộ. |
| [Lấy thông tin tệp (không hỗ trợ)](/simidoc/vi/apps/api/pending/files/retrieve) | `GET /v1/files/{file_id}`         | Trả về metadata đồng bộ.                         |
| [Liệt kê tệp (không hỗ trợ)](/simidoc/vi/apps/api/pending/files/list)           | `GET /v1/files`                   | Truy vấn phân trang đồng bộ.                     |
| [Lấy nội dung tệp (không hỗ trợ)](/simidoc/vi/apps/api/pending/files/content)   | `GET /v1/files/{file_id}/content` | Tải byte tệp, không phải SSE của mô hình.        |
| [Xóa tệp (không hỗ trợ)](/simidoc/vi/apps/api/pending/files/delete)             | `DELETE /v1/files/{file_id}`      | Xóa tài nguyên, trả về kết quả xóa.              |

Tải tệp lên thành công không có nghĩa tác vụ tiêu thụ đã hoàn tất. Trạng thái xử lý của huấn luyện, xử lý hàng loạt và lập chỉ mục được truy vấn bởi từng điểm cuối riêng. Giới hạn về mục đích, định dạng và kích thước tệp cũng do điểm cuối tiêu thụ cùng quyết định.

## Tài nguyên và an toàn

ID tệp thuộc dự án hoặc tổ chức tạo ra nó, không thể dùng trực tiếp ID tệp của nhà cung cấp hoặc cổng kết nối khác cho OpenAI. Ví dụ đọc khóa qua biến môi trường; không được ghi tập huấn luyện, thông tin cá nhân hoặc khóa vào kho công khai.

## Tham khảo chính thức

* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files)
* [Tải tệp lên OpenAI](https\://developers.openai.com/api/reference/resources/files/methods/create)