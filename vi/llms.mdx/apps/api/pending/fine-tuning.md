# Tinh chỉnh (không hỗ trợ)

Tinh chỉnh mô hình điều chỉnh hành vi của mô hình nền thông qua dữ liệu huấn luyện, tạo ra mô hình mới có thể dùng để suy luận. OpenAI cung cấp các phương pháp như tinh chỉnh có giám sát, tối ưu hóa sở thích trực tiếp (DPO) và tinh chỉnh tăng cường; phương pháp khả dụng phụ thuộc vào mô hình nền được chọn.

**SimiRouter chưa hỗ trợ tinh chỉnh. Giữ tài liệu và ví dụ chính thức trực tiếp, cần khóa dự án OpenAI; có thể tính phí.**

OpenAI đang dần dừng tinh chỉnh tự phục vụ\: người dùng mới không thể tạo tác vụ huấn luyện, còn người dùng hiện hữu đủ điều kiện có thể tạo tác vụ đến **ngày 6 tháng 1 năm 2027**, trừ khi mô hình nền ngừng hoạt động sớm hơn. Mô hình đã tinh chỉnh chỉ tiếp tục suy luận đến khi mô hình nền bị ngừng. Điều kiện, mô hình và mốc thời gian có thể thay đổi; hãy xem [lịch ngừng hỗ trợ chính thức](https\://developers.openai.com/api/docs/deprecations) trước khi sử dụng.

## Tổng quan

Tinh chỉnh thay đổi trọng số mô hình, không phải lời nhắc. Nó phù hợp với ràng buộc định dạng ổn định, giọng điệu cố định và cách diễn đạt chuyên ngành; không phù hợp để đưa vào kiến thức thay đổi liên tục — nhu cầu đó dùng truy xuất hoặc lời nhắc hệ thống dài hơn sẽ có chi phí thấp hơn. Để xác minh hiệu quả bắt buộc phải dùng mẫu độc lập không tham gia huấn luyện.

| Việc bạn cần làm                   | Đầu vào                            | Đầu ra                                 | Cách thực thi                       |
| ---------------------------------- | ---------------------------------- | -------------------------------------- | ----------------------------------- |
| Huấn luyện một mô hình chuyên dụng | Tập huấn luyện JSONL + mô hình nền | Đối tượng tác vụ và `fine_tuned_model` | Nền bất đồng bộ, thăm dò trạng thái |
| Quan sát quá trình huấn luyện      | ID tác vụ                          | Nhật ký sự kiện và chỉ số              | Truy vấn phân trang, không phải SSE |
| Dừng huấn luyện                    | ID tác vụ                          | Đối tượng tác vụ đã hủy                | Yêu cầu đồng bộ                     |

## Khái niệm cốt lõi

* **Mô hình nền**\: quyết định phương pháp và giá khả dụng. Các mô hình nền khác nhau hỗ trợ phương pháp và tham số khác nhau; chọn sai phương pháp sẽ bị từ chối khi tạo tác vụ.
* **Tập huấn luyện và tập kiểm định**\: JSONL, mỗi dòng một mẫu hội thoại; tối thiểu chính thức là 10 dòng, thường bắt đầu từ 50 dòng, 50 đến 100 dòng thường thấy cải thiện rõ rệt. Tập kiểm định phải chuẩn bị riêng, không được trùng với tập huấn luyện.
* **Trạng thái tác vụ**\: `queued`, `running`, `succeeded`, `failed`, `cancelled`. Chỉ `succeeded` mới tạo ra mô hình mới có thể suy luận; `failed` phải đọc `error` để xác định là vấn đề dữ liệu hay vấn đề tham số.
* **Mô hình đầu ra**\: sau khi thành công trả về định danh `fine_tuned_model`, dùng nó thay cho mô hình nền để phát khởi suy luận. Mô hình có vòng đời độc lập, tự xóa khi cần.
* **Chi phí**\: huấn luyện tính phí theo Token, mô hình đầu ra có thể phát sinh phí lưu trữ trong thời gian lưu giữ; chạy thử bằng mẫu nhỏ rồi mở rộng sẽ kiểm soát tốt hơn việc gửi toàn bộ dữ liệu một lần.

## Giao diện và cách thực thi

| Thao tác                                         | Yêu cầu chính thức                                      | Cách thực thi                                        |
| ------------------------------------------------ | ------------------------------------------------------- | ---------------------------------------------------- |
| [Tạo tác vụ (không hỗ trợ)](/simidoc/vi/apps/api/pending/fine-tuning/create)            | `POST /v1/fine_tuning/jobs`                             | Trả về đối tượng tác vụ, huấn luyện nền bất đồng bộ. |
| [Lấy chi tiết tác vụ (không hỗ trợ)](/simidoc/vi/apps/api/pending/fine-tuning/retrieve) | `GET /v1/fine_tuning/jobs/{fine_tuning_job_id}`         | Truy vấn đồng bộ trạng thái, mô hình đầu ra và lỗi.  |
| [Liệt kê tác vụ (không hỗ trợ)](/simidoc/vi/apps/api/pending/fine-tuning/list)          | `GET /v1/fine_tuning/jobs`                              | Truy vấn phân trang đồng bộ.                         |
| [Lấy sự kiện tác vụ (không hỗ trợ)](/simidoc/vi/apps/api/pending/fine-tuning/events)    | `GET /v1/fine_tuning/jobs/{fine_tuning_job_id}/events`  | Nhật ký phân trang, không phải SSE.                  |
| [Hủy tác vụ (không hỗ trợ)](/simidoc/vi/apps/api/pending/fine-tuning/cancel)            | `POST /v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel` | Dừng tác vụ và trả về đối tượng tác vụ.              |

## Quy trình cơ bản

1. Chuẩn bị tập huấn luyện JSONL theo phương pháp tinh chỉnh đã chọn, chuẩn bị tập kiểm định riêng.
2. Tải dữ liệu lên qua [giao diện tải tệp chính thức](/simidoc/vi/apps/api/pending/files/upload) với `purpose=fine-tune`.
3. Chọn mô hình hỗ trợ phương pháp đó, tạo tác vụ và lưu ID tác vụ.
4. Truy vấn trạng thái và sự kiện tác vụ; `succeeded` biểu thị thành công, `failed` cần đọc `error`, `cancelled` biểu thị đã hủy.
5. Sau khi huấn luyện thành công, dùng `fine_tuned_model` được trả về để suy luận, và xác minh hiệu quả bằng tập đánh giá độc lập.

Tạo yêu cầu thành công không đồng nghĩa huấn luyện thành công; hủy tác vụ cũng không có nghĩa mức dùng đã phát sinh được hoàn lại. Đừng trực tiếp tạo lặp lại cùng một tác vụ huấn luyện chỉ vì mạng quá thời gian.

## Tham khảo chính thức

* [Hướng dẫn tối ưu hóa mô hình OpenAI](https\://developers.openai.com/api/docs/guides/model-optimization)
* [Hướng dẫn tinh chỉnh có giám sát OpenAI](https\://developers.openai.com/api/docs/guides/supervised-fine-tuning)
* [OpenAI Fine-tuning Jobs API](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs)