# Cấu hình Grok CLI

Grok CLI cấu hình riêng địa chỉ danh sách mô hình và suy luận. `[endpoints].models_base_url` vừa là nguồn danh mục vừa là địa chỉ cơ sở mặc định cho suy luận; `base_url` của từng mô hình có thể ghi đè. Nếu chỉ đặt một trong hai, cái còn lại có thể vẫn trỏ tới địa chỉ chính thức, nên hãy kiểm tra cả hai.

Vị trí tệp cấu hình\:

* **Linux / macOS**\: `~/.grok/config.toml`
* **Windows**\: `%USERPROFILE%\.grok\config.toml`

## Cài đặt / cập nhật

Linux / macOS\:

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
grok update
grok --version
```

Windows (PowerShell)\:

```powershell
irm https://x.ai/cli/install.ps1 | iex
```

Nếu cài qua WinGet, hãy cập nhật bằng `winget upgrade` thay vì dựa vào `grok update`.

<Callout type="warn" title="Cần XAI_API_KEY khi khởi động">
  Khi khởi động, Grok CLI lấy danh sách mô hình chỉ bằng biến môi trường `XAI_API_KEY`; nếu chưa đặt, bước lấy danh sách sẽ lỗi bất kể `api_key` trong tệp cấu hình. Khi dùng SimiRouter, hãy ghi cùng khóa đó vào biến môi trường\:

  ```bash
  export XAI_API_KEY="PASTE_API_KEY_HERE"
  ```

  Không đặt khóa trong tệp được commit lên Git. Để dùng lâu dài, lưu trong tệp môi trường có quyền `600` rồi `source`.
</Callout>

## Ghi cấu hình

Ghi nội dung sau vào `~/.grok/config.toml` và thay `api_key` bằng khóa API của bạn\:

```toml
[models]
default = "grok-4.5"

[endpoints]
models_base_url = "https://api.dwchainless.com/v1"

[model."grok-4.5"]
base_url = "https://api.dwchainless.com/v1"
model = "grok-4.5"
name = "Grok 4.5"
api_key = "PASTE_API_KEY_HERE"
api_backend = "responses"
context_window = 500000
supports_backend_search = true

[session]
# 可选：官方默认值为 85；80 会更早触发自动压缩
auto_compact_threshold_percent = 80

[ui]
max_thoughts_width = 120
yolo = false
compact_mode = false
# permission_mode = "always-approve"  # enable only in trusted environments
```

Ví dụ giao diện đặt chiều rộng nội dung suy nghĩ 120 ký tự, tắt chế độ gọn và tự duyệt gọi công cụ.

<Callout type="warn" title="">
  Ví dụ tắt `yolo` và chú thích `permission_mode = "always-approve"`. Bật chúng sẽ cho phép Grok sửa tệp, chạy lệnh không cần xác nhận; **chỉ dùng trong dự án và môi trường đáng tin**.
</Callout>

<Callout type="info" title="">
  `api_key` phải dùng khóa SimiRouter do dịch vụ cấp, không phải grok.com OAuth `refresh_token`. Khóa nội tuyến được lưu văn bản thuần; trên Linux/macOS chạy `chmod 600 ~/.grok/config.toml`. Với máy dùng chung, nên chọn cách chính thức hỗ trợ `env_key`.
</Callout>

## Kiểm tra cấu hình

```bash
grok inspect
grok models
grok --model grok-4.5 --output-format json -p '只输出 YAI_GROK_OK'
```

## Tham khảo chính thức

* [xAI Grok CLI\: mô hình tùy chỉnh](https\://docs.x.ai/build/overview)
* [xAI Grok CLI\: tham khảo cấu hình](https\://docs.x.ai/build/settings)