# Jimeng / Volcengine Ark image generation

## Overview

Volcengine Ark's image generation interface uses the Seedream model family (`doubao-seedream-*`) to generate images from text or reference images. A request is submitted once and returns `data[]` synchronously; some models also support streaming or batch generation.

| What you want to do                              | Input                                  | Output          | Endpoint                                                           |
| ------------------------------------------------ | -------------------------------------- | --------------- | ------------------------------------------------------------------ |
| Generate an image from text                      | `prompt`                               | A new image     | `POST https://ark.cn-beijing.volces.com/api/v3/images/generations` |
| Generate from a reference image or edit an image | `prompt` + `image`                     | A new image     | The same endpoint                                                  |
| Batch-generate multiple images                   | `prompt` + batch generation parameters | Multiple images | The same endpoint                                                  |

## Core concepts

* **`size` has two forms**\: a resolution tier (such as `2K`) or explicit pixels (such as `2048x2048`). A tier is a model preset and does not equal fixed width and height; under the same tier, the actual dimensions depend on the model and the frame described in the prompt.
* **Reference images go in `image`**\: an HTTP(S) URL or `data:image/...;base64,...`. Passing an array means multi-image reference, and the count limit varies by model.
* **`watermark` is on by default**\: when `true`, an "AI generated" mark is added to the image; for output without a watermark, pass `false` explicitly and confirm that the use complies with applicable synthetic-content labeling requirements.
* **Synchronous response**\: ordinary requests wait directly for `data[]`. `stream` is available only for some models such as Seedream 5.0 lite, 4.5, and 4.0; you cannot turn other models into asynchronous tasks by adding a streaming parameter.
* **Billed per image**\: billing is tied to the number of generated images. Batch output from `sequential_image_generation` accumulates by the actual number of generated images, and failed items are returned separately in `data[].error`.

## Specifications and capabilities

| Model ID                          | `size` tiers and limits                                            | Reference images | Output format                                               |
| --------------------------------- | ------------------------------------------------------------------ | ---------------- | ----------------------------------------------------------- |
| `doubao-seedream-5-5-261028`      | `1K`, `1.5K`, `2K`, or `WxH`; pixels 921600–4624220, ratio 1/16–16 | Up to 10         | `url` / `b64_json`; `png` by default, `jpeg` also supported |
| `doubao-seedream-5-0-lite-260128` | `2K`, `3K`, `4K`, or `WxH`; pixels 3686400–16777216, ratio 1/16–16 | Up to 14         | `url` / `b64_json`; `png` / `jpeg`                          |
| `doubao-seedream-4-5-251128`      | `2K`, `4K`, or `WxH`; pixels 3686400–16777216, ratio 1/16–16       | Up to 14         | `url` / `b64_json`; `png` / `jpeg`                          |
| `doubao-seedream-4-0-250828`      | `1K`, `2K`, `4K`, or `WxH`; pixels 921600–16777216, ratio 1/16–16  | Up to 14         | `url` / `b64_json`; `png` / `jpeg`                          |

Pixel limits are calculated by total pixels; for example, 16777216 pixels corresponds to 4096×4096. Model IDs change with version updates, so before calling, check the Volcengine Ark model catalog and [Models and pricing](https://api.dwchainless.com/en/pricing/); `model` can also be an inference endpoint ID (`ep-...`).

## Call workflow

1. **Prepare the key**\: create an API key in the Volcengine Ark console and use `Authorization: Bearer $ARK_API_KEY` in the request header.
2. **Choose the model and size**\: confirm the `size` tiers or pixel range the model supports, and decide whether reference images are needed.
3. **Send a JSON request**\: submit to `/api/v3/images/generations` with `model` and `prompt`, adding `image`, `size`, `response_format`, and `watermark` as needed.
4. **Read `data[]`**\: when `response_format` is `url`, take `data[].url` (valid for 24 hours); when it is `b64_json`, decode `data[].b64_json`.
5. **Save and verify**\: check that the file opens and confirm actual dimensions and content; for batch generation, check `data[].error` item by item rather than looking only at the HTTP status.
6. **Check the cost**\: confirm the model, image count, and charge in the usage log; batch output is counted by the actual number of successfully generated images.

## Simulated call

The payloads below are illustrative, not real account responses; URLs and Base64 are truncated, and values do not represent current prices.

Request\:

```json
{
  "model": "doubao-seedream-5-5-261028",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "size": "2K",
  "response_format": "url",
  "watermark": true
}
```

Successful response (synchronous)\:

```json
{
  "created": 1763366400,
  "model": "doubao-seedream-5-5-261028",
  "data": [
    {
      "url": "https://example.com/generated-image.png",
      "size": "2048x2048",
      "output_format": "png"
    }
  ]
}
```

When no image is generated, a top-level `error` is returned; when a single image fails during batch generation, the failed item in `data[].error` gives `code` and `message`.

## Access and session

* **Base URL**\: `https://ark.cn-beijing.volces.com/api/v3`.
* **Authentication**\: `Authorization: Bearer $ARK_API_KEY`. Keep the key only in the request header; do not write it into prompts or source code.
* **Differences from OpenAI Images**\: the path is `/api/v3/images/generations`, not `/v1/images/generations`; there is no `quality` parameter; `size` can directly use tiers such as `1K` and `2K`; the response returns `data[].url` or `data[].b64_json`.
* **Calling through this site's gateway**\: change the request address to `https://api.dwchainless.com/v1/images/generations` and use this site's key for authentication; whether the request body passes through unchanged and whether the model ID is available follow the channel and [Models and pricing](https://api.dwchainless.com/en/pricing/).
* **Timeout**\: synchronous generation can take tens of seconds, so the client timeout should be clearly longer than for ordinary text requests; after a timeout, check the call log first to confirm whether an image and cost were produced, then decide whether to retry.
* **Batch and streaming**\: `sequential_image_generation` and `stream` are supported by only some models; when both are enabled, verify by the final completion event or the complete `data[]`, because intermediate results do not count as completed images.

## Official references

* [Volcengine Ark image generation API](https\://docs.volcengine.com/docs/82379/1541523)
* [Volcengine Ark Base URL and authentication](https\://docs.volcengine.com/docs/ark/base-url-and-authentication)
* [Seedream series image generation and editing](https\://docs.volcengine.com/docs/lake-ai-service/image-generation-and-editing-doubao-seed-ream-series-models?lang=en)