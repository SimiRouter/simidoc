# Âm thanh

API âm thanh dùng để biến văn bản thành giọng nói, chuyển bản ghi thành chữ và hiểu nội dung âm thanh. Tổng hợp giọng nói, tạo nhạc và âm thanh của video là các khả năng khác nhau; không được trộn lẫn mô hình và điểm cuối.

## Tổng quan

| Bạn muốn làm gì                         | Hướng                         | Đầu ra điển hình                      | Đơn vị tính phí                           |
| --------------------------------------- | ----------------------------- | ------------------------------------- | ----------------------------------------- |
| Đọc văn bản, làm lồng tiếng             | Văn bản → giọng nói           | Tệp âm thanh MP3, WAV…                | Số ký tự đầu vào hoặc thời lượng âm thanh |
| Chuyển bản ghi thành chữ                | Giọng nói → văn bản           | Chữ ngôn ngữ gốc, dấu thời gian       | Số giây hoặc số phút âm thanh             |
| Chuyển bản ghi ngoại ngữ sang tiếng Anh | Giọng nói → văn bản tiếng Anh | Chữ tiếng Anh, không giữ ngôn ngữ gốc | Thời lượng âm thanh                       |
| Hiểu nội dung bản ghi                   | Giọng nói → văn bản phân tích | Tóm tắt, người nói, kết luận          | Token tương ứng với âm thanh đầu vào      |
| Trò chuyện thời gian thực với người     | Luồng âm thanh hai chiều      | Âm thanh và sự kiện liên tục          | Thời lượng phiên hoặc Token               |

## Khái niệm cốt lõi

* **Tần số lấy mẫu**\: số lần lấy mẫu mỗi giây, phổ biến là 16kHz (đủ cho nhận dạng giọng nói) cùng 24kHz, 44.1kHz (chất lượng cao hơn). Tần số lấy mẫu không khớp sẽ khiến phát lại sai cao độ hoặc giảm chất lượng chép lời.
* **Độ sâu bit và kênh**\: 16 bit mono là lựa chọn phổ biến cho kịch bản giọng nói; stereo và độ sâu bit cao hơn làm tăng dung lượng tệp nhưng mô hình không nhất thiết tận dụng.
* **Vùng chứa và mã hóa**\: MP3 có tổn hao, dung lượng nhỏ; WAV thường không nén, dung lượng lớn; PCM là mẫu thô không có vùng chứa, khi phát cần chỉ định thủ công thông số lấy mẫu.
* **Thời lượng và dung lượng**\: giới hạn tải lên thường ràng buộc đồng thời theo dung lượng tệp và thời lượng; chuyển sang tần số lấy mẫu cao không nâng cao độ chính xác nhận dạng mà chỉ dễ vượt giới hạn hơn.
* **Đồng bộ và phát trực tuyến**\: TTS trả về byte âm thanh, ASR trả về JSON. Phát trực tuyến giảm thời gian chờ chữ hoặc đoạn đầu tiên, không thay đổi tổng lượng tính phí.

Giá trị thông số (thời lượng tối đa, định dạng hỗ trợ, phạm vi tần số lấy mẫu) do mô hình quyết định; xem bảng tham số yêu cầu của từng trang giao diện để biết chi tiết.

## Mô tả giao diện

| Năng lực                 | Đầu vào → đầu ra                                    | Cách yêu cầu                                                        | Tài liệu                                   |
| ------------------------ | --------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------ |
| Tổng hợp giọng nói (TTS) | Văn bản → âm thanh                                  | HTTP một lần; một số mô hình có thể chia khối hoặc dùng SSE         | [Chuyển văn bản thành giọng nói](/simidoc/vi/apps/api/audio/speech) |
| Chép lời giọng nói (ASR) | Tệp âm thanh → chữ ngôn ngữ gốc                     | Tải lên multipart; một số mô hình hỗ trợ SSE chép lời               | [Chép lời âm thanh](/simidoc/vi/apps/api/audio/transcriptions)      |
| Dịch giọng nói           | Tệp âm thanh đa ngôn ngữ → chữ tiếng Anh            | Yêu cầu multipart một lần                                           | [Dịch âm thanh](/simidoc/vi/apps/api/audio/translations)            |
| Tổng hợp giọng Gemini    | Văn bản → âm thanh một/ nhiều người nói             | Interactions gốc, mô hình cũ được hỗ trợ dùng generateContent riêng | [Gemini TTS](/simidoc/vi/apps/api/audio/gemini)                     |
| Hiểu âm thanh Gemini     | Bản ghi → tóm tắt, chép lời, văn bản phân tích      | Yêu cầu đa phương thức gốc                                          | [Hiểu âm thanh](/simidoc/vi/apps/api/audio/gemini-understanding)    |
| Giọng nói MiMo           | Văn bản/giọng tham chiếu → giọng nói; bản ghi → chữ | Tuyến tương thích riêng hoặc Chat Completions chính thức            | [MiMo](/simidoc/vi/apps/api/audio/mimo-audio)                       |
| Giọng nói thời gian thực | Đầu vào và đầu ra liên tục                          | WebRTC / WebSocket hai chiều                                        | [Realtime](/simidoc/vi/apps/api/pending/realtime)            |

## Khác biệt giữa đồng bộ, bất đồng bộ và phát trực tuyến

* **HTTP đồng bộ**\: một yêu cầu trả về tệp âm thanh hoặc bản chép lời đầy đủ, không có ID tác vụ và bước thăm dò trạng thái.
* **HTTP phát trực tuyến**\: cùng một phản hồi trả về âm thanh hoặc sự kiện SSE theo từng khối, không đồng nghĩa phiên thời gian thực hai chiều. Không áp dụng phân tích JSON cho luồng nhị phân.
* **Tác vụ bất đồng bộ**\: nhận ID tác vụ trước, sau đó truy vấn trạng thái; tạo video thường dùng cách này, còn TTS/ASR thông thường không theo quy trình này.
* **Realtime**\: phiên duy trì kết nối, máy khách có thể liên tục gửi âm thanh, ngắt phát và xử lý sự kiện; không thể thay thế bằng tải tệp lên.

## Mô phỏng lệnh gọi

Thân yêu cầu tổng hợp giọng nói là JSON, nhưng phản hồi là byte âm thanh chứ không phải JSON\:

```json
{
  "model": "gpt-4o-mini-tts",
  "voice": "alloy",
  "input": "欢迎使用 SimiRouter。",
  "response_format": "mp3"
}
```

Header trả về quyết định cách lưu tệp, phần thân được ghi trực tiếp vào `.mp3`\:

```text
HTTP/1.1 200 OK
Content-Type: audio/mpeg
Content-Length: 24576

<二进制音频数据>
```

Chép lời dùng tải lên multipart và trả về JSON\:

```json
{"text":"欢迎使用 SimiRouter。"}
```

Trong cùng danh mục “âm thanh”, tổng hợp trả về nhị phân còn chép lời trả về JSON, không được trộn lẫn bộ phân tích. Mô hình trong ví dụ `gpt-4o-mini-tts` đã bị nhà cung cấp đánh dấu ngừng hỗ trợ; xem [Văn bản thành giọng](/simidoc/vi/apps/api/audio/speech) để biết mô hình thay thế và cách chuyển đổi.

## Điều kiện tiên quyết khi sử dụng

Các trang tương thích OpenAI dùng địa chỉ SimiRouter và khóa SimiRouter; phần tham khảo gốc của hãng dùng địa chỉ hãng và khóa tương ứng. Mô hình có dùng được hay không do danh sách mô hình của tài khoản và quyền của kênh quyết định; không được coi mọi khả năng của hãng là cổng kết nối đã cung cấp đầy đủ. Trước khi tải bản ghi lên cần có sự cho phép cần thiết; nhân bản giọng nói cần có quyền sử dụng giọng đó và phải công bố với người nghe rằng đó là giọng tổng hợp.

## Tham khảo chính thức

* [Tổng hợp giọng nói OpenAI](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create)
* [Chép lời giọng nói OpenAI](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create)
* [Dịch giọng nói OpenAI](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create)
* [Hiểu âm thanh Google](https\://ai.google.dev/gemini-api/docs/audio)
* [Google Gemini TTS](https\://ai.google.dev/gemini-api/docs/speech-generation)