# 音频

音频 API 用于把文本变为语音、把录音转为文字，以及理解音频内容。语音、音乐生成和视频音轨是不同能力，不应混用模型和端点。

## 概览

| 你想做的事     | 方向        | 典型输出          | 计费单位          |
| --------- | --------- | ------------- | ------------- |
| 朗读文本、做配音  | 文本 → 语音   | MP3、WAV 等音频文件 | 输入字符数或音频时长    |
| 把录音转成文字   | 语音 → 文本   | 原语言文字、时间戳     | 音频秒数或分钟数      |
| 把外语录音转成英文 | 语音 → 英文文本 | 英文文字，不保留原语言   | 音频时长          |
| 理解录音内容    | 语音 → 分析文本 | 摘要、说话人、结论     | 输入音频对应的 Token |
| 与人实时对话    | 双向音频流     | 连续音频与事件       | 会话时长或 Token   |

## 核心概念

* **采样率**：每秒采样次数，常见 16kHz（语音识别够用）与 24kHz、44.1kHz（音质更高）。采样率不匹配会导致播放变调或转录质量下降。
* **位深与声道**：16 bit 单声道是语音场景的通用选择；立体声与更高位深会增加文件体积，模型未必利用。
* **容器与编码**：MP3 有损、体积小；WAV 通常无压缩、体积大；PCM 是没有容器的原始采样，播放时需要手动指定采样规格。
* **时长与大小**：上传限制常以文件大小和时长同时约束，转成高采样率不会提高识别准确率，只会更容易超限。
* **同步与流式**：TTS 返回音频字节，ASR 返回 JSON。流式降低首字或首段等待时间，不改变计费总量。

规格数值（最大时长、支持格式、采样率范围）由模型决定，逐项见各接口页的请求参数表。

## 接口说明

| 能力          | 输入 → 输出              | 请求方式                                     | 文档                              |
| ----------- | -------------------- | ---------------------------------------- | ------------------------------- |
| 语音合成（TTS）   | 文本 → 音频              | 单次 HTTP；部分模型可分块或 SSE                     | [文本转语音](/simidoc/zh/apps/api/audio/speech)               |
| 语音转录（ASR）   | 音频文件 → 原语言文字         | multipart 上传；部分模型支持转录 SSE                | [音频转录](/simidoc/zh/apps/api/audio/transcriptions)        |
| 语音翻译        | 多语言音频文件 → 英文文字       | multipart 单次请求                           | [音频翻译](/simidoc/zh/apps/api/audio/translations)          |
| Gemini 语音合成 | 文本 → 单人/多人音频         | 原生 Interactions，支持的旧模型另用 generateContent | [Gemini TTS](/simidoc/zh/apps/api/audio/gemini)          |
| Gemini 音频理解 | 录音 → 摘要、转录、分析文字      | 原生多模态请求                                  | [音频理解](/simidoc/zh/apps/api/audio/gemini-understanding)  |
| MiMo 语音     | 文本/参考声音 → 语音；录音 → 文字 | 独立兼容路由或官方 Chat Completions               | [MiMo](/simidoc/zh/apps/api/audio/mimo-audio)            |
| 实时语音        | 持续输入与输出              | WebRTC / 双向 WebSocket                    | [Realtime](/simidoc/zh/apps/api/pending/realtime) |

## 同步、异步与流式的区别

* **同步 HTTP**：一条请求返回音频文件或完整转录，没有任务 ID 和轮询步骤。
* **HTTP 流式**：同一响应逐块返回音频或 SSE 事件，不等于双向实时会话。不要对二进制流调用 JSON 解析。
* **异步任务**：先得到任务 ID，再查询状态；视频生成通常采用此方式，普通 TTS/ASR 不是这种流程。
* **Realtime**：会话保持连接，客户端可持续送入音频、打断播放并处理事件，不能用文件上传代替。

## 模拟调用

语音合成的请求体是 JSON，响应却是音频字节而不是 JSON：

```json
{
  "model": "gpt-4o-mini-tts",
  "voice": "alloy",
  "input": "欢迎使用 SimiRouter。",
  "response_format": "mp3"
}
```

返回的头部决定如何保存文件，正文直接写入 `.mp3`：

```text
HTTP/1.1 200 OK
Content-Type: audio/mpeg
Content-Length: 24576

<二进制音频数据>
```

转录走 multipart 上传，返回 JSON：

```json
{"text":"欢迎使用 SimiRouter。"}
```

同一个“音频”分类里，合成返回二进制、转录返回 JSON，解析器不能混用。示例模型 `gpt-4o-mini-tts` 已被厂商标记弃用，替代模型与迁移方式见[语音合成](/simidoc/zh/apps/api/audio/speech)。

## 使用前提

OpenAI 兼容页使用 SimiRouter 地址与 SimiRouter Key；厂商原生参考使用厂商地址与对应 Key。模型是否可用由账户模型列表和渠道权限决定，不能把厂商所有能力视为网关已全部提供。上传录音前应取得必要授权；克隆声音需拥有声音使用权并向听众披露合成语音。

## 官方参考

* [OpenAI 语音合成](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create)
* [OpenAI 语音转录](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create)
* [OpenAI 语音翻译](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create)
* [Google 音频理解](https\://ai.google.dev/gemini-api/docs/audio)
* [Google Gemini TTS](https\://ai.google.dev/gemini-api/docs/speech-generation)