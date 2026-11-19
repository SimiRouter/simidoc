# API hình ảnh gốc Qwen

Phần này dùng thân yêu cầu gốc Qwen, nhưng thống nhất gọi qua gateway của trang này\: `API_URL` là `https://api.dwchainless.com/v1/images/...`, xác thực dùng `API_KEY` của trang này. Tham số yêu cầu giữ `model`, `input.messages`, `parameters`, phản hồi thống nhất là `data[]`; trước tiên hoàn thành một lần gọi một ảnh, sau đó tăng số lượng hoặc tích hợp tác tử.

## Định dạng và tham số yêu cầu

| API                       | Định dạng yêu cầu                   | Tham số chính                                            | Tài liệu chi tiết                                   |
| ------------------------- | ----------------------------------- | -------------------------------------------------------- | --------------------------------------------------- |
| Văn bản thành ảnh         | `POST /v1/images/generations`, JSON | `model`, `input.messages[].content[].text`, `parameters` | [Tham số tạo ảnh và mã bốn ngôn ngữ](/simidoc/vi/apps/api/images/qwen/generations) |
| Chỉnh sửa / ảnh thành ảnh | `POST /v1/images/edits`, JSON       | `content[]` chứa `image` và một `text`, kèm `parameters` | [Tham số chỉnh sửa và mã bốn ngôn ngữ](/simidoc/vi/apps/api/images/qwen/edits)     |

Mẫu dòng 2.0 trên trang hiện tại đặt trong `input.messages` một tin nhắn `user`, mô tả chủ thể, bố cục, phong cách và chữ cần render; khi chỉnh sửa thì thêm URL ảnh đã được cấp quyền hoặc data URL mà mô hình hỗ trợ. Thay nền, chuyển phong cách, sửa chữ trong ảnh và ghép nhiều ảnh là mục tiêu chỉnh sửa, không đặt thêm trường multipart của OpenAI và cũng không bảo đảm giữ chi tiết từng pixel.

### Thông số ảnh

Kích thước ghi ở `parameters.size`, định dạng `width*height`, ví dụ `"2048*2048"`; không phải `"2048x2048"` hoặc `"2K"`. Dòng 2.0 ràng buộc kích thước theo khoảng tổng pixel, giới hạn cụ thể của ảnh đầu vào, chiều rộng, chiều cao và đầu ra phải đối chiếu theo mô hình; giới hạn tổng pixel không đồng nghĩa với giới hạn cạnh dài nhất.

| Ba bậc tính phí theo ảnh của trang này | Cạnh dài nhất của kích thước yêu cầu | Ví dụ pixel |
| -------------------------------------- | ------------------------------------ | ----------- |
| 1K                                     | ≤ 1024 pixel                         | 1024×1024   |
| 2K                                     | > 1024 và ≤ 2048 pixel               | 1536×1024   |
| 4K                                     | > 2048 pixel                         | 2560×1440   |

