# API hình ảnh Gemini

Phần này dùng cấu trúc `contents/parts` gốc của Gemini GenerateContent. Tạo và sửa ảnh cần mô hình hỗ trợ đầu ra hình ảnh; thêm tham số không biến mô hình văn bản thành mô hình tạo ảnh. Hoàn tất một tác vụ một ảnh trước khi tăng số lượng hoặc tích hợp tác tử.

## Định dạng và tham số yêu cầu

| API                       | Định dạng yêu cầu                                   | Tham số chính                                                               | Tài liệu chi tiết                                          |
| ------------------------- | --------------------------------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------- |
| Văn bản thành ảnh         | `POST /v1beta/models/{model}:generateContent`, JSON | `contents[].parts[].text`, `generationConfig`                               | [Tham số tạo ảnh và mã bốn ngôn ngữ](/simidoc/vi/apps/api/images/gemini/generate)           |
| Chỉnh sửa / ảnh thành ảnh | Cùng endpoint `generateContent`                     | `text` và Part ảnh riêng\: `inlineData` hoặc `fileData` được mô hình hỗ trợ | [Tham số chỉnh sửa và mã bốn ngôn ngữ](/simidoc/vi/apps/api/images/gemini/edits)            |
| Hiểu ảnh                  | Cùng endpoint `generateContent`                     | Ảnh và câu hỏi; mục tiêu là phân tích văn bản, không phải đầu ra ảnh        | [Nhận diện đa phương tiện Gemini](/simidoc/vi/apps/api/chat/gemini-media) |

Tạo ảnh chỉ cần văn bản; chỉnh sửa thêm ảnh tham chiếu và nêu rõ phần giữ lại, phần thay đổi. Chuyển phong cách, thay nền, ghép nhiều ảnh là mục tiêu chỉnh sửa, không có đường dẫn `/images/edits` riêng. `contents`, `candidates` của GenerateContent khác `input`, `steps`, `response_format` của Interactions; không trộn chúng.

### Thông số ảnh

Nếu được hỗ trợ, dùng `generationConfig.imageConfig.aspectRatio` để đặt tỷ lệ như `1:1`, và `generationConfig.imageConfig.imageSize` để đặt độ phân giải như `1K`, `2K`, `4K`. Đây không phải khả năng chung của mọi mô hình Gemini, cũng không thay bằng `size` của OpenAI. Số pixel thực tùy tỷ lệ và phiên bản mô hình; định dạng dựa vào MIME thực trả về.

| Bậc tính phí theo ảnh của trang này | Cạnh dài của kích thước yêu cầu | Ví dụ pixel |
| ----------------------------------- | ------------------------------- | ----------- |
| 1K                                  | ≤ 1024 pixel                    | 1024×1024   |
| 2K                                  | > 1024 và ≤ 2048 pixel          | 1536×1024   |
| 4K                                  | > 2048 pixel                    | 2560×1440   |

