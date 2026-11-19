# Cấu hình Claude CLI

Claude Code kết nối với cổng API thông qua biến môi trường. Trước tiên hãy thiết lập biến môi trường, sau đó chạy `claude` để khởi động.

## Linux / macOS

```bash
export ANTHROPIC_AUTH_TOKEN="PASTE_API_KEY_HERE"
export ANTHROPIC_BASE_URL="https://api.dwchainless.com"

# 可选：自定义默认模型映射（不配置也可正常使用）
export ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-6-astra"
export ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-terra"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-luna"
```

## Windows CMD

```cmd
set ANTHROPIC_AUTH_TOKEN=PASTE_API_KEY_HERE
set ANTHROPIC_BASE_URL=https://api.dwchainless.com

:: 可选：自定义默认模型映射（不配置也可正常使用）
set ANTHROPIC_DEFAULT_OPUS_MODEL=gpt-6-astra
set ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-5.6-terra
set ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-5.6-luna
```

## Windows PowerShell

```powershell
$env:ANTHROPIC_AUTH_TOKEN="PASTE_API_KEY_HERE"
$env:ANTHROPIC_BASE_URL="https://api.dwchainless.com"

# 可选：自定义默认模型映射（不配置也可正常使用）
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-6-astra"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-terra"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-luna"
```

## Kiểm tra khởi động

Sau khi thiết lập biến môi trường, chạy trong terminal\:

```bash
claude
```

Gửi tin nhắn ngắn rồi đối chiếu yêu cầu, mô hình trong nhật ký SimiRouter. Chỉ mở giao diện trò chuyện chưa xác minh được kết nối API.

## Tham khảo chính thức

[Tài liệu kết nối cổng Claude Code](https\://code.claude.com/docs/en/llm-gateway) mô tả kết nối cổng. `ANTHROPIC_BASE_URL` là địa chỉ gốc; ứng dụng tự thêm `/v1/messages`; không thêm trùng `/v1`. Ánh xạ mô hình phải được kênh hiện tại hỗ trợ.