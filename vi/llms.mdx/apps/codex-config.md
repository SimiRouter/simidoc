# Cấu hình Codex CLI

Ví dụ này cung cấp API Key trực tiếp trong `config.toml`. Script xử lý `config.toml` cấp người dùng và `models.json` cục bộ, không tạo hoặc sửa `auth.json`.

Script sử dụng hai URL và một API Key\:

* **Inference Base URL**\: `https://api.dwchainless.com/v1`, ghi vào `model_providers.simirouter.base_url` cho các yêu cầu Codex.
* **URL danh mục mô hình**\: `https://api.dwchainless.com/v1/models`. Script dùng cùng API Key dưới dạng Bearer, chuyển danh sách kiểu OpenAI thành `~/.codex/models.json` cục bộ và đặt `model_catalog_json`. Đây không phải URL suy luận thứ hai.
* **API Key**\: cùng một khóa SimiRouter được dùng cho cả hai URL. Script chỉ gửi khóa dưới dạng thông tin xác thực Bearer đến hai URL cố định này và không ghi vào tài liệu hay nơi khác.

Endpoint danh mục yêu cầu khóa hợp lệ. Mô hình và siêu dữ liệu cơ bản như độ dài ngữ cảnh lấy từ phản hồi; việc chuyển đổi không tự thêm công cụ hoặc khả năng suy luận chưa được xác nhận.

* **Linux / macOS**\: `~/.codex/config.toml`
* **Windows**\: `%USERPROFILE%\.codex\config.toml`

## Cách 1\: Script cấu hình tự động (tùy chọn; xem kỹ trước khi chạy)

Kho mã có script Bash và PowerShell. Hãy cài và chạy Codex CLI hoặc Codex Desktop trước; tải xuống và xem nội dung script trước khi chạy tệp cục bộ.

