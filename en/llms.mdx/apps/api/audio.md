# Audio

Audio APIs convert text to speech, recordings to text, and analyze audio. Speech, music generation, and video soundtracks are different capabilities; do not mix models or endpoints.

## Overview

| What you want to do                            | Direction                  | Typical output                              | Billing unit                            |
| ---------------------------------------------- | -------------------------- | ------------------------------------------- | --------------------------------------- |
| Read text aloud, produce voice-over            | Text → speech              | Audio files such as MP3 and WAV             | Input characters or audio duration      |
| Turn a recording into text                     | Speech → text              | Original-language text, timestamps          | Seconds or minutes of audio             |
| Turn a foreign-language recording into English | Speech → English text      | English text, without the original language | Audio duration                          |
| Understand recording content                   | Speech → analysis text     | Summary, speakers, conclusions              | Tokens corresponding to the input audio |
| Hold a realtime conversation                   | Bidirectional audio stream | Continuous audio and events                 | Session duration or Tokens              |

## Core concepts

* **Sample rate**\: samples per second, commonly 16kHz (sufficient for speech recognition) and 24kHz or 44.1kHz (higher fidelity). A mismatched sample rate causes pitch shifts on playback or lower transcription quality.
* **Bit depth and channels**\: 16 bit mono is the common choice for speech; stereo and higher bit depths increase file size without the model necessarily using them.
* **Container and codec**\: MP3 is lossy and small; WAV is usually uncompressed and large; PCM is raw samples without a container, so playback needs the sampling specification supplied manually.
* **Duration and size**\: upload limits often constrain file size and duration together. Converting to a higher sample rate does not improve recognition accuracy, only makes limits easier to hit.
* **Synchronous vs. streaming**\: TTS returns audio bytes and ASR returns JSON. Streaming reduces time to the first word or first segment without changing the total billed amount.

Specification values (maximum duration, supported formats, sample-rate ranges) depend on the model; see each endpoint page's request parameter table.

## Endpoint overview

| Capability                 | Input → output                                  | Request mode                                                    | Documentation                                 |
| -------------------------- | ----------------------------------------------- | --------------------------------------------------------------- | --------------------------------------------- |
| Speech synthesis (TTS)     | Text → audio                                    | One HTTP request; some models support chunked audio or SSE      | [Text to speech](/simidoc/en/apps/api/audio/speech)                    |
| Speech recognition (ASR)   | Audio file → original-language text             | Multipart upload; some models support transcription SSE         | [Audio transcription](/simidoc/en/apps/api/audio/transcriptions)       |
| Speech translation         | Multilingual audio → English text               | One multipart request                                           | [Audio translation](/simidoc/en/apps/api/audio/translations)           |
| Gemini speech synthesis    | Text → single- or multi-speaker audio           | Native Interactions; supported older models use generateContent | [Gemini TTS](/simidoc/en/apps/api/audio/gemini)                        |
| Gemini audio understanding | Recording → summary, transcript, or analysis    | Native multimodal request                                       | [Audio understanding](/simidoc/en/apps/api/audio/gemini-understanding) |
| MiMo speech                | Text/reference voice → speech; recording → text | Independent compatibility routes or official Chat Completions   | [MiMo](/simidoc/en/apps/api/audio/mimo-audio)                          |
| Realtime speech            | Continuous input and output                     | WebRTC / bidirectional WebSocket                                | [Realtime](/simidoc/en/apps/api/pending/realtime)               |

## Synchronous, asynchronous, and streaming modes

* **Synchronous HTTP**\: one request returns audio or a complete transcript, without a task ID or polling.
* **HTTP streaming**\: one response delivers audio chunks or SSE events. It is not a bidirectional realtime session; do not JSON-parse binary audio.
* **Asynchronous task**\: receive an ID, then query status. Video generation commonly uses this flow; ordinary TTS/ASR does not.
* **Realtime**\: keep a session connected to send audio continuously, interrupt playback, and handle events. File upload is not a substitute.

## Simulated call

A speech synthesis request body is JSON, yet the response is audio bytes rather than JSON\:

```json
{
  "model": "gpt-4o-mini-tts",
  "voice": "alloy",
  "input": "欢迎使用 SimiRouter。",
  "response_format": "mp3"
}
```

The response headers decide how to save the file; write the body straight to `.mp3`\:

```text
HTTP/1.1 200 OK
Content-Type: audio/mpeg
Content-Length: 24576

<二进制音频数据>
```

Transcription uploads multipart and returns JSON\:

```json
{"text":"欢迎使用 SimiRouter。"}
```

Within the same audio category, synthesis returns binary and transcription returns JSON, so the parsers cannot be mixed. The example model `gpt-4o-mini-tts` is marked deprecated by the vendor; see [Text to speech](/simidoc/en/apps/api/audio/speech) for the replacement and migration path.

## Prerequisites

OpenAI-compatible pages use SimiRouter addresses and keys; native references use vendor addresses and keys. Account model lists and channel permissions determine availability. Do not assume every vendor capability is proxied. Obtain recording consent; voice cloning requires usage rights and disclosure of synthetic speech.

## Official references

* [OpenAI speech synthesis](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create)
* [OpenAI audio transcription](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create)
* [OpenAI audio translation](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create)
* [Google audio understanding](https\://ai.google.dev/gemini-api/docs/audio)
* [Google Gemini TTS](https\://ai.google.dev/gemini-api/docs/speech-generation)