Bảng này chỉ giải thích bậc tính phí của các mô hình cụ thể trên trang này, không có nghĩa mô hình chấp nhận tham số `1K` / `2K` / `4K`. Gọi qua trang này được quyết toán theo [Mô hình và giá](https://api.dwchainless.com/vi/pricing/), đồng thời tham khảo [tổng quan thông số và tính phí ảnh](/simidoc/vi/apps/api/images). Số pixel lớn hơn không bảo đảm chữ và chi tiết chính xác; khi không hỗ trợ thông số đích phải báo lỗi thay vì âm thầm thay thế.

## Tham số trả về

| Trường trả về           | Ý nghĩa và xử lý                                                                           |
| ----------------------- | ------------------------------------------------------------------------------------------ |
| `created`               | Dấu thời gian phản hồi được tạo.                                                           |
| `data[].url`            | URL ảnh cuối cùng; thời hạn hiệu lực do kênh quyết định, cần tải xuống và lưu kịp thời.    |
| `data[].b64_json`       | Một số kênh trả Base64 thuần; khi có thể giải mã trực tiếp và lưu.                         |
| `data[].revised_prompt` | Lời nhắc sau khi kênh viết lại; có thể không tồn tại.                                      |
| `error` / `message`     | Mã lỗi và mô tả; HTTP thành công vẫn cần kiểm tra lỗi nghiệp vụ và ảnh có thực sự tồn tại. |

Thân yêu cầu là cấu trúc gốc Qwen, phản hồi là `data[]` thống nhất. Không sao chép nguyên giao thức `prompt`, multipart hoặc `task_id` bất đồng bộ của kênh khác; ID mô hình phải khớp với tên mà kênh của trang này thực tế cung cấp.

## Ví dụ gọi API

### Chuẩn bị cấu hình

Đối chiếu mô hình khả dụng và số dư tại [Mô hình và giá](https://api.dwchainless.com/vi/pricing/), và dùng Key được tạo trên trang này. `API_URL` luôn trỏ tới gateway của trang này, không cần ID không gian làm việc, tên miền khu vực hay Key chính thức của Bailian.

| Cấu hình    | Mục đích                                                                                                                                  |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `API_KEY`   | Khóa của trang này; điền trực tiếp trong ví dụ, không dán vào lời nhắc, mã, ảnh chụp hay Git.                                             |
| `API_URL`   | Địa chỉ yêu cầu đầy đủ của gateway trang này, như `https://api.dwchainless.com/v1/images/generations`.                                    |
| `model`     | Ví dụ hiện có là `qwen-image-2.0-pro`; trước tiên xác nhận kênh của trang này hỗ trợ mô hình và năng lực cần thiết.                       |
| `IMAGE_URL` | Địa chỉ ảnh HTTP(S) đã được cấp quyền, truy cập được từ đám mây dùng cho ví dụ chỉnh sửa, không phải đường dẫn máy cục bộ hoặc localhost. |

[Ví dụ tạo](/simidoc/vi/apps/api/images/qwen/generations) và [ví dụ chỉnh sửa](/simidoc/vi/apps/api/images/qwen/edits) đều cung cấp Python, Node.js, curl, Go. Mã hiện tại gửi một yêu cầu và in JSON, **không tự động tải ảnh**. Lưu mã Python thành `generate.py` / `edit.py`, chạy `python3 generate.py` / `python3 edit.py`; lưu Node.js thành `generate.mjs` / `edit.mjs`, chạy `node generate.mjs` / `node edit.mjs`. Cấu hình môi trường chạy và biến theo yêu cầu của trang tương ứng, trước tiên chỉ yêu cầu một ảnh, sau đó lưu ảnh thật mà URL trỏ tới theo phần dưới.

### Demo tác tử tạo ảnh

Tác tử cần khả năng chạy mã cục bộ, gửi yêu cầu mạng và kiểm tra kết quả trả về; trang này không phải chỉ dẫn cài Skill, cũng không bổ sung các năng lực đó cho máy khách chỉ có văn bản.

```text
Read this Qwen image protocol page and its generation reference first. Use the
existing API_KEY and API_URL from this site's gateway; never print, paste, commit,
or store the key in source files. Use the documented qwen-image-2.0-pro model only
after checking availability and pricing. For this one approved request, POST once
to /v1/images/generations with the native Qwen body: one user message, one text
content item, parameters.n=1 and size=1024*1024 if supported. Image brief: a calm
blue library with a small robot reading, watercolor illustration, no lettering.
Print the returned JSON and inspect data[].url or data[].b64_json; report the final
image URL without forwarding the API key. JSON or a URL alone is not a saved image.
Do not switch model/provider, increase size/count, write files, install remote
skills, or automatically retry an error or timeout. Ask before another paid request.
```

### Demo tác tử chỉnh sửa ảnh

Chỉ dùng ảnh đã được cấp quyền xử lý và tải lên; trước tiên kiểm tra thông tin cá nhân và bí mật kinh doanh. Ví dụ hiện tại đọc URL, không tự động công khai tải tệp cục bộ lên dịch vụ khác.

```text
Read this Qwen image protocol page and its editing reference first. Use the existing
API_KEY and API_URL from this site's gateway; never reveal the key or switch the
existing connection. Verify qwen-image-2.0-pro supports the edit. Use only the
authorized cloud-readable image in IMAGE_URL; do not upload unrelated local files or
publish a file. POST once to /v1/images/edits with the native Qwen body: one user
message containing that image item and one text instruction: keep the subject and
layout; change only the background to pale blue. Set parameters.n=1 and size=1024*1024
only if supported. Do not use OpenAI multipart or mask fields. Check the completed
business result, inspect data[].url or data[].b64_json without forwarding the API key,
and report it. Do not write files, change model/size/count/provider, install remote
skills, or retry automatically. If any step fails or the requested edit is not met,
report a redacted error instead of claiming success.
```

## Lưu và xác nhận hoàn tất

* Phản hồi đồng bộ không phải tác vụ thăm dò; phần này không dùng `task_id` hoặc `X-DashScope-Async`. Không trộn giao thức bất đồng bộ của mô hình khác, cũng không dùng sự kiện luồng làm điều kiện hoàn tất.
* Kiểm tra HTTP và lỗi nghiệp vụ, lý do kết thúc và mục ảnh thực tế, rồi duyệt qua các URL ảnh. URL có thời hạn hiệu lực hữu hạn, hãy tải xuống sớm nhất có thể; JSON, địa chỉ hay kết luận bằng lời của tác tử đều không đồng nghĩa tệp đã được lưu.
* Khi tải xuống, kiểm tra trạng thái phản hồi, nội dung và phần đầu tệp, không đổi tên trang lỗi thành PNG; không gửi Key của trang này tới tên miền lưu trữ kết quả. Giữ tệp gốc, khi thất bại chỉ dọn dẹp đầu ra không hợp lệ do lần này tạo ra.
* Xác nhận tệp tồn tại, mở được, kích thước và nội dung đáp ứng yêu cầu, đồng thời đối chiếu yêu cầu và chi phí trong hóa đơn hoặc nhật ký sử dụng của trang này. Với nhiều ảnh, kiểm tra từng mục, không tự động gọi lại để bù đủ số lượng.

## Lỗi, thử lại và chi phí

Với lỗi tham số, trước tiên kiểm tra `model`, cấu trúc tin nhắn, `size` và ảnh đầu vào; với lỗi xác thực, trước tiên đối chiếu Key của trang này và quyền mô hình; với lỗi hạn mức hoặc giới hạn tốc độ, trước tiên kiểm tra trạng thái tài khoản. Khi hết thời gian chờ, gặp 5xx hoặc kết quả chưa rõ ràng, trước tiên tra nhật ký gọi và tệp hiện có, không tự động gửi lại, tránh tạo ảnh hoặc trừ phí lặp. Chỉ báo lỗi đã che dữ liệu nhạy cảm, không xuất khóa, Base64 đầy đủ hay ảnh riêng tư.

Tạo và chỉnh sửa thật có thể phát sinh phí. Trước khi gọi, xác nhận mô hình, kích thước, số ảnh và vị trí đầu ra; việc tăng thêm, nâng cấp thông số hoặc thử lại phải xác nhận lại. Các yêu cầu song song kiểm soát riêng giới hạn tốc độ, thời gian chờ và chi phí; `n` là số lượng trong một yêu cầu. Cách tính giá cuối cùng theo quy tắc và hóa đơn của trang này.

## Tham khảo chính thức

* [Tạo Qwen-Image](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api)
* [Chỉnh sửa Qwen-Image](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api)