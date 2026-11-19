# Cài đặt DeepSeek Harness

DeepSeek Harness (`dsh`) là khung tác tử mã nguồn mở của DeepSeek AI. Thêm SimiRouter làm nhà cung cấp để dùng mô hình trong Web UI và tác vụ headless.

## Điều kiện tiên quyết

Trước khi bắt đầu, chuẩn bị\:

* Tài khoản và khóa API SimiRouter
* Node.js và `npx`
* Terminal macOS, Linux hoặc Windows
* Thư mục dự án cho tác tử thao tác

## Cài đặt và khởi chạy

Mở thư mục dự án muốn tác tử làm việc, rồi chạy\:

```bash
npx @deepseek-ai/dsh web
```

Địa chỉ Web UI mặc định là `http://127.0.0.1:3080`. Thư mục khởi động chỉ là vị trí tệp mặc định; Web UI mới không tự chọn không gian làm việc. Hãy thêm thư mục đó trong giao diện trước, vì ô nhập phiên sẽ bị vô hiệu cho đến khi chọn.

Để đổi cổng\:

```bash
npx @deepseek-ai/dsh web --port 8080
```

## Cấu hình SimiRouter trong Web UI (khuyến nghị)

### 1. Mở cài đặt mô hình

Trong Web UI DeepSeek Harness, mở **Settings → Models**.

![Mở cài đặt mô hình DeepSeek Harness](/simidoc/assets/deepseek-harness/open-model-settings.png)

### 2. Thêm nhà cung cấp tùy chỉnh

Chọn **Add a custom provider** và điền các trường\:

| Trường       | Giá trị                          |
| ------------ | -------------------------------- |
| Provider ID  | `simirouter`                     |
| Display name | `SimiRouter`                     |
| Base URL     | `https://api.dwchainless.com/v1` |
| API protocol | `openai-completions`             |
| API key      | Khóa API SimiRouter của bạn      |

![Biểu mẫu nhà cung cấp SimiRouter tùy chỉnh](/simidoc/assets/deepseek-harness/custom-provider-form.png)

<Callout type="warn" title="">
  Provider ID được phiên, mô hình mặc định và thông tin xác thực tham chiếu; không thể đổi tên trực tiếp sau khi lưu. Dùng chữ thường và `simirouter`.
</Callout>

### 3. Lấy mô hình

Trong **Model catalog**, chọn **Fetch available models**. Harness lấy danh sách bằng Base URL và khóa hiện tại.

Chọn mô hình cần rồi lưu. Nếu không tự lấy được, nhập ID thủ công, như `gpt-6-astra`. Tên phải khớp chính xác mô hình khả dụng cho nhóm khóa hiện tại.

![Chọn mô hình thêm vào nhà cung cấp SimiRouter](/simidoc/assets/deepseek-harness/select-provider-models.png)

### 4. Chọn mô hình

Sau khi lưu, tìm trong bộ chọn mô hình cạnh ô nhập **SimiRouter** rồi chọn mô hình muốn dùng. Nó thành mặc định cho phiên mới; phiên cũ đã gửi yêu cầu vẫn giữ mô hình trước đó.

![Chọn mô hình SimiRouter trong DeepSeek Harness](/simidoc/assets/deepseek-harness/model-picker.png)

## Cấu hình Profile Patch

Cấu hình nhà cung cấp nâng cao của Web Profile dùng `$DSH_HOME/profiles/web/cordis.patch.yml` (mặc định tại `~/.dsh/profiles/web/cordis.patch.yml`). Sao lưu tệp trước khi sửa và hợp nhất cấu hình tiện ích bên dưới, không ghi đè tiện ích hoặc nhà cung cấp sẵn có\:

```yaml
- id: llm-pi-ai
  config:
    providers:
      simirouter:
        displayName: SimiRouter
        apiKeyEnv: SIMIROUTER_API_KEY
        api: openai-completions
        baseURL: https://api.dwchainless.com/v1
        models:
          - id: MODEL_ID
```

Thay `MODEL_ID` bằng ID mô hình đầy đủ và đặt `SIMIROUTER_API_KEY` trong môi trường chạy Harness. Sau khi mở Web UI, chọn mô hình SimiRouter. Cấu hình chỉ dành Web Profile; không mặc định Profile khác kế thừa.

## Kiểm tra cấu hình

1. Mở Web UI\: mặc định `http://127.0.0.1:3080`, hoặc cổng bạn truyền cho `--port` khi khởi động.
2. Xác nhận bộ chọn có **SimiRouter** và mô hình đã lưu.
3. Tạo phiên và gửi tin nhắn thử ngắn.
4. Đối chiếu thời gian, mô hình và mức dùng trong nhật ký SimiRouter để xác minh.

## Chế độ Headless

Headless Profile mặc định tắt kho thông tin xác thực do Web quản lý; không mặc định khóa lưu trên giao diện tự áp dụng. Cấu hình cùng nhà cung cấp trong Headless Profile và truyền khóa qua môi trường khởi chạy. Xem [Thông tin xác thực Headless của DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness/blob/master/packages/bundle/headless/README.md#credentials).

## Câu hỏi thường gặp

### `MISSING_CREDENTIAL`

Harness không tìm thấy `SIMIROUTER_API_KEY`. Mở **Settings → Models** để lưu lại khóa, hoặc đặt biến môi trường cùng tên trong terminal chạy tiến trình.

### `UNKNOWN_MODEL`

Trong Profile hiện tại, mô hình thuộc `simirouter` — `models` không nằm trong danh sách mô hình được cấu hình. Lấy lại danh sách hoặc thêm ID đúng thủ công.

### 401 khi lấy mô hình hoặc trò chuyện

* Kiểm tra khóa đầy đủ, hợp lệ và không có khoảng trắng thừa.
* Xác nhận Base URL là `https://api.dwchainless.com/v1`.
* Xác nhận nhóm khóa hiện tại được dùng mô hình đã chọn.

### Yêu cầu không đi qua SimiRouter

Xác nhận đã thêm **custom provider** với Provider ID `simirouter`. Nhà cung cấp DeepSeek, OpenAI hoặc Anthropic tích hợp vẫn dùng điểm cuối chính thức riêng.

### Đổi mô hình mặc định không có tác dụng

Tạo phiên mới để thử. Phiên đã gửi yêu cầu vẫn giữ mô hình ghi nhận trước đó.

## Tham khảo chính thức

* [DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness)
* [Hướng dẫn cấu hình mô hình DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/providers.zh.md)