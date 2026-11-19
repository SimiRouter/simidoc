# BFL FLUX 图片生成

## 概览

Black Forest Labs（BFL）的 FLUX API 采用“提交任务 + 轮询结果”的异步模型。提交请求只返回任务 ID 和 `polling_url`，图片生成完成后才从轮询结果中读取签名 URL。

| 你要做的事     | 输入                        | 输出                      | 端点                                              |
| --------- | ------------------------- | ----------------------- | ----------------------------------------------- |
| 从文字生成图片   | `prompt`、`width`、`height` | 任务 `id` 与 `polling_url` | `POST https://api.bfl.ai/v1/flux-pro-1.1`       |
| 按比例生成宽幅图片 | `prompt`、`aspect_ratio`   | 任务 `id` 与 `polling_url` | `POST https://api.bfl.ai/v1/flux-pro-1.1-ultra` |
| 参考图生成或编辑  | `prompt` + `input_image`  | 任务 `id` 与 `polling_url` | `POST https://api.bfl.ai/v1/flux-2-pro` 等       |
| 获取最终图片    | `polling_url`             | `result.sample` 签名 URL  | `GET {polling_url}`                             |

## 核心概念

* **尺寸用 `width` / `height`**：FLUX 1.1 pro 的宽高范围是 256–1440，且必须是 32 的倍数。它不是分辨率档位，也不是 `size` 字符串。
* **Ultra 用 `aspect_ratio`**：`/v1/flux-pro-1.1-ultra` 没有宽高字段，改用 `aspect_ratio`（默认 `16:9`，文档描述范围为 `21:9` 到 `9:21`）。
* **`seed` 控制可复现性**：相同的提示词、参数和 `seed` 用于对比不同设置；它不保证跨模型或跨版本得到相同画面。
* **`steps` / `guidance` 只出现在部分模型**：FLUX.2 flex 支持 `steps`（1–50）和 `guidance`（1.5–10.0）；FLUX 1.1 pro 没有这两个字段。
* **提交与结果是两次请求**：提交返回 `id`、`polling_url` 和可选的 `cost`；轮询到 `Ready` 后才从 `result.sample` 取图，处理中为 `Pending`，失败或内容审核会返回对应状态。
* **签名 URL 有效期约 10 分钟**：`result.sample` 过期很快，必须及时下载并转存，不要把该地址长期当作公开图片链接。

## 规格与能力

| 端点                       | 尺寸控制                                            | 参考图                                            | 其他主要字段                                                            | 返回格式                 |
| ------------------------ | ----------------------------------------------- | ---------------------------------------------- | ----------------------------------------------------------------- | -------------------- |
| `/v1/flux-pro-1.1`       | `width`、`height`：256–1440，32 的倍数；默认 1024×768    | `image_prompt`（Base64，Flux Redux 风格参考）         | `seed`、`prompt_upsampling`、`safety_tolerance` 0–6、`output_format` | 轮询后取 `result.sample` |
| `/v1/flux-pro-1.1-ultra` | 无 `width` / `height`；用 `aspect_ratio`，默认 `16:9` | `image_prompt`、`image_prompt_strength` 0.0–1.0 | `seed`、`prompt_upsampling`、`raw`、`safety_tolerance` 0–6           | 同上                   |
| `/v1/flux-2-pro`         | `width`、`height`：最小 64，文档未给上限                   | `input_image` 至 `input_image_8`，最多 8 张         | `seed`、`safety_tolerance` 0–7、`output_format`                     | 同上                   |
| `/v1/flux-2-flex`        | `width`、`height`：最小 64，文档未给上限                   | `input_image` 至 `input_image_8`，最多 8 张         | `steps` 1–50、`guidance` 1.5–10.0、`seed`、`output_format`           | 同上                   |

`output_format` 可选 `jpeg`、`png`、`webp`，默认 `jpeg`。表中未列上限的端点，以对应端点的 OpenAPI schema 为准；不要把一个端点的宽高限制套到另一个端点。

## 调用流程

1. **准备密钥**：在 BFL 控制台创建 API Key，请求头使用 `x-key: $BFL_API_KEY`，不是 `Authorization: Bearer`。
2. **选择端点**：按模型能力选择 `/v1/flux-pro-1.1`、`/v1/flux-pro-1.1-ultra` 或其他 `/v1/flux-*` 端点。
3. **提交任务**：发送 JSON，设置 `prompt`、尺寸字段、`output_format` 和可选的 `seed`。
4. **保存 `polling_url`**：从响应中读取 `id` 与 `polling_url`，不要自行拼接轮询地址。
5. **轮询到 `Ready`**：用相同的 `x-key` 请求 `polling_url`；`Pending` 时继续等待，`Error` 或审核状态时停止并记录原因。
6. **下载并验收**：在签名 URL 过期前下载 `result.sample`，检查文件能否打开、尺寸与内容，再核对 `cost` 和使用日志。

## 模拟调用

以下报文为示意，不是真实账户返回；任务 ID、URL 和费用数值仅用于说明结构。

提交请求：

```json
{
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "width": 1024,
  "height": 768,
  "seed": 42,
  "output_format": "jpeg",
  "safety_tolerance": 2
}
```

提交成功响应（异步，尚未生成图片）：

```json
{
  "id": "task_example_01",
  "polling_url": "https://api.bfl.ai/v1/get_result?id=task_example_01",
  "cost": 0.04
}
```

轮询完成响应（`status` 为 `Ready`）：

```json
{
  "id": "task_example_01",
  "status": "Ready",
  "progress": 1,
  "result": {
    "sample": "https://delivery.example.bfl.ai/sample/image.jpeg"
  }
}
```

轮询期间还可能看到 `Pending`、`Error`、`Request Moderated`、`Content Moderated` 等状态。审核不通过时 `result` 可能为 `null`，原因在 `details` 中。

## 接入与会话

* **Base URL**：`https://api.bfl.ai`；也提供 `https://api.eu.bfl.ai` 和 `https://api.us.bfl.ai`。使用哪个入口，就轮询响应里返回的同一个 `polling_url`。
* **鉴权**：`x-key: $BFL_API_KEY`。这是与 OpenAI 风格接口最明显的差异，不要把 Key 放进 `Authorization` 头。
* **完全异步**：提交请求不返回图片，只返回 `id` 和 `polling_url`；必须再发一次 `GET` 才能拿到结果。
* **与 OpenAI 的差异**：没有 `/v1/images/generations` 端点，也没有 `size`、`quality`、`n` 字段；尺寸由 `width` / `height` 或 `aspect_ratio` 控制。
* **回调替代轮询**：请求可以带 `webhook_url` 和 `webhook_secret`，由 BFL 在完成时回调；使用回调时仍要校验签名并处理失败事件。
* **经本站网关调用**：把地址换成 `https://api.dwchainless.com`，鉴权使用本站 Key；FLUX 是异步任务，网关是否透传 `polling_url` 和 `x-key` 头以渠道为准，未开通时按上面的官方地址直连。
* **超时**：提交请求应快速返回，超时后可先查询是否已创建任务；轮询建议间隔约 0.5 秒，整体等待时间按模型和队列长度设置上限，不要无限重试。

## 官方参考

* [BFL 快速开始：文本生成图片](https\://docs.bfl.ai/quick_start/generating_images)
* [BFL OpenAPI 规范](https\://api.bfl.ai/openapi.json)
* [BFL API 文档全文](https\://docs.bfl.ai/llms-full.txt)