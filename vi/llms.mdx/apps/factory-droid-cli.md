# Cài đặt và cấu hình Factory Droid CLI

Droid CLI hỗ trợ cấu hình mô hình bằng khóa riêng. Mô hình cá nhân lưu trên máy; không đồng nghĩa website hoặc ứng dụng di động Factory dùng cùng mô hình.

## Cài đặt

macOS / Linux\:

```bash
curl -fsSL https://app.factory.ai/cli | sh
droid --version
```

Windows PowerShell\:

```powershell
irm https://app.factory.ai/cli/windows | iex
droid --version
```

Các lệnh chạy tập lệnh cài đặt chính thức; xác minh nguồn và tuân thủ quy định tổ chức. Không tắt phần mềm bảo mật hay hạ chính sách thực thi toàn cục. Đăng nhập tài khoản nếu ứng dụng yêu cầu.

## Thêm mô hình SimiRouter

1. Khởi chạy `droid`, chạy `/settings` rồi mở **Custom models**; cũng có thể mở `/model`, chọn **Manage custom models**.
2. Nhấp **Add model** và chọn nhà cung cấp Chat Completions chung.
3. Điền các trường rồi lưu\:

| Trường       | Nội dung                                 |
| ------------ | ---------------------------------------- |
| Provider     | `generic-chat-completion-api`            |
| Base URL     | `https://api.dwchainless.com/v1`         |
| API Key      | SimiRouter API Key                       |
| Model        | ID mô hình đầy đủ khả dụng cho tài khoản |
| Display name | Ví dụ `SimiRouter`; chỉ để hiển thị      |

## Cách dùng tệp cấu hình

Cũng có thể mở tệp `~/.factory/settings.json` — `customModels` và hợp nhất mảng này. Sao lưu trước, giữ các mục cùng cài đặt sẵn có.

```json
{
  "customModels": [
    {
      "model": "MODEL_ID",
      "displayName": "SimiRouter",
      "baseUrl": "https://api.dwchainless.com/v1",
      "apiKey": "${SIMIROUTER_API_KEY}",
      "provider": "generic-chat-completion-api"
    }
  ]
}
```

Thay `MODEL_ID` bằng ID mô hình thực và trong môi trường chạy Droid đặt `SIMIROUTER_API_KEY`. `${SIMIROUTER_API_KEY}` là tham chiếu biến môi trường được Droid hỗ trợ; không thay bằng khóa thật có thể nhìn thấy công khai.

Cấu hình hiện tại dùng `settings.json` và trường camelCase. Các mục trong tệp cũ `config.json` có thể được di chuyển khi chạy lần đầu; sau đó sửa `settings.json`, không tiếp tục chạy tập lệnh bên thứ ba cũ ghi đè cấu hình.

## Xác minh

Trong `/model`, chọn **Custom Models** rồi chọn mô hình SimiRouter. Bắt đầu với việc ít rủi ro như giải thích tệp, sau đó đối chiếu mô hình và mức dùng trong nhật ký SimiRouter. Cấu hình đầu ra, ảnh và công cụ theo mô hình đã chọn, không sao chép giới hạn cố định của mô hình khác.

## Tham khảo chính thức

* [Factory Droid CLI bắt đầu nhanh](https\://docs.factory.com/droid-cli/quickstart)
* [Mô hình tùy chỉnh Factory (BYOK)](https\://docs.factory.com/model-independence/byok)