# Jimeng / Tạo ảnh Volcengine Ark

## Tổng quan

Giao diện tạo ảnh của Volcengine Ark dùng dòng mô hình Seedream (`doubao-seedream-*`), tạo ảnh từ văn bản hoặc ảnh tham chiếu. Yêu cầu gửi một lần và trả về đồng bộ `data[]`; một số mô hình còn hỗ trợ tạo theo luồng hoặc theo lô.

| Việc bạn cần làm                   | Đầu vào                          | Đầu ra    | Điểm cuối                                                          |
| ---------------------------------- | -------------------------------- | --------- | ------------------------------------------------------------------ |
| Tạo ảnh từ văn bản                 | `prompt`                         | Ảnh mới   | `POST https://ark.cn-beijing.volces.com/api/v3/images/generations` |
| Tạo từ ảnh tham chiếu hoặc sửa ảnh | `prompt` + `image`               | Ảnh mới   | Như trên                                                           |
| Tạo hàng loạt nhiều ảnh            | `prompt` + tham số tạo hàng loạt | Nhiều ảnh | Như trên                                                           |

## Khái niệm cốt lõi

* **`size` có hai cách viết**\: bậc độ phân giải (như `2K`) hoặc pixel rõ ràng (như `2048x2048`). Bậc là đặt trước của mô hình, không tương đương chiều rộng cao cố định; kích thước thực tế trong cùng một bậc phụ thuộc mô hình và mô tả khung hình trong lời nhắc.
* **Ảnh tham chiếu đặt trong `image`**\: có thể là URL HTTP(S) hoặc `data:image/...;base64,...`. Truyền mảng là tham chiếu nhiều ảnh, giới hạn số lượng thay đổi theo mô hình.
* **`watermark` mặc định bật**\: mặc định `true` sẽ thêm nhãn “do AI tạo” lên ảnh; khi cần đầu ra không watermark hãy truyền rõ `false`, và xác nhận mục đích sử dụng phù hợp với yêu cầu nhận diện nội dung tổng hợp hiện hành.
* **Trả về đồng bộ**\: yêu cầu thông thường chờ trực tiếp `data[]`. `stream` chỉ mở cho một số mô hình như Seedream 5.0 lite, 4.5, 4.0; không thể biến mô hình khác thành tác vụ bất đồng bộ bằng cách thêm tham số luồng.
* **Tính phí theo ảnh**\: chi phí liên quan đến số ảnh tạo. Đầu ra hàng loạt của `sequential_image_generation` được cộng theo số ảnh thực tế tạo; mục thất bại được trả riêng trong `data[].error`.

## Thông số và năng lực

| ID mô hình                        | Bậc `size` và giới hạn                                             | Ảnh tham chiếu | Định dạng đầu ra                                       |
| --------------------------------- | ------------------------------------------------------------------ | -------------- | ------------------------------------------------------ |
| `doubao-seedream-5-5-261028`      | `1K`, `1.5K`, `2K` hoặc `WxH`; pixel 921600–4624220, tỷ lệ 1/16–16 | Tối đa 10 ảnh  | `url` / `b64_json`; `png` mặc định, cũng hỗ trợ `jpeg` |
| `doubao-seedream-5-0-lite-260128` | `2K`, `3K`, `4K` hoặc `WxH`; pixel 3686400–16777216, tỷ lệ 1/16–16 | Tối đa 14 ảnh  | `url` / `b64_json`; `png` / `jpeg`                     |
| `doubao-seedream-4-5-251128`      | `2K`, `4K` hoặc `WxH`; pixel 3686400–16777216, tỷ lệ 1/16–16       | Tối đa 14 ảnh  | `url` / `b64_json`; `png` / `jpeg`                     |
| `doubao-seedream-4-0-250828`      | `1K`, `2K`, `4K` hoặc `WxH`; pixel 921600–16777216, tỷ lệ 1/16–16  | Tối đa 14 ảnh  | `url` / `b64_json`; `png` / `jpeg`                     |

