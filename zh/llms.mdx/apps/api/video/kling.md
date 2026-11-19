# Kling 视频

## 接口说明

Kling 官方新版视频 API 使用功能/模型路径、settings/options 和统一任务查询：

| 操作   | 当前官方接口                                          | 文档                                          |
| ---- | ----------------------------------------------- | ------------------------------------------- |
| 文生视频 | `POST /text-to-video/kling-3.0`                 | [创建](/simidoc/zh/apps/api/video/kling/text-create) / [查询](/simidoc/zh/apps/api/video/kling/text-status)   |
| 图生视频 | `POST /image-to-video/kling-3.0`                | [创建](/simidoc/zh/apps/api/video/kling/image-create) / [查询](/simidoc/zh/apps/api/video/kling/image-status) |
| 查询   | `GET /tasks?task_ids=...` 或 external\_task\_ids | 通用任务查询                                      |

本节示例直连 `https://api-singapore.klingai.com`，使用 Kling 官方 API Key Bearer 鉴权。旧账户 AK/SK + HS256 JWT 仅适用于旧版设计标准；不能把 SimiRouter Key 或裸 SecretKey 当 Kling Key。

## 新旧协议不能混用

旧版 `/v1/videos/text2video`、`/v1/videos/image2video` 使用 model\_name、task\_id、task\_status 和 succeed；新版使用路由中的模型、data.id、status 和 succeeded。旧版 endpoint 在官方仍有 legacy 参考，但不能给新版请求补上旧版字段。SimiRouter `/kling/...` 属于网关映射，需确认渠道版本，不能只在新官方路径前添加前缀。

生成是异步过程，不是 SSE。创建后轮询或接收 callback，只有成功终态才消费 outputs 中的 video 项。

## 官方参考

[Kling 文生视频](https\://kling.ai/document-api/apiReference/model/textToVideo)、[图生视频](https\://kling.ai/document-api/apiReference/model/imageToVideo)、[鉴权](https\://kling.ai/document-api/api/get-started/authentication)。