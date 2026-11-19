# Cấu hình OpenCode CLI

OpenCode sử dụng tệp cấu hình toàn cục\:

* **Linux / macOS**\: `~/.config/opencode/opencode.jsonc`
* **Windows**\: `%USERPROFILE%\.config\opencode\opencode.jsonc`

Trước tiên ghi khóa vào `apiKey` trong tệp cấu hình, sau đó chạy lệnh kiểm tra. Ví dụ không tham chiếu biến môi trường, nên không cần đặt thêm biến môi trường. Bảo vệ tệp chứa khóa và giữ xác nhận quyền mặc định của OpenCode.

## Tệp cấu hình (định dạng tương thích V1)

Ghi nội dung sau vào tệp cấu hình và thay `apiKey` bằng khóa API của bạn\:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "openai/gpt-6-astra",
  "small_model": "openai/gpt-6-astra",
  "provider": {
    "openai": {
      "options": {
        "baseURL": "https://api.dwchainless.com/v1",
        "apiKey": "PASTE_API_KEY_HERE"
      },
      "models": {
        "gpt-6-astra": {
          "headers": {
            "originator": "opencode"
          }
        }
      }
    }
  },
  "agent": {
    "title": {
      "options": {
        "reasoningEffort": "none"
      }
    },
    "build": {
      "variant": "xhigh",
      "options": {
        "reasoningSummary": "detailed",
        "textVerbosity": "high"
      }
    },
    "plan": {
      "variant": "xhigh",
      "options": {
        "reasoningSummary": "detailed",
        "textVerbosity": "high"
      }
    }
  }
}
```

## Kiểm tra cấu hình

### Linux / macOS

```bash
opencode debug config
opencode run "你好"
```

### Windows CMD

```cmd
opencode debug config
opencode run "你好"
```

### Windows PowerShell

```powershell
opencode debug config
opencode run "你好"
```

<Callout type="info" title="">
  `opencode debug config` kiểm tra cấu hình có được tải đúng không; `opencode run "你好"` kiểm tra mô hình có phản hồi bình thường không.
</Callout>

## Tham khảo chính thức

[Tài liệu cấu hình OpenCode](https\://opencode.ai/docs/config/) giới thiệu vị trí và định dạng hiện tại. Hướng dẫn giữ cú pháp V1 tương thích; khi nâng cấp theo chỉ dẫn di chuyển của phiên bản, không ghi đè toàn bộ cấu hình.