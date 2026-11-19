# PixVerse video

## Overview

PixVerse's official OpenAPI submits asynchronous generation tasks over ordinary HTTP requests. A successful creation returns `video_id`; use the same ID to query status and get the video URL. Text-to-video and image-to-video are separate entry points; image-to-video first uploads an image, then submits with the resulting `img_id`.

| What you want to do            | Input                                                               | Output                                   | Endpoint                                  |
| ------------------------------ | ------------------------------------------------------------------- | ---------------------------------------- | ----------------------------------------- |
| Generate a video from text     | Prompt, duration, `quality`, `aspect_ratio`                         | `video_id`                               | `POST /openapi/v2/video/text/generate`    |
| Generate a video from an image | The uploaded image's `img_id` (or template `img_ids`) plus a prompt | `video_id`                               | `POST /openapi/v2/video/img/generate`     |
| Query the task result          | `video_id`                                                          | Status, video URL, actual specifications | `GET /openapi/v2/video/result/{video_id}` |
| Upload an image                | Image file                                                          | `img_id`                                 | `POST /openapi/v2/image/upload`           |

## Core concepts

* **Task lifecycle**\: creation returns `ErrCode=0` and `video_id`, which only means the task was accepted. Query status `1` means complete, `5` generating, `7` content moderation failure, `8` generation failure; `1`, `7`, and `8` are all terminal.
* **The two IDs serve different purposes**\: `video_id` is the business task identifier used for querying and downloading; `Ai-trace-id` is a UUID that must be newly generated for every request. It is for tracing only and is not an idempotency key; reusing it may create another task.
* **Polling cadence**\: the vendor recommends querying every 3–5 seconds. Clients must set an overall wait limit; stop immediately once status reaches `7` or `8` and do not keep retrying the same task.
* **Billing unit**\: `Resp.credits` in the creation response is the credit cost of this task. The actual unit price, plan, and refund rules follow the vendor's pricing page and account bill.
* **Frame and duration are controlled separately**\: text-to-video uses `quality` for the sharpness tier and `aspect_ratio` for the frame; image-to-video has no `aspect_ratio` field, and the frame is determined by the input image or template. Valid `duration` values vary by model; do not fill only the interface's 1–15 range.

## Specifications and capabilities

| Metric           | Verified value                                                                                                                   |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Model ID         | `v6-max`, `c1`, `v6`, `v5.6`, `v5.5`, `v5`, `v5-fast`, `v4.5`, `v4`, `v3.5`; `v5-fast` requires account permission               |
| Resolution       | `quality`\: `360p`, `540p`, `720p`, `1080p`                                                                                      |
| Aspect ratio     | Text-to-video\: `16:9`, `9:16`, `4:3`, `3:4`, `1:1`, `2:3`, `3:2`, `21:9`; image-to-video\: no such field                        |
| Duration         | Interface range 1–15 seconds; C1 and V6 are 1–15 seconds, V5.5 and V5.6 are 5, 8, or 10 seconds, older models are 5 or 8 seconds |
| Audio            | `generate_audio_switch` boolean, default `false`; V5.5, V5.6, V6, and C1 support native audio                                    |
| Reference images | Image-to-video uploads first and gets `img_id`; template tasks use `img_ids` with `template_id`                                  |
| Billing metering | The creation response returns `Resp.credits`; the unit price follows the vendor's pricing page                                   |

Choose by model generation first, then by `quality` and `duration`. `quality` only sets the output pixel tier and does not change the frame; `aspect_ratio` only sets the shape, and the final pixels depend on both. Image-to-video has no `aspect_ratio` field, so do not copy the text-to-video request body; the frame follows the input image or template. `Resp.credits` in the creation response is good for budget records, but the actual charge and refund still follow the account bill.

## Call workflow

1. Create an API key on the PixVerse open platform. Requests use the `API-KEY` header; do not write it into prompts or the code repository.
2. For image-to-video, first call `POST /openapi/v2/image/upload` to upload the image and save `Resp.img_id` from the response; skip this step for text-to-video.
3. Submit JSON to the corresponding generation endpoint. Required fields are `model`, `prompt`, `duration`, and `quality`; text-to-video also needs `aspect_ratio`. Generate a new `Ai-trace-id` for each request.
4. Save `Resp.video_id` from the creation response. Do not treat `ErrCode=0` as meaning the video is already generated.
5. Call the query endpoint every 3–5 seconds. Download only when `status=1` and `Resp.url` is reachable; for `status=7`, fix the content before deciding whether to retry; for `status=8`, keep `Ai-trace-id` for troubleshooting.
6. Copy the video to your own storage. The access policy and lifetime of the result URL follow the vendor documentation; do not treat it as a permanent public address.

## Simulated call

The payloads below only illustrate the field structure. Task IDs, credits, and URLs are illustrative values, not real account data.

Creating a text-to-video task\:

```json
{
  "model": "v6-max",
  "prompt": "示例：海边日落，一艘白色帆船缓慢驶过，镜头平稳。",
  "duration": 5,
  "quality": "720p",
  "aspect_ratio": "16:9",
  "seed": 20260804,
  "generate_audio_switch": false
}
```

A successful creation returns only the task ID and consumed credits\:

```json
{
  "ErrCode": 0,
  "ErrMsg": "Success",
  "Resp": {
    "video_id": 900000000000001,
    "credits": 12
  }
}
```

Only `status=1` provides a downloadable address\:

```json
{
  "ErrCode": 0,
  "ErrMsg": "Success",
  "Resp": {
    "id": 900000000000001,
    "status": 1,
    "url": "https://example.com/demo-pixverse.mp4",
    "duration": 5,
    "quality": "720p",
    "aspect_ratio": "16:9",
    "outputWidth": 1280,
    "outputHeight": 720,
    "has_audio": false,
    "credits": 12
  }
}
```

When `status=5`, keep polling; on `status=7` or `status=8`, end immediately and record the failure reason from `ErrMsg`, `Error.Message`, and `Ai-trace-id`.

## Access and session

* **Base URL**\: `https://app-api.pixverse.ai`. Generation and queries both live under `/openapi/v2/`.
* **Auth headers**\: `API-KEY: PASTE_API_KEY_HERE`; `Content-Type: application/json`; add a new `Ai-trace-id` to every request.
* **Two addresses**\: direct access uses `https://app-api.pixverse.ai` with the `API-KEY` header; use `https://api.dwchainless.com` and `Authorization: Bearer` plus this site's key only when the channel explicitly confirms this gateway mapping; do not assume that replacing the address and authentication is sufficient. Whether a SimiRouter channel maps these paths or switches to a unified video protocol depends on the channel configuration; do not assume field compatibility just by changing the domain.
* **Timeout and idempotency**\: a creation timeout does not prove that the server did not accept the task. Query with the saved `video_id` first and retry only after confirming it does not exist; do not submit the same prompt repeatedly to "hurry it along".
* **Error detection**\: HTTP 200 may still carry a nonzero `ErrCode`. For business errors, read `ErrCode`, `ErrMsg`, and the optional `Error.Type` and `Error.Param`; do not look only at the HTTP status code.

## Official references

* [PixVerse Quick Start](https\://docs.platform.pixverse.ai/quick-start-2394985m0)
* [PixVerse text-to-video API](https\://docs.platform.pixverse.ai/text-to-video-generation-13016634e0)
* [PixVerse image-to-video API](https\://docs.platform.pixverse.ai/image-to-video-generation-13016633e0)
* [PixVerse query task status](https\://docs.platform.pixverse.ai/query-task-status-43051212e0)