# Images

Choose the **API protocol**, decide on the **effect**, and then check the **dimensions, quality, format, and image count**. The protocol defines request and response structures, the model and prompt determine the effect, and specifications define the output requirements. These are separate decisions.

Generation and editing return images; image understanding takes images and returns text or structured results. A text-only model does not gain image-generation capabilities when image parameters are added. Before calling, check the exact model ID, supported interfaces, billing group, and quota under [Models and pricing](https://api.dwchainless.com/en/pricing/). Real requests may incur charges.

## Overview

| What you want to do                   | Input                                    | Output                       | Typical endpoint              |
| ------------------------------------- | ---------------------------------------- | ---------------------------- | ----------------------------- |
| Generate an image from text           | Prompt                                   | A new image                  | `POST /v1/images/generations` |
| Modify an existing image              | Prompt plus one or more reference images | The edited image             | `POST /v1/images/edits`       |
| Generate images inside a conversation | Chat messages plus the image tool        | Mixed image and text results | `POST /v1/responses`          |
| Have the model describe an image      | Image plus a question                    | Text, not a new image        | `POST /v1/chat/completions`   |

## Core concepts

Three kinds of numbers come first; the parameters and prices below only make sense once they are separated\:

* **Pixel dimensions**\: the real width × height, such as `1024x1024`. It sets the actual resolution of the file, not the file size, and it is not a quality tier.
* **Aspect ratio**\: ratios such as `1:1`, `16:9`, and `9:16` only determine the shape of the frame. One ratio can map to several pixel dimensions; naming a ratio does not specify the output size.
* **Resolution tier**\: tiers such as `1K`, `2K`, and `4K`. Vendor-native tiers are defined by longest edge or product line, while this site's per-image billing tiers are classified by longest edge; the names match but the boundaries may not, so neither can be inferred from the other.

There are also three common misconceptions\: `quality` controls rendering quality, not compression quality; PNG, JPEG, and WebP are file formats, and renaming an extension does not convert one to another; Base64 and URL are delivery methods, not resolutions. See section 4 below, "Image specifications and billing", for the itemized comparison.

## 1. APIs\: choose a protocol

Each of the three protocols has its own request parameters, response fields, and examples. Script calls, agent use, saving results, and failure handling are also explained within each protocol, so you do not need to start with a shared tutorial that only applies to OpenAI.

| Protocol                | API / capability                                          | Request endpoint                                        | Main result                                                  | Documentation                                             |
| ----------------------- | --------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------ | --------------------------------------------------------- |
| OpenAI                  | Text-to-image                                             | `POST /v1/images/generations`                           | `data[].b64_json`; compatible models may also return URLs    | [Generation](/simidoc/en/apps/api/images/openai/generations)                        |
| OpenAI                  | Image editing / image-to-image                            | `POST /v1/images/edits`                                 | Edited images                                                | [Editing](/simidoc/en/apps/api/images/openai/edits)                                 |
| OpenAI                  | Conversational image generation                           | `POST /v1/responses`, using the `image_generation` tool | Image tool results in `output[]`                             | [Conversational generation](/simidoc/en/apps/api/images/openai/chat-format)         |
| OpenAI                  | Image understanding                                       | `POST /v1/chat/completions`, with `image_url` input     | Text analysis, not generated images                          | [Image understanding](/simidoc/en/apps/api/images/openai/vision)                    |
| Gemini                  | Text-to-image                                             | `POST /v1beta/models/{model}:generateContent`           | `candidates[].content.parts[].inlineData`                    | [Generation](/simidoc/en/apps/api/images/gemini/generate)                           |
| Gemini                  | Image editing / multi-turn editing                        | Same endpoint, with mixed text and image input          | Images in the returned content parts                         | [Editing](/simidoc/en/apps/api/images/gemini/edits)                                 |
| Gemini                  | Image understanding                                       | Same endpoint, using a model with vision input          | Text analysis                                                | [Media understanding](/simidoc/en/apps/api/chat/gemini-media)               |
| Qwen                    | Text-to-image / image editing                             | `POST /v1/images/generations`, `POST /v1/images/edits`  | `data[].url` or `data[].b64_json`                            | [Generation](/simidoc/en/apps/api/images/qwen/generations), [Editing](/simidoc/en/apps/api/images/qwen/edits) |
| Jimeng / Volcengine Ark | Text-to-image / reference-image generation                | `POST /api/v3/images/generations`                       | `data[].url` or `data[].b64_json`                            | [Generation](/simidoc/en/apps/api/images/jimeng)                                    |
| xAI Grok                | Text-to-image / multiple images                           | `POST /v1/images/generations`                           | `data[].url` or `data[].b64_json`                            | [Generation](/simidoc/en/apps/api/images/grok)                                      |
| BFL FLUX                | Text-to-image / reference-image generation (asynchronous) | `POST /v1/flux-pro-1.1` and others                      | Take `polling_url` first, then `result.sample` when complete | [Generation](/simidoc/en/apps/api/images/flux)                                      |

**The Qwen section uses the native Qwen request body, called through this site's gateway `/v1/images/generations` and `/v1/images/edits`, and returns the uniform `data[]`.** Do not rewrite the request body into OpenAI's `prompt` field; model IDs must use the names actually provided by this site's channel. Jimeng uses the native Volcengine Ark request body; Grok uses the same paths as OpenAI Images, but its frame parameters are `aspect_ratio` and `resolution`; FLUX does not generate images synchronously and must submit a task and then poll `polling_url`. These three cannot copy each other's fields.

Call modes also vary by protocol\: ordinary OpenAI Images requests wait for complete results, and only supported models offer image event streams; Gemini streams through `streamGenerateContent?alt=sse`; the Qwen and Jimeng examples in this directory use synchronous responses; Grok is synchronous by default and can use `deferred` to become a deferred task; FLUX is always asynchronous polling. None becomes a universal task queue simply by adding an “asynchronous” parameter. See [OpenAI](/simidoc/en/apps/api/images/openai), [Gemini](/simidoc/en/apps/api/images/gemini), [Qwen](/simidoc/en/apps/api/images/qwen), [Jimeng](/simidoc/en/apps/api/images/jimeng), [Grok](/simidoc/en/apps/api/images/grok), and [FLUX](/simidoc/en/apps/api/images/flux) for requests, outputs, and completion checks.

## 2. Effects\: choose by your goal

“Watercolor,” “replace the background,” and “product composition” are usually generation or editing tasks, not separate APIs. The following categories describe tasks, not capabilities guaranteed across all models. Check the relevant protocol and model documentation first.

| Desired effect                                                              | Input and prompt focus                                                                        | Interface choice and limitations                                                                                           |
| --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Create from scratch\: illustrations, covers, posters, photorealistic scenes | Describe the subject, composition, style, lighting, and text to render                        | Use text-to-image; check text and details                                                                                  |
| Reference-image variations\: regenerate using a subject or composition      | Provide a reference and distinguish what to keep from what to change                          | Use image editing / image-to-image; pixel-perfect preservation is not guaranteed                                           |
| Style transfer\: photo to watercolor, line art, and more                    | Provide a reference and target style; state whether to preserve the subject and layout        | Use an editing model that accepts reference images                                                                         |
| Replace backgrounds, add or remove objects, or edit locally                 | Specify the area to change; provide a mask where supported                                    | Use editing; mask support and requirements vary by model                                                                   |
| Combine images\: compose products, people, and scenes                       | Explain each reference image's role, the relationships between subjects, and the final layout | Use an editing model with multi-image input and check input-count limits                                                   |
| Iterate over multiple turns\: continue editing a previous result            | Retain the history or references required by the protocol                                     | Use an interface supporting multi-turn image workflows; saving only text does not guarantee that image context is retained |
| Transparent-background assets                                               | Request a real alpha channel, not a white background or a checkerboard drawn into the image   | Select transparency and a format that preserves it only when the model supports them                                       |
| Image understanding, text extraction, chart questions                       | Supply the image and state the analysis goal                                                  | Use image understanding, which returns text rather than an edited image                                                    |

For capabilities and limitations, see [OpenAI image generation](https\://developers.openai.com/api/docs/guides/image-generation), [Gemini image generation and editing](https\://ai.google.dev/gemini-api/docs/image-generation), and [Qwen image editing](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api). Official examples do not establish that the current gateway channel exposes the same capabilities.

## 3. Calling the API\: four steps to your first image

Whichever protocol you choose, a call follows the same order\: confirm configuration, choose an endpoint, send a minimal request, then read and verify the result. The steps below describe only the general flow; the protocol page defines the exact fields.

### 1. Confirm the request URL, key, and model

* **Request URL**\: This site's gateway is `https://api.dwchainless.com`; the endpoint path varies by protocol and operation.
* **Key**\: Create one under [API key management](https://api.dwchainless.com/keys) and send it as `Authorization: Bearer $API_KEY`; never put it in prompts, source code, screenshots, or Git.
* **Model**\: Copy the complete model ID from [Models and pricing](https://api.dwchainless.com/en/pricing/) and confirm that it supports the target endpoint. Generation, editing, and image understanding may use different models.

### 2. Choose an endpoint and request format

Choose an endpoint from the protocol table above, then confirm the request body format\:

| Operation                       | Endpoint (OpenAI format)      | Request format                   |
| ------------------------------- | ----------------------------- | -------------------------------- |
| Text-to-image                   | `POST /v1/images/generations` | JSON                             |
| Image editing / image-to-image  | `POST /v1/images/edits`       | JSON `images[]` or multipart     |
| Conversational image generation | `POST /v1/responses`          | JSON with the image tool enabled |
| Image understanding             | `POST /v1/chat/completions`   | JSON with an `image_url` item    |

Gemini, Qwen, Jimeng, Grok, and FLUX use their own native request fields; do not copy OpenAI fields directly into them.

### 3. Send a minimal request

For the first call, generate one image without streaming to confirm that authentication, the model, and the parameters are valid. The following uses OpenAI generation as an example\:

```bash
API_URL="https://api.dwchainless.com/v1/images/generations"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
    "n": 1,
    "size": "1024x1024",
    "output_format": "png"
  }'
```

Once the response is normal, increase `n`, adjust the size, or enable streaming as needed. See [generation](/simidoc/en/apps/api/images/openai/generations) and [editing](/simidoc/en/apps/api/images/openai/edits) for complete multilingual examples.

**Response shape (illustrative)**\: a real response contains a very long Base64 string, so only the beginning is kept here. On success, read `data[]` rather than relying on HTTP 200 alone.

```json
{
  "created": 1763366400,
  "data": [{ "b64_json": "iVBORw0KGgoAAAANSUhEUg..." }],
  "usage": { "input_tokens": 28, "output_tokens": 4160, "total_tokens": 4188 }
}
```

### 4. Read and verify the result

1. **Check the status**\: Only 2xx means the request succeeded; for 4xx, check parameters and permissions; for 5xx or a timeout, first confirm whether the request executed.
2. **Read the result**\: Take images from `data[]`; GPT Image returns `data[].b64_json`, while compatible models may return `data[].url`; do not assume a first item exists.
3. **Save the image**\: Decode Base64 into binary and choose the extension from the actual MIME type; download URLs promptly and without the API key.
4. **Verify**\: Check that the file opens, then confirm actual pixel dimensions, transparency, and content, and inspect usage logs. HTTP 200, an empty `data[]`, or a streaming preview does not mean the final image has been saved.

## 4. Image specifications and billing

### What each request specification controls

| Specification          | Meaning and examples                                                                   | Common confusion                                                                                                                                         |
| ---------------------- | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Pixel dimensions       | Actual width × height, such as `1024x1024` or `1536x1024`                              | Not file size, and not automatically a quality tier                                                                                                      |
| Aspect ratio           | `1:1` square, `16:9` landscape, `9:16` portrait                                        | The same ratio can have multiple resolutions; choosing a ratio alone does not specify exact pixel dimensions                                             |
| Resolution tier        | Some models use native parameters such as `1K`, `2K`, and `4K`                         | Actual dimensions also depend on the model and aspect ratio; provider tiers should not be equated directly with this site's per-image billing boundaries |
| Generation quality     | For example, OpenAI's `quality` selects rendering quality                              | Not `size`, or JPEG/WebP compression quality; other models may not have the same parameter                                                               |
| File format            | PNG, JPEG, WebP, and others, according to the actual returned MIME type                | Base64 and URLs are delivery methods, not image formats; renaming an extension does not convert a file                                                   |
| Transparent background | An alpha channel, useful for compositing assets                                        | Requires support from the model, parameters, and file format; asking for transparency does not guarantee an alpha channel                                |
| Image count            | Number of generated images or candidates; fields and limits vary by protocol and model | Writing “generate three images” in the prompt is not the same as setting an API count; multiple inputs do not imply multiple outputs                     |

At a fixed aspect ratio, doubling both edges produces four times as many pixels, but does not guarantee a proportional increase in detail or sharpness. Start with the intended use, then check model support, latency, and pricing rather than always choosing the highest tier.

For fields, accepted values, and code examples, see [OpenAI request format](/simidoc/en/apps/api/images/openai/generations), [Gemini request format](/simidoc/en/apps/api/images/gemini/generate), [Qwen request format](/simidoc/en/apps/api/images/qwen/generations), [Jimeng request format](/simidoc/en/apps/api/images/jimeng), [Grok request format](/simidoc/en/apps/api/images/grok), and [FLUX request format](/simidoc/en/apps/api/images/flux). OpenAI's quality, format, and transparency settings are covered in the [official output options](https\://developers.openai.com/api/docs/guides/image-generation#customize-image-output); Qwen's dimension and output requirements are in the [official specifications](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api). Do not copy one protocol's parameters into another.

### How this site's 1K, 2K, and 4K per-image billing tiers differ

The table below applies only to models explicitly priced per image in three 1K / 2K / 4K tiers under [Model pricing](https://api.dwchainless.com/en/pricing/). Token-priced models and models with other fixed prices follow their own rules. An “image model” name alone does not determine how it is billed.

| Billing tier | Longest edge                          | Example dimensions (pixels) |
| ------------ | ------------------------------------- | --------------------------- |
| 1K           | Both edges ≤ 1024 pixels              | 1024×1024                   |
| 2K           | Longest edge > 1024 and ≤ 2048 pixels | 1280×720, 1536×1024         |
| 4K           | Either edge > 2048 pixels             | 2560×1440, 3840×2160        |

**Total price = per-image price for the current tier × billable image count.** Interfaces supporting settlement by completed results charge for the actual completed count; intermediate streaming previews are not completed images. Current model pricing and usage logs determine the unit price, group, and final charge. This page does not fix numerical prices.

Under these three-tier per-image rules, omitting `size` or using `auto` defaults to 1K only when no other valid resolution tier has been specified. Explicit native resolution fields still determine the billing tier. Pixel dimensions are classified by the longest requested edge, not total pixel count. For example, `1280x720` is 2K and `2560x1440` is 4K.

**A billing tier is not a promise of output dimensions.** Gemini's `generationConfig.imageConfig.imageSize` selects a native model resolution; confirm actual pixel dimensions against the model and aspect ratio. This site calculates billing tiers from supported request fields without promising uniform output dimensions. Do not send conflicting dimension fields, or apply these per-image rules to official direct calls or token-priced models.

### Common ratios at a glance\: 14 ratios × 1K / 2K / 4K

The table lists common 1K, 2K, and 4K preset dimensions by aspect ratio for quickly picking a frame. It is a size quick reference, not a model-support list\: available ratios, preset names, and per-side limits vary by model and gateway, so confirm against the model documentation or API error before requesting.

A K tier here is a preset name, not this page's per-image billing tier. For some "1K" presets the longest edge already exceeds 1024 pixels, which this site classifies as 2K; for example, the 16\:9 1K preset `1536x864` is 2K. Billing always follows the requested dimensions and [Models and pricing](https://api.dwchainless.com/en/pricing/).

| Ratio     | Common use                        | 1K size     | 2K size     | 4K size                 |
| :-------- | :-------------------------------- | :---------- | :---------- | :---------------------- |
| `1:1`     | Square avatar / product           | `1024x1024` | `2048x2048` | `3840x3840`             |
| `4:3`     | Landscape illustration / display  | `1152x896`  | `2048x1536` | `3840x2880`             |
| `3:4`     | Portrait poster / people          | `896x1152`  | `1536x2048` | `2880x3840`             |
| `16:9`    | Landscape cover / slides          | `1536x864`  | `2048x1152` | `3840x2160`             |
| `9:16`    | Vertical cover / phone background | `864x1536`  | `1152x2048` | `2160x3840`             |
| `3:2`     | Landscape photography             | `1536x1024` | `2048x1360` | `3840x2560`             |
| `2:3`     | Portrait photography              | `1024x1536` | `1360x2048` | `2560x3840`             |
| `5:4`     | Landscape product display         | `1280x1024` | `2560x2048` | `3840x3072`             |
| `4:5`     | Portrait product / social image   | `1024x1280` | `2048x2560` | `3072x3840`             |
| `21:9`    | Wide scene / banner               | `1792x768`  | `2048x880`  | `3840x1648`             |
| `1:4`     | Narrow vertical strip             | `512x2048`  | `768x3072`  | **Over per-side limit** |
| `4:1`     | Narrow horizontal strip           | `2048x512`  | `3072x768`  | **Over per-side limit** |
| `1.414:1` | Approx. A-series landscape paper  | `1440x1024` | `2048x1456` | `3840x2720`             |
| `1:1.414` | Approx. A-series portrait paper   | `1024x1440` | `1456x2048` | `2720x3840`             |

### Three correct ways to write size

Some OpenAI-compatible gateways accept the following forms; whether a field takes effect depends on the model and gateway, so fall back to explicit pixels when unsupported.

| Form                          | Request fragment                   | Purpose                                                               |
| :---------------------------- | :--------------------------------- | :-------------------------------------------------------------------- |
| Explicit pixels (recommended) | `{"size":"1536x2048"}`             | Most direct; avoids preset conversion differences                     |
| Ratio + resolution            | `{"size":"3:4","resolution":"2k"}` | Converts using the 2K, 3\:4 preset                                    |
| Automatic size                | `{"size":"auto"}`                  | The model chooses dimensions; fixed width and height are not promised |

* Put the K tier in `resolution` and pixels or a ratio in `size`; do not write `2k` in `size`.
* Use a lowercase English `x` as the dimension separator; do not use a multiplication sign, uppercase X, arrays, or strings with ×.
* A ratio in `size` takes precedence over `aspect_ratio` alone; explicit pixels or `auto` take precedence over ratio presets.
* The official arbitrary-size limit for gpt-image-2 is 3840×2160; the 4K `1:4` and `4:1` combinations exceed it and are marked as over the per-side limit. Other models follow their own published limits.
* Gemini and Qwen use their own size fields; these forms do not transfer directly.

### 28 common dimension references

The labels below indicate only the billing tiers defined above; they do not guarantee that the selected model supports these dimensions. Check the model's accepted dimensions first. Do not treat a billing tier as an API parameter value.

| Use / ratio                    | Dimensions (pixels) and billing tier                                         |
| ------------------------------ | ---------------------------------------------------------------------------- |
| General square · 1\:1          | 1024×1024 · 1K; 1536×1536 · 2K; 2048×2048 · 2K                               |
| Landscape cover · 16\:9        | 1280×720 · 2K; 1536×864 · 2K; 2048×1152 · 2K; 2560×1440 · 4K; 3840×2160 · 4K |
| Vertical video / Story · 9\:16 | 720×1280 · 2K; 864×1536 · 2K; 1152×2048 · 2K; 1440×2560 · 4K; 2160×3840 · 4K |
| Article illustration · 3\:2    | 1536×1024 · 2K; 1920×1280 · 2K; 2400×1600 · 4K                               |
| Portrait poster · 2\:3         | 1024×1536 · 2K; 1280×1920 · 2K; 1600×2400 · 4K                               |
| Wide banner · 2\:1             | 1536×768 · 2K; 2048×1024 · 2K; 2560×1280 · 4K; 3840×1920 · 4K                |
| Ultra-wide banner · 3\:1       | 1536×512 · 2K; 1920×640 · 2K; 2400×800 · 4K; 3072×1024 · 4K; 3840×1280 · 4K  |

## 5. Go deeper by protocol

Complete parameters, response structures, code examples, and error handling for each protocol\:

* [OpenAI format](/simidoc/en/apps/api/images/openai)
* [Gemini format](/simidoc/en/apps/api/images/gemini)
* [Qwen format](/simidoc/en/apps/api/images/qwen)
* [Jimeng / Volcengine Ark format](/simidoc/en/apps/api/images/jimeng)
* [xAI Grok format](/simidoc/en/apps/api/images/grok)
* [BFL FLUX format](/simidoc/en/apps/api/images/flux)