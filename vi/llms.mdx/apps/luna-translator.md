# Cấu hình LunaTranslator

<Callout type="info" title="">
  LunaTranslator là trình dịch visual novel miễn phí, mã nguồn mở, hướng đến trải nghiệm đọc tự nhiên.
</Callout>

* Trang dự án\: [https\://github.com/HIllya51/LunaTranslator](https\://github.com/HIllya51/LunaTranslator)
* Tài liệu dự án\: [https\://docs.lunatranslator.org](https\://docs.lunatranslator.org/zh/README.html)

## Khả năng

* **HOOK** Chủ yếu lấy văn bản bằng HOOK cho visual novel tương thích; xem hỗ trợ trong tài liệu chính thức.

* **Dịch nhúng** Một số trò chơi hiển thị bản dịch trực tiếp trong game.

* **HOOK trình giả lập** Đọc văn bản bằng HOOK từ trình giả lập và trò chơi được hỗ trợ.

* **OCR** Tích hợp OCR và hỗ trợ nhiều bộ máy trực tuyến, ngoại tuyến để lấy văn bản linh hoạt.

* **Giao diện dịch** Cấu hình nhiều mô hình ngôn ngữ và giao diện dịch ngoại tuyến.

* **Học ngôn ngữ** Hỗ trợ tách từ và phiên âm tiếng Nhật, AnkiConnect và Yomitan.

* **Tổng hợp giọng nói** Hỗ trợ nhiều bộ máy giọng nói trực tuyến và ngoại tuyến.

* **Nhận dạng giọng nói** Có thể dùng nhận dạng giọng nói Windows trên Windows 10 và 11.

## Cách cài

Xem [Tài liệu LunaTranslator\: tải, khởi chạy và cập nhật](https\://docs.lunatranslator.org/zh/README.html) để tải và cài đặt.

## Kết nối LunaTranslator với SimiRouter thủ công

1. Trong SimiRouter, mở [Quản lý khóa API](https://api.dwchainless.com/keys) để sao chép khóa muốn dùng.
2. Trong LunaTranslator **Cài đặt → Cài đặt dịch → Mô hình ngôn ngữ**, sao chép mẫu “Giao diện mô hình ngôn ngữ chung” để thêm giao diện.
3. Mở cài đặt giao diện vừa thêm, đặt **Địa chỉ API** thành `https://api.dwchainless.com`, **API Key** và dán khóa. Làm mới danh sách hoặc nhập ID mô hình đầy đủ khả dụng.
4. Lưu và bật giao diện. Dịch đoạn ngắn không nhạy cảm rồi xác minh trong nhật ký SimiRouter.

Không để khóa trong ảnh công khai. Tên mục khác nhau theo phiên bản; xem [Tài liệu chính thức LunaTranslator](https\://docs.lunatranslator.org/zh/guochandamoxing.html).