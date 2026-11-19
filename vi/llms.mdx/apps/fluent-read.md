# Cấu hình FluentRead

<Callout type="info" title="">
  🌊 FluentRead là tiện ích dịch trình duyệt mã nguồn mở, hướng đến trải nghiệm đọc tự nhiên như tiếng mẹ đẻ.
</Callout>

* Trang dự án\: [https\://github.com/FluentRead/FluentRead](https\://github.com/FluentRead/FluentRead)

## Tính năng chính

### Bộ máy dịch thông minh

* **Nhiều bộ máy**\: hỗ trợ nhiều bộ máy dịch
* **Dịch truyền thống**\: Microsoft Translator, Google Translate, DeepL và các dịch vụ khác.
* **Mô hình AI**\: OpenAI, DeepSeek, Kimi, Ollama và các mô hình khác.
* **Bộ máy tùy chỉnh**\: Hỗ trợ cấu hình dịch vụ dịch riêng.

### Trải nghiệm đọc liền mạch

* **Đối chiếu song ngữ**\: Hiển thị bản gốc cùng bản dịch để dễ đọc.
* **Dịch văn bản được chọn**\: Chọn đoạn bất kỳ để nhận bản dịch ngay.
* **Sao chép bằng một thao tác**\: Sao chép nhanh bản dịch, tăng hiệu quả đọc.
* **Dịch toàn trang**\: Nút nổi dịch toàn bộ trang web mà không cần tải lại.

### Quyền riêng tư và tùy chỉnh

* **Dữ liệu và quyền riêng tư**\: Khi dùng dịch vụ dịch trực tuyến hoặc mô hình đám mây, nội dung cần dịch được gửi đến dịch vụ đã cấu hình. Kiểm tra quy tắc xử lý dữ liệu của dịch vụ và không gửi thông tin nhạy cảm cho nhà cung cấp không đáng tin.
* **Tùy chỉnh sâu**\: Nhiều tùy chọn cho các nhu cầu khác nhau.
* **Hoàn toàn miễn phí**\: Mã nguồn mở, miễn phí, phi thương mại.

## Cài đặt

| Trình duyệt | Cách cài                                                                                                                                                                                                                                                           |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Chrome**  | [Chrome Web Store](https\://chromewebstore.google.com/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/djnlaiohfaaifbibleebjggkghlmcpcj?hl=zh-CN\&authuser=0) \| [Bản mirror tại Trung Quốc](https\://www.crxsoso.com/webstore/detail/djnlaiohfaaifbibleebjggkghlmcpcj) |
| **Edge**    | [Cửa hàng tiện ích Edge](https\://microsoftedge.microsoft.com/addons/detail/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/kakgmllfpjldjhcnkghpplmlbnmcoflp?hl=zh-CN)                                                                                                        |
| **Firefox** | [Cửa hàng tiện ích Firefox](https\://addons.mozilla.org/zh-CN/firefox/addon/%E6%B5%81%E7%95%85%E9%98%85%E8%AF%BB/)                                                                                                                                                 |

## Cấu hình

### Điền cấu hình thủ công trong FluentRead

Mở [Quản lý khóa API](https://api.dwchainless.com/keys) để sao chép khóa, mở cài đặt FluentRead và điền\:

| Mục cấu hình     | Nội dung                                      |
| ---------------- | --------------------------------------------- |
| Dịch vụ dịch     | New API                                       |
| Token truy cập   | Khóa API SimiRouter vừa sao chép              |
| Điểm cuối NewAPI | `https://api.dwchainless.com`(không có `/v1`) |
| Mô hình          | Chọn hoặc nhập ID mô hình đầy đủ khả dụng     |

Lưu rồi dịch đoạn ngắn không nhạy cảm; kiểm tra nhật ký SimiRouter. Dịch trực tuyến gửi nội dung nguồn tới dịch vụ đã cấu hình.