* [Tải script Bash (CDN)](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [Tải script Bash (dự phòng GitHub Raw)](https\://raw.githubusercontent.com/SimiRouter/simidoc/cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [Tải script PowerShell (CDN)](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)
* [Tải script PowerShell (dự phòng GitHub Raw)](https\://raw.githubusercontent.com/SimiRouter/simidoc/cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)

Trên macOS / Linux, chạy trong terminal\:

<Callout type="warn" title="">
  Các bước này lưu script từ một trong các liên kết CDN hoặc GitHub Raw ở trên nhưng không chuyển phản hồi mạng trực tiếp cho trình thông dịch. Hãy xem tệp cục bộ đã lưu trước khi chạy.
  Script ghi API Key vào `experimental_bearer_token` trong `config.toml`; không tạo hoặc sửa `auth.json`. Hãy coi tệp này là bí mật dạng văn bản rõ.
</Callout>

```bash
# Download the script from the public script link above, then review it.
less ./codex-simirouter-setup.sh
bash ./codex-simirouter-setup.sh
```

Trên Windows, chạy trong PowerShell\:

```powershell
# Download the script from the public script link above, then review it.
$script = Join-Path (Get-Location) 'codex-simirouter-setup.ps1'
Get-Content -LiteralPath $script
& powershell -File $script
```

<Callout type="info" title="">
  PowerShell 5.1 và PowerShell 7 đều lưu tệp trước khi chạy để bạn có thể xem nội dung trước khi nhập API Key. Với PowerShell 7, thay `powershell` ở dòng cuối bằng `pwsh`.
</Callout>

Sau khi chạy, chọn mô hình trong menu. Lần đầu chạy sẽ yêu cầu nhập API Key (bắt đầu bằng `sk-`, lấy trong bảng điều khiển SimiRouter).

Script lần lượt thực hiện (bản Bash yêu cầu Python 3.11 trở lên)\:

* **Sao lưu cấu hình hiện tại**\: Lưu snapshot của `config.toml` vào `~/.codex/backup-simirouter/`; khôi phục yêu cầu nhập rõ `RESTORE`.
* **Đồng bộ danh mục mô hình**\: Gọi URL danh mục bằng cùng API Key, chuyển ID mô hình và siêu dữ liệu cơ bản vào `~/.codex/models.json`, rồi đặt `model_catalog_json` trỏ đến tệp này.
* **Sửa `config.toml`**\: Cập nhật `model_provider`, `model`, `model_catalog_json` ở cấp cao nhất và các trường trong `[model_providers.simirouter]`\: `base_url`, `wire_api`, `experimental_bearer_token`, cố gắng giữ nguyên các nội dung khác.
* **Bảo vệ tệp**\: Script cố gắng giới hạn quyền truy cập thư mục và tệp cấu hình cho người dùng hiện tại; nếu hệ điều hành từ chối sẽ hiện cảnh báo.
* **Kiểm tra**\: Bản Bash dùng Python 3.11+ để phân tích TOML và JSON danh mục trước khi thay tệp. Script không kiểm tra hoặc sửa `auth.json` và không khẳng định cuộc gọi suy luận thực tế đã thành công.

<Callout type="info" title="">
  Chạy lại script để đổi mô hình hoặc chọn «Khôi phục cấu hình mặc định» để phục hồi trạng thái trước khi cài bằng bản sao lưu.
</Callout>

## Cách 2\: Cấu hình thủ công trên Linux / macOS (dự phòng)

Trước khi sửa, sao lưu riêng `config.toml` và `auth.json`. Không di chuyển hoặc tạo lại toàn bộ thư mục `~/.codex`, vì còn chứa lịch sử, phiên và thiết lập khác. Chỉ hợp nhất các trường mô hình và nhà cung cấp, không ghi đè toàn bộ tệp hoặc thêm bảng TOML trùng tên. Giữ nguyên cấu hình MCP, phê duyệt, sandbox và độ tin cậy dự án.

### `~/.codex/config.toml`

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
model_catalog_json = "~/.codex/models.json"

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

`model_catalog_json` trỏ đến danh mục cục bộ được tạo từ `https://api.dwchainless.com/v1/models`. Khi cấu hình thủ công, hãy gọi URL này bằng cùng API Key và lưu theo định dạng `models.json` của Codex; không dùng trực tiếp danh sách OpenAI `data`.

Tệp chứa token dạng văn bản rõ; không đưa vào kho mã hoặc chia sẻ. Trên Linux / macOS, hạn chế quyền truy cập sau khi lưu\:

```bash
chmod 600 ~/.codex/config.toml
```

### `auth.json` (chỉ khi cách xác thực khác cần đến)

Ví dụ trên xác thực bằng token trong cấu hình, không cần tạo hay ghi đè `auth.json`. JSON dưới đây chỉ tham khảo cho cách xác thực khác cần tệp này. Chọn một cách được phiên bản Codex hỗ trợ, không kết hợp để che lỗi xác thực.

```json
{
  "OPENAI_API_KEY": "PASTE_API_KEY_HERE"
}
```

## Cấu hình Windows

### PowerShell

Tạo thư mục và mở tệp cấu hình\:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex" | Out-Null
notepad "$env:USERPROFILE\.codex\config.toml"
```

### CMD

```cmd
if not exist "%USERPROFILE%\.codex" mkdir "%USERPROFILE%\.codex"
notepad "%USERPROFILE%\.codex\config.toml"
```

Sau khi sao lưu, hợp nhất các trường mô hình và nhà cung cấp trong TOML ở trên vào `config.toml`, không ghi đè thiết lập khác. Ví dụ dùng token trực tiếp trong cấu hình, nên không tạo hay ghi đè `auth.json`. Trên Windows, giới hạn quyền truy cập tệp chứa khóa cho người dùng hiện tại.

## Kiểm tra khởi động

```bash
codex
```

<Callout type="warn" title="">
  Trên Windows, `config.toml` và `auth.json` nằm trong `%USERPROFILE%\.codex\`. Hãy lưu đúng vị trí.
</Callout>