Bảng là quy tắc phí của một số mô hình trên trang này, không phải định nghĩa chung của Google về tên độ phân giải. Chỉ áp dụng khi [Mô hình và giá](https://api.dwchainless.com/vi/pricing/) ghi rõ; không áp dụng cho phí Token hoặc quy tắc khác. Độ phân giải cao không bảo đảm chữ hay chi tiết chính xác. Nếu không hỗ trợ thông số yêu cầu, phải báo lỗi thay vì tự hạ bậc. Xem [tổng quan thông số và tính phí ảnh](/simidoc/vi/apps/api/images).

## Tham số phản hồi

| Trường                                         | Ý nghĩa và xử lý                                                                                                       |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `candidates[]`                                 | Danh sách ứng viên; lọc an toàn hoặc lỗi có thể khiến không có ảnh hợp lệ.                                             |
| `candidates[].content.parts[]`                 | Duyệt văn bản và ảnh theo thứ tự, không giả định mục đầu là ảnh.                                                       |
| `parts[].inlineData.mimeType` / `.data`        | MIME ảnh thực và Base64 thuần; giải mã, chọn phần mở rộng theo MIME.                                                   |
| `parts[].thought` / `.thoughtSignature`        | Không coi ảnh suy nghĩ trung gian là ảnh cuối; giữ chữ ký không trong suốt mà mô hình trả về cho chỉnh sửa nhiều lượt. |
| `candidates[].finishReason` / `promptFeedback` | Kiểm tra kết thúc bình thường và lọc an toàn, không chỉ dựa HTTP 200 để báo thành công.                                |
| `usageMetadata`                                | Dữ liệu sử dụng tùy chọn; phí theo quy tắc áp dụng và nhật ký.                                                         |

## Ví dụ gọi API

### Chuẩn bị cấu hình

Tạo khóa ở [Quản lý khóa API](https://api.dwchainless.com/keys), sao chép ID đầy đủ của mô hình có sẵn, hỗ trợ đầu ra ảnh GenerateContent từ [Mô hình và giá](https://api.dwchainless.com/vi/pricing/). Kiểm tra nhóm, hạn mức và khả năng chỉnh sửa.

| Biến           | Mục đích                                                                                                                        |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `API_KEY`      | Bắt buộc; điền trực tiếp trong ví dụ, không đưa vào lời nhắc, mã, ảnh chụp hay Git.                                             |
| `MODEL`        | Bắt buộc; mô hình ảnh Gemini dùng trong đường dẫn.                                                                              |
| `API_URL`      | URL yêu cầu đầy đủ; ví dụ dùng cổng `https://api.dwchainless.com`.                                                              |
| `IMAGE_BASE64` | Thay bằng Base64 thuần của ảnh được phép dùng (không có tiền tố `data:`); định dạng và kích thước phải phù hợp mô hình đã chọn. |

[Ví dụ tạo](/simidoc/vi/apps/api/images/gemini/generate) và [ví dụ sửa](/simidoc/vi/apps/api/images/gemini/edits) có Python, Node.js, curl và Go. Chọn một ngôn ngữ, bắt đầu bằng một lần gọi không truyền luồng. Lưu Python thành `generate.py` / `edit.py` và chạy `python3 generate.py` / `python3 edit.py`. Mẫu Node.js dùng await cấp cao nhất (ESM)\: lưu `generate.mjs` / `edit.mjs`, chạy `node generate.mjs` / `node edit.mjs`.

### Demo tác tử tạo ảnh

Tác tử cần chạy mã cục bộ và kiểm tra phản hồi. Quy trình không cài Skill từ xa hoặc đổi kết nối có sẵn; máy khách chỉ có văn bản không thể thực thi trực tiếp.

```text
Read this Gemini protocol page and the GenerateContent image generation reference first.
Use the configured SimiRouter request URL in API_URL (default gateway
https://api.dwchainless.com) and MODEL. Set API_KEY directly in the example; never
print, paste, commit, or store it in source files. For this one approved task, call POST
/v1beta/models/{model}:generateContent once, non-streaming, Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. with a text Part describing a calm blue library with a small robot reading,
watercolor, no lettering. Request one image; use imageConfig aspectRatio=1:1 and
imageSize=1K only if the model supports them. Do not invent an n parameter or mix
Interactions fields into GenerateContent. After the response, read only completed,
non-thought inlineData from parts; decode the Base64 in memory and report any unmet
requirement; do not write an image file. Do not switch providers/models/billing groups,
increase size/count, write files, install remote skills, or retry an ambiguous failure
without approval. Report a redacted error instead of false success.
```

### Demo tác tử chỉnh sửa ảnh

Chỉ đọc ảnh tham chiếu được cấp quyền, kiểm tra dữ liệu cá nhân và bí mật kinh doanh. Sửa nhiều lượt cần đầy đủ ngữ cảnh do mô hình trả về; không tùy tiện bỏ chữ ký. Yêu cầu “giữ nguyên” không bảo đảm từng pixel.

```text
Read this Gemini protocol page and its image editing reference first. Use the existing
API_KEY, MODEL and configured SimiRouter request URL; never reveal credentials or change
the existing connection. Read only the authorized local image, encode it as pure Base64,
and put it in IMAGE_BASE64. Submit its inlineData Part alongside the text instruction
through POST /v1beta/models/{model}:generateContent. Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. Keep the subject and layout; change only the background to pale blue. Request one
image, non-streaming; use aspectRatio=1:1 and imageSize=1K only if supported. Do not use
OpenAI multipart or mask fields. After the response, read only completed, non-thought
inlineData from parts; decode the Base64 in memory and report any unmet requirement; do
not write an image file. Preserve opaque signatures for later turns. Do not upload
unrelated files, overwrite results, change model/size/count/provider, install remote
skills, or retry automatically. Ask before any additional paid request.
```

## Lưu và xác nhận hoàn tất

* Kiểm tra trạng thái HTTP, `finishReason` và nội dung ảnh. Chỉ có văn bản, bị lọc, thiếu ảnh cuối hoặc sai định dạng thì báo chưa hoàn tất; không lưu toàn bộ JSON thành ảnh.
* Giải mã Base64 chặt chẽ, đối chiếu định dạng thực và MIME, kiểm tra tệp mở được, đúng kích thước và nội dung. Giữ tệp cũ; khi lỗi chỉ dọn đầu ra không hợp lệ vừa tạo.
* Chỉ dùng `streamGenerateContent?alt=sse` khi mô hình hỗ trợ; đoạn bất kỳ không phải ảnh cuối. `generateContent` trả kết quả đồng bộ đầy đủ, không có ID tác vụ chung để thăm dò; Google Batch là dịch vụ riêng, không phải endpoint này.
* Lưu từng mục ảnh và kiểm tra số lượng. Viết “một ảnh” không bảo đảm mọi mô hình trả đúng một ảnh; không tự gọi thêm để bù số lượng khi chưa được cho phép.

## Lỗi, thử lại và chi phí

400\: kiểm tra mô hình, trường và ảnh tham chiếu; 401/403\: quyền khóa; 404\: mô hình và đường dẫn; 429\: hạn mức và tốc độ. Khi hết thời gian, 5xx hoặc thiếu kết thúc đầy đủ, xem nhật ký và tệp có sẵn trước, không tự gửi lại. Chỉ báo lỗi đã che dữ liệu nhạy cảm và mã yêu cầu, không xuất khóa, Base64 đầy đủ hay ảnh riêng tư.

Tạo và sửa thật có thể phát sinh phí. Trước khi gọi, xác nhận mô hình, thông số, số lượng và nơi lưu; tăng bậc, thêm ảnh, đổi mô hình hay thử lại cần xác nhận mới. Yêu cầu song song phải quản lý tốc độ, thời gian và phí riêng. Có trường sử dụng không đồng nghĩa phí Token. Phí cuối theo giá hiện tại và nhật ký sử dụng.

## Tài liệu chính thức

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Tạo và chỉnh sửa ảnh Google](https\://ai.google.dev/gemini-api/docs/image-generation)