# 视频

视频分为**生成**与**理解**：生成从文本/参考素材合成新视频；理解从现有视频提取摘要、事件和文字答案。二者请求、耗时与输出完全不同。

## 概览

| 能力    | 输入         | 输出        | 耗时量级    |
| ----- | ---------- | --------- | ------- |
| 文生视频  | 提示词        | 视频文件或下载地址 | 数十秒到数分钟 |
| 图生视频  | 首帧图片 + 提示词 | 视频文件      | 数十秒到数分钟 |
| 首尾帧控制 | 首帧、尾帧图片    | 两端受控的视频   | 数分钟     |
| 视频理解  | 视频 + 问题    | 文字摘要或答案   | 与视频时长相关 |

## 核心概念

* **分辨率**：常见 480p、720p、1080p。它决定画面清晰度，也直接影响生成耗时与价格；草稿或预览通常只支持较低分辨率。
* **宽高比**：`16:9` 横屏、`9:16` 竖屏、`1:1` 方形。比例与分辨率共同决定实际像素，例如 1080p 竖屏是 `1080x1920`。
* **帧率（fps）**：每秒帧数，常见 24 或 30。提高帧率会让文件更大、生成更慢，不必然让动作更自然。
* **时长**：单段视频的秒数，按模型设上限。部分模型支持用帧数代替时长，同时提交时二者谁优先要按接口说明确认。
* **参考素材**：图片用于首帧、尾帧或风格参考；参考视频与音频支持情况随模型差异很大，不能默认存在。
* **任务状态**：创建返回的 ID 只代表受理。真正的成功要看查询接口的终态和有效输出地址，`done` 一类状态不总是等于成功。

这些规格的可用值与上限由模型版本决定，逐项见各子页请求参数表；不要把一个版本的字段套给另一个版本。

## 接口说明

| 能力              | 模式                | 官方协议                                           | 文档                                               |
| --------------- | ----------------- | ---------------------------------------------- | ------------------------------------------------ |
| Seedance 生成     | 异步创建 → 查询 → 下载    | 火山方舟 contents/generations/tasks                | [Seedance](/simidoc/zh/apps/api/video/seedance)                           |
| Kling 生成        | 异步创建 → 查询/回调      | Kling 3.0 新任务协议                                | [Kling](/simidoc/zh/apps/api/video/kling)                                 |
| 即梦生成            | 异步提交 → 查询         | 火山视觉 CVSync2Async，AK/SK 签名                     | [即梦（待接入）](/simidoc/zh/apps/api/video/jimeng)                              |
| Sora 参考         | 官方 Videos API 已关闭 | 仅保留接口结构参考                                      | [Sora](/simidoc/zh/apps/api/video/sora)                                   |
| Veo 生成          | 异步 operation → 轮询 | Gemini API `predictLongRunning`                | [Veo](/simidoc/zh/apps/api/video/veo)                                     |
| PixVerse 生成     | 异步创建 → 查询         | PixVerse OpenAPI v2                            | [PixVerse](/simidoc/zh/apps/api/video/pixverse)                           |
| DashScope 视频生成  | 异步创建 → 查询         | DashScope video-synthesis                      | [DashScope（Wan / HappyHorse）](/simidoc/zh/apps/api/video/dashscope-video) |
| Grok Imagine 生成 | 异步创建 → 查询         | xAI `/v1/videos`                               | [Grok Imagine](/simidoc/zh/apps/api/video/grok-imagine)                   |
| 视频理解            | 多模态请求 → 文字 / SSE  | Dots、Kimi Chat Completions；Gemini Interactions | [视频理解](/simidoc/zh/apps/api/video/understanding)                          |

## 请求流程

1. 创建请求返回任务 ID，仅表示受理，不表示视频已生成。
2. 使用同一厂商/渠道的任务查询接口；建议间隔数秒并设置总等待上限，失败、过期或取消立即结束。
3. 只有成功终态且存在有效视频输出时才下载。保存原始任务 ID、请求 ID 和失败原因，避免只记“HTTP 200”。
4. 结果 URL 常有有效期，应及时转存。下载链接不能当永久存储地址。

视频生成通常不是 SSE；轮询状态不是实时视频流。音频、分辨率、时长、首尾帧及多参考能力按模型版本区分，不能把某一版本字段套给所有视频模型。

## 模拟调用

以下以 Seedance 协议为例，展示创建、受理和查询三个阶段；内容为示意，地址与鉴权属于火山方舟官方直连。

创建请求只提交提示词和视频规格：

```json
{
  "model": "doubao-seedance-2-5-260628",
  "content": [
    { "type": "text", "text": "海边日落，镜头缓慢推进" }
  ],
  "resolution": "720p",
  "ratio": "16:9",
  "duration": 5
}
```

创建成功只返回任务 ID，不是视频：

```json
{"id":"cgt-example"}
```

查询到终态且有结果地址才算完成：

```json
{
  "id": "cgt-example",
  "status": "succeeded",
  "content": { "video_url": "https://example.com/video.mp4" },
  "error": null
}
```

状态为 `queued` 或 `running` 时继续等待；`failed`、`expired`、`cancelled` 立即停止轮询并保存 `error`。视频生成没有 SSE 增量，结果只能通过轮询或回调取得。

## 厂商地址与 SimiRouter

各子页按**厂商官方协议**整理字段与流程。示例中的请求体、路径和状态字段先以厂商官方文档为准；只有页面明确标注已映射到 SimiRouter 时，才可以使用网关地址 `https://api.dwchainless.com` 与本站 Key。网关是否支持同名模型、使用哪条路径以及字段如何映射，以账户模型清单与当前渠道配置为准，不能把官方请求仅替换域名后直接发送到网关。

厂商 Key、火山 AK/SK 和本站 Key 不互通。渠道没有明确映射时，不要只替换域名就发起付费生成。

## 官方参考

* [火山方舟：创建视频生成任务](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)
* [火山方舟：查询视频生成任务](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)
* [即梦视频生成接口](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh)
* [Kling 文生视频](https\://kling.ai/document-api/apiReference/model/textToVideo)
* [OpenAI Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)