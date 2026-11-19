# Danh sách mô hình

Danh sách mô hình là đầu vào của cấu hình kết nối\: lấy ID mô hình trước, sau đó theo tài liệu năng lực của hãng để chọn giao diện chat, thị giác, hình ảnh, âm thanh hoặc công cụ. Nhìn thấy không đồng nghĩa gọi được, danh sách mô hình cũng không phải kiểm tra sức khỏe theo thời gian thực.

## Tổng quan

| Điều bạn cần xác nhận           | Xem ở đâu                                                                           | Giải thích                                                                               |
| ------------------------------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Có những ID mô hình nào         | Giao diện danh sách trong mục này                                                   | Chỉ trả về các mô hình mà thông tin xác thực hiện tại nhìn thấy                          |
| Có thực sự gọi được không       | Mô hình và giá + một yêu cầu thực tế                                                | Nhìn thấy, định tuyến được và có hạn mức là ba việc khác nhau                            |
| Hỗ trợ những đầu vào đầu ra nào | Mô tả năng lực mô hình                                                              | Siêu dữ liệu trong danh sách thường không đầy đủ                                         |
| Khi nào ngừng cung cấp          | Thông báo chính thức của nhà cung cấp về việc ngừng khuyến nghị hoặc ngừng cung cấp | Không dùng nữa không có nghĩa ngay lập tức không dùng được, nhưng không nên tích hợp mới |

## Khái niệm cốt lõi

* **ID mô hình**\: định danh duy nhất dùng trong nội dung yêu cầu, thường phân biệt chữ hoa chữ thường, phải sao chép đầy đủ, không tự viết tắt. Tên hiển thị, bí danh và ID yêu cầu thực tế có thể khác nhau.
* **Nhìn thấy và gọi được**\: danh sách chỉ phản ánh các mô hình trong phạm vi quyền; khi kênh chưa cấu hình, số dư không đủ hoặc bị giới hạn tốc độ vẫn sẽ thất bại.
* **Cửa sổ ngữ cảnh**\: giới hạn Token của đầu vào cộng đầu ra, khác nhau theo mô hình; giao diện danh sách thường không trả về giá trị này.
* **Đơn vị tính phí**\: mô hình văn bản chủ yếu theo Token, mô hình hình ảnh có thể theo ảnh hoặc theo Token, mô hình video thường theo giây hoặc theo lần; trong cùng một dòng mô hình cũng có thể khác nhau.
* **Ngày ngừng cung cấp**\: biểu thị ngày hãng dự kiến dừng dịch vụ; việc di chuyển nên hoàn tất trước hạn chứ không phải phát hiện sau khi hết hạn.

## Giao diện truy vấn

| Tài liệu                     | Yêu cầu            | Cấu trúc trả về                                         |
| ---------------------------- | ------------------ | ------------------------------------------------------- |
| [Định dạng OpenAI](/simidoc/vi/apps/api/models/openai) | GET /v1/models     | data\[].id, phù hợp với máy khách tương thích OpenAI.   |
| [Định dạng Gemini](/simidoc/vi/apps/api/models/gemini) | GET /v1beta/models | models\[].name, phù hợp với máy khách giao thức Gemini. |

## Cách gọi

Truy vấn danh sách là yêu cầu JSON đồng bộ, không hỗ trợ SSE và không phải tác vụ bất đồng bộ. Nhiều tài khoản có thể truy vấn song song riêng, nhưng thông tin xác thực và kết quả không được trộn lẫn. Bộ nhớ đệm danh sách nên có thời hạn hiệu lực, đọc lại khi phát hiện mô hình không còn dùng được; không gửi yêu cầu tạo thực tế chỉ để làm mới danh sách.

## Mô phỏng lệnh gọi

Gửi yêu cầu GET không có phần thân. Dưới đây là phản hồi minh họa từ cổng SimiRouter\:

```bash
curl "https://api.dwchainless.com/v1/models" \
  -H "Authorization: Bearer $SIMIROUTER_API_KEY"
```

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

Cổng trả về độ dài ngữ cảnh và các loại điểm cuối. Độ dài có thể là giá trị mặc định của nền tảng. Hãy xem tài liệu mô hình để biết giá, các dạng đầu vào và đầu ra cũng như khả năng hỗ trợ công cụ. Danh sách trống thường cho thấy thông tin xác thực hiện tại không có quyền xem mô hình nào.

## Ranh giới siêu dữ liệu

Đối tượng mô hình OpenAI gồm id, object, created, owned\_by; đối tượng mô hình gốc của Google có thể gồm phương thức và giới hạn Token. Cổng kết nối có thể chỉ trả về siêu dữ liệu rút gọn, vì vậy không được suy đoán giới hạn ngữ cảnh, phương thức hay hỗ trợ công cụ từ các trường bị thiếu.

## Tham khảo chính thức

* [OpenAI Models API](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [Google Models API](https\://ai.google.dev/api/models)