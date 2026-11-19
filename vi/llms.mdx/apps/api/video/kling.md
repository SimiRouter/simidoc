# Video Kling

## Tổng quan API

API mới dùng đường dẫn chức năng/mô hình, settings/options, truy vấn thống nhất\:

| Thao tác        | API chính thức hiện tại                            | Tài liệu                                           |
| --------------- | -------------------------------------------------- | -------------------------------------------------- |
| Chữ thành video | `POST /text-to-video/kling-3.0`                    | [Tạo](/simidoc/vi/apps/api/video/kling/text-create) / [Truy vấn](/simidoc/vi/apps/api/video/kling/text-status)   |
| Ảnh thành video | `POST /image-to-video/kling-3.0`                   | [Tạo](/simidoc/vi/apps/api/video/kling/image-create) / [Truy vấn](/simidoc/vi/apps/api/video/kling/image-status) |
| Truy vấn        | `GET /tasks?task_ids=...` hoặc external\_task\_ids | Truy vấn chung                                     |

Ví dụ trực tiếp `https://api-singapore.klingai.com`, dùng khóa Kling Bearer. AK/SK + HS256 JWT tài khoản cũ chỉ thiết kế cũ; không dùng SimiRouter hay SecretKey trần làm Kling key.

## Không trộn giao thức cũ/mới

Bản cũ `/v1/videos/text2video`, `/v1/videos/image2video` dùng model\_name, task\_id, task\_status, succeed; mới mô hình trong tuyến, data.id, status, succeeded. Legacy còn tham khảo, không thêm trường cũ vào mới. SimiRouter `/kling/...` là ánh xạ cổng, cần phiên bản kênh; không chỉ thêm tiền tố đường dẫn mới.

Sinh bất đồng bộ, không SSE. Poll hoặc callback sau tạo, chỉ dùng video trong outputs khi trạng thái cuối thành công.

## Tham khảo chính thức

[Kling chữ thành video](https\://kling.ai/document-api/apiReference/model/textToVideo), [Ảnh thành video](https\://kling.ai/document-api/apiReference/model/imageToVideo), [Xác thực](https\://kling.ai/document-api/api/get-started/authentication).