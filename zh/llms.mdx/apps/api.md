# API 参考

SimiRouter 使用 API Key 验证请求，并根据模型、分组和渠道转发模型调用。兼容接口与厂商原生接口可能采用不同的地址、鉴权方式和参数结构，不能只替换域名后混用。

## 概览

接口按三层组织：先选能力（文本、图片、视频、音频、工具、模型发现），再选协议（OpenAI 兼容、Gemini 原生、Claude Messages），最后在接口页核对参数。三种调用形态决定请求怎么写：

| 形态      | 特征               | 典型接口           |
| ------- | ---------------- | -------------- |
| 同步      | 同一连接返回完整结果       | 模型列表、图片生成、音频转录 |
| 流式（SSE） | 同一连接分批返回事件       | 聊天、图片理解、工具调用   |
| 异步任务    | 先返回任务 ID，再查询任务状态 | 视频生成、官方微调      |

客户端超时或断开连接不一定意味着上游任务已取消，生成类请求应先核对任务和使用记录，避免重复提交。

## 接入准备

1. 按[注册 SimiRouter Key](/simidoc/zh/apps/getting-started)创建密钥。
2. 从[模型广场](https://api.dwchainless.com/zh/pricing/)选择账户可用的完整模型 ID。
3. 在具体接口页确认服务地址、请求格式和模型要求。SimiRouter 的 API 根地址为 `https://api.dwchainless.com`；`/v1` 或 `/v1beta` 由接口路径决定。
4. 将密钥保存在环境变量或服务端密钥存储中。真实请求可能产生费用，不要在浏览器前端或公开代码中暴露密钥。

[API 脚本接入](/simidoc/zh/apps/api-script)提供一次完整文本请求的 Python、Node.js、curl 和 Go 示例。

## 服务地址

切换到厂商直连前，请核对接口路径、鉴权、模型 ID 和请求字段。只有两端使用同一协议且接口页明确说明兼容时，才可以沿用请求结构。

| 服务                              | 地址                                           | 鉴权                                      |
| ------------------------------- | -------------------------------------------- | --------------------------------------- |
| SimiRouter 网关                   | `https://api.dwchainless.com`                | `Authorization: Bearer` 加本站 Key         |
| Google Gemini API（AI Studio 密钥） | `https://generativelanguage.googleapis.com`  | `x-goog-api-key`                        |
| Google Vertex AI                | `https://{region}-aiplatform.googleapis.com` | OAuth 访问令牌                              |
| OpenAI                          | `https://api.openai.com`                     | `Authorization: Bearer` 加 OpenAI Key    |
| Anthropic                       | `https://api.anthropic.com`                  | `x-api-key`                             |
| xAI                             | `https://api.x.ai`                           | `Authorization: Bearer`                 |
| 火山方舟                            | `https://ark.cn-beijing.volces.com/api/v3`   | `Authorization: Bearer`                 |
| 阿里云 DashScope                   | `https://dashscope.aliyuncs.com`             | `Authorization: Bearer` 加 DashScope Key |

本地调试时网关地址用 `http://127.0.0.1:3001`。厂商密钥与本站 Key 不互通，替换地址时要一并替换鉴权。

## 功能目录

| 功能                                | 内容                                                                       | 调用方式                            |
| --------------------------------- | ------------------------------------------------------------------------ | ------------------------------- |
| [聊天](/simidoc/zh/apps/api/chat)                      | Chat Completions、Responses、Claude Messages、Gemini 内容生成                   | 非流式请求等待完整响应；流式请求逐步接收 SSE 事件     |
| [画图](/simidoc/zh/apps/api/images)                    | 图片生成、编辑、参考图生成和图片识别，覆盖 OpenAI、Gemini、Qwen、即梦、Grok、FLUX 协议                 | 按协议返回图片数据、地址或文本；支持流式与否见具体接口     |
| [视频](/simidoc/zh/apps/api/video)                     | Seedance、Kling、Veo、PixVerse、Wan、Happy Horse、Grok Imagine 生成协议与视频理解；即梦待接入 | 视频生成通常先提交任务，再查询结果；视频理解使用多模态内容接口 |
| [音频](/simidoc/zh/apps/api/audio)                     | OpenAI、Gemini 和 MiMo 的音频输入输出                                             | 文件请求、二进制音频或流式事件，不能混用响应解析器       |
| [语音合成](/simidoc/zh/apps/api/audio/speech)            | 文字转语音                                                                    | 返回音频文件或模型支持的流式事件                |
| [语音转录](/simidoc/zh/apps/api/audio/transcriptions)    | 音频转原语言文字                                                                 | 上传音频后返回转录结果                     |
| [音频翻译](/simidoc/zh/apps/api/audio/translations)      | 音频转英文文字                                                                  | 上传音频后返回英文文本，不是语音翻译输出            |
| [音乐（不支持）](/simidoc/zh/apps/api/music)                | Google Lyria 官方调用参考                                                      | 仅提供 Google 官方直连参考               |
| [嵌入（不支持）](/simidoc/zh/apps/api/pending/embeddings)   | OpenAI、Gemini 官方向量接口参考                                                   | 仅提供厂商官方直连参考                     |
| [重排序](/simidoc/zh/apps/api/pending/rerank)           | 文档相关性排序                                                                  | 按页面列出的厂商协议调用                    |
| [实时语音](/simidoc/zh/apps/api/pending/realtime)        | OpenAI Realtime 协议                                                       | 双向实时连接，不是普通 HTTP 音频文件请求         |
| [工具](/simidoc/zh/apps/api/tools)                     | Function Calling、网络搜索                                                    | 模型提出工具调用后，按工具类型执行并回传结果          |
| [内容审核](/simidoc/zh/apps/api/pending/moderations)     | 文本与图片安全分类                                                                | 返回类别判定和评分                       |
| [获取模型](/simidoc/zh/apps/api/models)                  | OpenAI 和 Gemini 格式模型列表                                                   | 返回模型标识；列表不等于每项能力均已开放            |
| [文件识别](/simidoc/zh/apps/api/upload)                  | 将文件内容传入支持的多模态模型                                                          | 与独立的 Files API 不同               |
| [微调（不支持）](/simidoc/zh/apps/api/pending/fine-tuning)  | 官方微调协议参考                                                                 | 仅提供 OpenAI 官方直连参考               |
| [Files API（不支持）](/simidoc/zh/apps/api/pending/files) | 官方文件管理协议参考                                                               | 仅提供 OpenAI 官方直连参考               |

## 阅读接口说明

接口页列出请求方法、参数、返回字段、代码示例、错误码和厂商官方参考。网关示例使用 SimiRouter Key，官方直连示例使用厂商密钥。标注“不支持”的功能仅提供厂商直连参考。