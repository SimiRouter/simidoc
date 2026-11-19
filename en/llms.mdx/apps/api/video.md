# Video

Video capabilities comprise **generation** and **understanding**\: generation synthesizes new videos from text or references; understanding extracts summaries, events, and textual answers from existing videos. Their requests, latency, and outputs differ completely.

## Overview

| Capability          | Input                             | Output                          | Typical duration           |
| ------------------- | --------------------------------- | ------------------------------- | -------------------------- |
| Text to video       | Prompt                            | Video file or download URL      | Tens of seconds to minutes |
| Image to video      | First-frame image + prompt        | Video file                      | Tens of seconds to minutes |
| First/last frames   | First-frame and last-frame images | Video with both ends controlled | Several minutes            |
| Video understanding | Video + question                  | Text summary or answer          | Scales with video length   |

## Core concepts

* **Resolution**\: commonly 480p, 720p, and 1080p. It sets visual sharpness and directly affects generation time and price; drafts and previews often support only lower resolutions.
* **Aspect ratio**\: `16:9` landscape, `9:16` portrait, `1:1` square. Ratio and resolution together determine actual pixels, for example 1080p portrait is `1080x1920`.
* **Frame rate (fps)**\: frames per second, commonly 24 or 30. Raising it makes files larger and generation slower, without necessarily making motion look more natural.
* **Duration**\: seconds in a single clip, capped per model. Some models accept frame counts instead of a duration; when both are submitted, confirm in the interface reference which one wins.
* **Reference media**\: images serve as first frame, last frame, or style reference; support for reference video and audio varies widely by model and must not be assumed.
* **Task status**\: the ID returned at creation only means acceptance. Real success depends on the terminal state and a valid output URL from the query endpoint, and a state named `done` does not always mean success.

The available values and caps of these specifications depend on the model version; see each subpage's request parameter table, and do not apply one version's fields to another.

## Endpoint overview

| Capability                 | Mode                                       | Official protocol                                | Documentation                                     |
| -------------------------- | ------------------------------------------ | ------------------------------------------------ | ------------------------------------------------- |
| Seedance generation        | Asynchronous creation → polling → download | Volcengine Ark contents/generations/tasks        | [Seedance](/simidoc/en/apps/api/video/seedance)                            |
| Kling generation           | Asynchronous creation → polling/callback   | Kling 3.0 task protocol                          | [Kling](/simidoc/en/apps/api/video/kling)                                  |
| Jimeng generation          | Asynchronous submission → polling          | Volcengine Visual CVSync2Async, AK/SK signing    | [Jimeng (pending)](/simidoc/en/apps/api/video/jimeng)                      |
| Sora reference             | Official Videos API closed                 | Interface structure retained for reference only  | [Sora](/simidoc/en/apps/api/video/sora)                                    |
| Veo generation             | Asynchronous operation → polling           | Gemini API `predictLongRunning`                  | [Veo](/simidoc/en/apps/api/video/veo)                                      |
| PixVerse generation        | Asynchronous creation → polling            | PixVerse OpenAPI v2                              | [PixVerse](/simidoc/en/apps/api/video/pixverse)                            |
| DashScope video generation | Asynchronous creation → polling            | DashScope video-synthesis                        | [DashScope (Wan / HappyHorse)](/simidoc/en/apps/api/video/dashscope-video) |
| Grok Imagine generation    | Asynchronous creation → polling            | xAI `/v1/videos`                                 | [Grok Imagine](/simidoc/en/apps/api/video/grok-imagine)                    |
| Video understanding        | Multimodal request → text / SSE            | Dots, Kimi Chat Completions; Gemini Interactions | [Video understanding](/simidoc/en/apps/api/video/understanding)            |

## Request workflow

1. A task ID returned at creation means acceptance, not that the video has been generated.
2. Poll using the same vendor/channel’s task endpoint. Wait a few seconds between polls, impose an overall timeout, and stop on failure, expiration, or cancellation.
3. Download only after a successful terminal status and valid video output. Retain the original task ID, request ID, and failure reason rather than only recording “HTTP 200.”
4. Result URLs often expire; save results promptly. Download links are not permanent storage.

Video generation is usually not SSE, and status polling is not a realtime video stream. Audio, resolution, duration, first/last frames, and multiple references vary by model version; one version’s fields do not apply to all video models.

## Simulated call

The example below uses the Seedance protocol to show creation, acceptance, and polling. The content is illustrative; the address and authentication belong to direct Volcengine Ark access.

The creation request submits only a prompt and the video specifications\:

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

A successful creation returns only a task ID, not a video\:

```json
{"id":"cgt-example"}
```

The job is complete only when polling reaches a terminal state with a result URL\:

```json
{
  "id": "cgt-example",
  "status": "succeeded",
  "content": { "video_url": "https://example.com/video.mp4" },
  "error": null
}
```

While the status is `queued` or `running`, keep waiting; on `failed`, `expired`, or `cancelled`, stop polling immediately and keep the `error`. Video generation has no SSE increments, so results come only from polling or a callback.

## Vendor endpoints and SimiRouter

Each subpage follows the **vendor's official protocol** for fields and flow. Treat the request body, path, and status fields in the examples as vendor-direct references first; use the gateway address `https://api.dwchainless.com` and a SimiRouter key only where the page explicitly confirms a gateway mapping. Whether the gateway exposes a model with the same name, which path it uses, and how fields are mapped follow your account's model list and current channel configuration. Do not send a vendor request to the gateway by changing only the domain.

Vendor keys, Volcengine AK/SK, and SimiRouter keys are not interchangeable. If the channel has no explicit mapping, do not initiate paid generation by merely replacing the domain.

## Official references

* [Volcengine Ark\: create video generation task](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)
* [Volcengine Ark\: get video generation task](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)
* [Jimeng video generation API](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh)
* [Kling text-to-video](https\://kling.ai/document-api/apiReference/model/textToVideo)
* [OpenAI Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)