# API reference

SimiRouter authenticates with API keys and routes model calls by model, group, and channel. Compatible and native vendor APIs can differ in address, authentication, and parameter structure. Do not mix them by only replacing a domain.

## Overview

Endpoints are organized in three layers\: choose the capability (text, images, video, audio, tools, model discovery), then the protocol (OpenAI-compatible, Gemini native, Claude Messages), and finally confirm parameters on the endpoint page. Three request shapes decide how the call is written\:

| Shape             | Characteristics                            | Typical endpoints                                  |
| ----------------- | ------------------------------------------ | -------------------------------------------------- |
| Synchronous       | One connection returns the complete result | Model lists, image generation, audio transcription |
| Streaming (SSE)   | One connection delivers incremental events | Chat, image understanding, tool calling            |
| Asynchronous task | Returns a task ID, then a status query     | Video generation, official fine-tuning             |

A client timeout or disconnect does not necessarily cancel upstream execution. Check task and usage records before resubmitting generation requests.

## Before integration

1. Follow [Create a SimiRouter key](/simidoc/en/apps/getting-started) to create a key.
2. Choose the exact model ID available to your account in the [model catalog](https://api.dwchainless.com/en/pricing/).
3. Confirm the address, request format, and model requirements on the endpoint page. SimiRouter’s root address is `https://api.dwchainless.com`; `/v1` or `/v1beta` is determined by the endpoint path.
4. Keep keys in environment variables or server-side secret storage. Real calls may incur charges; never expose keys in browser code or public repositories.

[API Script Integration](/simidoc/en/apps/api-script) provides a complete text request in Python, Node.js, curl, and Go.

## Service addresses

Before switching to a vendor API, check its endpoint path, authentication, model ID, and request fields. Reuse the request structure only when both services use the same protocol and the endpoint page confirms compatibility.

| Service                           | Address                                      | Authentication                                |
| --------------------------------- | -------------------------------------------- | --------------------------------------------- |
| SimiRouter gateway                | `https://api.dwchainless.com`                | `Authorization: Bearer` plus a SimiRouter key |
| Google Gemini API (AI Studio key) | `https://generativelanguage.googleapis.com`  | `x-goog-api-key`                              |
| Google Vertex AI                  | `https://{region}-aiplatform.googleapis.com` | OAuth access token                            |
| OpenAI                            | `https://api.openai.com`                     | `Authorization: Bearer` plus an OpenAI key    |
| Anthropic                         | `https://api.anthropic.com`                  | `x-api-key`                                   |
| xAI                               | `https://api.x.ai`                           | `Authorization: Bearer`                       |
| Volcengine Ark                    | `https://ark.cn-beijing.volces.com/api/v3`   | `Authorization: Bearer`                       |
| Alibaba Cloud DashScope           | `https://dashscope.aliyuncs.com`             | `Authorization: Bearer` plus a DashScope key  |

For local debugging, use `http://127.0.0.1:3001` as the gateway address. Vendor keys and SimiRouter keys are not interchangeable; when replacing the address, replace the authentication as well.

## Capability directory

| Capability                                         | Content                                                                                                                                      | Request mode                                                                                           |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [Chat](/simidoc/en/apps/api/chat)                                     | Chat Completions, Responses, Claude Messages, and Gemini content generation                                                                  | Non-streaming waits for a complete response; streaming receives SSE events incrementally               |
| [Images](/simidoc/en/apps/api/images)                                 | Image generation, editing, reference-image generation, and understanding, covering OpenAI, Gemini, Qwen, Jimeng, Grok, and FLUX protocols    | Image data, URLs, or text according to the protocol; streaming availability is endpoint-specific       |
| [Video](/simidoc/en/apps/api/video)                                   | Seedance, Kling, Veo, PixVerse, Wan, Happy Horse, and Grok Imagine generation protocols, and video understanding; Jimeng integration pending | Generation typically submits a task and queries its result; understanding uses multimodal content APIs |
| [Audio](/simidoc/en/apps/api/audio)                                   | OpenAI, Gemini, and MiMo audio input/output                                                                                                  | File requests, binary audio, or streaming events require different parsers                             |
| [Speech synthesis](/simidoc/en/apps/api/audio/speech)                 | Text to speech                                                                                                                               | Audio files or model-supported streaming events                                                        |
| [Speech transcription](/simidoc/en/apps/api/audio/transcriptions)     | Audio to text in its original language                                                                                                       | Upload audio and receive transcription                                                                 |
| [Audio translation](/simidoc/en/apps/api/audio/translations)          | Audio to English text                                                                                                                        | Upload audio and receive English text, not translated speech                                           |
| [Music (unsupported)](/simidoc/en/apps/api/music)                     | Official Google Lyria examples                                                                                                               | Official Google direct-access reference only                                                           |
| [Embeddings (unsupported)](/simidoc/en/apps/api/pending/embeddings)   | Official OpenAI and Gemini vector API references                                                                                             | Official vendor direct-access reference only                                                           |
| [Reranking](/simidoc/en/apps/api/pending/rerank)                      | Document relevance ranking                                                                                                                   | Use the vendor protocol documented on the page                                                         |
| [Realtime speech](/simidoc/en/apps/api/pending/realtime)              | OpenAI Realtime protocol                                                                                                                     | A bidirectional realtime connection, not a normal HTTP audio-file request                              |
| [Tools](/simidoc/en/apps/api/tools)                                   | Function calling and web search                                                                                                              | Execute requested tools by type and return their results to the model                                  |
| [Content moderation](/simidoc/en/apps/api/pending/moderations)        | Safety classification for text and images                                                                                                    | Category decisions and scores                                                                          |
| [List models](/simidoc/en/apps/api/models)                            | OpenAI- and Gemini-format model catalogs                                                                                                     | Model IDs and basic metadata. Listing does not confirm access to every capability.                     |
| [File understanding](/simidoc/en/apps/api/upload)                     | Pass file contents to a supported multimodal model                                                                                           | Different from the standalone Files API                                                                |
| [Fine-tuning (unsupported)](/simidoc/en/apps/api/pending/fine-tuning) | Official fine-tuning protocol reference                                                                                                      | Official OpenAI direct-access reference only                                                           |
| [Files API (unsupported)](/simidoc/en/apps/api/pending/files)         | Official file management reference                                                                                                           | Official OpenAI direct-access reference only                                                           |

## Reading endpoint documentation

Endpoint pages cover methods, parameters, response fields, code examples, errors, and official vendor references. Gateway examples use a SimiRouter key. Direct examples use the vendor’s own credentials. Features marked “unsupported” provide direct vendor references only.