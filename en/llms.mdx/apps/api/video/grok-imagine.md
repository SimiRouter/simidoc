# Grok Imagine video

## Overview

Grok Imagine uses xAI's asynchronous video API\: submit a task with `POST /v1/videos/generations` and get a `request_id`, then poll with `GET /v1/videos/{request_id}`. A text prompt generates a video directly; supplying `image` enters image-to-video, and supplying reference images or keyframes enters reference-to-video.

| What you want to do | Input                                           | Output                   | Endpoint                      |
| ------------------- | ----------------------------------------------- | ------------------------ | ----------------------------- |
| Text-to-video       | `prompt`, duration, frame, resolution           | `request_id`             | `POST /v1/videos/generations` |
| Image-to-video      | `image` plus an optional `prompt`               | `request_id`             | The same endpoint             |
| Reference-to-video  | `prompt` plus `reference_images` or `keyframes` | `request_id`             | The same endpoint             |
| Query the task      | `request_id`                                    | Status, video URL, usage | `GET /v1/videos/{request_id}` |

## Core concepts

* **Task lifecycle**\: query status has only `pending`, `done`, and `failed`. While `pending`, `progress` is 0–99; it is 100 when `done`, and may be omitted when `failed`.
* **`request_id` is the polling identifier**\: it is not an idempotency key. After a submission timeout, do not conclude that the task was not created just because no response arrived; save and query the possible `request_id` first.
* **Polling cadence**\: the official documentation does not specify a fixed interval. Clients can use 5–10 seconds and set an overall wait limit; stop immediately after `failed`.
* **Duration and frame**\: `duration` ranges from 1–15 seconds, defaulting to 8 seconds; image-to-video ignores `aspect_ratio`, and the frame follows the input image. `resolution` defaults to `480p`, and `grok-imagine-video-1.5` supports native 1080p.
* **Audio switch**\: the capability page lists `generate_audio`, default `true`; set it to `false` to request silence. The REST reference does not list the field separately, so actual availability depends on what the interface returns.
* **Billing unit**\: `usage.cost_in_usd_ticks` in the query response is the cost counter for this task. The exact conversion, unit price, and failed-task settlement follow the vendor's pricing page.

## Specifications and capabilities

| Metric           | Verified value                                                                                                |
| ---------------- | ------------------------------------------------------------------------------------------------------------- |
| Model ID         | `grok-imagine-video-1.5`, `grok-imagine-video-1.5-lite`, `grok-imagine-video`                                 |
| Resolution       | `480p` (default), `720p`, `1080p`; `grok-imagine-video-1.5` offers native 1080p                               |
| Aspect ratio     | `1:1`, `16:9` (default), `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `21:9`, `5:2`; image-to-video ignores this field |
| Duration         | 1–15 seconds, default 8 seconds; editing an existing video does not accept a custom duration                  |
| Audio            | `generate_audio` defaults to `true`; `false` requests silence; follow the capability page description         |
| Reference media  | `image` first frame, `reference_images` reference images, `keyframes` up to 4, `last_frame` last frame (1.5)  |
| Image input      | Public URL, Base64 data URI, or a `file_id` from the xAI Files API; JPEG, PNG, WebP                           |
| Billing metering | `usage.cost_in_usd_ticks`; the unit price follows the vendor's pricing page                                   |

The default `480p` suits previews, while `720p` and `1080p` increase generation time and cost. Image-to-video ignores `aspect_ratio`, and the frame is determined by `image`; to control landscape or portrait, handle it while preparing the input image. `duration` defaults to 8 seconds, and actual elapsed time also depends on queuing, so do not estimate from duration alone. `generate_audio` is described on the capability page but not listed separately in the REST reference; before integrating, verify with a short request whether the current model accepts the field.

## Call workflow

1. Create an API key in the xAI console; subsequent requests use `Authorization: Bearer`.
2. Choose the generation mode\: sending only `prompt` is text-to-video; adding `image` is image-to-video; adding `reference_images`, `keyframes`, or `last_frame` is reference-to-video.
3. Call `POST https://api.x.ai/v1/videos/generations`, setting `duration`, `aspect_ratio`, `resolution`, and the audio switch for the target model.
4. Save the `request_id` from the response. A successful creation only means the task was accepted.
5. Poll `GET https://api.x.ai/v1/videos/{request_id}` until `status` is `done` or `failed`.
6. After `done`, download `video.url`; to write into your own object storage, you can also use `output.upload_url` or `storage_options` in the request. On `failed`, read `error.code` and `error.message`.

## Simulated call

The payloads below are illustrative; `request_id`, URLs, and usage are not real account data.

Creation request\:

```json
{
  "model": "grok-imagine-video-1.5",
  "prompt": "示例：夜晚的霓虹街道，镜头缓慢前推。",
  "duration": 6,
  "aspect_ratio": "16:9",
  "resolution": "720p",
  "generate_audio": true
}
```

A successful creation returns the polling identifier\:

```json
{
  "request_id": "demo-request-0001"
}
```

Polling reaches the success terminal state\:

```json
{
  "status": "done",
  "progress": 100,
  "model": "grok-imagine-video-1.5",
  "video": {
    "url": "https://example.com/demo-grok-imagine.mp4",
    "duration": 6,
    "respect_moderation": true
  }
}
```

While `pending`, keep polling; on `failed`, stop and read `error`. When `video.respect_moderation` is `false`, the URL may be empty and must not be treated as a playable result.

## Access and session

* **Base URL**\: `https://api.x.ai`. Generation, query, editing, and extension use `/v1/videos/generations`, `/v1/videos/{request_id}`, `/v1/videos/edits`, and `/v1/videos/extensions` respectively.
* **Auth header**\: `Authorization: Bearer PASTE_API_KEY_HERE`, with a JSON request body.
* **Two addresses**\: direct access uses `https://api.x.ai`; use `https://api.dwchainless.com` and `Authorization: Bearer` plus this site's key only when the channel explicitly confirms this gateway mapping; do not assume that replacing the address and authentication is sufficient. Whether a SimiRouter channel exposes `/v1/videos/*` and preserves `request_id` and the status fields depends on the channel mapping.
* **Timeout and idempotency**\: there is no public idempotency key. After a submission timeout, query the known `request_id` first and retry only after confirming the task does not exist; do not submit the same prompt concurrently to avoid the wait.
* **Saving results**\: `video.url` is a temporary address, and the documentation also provides file-output and expiration fields. The product side should download or copy it first, then serve a long-term link.

## Official references

* [xAI\: Grok Imagine video generation](https\://docs.x.ai/developers/model-capabilities/video/generation)
* [xAI\: video REST API reference](https\://docs.x.ai/developers/rest-api-reference/inference/videos)
* [xAI\: image-to-video](https\://docs.x.ai/developers/model-capabilities/video/image-to-video)