# 即梦 / 火山方舟图片生成

## 概览

火山方舟（Volcengine Ark）的图片生成接口使用 Seedream 系列模型（`doubao-seedream-*`），从文字或参考图生成图片。请求一次提交，同步返回 `data[]`；部分模型还支持流式或批量生成。

| 你要做的事    | 输入                 | 输出   | 端点                                                                 |
| -------- | ------------------ | ---- | ------------------------------------------------------------------ |
| 从文字生成图片  | `prompt`           | 新图片  | `POST https://ark.cn-beijing.volces.com/api/v3/images/generations` |
| 参考图生成或改图 | `prompt` + `image` | 新图片  | 同上                                                                 |
| 批量生成多张   | `prompt` + 批量生成参数  | 多张图片 | 同上                                                                 |

## 核心概念

* **`size` 有两种写法**：分辨率档位（如 `2K`）或明确像素（如 `2048x2048`）。档位是模型预设，不等于固定宽高；同一档位下实际尺寸取决于模型与提示词中的画幅描述。
* **参考图放在 `image`**：可以是 HTTP(S) URL 或 `data:image/...;base64,...`。传数组即为多图参考，数量上限随模型变化。
* **`watermark` 默认开启**：默认 `true` 时会在图片上添加“AI 生成”标识；需要无水印输出时显式传 `false`，并确认用途符合适用的合成内容标识要求。
* **同步返回**：普通请求直接等待 `data[]`。`stream` 只对 Seedream 5.0 lite、4.5、4.0 等部分模型开放，不能靠添加流式参数把其他模型变成异步任务。
* **按张计费**：计费与生成张数相关。`sequential_image_generation` 的批量输出会按实际生成的图片张数累计，失败项以 `data[].error` 单独返回。

## 规格与能力

| 模型 ID                             | `size` 档位与上限                                          | 参考图     | 输出格式                                   |
| --------------------------------- | ----------------------------------------------------- | ------- | -------------------------------------- |
| `doubao-seedream-5-5-261028`      | `1K`、`1.5K`、`2K` 或 `WxH`；像素 921600–4624220，比例 1/16–16 | 最多 10 张 | `url` / `b64_json`；`png` 默认，也支持 `jpeg` |
| `doubao-seedream-5-0-lite-260128` | `2K`、`3K`、`4K` 或 `WxH`；像素 3686400–16777216，比例 1/16–16 | 最多 14 张 | `url` / `b64_json`；`png` / `jpeg`      |
| `doubao-seedream-4-5-251128`      | `2K`、`4K` 或 `WxH`；像素 3686400–16777216，比例 1/16–16      | 最多 14 张 | `url` / `b64_json`；`png` / `jpeg`      |
| `doubao-seedream-4-0-250828`      | `1K`、`2K`、`4K` 或 `WxH`；像素 921600–16777216，比例 1/16–16  | 最多 14 张 | `url` / `b64_json`；`png` / `jpeg`      |

像素上限按总像素计算，例如 16777216 像素对应 4096×4096。模型 ID 会随版本更新，调用前以火山方舟模型目录和[模型与价格](https://api.dwchainless.com/zh/pricing/)为准；`model` 也可以填推理接入点 ID（`ep-...`）。

## 调用流程

1. **准备密钥**：在火山方舟控制台创建 API Key，请求头使用 `Authorization: Bearer $ARK_API_KEY`。
2. **选择模型与尺寸**：确认模型支持的 `size` 档位或像素范围，并决定是否需要参考图。
3. **发送 JSON 请求**：向 `/api/v3/images/generations` 提交 `model`、`prompt`，按需添加 `image`、`size`、`response_format` 和 `watermark`。
4. **读取 `data[]`**：`response_format` 为 `url` 时取 `data[].url`（有效期 24 小时），为 `b64_json` 时解码 `data[].b64_json`。
5. **保存并验收**：检查文件能否打开、实际尺寸与内容；批量生成时逐项检查 `data[].error`，不要只看 HTTP 状态。
6. **核对费用**：在使用日志中确认模型、张数与扣费，批量输出按实际成功生成的张数计算。

## 模拟调用

以下报文为示意，不是真实账户返回；URL 与 Base64 已截断，数值不代表当前价格。

请求：

```json
{
  "model": "doubao-seedream-5-5-261028",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "size": "2K",
  "response_format": "url",
  "watermark": true
}
```

成功响应（同步）：

```json
{
  "created": 1763366400,
  "model": "doubao-seedream-5-5-261028",
  "data": [
    {
      "url": "https://example.com/generated-image.png",
      "size": "2048x2048",
      "output_format": "png"
    }
  ]
}
```

未生成图片时返回顶层 `error`；批量生成中单张失败时，失败项在 `data[].error` 中给出 `code` 与 `message`。

## 接入与会话

* **Base URL**：`https://ark.cn-beijing.volces.com/api/v3`。
* **鉴权**：`Authorization: Bearer $ARK_API_KEY`。密钥只放在请求头，不要写进提示词或源码。
* **与 OpenAI Images 的差异**：路径是 `/api/v3/images/generations`，不是 `/v1/images/generations`；没有 `quality` 参数；`size` 可以直接写 `1K`、`2K` 档位；返回 `data[].url` 或 `data[].b64_json`。
* **经本站网关调用**：请求地址改为 `https://api.dwchainless.com/v1/images/generations`，鉴权使用本站 Key；请求体是否原样透传、模型 ID 是否可用，以渠道和[模型与价格](https://api.dwchainless.com/zh/pricing/)为准。
* **超时**：同步生成可能持续数十秒，客户端超时应明显高于普通文本请求；超时后先查调用日志，确认是否已产生图片和费用，再决定是否重试。
* **批量与流式**：`sequential_image_generation` 和 `stream` 仅部分模型支持；同时开启时要按最终完成事件或完整 `data[]` 验收，中间结果不算完成图片。

## 官方参考

* [火山方舟图片生成 API](https\://docs.volcengine.com/docs/82379/1541523)
* [火山方舟 Base URL 及鉴权](https\://docs.volcengine.com/docs/ark/base-url-and-authentication)
* [Seedream 系列图片生成与编辑](https\://docs.volcengine.com/docs/lake-ai-service/image-generation-and-editing-doubao-seed-ream-series-models?lang=en)