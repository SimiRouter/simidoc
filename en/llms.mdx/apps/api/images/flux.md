# BFL FLUX image generation

## Overview

The Black Forest Labs (BFL) FLUX API uses an asynchronous "submit a task, poll for the result" model. A submission request returns only a task ID and `polling_url`; once image generation completes, you read the signed URL from the polling result.

| What you want to do                     | Input                       | Output                      | Endpoint                                           |
| --------------------------------------- | --------------------------- | --------------------------- | -------------------------------------------------- |
| Generate an image from text             | `prompt`, `width`, `height` | Task `id` and `polling_url` | `POST https://api.bfl.ai/v1/flux-pro-1.1`          |
| Generate a wide image by ratio          | `prompt`, `aspect_ratio`    | Task `id` and `polling_url` | `POST https://api.bfl.ai/v1/flux-pro-1.1-ultra`    |
| Generate from a reference image or edit | `prompt` + `input_image`    | Task `id` and `polling_url` | `POST https://api.bfl.ai/v1/flux-2-pro` and others |
| Fetch the final image                   | `polling_url`               | `result.sample` signed URL  | `GET {polling_url}`                                |

## Core concepts

* **Dimensions use `width` / `height`**\: FLUX 1.1 pro supports width and height from 256–1440, and both must be multiples of 32. It is neither a resolution tier nor a `size` string.
* **Ultra uses `aspect_ratio`**\: `/v1/flux-pro-1.1-ultra` has no width or height fields and uses `aspect_ratio` instead (default `16:9`; the documentation describes a range from `21:9` to `9:21`).
* **`seed` controls reproducibility**\: the same prompt, parameters, and `seed` are used to compare different settings; it does not guarantee the same picture across models or versions.
* **`steps` / `guidance` appear only on some models**\: FLUX.2 flex supports `steps` (1–50) and `guidance` (1.5–10.0); FLUX 1.1 pro has neither field.
* **Submission and result are two requests**\: submission returns `id`, `polling_url`, and an optional `cost`; only after polling reaches `Ready` do you take the image from `result.sample`. Processing is `Pending`, and failure or content moderation returns the corresponding status.
* **Signed URLs last about 10 minutes**\: `result.sample` expires quickly, so download and copy it promptly; do not treat the address as a long-term public image link.

## Specifications and capabilities

| Endpoint                 | Size control                                                           | Reference images                                    | Other main fields                                                    | Return format                      |
| ------------------------ | ---------------------------------------------------------------------- | --------------------------------------------------- | -------------------------------------------------------------------- | ---------------------------------- |
| `/v1/flux-pro-1.1`       | `width`, `height`\: 256–1440, multiples of 32; default 1024×768        | `image_prompt` (Base64, Flux Redux style reference) | `seed`, `prompt_upsampling`, `safety_tolerance` 0–6, `output_format` | Take `result.sample` after polling |
| `/v1/flux-pro-1.1-ultra` | No `width` / `height`; uses `aspect_ratio`, default `16:9`             | `image_prompt`, `image_prompt_strength` 0.0–1.0     | `seed`, `prompt_upsampling`, `raw`, `safety_tolerance` 0–6           | Same as above                      |
| `/v1/flux-2-pro`         | `width`, `height`\: minimum 64; the documentation gives no upper limit | `input_image` through `input_image_8`, up to 8      | `seed`, `safety_tolerance` 0–7, `output_format`                      | Same as above                      |
| `/v1/flux-2-flex`        | `width`, `height`\: minimum 64; the documentation gives no upper limit | `input_image` through `input_image_8`, up to 8      | `steps` 1–50, `guidance` 1.5–10.0, `seed`, `output_format`           | Same as above                      |

`output_format` accepts `jpeg`, `png`, and `webp`, defaulting to `jpeg`. For endpoints whose upper limits are not listed in the table, follow the OpenAPI schema for that endpoint; do not apply one endpoint's width and height limits to another.

## Call workflow

1. **Prepare the key**\: create an API key in the BFL console and use `x-key: $BFL_API_KEY` in the request header, not `Authorization: Bearer`.
2. **Choose an endpoint**\: based on model capabilities, choose `/v1/flux-pro-1.1`, `/v1/flux-pro-1.1-ultra`, or another `/v1/flux-*` endpoint.
3. **Submit the task**\: send JSON with `prompt`, the size fields, `output_format`, and an optional `seed`.
4. **Save `polling_url`**\: read `id` and `polling_url` from the response; do not construct the polling address yourself.
5. **Poll until `Ready`**\: use the same `x-key` to request `polling_url`; keep waiting while `Pending`, and on `Error` or a moderation status, stop and record the reason.
6. **Download and verify**\: before the signed URL expires, download `result.sample`, check that the file opens, and confirm dimensions and content, then check `cost` and the usage log.

## Simulated call

The payloads below are illustrative, not real account responses; task IDs, URLs, and cost values only show the structure.

Submission request\:

```json
{
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "width": 1024,
  "height": 768,
  "seed": 42,
  "output_format": "jpeg",
  "safety_tolerance": 2
}
```

Successful submission response (asynchronous, no image generated yet)\:

```json
{
  "id": "task_example_01",
  "polling_url": "https://api.bfl.ai/v1/get_result?id=task_example_01",
  "cost": 0.04
}
```

Completed polling response (`status` is `Ready`)\:

```json
{
  "id": "task_example_01",
  "status": "Ready",
  "progress": 1,
  "result": {
    "sample": "https://delivery.example.bfl.ai/sample/image.jpeg"
  }
}
```

During polling you may also see statuses such as `Pending`, `Error`, `Request Moderated`, and `Content Moderated`. When moderation fails, `result` may be `null`, and the reason is in `details`.

## Access and session

* **Base URL**\: `https://api.bfl.ai`; `https://api.eu.bfl.ai` and `https://api.us.bfl.ai` are also available. Whichever entry you use, poll the same `polling_url` returned in the response.
* **Authentication**\: `x-key: $BFL_API_KEY`. This is the most obvious difference from OpenAI-style interfaces; do not put the key in an `Authorization` header.
* **Fully asynchronous**\: a submission request returns no image, only `id` and `polling_url`; you must send another `GET` to obtain the result.
* **Differences from OpenAI**\: there is no `/v1/images/generations` endpoint and no `size`, `quality`, or `n` fields; dimensions are controlled by `width` / `height` or `aspect_ratio`.
* **Callbacks instead of polling**\: a request can include `webhook_url` and `webhook_secret`, and BFL calls back on completion; with callbacks, still verify the signature and handle failure events.
* **Calling through this site's gateway**\: replace the address with `https://api.dwchainless.com` and use this site's key for authentication. FLUX is an asynchronous task, so whether the gateway passes through `polling_url` and the `x-key` header depends on the channel; if not enabled, connect directly using the official address above.
* **Calling through this site's gateway**\: the request address and authentication method follow this site's channel documentation; this page describes the native BFL protocol, so confirm model availability and parameter passthrough scope before connecting through the gateway.
* **Timeout**\: submission requests should return quickly; after a timeout, first query whether the task was created. Poll at intervals of about 0.5 seconds, set an overall wait limit according to the model and queue length, and do not retry indefinitely.

## Official references

* [BFL quick start\: text to image](https\://docs.bfl.ai/quick_start/generating_images)
* [BFL OpenAPI specification](https\://api.bfl.ai/openapi.json)
* [BFL API documentation full text](https\://docs.bfl.ai/llms-full.txt)