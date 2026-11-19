# xAI Grok image generation

## Overview

xAI Grok's image generation interface follows the OpenAI Images path and response envelope, but its request parameters are xAI-native fields\: use `aspect_ratio` and `resolution` for the frame instead of `size`. It returns synchronously by default, and you can also enable `deferred` and poll the task.

| What you want to do                             | Input                       | Output                  | Endpoint                                              |
| ----------------------------------------------- | --------------------------- | ----------------------- | ----------------------------------------------------- |
| Generate an image from text                     | `prompt`                    | A new image             | `POST https://api.x.ai/v1/images/generations`         |
| Generate multiple images at once                | `prompt` + `n` (1–10)       | Multiple images         | The same endpoint                                     |
| Generate in the background and fetch the result | `prompt` + `deferred: true` | `request_id`, then poll | The same endpoint; poll `GET /v1/images/{request_id}` |
| Edit an existing image                          | `prompt` + image            | The edited image        | `POST https://api.x.ai/v1/images/edits`               |

## Core concepts

* **`aspect_ratio` replaces `size`**\: the interface does not accept OpenAI's `size` and `style`. The frame is controlled by `aspect_ratio`, with common values including `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `2:3`, `3:2`, `21:9`, and `auto`.
* **`resolution` controls the resolution tier**\: use `1k` or `2k`, defaulting to `1k`. It is a tier, not a pixel value; under the same tier, the actual width and height are determined by `aspect_ratio`.
* **`quality` applies only to the 2.0 model**\: options are `low`, `medium`, and `auto`; at generation time `auto` is currently treated as `low`, and at edit time as `medium`.
* **Synchronous by default, optional asynchronous with `deferred`**\: a synchronous request returns `data[]` directly; with `deferred: true` it returns `request_id` immediately, and you then poll `GET /v1/images/{request_id}`. Deferred tasks support only `response_format: "url"`, and results are retained for 24 hours.
* **URLs are temporary**\: when `response_format` is `url` (the default), the returned image address expires; download it promptly for long-term storage, or switch to `b64_json`.
* **Billed per image**\: `n` is the number of images generated per request, ranging from 1–10. The response's `usage.cost_in_usd_ticks` provides the cost information for that request; actual settlement follows this site's bill.

## Specifications and capabilities

| Model ID                 | Resolution tier | Aspect ratio                                                                                                               | Reference images                                                                           | Return format       |
| ------------------------ | --------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ------------------- |
| `grok-imagine-image-2.0` | `1k`, `2k`      | `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `2:1`, `1:2`, `19.5:9`, `9:19.5`, `20:9`, `9:20`, `21:9`, `5:2`, `auto` | The generation interface does not accept reference images; edit through `/v1/images/edits` | `url` or `b64_json` |

`grok-2-image` is a legacy model name; current official interface documentation uses `grok-imagine-image-2.0`. Before calling, confirm the model ID actually provided by this site's channel under [Models and pricing](https://api.dwchainless.com/en/pricing/), and do not simply copy names from older tutorials.

## Call workflow

1. **Prepare the key**\: create a key in the xAI console and use `Authorization: Bearer $XAI_API_KEY` in the request header.
2. **Confirm the model**\: check `grok-imagine-image-2.0` or the equivalent model provided by the channel under [Models and pricing](https://api.dwchainless.com/en/pricing/).
3. **Choose the frame**\: set `aspect_ratio` and `resolution`; do not send `size`.
4. **Send the request**\: submit JSON to `/v1/images/generations`. Add `deferred: true` when a long wait is expected.
5. **Read the result**\: for a synchronous response, take `data[].url` or `data[].b64_json`; for a deferred task, poll until `done`, then read `data[]`.
6. **Save and verify**\: download the image before the URL expires, check that the file opens, and confirm dimensions and content, then check the usage log.

## Simulated call

The payloads below are illustrative, not real account responses; URLs and cost values are truncated or only examples.

Synchronous request\:

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "response_format": "url"
}
```

Synchronous success response\:

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

Deferred task request\:

```json
{
  "model": "grok-imagine-image-2.0",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "n": 1,
  "aspect_ratio": "1:1",
  "resolution": "1k",
  "deferred": true
}
```

Illustrative response after submission\:

```json
{
  "request_id": "req_example_01"
}
```

Illustrative response after polling completes (HTTP 200; 202 while processing, and `error.code` and `error.message` on failure)\:

```json
{
  "data": [
    {
      "url": "https://imgen.x.ai/example/image.jpeg",
      "mime_type": "image/jpeg"
    }
  ],
  "usage": {
    "cost_in_usd_ticks": 40000
  }
}
```

## Access and session

* **Base URL**\: `https://api.x.ai/v1`. The generation endpoint is `/v1/images/generations`, and the edit endpoint is `/v1/images/edits`.
* **Authentication**\: `Authorization: Bearer $XAI_API_KEY`. The OpenAI SDK can reuse it by setting `base_url` to `https://api.x.ai/v1`, but request fields still follow the xAI documentation.
* **Differences from OpenAI**\: the path and `data[]` envelope are similar, but `size` and `style` are not supported; use `aspect_ratio`, `resolution`, and `quality` instead. The `n` limit is 10.
* **Deferred tasks**\: `deferred` supports only URL output; after submission, poll `GET /v1/images/{request_id}`; results are retained for 24 hours, and you must regenerate after expiry.
* **Calling through this site's gateway**\: change the request address to `https://api.dwchainless.com/v1/images/generations` and use this site's key for authentication; model ID and parameter passthrough follow the channel.
* **Timeout**\: synchronous generation usually completes within one request, but the client should still allow a sufficient timeout; for unpredictable latency or batch generation, prefer `deferred` and do not blindly resend after a timeout.

## Official references

* [xAI image generation capabilities](https\://docs.x.ai/developers/model-capabilities/images/generation)
* [xAI Images REST API reference](https\://docs.x.ai/developers/rest-api-reference/inference/images)