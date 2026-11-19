# 音乐（不支持）

本节整理 Google Lyria 的公开生成协议。SimiRouter 尚未开放音乐能力，以下示例均按 Google AI Studio Gemini API 直连，使用 `https://generativelanguage.googleapis.com` 与 Google API Key。Vertex AI 需要独立协议，本页未验证，不要直接替换地址调用。

## 概览

| 能力     | 输入           | 产物              | 本节性质   |
| ------ | ------------ | --------------- | ------ |
| 生成音乐片段 | 文本描述或图片      | 约 30 秒音频，默认 MP3 | 官方接口参考 |
| 生成完整歌曲 | 含主歌、副歌描述的提示  | 数分钟歌曲，可带歌词与曲式   | 官方接口参考 |
| 实时演奏   | 持续下发的提示与播放控制 | 连续 PCM 音频块      | 官方接口参考 |

## 核心概念

* **片段与歌曲**：片段固定 30 秒，适合试听与循环；歌曲由提示词控制长度和结构，时长不是精确保证。
* **实时会话**：双向 WebSocket，连接期间持续下发提示和 PLAY、PAUSE 控制，不是把一次性请求改成 stream 开关。
* **音频格式**：默认 MP3，可请求 WAV；实时接口返回原始 PCM 块，需应用自行缓冲并封装。
* **Key 与地址**：本页示例只使用 Google AI Studio Gemini API 的地址与 Google API Key；SimiRouter 尚未代理音乐模型，Vertex AI 的独立协议也未在本页验证。

时长上限、采样率与码率由模型决定，逐项见 [Lyria](/simidoc/zh/apps/api/music/lyria) 与 [RealTime](/simidoc/zh/apps/api/music/realtime) 的参数表。

## 接口说明

| 模式      | 官方协议                        | 能力             | 文档                           |
| ------- | --------------------------- | -------------- | ---------------------------- |
| 一次性音乐生成 | `POST /v1beta/interactions` | 文本或图片生成片段/完整歌曲 | [Lyria 音乐生成](/simidoc/zh/apps/api/music/lyria)        |
| 实时音乐    | 双向 WebSocket                | 持续产生并动态调整器乐音频  | [Lyria RealTime](/simidoc/zh/apps/api/music/realtime) |

Lyria Clip 生成 30 秒片段；Lyria 3.5 面向较完整歌曲。RealTime 是实验能力，使用持久连接，不是 Interactions 的 stream 开关。音乐模型不负责普通文字朗读，需要 TTS 时使用 [音频](/simidoc/zh/apps/api/audio)。

## 模拟调用

Google 官方一次性生成使用 Interactions，请求描述曲风与结构：

```json
{
  "model": "lyria-3-clip-preview",
  "input": "温暖的钢琴与弦乐，节奏舒缓，适合纪录片开场"
}
```

响应里的音频是 Base64，不是下载地址：

```json
{
  "steps": [
    {
      "type": "model_output",
      "content": [
        { "type": "text", "text": "[Instrumental]" },
        { "type": "audio", "data": "<Base64音频>" }
      ]
    }
  ]
}
```

音频与文字项可能交错出现，必须遍历 `content[]` 按 `type` 取用；只取最后一项会漏掉歌词或曲式说明。

## 鉴权与权利

Google 官方 Interactions 使用 `x-goog-api-key: $GEMINI_API_KEY`，实时连接使用官方 SDK 或其 WebSocket 协议。生成内容仍须遵守 Google 使用条款、著作权与声音授权要求。模型供应、地域和配额由 Google 账户决定。

## 官方参考

[Google 音乐生成](https\://ai.google.dev/gemini-api/docs/music-generation)、[实时音乐](https\://ai.google.dev/gemini-api/docs/realtime-music-generation)。