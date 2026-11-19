# DashScope video generation (Wan / HappyHorse)

## Overview

Wan and HappyHorse are both video generation model families on the Alibaba Cloud Model Studio platform, and they share the same DashScope asynchronous protocol\: the submission endpoint, the `X-DashScope-Async` header, the task query path, the status strings, and the result fields are all identical. They differ in only three places — model ID, input structure, and aspect parameters.

| What you want to do                                  | Input                                                                  | Output                     | Endpoint                                                      |
| ---------------------------------------------------- | ---------------------------------------------------------------------- | -------------------------- | ------------------------------------------------------------- |
| Text to video (Wan)                                  | Prompt, `parameters.size`, `duration`                                  | `task_id`                  | `POST /api/v1/services/aigc/video-generation/video-synthesis` |
| First-frame image to video (Wan)                     | Prompt, `input.img_url`, `parameters.resolution`                       | `task_id`                  | Same submission endpoint                                      |
| Text to video (HappyHorse)                           | Prompt, `resolution`, `ratio`, `duration`                              | `task_id`                  | Same submission endpoint                                      |
| First-frame or reference image to video (HappyHorse) | `input.media` containing `first_frame` or 1–9 `reference_image` images | `task_id`                  | Same submission endpoint                                      |
| Query a task                                         | `task_id`                                                              | `task_status`, `video_url` | `GET /api/v1/tasks/{task_id}`                                 |

## Core concepts

* **Task lifecycle**\: `PENDING → RUNNING → SUCCEEDED`, with `FAILED` as the failed terminal state, plus `CANCELED` and `UNKNOWN`. Only `SUCCEEDED` reads `output.video_url`.
* **Two IDs have different roles**\: `output.task_id` is used to query the task; `request_id` only traces a single HTTP request. Keep both when troubleshooting.
* **Polling rhythm**\: the official recommendation is to query every 15 seconds. Task IDs and result URLs are both valid for 24 hours; after expiry, a query returns `UNKNOWN`.
* **Input structure differs by model family**\: Wan image-to-video uses `input.img_url`; HappyHorse uses the `input.media` array, whose elements carry `type` (`first_frame` or `reference_image`) and `url`. The two structures are not interchangeable.
* **Aspect parameters differ by model family**\: Wan text-to-video uses `parameters.size` (`宽*高`, for example `1280*720`), and Wan image-to-video uses `parameters.resolution` (`480P`, `720P`, `1080P`); HappyHorse text-to-video and reference-image-to-video use `parameters.ratio` (for example `16:9`), while first-frame image-to-video follows the first-frame image.
* **Audio only on some Wan generations**\: Wan2.6 and Wan2.5 generate music or sound effects that match the picture by default, and you can also supply WAV or MP3 through `input.audio_url`; Wan2.2 and Wan2.1 output silent video by default. The HappyHorse documentation has no audio input or output parameters.
* **Billing is measured in output seconds**\: `usage.duration` in the query response is the output video duration. Unit prices, settlement of failed tasks, and refund rules follow the vendor's pricing page and billing.

## Specifications and capabilities

Wan values\:

| Metric                | Verified values                                                                                                                                                                                                                           |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Text-to-video models  | `wan2.6-t2v`, `wan2.5-t2v-preview`, `wan2.2-t2v-plus`, `wan2.1-t2v-turbo`, `wan2.1-t2v-plus`                                                                                                                                              |
| Image-to-video models | `wan2.6-i2v`, `wan2.6-i2v-flash`, `wan2.5-i2v-preview`, `wan2.2-i2v-plus`, `wan2.2-i2v-flash`, `wan2.1-i2v-turbo`, `wan2.1-i2v-plus`                                                                                                      |
| Resolution            | Text-to-video `size`\: `832*480`, `480*832`, `624*624`, `1280*720`, `720*1280`, `960*960`, `1088*832`, `832*1088`, `1920*1080`, `1080*1920`, `1440*1440`, `1632*1248`, `1248*1632`; image-to-video `resolution`\: `480P`, `720P`, `1080P` |
| Duration              | `wan2.6-t2v` is 2–15 seconds; `wan2.5-t2v-preview` is 5 or 10 seconds; `wan2.2` and `wan2.1` text-to-video is fixed at 5 seconds; `wan2.1-i2v-turbo` supports 3, 4, or 5 seconds                                                          |
| Audio                 | Wan2.6 and Wan2.5 automatically generate music or sound effects; `audio_url` supports WAV and MP3, 3–30 seconds, up to 15 MB; Wan2.2 and Wan2.1 are silent by default                                                                     |
| Reference media       | Image-to-video uses `input.img_url`, supporting a public URL or Base64; image width and height are 240–8000 pixels, up to 20 MB for Wan2.6/2.5                                                                                            |

HappyHorse values\:

| Metric           | Verified values                                                                                                                                                                                                       |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Model IDs        | `happyhorse-1.1-t2v`, `happyhorse-1.0-t2v`, `happyhorse-1.1-i2v`, `happyhorse-1.1-r2v`                                                                                                                                |
| Resolution       | `480P`, `720P`, `1080P`, default `1080P`                                                                                                                                                                              |
| Aspect ratio     | Text-to-video and reference-image-to-video\: `16:9` (default), `9:16`, `1:1`, `4:3`, `3:4`, `4:5`, `5:4`, `9:21`, `21:9`; image-to-video follows the first frame and allows 1\:2.5 to 2.5\:1                          |
| Duration         | 3–15 seconds, default 5 seconds; this range is explicit in the `happyhorse-1.0-t2v`, image-to-video, and reference-image-to-video documentation, while the `happyhorse-1.1-t2v` documentation does not state a range  |
| Reference images | Image-to-video takes 1 first frame with a shortest side of at least 300 pixels; reference-image-to-video takes 1–9 images with a shortest side of at least 400 pixels; up to 20 MB each; formats JPEG, JPG, PNG, WEBP |
| Other parameters | `watermark` defaults to `true`, and when enabled shows HappyHorse in the bottom-right corner; `seed` ranges from 0 to 2147483647                                                                                      |

