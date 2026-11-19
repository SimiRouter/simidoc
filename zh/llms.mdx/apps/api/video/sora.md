# Sora 视频（官方接口已关闭）

**OpenAI 官方 Sora 2 与 Videos API 已于 2026-09-24 关闭。** 下方仅保留接口结构参考，不是可用调用教程。SimiRouter 若存在同名模型或第三方兼容实现，其来源、能力与协议应另行确认，不能称作 OpenAI 官方直连。

## 接口说明

| 操作   | 原官方端点                               | 参考              |
| ---- | ----------------------------------- | --------------- |
| 创建任务 | `POST /v1/videos`                   | [创建](/simidoc/zh/apps/api/video/sora/create)  |
| 查询任务 | `GET /v1/videos/{video_id}`         | [查询](/simidoc/zh/apps/api/video/sora/status)  |
| 下载视频 | `GET /v1/videos/{video_id}/content` | [内容](/simidoc/zh/apps/api/video/sora/content) |

原协议为异步生成，status 从 queued/in\_progress 进入 completed 或 failed；没有普通流式生成输出。官方停用通知明确没有一对一替代 API。其他视频能力请按 [视频分类](/simidoc/zh/apps/api/video) 选择可用供应商，不做自动替换。

## 官方参考

[OpenAI 关闭通知](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api)、[Videos API Reference](https\://developers.openai.com/api/reference/resources/videos/methods/create)。