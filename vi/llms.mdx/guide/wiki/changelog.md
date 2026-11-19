# Nhật ký thay đổi

<Callout type="warn" title="Thông tin phiên bản · Cập nhật dữ liệu lúc 2026-8-12 18:48:26">
  Để xem toàn bộ phiên bản trước, truy cập [GitHub Releases](https\://github.com/QuantumNous/new-api/releases). Trang này không phải dữ liệu thời gian thực; thời điểm đồng bộ gần nhất nằm trong tiêu đề thông báo này. Khi thượng nguồn phát hành mới hơn, hãy lấy thượng nguồn làm chuẩn.
</Callout>

## v1.0.0-rc.24

<Callout type="info" title="Bản ghi mới nhất trên trang · Phát hành lúc 2026-08-07 17:47:48 (giờ Trung Quốc)">
  ### Phát hành\: v1.0.0-rc.24

  #### Tính năng mới

  * Thêm middleware giới hạn tốc độ thao tác quan trọng cho tuyến access token và chuyển hoa hồng, tăng bảo mật và ổn định.
  * Cải thiện phân loại mô hình lấy về trong kênh để tổ chức và truy xuất rõ hơn.

  #### Sửa lỗi

  * Sửa mất độ chính xác hạn mức mã đổi, bảo đảm phân bổ chính xác (#6685).
  * Sửa lỗi HTTP/2 không thử lại trong suốt sau reset luồng thượng nguồn bằng cách đặt đúng `Request.GetBody` trong bộ chuyển tiếp (#6249).
  * Kiểm thử Claude/Gemini bằng định dạng yêu cầu gốc để tăng tương thích.

  #### Khác

  * Bổ sung tùy chọn đồng bộ tệp CI cho quy trình đồng bộ bản phát hành.

  ***

  ### Thay đổi

  * fix(relay)\: đặt Request.GetBody để HTTP/2 thử lại trong suốt sau reset luồng, bởi @BlockchainHe tại [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * feat(channels)\: cải thiện phân loại mô hình lấy về, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6632](https\://github.com/QuantumNous/new-api/pull/6632)
  * fix\: thử Claude/Gemini bằng yêu cầu gốc, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6698](https\://github.com/QuantumNous/new-api/pull/6698)
  * fix\: sửa mất độ chính xác hạn mức mã đổi (#6680) bởi @lihu-001 tại [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  ### Người đóng góp mới

  * @BlockchainHe đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/6249](https\://github.com/QuantumNous/new-api/pull/6249)
  * @lihu-001 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/6685](https\://github.com/QuantumNous/new-api/pull/6685)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.23...v1.0.0-rc.24)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-arm64-v1.0.0-rc.24) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-macos-v1.0.0-rc.24) (132.6 MB)
  * [new-api-v1.0.0-rc.24](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24) (113.2 MB)
  * [new-api-v1.0.0-rc.24.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.24/new-api-v1.0.0-rc.24.exe) (115.1 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.24.tar.gz)
</Callout>

***

## v1.0.0-rc.23

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-08-01 23:25:04 (giờ Trung Quốc)">
  Điểm nổi bật\: mở rộng tương thích với kênh New API, DeepSeek Responses, giải nén zstd và tự chọn nhóm. Nhật ký hiện trạng thái luồng, tính phí thử lại theo bậc tin cậy hơn, hủy Bedrock khi client ngắt.

  ### Tính năng mới

  * Thêm kênh New API với chuyển luồng Gemini sang OpenAI, xử lý Advanced Custom Responses Compact và sửa ảnh multipart (#6559).
  * Thêm DeepSeek Responses API (#6562).
  * Tự chọn nhóm định tuyến (#6590).
  * Thêm điều khiển HTTP từng kênh cho quản trị viên chỉnh kết nối.
  * Nhận yêu cầu nén zstd (#6545).
  * Chủ nhật ký xem được yêu cầu có truyền luồng không (#6558).

  ### Sửa lỗi

  * Qwen `thinking_budget` được giữ khi chuyển yêu cầu (#5836).
  * Tính phí thử lại theo bậc dùng nhóm cuối, gồm thử lại đổi nhóm (#6570).
  * Hủy yêu cầu Bedrock khi client ngắt, giảm lãng phí thượng nguồn (#6589).

  ### Cải tiến

  * Đồng nhất cỡ chữ liên kết điều hướng đầu trang công khai (#6557).

  ***

  ### Thay đổi

  * refactor\: tách chuyển giao thức thành relaykit độc lập, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/6369](https\://github.com/QuantumNous/new-api/pull/6369)
  * fix\: tham số hóa nhật ký truy vấn chậm/SQL lỗi bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6493](https\://github.com/QuantumNous/new-api/pull/6493)
  * feat(oidc)\: hỗ trợ tên hiển thị đăng nhập OIDC tùy chỉnh bởi @mrchi tại [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * fix\: giữ truyền thinking\_budget Qwen, bởi @wxwwt tại [https\://github.com/QuantumNous/new-api/pull/5836](https\://github.com/QuantumNous/new-api/pull/5836)
  * feat\: giải nén yêu cầu zstd, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6545](https\://github.com/QuantumNous/new-api/pull/6545)
  * feat(logs)\: hiện trạng thái luồng cho chủ nhật ký, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6558](https\://github.com/QuantumNous/new-api/pull/6558)
  * fix(relay)\: giữ sửa ảnh multipart kênh New API, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6559](https\://github.com/QuantumNous/new-api/pull/6559)
  * fix(oauth)\: không coi window\.opener ngoài là luồng gắn tài khoản, bởi @neimaravila tại [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * style\: thống nhất chữ điều hướng công khai 14px (text-sm), bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6557](https\://github.com/QuantumNous/new-api/pull/6557)
  * feat\: DeepSeek Responses API, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6562](https\://github.com/QuantumNous/new-api/pull/6562)
  * fix(billing)\: quyết toán thử lại theo nhóm cuối, bởi @faithleysath tại [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)
  * fix(billing)\: củng cố phí thử lại đổi nhóm, tiếp #6518, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/6570](https\://github.com/QuantumNous/new-api/pull/6570)
  * fix(aws)\: hủy Bedrock khi client ngắt, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/6589](https\://github.com/QuantumNous/new-api/pull/6589)
  * Feat/auto group\: nhóm tự động, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/6590](https\://github.com/QuantumNous/new-api/pull/6590)

  ### Người đóng góp mới

  * @mrchi đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/6012](https\://github.com/QuantumNous/new-api/pull/6012)
  * @neimaravila đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/6425](https\://github.com/QuantumNous/new-api/pull/6425)
  * @faithleysath đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/6518](https\://github.com/QuantumNous/new-api/pull/6518)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.22...v1.0.0-rc.23)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-arm64-v1.0.0-rc.23) (110.1 MB)
  * [new-api-macos-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-macos-v1.0.0-rc.23) (132.6 MB)
  * [new-api-v1.0.0-rc.23](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23) (113.2 MB)
  * [new-api-v1.0.0-rc.23.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.23/new-api-v1.0.0-rc.23.exe) (115.0 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.23.tar.gz)
</Callout>

***

## v1.0.0-rc.22

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-07-26 21:19:04 (giờ Trung Quốc)">
  Mở rộng quản lý kênh/mô hình với khám phá thượng nguồn, mô hình ảnh Gemini mới, phí tùy chỉnh và Sub2API; tăng tin cậy luồng, giá, hoàn tiền, người dùng và UI quản trị.

  ### Tính năng mới

  * Kênh khám phá mô hình từ thượng nguồn tùy chỉnh nâng cao và Codex tương thích (#6184).
  * Hỗ trợ mô hình ảnh Gemini GA mới nhất (#6371).
  * Thêm giá công cụ cấu hình được, kênh Sub2API và tính phí alpha-search.
  * Mô hình Realtime GA khả dụng với tương thích tuyến tốt hơn (#6032).

  ### Sửa lỗi

  * Luồng Responses sang Chat không lặp gọi công cụ (#6225).
  * Tạo mô hình trùng tên không xóa giá đã lưu (#6365).
  * Trang chưa đặt giá chỉ hiện mô hình từ kênh đã chọn (#6126).
  * Hạn mức người dùng rất lớn không tràn (#6134).
  * Sắp người dùng đúng với phân trang (#6194).
  * Gắn mô hình MiniMax đúng hãng (#6164).
  * Bộ chọn nhóm Playground xử lý nhóm auto và tùy chọn dài (#6163).
  * Không hoàn tác vụ trùng khi cập nhật trạng thái đồng thời (#6074).
  * Có thể xóa hết ô số tiền nạp khi sửa (#6473).
  * Cập nhật ưu tiên kênh tại chỗ ổn định hơn (#6415).

  ### Cải tiến

  * Sửa JSON quản trị nhất quán, tránh UI che nội dung (#6421).
  * Debounce tìm người dùng, giảm yêu cầu thừa và tăng phản hồi (#6474).
  * Kênh qua proxy tương thích/ổn định hơn (#6157).
  * Nhật ký lỗi thượng nguồn có chi tiết dự phòng khi hãng trả lỗi mơ hồ (#6431).

  ***

  ### Thay đổi

  * fix\: tab chưa giá chỉ liệt kê mô hình kênh, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6126](https\://github.com/QuantumNous/new-api/pull/6126)
  * fix\: xóa dữ liệu xác thực khi xóa người dùng vĩnh viễn, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6168](https\://github.com/QuantumNous/new-api/pull/6168)
  * fix(users)\: tránh tràn hạn mức lớn, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/6134](https\://github.com/QuantumNous/new-api/pull/6134)
  * fix\: xác định hãng MiniMax cho mô hình MiniMax, bởi @fux-dev tại [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * fix\: sắp người dùng phía máy chủ thay vì trên một trang, bởi @DawnMoon1542 tại [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * fix(data-table)\: cập nhật thân bảng ngay khi đổi cột, bởi @DawnMoon1542 tại [https\://github.com/QuantumNous/new-api/pull/6253](https\://github.com/QuantumNous/new-api/pull/6253)
  * fix\: tránh công cụ trùng trong Responses sang Chat, bởi @nikuleo tại [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * feat(channel)\: khám phá mô hình Codex thượng nguồn, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6184](https\://github.com/QuantumNous/new-api/pull/6184)
  * feat\: lấy mô hình kênh tùy chỉnh nâng cao, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5971](https\://github.com/QuantumNous/new-api/pull/5971)
  * refactor(auth)\: thay session bảng điều khiển bằng token không trạng thái và kiểm soát phiên, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/6329](https\://github.com/QuantumNous/new-api/pull/6329)
  * fix\: không gửi cờ realtime beta khi chuyển mô hình gpt-realtime GA bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6032](https\://github.com/QuantumNous/new-api/pull/6032)
  * fix(playground)\: tránh tùy chọn nhóm bị kéo giãn, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/6120](https\://github.com/QuantumNous/new-api/pull/6120)
  * perf(data-table)\: tối ưu độ rộng cột thao tác, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/6135](https\://github.com/QuantumNous/new-api/pull/6135)
  * fix(web)\: hiện mức đã dùng khóa không giới hạn, bởi @RedwindA tại [https\://github.com/QuantumNous/new-api/pull/6224](https\://github.com/QuantumNous/new-api/pull/6224)
  * fix(channel)\: cải thiện proxy và vòng đời cache, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/6157](https\://github.com/QuantumNous/new-api/pull/6157)
  * fix(playground)\: sửa liệt kê mô hình nhóm auto, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/6163](https\://github.com/QuantumNous/new-api/pull/6163)
  * fix\: tránh hoàn tác vụ suno trùng qua cập nhật CAS, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6074](https\://github.com/QuantumNous/new-api/pull/6074)
  * chore(github)\: đổi mẫu issue thành biểu mẫu bắt buộc, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6452](https\://github.com/QuantumNous/new-api/pull/6452)
  * fix(github)\: khôi phục hiển thị biểu mẫu issue, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6454](https\://github.com/QuantumNous/new-api/pull/6454)
  * fix\: ghi thân lỗi khi thông điệp đã phân tích rỗng, bởi @bigsongeth tại [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)
  * fix\: tạo mô hình trùng tên không xóa giá cũ, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6365](https\://github.com/QuantumNous/new-api/pull/6365)
  * fix(web/channel)\: ổn định cập nhật ưu tiên tại chỗ, bởi @RedwindA tại [https\://github.com/QuantumNous/new-api/pull/6415](https\://github.com/QuantumNous/new-api/pull/6415)
  * perf(json-editor)\: thống nhất sửa JSON quản trị, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/6421](https\://github.com/QuantumNous/new-api/pull/6421)
  * feat\: thêm gemini-3-pro-image và gemini-3.1-flash-image GA, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6371](https\://github.com/QuantumNous/new-api/pull/6371)
  * feat\: hỗ trợ khóa Tencent TokenHub qua OpenAI tương thích, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6232](https\://github.com/QuantumNous/new-api/pull/6232)
  * fix\: cho xóa hết ô số tiền nạp, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6473](https\://github.com/QuantumNous/new-api/pull/6473)
  * fix\: debounce tìm người dùng, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6474](https\://github.com/QuantumNous/new-api/pull/6474)

  ### Người đóng góp mới

  * @fux-dev đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/6164](https\://github.com/QuantumNous/new-api/pull/6164)
  * @DawnMoon1542 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/6194](https\://github.com/QuantumNous/new-api/pull/6194)
  * @nikuleo đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/6225](https\://github.com/QuantumNous/new-api/pull/6225)
  * @bigsongeth đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/6431](https\://github.com/QuantumNous/new-api/pull/6431)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.21...v1.0.0-rc.22)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-arm64-v1.0.0-rc.22) (109.9 MB)
  * [new-api-macos-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-macos-v1.0.0-rc.22) (132.4 MB)
  * [new-api-v1.0.0-rc.22](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22) (113.0 MB)
  * [new-api-v1.0.0-rc.22.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.22/new-api-v1.0.0-rc.22.exe) (114.9 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.22.tar.gz)
</Callout>

***

## v1.0.0-rc.21

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-07-11 23:01:26 (giờ Trung Quốc)">
  ### Điểm nổi bật

  Thay đổi chính là phí ghi cache GPT-5.6\: OpenAI `cache_write_tokens` tính theo giá tạo cache, với bảo vệ số token prompt cache/không cache. Cũng cải thiện giá, Playground, bảng kênh và độ tin cậy phí/nhật ký.

  ### Tính năng mới

  * Thêm phí ghi cache GPT-5.6, tính OpenAI `cache_write_tokens` theo giá tạo cache và giữ nhất quán token prompt có/không cache.
  * Trang giá tính động theo nhóm, không hiện nhóm đặc biệt chỉ mẫu (#5906).
  * Cài giá mô hình có tab chưa giá, lọc trạng thái/đồng bộ để tìm cấu hình dễ hơn (#6124).
  * Playground có bảng tham số chat/sinh, chỉnh hành vi ngay UI (#6044).
  * Bảng kênh cho chỉnh độ rộng cột và giữ lấp đầy vùng trống (#5948).
  * Nhật ký hiện thời gian luồng và chi tiết tác vụ để chẩn đoán.
  * Tăng chuyển giao thức chữ và tuyến tùy chỉnh nâng cao (#5825).

  ### Sửa lỗi

  * Dịch trình duyệt không còn làm hỏng trang React (#5963).
  * Thêm được tên mô hình chỉ khác hoa thường, kể cả chọn nhiều (#6061).
  * Tính phí xử lý chính xác hơn việc trừ trước và đứt luồng ảnh.
  * Đặt lại gói ổn định hơn khi cập nhật đồng thời (#6057).
  * Đồng bộ đúng trường Responses Codex truyền qua (#6018).
  * Danh sách chọn mô hình Playground đồng bộ sau đổi mô hình.
  * iframe trang chủ tùy chỉnh được điều hướng cấp trên sau thao tác người dùng (#5955).
  * Khôi phục dán trong cấu hình kết nối kênh mặc định.

  ### Cải tiến

  * Bảng đồng bộ giá thượng nguồn tải/vẽ hiệu quả hơn (#6092).
  * Tinh chỉnh nhãn bảng, bố cục giá, hộp đồng bộ và giao diện mặc định sạch hơn.
  * Tài nguyên phông chữ phân giải đúng giữa bố cục workspace.

  ***

  ### Thay đổi

  * fix(web)\: ngăn dịch trình duyệt sửa gốc React, bởi @cat0825 tại [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)
  * feat(web)\: hỗ trợ đổi độ rộng cột danh sách kênh thủ công bởi @zuiho-kai tại [https\://github.com/QuantumNous/new-api/pull/5948](https\://github.com/QuantumNous/new-api/pull/5948)
  * fix(web)\: bảng kênh lấp chiều rộng sẵn có, bởi @zuiho-kai tại [https\://github.com/QuantumNous/new-api/pull/6031](https\://github.com/QuantumNous/new-api/pull/6031)
  * chore\: bỏ tệp thừa bị phục hồi lúc phát hành v1.0, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6041](https\://github.com/QuantumNous/new-api/pull/6041)
  * fix\: khóa hàng GORM v2 cho đặt lại gói, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6057](https\://github.com/QuantumNous/new-api/pull/6057)
  * feat(playground)\: thêm bảng tham số, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/6044](https\://github.com/QuantumNous/new-api/pull/6044)
  * fix\: cho thêm tên khác hoa thường trong chọn nhiều, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6061](https\://github.com/QuantumNous/new-api/pull/6061)
  * fix\: bỏ nhóm mẫu đặc biệt rò vào trang giá, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5906](https\://github.com/QuantumNous/new-api/pull/5906)
  * perf(model-pricing)\: tối ưu bảng đồng bộ giá, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/6092](https\://github.com/QuantumNous/new-api/pull/6092)
  * fix(web)\: cho iframe trang chủ điều hướng trên khi người dùng kích hoạt, bởi @Heykode tại [https\://github.com/QuantumNous/new-api/pull/5955](https\://github.com/QuantumNous/new-api/pull/5955)
  * chore(deps)\: nâng golang.org/x/crypto 0.51.0 lên 0.52.0, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/6096](https\://github.com/QuantumNous/new-api/pull/6096)
  * fix\: đồng bộ trường Responses Codex truyền qua, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/6018](https\://github.com/QuantumNous/new-api/pull/6018)
  * feat\: tăng chuyển giao thức chữ và tuyến tùy chỉnh, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/5825](https\://github.com/QuantumNous/new-api/pull/5825)
  * feat\: thêm tab mô hình chưa giá, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/6124](https\://github.com/QuantumNous/new-api/pull/6124)

  ### Người đóng góp mới

  * @cat0825 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5963](https\://github.com/QuantumNous/new-api/pull/5963)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.20...v1.0.0-rc.21)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-arm64-v1.0.0-rc.21) (129.6 MB)
  * [new-api-macos-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-macos-v1.0.0-rc.21) (152.2 MB)
  * [new-api-v1.0.0-rc.21](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21) (132.8 MB)
  * [new-api-v1.0.0-rc.21.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.21/new-api-v1.0.0-rc.21.exe) (134.6 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.21.tar.gz)
</Callout>

***

## v1.0.0-rc.20

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-07-07 21:46:39 (giờ Trung Quốc)">
  ### Điểm nổi bật

  Thêm giá GPT-5.6 và dọn instance cũ cho quản trị. Sửa biên hạn mức/giá, chuyển thưởng ví và nhập tỷ lệ thập phân.

  ### Tính năng mới

  * Thêm giá token GPT-5.6.
  * Thêm thao tác dọn instance cũ trong system-info (#5953).

  ### Sửa lỗi

  * Chuyển thưởng ví theo đơn vị hạn mức cấu hình, không đơn vị cố định sai (#5808).
  * Ô tỷ lệ nhóm cho nhập thập phân như `0.05` bình thường (#5995).
  * Giá theo bậc dùng ước tính token mặc định khi trừ trước để tính hạn mức tốt hơn.

  ***

  ### Thay đổi

  * fix\: giữ trạng thái nhập thập phân trường Ratio và sửa nhập 0.05 bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5995](https\://github.com/QuantumNous/new-api/pull/5995)
  * feat(system-info)\: dọn instance cũ, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5953](https\://github.com/QuantumNous/new-api/pull/5953)
  * fix(wallet)\: dùng đơn vị quota cấu hình khi chuyển thưởng, bởi @A-Words tại [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  ### Người đóng góp mới

  * @A-Words đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5808](https\://github.com/QuantumNous/new-api/pull/5808)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.19-i18nfix.2...v1.0.0-rc.20)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-arm64-v1.0.0-rc.20) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-macos-v1.0.0-rc.20) (151.7 MB)
  * [new-api-v1.0.0-rc.20](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20) (132.4 MB)
  * [new-api-v1.0.0-rc.20.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.20/new-api-v1.0.0-rc.20.exe) (134.2 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.20.tar.gz)
</Callout>

***

## v1.0.0-rc.19-i18nfix.2

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-07-07 14:06:07 (giờ Trung Quốc)">
  Sửa lỗi i18n

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-linux.txt) (200 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-macos.txt) (103 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/checksums-windows.txt) (101 B)
  * [new-api-arm64-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-arm64-v1.0.0-rc.19-i18nfix.2) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-macos-v1.0.0-rc.19-i18nfix.2) (151.7 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2) (132.4 MB)
  * [new-api-v1.0.0-rc.19-i18nfix.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19-i18nfix.2/new-api-v1.0.0-rc.19-i18nfix.2.exe) (134.2 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19-i18nfix.2.tar.gz)
</Callout>

***

## v1.0.0-rc.19

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-07-07 13:19:27 (giờ Trung Quốc)">
  ### Tính năng mới

  * Quản trị đặt lại hạn mức gói và xem sự kiện bão hòa cho kiểm toán (#5952).
  * Thêm bản địa hóa Trung phồn thể zh-TW cho UI mới (#5942).

  ### Sửa lỗi

  * Sửa tính phí hạn mức rất lớn để giới hạn đúng.

  ***

  ### Thay đổi

  * Bản địa hóa UI mới zh-TW, bởi @MeowTechOpenSource tại [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)
  * feat(subscription)\: quản trị đặt lại quota, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5952](https\://github.com/QuantumNous/new-api/pull/5952)

  ### Người đóng góp mới

  * @MeowTechOpenSource đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5942](https\://github.com/QuantumNous/new-api/pull/5942)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.18...v1.0.0-rc.19)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-arm64-v1.0.0-rc.19) (129.3 MB)
  * [new-api-macos-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-macos-v1.0.0-rc.19) (151.7 MB)
  * [new-api-v1.0.0-rc.19](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19) (132.4 MB)
  * [new-api-v1.0.0-rc.19.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.19/new-api-v1.0.0-rc.19.exe) (134.2 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.19.tar.gz)
</Callout>

***

## v1.0.0-rc.18

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-07-07 01:16:57 (giờ Trung Quốc)">
  Xử lý hạn mức phí tin cậy hơn với kiểm số lượng chặt để tránh tính sai.

  **Sửa lỗi**

  * Kiểm số lượng phí tốt hơn với giá trị sai hoặc cực lớn.

  ***

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.17...v1.0.0-rc.18)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-arm64-v1.0.0-rc.18) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-macos-v1.0.0-rc.18) (151.4 MB)
  * [new-api-v1.0.0-rc.18](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18) (132.0 MB)
  * [new-api-v1.0.0-rc.18.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.18/new-api-v1.0.0-rc.18.exe) (133.9 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.18.tar.gz)
</Callout>

***

## v1.0.0-rc.17

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-07-06 22:37:46 (giờ Trung Quốc)">
  ### Điểm nổi bật

  Cải thiện thử kênh, mã đổi, giao diện và UI web; sửa mức dùng, build classic, đứt luồng, tính quota/thời lượng video.

  ### Tính năng mới

  * Quản lý mã đổi có lọc trạng thái và dọn dẹp.
  * Sửa tỷ lệ nhóm dễ hơn, hiển thị rõ và nhập JSON vững hơn.
  * Lỗi đổi mã có thông báo rõ hơn.

  ### Sửa lỗi

  * AI Elements đọc usage lồng để báo token đúng.
  * Build web classic lại thành công (#5892).
  * Điều khiển truyền trường hiện đúng cho Codex (#5902).
  * iframe trang chủ theo ngôn ngữ và giao diện đã chọn (#5917).
  * HTML trong Shadow DOM theo sáng/tối đúng (#5890).
  * Người đã đăng nhập rời trang đăng ký nhất quán trang đăng nhập/classic (#5910).
  * Luồng không tiếp tục ghi khi client ngắt (#5710).
  * Sửa quota và thời lượng video Ali sau quyết toán tác vụ (#5923).
  * Tạo ngày build không lỗi khi DNS thất bại (#5945).

  ### Cải tiến

  * Hộp thử kênh/mô hình gọn và dễ dùng (#5886).
  * Chi tiết giá động đồng nhất phần chi tiết nhật ký (#5905).
  * Thẻ người dùng mobile rõ và bố cục tốt hơn.
  * Cảnh báo nạp cũ dễ hiểu hơn (#5855).

  ***

  ### Thay đổi

  * chore(deps-dev)\: nâng tmp 0.2.5 lên 0.2.7 trong /electron, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/5147](https\://github.com/QuantumNous/new-api/pull/5147)
  * chore(web)\: cập nhật phụ thuộc mặc định, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5884](https\://github.com/QuantumNous/new-api/pull/5884)
  * perf(web)\: tinh chỉnh tương tác thử kênh, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5886](https\://github.com/QuantumNous/new-api/pull/5886)
  * fix(classic)\: sửa build classic, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5892](https\://github.com/QuantumNous/new-api/pull/5892)
  * fix(channels)\: hiện truyền trường Codex, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5902](https\://github.com/QuantumNous/new-api/pull/5902)
  * fix\: đồng nhất giá động với chi tiết nhật ký, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5905](https\://github.com/QuantumNous/new-api/pull/5905)
  * fix\: tối ưu quota sau quyết toán chênh lệch tác vụ và thời lượng video Alibaba bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5923](https\://github.com/QuantumNous/new-api/pull/5923)
  * fix(web)\: đồng bộ theme/ngôn ngữ iframe, bởi @guoruqiang tại [https\://github.com/QuantumNous/new-api/pull/5917](https\://github.com/QuantumNous/new-api/pull/5917)
  * fix(web)\: sửa giao diện sáng/tối HTML tùy chỉnh trong Shadow DOM bởi @olwater tại [https\://github.com/QuantumNous/new-api/pull/5890](https\://github.com/QuantumNous/new-api/pull/5890)
  * fix(web)\: thêm chuyển hướng người đã đăng nhập ở trang đăng ký, đồng nhất trang đăng nhập/classic (#5908) bởi @Heykode tại [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * feat\: tối ưu cảnh báo nạp cũ (#5851), bởi @Gravirei tại [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)
  * fix\: tránh ghi luồng cũ sau client ngắt, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5710](https\://github.com/QuantumNous/new-api/pull/5710)
  * Sửa lỗi DNS ngày build, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5945](https\://github.com/QuantumNous/new-api/pull/5945)

  ### Người đóng góp mới

  * @Heykode đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5910](https\://github.com/QuantumNous/new-api/pull/5910)
  * @Gravirei đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5855](https\://github.com/QuantumNous/new-api/pull/5855)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.16...v1.0.0-rc.17)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-arm64-v1.0.0-rc.17) (128.9 MB)
  * [new-api-macos-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-macos-v1.0.0-rc.17) (151.4 MB)
  * [new-api-v1.0.0-rc.17](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17) (132.0 MB)
  * [new-api-v1.0.0-rc.17.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.17/new-api-v1.0.0-rc.17.exe) (133.8 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.17.tar.gz)
</Callout>

***

## v1.0.0-rc.16

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-07-03 15:41:42 (giờ Trung Quốc)">
  **Điểm nổi bật**

  Mở rộng mô hình/phương tiện với Responses/Chat, Seedance 2.0 và Wan2.7 i2v; cải thiện Playground, quản lý kênh, giữ trạng thái trang và khởi động lại êm.

  **Tính năng mới**

  * Tương thích Responses sang Chat, giúp hai định dạng hoạt động tin cậy hơn (#5787).
  * Mở Seedance 2.0\: API tài nguyên, phí theo phân giải/video vào/4K, tùy chọn mới (#5824).
  * Ánh xạ phương tiện Wan2.7 ảnh thành video (#4984).
  * Tắt dịch vụ êm, giảm đứt trả lời và mất cache bảng điều khiển khi restart (#4258).
  * Bố cục quản lý kênh rõ hơn, trình sửa tuyến nâng cao mạnh hơn.

  **Sửa lỗi**

  * Trình sửa biểu thức giá bậc làm mới đúng khi đổi mô hình (#5752).
  * Nhật ký tác vụ bất đồng bộ ghi đúng node khởi tạo (#5684).
  * Đổi theme về trang chủ thay vì 404 (#5612).
  * HTML/Markdown giữ kiểu, khoảng cách nhất quán, gồm view cô lập (#5795).
  * Giữ trạng thái khi chuyển tab cùng tuyến, gồm khoảng thời gian dashboard (#5796).
  * Giữ bộ lọc trạng thái kênh qua điều hướng (#5863).
  * Sửa gọi công cụ Ollama không luồng (#5865).
  * Sửa thông tin sản phẩm và webhook Waffo (#5704).

  **Cải tiến**

  * Cải thiện chat Playground và Markdown (#5217).
  * Đơn giản thao tác bảng và xác nhận phá hủy (#5645).
  * Cải thiện lọc LIKE nhật ký ClickHouse.
  * Tối ưu pipeline build web nhanh hơn (#5786).

  ***

  ### Thay đổi

  * chore(deps)\: nâng dompurify 3.4.5 lên 3.4.11 trong /web/default, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/5718](https\://github.com/QuantumNous/new-api/pull/5718)
  * fix(ci)\: cài phụ thuộc workspace classic cho release, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5719](https\://github.com/QuantumNous/new-api/pull/5719)
  * perf(web)\: gọn thao tác bảng và hộp phá hủy, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5645](https\://github.com/QuantumNous/new-api/pull/5645)
  * fix\: thêm thông tin hàng Waffo/cập nhật SDK webhook, bởi @zhongyuanzhao-alt tại [https\://github.com/QuantumNous/new-api/pull/5704](https\://github.com/QuantumNous/new-api/pull/5704)
  * fix(model-pricing)\: làm mới trình sửa giá bậc khi đổi mô hình, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5752](https\://github.com/QuantumNous/new-api/pull/5752)
  * fix\: đồng bộ bun.lock dompurify 3.4.11 để build frozen-lockfile, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5738](https\://github.com/QuantumNous/new-api/pull/5738)
  * fix(theme)\: về trang chủ sau đổi giao diện để tránh 404 bởi @zhangzhichaolove tại [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * fix(task)\: gán nhật ký bất đồng bộ đúng node khởi tạo, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5684](https\://github.com/QuantumNous/new-api/pull/5684)
  * feat\: thêm quyền quản trị Casbin, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/5755](https\://github.com/QuantumNous/new-api/pull/5755)
  * feat(playground)\: cải thiện chat/Markdown, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5217](https\://github.com/QuantumNous/new-api/pull/5217)
  * fix(auth)\: thống nhất mô tả kiểm mật khẩu, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5759](https\://github.com/QuantumNous/new-api/pull/5759)
  * fix(web)\: hiển thị HTML/Markdown nhất quán, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5760](https\://github.com/QuantumNous/new-api/pull/5760)
  * fix(openai)\: củng cố tương thích Chat sang Responses, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/5772](https\://github.com/QuantumNous/new-api/pull/5772)
  * feat\: Responses sang Chat, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/5787](https\://github.com/QuantumNous/new-api/pull/5787)
  * feat\: hỗ trợ giá theo độ phân giải doubao-seedance-2-0-260128 bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5300](https\://github.com/QuantumNous/new-api/pull/5300)
  * feat\: Seedance 2.0 safety\_identifier/priority và phí 4k, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5824](https\://github.com/QuantumNous/new-api/pull/5824)
  * fix(web)\: sửa lọc CSS HTML tùy chỉnh và khoảng cách bố cục bởi @olwater tại [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * feat\: ánh xạ Wan2.7 i2v, bởi @wxwwt tại [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * perf(web)\: tối ưu Rsbuild/Tailwind, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5786](https\://github.com/QuantumNous/new-api/pull/5786)
  * fix(makefile)\: dev-web chỉ chạy server web mặc định, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5794](https\://github.com/QuantumNous/new-api/pull/5794)
  * fix(web)\: đưa style ứng dụng vào HTML cô lập, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5860](https\://github.com/QuantumNous/new-api/pull/5860)
  * fix\: giữ trạng thái tab cùng tuyến, tránh reset thời gian dashboard, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5796](https\://github.com/QuantumNous/new-api/pull/5796)
  * Hỗ trợ tắt dịch vụ êm, tránh ngắt phản hồi và mất bộ nhớ đệm bảng điều khiển khi khởi động lại bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/4258](https\://github.com/QuantumNous/new-api/pull/4258)
  * fix\: auth guard mặc định chỉ coi 401 là hết phiên, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5872](https\://github.com/QuantumNous/new-api/pull/5872)
  * fix\: giữ lọc trạng thái kênh qua trang, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5863](https\://github.com/QuantumNous/new-api/pull/5863)
  * chore(deps)\: nâng golang.org/x/net 0.50.0 lên 0.55.0, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/5862](https\://github.com/QuantumNous/new-api/pull/5862)
  * chore(deps)\: nâng golang.org/x/image 0.38.0 lên 0.41.0, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/5873](https\://github.com/QuantumNous/new-api/pull/5873)
  * fix\: xử lý công cụ Ollama không luồng, bởi @stevenjoezhang tại [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  ### Người đóng góp mới

  * @zhangzhichaolove đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5612](https\://github.com/QuantumNous/new-api/pull/5612)
  * @olwater đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5795](https\://github.com/QuantumNous/new-api/pull/5795)
  * @wxwwt đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4984](https\://github.com/QuantumNous/new-api/pull/4984)
  * @stevenjoezhang đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5865](https\://github.com/QuantumNous/new-api/pull/5865)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.15...v1.0.0-rc.16)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-arm64-v1.0.0-rc.16) (127.4 MB)
  * [new-api-macos-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-macos-v1.0.0-rc.16) (149.8 MB)
  * [new-api-v1.0.0-rc.16](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16) (130.5 MB)
  * [new-api-v1.0.0-rc.16.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.16/new-api-v1.0.0-rc.16.exe) (132.3 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.16.tar.gz)
</Callout>

***

## v1.0.0-rc.15

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-06-24 21:00:04 (giờ Trung Quốc)">
  ### Điểm nổi bật

  Thêm vận hành\: giám sát kênh thụ động, ClickHouse, tác vụ hệ thống, thông tin instance; cải thiện nhật ký, Markdown, chọn kênh, ví tùy chọn.

  ### Tính năng mới

  * Giám sát kênh thụ động, kiểm sức khỏe không chủ động làm gián đoạn lưu lượng (#5592).
  * Lưu nhật ký ClickHouse cho truy vấn/lưu trữ mở rộng (#5663).
  * Trình chạy hệ thống lưu tiến độ dọn dài hạn (#5680).
  * Bảng instance kiểm trạng thái triển khai/node (#5716).
  * Phần giới hạn token người dùng trong hệ thống (#5678).
  * Thử kênh cho chọn môi trường và độ trễ polling.
  * Tên node dùng hostname nếu `NODE_NAME` chưa đặt (#5659).

  ### Sửa lỗi

  * Nhật ký hiện đúng biểu tượng hãng mô hình CN (#5631).
  * Sửa tên hiển thị Stepfun (#5636).
  * Sửa SMTP STARTTLS/NTLM (#5426).
  * Sửa build classic liên quan múi giờ (#5676).
  * Cải Markdown và mở cú pháp web (#5689).
  * Đồng bộ chọn thẻ kênh (#5700).
  * Ẩn mục ví khi mô-đun tắt (#5708).

  ### Cải tiến

  * Đơn giản dọn nhật ký trong luồng ClickHouse và tác vụ mới.

  ***

  ### Thay đổi

  * fix(usage-logs)\: biểu tượng hãng CN khớp classic, bởi @DeliciousBuding tại [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * fix\: đổi StepFun thành Stepfun, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5636](https\://github.com/QuantumNous/new-api/pull/5636)
  * feat\: giám sát kênh thụ động, bởi @exherb tại [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)
  * feat\: dùng hostname khi NODE\_NAME thiếu, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5659](https\://github.com/QuantumNous/new-api/pull/5659)
  * feat\: CSDL nhật ký ClickHouse, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/5663](https\://github.com/QuantumNous/new-api/pull/5663)
  * fix\: SMTP STARTTLS và NTLM, bởi @bensonfx tại [https\://github.com/QuantumNous/new-api/pull/5426](https\://github.com/QuantumNous/new-api/pull/5426)
  * chore(deps)\: nâng github.com/ClickHouse/ch-go 0.58.2 lên 0.65.0, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/5664](https\://github.com/QuantumNous/new-api/pull/5664)
  * fix\: lỗi build classic date-fns-tz, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5676](https\://github.com/QuantumNous/new-api/pull/5676)
  * feat\: trình chạy tác vụ hệ thống, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/5680](https\://github.com/QuantumNous/new-api/pull/5680)
  * feat\: bảng thông tin instance, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/5716](https\://github.com/QuantumNous/new-api/pull/5716)
  * fix(web)\: thay bộ Markdown, mở cú pháp, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5689](https\://github.com/QuantumNous/new-api/pull/5689)
  * fix(web)\: đồng bộ chọn thẻ kênh, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5700](https\://github.com/QuantumNous/new-api/pull/5700)
  * fix(web)\: ẩn ví trong menu hồ sơ khi tắt, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5708](https\://github.com/QuantumNous/new-api/pull/5708)
  * feat(system-settings)\: phần giới hạn token người dùng, bởi @RedwindA tại [https\://github.com/QuantumNous/new-api/pull/5678](https\://github.com/QuantumNous/new-api/pull/5678)

  ### Người đóng góp mới

  * @DeliciousBuding đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5631](https\://github.com/QuantumNous/new-api/pull/5631)
  * @exherb đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5592](https\://github.com/QuantumNous/new-api/pull/5592)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.14...v1.0.0-rc.15)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-arm64-v1.0.0-rc.15) (131.4 MB)
  * [new-api-macos-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-macos-v1.0.0-rc.15) (153.3 MB)
  * [new-api-v1.0.0-rc.15](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15) (134.2 MB)
  * [new-api-v1.0.0-rc.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.15/new-api-v1.0.0-rc.15.exe) (136.0 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.15.tar.gz)
</Callout>

***

## v1.0.0-rc.14

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-06-20 22:15:42 (giờ Trung Quốc)">
  ### Điểm nổi bật

  Thêm Sankey lưu lượng token với tô sáng tương tác, bộ lọc lưu, giới hạn đồ thị dễ đọc; bố cục thẻ kênh nhanh, gọn, giảm render lại.

  ### Tính năng mới

  * Thêm Sankey để quản trị thấy luồng token/định tuyến (#5465).
  * Thêm quản lý độ tin cậy định tuyến.

  ### Thư viện ảnh

  | Biểu đồ lưu lượng                                                                                                  | Channel management card layout                                                                                           |
  | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
  | ![Ví dụ bố cục thẻ quản lý kênh](https\://github.com/user-attachments/assets/e0d82bd4-e052-4518-9fac-1144c0bd0721) | ![Ảnh trong ghi chú phát hành Gallery](https\://github.com/user-attachments/assets/2ab5e6e6-f4f7-44f5-9abd-7191ed30e7aa) |

  ### Sửa lỗi

  * Sửa lọc loại đăng nhập UI mới (#5620).
  * Sửa phân trang đè danh sách lịch sử phí (#5627).
  * Sửa mục giá không xóa được (#5628).
  * Không lặp di chuyển cột CSDL sau restart (#5361, #5616).

  ### Cải tiến

  * Cải thẻ kênh, giảm render thừa.
  * Đơn giản danh sách mô hình dễ quét/quản lý.
  * Đồng nhất biểu tượng kênh.

  ***

  ### Thay đổi

  * fix\: dừng lặp migrate allow\_balance\_pay sau restart, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5361](https\://github.com/QuantumNous/new-api/pull/5361)
  * fix\: dừng lặp migrate allow\_wallet\_overflow sau restart, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5616](https\://github.com/QuantumNous/new-api/pull/5616)
  * feat(dashboard)\: thêm biểu đồ Sankey lưu lượng token bởi @Quaternijkon tại [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)
  * fix(log)\: sửa lọc loại đăng nhập type=7 trong nhật ký giao diện mới bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5620](https\://github.com/QuantumNous/new-api/pull/5620)
  * fix(wallet)\: sửa phân trang đè danh sách lịch sử thanh toán (#5624) bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5627](https\://github.com/QuantumNous/new-api/pull/5627)
  * fix(model-pricing)\: sửa không xóa được mục giá mô hình (#5623) bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5628](https\://github.com/QuantumNous/new-api/pull/5628)

  ### Người đóng góp mới

  * @Quaternijkon đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5465](https\://github.com/QuantumNous/new-api/pull/5465)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.13...v1.0.0-rc.14)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-arm64-v1.0.0-rc.14) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-macos-v1.0.0-rc.14) (142.3 MB)
  * [new-api-v1.0.0-rc.14](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14) (125.4 MB)
  * [new-api-v1.0.0-rc.14.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.14/new-api-v1.0.0-rc.14.exe) (127.1 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.14.tar.gz)
</Callout>

***

## v1.0.0-rc.13

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-06-19 20:28:34 (giờ Trung Quốc)">
  v1.0.0-rc.13 tập trung frontend mượt và hoàn thiện hơn, nhất là quản lý kênh/trang nhiều dữ liệu. Thẻ kênh hỗ trợ mobile tốt; nhật ký, chỉ số, chọn điểm cuối, ngày và mức dùng được tinh chỉnh UI/UX.

  ### Tính năng mới

  * Thêm nút thẻ/bảng tái dùng và bố cục thẻ cho trang nhiều bảng dễ đọc mọi cỡ màn.
  * Định dạng số theo ngôn ngữ/vùng.

  ### Cải tiến

  * Thẻ kênh trái/phải rõ hơn, tốt hơn trên mobile nhỏ.
  * Tinh chỉnh nhật ký, chỉ số, chọn endpoint, ngày, thanh công cụ, ngăn mô hình đồng nhất.
  * Giao diện dùng Codex dễ đọc/dùng hơn (#5595).
  * Giảm làm mới thừa khi cửa sổ lấy lại tiêu điểm.
  * Cập nhật nội dung thương hiệu và kiểu frontend đồng nhất.

  ### Sửa lỗi

  * Hiện thời điểm tạo ảnh tới mili giây khi cần.

  ***

  ### Thay đổi

  * chore(web)\: bắt kiểm chất lượng oxc frontend mặc định, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5585](https\://github.com/QuantumNous/new-api/pull/5585)
  * refactor\: giao diện usage Codex, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5595](https\://github.com/QuantumNous/new-api/pull/5595)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.12...v1.0.0-rc.13)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-arm64-v1.0.0-rc.13) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-macos-v1.0.0-rc.13) (142.2 MB)
  * [new-api-v1.0.0-rc.13](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13) (125.3 MB)
  * [new-api-v1.0.0-rc.13.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.13/new-api-v1.0.0-rc.13.exe) (127.0 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.13.tar.gz)
</Callout>

***

## v1.0.0-rc.12

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-06-18 20:34:16 (giờ Trung Quốc)">
  Điểm nổi bật\: kênh AdvancedCustom linh hoạt, thử lô kênh dễ xử lý, giám sát hiệu năng mô hình rõ tỷ lệ thành công/độ trễ.

  ### Tính năng mới

  * Kênh AdvancedCustom khớp tuyến tùy chỉnh tốt hơn (#5590).
  * Thử lô đầy đủ, làm mới trạng thái, kết quả rõ, xóa mô hình lỗi, sao chép đã chọn (#5532).
  * Giám sát marketplace có uptime, tỷ lệ gần đây, phân hạng thành công, độ trễ/thông lượng gọn.
  * Lưu kích thước trang và cột hiện qua điều hướng/phiên (#5403).

  ### Sửa lỗi

  * Sửa công cụ để giá trị `arguments` rỗng vẫn giữ khối `tool_use` như mong đợi (#5543).
  * Sửa bộ chọn mô hình CC Switch cập nhật/hiện đúng (#5515).
  * Sửa cắt/tràn UI danh sách, bảng, chi tiết usage, iframe trang chủ (#5510, #5536, #5533, #5545).

  ### Cải tiến

  * Thanh toán/nạp có nút, biểu tượng và mức nạp tối thiểu rõ hơn.
  * Gói có mô tả mua, tràn ví, nhóm hạ cấp.
  * Tinh chỉnh cài đặt, hướng dẫn ban đầu, ví/hồ sơ, thẻ thống kê dễ đọc.

  ### Thay đổi không tương thích

  * API tùy chọn/danh mục gói nay dùng `GET`, tích hợp có thể cần đổi phương thức.
  * Bỏ tùy chọn “Tất cả” khỏi kỳ xếp hạng.

  ***

  ### Thay đổi

  * fix(web)\: tránh tràn chữ/nhãn ô danh sách, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5510](https\://github.com/QuantumNous/new-api/pull/5510)
  * fix(keys)\: làm mới tùy chọn biểu mẫu khóa, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5512](https\://github.com/QuantumNous/new-api/pull/5512)
  * fix\: bộ chọn mô hình CC Switch, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5515](https\://github.com/QuantumNous/new-api/pull/5515)
  * fix(data-table)\: xét chọn hàng trong so sánh memo, bởi @RedwindA tại [https\://github.com/QuantumNous/new-api/pull/5524](https\://github.com/QuantumNous/new-api/pull/5524)
  * fix(channels)\: làm mới trạng thái hộp thử, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5517](https\://github.com/QuantumNous/new-api/pull/5517)
  * fix\: khôi phục chiều cao iframe trang chủ, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5545](https\://github.com/QuantumNous/new-api/pull/5545)
  * fix(web)\: tránh cắt nội dung cuối chi tiết nhật ký, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5533](https\://github.com/QuantumNous/new-api/pull/5533)
  * fix\: quản lý ngữ cảnh AWS AK/SK, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5547](https\://github.com/QuantumNous/new-api/pull/5547)
  * test\: dọn kiểm thử backend lách phần thưởng, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5563](https\://github.com/QuantumNous/new-api/pull/5563)
  * fix\: giữ khối tool\_use khi arguments rỗng bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5543](https\://github.com/QuantumNous/new-api/pull/5543)
  * fix\: hoàn thiện thử lô mô hình kênh, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5532](https\://github.com/QuantumNous/new-api/pull/5532)
  * feat\: lưu số hàng mỗi trang qua điều hướng/phiên (#5377) bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5403](https\://github.com/QuantumNous/new-api/pull/5403)
  * fix(data-table)\: tránh cắt ô thành phần, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5536](https\://github.com/QuantumNous/new-api/pull/5536)
  * fix(oauth)\: xóa liên kết khi xóa người vĩnh viễn, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5582](https\://github.com/QuantumNous/new-api/pull/5582)
  * feat\: kênh tùy chỉnh nâng cao, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5590](https\://github.com/QuantumNous/new-api/pull/5590)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.11...v1.0.0-rc.12)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-arm64-v1.0.0-rc.12) (122.9 MB)
  * [new-api-macos-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-macos-v1.0.0-rc.12) (142.1 MB)
  * [new-api-v1.0.0-rc.12](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12) (125.3 MB)
  * [new-api-v1.0.0-rc.12.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.12/new-api-v1.0.0-rc.12.exe) (127.0 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.12.tar.gz)
</Callout>

***

## v1.0.0-rc.11

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-06-13 16:15:40 (giờ Trung Quốc)">
  Điểm nổi bật\: Claude Opus 4.8, tương thích ảnh OpenAI, trình giá/bảng dễ dùng; sửa UI, quota, chuyển tiếp và lỗi hãng.

  ### Tính năng mới

  * Hỗ trợ Claude Opus 4.8 (#5177).
  * Tùy chọn xóa độ bám khi tắt kênh (#5306).
  * Công tắc đổi số dư gói.
  * Hiện ID người dùng trang hồ sơ (#5317).
  * Chuyển ảnh luồng và sửa ảnh OpenAI (#4608).

  ### Sửa lỗi

  * Biểu mẫu focus lỗi đầu sau gửi (#5163).
  * Sửa tên cc-switch đặt lại khi mất tiêu điểm (#5170).
  * Đồng bộ biểu tượng mô hình tùy chỉnh trong giá (#5224).
  * Hiện lỗi nâng cao không mở nhầm cài đặt khác (#5239).
  * Đổi tiền cập nhật cả đơn vị và số dư/quota (#5296).
  * Sửa ảnh từ xa Dify trong yêu cầu tệp (#5134).
  * Sửa tìm mô hình khi tra tác vụ video (#5133).
  * Cải chuyển GLM tương thích Anthropic (#5307).
  * Thu hẹp adapter OpenAI o, tránh mô hình không hỗ trợ (#5293).
  * Chọn nhiều theo theme hiện tại (#5328).
  * Sửa chuẩn hóa temperature Kimi K2.6 (#5390).
  * Lọc người đã xóa theo trạng thái (#5464).
  * Chỉ lấy cấu hình triển khai trên trang triển khai (#5466).

  ### Cải tiến

  * Tăng hiệu năng nhật ký quản trị/cập nhật lô (#5116).
  * Trình giá bố cục rõ, lưu nháp, JSON tái dùng, bước sáu thập phân (#5275).
  * Debounce tìm kênh, xử lý IME tốt (#5393).
  * Cải vẽ bảng, cột ghim, bố cục, nhãn (#5405).
  * Cải cỡ hộp thoại và footer (#5346).
  * Gọn nội dung hero trang công khai (#5339).

  ***

  ### Thay đổi

  * fix(web)\: focus lỗi biểu mẫu tốt hơn, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5163](https\://github.com/QuantumNous/new-api/pull/5163)
  * feat(keys/cc-switch-dialog)\: sửa tên cc-switch tùy chỉnh bị đặt lại khi mất tiêu điểm bởi @GnezIew tại [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * fix(model)\: thứ tự idx\_created\_at\_id thành (created\_at, id), bởi @realRoc tại [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * perf\: xếp log quản trị theo created\_at dùng chỉ mục ghép, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5116](https\://github.com/QuantumNous/new-api/pull/5116)
  * chore(deps)\: nâng axios 1.15.2 lên 1.16.0 /web/classic, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/5185](https\://github.com/QuantumNous/new-api/pull/5185)
  * feat\: claude-opus-4-8, bởi @hjxwz123 tại [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * fix(pricing)\: đồng bộ icon mô hình riêng, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5224](https\://github.com/QuantumNous/new-api/pull/5224)
  * chore(web)\: tập trung phiên bản phụ thuộc dùng chung, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5227](https\://github.com/QuantumNous/new-api/pull/5227)
  * feat(web)\: dev/build Rsbuild classic, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5232](https\://github.com/QuantumNous/new-api/pull/5232)
  * fix(channels)\: hiện lỗi kiểm nâng cao, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5239](https\://github.com/QuantumNous/new-api/pull/5239)
  * docs\: tinh chỉnh mẫu issue, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5271](https\://github.com/QuantumNous/new-api/pull/5271)
  * fix\: sửa đổi đơn vị số dư mà không đổi giá trị bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/5296](https\://github.com/QuantumNous/new-api/pull/5296)
  * fix(dify)\: tạo con trỏ tệp trước gán ảnh từ xa, bởi @Pluviobyte tại [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * fix(distributor)\: tìm mô hình GET /v1/video/generations/\:task\_id, bởi @Pluviobyte tại [https\://github.com/QuantumNous/new-api/pull/5133](https\://github.com/QuantumNous/new-api/pull/5133)
  * fix\: cấu hình timeout kết nối chuyển tiếp nhàn rỗi, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5309](https\://github.com/QuantumNous/new-api/pull/5309)
  * feat\: cấu hình có xóa tính bám kênh khi vô hiệu hóa kênh không bởi @GuangYiDing tại [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * fix(relay)\: sửa GLM Anthropic-compatible tránh chunked encoding, bởi @Chen011214 tại [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * fix\: giới hạn thân yêu cầu vô danh, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5244](https\://github.com/QuantumNous/new-api/pull/5244)
  * fix(i18n)\: rõ mô tả adapter suy nghĩ, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5242](https\://github.com/QuantumNous/new-api/pull/5242)
  * fix\: thu hẹp phạm vi thích ứng mô hình OpenAI dòng o bởi @USER-HFC tại [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * fix\: tái dùng đệm scanner luồng trong handler kênh, bởi @xujiantop-crypto tại [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * feat(web)\: hiện ID trang hồ sơ, bởi @P2K0 tại [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * perf(model-pricing)\: cải UX trình giá, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5275](https\://github.com/QuantumNous/new-api/pull/5275)
  * perf(web)\: gọn chữ hero công khai, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5339](https\://github.com/QuantumNous/new-api/pull/5339)
  * perf(web)\: cải cỡ/bố cục hộp thoại, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5346](https\://github.com/QuantumNous/new-api/pull/5346)
  * fix\: popover chọn nhiều theo theme, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5328](https\://github.com/QuantumNous/new-api/pull/5328)
  * fix\: căn nhãn phí mobile, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5161](https\://github.com/QuantumNous/new-api/pull/5161)
  * fix\: bước giá sáu thập phân, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5332](https\://github.com/QuantumNous/new-api/pull/5332)
  * fix(openai)\: hỗ trợ chuyển ảnh luồng và sửa ảnh Images API, bởi @gaoren002 tại `#4608`
  * perf(web)\: debounce tìm kênh, bỏ lúc nhập IME, bởi @QAbot-zh tại [https\://github.com/QuantumNous/new-api/pull/5393](https\://github.com/QuantumNous/new-api/pull/5393)
  * fix\: chuẩn hóa temperature kimi k2.6, bởi @bensonfx tại [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)
  * perf(web)\: cải bảng và cột ghim, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5405](https\://github.com/QuantumNous/new-api/pull/5405)
  * perf(data-table)\: cải bố cục/nhãn, bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/5460](https\://github.com/QuantumNous/new-api/pull/5460)
  * feat(audit)\: nhật ký an ninh bản địa hóa, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/5462](https\://github.com/QuantumNous/new-api/pull/5462)
  * chore\: cập nhật kênh Codex, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5461](https\://github.com/QuantumNous/new-api/pull/5461)
  * fix\: lọc trạng thái người đã xóa, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5464](https\://github.com/QuantumNous/new-api/pull/5464)
  * fix\: chỉ lấy cấu hình khi ở trang triển khai, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5466](https\://github.com/QuantumNous/new-api/pull/5466)

  ### Người đóng góp mới

  * @GnezIew đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5170](https\://github.com/QuantumNous/new-api/pull/5170)
  * @realRoc đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5191](https\://github.com/QuantumNous/new-api/pull/5191)
  * @hjxwz123 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5177](https\://github.com/QuantumNous/new-api/pull/5177)
  * @Pluviobyte đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5134](https\://github.com/QuantumNous/new-api/pull/5134)
  * @GuangYiDing đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5306](https\://github.com/QuantumNous/new-api/pull/5306)
  * @Chen011214 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5307](https\://github.com/QuantumNous/new-api/pull/5307)
  * @USER-HFC đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5293](https\://github.com/QuantumNous/new-api/pull/5293)
  * @xujiantop-crypto đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5225](https\://github.com/QuantumNous/new-api/pull/5225)
  * @P2K0 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5317](https\://github.com/QuantumNous/new-api/pull/5317)
  * @bensonfx đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5390](https\://github.com/QuantumNous/new-api/pull/5390)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.10...v1.0.0-rc.11)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-linux.txt) (180 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-macos.txt) (93 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-arm64-v1.0.0-rc.11) (84.8 MB)
  * [new-api-macos-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-macos-v1.0.0-rc.11) (103.8 MB)
  * [new-api-v1.0.0-rc.11](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11) (87.2 MB)
  * [new-api-v1.0.0-rc.11.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.11/new-api-v1.0.0-rc.11.exe) (88.9 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.11.tar.gz)
</Callout>

***

## v1.0.0-rc.10

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-05-26 22:20:13 (giờ Trung Quốc)">
  ### Điểm nổi bật

  v1.0.0-rc.10 cải UI, độ tin cậy chuyển tiếp và quy trình quản trị; thêm theme và mua gói bằng số dư, củng cố nhật ký, kênh, webhook, thanh toán, công cụ hãng.

  ### Tính năng mới

  * Theme có preset Anthropic/Simple Large, chữ serif tùy chỉnh và tỷ lệ cực lớn.
  * Gói hỗ trợ mua bằng số dư.

  ### Sửa lỗi

  * Kênh tự tắt không được chọn cho yêu cầu mới, thao tác không thông báo trùng (#4983).
  * Chuyển công cụ Gemini/Claude tin cậy hơn, gồm đồng thời (#5095).
  * Ảnh chuyển tiếp áp đúng quality (#5103).
  * Lọc log khớp chính xác trừ wildcard rõ; rút lỗi thượng nguồn quá lớn (#5097).
  * Webhook hoàn tất tin cậy hơn (#5047).
  * Waffo lưu nhất quán và ẩn tùy chọn cũ (#5110).
  * Cài hệ thống nhận biết chưa lưu và tránh giá trị số sai.

  ### Cải tiến

  * Chuyển phương tiện lớn dùng ít bộ nhớ hơn.
  * Cài hệ thống/tạo sửa kênh gọn rõ hơn.
  * Nhật ký/UI mặc định dễ dùng mobile, khoảng bảng, nhãn, đồ thị, dark rõ hơn.
  * Hero trang chủ bố cục hai cột sạch, nội dung mới.

  ***

  ### Thay đổi

  * 🐛 fix(channel)\: bỏ kênh nhiều khóa tự tắt khỏi cache, bởi @t0ng7u tại [https\://github.com/QuantumNous/new-api/pull/4983](https\://github.com/QuantumNous/new-api/pull/4983)
  * \[BugFix] sửa xử lý webhook, bởi @Hill-waffo tại [https\://github.com/QuantumNous/new-api/pull/5047](https\://github.com/QuantumNous/new-api/pull/5047)
  * fix(payment)\: ẩn Waffo Pancake classic, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5085](https\://github.com/QuantumNous/new-api/pull/5085)
  * fix(relay)\: sửa tham số chất lượng ảnh, bởi @lanfunoe tại [https\://github.com/QuantumNous/new-api/pull/5103](https\://github.com/QuantumNous/new-api/pull/5103)
  * fix\: cắt log thượng nguồn quá lớn, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5083](https\://github.com/QuantumNous/new-api/pull/5083)
  * fix\: bỏ độ lệch fcIdx -1, sửa trùng khóa gọi công cụ đồng thời bởi @learner-i tại [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)
  * fix\: lỗi tool\_use Gemini sang Claude, bởi @nekohy tại [https\://github.com/QuantumNous/new-api/pull/5041](https\://github.com/QuantumNous/new-api/pull/5041)
  * fix\: xử lý tìm khóa API phân trang, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5014](https\://github.com/QuantumNous/new-api/pull/5014)
  * fix\: tránh toast thao tác kênh trùng, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5015](https\://github.com/QuantumNous/new-api/pull/5015)
  * fix\: thống nhất lưu Waffo, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5110](https\://github.com/QuantumNous/new-api/pull/5110)
  * fix\: thử kênh dùng ID người thực, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5109](https\://github.com/QuantumNous/new-api/pull/5109)
  * fix\: lọc log chính xác trừ wildcard rõ, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5097](https\://github.com/QuantumNous/new-api/pull/5097)

  ### Người đóng góp mới

  * @learner-i đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5095](https\://github.com/QuantumNous/new-api/pull/5095)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.8...v1.0.0-rc.10)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-linux.txt) (180 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/checksums-windows.txt) (91 B)
  * [new-api-arm64-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-arm64-v1.0.0-rc.10) (82.8 MB)
  * [new-api-v1.0.0-rc.10](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10) (85.3 MB)
  * [new-api-v1.0.0-rc.10.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.10/new-api-v1.0.0-rc.10.exe) (86.9 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.10.tar.gz)
</Callout>

***

## v1.0.0-rc.8

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-05-22 16:25:46 (giờ Trung Quốc)">
  #### Điểm nổi bật

  Thêm Waffo Pancake với gắn danh mục/sản phẩm quản trị; hoàn thiện API, metadata/giá mô hình, chẩn đoán kênh, bộ lọc báo cáo và xử lý yêu cầu.

  #### Tính năng mới

  * Cổng Waffo Pancake với gắn danh mục/sản phẩm (#4935).

  #### Sửa lỗi

  * Dashboard theo thiết lập hiển thị (#4975).
  * Tổng hiệu năng chỉ nhóm hoạt động (#4976).
  * Chuẩn hóa giá tránh lệch (#4985).
  * Sở hữu mô hình từ kênh hoạt động (#4416).
  * Link frontend mặc định đúng tuyến (#5016).
  * Khôi phục lọc usage cũ tránh hồi quy.

  #### Cải tiến

  * Thử kênh hiện lỗi rõ hơn (#4988).
  * Giảm chi phí xử lý yêu cầu dưới tải (#5009).

  ***

  ### Thay đổi

  * fix\: kiểm toán ghi đè tham số trường tin nhạy cảm, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4974](https\://github.com/QuantumNous/new-api/pull/4974)
  * fix\: theo hiển thị dashboard, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4975](https\://github.com/QuantumNous/new-api/pull/4975)
  * fix\: tổng hiệu năng lọc nhóm hoạt động, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4976](https\://github.com/QuantumNous/new-api/pull/4976)
  * fix\: UX lỗi thử kênh, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4988](https\://github.com/QuantumNous/new-api/pull/4988)
  * fix\: chuẩn hóa lệch giá hiển thị, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4985](https\://github.com/QuantumNous/new-api/pull/4985)
  * fix\: owned\_by từ kênh hoạt động, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4416](https\://github.com/QuantumNous/new-api/pull/4416)
  * perf\: tối ưu metadata và lọc trường tắt, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5009](https\://github.com/QuantumNous/new-api/pull/5009)
  * fix\: sửa link tuyến viết cứng mặc định, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/5016](https\://github.com/QuantumNous/new-api/pull/5016)
  * Sửa trang đăng ký không hiện Turnstile sau đổi giao diện mới bởi @JunXiaoRuo tại [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * \[Feature Request] Waffo Pancake tích hợp gói và gắn danh mục quản trị, bởi @Hill-waffo tại [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)
  * fix\: tuân thủ gói Waffo và đổi ID sản phẩm, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/5038](https\://github.com/QuantumNous/new-api/pull/5038)

  ### Người đóng góp mới

  * @JunXiaoRuo đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/5011](https\://github.com/QuantumNous/new-api/pull/5011)
  * @Hill-waffo đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4935](https\://github.com/QuantumNous/new-api/pull/4935)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.7...v1.0.0-rc.8)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-arm64-v1.0.0-rc.8) (82.4 MB)
  * [new-api-v1.0.0-rc.8](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8) (84.8 MB)
  * [new-api-v1.0.0-rc.8.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.8/new-api-v1.0.0-rc.8.exe) (86.5 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.8.tar.gz)
</Callout>

***

## v1.0.0-rc.7

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-05-19 16:54:08 (giờ Trung Quốc)">
  #### Tính năng mới

  * Thêm hỗ trợ nguồn khóa `request_header` (#4903).

  #### Sửa lỗi

  * Sửa nhiều UI mặc định theo lô (#4880, #4893, #4817, #4877, #4898, #4876).
  * Sửa không xóa được ghi chú kênh (#4886).
  * Sửa bộ lọc nhật ký dùng (#4883).
  * Kiểm hạn mức khóa vô hạn trên web (#4881).
  * Kiểm quyền điều hướng mô-đun công khai (#4889).
  * Áp lọc nhóm đúng truy vấn kênh (#4847, #4885).
  * Sửa tên cột mơ hồ khi upsert `PerfMetric` (#4684).
  * Thêm chỗ giữ phân tích thiếu cho theme mặc định (#4928).
  * Sửa gửi quên mật khẩu bằng đúng loại nút (#4910).
  * Chuẩn hóa bố cục tab chi tiết mô hình (#4938).
  * Sửa tạo/xóa người dùng bảng quản lý (#4818).
  * Link đăng ký theo cài đặt cho phép (#4871).
  * Cập nhật nhãn phân trang ModelCardGrid (#4675).
  * Bản địa hóa xác nhận đặt lại mật khẩu (#4769).
  * Hiện lựa chọn nạp sẵn ở dark (#4897).
  * Sửa chấm màu API sai do token ngữ nghĩa lệch (#4824).
  * Sửa lưu API màu sai thất bại im lặng (#4823).
  * Dùng đúng tên trường `aff_code` trong dữ liệu đăng ký (#4965).
  * Popover lọc bảng tự thích độ rộng (#4966).
  * Sửa liên kết biểu mẫu cũ khi gửi khóa (#4967).

  #### Cải tiến

  * Tránh định dạng sớm trong debug log để tăng hiệu năng (#4929).

  ***

  ### Thay đổi

  * fix\: cho xóa ghi chú kênh, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4886](https\://github.com/QuantumNous/new-api/pull/4886)
  * fix\: sửa lọc usage log, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4883](https\://github.com/QuantumNous/new-api/pull/4883)
  * fix(web)\: kiểm quota khóa vô hạn, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4881](https\://github.com/QuantumNous/new-api/pull/4881)
  * fix\: kiểm quyền header công khai, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4889](https\://github.com/QuantumNous/new-api/pull/4889)
  * fix\: GetAllChannels bỏ lọc nhóm, bởi @draftgo tại [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * fix\: định danh cột PerfMetric upsert tránh mơ hồ PG, bởi @SAY-5 tại [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * fix\: lọc nhóm truy vấn kênh, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4885](https\://github.com/QuantumNous/new-api/pull/4885)
  * feat\: nguồn khóa request\_header, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4903](https\://github.com/QuantumNous/new-api/pull/4903)
  * fix\: sửa hiển thị ngôn ngữ và văn bản UI mới bởi @QuentinHsu tại [https\://github.com/QuantumNous/new-api/pull/4876](https\://github.com/QuantumNous/new-api/pull/4876)
  * fix\: thêm umami/ga4 placeholder index.html mặc định, bởi @NitroRCr tại [https\://github.com/QuantumNous/new-api/pull/4928](https\://github.com/QuantumNous/new-api/pull/4928)
  * perf\: tránh định dạng sớm debug log, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4929](https\://github.com/QuantumNous/new-api/pull/4929)
  * fix\: thêm type="submit" nút quên mật khẩu, bởi @lihan3238 tại [https\://github.com/QuantumNous/new-api/pull/4910](https\://github.com/QuantumNous/new-api/pull/4910)
  * fix(web)\: chuẩn hóa tab chi tiết mô hình, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4938](https\://github.com/QuantumNous/new-api/pull/4938)
  * fix(user)\: sửa tạo/xóa người quản lý, bởi @bugmaker2 tại [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * fix(auth)\: trả register\_enabled /api/status, kiểm link đăng ký, bởi @Gnonymous tại [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * fix(web/default)\: rõ nhãn phân trang ModelCardGrid, bởi @ellisfan tại [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * fix(auth)\: bản địa hóa xác nhận reset mật khẩu, bởi @neow021 tại [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * fix(web/default/wallet)\: hiện chọn preset dark, bởi @xinnyu tại [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)
  * fix(web/default)\: sửa màu api-info do token ngữ nghĩa, bởi @Micah-Zheng tại [https\://github.com/QuantumNous/new-api/pull/4824](https\://github.com/QuantumNous/new-api/pull/4824)
  * fix(web/default)\: sửa lưu màu sai/thông tin chưa kiểm bị im lặng, bởi @Micah-Zheng tại [https\://github.com/QuantumNous/new-api/pull/4823](https\://github.com/QuantumNous/new-api/pull/4823)
  * fix(auth)\: dùng aff\_code đăng ký (#4945), bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/4965](https\://github.com/QuantumNous/new-api/pull/4965)
  * fix(data-table)\: popover lọc tự rộng (#4905), bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/4966](https\://github.com/QuantumNous/new-api/pull/4966)
  * fix(keys)\: gọi submit trực tiếp tránh liên kết cũ (#4858), bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/4967](https\://github.com/QuantumNous/new-api/pull/4967)

  ### Người đóng góp mới

  * @draftgo đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4847](https\://github.com/QuantumNous/new-api/pull/4847)
  * @SAY-5 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4684](https\://github.com/QuantumNous/new-api/pull/4684)
  * @bugmaker2 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4818](https\://github.com/QuantumNous/new-api/pull/4818)
  * @Gnonymous đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4871](https\://github.com/QuantumNous/new-api/pull/4871)
  * @ellisfan đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4675](https\://github.com/QuantumNous/new-api/pull/4675)
  * @neow021 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4769](https\://github.com/QuantumNous/new-api/pull/4769)
  * @xinnyu đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4897](https\://github.com/QuantumNous/new-api/pull/4897)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.6...v1.0.0-rc.7)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-arm64-v1.0.0-rc.7) (82.3 MB)
  * [new-api-v1.0.0-rc.7](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7) (84.6 MB)
  * [new-api-v1.0.0-rc.7.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.7/new-api-v1.0.0-rc.7.exe) (86.3 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.7.tar.gz)
</Callout>

***

## v1.0.0-rc.6

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-05-13 22:29:13 (giờ Trung Quốc)">
  ### Điểm nổi bật

  Tăng quan sát bằng ID thượng nguồn trong log, xác nhận tuân thủ tính năng trả phí. Nếu bảng `logs` lớn, thêm trước cột `upstream_request_id` và chỉ mục bằng DDL trực tuyến để tránh migrate lâu khi nâng.

  ### Tính năng mới

  * Theo dõi ID thượng nguồn trong log, không ghi đè header ngoài ý muốn.
  * Xác nhận tuân thủ trước tính năng trả phí.

  ### Sửa lỗi

  * Focus chọn kênh không ẩn tùy chọn hợp lệ (#4829).

  ### Khác

  * Lưu ý nâng cấp\: bảng `logs` thêm cột `upstream_request_id` và chỉ mục; hệ lớn chạy DDL trực tuyến dưới trước để tránh migrate chặn/lâu.

  MySQL / InnoDB\:

  ```sql
  -- 1. Add the column using online DDL.
  ALTER TABLE logs
    ADD COLUMN upstream_request_id VARCHAR(128) NOT NULL DEFAULT '',
    ALGORITHM=INPLACE, LOCK=NONE;

  -- 2. Add the index using online DDL.
  ALTER TABLE logs
    ADD INDEX idx_logs_upstream_request_id (upstream_request_id),
    ALGORITHM=INPLACE, LOCK=NONE;
  ```

  PostgreSQL 11+\:

  ```sql
  -- 1. Add the column without rewriting the table on PG 11+.
  ALTER TABLE logs
    ADD COLUMN IF NOT EXISTS upstream_request_id VARCHAR(128) NOT NULL DEFAULT '';

  -- 2. Add the index concurrently to avoid blocking reads and writes.
  CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_logs_upstream_request_id
    ON logs (upstream_request_id);
  ```

  ***

  ### Thay đổi

  * chore(deps)\: nâng axios 1.15.0 lên 1.15.2 /web/classic, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/4634](https\://github.com/QuantumNous/new-api/pull/4634)
  * chore(deps-dev)\: nâng ip-address 10.1.0 lên 10.2.0 /electron, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/4811](https\://github.com/QuantumNous/new-api/pull/4811)
  * Sửa danh sách kênh hiển thị thiếu bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/4829](https\://github.com/QuantumNous/new-api/pull/4829)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.5...v1.0.0-rc.6)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-arm64-v1.0.0-rc.6) (82.3 MB)
  * [new-api-v1.0.0-rc.6](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6) (84.6 MB)
  * [new-api-v1.0.0-rc.6.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.6/new-api-v1.0.0-rc.6.exe) (86.3 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.6.tar.gz)
</Callout>

***

## v1.0.0-rc.5

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-05-12 16:53:57 (giờ Trung Quốc)">
  ### Điểm nổi bật

  Dashboard mới có chỉ số mô hình và sức khỏe rõ; thêm DeepChat deeplink, sửa UI, ví, Playground và tỷ lệ.

  ### Tính năng mới

  * Thiết kế lại tổng quan, thêm chỉ số hiệu năng/sức khỏe.
  * Hỗ trợ DeepChat deeplink mở chat trực tiếp (#4668).

  ### Sửa lỗi

  * Khả dụng cổng nạp đọc đúng cấu hình để hiện phương thức ví (#4599).
  * Tỷ lệ nhóm theo cấu hình nhóm-đến-nhóm (#4772).
  * Menu mặc định gọi handler chọn đúng (#4787).
  * Playground xử lý tin dạng classic cũ (#4650).
  * Tránh hồi quy v1 như vùng mô tả rỗng/bố cục (#4802).

  ### Cải tiến

  * Web/đồ thị theo preset chung cho màu, điều khiển, bo góc đồng nhất.
  * Docker chứa thông báo giấy phép dự án/bên thứ ba (#4739).

  ***

  ### Thay đổi

  * feat\: DeepChat deeplink, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4668](https\://github.com/QuantumNous/new-api/pull/4668)
  * fix\: bỏ THIRD-PARTY-LICENSES.md khỏi .dockerignore, bởi @yeying-xingchen tại [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * fix(wallet)\: đọc cờ cổng nạp từ topupInfo không status, bởi @ImogeneOctaviap794 tại [https\://github.com/QuantumNous/new-api/pull/4599](https\://github.com/QuantumNous/new-api/pull/4599)
  * fix(web/default)\: getUserGroups hiển thị GroupGroupRatio, bởi @Micah-Zheng tại [https\://github.com/QuantumNous/new-api/pull/4772](https\://github.com/QuantumNous/new-api/pull/4772)
  * fix(default)\: DropdownMenuItem onSelect, bởi @lihan3238 tại [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)
  * fix(web/default)\: bảo vệ tin playground dạng classic cũ, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/4650](https\://github.com/QuantumNous/new-api/pull/4650)
  * fix\: phân loại lỗi UI mặc định, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/4802](https\://github.com/QuantumNous/new-api/pull/4802)

  ### Người đóng góp mới

  * @yeying-xingchen đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4739](https\://github.com/QuantumNous/new-api/pull/4739)
  * @lihan3238 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4787](https\://github.com/QuantumNous/new-api/pull/4787)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.4...v1.0.0-rc.5)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-arm64-v1.0.0-rc.5) (82.1 MB)
  * [new-api-v1.0.0-rc.5](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5) (84.5 MB)
  * [new-api-v1.0.0-rc.5.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.5/new-api-v1.0.0-rc.5.exe) (86.2 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.5.tar.gz)
</Callout>

***

## v1.0.0-rc.4

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-05-06 22:25:59 (giờ Trung Quốc)">
  ### Điểm nổi bật

  Sửa ảnh OpenAI giữ tham chiếu/metadata khi chuyển, tránh mất ngữ cảnh (#4646). Thêm nhãn hiệu năng và sửa phí/menu.

  ### Tính năng mới

  * Nhãn hiệu năng trong danh sách để so mô hình nhanh.

  ### Sửa lỗi

  * Giữ ảnh và metadata chỉnh khi chuyển (#4646).
  * Biểu mẫu phí/nạp hoạt động tin cậy hơn.
  * Sửa dropdown/select sau cập nhật thành phần (#4655).

  ### Thay đổi không tương thích

  * Tích hợp đọc link nạp từ API thông tin nạp thay status.

  ### Thư viện ảnh

  | Xếp hạng khả dụng mô hình                                                                                                | UI giá và cài đặt mới                                                                                                    |
  | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
  | ![Ảnh trong ghi chú phát hành Gallery](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Ảnh trong ghi chú phát hành Gallery](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### Thay đổi

  * fix\: giữ trường tham chiếu sửa ảnh OpenAI, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4646](https\://github.com/QuantumNous/new-api/pull/4646)
  * fix\: chuyển select sang Base UI items API, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4655](https\://github.com/QuantumNous/new-api/pull/4655)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.3...v1.0.0-rc.4)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-arm64-v1.0.0-rc.4) (82.0 MB)
  * [new-api-v1.0.0-rc.4](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4) (84.4 MB)
  * [new-api-v1.0.0-rc.4.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.4/new-api-v1.0.0-rc.4.exe) (86.1 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.4.tar.gz)
</Callout>

***

## v1.0.0-rc.3

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-05-06 18:43:33 (giờ Trung Quốc)">
  ### Điểm nổi bật

  v1.0.0-rc.3 thêm xếp hạng mô hình với khả dụng/hiệu năng rõ, giúp so độ tin cậy trước chọn tuyến/hãng. Làm mới UI mặc định như giá, cài đặt, điều khiển bảng.

  ### Tính năng mới

  * Dashboard xếp hạng khả dụng/hiệu năng thực để so độ tin cậy (#4633).

  ### Cải tiến

  * UI mặc định Base UI, preset mới, thanh bảng sạch (#4633).
  * Tổ chức lại giá hệ thống dễ quét/quản lý.

  ### Sửa lỗi

  * Sắp bảng kênh phía máy chủ đúng (#4600).
  * Sửa hiển thị thanh toán gói mặc định.

  ### Thư viện ảnh

  | Xếp hạng khả dụng mô hình                                                                                                | UI giá và cài đặt mới                                                                                                    |
  | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
  | ![Ảnh trong ghi chú phát hành Gallery](https\://github.com/user-attachments/assets/03e974ba-4605-4bfd-83ef-dd32a30974de) | ![Ảnh trong ghi chú phát hành Gallery](https\://github.com/user-attachments/assets/db5bb31a-ef40-4914-989f-b7a6fd569a85) |

  ***

  ### Thay đổi

  * feat(web/default)\: cải UI Base UI, preset, ranking, thanh bảng, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/4633](https\://github.com/QuantumNous/new-api/pull/4633)
  * feat\: thu chỉ số mô hình, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/4635](https\://github.com/QuantumNous/new-api/pull/4635)
  * fix\: sắp kênh phía máy chủ, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4600](https\://github.com/QuantumNous/new-api/pull/4600)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.2...v1.0.0-rc.3)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-arm64-v1.0.0-rc.3) (81.9 MB)
  * [new-api-v1.0.0-rc.3](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3) (84.4 MB)
  * [new-api-v1.0.0-rc.3.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.3/new-api-v1.0.0-rc.3.exe) (86.1 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.3.tar.gz)
</Callout>

***

## v1.0.0-rc.2

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-04-30 20:42:48 (giờ Trung Quốc)">
  ### Điểm nổi bật

  v1.0.0-rc.2 chính thức cho chuyển frontend mới/classic, thử UI, so quy trình và quay lại ngay. Làm mới console, sửa gắn email, giá bậc, nhóm khóa và Vertex base URL tùy chỉnh.

  ### Tính năng mới

  * Công tắc mới/classic cho chuyển dần mà giữ quy trình cũ.

  ### Cải tiến

  * Console mới với giá, dashboard/log đồng nhất, lọc tốt, điều hướng mượt, mobile tốt.

  ### Sửa lỗi

  * Sửa gắn email frontend mới (#4551).
  * Sửa nhập số giá bậc tin cậy hơn (#4536).
  * Sửa giá bậc hiện sai số/nhãn (#4530).
  * Sửa nhóm khóa mặc định đúng nhóm mong muốn (#4548).
  * Sửa Vertex base URL khi có tiền tố cổng (#4200).

  ### Thư viện ảnh

  | Trang giá mới                                                                                      | Điều khiển dashboard và phân tích                                                                                      |
  | -------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
  | ![Trang giá mới](https\://github.com/user-attachments/assets/8d403155-27ac-407d-b0ae-8815034c66a7) | ![Điều khiển dashboard và phân tích](https\://github.com/user-attachments/assets/caa73f0a-13d2-47fc-ab7d-0ffb4e7b6194) |

  ### Thay đổi

  * fix\: sửa nhóm khóa API giao diện mặc định bởi @Micah-Zheng tại [https\://github.com/QuantumNous/new-api/pull/4548](https\://github.com/QuantumNous/new-api/pull/4548)
  * bug fix\: sửa gắn email giao diện mới bởi @SHLE1 tại [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)
  * fix\: cải sửa số giá bậc, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4536](https\://github.com/QuantumNous/new-api/pull/4536)
  * fix(vertex)\: tôn trọng base\_url làm tiền tố cổng, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4200](https\://github.com/QuantumNous/new-api/pull/4200)
  * fix(web)\: sửa hiển thị giá bậc do lỗi giải Base64 và nhãn không khớp bởi @wans10 tại [https\://github.com/QuantumNous/new-api/pull/4530](https\://github.com/QuantumNous/new-api/pull/4530)

  ### Người đóng góp mới

  * @SHLE1 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4551](https\://github.com/QuantumNous/new-api/pull/4551)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/compare/v1.0.0-rc.1...v1.0.0-rc.2)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-arm64-v1.0.0-rc.2) (76.5 MB)
  * [new-api-v1.0.0-rc.2](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2) (78.9 MB)
  * [new-api-v1.0.0-rc.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.2/new-api-v1.0.0-rc.2.exe) (80.6 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.2.tar.gz)
</Callout>

***

## v1.0.0-rc.1

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-04-29 20:15:01 (giờ Trung Quốc)">
  v1.0.0-rc.1 là bản ứng viên đầu của 1.0, tập trung frontend v1 xây lại từ đầu cho quản trị sạch, nhanh, mạnh hơn.

  RC làm mới điều hướng, cấu hình, phân tích, nhật ký, quản lý hằng ngày dễ hơn hướng v1 cuối.

  ![Ảnh trong ghi chú phát hành v1.0.0-rc.1](https\://github.com/user-attachments/assets/f3f8ed32-e0c5-4cfb-94a3-da0f357b62ab)

  ### Tính năng mới

  * Frontend v1 dựng lại, điều hướng/bố cục mới, sửa kênh trực quan cho ghi đè tham số, dễ cài/theme (#4265).

  ### Cải tiến

  * Nâng dashboard/đồ thị, phân tích rõ, sắp tốt, tooltip hữu ích.
  * Usage log có loại, tên/avatar và bảng sạch.
  * Hoàn thiện bố cục, bảng, biểu mẫu dùng chung.

  ### Sửa lỗi

  * Theme CSDL áp đúng runtime (#4518).
  * Giữ trường suy luận rỗng khi chuyển thay bỏ im lặng (#4520).
  * Nhãn trường bắt buộc nhất quán (#4533).

  ***

  ### Thay đổi

  * 🚀 feat\: v1.0 — frontend thế hệ mới dựng từ đầu, bởi @t0ng7u tại [https\://github.com/QuantumNous/new-api/pull/4265](https\://github.com/QuantumNous/new-api/pull/4265)
  * fix\: giữ nội dung suy nghĩ rỗng Message.ReasoningContent/Reasoning khi chuyển yêu cầu bởi @heimoshuiyu tại [https\://github.com/QuantumNous/new-api/pull/4520](https\://github.com/QuantumNous/new-api/pull/4520)
  * fix\: đồng bộ theme runtime khi nạp CSDL, bởi @Micah-Zheng tại [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  ### Người đóng góp mới

  * @Micah-Zheng đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4518](https\://github.com/QuantumNous/new-api/pull/4518)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/compare/v1.0.0-alpha.1...v1.0.0-rc.1)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-linux.txt) (178 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/checksums-windows.txt) (90 B)
  * [new-api-arm64-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-arm64-v1.0.0-rc.1) (76.4 MB)
  * [new-api-v1.0.0-rc.1](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1) (78.8 MB)
  * [new-api-v1.0.0-rc.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v1.0.0-rc.1/new-api-v1.0.0-rc.1.exe) (80.5 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-rc.1.tar.gz)
</Callout>

***

## v1.0.0-alpha.1 - License boundary release

<Callout type="note" title="Bản phát hành trước · Phát hành lúc 2026-04-28 14:26:06 (giờ Trung Quốc)">
  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1](https\://github.com/QuantumNous/new-api/compare/v0.13.2...v1.0.0-alpha.1)

  **Tài nguyên tải xuống**

  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v1.0.0-alpha.1.tar.gz)
</Callout>

***

## v0.13.2

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-04-27 22:11:42 (giờ Trung Quốc)">
  ### Tính năng mới

  * Đồng bộ mô hình phát hiện chính xác, tự cập nhật giá từ hãng, hiện mô hình bị bỏ, giữ giá khi trễ (#4452).
  * Người dùng có thời gian tạo/đăng nhập cuối để kiểm toán (#4450).
  * Khớp mô hình cấu hình được cho Ali Messages gốc (#4468).

  ### Sửa lỗi

  * Công cụ nhận tham số JSON thô, tương thích hãng trả đối tượng (#4469).
  * Cập nhật cấu hình xử lý JSON vững hơn, tránh lưu sai.

  ### Cải tiến

  * Thông báo rõ khi bỏ kênh vì affinity tắt (#4453).

  ***

  ### Thay đổi

  * fix(channel)\: nạp ánh xạ khi kiểm mô hình thượng nguồn, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4437](https\://github.com/QuantumNous/new-api/pull/4437)
  * feat\: đồng bộ giá từ endpoint hãng, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4452](https\://github.com/QuantumNous/new-api/pull/4452)
  * fix\: rõ thông báo bỏ kênh affinity tắt, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4453](https\://github.com/QuantumNous/new-api/pull/4453)
  * feat\: cấu hình khớp mô hình Ali Messages gốc, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4468](https\://github.com/QuantumNous/new-api/pull/4468)
  * fix\: tham số công cụ JSON thô, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4469](https\://github.com/QuantumNous/new-api/pull/4469)
  * feat\: hiện mô hình thượng nguồn bị bỏ trong hộp lấy, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4470](https\://github.com/QuantumNous/new-api/pull/4470)
  * Thêm thời gian tạo và đăng nhập cuối của người dùng bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/4450](https\://github.com/QuantumNous/new-api/pull/4450)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2](https\://github.com/QuantumNous/new-api/compare/v0.13.1-patch.1...v0.13.2)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.0.13.2.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/New-API-App.Setup.0.13.2.exe) (106.8 MB)
  * [new-api-arm64-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-arm64-v0.13.2) (64.6 MB)
  * [new-api-macos-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-macos-v0.13.2) (83.2 MB)
  * [new-api-v0.13.2](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2) (67.0 MB)
  * [new-api-v0.13.2.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.2/new-api-v0.13.2.exe) (68.6 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.2.tar.gz)
</Callout>

***

## v0.13.1-patch.1

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-04-25 13:27:23 (giờ Trung Quốc)">
  ### Điểm nổi bật

  Bản vá hỗ trợ `len` trong điều kiện bậc và trợ lý prompt, tạo quy tắc theo độ dài.

  ### Tính năng mới

  * Thêm biến `len` vào điều kiện bậc/trợ lý prompt để định giá theo độ dài.

  ***

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/compare/v0.13.1...v0.13.1-patch.1)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-linux.txt) (186 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-macos.txt) (96 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/checksums-windows.txt) (94 B)
  * [new-api-arm64-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-arm64-v0.13.1-patch.1) (64.6 MB)
  * [new-api-macos-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-macos-v0.13.1-patch.1) (83.2 MB)
  * [new-api-v0.13.1-patch.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1) (66.9 MB)
  * [new-api-v0.13.1-patch.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1-patch.1/new-api-v0.13.1-patch.1.exe) (68.6 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1-patch.1.tar.gz)
</Callout>

***

## v0.13.1

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-04-24 22:20:58 (giờ Trung Quốc)">
  #### Tính năng mới

  * Hỗ trợ hậu tố suy luận DeepSeek V4 (#4428).

  #### Sửa lỗi

  * Sửa bỏ mô hình phí bậc khỏi danh sách (#4431).

  ***

  ### Thay đổi

  * fix\: đưa mô hình phí bậc vào danh sách, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4431](https\://github.com/QuantumNous/new-api/pull/4431)
  * feat\: xử lý/kiểm thử hậu tố DeepSeek V4, bởi @HynoR tại [https\://github.com/QuantumNous/new-api/pull/4428](https\://github.com/QuantumNous/new-api/pull/4428)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1](https\://github.com/QuantumNous/new-api/compare/v0.13.0...v0.13.1)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.0.13.1.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/New-API-App.Setup.0.13.1.exe) (106.7 MB)
  * [new-api-arm64-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-arm64-v0.13.1) (64.6 MB)
  * [new-api-macos-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-macos-v0.13.1) (83.2 MB)
  * [new-api-v0.13.1](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1) (66.9 MB)
  * [new-api-v0.13.1.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.1/new-api-v0.13.1.exe) (68.6 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.1.tar.gz)
</Callout>

***

## v0.13.0

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-04-24 14:09:21 (giờ Trung Quốc)">
  ### Điểm nổi bật

  Bản này hỗ trợ `expr` biểu thức giá bậc để quản trị đặt quy tắc động phức tạp, như `tokens <= 128000 ? 0.002 : 0.004`, tự giá thấp dưới 128K token, cao hơn trên ngưỡng.

  ### Tính năng mới

  * Đánh giá biểu thức `expr` trong tính phí, hỗ trợ preset động (#4409).
  * UI giá công cụ và tính quota tốt hơn.
  * Hiện ID người dùng hóa đơn nạp quản trị (#4349).
  * Cột lần dùng cuối bảng token (#4372).
  * Nới chiều dài cột khóa để migrate khóa cũ dài (#4401).

  ### Sửa lỗi

  * Chỉ mô hình ảnh áp tỷ lệ N (#4412).
  * Giữ phụ phí công cụ chữ khi quyết toán bậc (#4162).
  * Sửa tỷ lệ completion của `gpt-5.5` (#4414).
  * UI giá dùng đúng loại hiển thị (#4426).
  * Sửa crash runtime/biên trình giá và quyết toán.
  * Thử kênh hỗ trợ đánh giá mô hình phí bậc.

  ### Cải tiến

  * Preset Doubao Seed 1.8 cho chiết khấu.
  * Thay Card bằng div để bố cục đồng nhất.
  * Tính nội bộ dùng quota mỗi đơn vị chính xác hơn.

  ***

  ### Thay đổi

  * fix(channel-test)\: thử mô hình phí bậc, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4145](https\://github.com/QuantumNous/new-api/pull/4145)
  * Hiện ID người dùng trong hóa đơn nạp của quản trị viên bởi @uskyu tại [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * Thêm thời gian dùng token cuối bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/4372](https\://github.com/QuantumNous/new-api/pull/4372)
  * chore(deps)\: nâng github.com/jackc/pgx/v5 5.9.0 lên 5.9.2, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/4397](https\://github.com/QuantumNous/new-api/pull/4397)
  * chore(deps-dev)\: nâng @xmldom/xmldom 0.8.12 lên 0.8.13 /electron, bởi @dependabot\[bot] tại [https\://github.com/QuantumNous/new-api/pull/4399](https\://github.com/QuantumNous/new-api/pull/4399)
  * Nới cột khóa tương thích migrate cũ, bởi @XiaoAI1024 tại [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * fix(billing)\: giữ phụ phí công cụ chữ khi quyết toán bậc, bởi @yyhhyyyyyy tại [https\://github.com/QuantumNous/new-api/pull/4162](https\://github.com/QuantumNous/new-api/pull/4162)
  * feat\: biểu thức phí bậc, bởi @Calcium-Ion tại [https\://github.com/QuantumNous/new-api/pull/4409](https\://github.com/QuantumNous/new-api/pull/4409)
  * fix(image)\: chỉ ảnh dùng tỷ lệ N, bởi @xyfacai tại [https\://github.com/QuantumNous/new-api/pull/4412](https\://github.com/QuantumNous/new-api/pull/4412)
  * fix\: tỷ lệ completion gpt-5.5, bởi @jingx8885 tại [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)
  * fix\: loại hiển thị giá, bởi @feitianbubu tại [https\://github.com/QuantumNous/new-api/pull/4426](https\://github.com/QuantumNous/new-api/pull/4426)

  ### Người đóng góp mới

  * @uskyu đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4349](https\://github.com/QuantumNous/new-api/pull/4349)
  * @XiaoAI1024 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4401](https\://github.com/QuantumNous/new-api/pull/4401)
  * @jingx8885 đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4414](https\://github.com/QuantumNous/new-api/pull/4414)

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0](https\://github.com/QuantumNous/new-api/compare/v0.12.15...v0.13.0)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-linux.txt) (170 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-macos.txt) (88 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/checksums-windows.txt) (86 B)
  * [New-API-App.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.0.13.0.exe) (106.5 MB)
  * [New-API-App.Setup.0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/New-API-App.Setup.0.13.0.exe) (106.8 MB)
  * [new-api-arm64-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-arm64-v0.13.0) (64.6 MB)
  * [new-api-macos-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-macos-v0.13.0) (83.2 MB)
  * [new-api-v0.13.0](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0) (66.9 MB)
  * [new-api-v0.13.0.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.13.0/new-api-v0.13.0.exe) (68.6 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.13.0.tar.gz)
</Callout>

***

## v0.12.15

<Callout type="note" title="Bản chính thức · Phát hành lúc 2026-04-22 23:04:03 (giờ Trung Quốc)">
  #### Tính năng mới

  * Waffo Pay cho nạp và thanh toán (#4089).

  #### Sửa lỗi

  * Sửa thẻ nạp làm hỏng giao diện (#4388).

  #### Cải tiến

  * Hỗ trợ Gemini `IncludeServerSideToolInvocations` trong `ToolConfig`, tương thích công cụ mới tốt hơn (#4311).
  * Kênh Codex làm mới khóa khi tự tắt, tự thử bằng luồng, hộp usage tốt hơn (#4324).

  ***

  ### Thay đổi

  * fix(gemini)\: IncludeServerSideToolInvocations trong ToolConfig, bởi @KoellM tại [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * rafactor\: thanh toán, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4089](https\://github.com/QuantumNous/new-api/pull/4089)
  * fix(topup)\: nhập Tag thiếu ở thẻ nạp, bởi @gaoren002 tại `#4388`
  * chore\: bố cục hộp usage Codex, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4386](https\://github.com/QuantumNous/new-api/pull/4386)
  * fix\: thử tự động Codex bằng luồng, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4325](https\://github.com/QuantumNous/new-api/pull/4325)
  * fix\: làm mới khóa Codex kênh tự tắt, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4324](https\://github.com/QuantumNous/new-api/pull/4324)
  * fix\: xác minh đúng khi đổi passkey, bởi @seefs001 tại [https\://github.com/QuantumNous/new-api/pull/4393](https\://github.com/QuantumNous/new-api/pull/4393)

  ### Người đóng góp mới

  * @KoellM đóng góp lần đầu tại [https\://github.com/QuantumNous/new-api/pull/4311](https\://github.com/QuantumNous/new-api/pull/4311)
  * @gaoren002 đóng góp lần đầu tại `#4388`

  **Nhật ký đầy đủ**\: [https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15](https\://github.com/QuantumNous/new-api/compare/v0.12.14...v0.12.15)

  **Tài nguyên tải xuống**

  * [checksums-linux.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-linux.txt) (172 B)
  * [checksums-macos.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-macos.txt) (89 B)
  * [checksums-windows.txt](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/checksums-windows.txt) (87 B)
  * [New-API-App.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.0.12.15.exe) (106.3 MB)
  * [New-API-App.Setup.0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/New-API-App.Setup.0.12.15.exe) (106.6 MB)
  * [new-api-arm64-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-arm64-v0.12.15) (63.7 MB)
  * [new-api-macos-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-macos-v0.12.15) (82.0 MB)
  * [new-api-v0.12.15](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15) (66.0 MB)
  * [new-api-v0.12.15.exe](https\://github.com/QuantumNous/new-api/releases/download/v0.12.15/new-api-v0.12.15.exe) (67.7 MB)
  * [Mã nguồn (zip)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.zip)
  * [Mã nguồn (tar.gz)](https\://github.com/QuantumNous/new-api/archive/refs/tags/v0.12.15.tar.gz)
</Callout>

***