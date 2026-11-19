# Seedance 视频

## 接口说明

Seedance 支持文本生成视频和模型允许的图片、视频、音频参考输入。火山方舟官方流程为创建异步任务、查询状态、成功后下载。

| 操作 | 官方路径                                          | 文档               |
| -- | --------------------------------------------- | ---------------- |
| 创建 | `POST /api/v3/contents/generations/tasks`     | [创建任务](/simidoc/zh/apps/api/video/seedance/create) |
| 查询 | `GET /api/v3/contents/generations/tasks/{id}` | [查询任务](/simidoc/zh/apps/api/video/seedance/status) |

官方基础地址 `https://ark.cn-beijing.volces.com`，使用 `ARK_API_KEY` Bearer 鉴权。`/v1/video/generations` 是网关兼容路径，不是火山方舟官方地址；只有渠道明确提供映射时才使用，不能把 id/status 自动改写成其他厂商格式。

状态为 `queued → running → succeeded`，失败终态包括 failed、expired、cancelled。它不是 SSE 或 Realtime。模型版本决定有声视频、参考素材、时长和分辨率的支持范围。

## 官方参考

[创建视频任务](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)、[查询任务](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)、[视频教程](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh)。