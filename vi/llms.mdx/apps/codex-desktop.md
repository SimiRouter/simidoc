# Thiết lập ứng dụng Codex trên máy tính

Ứng dụng Codex trên máy tính hỗ trợ đăng nhập bằng API Key và mở `config.toml` cấp người dùng ngay trong ứng dụng. Sau khi hoàn tất cấu hình dưới đây, Codex gửi yêu cầu qua API tương thích Responses của SimiRouter.

<Callout type="info" title="">
  Trường trên màn hình đăng nhập vẫn có tên **OpenAI API key**. Hãy nhập SimiRouter API Key của bạn, ví dụ `sk-...`.
</Callout>

## Điều kiện tiên quyết

Trước khi bắt đầu, chuẩn bị\:

* Ứng dụng Codex mới nhất.
* Tài khoản SimiRouter.
* API Key tạo trong bảng điều khiển SimiRouter.
* Quyền sử dụng mô hình định cấu hình cho tài khoản hiện tại.

## Các bước cấu hình

### 1. Đăng nhập bằng API Key

1. Mở ứng dụng Codex.
2. Trên trang đăng nhập, chọn **Sign in another way**.
3. Nhập khóa API SimiRouter vào ô **OpenAI API key**.
4. Chọn **Continue** để vào ứng dụng.

![Nhập API Key trong ứng dụng Codex](/simidoc/assets/codex-desktop/codex-api-key-login.png)

### 2. Mở tệp cấu hình cấp người dùng

1. Mở trang thiết lập Codex.
2. Chọn **Configuration**.
3. Trong **Custom config.toml settings**, chọn **User config**.
4. Chọn **Open config.toml** để mở tệp cấu hình cấp người dùng.

![Mở config.toml cấp người dùng trong Codex](/simidoc/assets/codex-desktop/codex-user-config.png)

### 3. Ghi cấu hình SimiRouter

Sao lưu `config.toml` hiện có trước. Hợp nhất các trường mô hình và nhà cung cấp bên dưới thay vì ghi đè toàn bộ tệp. Giữ thiết lập MCP, độ tin cậy dự án, phê duyệt và sandbox; không thêm bảng TOML trùng tên.

```toml
model_provider = "simirouter"
review_model = "gpt-6-astra"
model = "gpt-6-astra"
model_reasoning_effort = "xhigh"
plan_mode_reasoning_effort = "high"
model_reasoning_summary = "auto"
model_verbosity = "high"

suppress_unstable_features_warning = true
web_search = "live"

[model_providers.simirouter]
name = "simirouter"
base_url = "https://api.dwchainless.com/v1"
wire_api = "responses"
stream_idle_timeout_ms = 900000
supports_websockets = false
http_headers = { "x-openai-actor-authorization" = "api.dwchainless.com" }
requires_openai_auth = false
experimental_bearer_token="PASTE_API_KEY_HERE"
```

Lưu tệp, sau đó thoát hoàn toàn và mở lại Codex.

<Callout type="info" title="">
  Ví dụ này cung cấp token trực tiếp bằng `requires_openai_auth = false` và `experimental_bearer_token`. Thay giá trị mẫu bằng SimiRouter API Key của bạn. Không cần cấu hình thêm `auth.json`, và cách này không dựa vào khóa đã lưu khi đăng nhập. Vì `config.toml` chứa khóa dạng văn bản rõ, không đưa tệp vào kho mã hoặc chia sẻ. Trên Linux / macOS, dùng `chmod 600 ~/.codex/config.toml`; trên Windows, giới hạn quyền truy cập tệp. Giữ nguyên thiết lập phê duyệt, sandbox và độ tin cậy dự án; kết nối nhà cung cấp không yêu cầu tắt xác nhận an toàn.
</Callout>

## Kiểm tra cấu hình

Sau khi mở lại Codex\:

1. Mở một dự án hoặc không gian làm việc.
2. Bắt đầu bằng tác vụ ít rủi ro, như yêu cầu Codex giải thích một tệp.
3. Đối chiếu thời gian, mô hình và lượng sử dụng trong nhật ký SimiRouter. Tên hiển thị và mô hình tự nhận không chứng minh định tuyến thực.

## Câu hỏi thường gặp

### API Key không hợp lệ

* Sao chép lại toàn bộ API Key từ bảng điều khiển SimiRouter.
* Kiểm tra khoảng trắng thừa ở đầu và cuối khóa.
* Bảo đảm khóa bắt đầu bằng `sk-` và còn hiệu lực.

### Cấu hình chưa có hiệu lực

* Xác nhận đang sửa `config.toml` được mở từ **User config**.
* Bảo đảm tên trong `model_provider = "simirouter"` khớp `[model_providers.simirouter]`.
* Sau khi lưu, thoát hoàn toàn ứng dụng, không chỉ đóng cửa sổ hiện tại.

### Lỗi mô hình hoặc kết nối

* Bảo đảm `base_url` là `https://api.dwchainless.com/v1`.
* Bảo đảm `wire_api` là `responses`.
* Bảo đảm nhóm API Key hiện tại được dùng `gpt-6-astra`; muốn dùng mô hình khác, thay `model` bằng tên tương ứng.

Để cấu hình `auth.json` thủ công, đổi mô hình hoặc dùng phiên bản dòng lệnh, xem [Cấu hình Codex CLI](/simidoc/vi/apps/codex-config).

## Tham khảo chính thức

* [Tài liệu cấu hình OpenAI Codex](https\://developers.openai.com/codex/config-reference/)