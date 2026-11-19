# Gemini image interfaces

This section uses Gemini GenerateContent's native `contents/parts` format. Generation and editing require a model with image output; adding parameters does not give a text-only model image-generation capabilities. Complete one single-image task before increasing the count or connecting an agent.

## Request format and parameters

| API                      | Request format                                      | Main parameters                                                               | Detailed documentation                                         |
| ------------------------ | --------------------------------------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Text-to-image            | `POST /v1beta/models/{model}:generateContent`, JSON | `contents[].parts[].text`, `generationConfig`                                 | [Generation parameters and code in four languages](/simidoc/en/apps/api/images/gemini/generate) |
| Editing / image-to-image | The same `generateContent` endpoint                 | `text` and a separate image Part\: `inlineData` or model-supported `fileData` | [Editing parameters and code in four languages](/simidoc/en/apps/api/images/gemini/edits)       |
| Image understanding      | The same `generateContent` endpoint                 | An image and a question, targeting text analysis rather than image output     | [Gemini media understanding](/simidoc/en/apps/api/chat/gemini-media)          |

Text-to-image uses text only. For editing, add references and distinguish what to keep from what to change. Style transfer, background replacement, and multi-image composition are editing goals, not a separate `/images/edits` path. GenerateContent's `contents` and `candidates` differ from Interactions' `input`, `steps`, and `response_format`; do not mix them.

### Image specifications

Where supported, `generationConfig.imageConfig.aspectRatio` sets the aspect ratio, such as `1:1`, and `generationConfig.imageConfig.imageSize` sets a model-accepted resolution, such as `1K`, `2K`, or `4K`. These values are not supported by every Gemini image model, and cannot be replaced with OpenAI's `size`. Actual pixel dimensions depend on available ratios and model versions; determine the returned format from the actual MIME type.

| This site's three-tier per-image billing | Longest requested edge   | Pixel example |
| ---------------------------------------- | ------------------------ | ------------- |
| 1K                                       | ≤ 1024 pixels            | 1024×1024     |
| 2K                                       | > 1024 and ≤ 2048 pixels | 1536×1024     |
| 4K                                       | > 2048 pixels            | 2560×1440     |

