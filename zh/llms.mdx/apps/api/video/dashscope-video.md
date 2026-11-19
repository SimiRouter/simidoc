# DashScope 视频生成（Wan / HappyHorse）

## 概览

Wan 与 HappyHorse 都是阿里云百炼平台上的视频生成模型族，共用同一套 DashScope 异步协议：提交端点、`X-DashScope-Async` 头、任务查询路径、状态字符串与结果字段都相同。差别只在三处——模型 ID、输入结构、画幅参数。

| 你要做的事                 | 输入                                                       | 输出                        | 端点                                                            |
| --------------------- | -------------------------------------------------------- | ------------------------- | ------------------------------------------------------------- |
| 文生视频（Wan）             | 提示词、`parameters.size`、`duration`                         | `task_id`                 | `POST /api/v1/services/aigc/video-generation/video-synthesis` |
| 首帧图生视频（Wan）           | 提示词、`input.img_url`、`parameters.resolution`              | `task_id`                 | 同一提交端点                                                        |
| 文生视频（HappyHorse）      | 提示词、`resolution`、`ratio`、`duration`                      | `task_id`                 | 同一提交端点                                                        |
| 首帧或参考图生视频（HappyHorse） | `input.media` 中的 `first_frame` 或 1–9 张 `reference_image` | `task_id`                 | 同一提交端点                                                        |
| 查询任务                  | `task_id`                                                | `task_status`、`video_url` | `GET /api/v1/tasks/{task_id}`                                 |

## 核心概念

* **任务生命周期**：`PENDING → RUNNING → SUCCEEDED`，失败终态为 `FAILED`，另有 `CANCELED` 与 `UNKNOWN`。只有 `SUCCEEDED` 才读取 `output.video_url`。
* **两个 ID 分工不同**：`output.task_id` 用于查询任务；`request_id` 只用于追踪一次 HTTP 请求。排错时两者都要保留。
* **轮询节奏**：官方建议每 15 秒查询一次。任务 ID 与结果 URL 的有效期均为 24 小时，超时后查询会返回 `UNKNOWN`。
* **输入结构按模型族区分**：Wan 的图生视频用 `input.img_url`；HappyHorse 用 `input.media` 数组，元素带 `type`（`first_frame` 或 `reference_image`）与 `url`。两套结构不能互换。
* **画幅参数按模型族区分**：Wan 文生视频用 `parameters.size`（`宽*高`，如 `1280*720`），Wan 图生视频用 `parameters.resolution`（`480P`、`720P`、`1080P`）；HappyHorse 文生与参考图生视频用 `parameters.ratio`（如 `16:9`），首帧图生视频跟随首帧图片。
* **音频只在部分 Wan 代际**：Wan2.6 与 Wan2.5 默认生成与画面匹配的音乐或音效，也可用 `input.audio_url` 提供 WAV、MP3；Wan2.2 与 Wan2.1 默认输出无声视频。HappyHorse 文档没有音频输入或输出参数。
* **计费按输出秒数计量**：查询响应的 `usage.duration` 是输出视频时长。单价、失败任务结算和退款规则以厂商计价页与账单为准。

## 规格与能力

Wan 的取值：

| 指标     | 已核实取值                                                                                                                                                                                               |
| ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 文生视频模型 | `wan2.6-t2v`、`wan2.5-t2v-preview`、`wan2.2-t2v-plus`、`wan2.1-t2v-turbo`、`wan2.1-t2v-plus`                                                                                                            |
| 图生视频模型 | `wan2.6-i2v`、`wan2.6-i2v-flash`、`wan2.5-i2v-preview`、`wan2.2-i2v-plus`、`wan2.2-i2v-flash`、`wan2.1-i2v-turbo`、`wan2.1-i2v-plus`                                                                      |
| 分辨率    | 文生视频 `size`：`832*480`、`480*832`、`624*624`、`1280*720`、`720*1280`、`960*960`、`1088*832`、`832*1088`、`1920*1080`、`1080*1920`、`1440*1440`、`1632*1248`、`1248*1632`；图生视频 `resolution`：`480P`、`720P`、`1080P` |
| 时长     | `wan2.6-t2v` 为 2–15 秒；`wan2.5-t2v-preview` 为 5 或 10 秒；`wan2.2`、`wan2.1` 文生视频固定 5 秒；`wan2.1-i2v-turbo` 支持 3、4、5 秒                                                                                    |
| 音频     | Wan2.6、Wan2.5 自动生成音乐或音效；`audio_url` 支持 WAV、MP3，3–30 秒，最大 15 MB；Wan2.2、Wan2.1 默认无声                                                                                                                   |
| 参考素材   | 图生视频用 `input.img_url`，支持公网 URL 或 Base64；图片宽高 240–8000 像素，Wan2.6/2.5 最大 20 MB                                                                                                                        |

HappyHorse 的取值：

| 指标    | 已核实取值                                                                                               |
| ----- | --------------------------------------------------------------------------------------------------- |
| 模型 ID | `happyhorse-1.1-t2v`、`happyhorse-1.0-t2v`、`happyhorse-1.1-i2v`、`happyhorse-1.1-r2v`                 |
| 分辨率   | `480P`、`720P`、`1080P`，默认 `1080P`                                                                    |
| 宽高比   | 文生与参考图生视频：`16:9`（默认）、`9:16`、`1:1`、`4:3`、`3:4`、`4:5`、`5:4`、`9:21`、`21:9`；图生视频跟随首帧，允许 1\:2.5 到 2.5\:1 |
| 时长    | 3–15 秒，默认 5 秒；该范围在 `happyhorse-1.0-t2v`、图生视频和参考图生视频文档中明确，`happyhorse-1.1-t2v` 文档未给范围                |
| 参考图片  | 图生视频 1 张首帧，最短边至少 300 像素；参考图生视频 1–9 张，最短边至少 400 像素；单张最大 20 MB；格式 JPEG、JPG、PNG、WEBP                   |
| 其他参数  | `watermark` 默认 `true`，开启时右下角显示 HappyHorse；`seed` 范围 0–2147483647                                    |

