# Video Seedance

## Tổng quan API

Seedance hỗ trợ chữ và tham chiếu ảnh/video/âm thanh tùy mô hình. Quy trình Ark tạo bất đồng bộ, truy vấn, tải sau thành công.

| Thao tác | Đường dẫn chính thức                          | Tài liệu                    |
| -------- | --------------------------------------------- | --------------------------- |
| Tạo      | `POST /api/v3/contents/generations/tasks`     | [Tạo tác vụ](/simidoc/vi/apps/api/video/seedance/create)      |
| Truy vấn | `GET /api/v3/contents/generations/tasks/{id}` | [Truy vấn tác vụ](/simidoc/vi/apps/api/video/seedance/status) |

Địa chỉ gốc chính thức `https://ark.cn-beijing.volces.com` và `ARK_API_KEY` xác thực Bearer.`/v1/video/generations` là đường dẫn cổng tương thích, không Ark chính thức; chỉ dùng khi kênh có ánh xạ rõ, không tự đổi id/status sang hãng khác.

Trạng thái là `queued → running → succeeded`; lỗi cuối failed, expired, cancelled. Không SSE/Realtime. Phiên bản quyết định có tiếng, tham chiếu, thời lượng, độ phân giải.

## Tham khảo chính thức

[Tạo tác vụ video](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh), [Truy vấn tác vụ](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh), [Hướng dẫn video](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh).