# Tệp và hiểu nội dung

Hai tầng\: API tải quản lý tài nguyên, API mô hình đọc và trả lời. Đính tệp vào sinh không nghĩa lưu thành tài nguyên tái dùng.

## Tổng quan

| Bạn muốn làm gì                        | Cách nhập                                             | Tệp đi đâu                    | Có cần tải lên trước không |
| -------------------------------------- | ----------------------------------------------------- | ----------------------------- | -------------------------- |
| Cho mô hình đọc một PDF                | Base64 nội tuyến trong yêu cầu hoặc URL truy cập được | Chỉ tồn tại trong yêu cầu này | Không                      |
| Tái sử dụng tệp qua nhiều lượt yêu cầu | file\_id hoặc tham chiếu tệp của hãng                 | Tài nguyên tệp của hãng       | Có (Files API chính thức)  |
| Tiền xử lý tệp hàng loạt hoặc quá dài  | Tải lên rồi chờ xử lý xong                            | Tài nguyên tệp của hãng       | Có, và có vòng đời         |

## Khái niệm cốt lõi

* **Đầu vào nội tuyến**\: tệp được mã hóa vào thân yêu cầu và gửi cùng tin nhắn; yêu cầu kết thúc là kết thúc, không có file\_id cũng không có bước xóa sau đó.
* **Tài nguyên tệp**\: tải lên trước để lấy id, sau đó tham chiếu trong nhiều yêu cầu; tài nguyên có quyền sở hữu, thời hạn và hạn mức, cần xóa tường minh.
* **Vòng đời**\: tải lên xong không có nghĩa đã trích xuất xong văn bản, cũng không có nghĩa mô hình đã hiểu; phải truy vấn đến trạng thái có thể xử lý rồi mới suy luận.
* **Kích thước và định dạng**\: giới hạn được đặt riêng theo kích thước tệp, số trang, thời lượng; nén ảnh không chuyển đổi loại tệp, PDF dạng quét còn cần khả năng OCR.
* **Lưu trữ dữ liệu**\: chính sách lưu giữ nội dung tệp và kết quả nhận dạng khác nhau giữa các hãng; tài liệu nhạy cảm cần xác nhận quyền và cách xóa trước.

## Yêu cầu và khả năng

| Mục đích                                        | Yêu cầu                                       | Giới hạn                                                       |
| ----------------------------------------------- | --------------------------------------------- | -------------------------------------------------------------- |
| [Hiểu nội dung PDF](/simidoc/vi/apps/api/upload/file-recognition)         | POST /v1/responses + input\_file              | Base64 nội tuyến, không cần Files API.                         |
| Đầu vào PDF Chat                                | POST /v1/chat/completions + type=file         | Dùng file Chat, không cấu trúc Responses.                      |
| [Files API](/simidoc/vi/apps/api/pending/files)                   | /v1/files                                     | Cổng chưa triển khai; hãng có tải gốc không nghĩa nền tảng mở. |
| [Hiểu phương tiện Gemini](/simidoc/vi/apps/api/chat/gemini-media) | POST /v1beta/models/\{model}\:generateContent | inlineData hoặc fileData phù hợp.                              |

## Cách gọi

Nội tuyến trả JSON đồng bộ hoặc sự kiện chữ luồng, đều một yêu cầu. Tải/tiền xử lý hãng có thể chờ tài nguyên, là vòng đời tài nguyên không tự chạy mô hình nền. Nhiều tệp cùng yêu cầu hoặc song song có ngữ cảnh, phí, giới hạn khác.

Trước tải tệp nhạy cảm, xác nhận quyền và chính sách dữ liệu. Chọn trang/đoạn liên quan thay tăng vô hạn. Giữ bất định kết quả; tiền, mã và kết luận luật/y cần người kiểm.

## Mô phỏng lệnh gọi

Nhận dạng nội tuyến hoàn tất trong một yêu cầu, tệp được đặt dưới dạng Base64 trong `input_file`\:

```json
{
  "model": "gpt-5.5",
  "input": [
    {
      "role": "user",
      "content": [
        { "type": "input_text", "text": "总结这份合同的付款条款。" },
        { "type": "input_file", "filename": "contract.pdf", "file_data": "data:application/pdf;base64,JVBERi0xLjQK..." }
      ]
    }
  ]
}
```

Phản hồi là tin nhắn mô hình thông thường, kết quả nhận dạng nằm trong `output_text`\:

```json
{
  "status": "completed",
  "output": [
    {
      "type": "message",
      "content": [
        { "type": "output_text", "text": "（示意）合同约定分三期付款……" }
      ]
    }
  ]
}
```

Toàn bộ quá trình không có bước tải lên và cũng không có file\_id tái sử dụng; muốn hỏi lại cùng một tệp, cần gửi lại Base64 hoặc chuyển sang tài nguyên tệp chính thức.

## Tham khảo chính thức

* [Đầu vào tệp OpenAI](https\://developers.openai.com/api/docs/guides/file-inputs)
* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [Đầu vào tệp Google](https\://ai.google.dev/gemini-api/docs/file-input-methods)