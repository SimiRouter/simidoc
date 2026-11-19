# Video Jimeng (chờ tích hợp)

## Tổng quan API

Video Jimeng chính thức qua **Volcengine Visual** cung cấp chữ thành video và ảnh khung đầu qua API đồng bộ sang bất đồng bộ. Khác với **Volcengine Ark Seedance** về cổng và xác thực, không chung khóa Bearer.

| Bước     | Yêu cầu chính thức                                                                        | Tài liệu                     |
| -------- | ----------------------------------------------------------------------------------------- | ---------------------------- |
| Gửi      | POST `https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31` | [Gửi tác vụ](/simidoc/vi/apps/api/video/jimeng/create)       |
| Truy vấn | POST cùng máy chủ, Action=CVSync2AsyncGetResult                                           | [Truy vấn kết quả](/simidoc/vi/apps/api/video/jimeng/status) |

Giữ tham khảo Jimeng 3.0 Pro chính thức đang ngừng; kiểm sản phẩm, phiên bản còn mở trong Volcengine console. SimiRouter là tham khảo chờ tích hợp, không hứa gọi công khai khi chưa cấu hình rõ.

## Xác thực và luồng bất đồng bộ

Dùng AK/SK HMAC-SHA256 V4, Region=`cn-north-1`, Service=`cv`. Authorization không Bearer; ký phủ phương thức, đường dẫn, query, header chỉ định, hash thân.

code=10000 lấy data.task\_id; truy vấn cùng req\_key/task\_id. Trạng thái in\_queue, generating, done, not\_found, expired. **done chỉ xử lý kết thúc, không bảo đảm thành công**; kiểm code, message, video\_url. Không luồng video trực tiếp hay SSE.

## Tham khảo chính thức

[API Jimeng 3.0 Pro](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh), [Triển khai ký chính thức Volcengine](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py).