Giới hạn pixel tính theo tổng pixel, ví dụ 16777216 pixel tương ứng 4096×4096. ID mô hình sẽ cập nhật theo phiên bản; trước khi gọi, hãy theo danh mục mô hình Volcengine Ark và [Mô hình và giá](https://api.dwchainless.com/vi/pricing/); `model` cũng có thể điền ID điểm truy cập suy luận (`ep-...`).

## Quy trình gọi

1. **Chuẩn bị khóa**\: tạo API Key trên bảng điều khiển Volcengine Ark, header yêu cầu dùng `Authorization: Bearer $ARK_API_KEY`.
2. **Chọn mô hình và kích thước**\: xác nhận bậc `size` hoặc phạm vi pixel mô hình hỗ trợ, và quyết định có cần ảnh tham chiếu hay không.
3. **Gửi yêu cầu JSON**\: gửi đến `/api/v3/images/generations` với `model`, `prompt`, thêm `image`, `size`, `response_format` và `watermark` theo nhu cầu.
4. **Đọc `data[]`**\: khi `response_format` là `url` thì lấy `data[].url` (thời hạn 24 giờ), khi là `b64_json` thì giải mã `data[].b64_json`.
5. **Lưu và nghiệm thu**\: kiểm tra tệp có mở được không, kích thước thực và nội dung; khi tạo hàng loạt kiểm tra từng mục `data[].error`, không chỉ nhìn mã trạng thái HTTP.
6. **Đối chiếu chi phí**\: xác nhận mô hình, số ảnh và khoản trừ trong nhật ký sử dụng; đầu ra hàng loạt tính theo số ảnh thực tế tạo thành công.

## Mô phỏng lệnh gọi

Bản tin dưới đây là minh họa, không phải phản hồi tài khoản thật; URL và Base64 đã được cắt ngắn, con số không đại diện giá hiện tại.

Yêu cầu\:

```json
{
  "model": "doubao-seedream-5-5-261028",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "size": "2K",
  "response_format": "url",
  "watermark": true
}
```

Phản hồi thành công (đồng bộ)\:

```json
{
  "created": 1763366400,
  "model": "doubao-seedream-5-5-261028",
  "data": [
    {
      "url": "https://example.com/generated-image.png",
      "size": "2048x2048",
      "output_format": "png"
    }
  ]
}
```

Khi không tạo được ảnh, trả `error` ở cấp cao nhất; khi một ảnh trong lô thất bại, mục thất bại nêu `data[].error` chứa `code` và `message`.

## Kết nối và phiên

* **Base URL**\: `https://ark.cn-beijing.volces.com/api/v3`.
* **Xác thực**\: `Authorization: Bearer $ARK_API_KEY`. Chỉ đặt khóa trong header yêu cầu, không ghi vào lời nhắc hay mã nguồn.
* **Khác biệt với OpenAI Images**\: đường dẫn là `/api/v3/images/generations`, không phải `/v1/images/generations`; không có tham số `quality`; `size` có thể ghi trực tiếp bậc `1K`, `2K`; trả `data[].url` hoặc `data[].b64_json`.
* **Gọi qua cổng của trang này**\: đổi địa chỉ yêu cầu thành `https://api.dwchainless.com/v1/images/generations`, xác thực bằng khóa của trang này; nội dung yêu cầu có được chuyển nguyên hay không, ID mô hình có khả dụng hay không, theo kênh và [Mô hình và giá](https://api.dwchainless.com/vi/pricing/).
* **Quá thời gian**\: tạo đồng bộ có thể kéo dài hàng chục giây, thời gian chờ phía máy khách nên cao hơn rõ rệt so với yêu cầu văn bản thông thường; sau khi quá thời gian, trước tiên xem nhật ký gọi để xác nhận đã tạo ảnh và phí chưa, rồi mới quyết định thử lại.
* **Hàng loạt và luồng**\: `sequential_image_generation` và `stream` chỉ một số mô hình hỗ trợ; khi bật đồng thời, phải nghiệm thu theo sự kiện hoàn tất cuối hoặc `data[]` đầy đủ, kết quả trung gian không tính là ảnh hoàn thành.

## Tham khảo chính thức

* [API tạo ảnh Volcengine Ark](https\://docs.volcengine.com/docs/82379/1541523)
* [Base URL và xác thực Volcengine Ark](https\://docs.volcengine.com/docs/ark/base-url-and-authentication)
* [Tạo và chỉnh sửa ảnh dòng Seedream](https\://docs.volcengine.com/docs/lake-ai-service/image-generation-and-editing-doubao-seed-ream-series-models?lang=en)