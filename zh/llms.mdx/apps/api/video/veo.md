# Veo 视频（Gemini API 预览模型已停用）

## 概览

Veo 通过 Gemini API 的 long-running operation 生成视频：先调用 `predictLongRunning` 启动任务，拿到 operation 名称，再轮询该 operation，完成后从响应中的文件 URI 下载 MP4。

**Gemini API 上的 `veo-3.1-generate-preview`、`veo-3.1-fast-generate-preview` 等预览模型已于 2026-10-22 停用。** 本页保留协议结构，供理解已有调用和迁移参考；现在不能把这个端点当作可用的生产接口。可迁移到 `gemini-omni-1.2-flash`，或使用 Gemini Enterprise Agent Platform 上的 GA 模型。

| 你要做的事  | 输入            | 输出           | 端点                                                  |
| ------ | ------------- | ------------ | --------------------------------------------------- |
| 启动视频生成 | 提示词、首帧、尾帧或参考图 | operation 名称 | `POST /v1beta/models/{MODEL_ID}:predictLongRunning` |
| 查询操作   | operation 名称  | `done`、结果或错误 | `GET /v1beta/{operation_name}`                      |
| 下载视频   | 结果中的文件 URI    | MP4 字节       | `GET {video.uri}`                                   |

## 核心概念

* **操作（operation）不是任务 ID**：创建响应返回 `name`，例如 `models/veo-3.1-generate-preview/operations/...`。轮询、读取结果和排错都使用这个完整名称。
* **完成条件是 `done: true`**：`done: false` 只表示仍在处理。`done: true` 时还要检查是否存在 `error`，以及 `response.generateVideoResponse.generatedSamples[0].video.uri` 是否为空。
* **耗时范围**：官方给出的生成耗时为最少 11 秒，峰值最长 6 分钟。轮询可用 10–15 秒间隔，并设置客户端总等待上限。
* **时长与分辨率联动**：时长只有 4、6、8 秒三档。使用 1080p、4k、参考图或视频延长时，时长必须为 8 秒；不能把 4 秒请求直接改成 1080p。
* **音频随模型生成**：Gemini API 文档把音频描述为始终开启，没有单独的 `generateAudio` 开关。提示词可以写对白、音效和环境声。
* **计费按平台区分**：Gemini API 与 Agent Platform 是两套计费与配额体系，单价以厂商计价页为准。预览模型停用后，不应再产生新的调用费用。

## 规格与能力

| 指标    | Gemini API 预览模型                                                                                                                                                                 | Agent Platform GA 模型                                                                         |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| 模型 ID | `veo-3.1-generate-preview`、`veo-3.1-fast-generate-preview`、`veo-3.1-lite-generate-preview`；`veo-3.0-generate-001`、`veo-3.0-fast-generate-001`。Gemini API 文档把这些 ID 标为 Deprecated | `veo-3.1-generate-001`、`veo-3.1-fast-generate-001`（GA）；`veo-3.1-lite-generate-001` 为 Preview |
| 分辨率   | 默认 `720p`；`1080p` 与 `4k` 仅限 8 秒                                                                                                                                                 | 标准模型输出 `720p`、`1080p`、`4K`；Fast 模型输出 `720p`、`1080p`                                          |
| 宽高比   | `16:9`、`9:16`                                                                                                                                                                   | `16:9`、`9:16`                                                                                |
| 时长    | `4`、`6`、`8` 秒                                                                                                                                                                   | `4`、`6`、`8` 秒；参考图模式仅 8 秒                                                                     |
| 音频    | 原生生成，始终开启                                                                                                                                                                       | 能力表列出声音生成                                                                                    |
| 参考素材  | `image` 首帧、`lastFrame` 尾帧、最多 3 张 `referenceImages`                                                                                                                              | 资产参考图、首尾帧                                                                                    |
| 视频延长  | 每次增加 7 秒，最多 20 次；输入最长 141 秒，输出最长 148 秒；仅 720p                                                                                                                                   | 支持延长能力，参数以平台文档为准                                                                             |

