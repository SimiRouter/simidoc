# Seedance video

## Endpoint overview

Seedance supports text-to-video and model-permitted image, video, and audio references. The official Ark workflow creates an asynchronous task, polls status, and downloads after success.

| Operation | Official path                                 | Documentation           |
| --------- | --------------------------------------------- | ----------------------- |
| Create    | `POST /api/v3/contents/generations/tasks`     | [Create task](/simidoc/en/apps/api/video/seedance/create) |
| Query     | `GET /api/v3/contents/generations/tasks/{id}` | [Query task](/simidoc/en/apps/api/video/seedance/status)  |

Official base URL `https://ark.cn-beijing.volces.com` and `ARK_API_KEY` with Bearer authentication. `/v1/video/generations` is a compatible gateway path, not an official Ark address. Use it only with an explicit channel mapping; do not automatically rewrite id/status into another vendor’s format.

Statuses are `queued → running → succeeded`; failed terminal states include failed, expired, and cancelled. It is neither SSE nor Realtime. Model versions determine audio, reference, duration, and resolution support.

## Official reference

[Create video task](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh), [Query task](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh), [Video tutorial](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh).