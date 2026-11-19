# 视频理解

视频理解将已有视频作为输入，返回摘要、画面描述、事件顺序或问题答案；它不是根据提示词生成新视频。Dots、Kimi 和 Gemini 均提供视频输入能力，采用的内容格式、文件引用方式和鉴权不同。

## 厂商与协议

| 文档                      | 官方示例模型             | 视频输入                                       | 请求与响应                                                    |
| ----------------------- | ------------------ | ------------------------------------------ | -------------------------------------------------------- |
| [Dots 视频理解](/simidoc/zh/apps/api/video/understanding/dots)     | `dots3-note-prev`  | 模型服务可访问的 `video_url.url`                   | Chat Completions 消息数组；最终文字位于 `choices[].message.content` |
| [Kimi 视频理解](/simidoc/zh/apps/api/video/understanding/kimi)     | `kimi-k3`          | Base64 视频 data URL，或 Moonshot `ms://` 文件引用 | Chat Completions 消息数组；最终文字位于 `choices[].message.content` |
| [Gemini 视频理解](/simidoc/zh/apps/api/video/understanding/gemini) | `gemini-3.8-flash` | 内联视频数据或 Google 支持的文件 URI                   | 本文采用 Interactions；文字位于 `steps[].content[]`               |

Dots 视频请求使用官方 `api-key` 请求头；Kimi 使用 Bearer；Gemini 使用 `x-goog-api-key`。Dots 和 Kimi 的 `video_url` 是厂商支持的多模态扩展，不是所有 OpenAI 兼容服务都支持的视频通用标准。不能仅因路径同为 `/v1/chat/completions` 就互换视频载荷。

## 同步、流式与文件引用

* **非流式**：一次 HTTP 请求等待完整文字响应，不返回视频生成任务 ID。
* **流式**：以 SSE 增量返回文字；首个事件前可能仍需下载、解码和分析视频。流式不代表持续上传摄像头，也不保证立即返回首字。
* **文件引用**：先上传到厂商存储，再在分析请求中引用。上传完成不等于已完成分析，各厂商的文件 ID 不互通。
* **并行请求**：由客户端发起多个独立请求，每个请求单独计算限流、上下文和用量，不是正文中的某个“并行”参数。

## 输入准备

使用有权处理的视频。公开视频直链、平台分享页、本地路径和 Base64 数据是不同输入，必须按对应协议传入。小红书或其他网站的分享页面不等同于可下载的视频文件 URL；需要登录或防盗链的视频也不一定能由模型服务读取。

视频长度、分辨率、采样帧数和文件大小会影响耗时、Token 与费用；具体限制见厂商页面。时间点与事件判断应对照原视频复核，不作为精确逐帧取证或强制对齐结果。

## SimiRouter 接入

上述子页提供厂商官方直连示例，使用厂商 Key。通过 SimiRouter 调用时，须确认账户可用的完整模型 ID、渠道的视频输入映射及文件引用支持；不能把模型官方支持直接写成本站已联调通过。厂商 Key 与 SimiRouter Key 不通用。

## 官方参考

* [Dots：视频输入](https\://dots.ai/platform/docs#video-input)
* [Kimi K3 快速开始](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart)与[视觉模型](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Google：视频理解](https\://ai.google.dev/gemini-api/docs/video-understanding)