# Cài Codex CLI

## macOS / Linux

OpenAI cung cấp bộ cài độc lập\:

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex --version
```

Lệnh tải và chạy tập lệnh chính thức. Môi trường quản lý nên xem trước hoặc dùng trình quản lý gói được duyệt theo tài liệu.

## Windows

Windows có thể cài trực tiếp hoặc dùng công cụ Linux trong WSL. Xem cài đặt và sandbox tại [Tài liệu Windows OpenAI](https\://learn.chatgpt.com/docs/windows/windows-sandbox).

Nếu cài bằng npm, thiết lập Node.js tương thích theo tài liệu rồi chạy\:

```powershell
npm install -g @openai/codex
codex --version
```

Người dùng WSL phải cài và cấu hình trong WSL; không nhầm cấu hình Windows tại `%USERPROFILE%` với Linux tại `~/.codex`. Không tắt phần mềm bảo mật hoặc tùy tiện bật quyền quản trị.

## Cấu hình và xác minh

1. Theo [Cấu hình Codex CLI](/simidoc/vi/apps/codex-config) để hợp nhất các trường nhà cung cấp và mô hình trong `config.toml`; sao lưu tệp trước khi sửa.
2. Mở thư mục dự án, chạy `codex`.
3. Giữ mặc định phê duyệt và sandbox; yêu cầu Codex giải thích tệp rồi xác minh nhật ký SimiRouter.

`codex --version` xác minh lệnh chạy được, không phải kết nối API. Không ghi đè toàn bộ thư mục `~/.codex` vì có thể mất lịch sử, phiên và cấu hình khác.

## Tham khảo chính thức

* [OpenAI Codex CLI](https\://learn.chatgpt.com/docs/codex/cli)
* [Tài liệu sandbox Windows OpenAI](https\://learn.chatgpt.com/docs/windows/windows-sandbox)