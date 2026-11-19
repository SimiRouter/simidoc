# Hình ảnh

Chọn **giao thức API** trước, sau đó xác định **hiệu ứng** cần thực hiện, cuối cùng kiểm tra **kích thước, chất lượng, định dạng và số lượng**. Giao thức quyết định cấu trúc yêu cầu và phản hồi, hiệu ứng do năng lực mô hình và lời nhắc cùng quyết định, thông số quyết định yêu cầu đầu ra; không được trộn lẫn ba khái niệm này.

Tạo và chỉnh sửa trả về hình ảnh; hiểu hình ảnh nhận hình ảnh làm đầu vào và trả về văn bản hoặc kết quả có cấu trúc. Mô hình văn bản thông thường không có khả năng tạo ảnh chỉ vì thêm tham số hình ảnh. Trước khi gọi, hãy xác nhận ID mô hình chính xác, hỗ trợ API, nhóm tính phí và hạn mức tại [Mô hình và giá](https://api.dwchainless.com/vi/pricing/); yêu cầu thực tế có thể phát sinh phí.

## Tổng quan

| Bạn muốn làm gì               | Đầu vào                                  | Đầu ra                         | Điểm cuối điển hình           |
| ----------------------------- | ---------------------------------------- | ------------------------------ | ----------------------------- |
| Tạo ảnh từ văn bản            | Lời nhắc                                 | Ảnh mới                        | `POST /v1/images/generations` |
| Sửa ảnh đã có                 | Lời nhắc + một hoặc nhiều ảnh tham chiếu | Ảnh đã chỉnh sửa               | `POST /v1/images/edits`       |
| Vừa trò chuyện vừa tạo ảnh    | Tin nhắn hội thoại + công cụ hình ảnh    | Kết quả kết hợp ảnh và văn bản | `POST /v1/responses`          |
| Để mô hình xem ảnh và trả lời | Ảnh + câu hỏi                            | Văn bản, không phải ảnh mới    | `POST /v1/chat/completions`   |

## Khái niệm cốt lõi

Trước hết hãy phân biệt ba loại con số, khi đó các tham số và giá phía sau mới dễ hiểu\:

* **Kích thước pixel**\: chiều rộng × chiều cao thực tế, ví dụ `1024x1024`. Nó quyết định độ phân giải thực của tệp, không phải dung lượng tệp và cũng không tương đương bậc chất lượng.
* **Tỷ lệ khung hình**\: các tỷ lệ như `1:1`, `16:9`, `9:16`, chỉ quyết định hình dạng khung hình. Cùng một tỷ lệ có thể ứng với nhiều kích thước pixel; chỉ nêu tỷ lệ không có nghĩa là đã chỉ định kích thước đầu ra.
* **Bậc độ phân giải**\: các bậc như `1K`, `2K`, `4K`. Bậc gốc của hãng được định nghĩa theo cạnh dài nhất hoặc theo dòng sản phẩm, còn bậc tính phí theo ảnh của trang này được xếp theo cạnh dài nhất; hai bên có thể cùng tên nhưng ranh giới không nhất thiết trùng nhau và không thể suy ra lẫn nhau.

Còn có ba hiểu lầm phổ biến\: `quality` điều khiển chất lượng kết xuất chứ không phải chất lượng nén; PNG, JPEG, WebP là định dạng tệp, đổi phần mở rộng không chuyển đổi định dạng; Base64 và URL chỉ là cách bàn giao, không phải độ phân giải. Xem đối chiếu từng mục ở mục 4 bên dưới, “Thông số ảnh và tính phí”.

## 1. Các API\: chọn theo giao thức

Ba bộ giao thức có tham số yêu cầu, tham số trả về và ví dụ độc lập. Cách gọi bằng script, sử dụng trong tác tử, lưu kết quả và xử lý thất bại cũng được mô tả trong từng giao thức, không cần đọc trước một hướng dẫn chung chỉ dành cho OpenAI.

| Giao thức               | API / khả năng                                       | Điểm cuối yêu cầu                                      | Kết quả chính                                              | Tài liệu                                                 |
| ----------------------- | ---------------------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------------- | -------------------------------------------------------- |
| OpenAI                  | Tạo ảnh từ văn bản                                   | `POST /v1/images/generations`                          | `data[].b64_json`; mô hình tương thích cũng có thể trả URL | [Tạo ảnh](/simidoc/vi/apps/api/images/openai/generations)                          |
| OpenAI                  | Chỉnh sửa ảnh / tạo ảnh từ ảnh                       | `POST /v1/images/edits`                                | Ảnh đã chỉnh sửa                                           | [Chỉnh sửa](/simidoc/vi/apps/api/images/openai/edits)                              |
| OpenAI                  | Tạo ảnh hội thoại                                    | `POST /v1/responses`, dùng công cụ `image_generation`  | Kết quả công cụ hình ảnh trong `output[]`                  | [Tạo ảnh hội thoại](/simidoc/vi/apps/api/images/openai/chat-format)                |
| OpenAI                  | Hiểu hình ảnh                                        | `POST /v1/chat/completions`, nhập `image_url`          | Phân tích văn bản, không tạo ảnh                           | [Hiểu hình ảnh](/simidoc/vi/apps/api/images/openai/vision)                         |
| Gemini                  | Tạo ảnh từ văn bản                                   | `POST /v1beta/models/{model}:generateContent`          | `candidates[].content.parts[].inlineData`                  | [Tạo ảnh](/simidoc/vi/apps/api/images/gemini/generate)                             |
| Gemini                  | Chỉnh sửa ảnh / sửa nhiều lượt                       | Như trên, trộn văn bản và hình ảnh                     | Hình ảnh trong các mục nội dung trả về                     | [Chỉnh sửa](/simidoc/vi/apps/api/images/gemini/edits)                              |
| Gemini                  | Hiểu hình ảnh                                        | Như trên, dùng mô hình hỗ trợ đầu vào thị giác         | Phân tích văn bản                                          | [Nhận diện phương tiện](/simidoc/vi/apps/api/chat/gemini-media)            |
| Qwen                    | Tạo ảnh / chỉnh sửa ảnh                              | `POST /v1/images/generations`, `POST /v1/images/edits` | `data[].url` hoặc `data[].b64_json`                        | [Tạo ảnh](/simidoc/vi/apps/api/images/qwen/generations), [Chỉnh sửa](/simidoc/vi/apps/api/images/qwen/edits) |
| Jimeng / Volcengine Ark | Tạo ảnh từ văn bản / tạo từ ảnh tham chiếu           | `POST /api/v3/images/generations`                      | `data[].url` hoặc `data[].b64_json`                        | [Tạo ảnh](/simidoc/vi/apps/api/images/jimeng)                                      |
| xAI Grok                | Tạo ảnh từ văn bản / tạo nhiều ảnh                   | `POST /v1/images/generations`                          | `data[].url` hoặc `data[].b64_json`                        | [Tạo ảnh](/simidoc/vi/apps/api/images/grok)                                        |
| BFL FLUX                | Tạo ảnh từ văn bản / từ ảnh tham chiếu (bất đồng bộ) | `POST /v1/flux-pro-1.1` và tương tự                    | Trước lấy `polling_url`, hoàn tất rồi lấy `result.sample`  | [Tạo ảnh](/simidoc/vi/apps/api/images/flux)                                        |

**Phần Qwen này dùng nội dung yêu cầu gốc của Qwen, gọi qua `/v1/images/generations` và `/v1/images/edits` của cổng kết nối trang này, trả về thống nhất dưới dạng `data[]`.** Không viết lại nội dung thành trường `prompt` của OpenAI; ID mô hình phải dùng tên do kênh thực tế của trang này cung cấp. Jimeng dùng nội dung yêu cầu gốc của Volcengine Ark; đường dẫn của Grok giống OpenAI Images, nhưng tham số khung hình đổi thành `aspect_ratio` và `resolution`; FLUX không tạo ảnh đồng bộ, phải gửi tác vụ trước rồi thăm dò `polling_url`. Ba bên không thể sao chép trường của nhau.

Cách gọi cũng khác nhau theo giao thức\: yêu cầu thông thường của OpenAI Images chờ kết quả đầy đủ, chỉ mô hình được hỗ trợ mới dùng được luồng sự kiện hình ảnh; Gemini phát trực tuyến dùng `streamGenerateContent?alt=sse`; ví dụ Qwen trong thư mục này dùng trả về đồng bộ; Grok mặc định đồng bộ, cũng có thể dùng `deferred` để chuyển thành tác vụ trì hoãn; FLUX thì cố định là thăm dò bất đồng bộ. Chúng đều không thể biến thành hàng đợi tác vụ chung chỉ bằng cách thêm tham số “bất đồng bộ”. Yêu cầu, đầu ra và cách xác định hoàn tất cụ thể xem mô tả riêng của [OpenAI](/simidoc/vi/apps/api/images/openai), [Gemini](/simidoc/vi/apps/api/images/gemini), [Qwen](/simidoc/vi/apps/api/images/qwen), [Jimeng](/simidoc/vi/apps/api/images/jimeng), [Grok](/simidoc/vi/apps/api/images/grok), [FLUX](/simidoc/vi/apps/api/images/flux).

## 2. Các hiệu ứng\: chọn theo mục tiêu

“Màu nước”, “đổi nền”, “ghép sản phẩm”… thường là tác vụ tạo hoặc chỉnh sửa, không phải các API độc lập. Dưới đây là phân loại tác vụ, không phải cam kết năng lực cho mọi mô hình; hãy xác nhận phạm vi hỗ trợ trong giao thức và mô tả mô hình tương ứng trước.

| Hiệu ứng muốn có                                             | Trọng tâm đầu vào và lời nhắc                                              | Lựa chọn và giới hạn giao diện                                                                                                      |
| ------------------------------------------------------------ | -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Sáng tạo từ đầu\: minh họa, bìa, áp phích, hình ảnh thực tế  | Mô tả chủ thể, bố cục, phong cách, ánh sáng và chữ cần hiển thị            | Chọn tạo ảnh từ văn bản; cần kiểm tra chữ và chi tiết                                                                               |
| Biến thể ảnh tham chiếu\: giữ chủ thể hoặc bố cục để tạo lại | Cung cấp ảnh tham chiếu, nêu riêng phần giữ lại và phần thay đổi           | Chọn chỉnh sửa ảnh / tạo ảnh từ ảnh; không bảo đảm giữ nguyên từng pixel                                                            |
| Chuyển phong cách\: ảnh chụp sang màu nước, nét vẽ…          | Ảnh tham chiếu cộng phong cách đích, nêu rõ có giữ chủ thể và bố cục không | Chọn mô hình chỉnh sửa hỗ trợ ảnh tham chiếu                                                                                        |
| Thay nền, thêm bớt phần tử, sửa cục bộ                       | Nêu rõ vùng cần sửa; cung cấp mặt nạ khi được hỗ trợ                       | Chọn giao diện chỉnh sửa; hỗ trợ mặt nạ và quy tắc thay đổi theo mô hình                                                            |
| Ghép nhiều ảnh\: sản phẩm, nhân vật và bối cảnh              | Nêu mục đích từng ảnh tham chiếu, quan hệ chủ thể và bố cục cuối           | Chọn mô hình chỉnh sửa hỗ trợ nhiều ảnh vào, kiểm tra giới hạn số ảnh                                                               |
| Lặp nhiều lượt\: sửa tiếp dựa trên ảnh trước                 | Giữ nội dung lịch sử hoặc thông tin tham chiếu theo yêu cầu giao thức      | Chọn giao diện hỗ trợ làm việc với hình ảnh nhiều lượt; không thể giả định ngữ cảnh hình ảnh vẫn còn chỉ vì đã lưu một đoạn văn bản |
| Tư liệu nền trong suốt                                       | Nêu rõ cần kênh trong suốt thật, không phải nền trắng hay họa tiết bàn cờ  | Chỉ chọn nền trong suốt và định dạng đầu ra giữ được kênh trong suốt khi mô hình hỗ trợ                                             |
| Nhận diện ảnh, trích xuất chữ, hỏi đáp về biểu đồ            | Nhập ảnh và nêu mục tiêu phân tích                                         | Chọn giao diện hiểu hình ảnh, trả về văn bản thay vì ảnh đã chỉnh sửa                                                               |

Có thể tham khảo các năng lực và giới hạn này tại [Tạo ảnh OpenAI](https\://developers.openai.com/api/docs/guides/image-generation), [Tạo và chỉnh sửa ảnh Gemini](https\://ai.google.dev/gemini-api/docs/image-generation), [Chỉnh sửa ảnh Qwen](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api). Ví dụ chính thức không có nghĩa kênh hiện tại của cổng kết nối đã mở cùng năng lực.

## 3. Gọi API\: bốn bước để có ảnh đầu tiên

Dù chọn giao thức nào, việc gọi đều theo cùng thứ tự\: xác nhận cấu hình, chọn điểm cuối, gửi yêu cầu tối thiểu, đọc và nghiệm thu kết quả. Dưới đây chỉ mô tả quy trình chung; trường cụ thể theo trang của giao thức tương ứng.

### 1. Xác nhận địa chỉ yêu cầu, khóa và mô hình

* **Địa chỉ yêu cầu**\: cổng kết nối của trang này là `https://api.dwchainless.com`, đường dẫn điểm cuối thay đổi theo giao thức và thao tác.
* **Khóa**\: tạo tại [Quản lý API key](https://api.dwchainless.com/keys), mang theo khi yêu cầu qua `Authorization: Bearer $API_KEY`; không ghi vào lời nhắc, mã nguồn, ảnh chụp màn hình hay Git.
* **Mô hình**\: sao chép ID mô hình đầy đủ từ [Mô hình và giá](https://api.dwchainless.com/vi/pricing/) và xác nhận mô hình hỗ trợ điểm cuối đích. Tạo ảnh, chỉnh sửa và hiểu hình ảnh có thể do các mô hình khác nhau cung cấp.

### 2. Chọn điểm cuối và định dạng yêu cầu

Chọn điểm cuối theo bảng giao thức phía trên, sau đó xác nhận định dạng nội dung yêu cầu\:

| Thao tác                       | Điểm cuối (định dạng OpenAI)  | Định dạng yêu cầu                   |
| ------------------------------ | ----------------------------- | ----------------------------------- |
| Tạo ảnh từ văn bản             | `POST /v1/images/generations` | JSON                                |
| Chỉnh sửa ảnh / tạo ảnh từ ảnh | `POST /v1/images/edits`       | JSON `images[]` hoặc multipart      |
| Tạo ảnh hội thoại              | `POST /v1/responses`          | JSON, bật công cụ hình ảnh          |
| Hiểu hình ảnh                  | `POST /v1/chat/completions`   | JSON, mục nội dung chứa `image_url` |

Gemini, Qwen, Jimeng, Grok và FLUX dùng trường yêu cầu gốc của riêng chúng; không thể sao chép trực tiếp các trường của OpenAI sang.

### 3. Gửi yêu cầu tối thiểu

Lần gọi đầu tiên chỉ tạo một ảnh, không dùng phát trực tuyến, trước hết xác nhận xác thực, mô hình và tham số đều hợp lệ. Dưới đây lấy tạo ảnh OpenAI làm ví dụ\:

```bash
API_URL="https://api.dwchainless.com/v1/images/generations"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
    "n": 1,
    "size": "1024x1024",
    "output_format": "png"
  }'
```

Sau khi xác nhận phản hồi bình thường, hãy tăng `n`, điều chỉnh kích thước hoặc bật phát trực tuyến theo nhu cầu. Ví dụ đầy đủ đa ngôn ngữ xem [Tạo ảnh](/simidoc/vi/apps/api/images/openai/generations) và [Chỉnh sửa](/simidoc/vi/apps/api/images/openai/edits).

**Hình thức trả về (minh họa)**\: Base64 trong phản hồi thật rất dài, ở đây chỉ giữ phần đầu; khi thành công hãy xem `data[]` chứ không chỉ HTTP 200.

```json
{
  "created": 1763366400,
  "data": [{ "b64_json": "iVBORw0KGgoAAAANSUhEUg..." }],
  "usage": { "input_tokens": 28, "output_tokens": 4160, "total_tokens": 4188 }
}
```

### 4. Đọc kết quả và nghiệm thu

1. **Kiểm tra trạng thái**\: chỉ 2xx biểu thị yêu cầu thành công; 4xx kiểm tra tham số và quyền, 5xx hoặc quá thời gian hãy xác nhận trước yêu cầu đã được thực thi chưa.
2. **Đọc kết quả**\: lấy ảnh từ `data[]`; GPT Image trả `data[].b64_json`, mô hình tương thích có thể trả `data[].url`; không được giả định luôn có mục đầu tiên.
3. **Lưu ảnh**\: Base64 giải mã thành nhị phân trước, chọn phần mở rộng theo MIME thực tế; URL tải xuống kịp thời, không đính kèm API Key khi tải.
4. **Nghiệm thu**\: kiểm tra tệp có mở được không, kích thước pixel thực, hiệu ứng trong suốt và nội dung, rồi đối chiếu nhật ký sử dụng. HTTP 200, `data[]` rỗng hay bản xem trước giữa luồng đều không có nghĩa ảnh cuối đã được lưu.

## 4. Thông số ảnh và tính phí

### Từng thông số trong yêu cầu điều khiển gì

| Thông số         | Ý nghĩa và ví dụ                                                                   | Điểm dễ nhầm                                                                                                                                          |
| ---------------- | ---------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Kích thước pixel | Chiều rộng × chiều cao thực, ví dụ `1024x1024`, `1536x1024`                        | Không phải dung lượng tệp, cũng không tự động đại diện bậc chất lượng                                                                                 |
| Tỷ lệ khung hình | `1:1` vuông, `16:9` ngang, `9:16` dọc                                              | Cùng tỷ lệ có thể có nhiều độ phân giải; chỉ chọn tỷ lệ chưa chỉ định đủ kích thước pixel                                                             |
| Bậc độ phân giải | Một số mô hình dùng tham số gốc `1K`, `2K`, `4K`                                   | Chiều rộng và cao thực của bậc hãng còn phụ thuộc mô hình và tỷ lệ, không nên đánh đồng trực tiếp với ranh giới pixel tính phí theo ảnh của trang này |
| Chất lượng tạo   | Ví dụ `quality` của OpenAI, điều khiển lựa chọn chất lượng kết xuất của mô hình    | Không phải `size`, cũng không phải chất lượng nén JPEG/WebP; các mô hình khác nhau có thể không có tham số cùng tên                                   |
| Định dạng tệp    | PNG, JPEG, WebP… lấy MIME thực tế trả về làm chuẩn                                 | Base64 và URL là cách bàn giao, không phải định dạng ảnh; đổi phần mở rộng không chuyển đổi định dạng                                                 |
| Nền trong suốt   | Ảnh chứa kênh trong suốt, phù hợp chồng ghép tư liệu                               | Cần mô hình, tham số và định dạng tệp cùng hỗ trợ; ghi “nền trong suốt” không bảo đảm kết quả có kênh trong suốt                                      |
| Số ảnh           | Số lượng tạo hoặc số ứng viên, trường và giới hạn thay đổi theo giao thức, mô hình | Lời nhắc ghi “tạo ba ảnh” không bằng thiết lập số lượng API; nhiều ảnh vào cũng không bằng nhiều ảnh ra                                               |

Cùng một tỷ lệ, khi gấp đôi cạnh thì tổng số pixel thành bốn lần, nhưng không bảo đảm chi tiết hình ảnh hay độ nét tăng cùng bội số. Khi chọn, hãy đáp ứng trước nhu cầu sử dụng, rồi kiểm tra hỗ trợ mô hình, thời gian và giá; không nhất thiết luôn dùng bậc cao nhất.

Trường cụ thể, giá trị khả dụng và ví dụ mã xem tại [Định dạng yêu cầu OpenAI](/simidoc/vi/apps/api/images/openai/generations), [Định dạng yêu cầu Gemini](/simidoc/vi/apps/api/images/gemini/generate), [Định dạng yêu cầu Qwen](/simidoc/vi/apps/api/images/qwen/generations), [Định dạng yêu cầu Jimeng](/simidoc/vi/apps/api/images/jimeng), [Định dạng yêu cầu Grok](/simidoc/vi/apps/api/images/grok), [Định dạng yêu cầu FLUX](/simidoc/vi/apps/api/images/flux). Trong đó tham số chất lượng đầu ra, định dạng và trong suốt của OpenAI xem [cài đặt đầu ra chính thức](https\://developers.openai.com/api/docs/guides/image-generation#customize-image-output); yêu cầu kích thước và đầu ra của Qwen xem [thông số chính thức](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api). Không sao chép trực tiếp tham số của giao thức này sang giao thức khác.

### Khác biệt giữa tính phí theo ảnh 1K, 2K, 4K của trang này

Chỉ các mô hình được ghi rõ tính phí theo ba bậc 1K / 2K / 4K theo ảnh trong [Giá mô hình](https://api.dwchainless.com/vi/pricing/) mới áp dụng bảng dưới đây. Mô hình tính theo Token hoặc đơn giá cố định khác vẫn quyết toán theo quy tắc riêng, không thể chỉ dựa vào tên “mô hình ảnh” để phán đoán cách thu phí.

| Bậc tính phí | Cạnh dài nhất                        | Kích thước ví dụ (pixel) |
| ------------ | ------------------------------------ | ------------------------ |
| 1K           | Cả hai cạnh đều ≤ 1024 pixel         | 1024×1024                |
| 2K           | Cạnh dài nhất > 1024 và ≤ 2048 pixel | 1280×720, 1536×1024      |
| 4K           | Một trong hai cạnh > 2048 pixel      | 2560×1440, 3840×2160     |

**Tổng giá = giá mỗi ảnh của bậc hiện tại × số ảnh tính phí.** Các giao diện hỗ trợ quyết toán theo kết quả hoàn thành sẽ tính theo số ảnh thực tế hoàn thành; bản xem trước giữa luồng không tính là ảnh hoàn thành. Giá mỗi ảnh, nhóm và khoản khấu trừ cuối cùng theo giá mô hình hiện tại và nhật ký sử dụng; trang này không cố định con số giá.

Khi áp dụng quy tắc ba bậc theo ảnh nêu trên, chỉ khi không chỉ định bậc kích thước hợp lệ khác thì việc bỏ `size` hoặc dùng `auto` mới mặc định tính theo bậc 1K; trường độ phân giải gốc được chỉ định rõ vẫn quyết định bậc tính phí. Phân loại theo ranh giới sau\: 1K là cả hai cạnh đều ≤ 1024; 2K là cạnh dài nhất > 1024 và ≤ 2048; 4K là một trong hai cạnh > 2048. Ví dụ `1280x720` thuộc 2K, `2560x1440` thuộc 4K.

**Bậc tính phí không phải cam kết kích thước đầu ra.** `generationConfig.imageConfig.imageSize` của Gemini là lựa chọn độ phân giải gốc của mô hình, kích thước pixel thực cần xác nhận cùng mô hình và tỷ lệ; trang này tính bậc tính phí theo trường yêu cầu được hỗ trợ, không vì thế cam kết chiều rộng và cao đầu ra thống nhất. Không điền đồng thời các trường kích thước xung đột, cũng không áp quy tắc theo ảnh cho kết nối trực tiếp chính thức hoặc mô hình tính theo Token.

### Tra nhanh tỷ lệ phổ biến\: 14 tỷ lệ × 1K / 2K / 4K

Bảng dưới liệt kê kích thước đặt trước 1K, 2K, 4K phổ biến theo tỷ lệ, giúp chọn nhanh khung hình. Đây là bảng tra kích thước, không phải danh sách mô hình hỗ trợ\: tỷ lệ khả dụng, tên đặt trước và giới hạn mỗi cạnh thay đổi theo mô hình và kênh; trước khi yêu cầu vẫn phải dựa vào mô tả mô hình hoặc lỗi giao diện.

Bậc K là tên đặt trước, không phải bậc tính phí theo ảnh của trang này. Một số đặt trước “1K” có cạnh dài đã vượt 1024 pixel, theo quy tắc trang này sẽ xếp vào bậc 2K; ví dụ đặt trước 1K 16\:9 `1536x864` thuộc 2K. Việc tính phí luôn theo kích thước yêu cầu thực tế và [Giá mô hình](https://api.dwchainless.com/vi/pricing/).

| Tỷ lệ     | Mục đích phổ biến                 | Kích thước 1K | Kích thước 2K | Kích thước 4K              |
| :-------- | :-------------------------------- | :------------ | :------------ | :------------------------- |
| `1:1`     | Ảnh đại diện vuông / ảnh sản phẩm | `1024x1024`   | `2048x2048`   | `3840x3840`                |
| `4:3`     | Minh họa ngang / ảnh trưng bày    | `1152x896`    | `2048x1536`   | `3840x2880`                |
| `3:4`     | Áp phích dọc / chân dung          | `896x1152`    | `1536x2048`   | `2880x3840`                |
| `16:9`    | Bìa ngang / slide                 | `1536x864`    | `2048x1152`   | `3840x2160`                |
| `9:16`    | Bìa dọc / hình nền điện thoại     | `864x1536`    | `1152x2048`   | `2160x3840`                |
| `3:2`     | Nhiếp ảnh ngang                   | `1536x1024`   | `2048x1360`   | `3840x2560`                |
| `2:3`     | Nhiếp ảnh dọc                     | `1024x1536`   | `1360x2048`   | `2560x3840`                |
| `5:4`     | Trưng bày sản phẩm ngang          | `1280x1024`   | `2560x2048`   | `3840x3072`                |
| `4:5`     | Sản phẩm dọc / ảnh mạng xã hội    | `1024x1280`   | `2048x2560`   | `3072x3840`                |
| `21:9`    | Cảnh rộng / banner                | `1792x768`    | `2048x880`    | `3840x1648`                |
| `1:4`     | Dải dọc hẹp dài                   | `512x2048`    | `768x3072`    | **Vượt giới hạn một cạnh** |
| `4:1`     | Dải ngang hẹp dài                 | `2048x512`    | `3072x768`    | **Vượt giới hạn một cạnh** |
| `1.414:1` | Giấy ngang gần khổ A              | `1440x1024`   | `2048x1456`   | `3840x2720`                |
| `1:1.414` | Giấy dọc gần khổ A                | `1024x1440`   | `1456x2048`   | `2720x3840`                |

### Ba cách viết size đúng

Một số cổng kết nối tương thích OpenAI hỗ trợ các cách viết sau; trường có hiệu lực hay không phụ thuộc mô hình và kênh, khi không được hỗ trợ hãy quay lại pixel rõ ràng.

| Cách viết                   | Đoạn yêu cầu                       | Mục đích                                                         |
| :-------------------------- | :--------------------------------- | :--------------------------------------------------------------- |
| Pixel rõ ràng (khuyến nghị) | `{"size":"1536x2048"}`             | Trực quan nhất, tránh khác biệt quy đổi đặt trước                |
| Tỷ lệ + độ phân giải        | `{"size":"3:4","resolution":"2k"}` | Quy đổi theo đặt trước 2K / 3\:4                                 |
| Kích thước tự động          | `{"size":"auto"}`                  | Mô hình chọn theo năng lực, không cam kết chiều rộng cao cố định |

* Bậc K điền vào `resolution`, `size` điền pixel hoặc tỷ lệ; không viết `2k` vào `size`.
* Dấu phân cách kích thước dùng chữ `x` thường, không dùng dấu nhân ×, X hoa, mảng hay chuỗi có dấu nhân.
* Khi viết tỷ lệ vào `size` thì ưu tiên hơn `aspect_ratio` riêng; pixel rõ ràng hoặc `auto` ưu tiên hơn đặt trước tỷ lệ.
* Giới hạn kích thước tùy ý chính thức của OpenAI cho gpt-image-2 là 3840×2160; tổ hợp 4K của `1:4`, `4:1` vượt giới hạn này nên được ghi là vượt giới hạn một cạnh. Giới hạn của các mô hình khác theo mô tả mô hình.
* Gemini và Qwen dùng trường kích thước riêng, không thể áp dụng trực tiếp các cách viết trên.

### Tham khảo kích thước phổ biến\: 28 loại

Các nhãn dưới đây chỉ biểu thị bậc tính phí theo quy tắc theo ảnh nêu trên, không bảo đảm mô hình được chọn hỗ trợ các kích thước này. Hãy kiểm tra phạm vi hỗ trợ giao diện của mô hình trước rồi mới chọn kích thước; không dùng bậc tính phí trực tiếp làm giá trị tham số giao diện.

| Mục đích / tỷ lệ             | Kích thước (pixel) và bậc tính phí                                           |
| ---------------------------- | ---------------------------------------------------------------------------- |
| Ảnh vuông chung · 1\:1       | 1024×1024 · 1K; 1536×1536 · 2K; 2048×2048 · 2K                               |
| Bìa ngang · 16\:9            | 1280×720 · 2K; 1536×864 · 2K; 2048×1152 · 2K; 2560×1440 · 4K; 3840×2160 · 4K |
| Video dọc / Story · 9\:16    | 720×1280 · 2K; 864×1536 · 2K; 1152×2048 · 2K; 1440×2560 · 4K; 2160×3840 · 4K |
| Ảnh minh họa bài viết · 3\:2 | 1536×1024 · 2K; 1920×1280 · 2K; 2400×1600 · 4K                               |
| Áp phích dọc · 2\:3          | 1024×1536 · 2K; 1280×1920 · 2K; 1600×2400 · 4K                               |
| Banner rộng · 2\:1           | 1536×768 · 2K; 2048×1024 · 2K; 2560×1280 · 4K; 3840×1920 · 4K                |
| Banner siêu rộng · 3\:1      | 1536×512 · 2K; 1920×640 · 2K; 2400×800 · 4K; 3072×1024 · 4K; 3840×1280 · 4K  |

## 5. Đi sâu theo giao thức

Đầy đủ tham số, cấu trúc trả về, ví dụ mã và xử lý lỗi của từng giao thức\:

* [Định dạng OpenAI](/simidoc/vi/apps/api/images/openai)
* [Định dạng Gemini](/simidoc/vi/apps/api/images/gemini)
* [Định dạng Qwen](/simidoc/vi/apps/api/images/qwen)
* [Định dạng Jimeng / Volcengine Ark](/simidoc/vi/apps/api/images/jimeng)
* [Định dạng xAI Grok](/simidoc/vi/apps/api/images/grok)
* [Định dạng BFL FLUX](/simidoc/vi/apps/api/images/flux)