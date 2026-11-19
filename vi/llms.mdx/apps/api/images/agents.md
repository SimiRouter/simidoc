# Gọi ảnh bằng tác tử đã tích hợp vào tài liệu giao thức

Tác vụ tác tử đã được phân vào ba giao thức. Mỗi trang có mẫu tạo và sửa, chuẩn bị cấu hình, lưu kết quả và xử lý lỗi; không còn duy trì hướng dẫn riêng thiên về OpenAI Images.

* [Tác tử theo định dạng OpenAI](/simidoc/vi/apps/api/images/openai)\: tạo bằng Images, chỉnh sửa JSON và kiểm tra sự kiện cuối.
* [Tác tử theo Gemini gốc](/simidoc/vi/apps/api/images/gemini)\: Part ảnh GenerateContent, MIME và ngữ cảnh nhiều lượt.
* [Tác tử theo Qwen gốc](/simidoc/vi/apps/api/images/qwen)\: cấu hình khu vực chính thức, gọi đồng bộ và tải URL ảnh.

Tác tử vẫn cần chạy cục bộ và kiểm tra phản hồi; tài liệu không cài Skill từ xa. Yêu cầu thật có thể tính phí\: xác nhận mô hình, thông số, số lượng và nơi lưu; không lộ khóa, không ghi đè và không tự thử lại. Xem so sánh API, hiệu ứng và thông số tại [tổng quan API hình ảnh](/simidoc/vi/apps/api/images).