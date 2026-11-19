# Âm nhạc (không hỗ trợ)

Mục này tổng hợp giao thức tạo nhạc công khai của Google Lyria. SimiRouter chưa mở khả năng này; mọi ví dụ kết nối trực tiếp Gemini API của Google AI Studio qua `https://generativelanguage.googleapis.com` bằng khóa Google API. Vertex AI cần giao thức riêng chưa được kiểm chứng trong trang này; không chỉ thay địa chỉ để gọi.

## Tổng quan

| Năng lực                 | Đầu vào                              | Đầu ra                                       | Tính chất mục này              |
| ------------------------ | ------------------------------------ | -------------------------------------------- | ------------------------------ |
| Tạo đoạn nhạc            | Mô tả văn bản hoặc hình ảnh          | Âm thanh khoảng 30 giây, mặc định MP3        | Tham khảo giao diện chính thức |
| Tạo bài hát hoàn chỉnh   | Lời nhắc mô tả verse và điệp khúc    | Bài hát vài phút, có thể kèm lời và cấu trúc | Tham khảo giao diện chính thức |
| Biểu diễn thời gian thực | Lời nhắc và điều khiển phát liên tục | Các khối âm thanh PCM liên tục               | Tham khảo giao diện chính thức |

## Khái niệm cốt lõi

* **Đoạn nhạc và bài hát**\: đoạn nhạc cố định 30 giây, phù hợp để nghe thử và lặp; bài hát do lời nhắc kiểm soát độ dài và cấu trúc, thời lượng không được đảm bảo chính xác.
* **Phiên thời gian thực**\: WebSocket hai chiều, trong thời gian kết nối liên tục gửi lời nhắc và điều khiển PLAY, PAUSE, không phải biến yêu cầu một lần thành công tắc stream.
* **Định dạng âm thanh**\: mặc định MP3, có thể yêu cầu WAV; giao diện thời gian thực trả về khối PCM thô, ứng dụng phải tự đệm và đóng gói.
* **Khóa và địa chỉ**\: ví dụ trong trang này chỉ dùng địa chỉ Gemini API của Google AI Studio và khóa Google API; SimiRouter chưa proxy mô hình nhạc, còn giao thức riêng của Vertex AI chưa được kiểm chứng tại đây.

Giới hạn thời lượng, tần số lấy mẫu và tốc độ bit do mô hình quyết định; xem bảng tham số của [Lyria](/simidoc/vi/apps/api/music/lyria) và [RealTime](/simidoc/vi/apps/api/music/realtime) cho từng mục.

## Tổng quan API

| Chế độ              | Giao thức chính thức        | Khả năng                                | Tài liệu                     |
| ------------------- | --------------------------- | --------------------------------------- | ---------------------------- |
| Tạo nhạc một lần    | `POST /v1beta/interactions` | Từ chữ/ảnh tạo đoạn hoặc bài hát đầy đủ | [Tạo nhạc Lyria](/simidoc/vi/apps/api/music/lyria)    |
| Nhạc thời gian thực | WebSocket hai chiều         | Liên tục sinh và chỉnh âm thanh nhạc cụ | [Lyria RealTime](/simidoc/vi/apps/api/music/realtime) |

Lyria Clip tạo đoạn 30 giây; Lyria 3.5 hướng bài hoàn chỉnh hơn. RealTime thử nghiệm dùng kết nối lâu dài, không phải stream Interactions. Mô hình nhạc không đọc văn bản thường; TTS dùng [Âm thanh](/simidoc/vi/apps/api/audio).

## Mô phỏng lệnh gọi

Tạo một lần chính thức của Google dùng Interactions, yêu cầu mô tả phong cách và cấu trúc\:

```json
{
  "model": "lyria-3-clip-preview",
  "input": "温暖的钢琴与弦乐，节奏舒缓，适合纪录片开场"
}
```

Âm thanh trong phản hồi là Base64, không phải địa chỉ tải xuống\:

```json
{
  "steps": [
    {
      "type": "model_output",
      "content": [
        { "type": "text", "text": "[Instrumental]" },
        { "type": "audio", "data": "<Base64音频>" }
      ]
    }
  ]
}
```

Các mục âm thanh và văn bản có thể xen kẽ, phải duyệt `content[]` và lấy theo `type`; chỉ lấy mục cuối sẽ bỏ sót lời bài hát hoặc mô tả cấu trúc.

## Xác thực và quyền

Google Interactions chính thức dùng `x-goog-api-key: $GEMINI_API_KEY`; thời gian thực dùng SDK hoặc WebSocket chính thức. Nội dung phải tuân điều khoản Google, bản quyền và quyền giọng nói. Khả dụng, vùng, hạn mức theo tài khoản Google.

## Tham khảo chính thức

[Tạo nhạc Google](https\://ai.google.dev/gemini-api/docs/music-generation), [Nhạc thời gian thực](https\://ai.google.dev/gemini-api/docs/realtime-music-generation).