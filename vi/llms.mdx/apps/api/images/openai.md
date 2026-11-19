# API hình ảnh định dạng OpenAI

Phần này sử dụng định dạng OpenAI và phân biệt tạo ảnh, chỉnh sửa, tạo ảnh trong hội thoại và hiểu ảnh. Hoàn tất một lần gọi cho một ảnh trước khi tăng số lượng hoặc tích hợp tác tử. Mô hình phải có đúng khả năng hình ảnh cho tác vụ tương ứng.

## Thứ tự gọi

1. **Chuẩn bị cấu hình**\: tạo khóa tại [Quản lý khóa API](https://api.dwchainless.com/keys) và sao chép ID mô hình đầy đủ được hỗ trợ từ [Mô hình và giá](https://api.dwchainless.com/vi/pricing/); địa chỉ yêu cầu là cổng `https://api.dwchainless.com`, header dùng `Authorization: Bearer $API_KEY`.
2. **Chọn endpoint**\: văn bản thành ảnh dùng `POST /v1/images/generations`, chỉnh sửa / ảnh thành ảnh dùng `POST /v1/images/edits`, tạo ảnh trong hội thoại dùng `POST /v1/responses`, hiểu ảnh dùng `POST /v1/chat/completions`.
3. **Gửi yêu cầu tối thiểu trước**\: chỉ yêu cầu một ảnh, không dùng streaming; xác nhận xác thực, mô hình và tham số hợp lệ rồi mới tăng số lượng, kích thước hoặc tích hợp tác tử.
4. **Đọc và xác nhận**\: giải mã Base64 từ `data[]` hoặc tải URL, kiểm tra tệp mở được và kích thước, nội dung đúng yêu cầu, rồi đối chiếu nhật ký sử dụng.

Tham số, ví dụ và xử lý lỗi đầy đủ ở các trang giao thức bên dưới; lần gọi đầu nên bắt đầu từ [tạo ảnh](/simidoc/vi/apps/api/images/openai/generations).

## Định dạng và tham số yêu cầu

| API                       | Định dạng yêu cầu                                 | Tham số chính                                                               | Tài liệu chi tiết                                   |
| ------------------------- | ------------------------------------------------- | --------------------------------------------------------------------------- | --------------------------------------------------- |
| Văn bản thành ảnh         | `POST /v1/images/generations`, JSON               | `model`, `prompt`; đặt `n`, `size`, `quality` tùy mô hình                   | [Tham số tạo ảnh và mã bốn ngôn ngữ](/simidoc/vi/apps/api/images/openai/generations) |
| Chỉnh sửa / ảnh thành ảnh | `POST /v1/images/edits`, chọn JSON hoặc multipart | `model`, `prompt`, `images[]` hoặc tệp `image`; thêm `mask` khi được hỗ trợ | [Tham số chỉnh sửa và mã bốn ngôn ngữ](/simidoc/vi/apps/api/images/openai/edits)     |
| Tạo ảnh trong hội thoại   | `POST /v1/responses`, JSON                        | `input`, công cụ tạo ảnh và cấu hình mô hình tương ứng                      | [Tạo ảnh trong hội thoại](/simidoc/vi/apps/api/images/openai/chat-format)            |
| Hiểu ảnh                  | `POST /v1/chat/completions`, JSON                 | Văn bản trong `messages` và mục `image_url`                                 | [Hiểu ảnh](/simidoc/vi/apps/api/images/openai/vision)                                |

Lệnh chỉnh sửa nên tách rõ phần cần giữ và phần cần đổi. Chuyển phong cách, thay nền, thêm hoặc xóa vật thể là mục tiêu chỉnh sửa, không phải bộ API riêng. Mặt nạ, nhiều ảnh và nền trong suốt cần được mô hình hỗ trợ; không bảo đảm giữ nguyên từng pixel của người, sản phẩm hay chữ.

### Thông số ảnh

`size` là chiều rộng và cao bằng pixel, ví dụ `1024x1024`, không phải bộ giá trị `1K` / `2K` / `4K` dùng chung. Kích thước hợp lệ tùy mô hình. `quality` điều khiển chất lượng tạo ảnh, `output_format` điều khiển mã hóa PNG/JPEG/WebP; chúng không thay thế độ phân giải. Nền trong suốt cần mô hình hỗ trợ `background: transparent` và định dạng PNG hoặc WebP.

Ba cách viết size, bảng tra 14 tỷ lệ và bậc tính phí 1K/2K/4K theo ảnh được tổng hợp tại [tổng quan thông số và tính phí ảnh](/simidoc/vi/apps/api/images). Bảng tính phí chỉ áp dụng cho mô hình được [Mô hình và giá](https://api.dwchainless.com/vi/pricing/) ghi rõ dùng quy tắc này, không bảo đảm mọi kích thước ví dụ đều được hỗ trợ.

## Tham số phản hồi

| Trường / sự kiện                                      | Ý nghĩa và xử lý                                                                                                            |
| ----------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Images `data[].b64_json`                              | Dữ liệu Base64 của GPT Image; giải mã thành ảnh nhị phân, không đổi tên toàn bộ JSON thành PNG.                             |
| Images `data[].url`                                   | Có thể xuất hiện ở mô hình cũ hoặc tương thích có hỗ trợ URL. Tải kịp thời; không coi đây là trường bắt buộc của GPT Image. |
| Images `usage`                                        | Thông tin sử dụng tùy chọn; có trường này không đồng nghĩa tính phí Token.                                                  |
| `image_generation.completed` / `image_edit.completed` | Sự kiện cuối cho tạo / sửa ảnh dạng luồng của Images; `partial_image` chỉ là bản xem trước.                                 |
| Responses `output[]`                                  | Xử lý mục đầu ra của công cụ ảnh; không áp dụng cấu trúc Images `data[]`.                                                   |
| Chat `choices[].message.content`                      | Văn bản phân tích từ hiểu ảnh, không phải ảnh được tạo.                                                                     |

## Ví dụ gọi API

### Chuẩn bị cấu hình

Tạo khóa tại [Quản lý khóa API](https://api.dwchainless.com/keys), sao chép ID đầy đủ của mô hình ảnh mà khóa hiện tại được dùng từ [Mô hình và giá](https://api.dwchainless.com/vi/pricing/), rồi kiểm tra quyền, nhóm tính phí và hạn mức.

| Biến        | Mục đích                                                                                  |
| ----------- | ----------------------------------------------------------------------------------------- |
| `API_KEY`   | Bắt buộc; điền trực tiếp trong ví dụ, không dán vào lời nhắc, mã nguồn, ảnh chụp hay Git. |
| `MODEL`     | Bắt buộc; xác nhận mô hình hỗ trợ endpoint tạo hoặc chỉnh sửa tương ứng.                  |
| `API_URL`   | URL yêu cầu đầy đủ; ví dụ dùng cổng `https://api.dwchainless.com`.                        |
| `IMAGE_URL` | URL HTTPS dùng trong ví dụ chỉnh sửa; máy chủ phải truy cập được ảnh PNG, JPEG hoặc WebP. |

[Ví dụ tạo ảnh](/simidoc/vi/apps/api/images/openai/generations) và [ví dụ chỉnh sửa](/simidoc/vi/apps/api/images/openai/edits) có Python, Node.js, curl và Go. Chọn một ngôn ngữ, trước tiên chỉ yêu cầu một ảnh không truyền luồng. Mẫu Python 3.8+ và Node.js 20+ chỉ dùng thư viện chuẩn. Lưu mã tạo thành `generate.py` hoặc `generate.mjs`, mã sửa thành `edit.py` hoặc `edit.mjs`, rồi chạy tương ứng, ví dụ `python3 generate.py` hoặc `node generate.mjs`. Ví dụ chỉnh sửa Python và Node.js đều dùng JSON `images[].image_url`, không dùng multipart.

### Demo tác tử tạo ảnh

Tác tử phải chạy được mã cục bộ, đọc ảnh được cấp quyền và kiểm tra phản hồi. Trang này không cài Skill, cũng không tự cấp công cụ cho máy khách chỉ trò chuyện văn bản. Giữ nguyên kết nối có sẵn, không tự đổi dịch vụ.

```text
Read this OpenAI image protocol page and its generation reference first. Use the
SimiRouter request URL in API_URL (default gateway https://api.dwchainless.com) and the
image model in MODEL. Set API_KEY directly in the example; never print, paste, commit,
or store it in source files. For this one approved request, use POST
/v1/images/generations with n=1, size=1024x1024, stream=false and output_format=png only
after verifying the model supports these parameters. Image brief: a calm blue library
with a small robot reading, watercolor illustration, no lettering. Print the returned
JSON and inspect data[].b64_json; do not write an image file. Confirm that
data[].b64_json contains non-empty Base64 data before reporting completion. Do not
install remote skills, switch providers/models/billing groups, increase size/count,
write files, or retry after timeout or ambiguous failure without approval. If the
request or validation fails, report a redacted error, not success.
```

### Demo tác tử chỉnh sửa ảnh

Kiểm tra quyền xử lý ảnh tham chiếu và thông tin cá nhân hoặc bí mật kinh doanh; chỉ cấp quyền cho tệp cần dùng. Yêu cầu “giữ nguyên” là mục tiêu, không phải bảo đảm từng pixel.

```text
Read this OpenAI image protocol page and its editing reference first. Set API_KEY,
MODEL, and API_URL directly in the example; use the configured SimiRouter request URL;
never reveal the key or change the existing connection. Use only the authorized HTTPS
image URL in IMAGE_URL. Use POST /v1/images/edits with JSON images[]; do not set
multipart Content-Type or send local files. Keep the subject and layout; change only the
background to pale blue. Request one PNG at 1024x1024 with stream=false only if the
selected model supports it. Print the returned JSON and inspect data[].b64_json; do not
write an image file. Confirm that data[].b64_json contains non-empty Base64 data and
report any unmet requirement. Do not upload unrelated files, change
size/count/model/provider, install remote skills, or retry automatically after an error
or timeout. Ask before another paid request.
```

## Lưu và xác nhận hoàn tất

* Kiểm tra trạng thái HTTP, trường ảnh cuối, kết quả giải mã và định dạng tệp thực. Đổi phần mở rộng không chuyển đổi định dạng. Khi lỗi, chỉ xóa tệp không hợp lệ vừa tạo, không xóa tệp có sẵn.
* Bắt đầu bằng một ảnh không truyền luồng. Với luồng, phải đợi `completed` tương ứng và xử lý nhiều ảnh theo chỉ số. Thiếu trạng thái cuối thì không coi xem trước là hoàn tất. Images chuẩn không phải hàng đợi bất đồng bộ chung trả ID tác vụ để thăm dò.
* Xác nhận tệp tồn tại, mở được, đúng kích thước và nội dung, rồi đối chiếu nhật ký sử dụng. HTTP thành công hoặc lời tác tử nói “xong” chưa chứng minh ảnh đã lưu.

## Lỗi, thử lại và chi phí

400\: kiểm tra mô hình và tham số; 401\: kiểm tra khóa; 403/404\: kiểm tra quyền, ID và đường dẫn; 429\: kiểm tra hạn mức và tốc độ. Sau 5xx, hết thời gian hoặc đứt luồng, xem nhật ký và kết quả đã có trước, không tự gửi lại để tránh tạo và tính phí trùng. Chỉ báo lỗi đã che dữ liệu nhạy cảm và mã yêu cầu, không xuất khóa, Base64 đầy đủ hay nội dung ảnh riêng tư.

Tạo và sửa thật có thể phát sinh phí. Trước khi gọi, xác nhận mô hình, kích thước, số ảnh và nơi lưu. Tăng `n`, tăng bậc, đổi mô hình hoặc thử lại phải được xác nhận lại. Yêu cầu song song cần giới hạn tốc độ, thời gian và phí riêng; `n` là số ảnh trong một yêu cầu, không phải mức song song. Phí cuối theo giá mô hình hiện tại và nhật ký sử dụng.

## Tài liệu chính thức

* [Hướng dẫn tạo ảnh OpenAI](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Images API](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [Đầu vào hình ảnh OpenAI](https\://developers.openai.com/api/docs/guides/images-vision)