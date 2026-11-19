# PixVerse 视频

## 概览

PixVerse 官方 OpenAPI 用普通 HTTP 请求提交异步生成任务，创建成功后返回 `video_id`，再用同一 ID 查询状态并取得视频地址。文生视频与图生视频是两个入口；图生视频要先上传图片，拿到 `img_id` 后再提交。

| 你要做的事   | 输入                                 | 输出             | 端点                                        |
| ------- | ---------------------------------- | -------------- | ----------------------------------------- |
| 从文字生成视频 | 提示词、时长、`quality`、`aspect_ratio`    | `video_id`     | `POST /openapi/v2/video/text/generate`    |
| 从图片生成视频 | 已上传图片的 `img_id`（或模板 `img_ids`）加提示词 | `video_id`     | `POST /openapi/v2/video/img/generate`     |
| 查询任务结果  | `video_id`                         | 状态、视频 URL、实际规格 | `GET /openapi/v2/video/result/{video_id}` |
| 上传图片    | 图片文件                               | `img_id`       | `POST /openapi/v2/image/upload`           |

## 核心概念

* **任务生命周期**：创建返回 `ErrCode=0` 和 `video_id`，只表示任务已受理。查询状态 `1` 为完成，`5` 为生成中，`7` 为内容审核失败，`8` 为生成失败；`1`、`7`、`8` 都是终态。
* **两个 ID 的用途不同**：`video_id` 是业务任务标识，用于查询和下载；`Ai-trace-id` 是每个请求都要新生成的 UUID，只用于追踪，不是幂等键，重复使用可能创建另一个任务。
* **轮询节奏**：官方建议每 3–5 秒查询一次。客户端要设置总等待上限；进入 `7` 或 `8` 后立即停止，不要继续重试同一任务。
* **计费单位**：创建响应中的 `Resp.credits` 是本次任务消耗的积分。实际单价、套餐与退款规则以厂商计价页和账户账单为准。
* **画幅与时长分开控制**：文生视频用 `quality` 指定清晰度档位、用 `aspect_ratio` 指定画幅；图生视频没有 `aspect_ratio` 字段，画幅由输入图片或模板决定。`duration` 的有效值随模型变化，不能只按接口的 1–15 范围填写。

## 规格与能力

| 指标    | 已核实取值                                                                               |
| ----- | ----------------------------------------------------------------------------------- |
| 模型 ID | `v6-max`、`c1`、`v6`、`v5.6`、`v5.5`、`v5`、`v5-fast`、`v4.5`、`v4`、`v3.5`；`v5-fast` 需要账户权限 |
| 分辨率   | `quality`：`360p`、`540p`、`720p`、`1080p`                                              |
| 宽高比   | 文生视频：`16:9`、`9:16`、`4:3`、`3:4`、`1:1`、`2:3`、`3:2`、`21:9`；图生视频：无该字段                   |
| 时长    | 接口范围 1–15 秒；C1、V6 为 1–15 秒，V5.5、V5.6 为 5、8 或 10 秒，旧模型为 5 或 8 秒                      |
| 音频    | `generate_audio_switch` 布尔开关，默认 `false`；V5.5、V5.6、V6、C1 支持原生音频                      |
| 参考图片  | 图生视频先上传得到 `img_id`；模板任务用 `img_ids` 配合 `template_id`                                 |
| 计费计量  | 创建响应返回 `Resp.credits`，单价按厂商计价页为准                                                    |

选择时先看模型代际，再看 `quality` 与 `duration`。`quality` 只决定输出像素档位，不改变画幅；`aspect_ratio` 只决定形状，最终像素由两者共同决定。图生视频没有 `aspect_ratio` 字段，不要照搬文生视频请求体，画幅由输入图片或模板决定。创建响应中的 `Resp.credits` 适合做预算记录，实际扣费与退款仍以账户账单为准。

## 调用流程

