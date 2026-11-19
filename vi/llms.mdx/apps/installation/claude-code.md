# Cài Claude Code CLI

Claude Code hỗ trợ macOS, Linux, Windows gốc và WSL. Bộ cài gốc không cần Node.js; chỉ cách npm cần phiên bản Node.js phù hợp.

## macOS / Linux / WSL

Chạy lệnh chính thức trong Bash hoặc Zsh\:

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
```

Lệnh tải và chạy tập lệnh chính thức. Môi trường quản lý nên xem trước hoặc dùng cách được tổ chức duyệt; không chạy bằng `sudo`.

## Windows PowerShell

```powershell
irm https://claude.ai/install.ps1 | iex
claude --version
```

Không cần quyền quản trị. Git for Windows là tùy chọn, chỉ cài khi cần công cụ Bash. Người dùng WSL chạy lệnh Linux trong WSL, không cấu hình ứng dụng Linux từ PowerShell.

## Cấu hình và chạy

1. Nhấn [Cấu hình Claude CLI](/simidoc/vi/apps/claude-config) để đặt địa chỉ và khóa SimiRouter.
2. Mở thư mục dự án và chạy `claude`.
3. Giữ xác nhận quyền; bắt đầu bằng giải thích tệp ít rủi ro rồi kiểm tra nhật ký SimiRouter.

`claude --version` chỉ xác minh đã cài lệnh, không chứng minh API kết nối. Không tắt chống virus hay hạ bảo mật toàn hệ thống để xử lý lỗi cài đặt.

## Tham khảo chính thức

[Anthropic\: cài Claude Code và yêu cầu hệ thống](https\://code.claude.com/docs/en/setup).