This table describes billing for specific per-image models on this site, not a universal Google definition of resolution names. It applies only where [Models and pricing](https://api.dwchainless.com/en/pricing/) explicitly specifies this rule; token-based and other pricing rules do not use this table. Higher resolution does not guarantee correct text or details. If the model does not support the target specifications, report an error instead of lowering them without permission. See the [image specifications and billing overview](/simidoc/en/apps/api/images).

## Response parameters

| Response field                                 | Meaning and handling                                                                                                      |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `candidates[]`                                 | Candidate list; filtering or failure may leave no usable images.                                                          |
| `candidates[].content.parts[]`                 | Traverse text and images in order; do not assume the first part is an image.                                              |
| `parts[].inlineData.mimeType` / `.data`        | Actual image MIME type and raw Base64; choose the extension by MIME and decode the data.                                  |
| `parts[].thought` / `.thoughtSignature`        | Do not treat intermediate thought images as final; retain opaque signatures returned by the model for multi-turn editing. |
| `candidates[].finishReason` / `promptFeedback` | Check completion and filtering rather than claiming success solely on HTTP 200.                                           |
| `usageMetadata`                                | Optional usage information; applicable pricing rules and logs still determine charges.                                    |

## Calling examples

### Prepare configuration

Create a key in [API key management](https://api.dwchainless.com/keys), copy the exact currently available model ID supporting GenerateContent image output from [Models and pricing](https://api.dwchainless.com/en/pricing/), and check the group, quota, and editing capability. Fill in API\_URL, API\_KEY, and MODEL directly in the example\:

| Variable       | Purpose                                                                                                                                     |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `API_KEY`      | Required; set directly in the example, never place in prompts, code, screenshots, or Git.                                                   |
| `MODEL`        | Required; the selected Gemini image model, used as the model name in the path.                                                              |
| `API_URL`      | Complete request URL; the examples use the gateway `https://api.dwchainless.com`.                                                           |
| `IMAGE_BASE64` | Replace with the pure Base64 of an authorized image (no `data:` prefix); format and dimensions must meet the selected model’s requirements. |

The [generation examples](/simidoc/en/apps/api/images/gemini/generate) and [editing examples](/simidoc/en/apps/api/images/gemini/edits) provide Python, Node.js, curl, and Go. Choose one language and make one non-streaming call first. Save Python code as `generate.py` or `edit.py`, then run `python3 generate.py` or `python3 edit.py`. The Node.js examples use top-level await (ESM); save them as `generate.mjs` or `edit.mjs`, then run `node generate.mjs` or `node edit.mjs`.

### Agent generation demo

The agent must be able to run local scripts and inspect responses. This workflow does not install remote Skills or modify the existing connection. A text-only client cannot execute it directly.

```text
Read this Gemini protocol page and the GenerateContent image generation reference first.
Use the configured SimiRouter request URL in API_URL (default gateway
https://api.dwchainless.com) and MODEL. Set API_KEY directly in the example; never
print, paste, commit, or store it in source files. For this one approved task, call POST
/v1beta/models/{model}:generateContent once, non-streaming, Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. with a text Part describing a calm blue library with a small robot reading,
watercolor, no lettering. Request one image; use imageConfig aspectRatio=1:1 and
imageSize=1K only if the model supports them. Do not invent an n parameter or mix
Interactions fields into GenerateContent. After the response, read only completed,
non-thought inlineData from parts; decode the Base64 in memory and report any unmet
requirement; do not write an image file. Do not switch providers/models/billing groups,
increase size/count, write files, install remote skills, or retry an ambiguous failure
without approval. Report a redacted error instead of false success.
```

### Agent editing demo

Read only authorized references, checking for personal information or trade secrets first. Multi-turn editing needs the complete context returned by the model; do not discard signatures arbitrarily. A request to “keep” something does not guarantee pixel-level consistency.

```text
Read this Gemini protocol page and its image editing reference first. Use the existing
API_KEY, MODEL and configured SimiRouter request URL; never reveal credentials or change
the existing connection. Read only the authorized local image, encode it as pure Base64,
and put it in IMAGE_BASE64. Submit its inlineData Part alongside the text instruction
through POST /v1beta/models/{model}:generateContent. Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. Keep the subject and layout; change only the background to pale blue. Request one
image, non-streaming; use aspectRatio=1:1 and imageSize=1K only if supported. Do not use
OpenAI multipart or mask fields. After the response, read only completed, non-thought
inlineData from parts; decode the Base64 in memory and report any unmet requirement; do
not write an image file. Preserve opaque signatures for later turns. Do not upload
unrelated files, overwrite results, change model/size/count/provider, install remote
skills, or retry automatically. Ask before any additional paid request.
```

## Saving and completion criteria

* Check the HTTP status, `finishReason`, and image content. Explicitly report incomplete results if the response is text-only, filtered, missing a final image, or in an unexpected format. Do not save the whole JSON as an image.
* Strictly decode Base64, check the actual file format against the MIME type, and verify that the file opens and meets dimension and content requirements. Preserve existing files; on failure, remove only invalid outputs created by this attempt.
* Use streaming through `streamGenerateContent?alt=sse` only where the model supports it. An arbitrary fragment is not a final image. `generateContent` returns complete results synchronously and does not provide a universal task ID for polling. Google Batch is a separate service, not the endpoint documented here.
* Save multiple images separately by content part and check the completed count. A prompt asking for “one image” does not guarantee exactly one result from every model. Do not call again automatically to make up the count without permission.

## Errors, retries, and charges

For 400, check the model, fields, and reference image; for 401/403, check key permissions; for 404, check the model and path; for 429, check quota and rate limits. After a timeout, 5xx, or missing complete terminal result, inspect usage logs and existing files first, without resending automatically. Report only redacted errors and request identifiers, not keys, complete Base64, or private image content.

Real generation and editing may incur charges. Confirm the model, specifications, count, and output location before calling. Higher tiers, more images, model changes, and retries require renewed confirmation. Control rate limits, timeouts, and charges separately for parallel requests. Usage fields do not establish that a model is token-priced. Current pricing and usage logs determine the final charge.

## Official references

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google image generation and editing](https\://ai.google.dev/gemini-api/docs/image-generation)