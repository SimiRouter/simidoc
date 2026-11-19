# xAI Grok 图片生成

## 概览

xAI Grok 的图片生成接口沿用 OpenAI Images 的路径和响应信封，但请求参数是 xAI 原生字段：用 `aspect_ratio` 与 `resolution` 指定画幅，而不是 `size`。默认同步返回，也可以开启 `deferred` 后轮询任务。

| 你要做的事    | 输入                          | 输出               | 端点                                            |
| -------- | --------------------------- | ---------------- | --------------------------------------------- |
| 从文字生成图片  | `prompt`                    | 新图片              | `POST https://api.x.ai/v1/images/generations` |
| 一次生成多张   | `prompt` + `n`（1–10）        | 多张图片             | 同上                                            |
| 后台生成后取结果 | `prompt` + `deferred: true` | `request_id`，再轮询 | 同上，轮询 `GET /v1/images/{request_id}`           |
| 编辑已有图片   | `prompt` + 图片               | 编辑后的图片           | `POST https://api.x.ai/v1/images/edits`       |

## 核心概念

* **`aspect_ratio` 取代 `size`**：接口不接受 OpenAI 的 `size` 和 `style`。画幅由 `aspect_ratio` 控制，常用值包括 `1:1`、`16:9`、`9:16`、`4:3`、`3:4`、`2:3`、`3:2`、`21:9` 与 `auto`。
* **`resolution` 控制分辨率档位**：取 `1k` 或 `2k`，默认 `1k`。它是档位，不是像素值；同一档位下的实际宽高由 `aspect_ratio` 决定。
* **`quality` 只对 2.0 模型生效**：可选 `low`、`medium`、`auto`；`auto` 在生成时当前按 `low` 处理，在编辑时按 `medium` 处理。
* **默认同步，`deferred` 可选异步**：同步请求直接返回 `data[]`；设置 `deferred: true` 后立即返回 `request_id`，再轮询 `GET /v1/images/{request_id}`。延迟任务只支持 `response_format: "url"`，结果保留 24 小时。
* **URL 是临时的**：`response_format` 为 `url`（默认）时，返回的图片地址会过期；需要长期保存时及时下载，或改用 `b64_json`。
* **按张计费**：`n` 表示单次请求生成张数，范围为 1–10。响应的 `usage.cost_in_usd_ticks` 给出该次请求的费用信息，实际结算以本站账单为准。

## 规格与能力

| 模型 ID                    | 分辨率档位     | 宽高比                                                                                                         | 参考图                               | 返回格式               |
| ------------------------ | --------- | ----------------------------------------------------------------------------------------------------------- | --------------------------------- | ------------------ |
| `grok-imagine-image-2.0` | `1k`、`2k` | `1:1`、`16:9`、`9:16`、`4:3`、`3:4`、`3:2`、`2:3`、`2:1`、`1:2`、`19.5:9`、`9:19.5`、`20:9`、`9:20`、`21:9`、`5:2`、`auto` | 生成接口不接收参考图；编辑走 `/v1/images/edits` | `url` 或 `b64_json` |

`grok-2-image` 是旧模型名，现行官方接口文档使用 `grok-imagine-image-2.0`。调用前从[模型与价格](https://api.dwchainless.com/zh/pricing/)确认本站渠道实际提供的模型 ID，不要直接套用旧教程中的名称。

## 调用流程

1. **准备密钥**：在 xAI 控制台创建 Key，请求头使用 `Authorization: Bearer $XAI_API_KEY`。
2. **确认模型**：在[模型与价格](https://api.dwchainless.com/zh/pricing/)核对 `grok-imagine-image-2.0` 或渠道提供的等价模型。
3. **选择画幅**：设置 `aspect_ratio` 和 `resolution`；不要发送 `size`。
4. **发送请求**：向 `/v1/images/generations` 提交 JSON。预计耗时较长时加 `deferred: true`。
5. **读取结果**：同步响应取 `data[].url` 或 `data[].b64_json`；延迟任务轮询到 `done` 后再取 `data[]`。
6. **保存并验收**：在 URL 过期前下载图片，检查文件能否打开、尺寸与内容，再核对使用日志。

## 模拟调用

以下报文为示意，不是真实账户返回；URL 与费用数值已截断或仅作示例。

同步请求：

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "response_format": "url"
}
```

同步成功响应：

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

延迟任务请求：

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "deferred": true
}
```

提交后的示意响应：

```json
{
  "request_id": "req_example_01"
}
```

轮询完成的示意响应（HTTP 200；处理中为 202，失败时返回 `error.code` 与 `error.message`）：

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

## 接入与会话

* **Base URL**：`https://api.x.ai/v1`。生成端点为 `/v1/images/generations`，编辑端点为 `/v1/images/edits`。
* **鉴权**：`Authorization: Bearer $XAI_API_KEY`。OpenAI SDK 可以把 `base_url` 设为 `https://api.x.ai/v1` 复用，但请求字段仍按 xAI 文档填写。
* **与 OpenAI 的差异**：路径和 `data[]` 信封相似，但 `size`、`style` 不受支持；用 `aspect_ratio`、`resolution`、`quality` 代替。`n` 上限为 10。
* **延迟任务**：`deferred` 只支持 URL 输出，提交后轮询 `GET /v1/images/{request_id}`；结果保留 24 小时，超时需重新生成。
* **经本站网关调用**：请求地址改为 `https://api.dwchainless.com/v1/images/generations`，鉴权使用本站 Key；模型 ID 与参数透传以渠道为准。
* **超时**：同步生成通常在一次请求内完成，客户端仍应留出足够超时；耗时不可控或批量生成时优先使用 `deferred`，不要在超时后盲目重发。

## 官方参考

* [xAI 图片生成能力](https\://docs.x.ai/developers/model-capabilities/images/generation)
* [xAI Images REST API 参考](https\://docs.x.ai/developers/rest-api-reference/inference/images)