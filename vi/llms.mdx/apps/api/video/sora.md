# Video Sora (API chính thức đã đóng)

**Sora 2 và Videos API OpenAI đã đóng ngày 24-09-2026.** Dưới chỉ cấu trúc, không hướng dẫn dùng hiện tại. Mô hình SimiRouter cùng tên/triển khai bên thứ ba cần xác minh nguồn, khả năng, giao thức; không gọi là OpenAI trực tiếp chính thức.

## Tổng quan API

| Thao tác        | Điểm cuối chính thức cũ             | Tham khảo             |
| --------------- | ----------------------------------- | --------------------- |
| Tạo tác vụ      | `POST /v1/videos`                   | [Tạo](/simidoc/vi/apps/api/video/sora/create)       |
| Truy vấn tác vụ | `GET /v1/videos/{video_id}`         | [Truy vấn](/simidoc/vi/apps/api/video/sora/status)  |
| Tải video       | `GET /v1/videos/{video_id}/content` | [Nội dung](/simidoc/vi/apps/api/video/sora/content) |

Giao thức cũ bất đồng bộ queued/in\_progress sang completed/failed, không luồng sinh thường. Thông báo không có thay thế một-một. Khả năng khác theo [phân loại video](/simidoc/vi/apps/api/video) chọn hãng khả dụng, không tự thay thế.

## Tham khảo chính thức

[Thông báo đóng OpenAI](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API Reference](https\://developers.openai.com/api/reference/resources/videos/methods/create).