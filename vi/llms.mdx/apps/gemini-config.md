# Cấu hình Gemini CLI

Đặt biến môi trường để trỏ Gemini CLI tới SimiRouter.

## macOS / Linux

**Tạm thời (phiên terminal hiện tại)\:**

```bash
export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
export GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**Lâu dài (thêm vào cấu hình Shell)\:**

```bash
install -d -m 700 ~/.config
umask 077
printf '%s\n' \
  'export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"' \
  'export GEMINI_API_KEY="PASTE_API_KEY_HERE"' > ~/.config/simiroouter.env
chmod 600 ~/.config/simiroouter.env
# Add this line to ~/.zshrc or ~/.bashrc: source ~/.config/simiroouter.env
source ~/.config/simiroouter.env
```

<Callout type="info" title="">
  Khóa được lưu với quyền `600` trong `~/.config/simiroouter.env`, không ghi vào hồ sơ shell chạy mỗi lần đăng nhập. Thêm `source ~/.config/simiroouter.env` vào `~/.bashrc` hoặc `~/.zshrc` để có hiệu lực lâu dài, và không để người khác đọc tệp trên máy dùng chung.
</Callout>

## Windows PowerShell

**Tạm thời\:**

```powershell
$env:GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
$env:GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**Lâu dài (thêm vào hồ sơ PowerShell)\:**

```powershell
Add-Content $PROFILE 'Set-Item -Path Env:GOOGLE_GEMINI_BASE_URL -Value "https://api.dwchainless.com"'
Add-Content $PROFILE 'Set-Item -Path Env:GEMINI_API_KEY -Value "PASTE_API_KEY_HERE"'
```

## Windows CMD

**Tạm thời\:**

```cmd
set GOOGLE_GEMINI_BASE_URL=https://api.dwchainless.com
set GEMINI_API_KEY=PASTE_API_KEY_HERE
```

**Lâu dài (người dùng hiện tại)\:**

1. Nhấn `Win + R`, nhập `sysdm.cpl` rồi nhấn Enter
2. Nhấp “Nâng cao” → “Biến môi trường”
3. Trong “Biến người dùng”, nhấp “Mới” rồi thêm `GOOGLE_GEMINI_BASE_URL` và `GEMINI_API_KEY`
4. Khởi động lại terminal để biến có hiệu lực

## Kiểm tra khởi động

```bash
gemini
```

Chọn xác thực khóa API rồi gửi tin nhắn ngắn; xác minh lệnh gọi trong nhật ký SimiRouter. Mở được ứng dụng không chứng minh API đã kết nối.

## Câu hỏi thường gặp

**Thông báo `GEMINI_API_KEY` chưa đặt?**

* Kiểm tra chính tả tên biến
* Trên Windows, khởi động lại terminal sau khi đặt biến hệ thống

**Kết nối hết thời gian chờ hoặc lỗi?**

* Bảo đảm `GOOGLE_GEMINI_BASE_URL` không có phần cuối thừa `/`
* Kiểm tra kết nối mạng
* Xác nhận khóa hợp lệ và chưa hết hạn

## Tham khảo chính thức

[Tham khảo cấu hình Gemini CLI](https\://geminicli.com/docs/reference/configuration/) mô tả `GOOGLE_GEMINI_BASE_URL` dùng ghi đè địa chỉ gốc dịch vụ. SDK tự thêm phiên bản API và đường dẫn mô hình; không thêm tại đây `/v1`.