分辨率和时长不是独立选项：1080p、4k、参考图和延长都要求 8 秒；4 秒或 6 秒只能配 720p。参考图最多 3 张，首帧与尾帧是画面约束，不是风格参考。音频始终生成，不能通过参数关闭。迁移到 Agent Platform 后，模型 ID、认证和配额都换了一套，不能把本文端点直接换成 GA 模型名继续使用。

## 调用流程

1. 确认平台与凭据。Gemini API 使用 `x-goog-api-key`；Agent Platform 使用平台自身的认证方式，两者不能互换。
2. 向 `POST /v1beta/models/{MODEL_ID}:predictLongRunning` 提交 `instances` 与 `parameters`。提示词放在 `instances[0].prompt`，首帧放在 `instances[0].image`。
3. 保存响应中的 `name`。创建成功只代表操作已建立，不代表视频可下载。
4. 轮询 `GET /v1beta/{operation_name}`，直到 `done: true`。若存在 `error`，按错误内容结束，不要继续等待。
5. 从 `response.generateVideoResponse.generatedSamples[0].video.uri` 读取下载地址，携带 API Key 请求该 URI，并允许 HTTP 重定向。
6. 把文件转存到自己的存储。官方文档说明生成视频保留 2 天，延长引用会重置计时；不要依赖长期有效的厂商 URL。

## 模拟调用

以下为归档示意，用来说明原 Gemini API 的报文结构。预览模型已于 2026-10-22 停用，当前不会据此产生新任务；operation 名称与 URL 均为示意值。

启动请求：

```json
{
  "instances": [
    {
      "prompt": "示例：海边日落，镜头缓慢推进。"
    }
  ],
  "parameters": {
    "aspectRatio": "16:9",
    "resolution": "720p",
    "numberOfVideos": 1,
    "durationSeconds": 8,
    "personGeneration": "allow_all"
  }
}
```

创建响应只有操作名称：

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": false
}
```

完成后的操作响应：

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": true,
  "response": {
    "generateVideoResponse": {
      "generatedSamples": [
        {
          "video": {
            "uri": "https://example.com/demo-veo.mp4"
          }
        }
      ]
    }
  }
}
```

`done: true` 但没有 `generatedSamples` 或 URI 为空时，按失败处理并保留 operation 名称。

## 接入与会话

* **基础地址**：`https://generativelanguage.googleapis.com/v1beta`。
* **鉴权头**：`x-goog-api-key: PASTE_API_KEY_HERE`，同时发送 `Content-Type: application/json`。
* **两套地址**：直连 Gemini API 用 `https://generativelanguage.googleapis.com/v1beta`，鉴权头为 `x-goog-api-key`；仅当渠道明确确认映射到本站网关时，才使用 `https://api.dwchainless.com` 和 `Authorization: Bearer` 加本站 Key；不能仅替换地址和鉴权。SimiRouter 若提供同名模型，路径、字段和轮询方式由渠道映射决定。Agent Platform 的 GA 模型使用 `https://{region}-aiplatform.googleapis.com` 这类区域地址与项目认证，既不是 `generativelanguage` 地址，也不是模型字符串替换。
* **超时与幂等**：启动请求超时后，先检查是否已创建 operation；保存 `name` 比保存 HTTP 状态更重要。不要因为等待时间长而重复启动相同任务。
* **迁移提示**：`gemini-omni-1.2-flash` 的接口形态与 `predictLongRunning` 不同，现有轮询代码可能必须重写。迁移前以官方迁移文档和账户可用模型列表为准。

## 官方参考

* [Gemini API：Veo 视频生成](https\://aistudio.google.com/docs/veo)
* [Veo 3.1 预览模型停用说明](https\://aistudio.google.com/docs/models/veo-3.1-generate-preview)
* [Gemini Enterprise Agent Platform：Veo 3.1](https\://docs.cloud.google.com/gemini-enterprise-agent-platform/models/veo/3-1-generate)