Wan's `size` is concrete pixels and `resolution` is a tier; the two serve different endpoints\: 1080P portrait text-to-video must be written as `1080*1920`, not `1080P`; image-to-video is the reverse and accepts only `480P`, `720P`, `1080P`. HappyHorse first-frame image-to-video does not read `ratio`; the output ratio is determined by the image. Wan2.2 and Wan2.1 text-to-video are fixed at 5 seconds, and a longer `duration` will not produce a longer clip. Wan2.6 and Wan2.5 always generate an audio track; when downstream does not need audio, remove it in post, or first confirm whether that model offers a disable parameter. When the number of reference images is 1–9, `[Image N]` in the prompt must match the order of `media`; a wrong order references the wrong image.

## Call workflow

1. Create an API key in Alibaba Cloud Model Studio. The model, request address, and key must belong to the same region; cross-region calls fail.
2. Choose the model family and mode\: Wan text-to-video/image-to-video, or HappyHorse text-to-video/first-frame image-to-video/reference-image-to-video. The input structures differ, and the same request body cannot be reused.
3. Submit JSON to `POST /api/v1/services/aigc/video-generation/video-synthesis` with `Authorization: Bearer`, `Content-Type: application/json`, and `X-DashScope-Async: enable`.
4. Save `output.task_id` and `request_id`. A creation response of `PENDING` only means queueing succeeded.
5. Call `GET /api/v1/tasks/{task_id}` every 15 seconds. After `SUCCEEDED`, read `output.video_url`; on `FAILED`, read `output.code` and `output.message`.
6. Download and copy the video within 24 hours. After the task expires, it can no longer be queried, and the result URL can no longer be relied on.

## Simulated call

The following payloads are illustrative; the task IDs, request IDs, URLs, and usage are not real account data.

Wan text-to-video creation request\:

```json
{
  "model": "wan2.5-t2v-preview",
  "input": {
    "prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "parameters": {
    "size": "1280*720",
    "duration": 5,
    "prompt_extend": true,
    "watermark": false,
    "seed": 20260804
  }
}
```

HappyHorse first-frame image-to-video creation request\:

```json
{
  "model": "happyhorse-1.1-i2v",
  "input": {
    "prompt": "示例：让画面中的帆船缓慢向前移动。",
    "media": [
      {
        "type": "first_frame",
        "url": "https://example.com/demo-first-frame.png"
      }
    ]
  },
  "parameters": {
    "resolution": "720P",
    "duration": 5,
    "watermark": false,
    "seed": 20260804
  }
}
```

Creation success responses for both model families have the same structure and return only the queueing status\:

```json
{
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "PENDING"
  },
  "request_id": "demo-request-0001"
}
```

A query that reaches the successful terminal state\:

```json
{
  "request_id": "demo-request-0001",
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "SUCCEEDED",
    "video_url": "https://example.com/demo-video.mp4",
    "orig_prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "usage": {
    "duration": 5,
    "output_video_duration": 5,
    "video_count": 1,
    "SR": 720
  }
}
```

`PENDING` and `RUNNING` mean keep waiting; on `FAILED` or `CANCELED`, stop immediately and save `output.code` and `output.message`; for `UNKNOWN`, first confirm whether the task has exceeded 24 hours.

## Access and session

* **Base address**\: `https://{WorkspaceId}.{region}.maas.aliyuncs.com`. Singapore, the United States, Beijing, Frankfurt, and Tokyo use different regional hosts, with the same submission and query paths.
* **Authentication header**\: `Authorization: Bearer PASTE_API_KEY_HERE`; creating a task requires `X-DashScope-Async: enable`, and a missing header returns a synchronous-call error.
* **Two sets of addresses**\: direct access uses `https://{WorkspaceId}.{region}.maas.aliyuncs.com`; use `https://api.dwchainless.com` and `Authorization: Bearer` plus a key from this site only when the channel explicitly confirms this gateway mapping; do not assume that replacing the address and authentication is sufficient. If a SimiRouter channel performs a unified wrapper, `task_id`, status strings, and result fields may be rewritten; follow the channel documentation.
* **Timeouts and idempotency**\: after a submission timeout, first save and query the `task_id` that may already have been created; do not resubmit immediately. Polling requests themselves can be retried, but set an overall wait limit.
* **Result storage**\: `video_url` is a time-limited download address. For long-term use, download and then transcode or copy it; do not write the vendor URL directly into a product database as a permanent asset.

## Official references

* [Wan text-to-video API reference](https\://www.alibabacloud.com/help/en/model-studio/legacy-wan-text-to-video-api-reference)
* [Wan image-to-video API reference](https\://www.alibabacloud.com/help/en/model-studio/image-to-video-api-reference)
* [Wan2.5 image-to-video model description](https\://www.alibabacloud.com/help/en/model-studio/wan2-5-i2v)
* [HappyHorse text-to-video API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-text-to-video-api-reference)
* [HappyHorse first-frame image-to-video API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-image-to-video-api-reference)
* [HappyHorse reference-image-to-video API](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-reference-to-video-api-reference)