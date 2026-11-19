# Định dạng âm thanh OpenAI

## Tổng quan API

Định dạng âm thanh OpenAI có ba điểm cuối HTTP độc lập, đều dùng `Authorization: Bearer $SIMIROUTER_API_KEY`.

| Điểm cuối                       | Loại nội dung       | Phản hồi                               | Tài liệu                               |
| ------------------------------- | ------------------- | -------------------------------------- | -------------------------------------- |
| `POST /v1/audio/speech`         | JSON                | Byte âm thanh; SSE khi mô hình hỗ trợ  | [Tổng hợp giọng nói](/simidoc/vi/apps/api/audio/speech)         |
| `POST /v1/audio/transcriptions` | multipart/form-data | JSON chép lời, văn bản hoặc phụ đề     | [Chép lời giọng nói](/simidoc/vi/apps/api/audio/transcriptions) |
| `POST /v1/audio/translations`   | multipart/form-data | Bản dịch tiếng Anh dạng văn bản/phụ đề | [Dịch giọng nói](/simidoc/vi/apps/api/audio/translations)       |

Yêu cầu `model` phải là mô hình âm thanh khả dụng. TTS `voice`, định dạng chép lời, mốc thời gian và luồng tùy mô hình, không thay thế lẫn nhau. Chép tệp không có phiên mic liên tục; xem [Realtime](/simidoc/vi/apps/api/pending/realtime).

Trang tham khảo định dạng OpenAI API. Vòng đời mô hình và tham số hãng theo API Reference từng điểm cuối. Không dùng lẫn khóa cổng và OpenAI.