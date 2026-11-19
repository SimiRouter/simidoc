# Grok Imagine 视频

## 概览

Grok Imagine 用 xAI 的异步视频接口：`POST /v1/videos/generations` 提交任务并返回 `request_id`，再用 `GET /v1/videos/{request_id}` 轮询。文本提示词可直接生成视频；提供 `image` 时进入图生视频，提供参考图或关键帧时进入参考生视频。

| 你要做的事 | 输入                                          | 输出           | 端点                            |
| ----- | ------------------------------------------- | ------------ | ----------------------------- |
| 文生视频  | `prompt`、时长、画幅、分辨率                          | `request_id` | `POST /v1/videos/generations` |
| 图生视频  | `image` + 可选 `prompt`                       | `request_id` | 同一端点                          |
| 参考生视频 | `prompt` + `reference_images` 或 `keyframes` | `request_id` | 同一端点                          |
| 查询任务  | `request_id`                                | 状态、视频 URL、用量 | `GET /v1/videos/{request_id}` |

## 核心概念

* **任务生命周期**：查询状态只有 `pending`、`done`、`failed`。`pending` 时 `progress` 在 0–99，`done` 时为 100，`failed` 时可能省略。
* **`request_id` 是轮询标识**：它不是幂等键。提交超时后不能凭“没有收到响应”判断任务未创建，应先保留并查询可能存在的 `request_id`。
* **轮询节奏**：官方文档没有规定固定间隔。客户端可用 5–10 秒间隔，并设置总等待上限；`failed` 后立即停止。
* **时长与画幅**：`duration` 范围 1–15 秒，默认 8 秒；图生视频会忽略 `aspect_ratio`，画幅随输入图片。`resolution` 默认 `480p`，`grok-imagine-video-1.5` 支持原生 1080p。
* **音频开关**：能力页列出 `generate_audio`，默认 `true`，设为 `false` 请求静音；REST 参考没有单列该字段，实际可用性以接口返回为准。
* **计费单位**：查询响应的 `usage.cost_in_usd_ticks` 是本次任务的成本计数，具体换算、单价与失败结算以厂商计价页为准。

## 规格与能力

| 指标    | 已核实取值                                                                       |
| ----- | --------------------------------------------------------------------------- |
| 模型 ID | `grok-imagine-video-1.5`、`grok-imagine-video-1.5-lite`、`grok-imagine-video` |
| 分辨率   | `480p`（默认）、`720p`、`1080p`；`grok-imagine-video-1.5` 为原生 1080p                |
| 宽高比   | `1:1`、`16:9`（默认）、`9:16`、`4:3`、`3:4`、`3:2`、`2:3`、`21:9`、`5:2`；图生视频忽略该字段      |
| 时长    | 1–15 秒，默认 8 秒；编辑已有视频时不接受自定义时长                                               |
| 音频    | `generate_audio` 默认 `true`，`false` 请求静音；以能力页描述为准                            |
| 参考素材  | `image` 首帧、`reference_images` 参考图、`keyframes` 最多 4 个、`last_frame` 尾帧（1.5）   |
| 图片输入  | 公网 URL、Base64 data URI，或 xAI Files API 的 `file_id`；JPEG、PNG、WebP            |
| 计费计量  | `usage.cost_in_usd_ticks`，单价按厂商计价页为准                                        |

默认 `480p` 适合预览，`720p` 与 `1080p` 会增加生成时间和成本。图生视频忽略 `aspect_ratio`，画幅由 `image` 决定；要控制横屏或竖屏，应在准备输入图片时处理。`duration` 默认 8 秒，实际耗时还受排队影响，不能只按时长估算。`generate_audio` 在能力页有说明、REST 参考未单列，接入前先用一个短请求验证当前模型是否接受该字段。

## 调用流程

1. 在 xAI 控制台创建 API Key，后续请求使用 `Authorization: Bearer`。
2. 选择生成方式：只发 `prompt` 是文生视频；加 `image` 是图生视频；加 `reference_images`、`keyframes` 或 `last_frame` 是参考生视频。
3. 调用 `POST https://api.x.ai/v1/videos/generations`，按目标模型设置 `duration`、`aspect_ratio`、`resolution` 和音频开关。
4. 保存响应中的 `request_id`。创建成功只代表任务已受理。
5. 轮询 `GET https://api.x.ai/v1/videos/{request_id}`，直到 `status` 为 `done` 或 `failed`。
6. `done` 后下载 `video.url`；需要写入自己的对象存储时，也可以在请求里使用 `output.upload_url` 或 `storage_options`。`failed` 时读取 `error.code` 与 `error.message`。

## 模拟调用

以下为示意报文，`request_id`、URL 和用量都不是真实账户数据。

创建请求：

```json
{
  "model": "grok-imagine-video-1.5",
  "prompt": "示例：夜晚的霓虹街道，镜头缓慢前推。",
  "duration": 6,
  "aspect_ratio": "16:9",
  "resolution": "720p",
  "generate_audio": true
}
```

创建成功返回轮询标识：

```json
{
  "request_id": "demo-request-0001"
}
```

查询到成功终态：

```json
{
  "status": "done",
  "progress": 100,
  "model": "grok-imagine-video-1.5",
  "video": {
    "url": "https://example.com/demo-grok-imagine.mp4",
    "duration": 6,
    "respect_moderation": true
  }
}
```

`pending` 时继续轮询；`failed` 时停止并读取 `error`。`video.respect_moderation` 为 `false` 时，URL 可能为空，不能当作可播放结果。

## 接入与会话

* **基础地址**：`https://api.x.ai`。生成、查询、编辑和延长分别是 `/v1/videos/generations`、`/v1/videos/{request_id}`、`/v1/videos/edits`、`/v1/videos/extensions`。
* **鉴权头**：`Authorization: Bearer PASTE_API_KEY_HERE`，请求体为 JSON。
* **两套地址**：直连用 `https://api.x.ai`；仅当渠道明确确认映射到本站网关时，才使用 `https://api.dwchainless.com` 和 `Authorization: Bearer` 加本站 Key；不能仅替换地址和鉴权。SimiRouter 渠道是否暴露 `/v1/videos/*`、是否保留 `request_id` 和状态字段，由渠道映射决定。
* **超时与幂等**：没有公开的幂等键。提交超时后先查询已知 `request_id`，确认任务不存在再重试；不要并发提交相同提示词来规避等待。
* **结果保存**：`video.url` 是临时地址，文档同时提供文件输出与过期时间字段。产品侧应先下载或转存，再对外提供长期链接。

## 官方参考

* [xAI：Grok Imagine 视频生成](https\://docs.x.ai/developers/model-capabilities/video/generation)
* [xAI：视频 REST API 参考](https\://docs.x.ai/developers/rest-api-reference/inference/videos)
* [xAI：图生视频](https\://docs.x.ai/developers/model-capabilities/video/image-to-video)