Wan 的 `size` 是具体像素，`resolution` 是档位，两者服务于不同端点：文生视频 1080P 竖屏要写 `1080*1920`，不能写 `1080P`；图生视频反过来，只接受 `480P`、`720P`、`1080P`。HappyHorse 的首帧图生视频不读 `ratio`，输出比例由图片决定。Wan2.2 与 Wan2.1 文生视频固定 5 秒，加长 `duration` 不会得到更长片段。Wan2.6 与 Wan2.5 会自动生成音轨，下游不需要音频时应在后期移除，或先确认该模型是否提供关闭参数。参考图数量为 1–9 张时，提示词中的 `[Image N]` 必须与 `media` 顺序一致，顺序错了会引用错图。

## 调用流程

1. 在阿里云百炼创建 API Key。模型、请求地址和 Key 必须属于同一区域，跨区调用会失败。
2. 选择模型族与模式：Wan 的文生/图生视频，或 HappyHorse 的文生/首帧图生/参考图生视频。输入结构不同，不能复用同一份请求体。
3. 向 `POST /api/v1/services/aigc/video-generation/video-synthesis` 提交 JSON，带上 `Authorization: Bearer`、`Content-Type: application/json` 和 `X-DashScope-Async: enable`。
4. 保存 `output.task_id` 和 `request_id`。创建返回 `PENDING` 只代表排队成功。
5. 每 15 秒调用 `GET /api/v1/tasks/{task_id}`。`SUCCEEDED` 后读取 `output.video_url`；`FAILED` 时读取 `output.code` 与 `output.message`。
6. 在 24 小时内下载并转存视频。任务过期后不能再查询，结果 URL 也不能继续依赖。

## 模拟调用

以下为示意报文，任务 ID、请求 ID、URL 与用量都不是真实账户数据。

Wan 文生视频的创建请求：

```json
{
  "model": "wan2.5-t2v-preview",
  "input": {
    "prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "parameters": {
    "size": "1280*720",
    "duration": 5,
    "prompt_extend": true,
    "watermark": false,
    "seed": 20260804
  }
}
```

HappyHorse 首帧图生视频的创建请求：

```json
{
  "model": "happyhorse-1.1-i2v",
  "input": {
    "prompt": "示例：让画面中的帆船缓慢向前移动。",
    "media": [
      {
        "type": "first_frame",
        "url": "https://example.com/demo-first-frame.png"
      }
    ]
  },
  "parameters": {
    "resolution": "720P",
    "duration": 5,
    "watermark": false,
    "seed": 20260804
  }
}
```

两族模型的创建成功响应结构一致，只返回排队状态：

```json
{
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "PENDING"
  },
  "request_id": "demo-request-0001"
}
```

查询到成功终态：

```json
{
  "request_id": "demo-request-0001",
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "SUCCEEDED",
    "video_url": "https://example.com/demo-video.mp4",
    "orig_prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "usage": {
    "duration": 5,
    "output_video_duration": 5,
    "video_count": 1,
    "SR": 720
  }
}
```

`PENDING`、`RUNNING` 继续等待；`FAILED`、`CANCELED` 立即停止并保存 `output.code` 与 `output.message`；`UNKNOWN` 先确认任务是否已超过 24 小时。

## 接入与会话

* **基础地址**：`https://{WorkspaceId}.{region}.maas.aliyuncs.com`。新加坡、美国、北京、法兰克福、东京使用不同区域主机，提交与查询路径相同。
* **鉴权头**：`Authorization: Bearer PASTE_API_KEY_HERE`；创建任务必须加 `X-DashScope-Async: enable`，缺少该头会收到同步调用错误。
* **两套地址**：直连用 `https://{WorkspaceId}.{region}.maas.aliyuncs.com`；仅当渠道明确确认映射到本站网关时，才使用 `https://api.dwchainless.com` 和 `Authorization: Bearer` 加本站 Key；不能仅替换地址和鉴权。SimiRouter 渠道若做统一封装，`task_id`、状态字符串和结果字段可能被改写；以渠道文档为准。
* **超时与幂等**：提交超时后先保存并查询可能已创建的 `task_id`，不要立即重复提交。轮询请求本身可以重试，但要设置总等待上限。
* **结果保存**：`video_url` 是带时效的下载地址。需要长期使用时，下载后转码或转存，不要把厂商 URL 直接写进产品数据库当作永久资源。

## 官方参考

* [Wan 文生视频 API 参考](https\://www.alibabacloud.com/help/en/model-studio/legacy-wan-text-to-video-api-reference)
* [Wan 图生视频 API 参考](https\://www.alibabacloud.com/help/en/model-studio/image-to-video-api-reference)
* [Wan2.5 图生视频模型说明](https\://www.alibabacloud.com/help/en/model-studio/wan2-5-i2v)
* [HappyHorse 文生视频 API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-text-to-video-api-reference)
* [HappyHorse 首帧图生视频 API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-image-to-video-api-reference)
* [HappyHorse 参考图生视频 API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-reference-to-video-api-reference)