1. 在 PixVerse 开放平台创建 API Key。请求使用 `API-KEY` 头，不要把它写进提示词或代码仓库。
2. 图生视频先调用 `POST /openapi/v2/image/upload` 上传图片，保存响应中的 `Resp.img_id`；文生视频跳过这一步。
3. 向对应生成端点提交 JSON。必填字段为 `model`、`prompt`、`duration`、`quality`；文生视频还需要 `aspect_ratio`。每次请求生成新的 `Ai-trace-id`。
4. 保存创建响应中的 `Resp.video_id`。不要把 `ErrCode=0` 当作视频已经生成。
5. 每 3–5 秒调用一次查询端点。只在 `status=1` 且 `Resp.url` 可访问时下载；`status=7` 修正内容后再决定是否重试，`status=8` 保留 `Ai-trace-id` 供排查。
6. 把视频转存到自己的存储。结果 URL 的访问策略与有效期以厂商说明为准，不要把它当作永久公开地址。

## 模拟调用

以下报文只用于说明字段结构，任务 ID、积分和 URL 都是示意值，不是真实账户数据。

创建文生视频任务：

```json
{
  "model": "v6-max",
  "prompt": "示例：海边日落，一艘白色帆船缓慢驶过，镜头平稳。",
  "duration": 5,
  "quality": "720p",
  "aspect_ratio": "16:9",
  "seed": 20260804,
  "generate_audio_switch": false
}
```

创建成功只返回任务 ID 和消耗积分：

```json
{
  "ErrCode": 0,
  "ErrMsg": "Success",
  "Resp": {
    "video_id": 900000000000001,
    "credits": 12
  }
}
```

查询到 `status=1` 才有可下载地址：

```json
{
  "ErrCode": 0,
  "ErrMsg": "Success",
  "Resp": {
    "id": 900000000000001,
    "status": 1,
    "url": "https://example.com/demo-pixverse.mp4",
    "duration": 5,
    "quality": "720p",
    "aspect_ratio": "16:9",
    "outputWidth": 1280,
    "outputHeight": 720,
    "has_audio": false,
    "credits": 12
  }
}
```

`status=5` 时继续轮询；`status=7` 或 `status=8` 立即结束，并从 `ErrMsg`、`Error.Message` 和 `Ai-trace-id` 记录失败原因。

## 接入与会话

* **基础地址**：`https://app-api.pixverse.ai`。生成与查询都在 `/openapi/v2/` 下。
* **鉴权头**：`API-KEY: PASTE_API_KEY_HERE`；`Content-Type: application/json`；每个请求再加一个新的 `Ai-trace-id`。
* **两套地址**：直连用 `https://app-api.pixverse.ai`，鉴权头为 `API-KEY`；仅当渠道明确确认映射到本站网关时，才使用 `https://api.dwchainless.com` 和 `Authorization: Bearer` 加本站 Key；不能仅替换地址和鉴权。SimiRouter 渠道是否映射这些路径、是否改用统一视频协议，取决于渠道配置；不能只换域名就假定字段兼容。
* **超时与幂等**：创建请求超时不能说明服务端没有受理。先按已保存的 `video_id` 查询，确认不存在后再重试；不要连续提交相同提示词来“催进度”。
* **错误判断**：HTTP 200 也可能带非零 `ErrCode`。业务错误要读 `ErrCode`、`ErrMsg` 和可选的 `Error.Type`、`Error.Param`，不要只看 HTTP 状态码。

## 官方参考

* [PixVerse Quick Start](https\://docs.platform.pixverse.ai/quick-start-2394985m0)
* [PixVerse 文生视频 API](https\://docs.platform.pixverse.ai/text-to-video-generation-13016634e0)
* [PixVerse 图生视频 API](https\://docs.platform.pixverse.ai/image-to-video-generation-13016633e0)
* [PixVerse 查询任务状态](https\://docs.platform.pixverse.ai/query-task-status-43051212e0)