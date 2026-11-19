# OpenAI 音频格式

## 接口说明

OpenAI 音频格式包含三个独立 HTTP 端点，均使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。

| 端点                              | 内容类型                | 返回值              | 文档                       |
| ------------------------------- | ------------------- | ---------------- | ------------------------ |
| `POST /v1/audio/speech`         | JSON                | 音频字节；模型支持时可用 SSE | [语音合成](/simidoc/zh/apps/api/audio/speech)         |
| `POST /v1/audio/transcriptions` | multipart/form-data | 转录 JSON、文字或字幕    | [语音转录](/simidoc/zh/apps/api/audio/transcriptions) |
| `POST /v1/audio/translations`   | multipart/form-data | 英文翻译文字或字幕        | [语音翻译](/simidoc/zh/apps/api/audio/translations)   |

请求 `model` 必须是账户可用的音频模型。TTS 的 `voice`、转录输出格式、时间戳和流式能力按具体模型区分，不能相互替换。文件转录不提供持续麦克风会话；此场景参考 [Realtime](/simidoc/zh/apps/api/pending/realtime)。

本文为 OpenAI API 格式参考，模型生命周期和厂商参数以各端点的官方 API Reference 为准。网关 Key 与 OpenAI 官方 Key 不可混用。