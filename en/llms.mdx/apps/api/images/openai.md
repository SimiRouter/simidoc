# OpenAI-format image interfaces

This section uses the OpenAI format and distinguishes generation, editing, conversational image generation, and image understanding. Complete one single-image call before increasing the count or connecting an agent. The selected model must support the required image capability.

## Calling order

1. **Prepare configuration**\: Create a key under [API key management](https://api.dwchainless.com/keys), and copy a supported full model ID from [Models and pricing](https://api.dwchainless.com/en/pricing/); the request URL is the gateway `https://api.dwchainless.com`, and the header is `Authorization: Bearer $API_KEY`.
2. **Choose an endpoint**\: use `POST /v1/images/generations` for text-to-image, `POST /v1/images/edits` for editing / image-to-image, `POST /v1/responses` for conversational image generation, and `POST /v1/chat/completions` for image understanding.
3. **Send a minimal request first**\: request a single image without streaming; confirm authentication, model, and parameters are valid before increasing count, size, or connecting an agent.
4. **Read and verify**\: decode Base64 from `data[]` or download the URL, check that the file opens and that dimensions and content meet requirements, then check the usage logs.

Full parameters, examples, and error handling are on the protocol pages below; start with [generation](/simidoc/en/apps/api/images/openai/generations) for the first call.

## Request format and parameters

| API                             | Request format                                    | Main parameters                                                                   | Detailed documentation                                            |
| ------------------------------- | ------------------------------------------------- | --------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| Text-to-image                   | `POST /v1/images/generations`, JSON               | `model`, `prompt`; set `n`, `size`, and `quality` according to the model          | [Generation parameters and code in four languages](/simidoc/en/apps/api/images/openai/generations) |
| Editing / image-to-image        | `POST /v1/images/edits`, either JSON or multipart | `model`, `prompt`, and `images[]` or the `image` file; add `mask` where supported | [Editing parameters and code in four languages](/simidoc/en/apps/api/images/openai/edits)          |
| Conversational image generation | `POST /v1/responses`, JSON                        | `input`, the image generation tool, and its model configuration                   | [Conversational image generation](/simidoc/en/apps/api/images/openai/chat-format)                  |
| Image understanding             | `POST /v1/chat/completions`, JSON                 | Text and image content items within `messages`, using `image_url`                 | [Image understanding](/simidoc/en/apps/api/images/openai/vision)                                   |

Editing prompts should distinguish what to keep from what to change. Style transfer, background replacement, and adding or removing objects are editing goals, not another API. Masks, multiple input images, and transparent backgrounds require support from the selected model. Pixel-perfect preservation of people, products, or text is not guaranteed.

### Image specifications

`size` expresses pixel dimensions, such as `1024x1024`, rather than a universal `1K` / `2K` / `4K` enumeration; accepted dimensions vary by model. `quality` controls quality and `output_format` controls PNG/JPEG/WebP encoding. Neither replaces resolution. Transparent backgrounds also require model support for `background: transparent` and PNG or WebP output.

The three ways to write size, the 14-ratio quick reference, and the 1K/2K/4K per-image billing tiers are covered in the [image specifications and billing overview](/simidoc/en/apps/api/images). The billing table applies only to models that explicitly use this rule in [Models and pricing](https://api.dwchainless.com/en/pricing/), and does not guarantee that every example dimension is accepted.

## Response parameters

| Response field / event                                | Meaning and handling                                                                                                             |
| ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Images `data[].b64_json`                              | GPT Image's Base64 image data; decode and save it as a binary image, rather than renaming the whole JSON to PNG.                 |
| Images `data[].url`                                   | May appear only for older or compatible models with URL output; download promptly and do not assume GPT Image always returns it. |
| Images `usage`                                        | Optional usage data; the presence of this field does not necessarily mean token-based billing.                                   |
| `image_generation.completed` / `image_edit.completed` | Final Images streaming generation / editing events; `partial_image` is only an intermediate preview.                             |
| Responses `output[]`                                  | Handle conversational generation through image-tool output items, not Images `data[]`.                                           |
| Chat `choices[].message.content`                      | Image understanding returns text analysis rather than generated images.                                                          |

## Calling examples

### Prepare configuration

Create a key in [API key management](https://api.dwchainless.com/keys), copy the exact image model ID available to that key from [Models and pricing](https://api.dwchainless.com/en/pricing/), and check permissions, group, and quota. Fill in API\_URL, API\_KEY, and MODEL directly in the example\:

| Variable    | Purpose                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------- |
| `API_KEY`   | Required; set directly in the example, never paste into prompts, source files, screenshots, or Git.           |
| `MODEL`     | Required; separately confirm that the model supports the generation or editing endpoint.                      |
| `API_URL`   | Complete request URL; the examples use the gateway `https://api.dwchainless.com`.                             |
| `IMAGE_URL` | An HTTPS image URL used by the editing example; the server must be able to access a PNG, JPEG, or WebP image. |

The [generation examples](/simidoc/en/apps/api/images/openai/generations) and [editing examples](/simidoc/en/apps/api/images/openai/edits) provide Python, Node.js, curl, and Go. Choose one language and first request only one non-streaming image. The Python 3.8+ and Node.js 20+ examples use standard libraries. Save generation code as `generate.py` or `generate.mjs`, and editing code as `edit.py` or `edit.mjs`; run the relevant file, for example `python3 generate.py` or `node generate.mjs`. Both the Python and Node.js editing examples use JSON `images[].image_url` and do not use multipart uploads.

### Agent generation demo

The agent must be able to run local scripts, read authorized images, and inspect responses. This page does not install a Skill or give a text-only client tool capabilities. Preserve the existing connection and do not switch services without permission.

```text
Read this OpenAI image protocol page and its generation reference first. Use the
SimiRouter request URL in API_URL (default gateway https://api.dwchainless.com) and the
image model in MODEL. Set API_KEY directly in the example; never print, paste, commit,
or store it in source files. For this one approved request, use POST
/v1/images/generations with n=1, size=1024x1024, stream=false and output_format=png only
after verifying the model supports these parameters. Image brief: a calm blue library
with a small robot reading, watercolor illustration, no lettering. Print the returned
JSON and inspect data[].b64_json; do not write an image file. Confirm that
data[].b64_json contains non-empty Base64 data before reporting completion. Do not
install remote skills, switch providers/models/billing groups, increase size/count,
write files, or retry after timeout or ambiguous failure without approval. If the
request or validation fails, report a redacted error, not success.
```

### Agent editing demo

Confirm permission to process the reference image and check for personal information or trade secrets. Authorize only the necessary files. “Keep” in a prompt expresses a goal, not a pixel-level guarantee.

```text
Read this OpenAI image protocol page and its editing reference first. Set API_KEY,
MODEL, and API_URL directly in the example; use the configured SimiRouter request URL;
never reveal the key or change the existing connection. Use only the authorized HTTPS
image URL in IMAGE_URL. Use POST /v1/images/edits with JSON images[]; do not set
multipart Content-Type or send local files. Keep the subject and layout; change only the
background to pale blue. Request one PNG at 1024x1024 with stream=false only if the
selected model supports it. Print the returned JSON and inspect data[].b64_json; do not
write an image file. Confirm that data[].b64_json contains non-empty Base64 data and
report any unmet requirement. Do not upload unrelated files, change
size/count/model/provider, install remote skills, or retry automatically after an error
or timeout. Ask before another paid request.
```

## Saving and completion criteria

* Before saving, check the HTTP status, final image fields, decoding result, and actual file format. Renaming an extension does not convert the format. On failure, clean up only invalid files created by this attempt; do not delete existing files.
* Start with a single-image, non-streaming request. Streaming requires the corresponding `completed` event; handle multiple results by image index. Without a terminal result, do not mark previews as completed. Standard Images is not a universal asynchronous queue that first returns a task ID for polling.
* Check that the file exists, opens, and meets dimension and content requirements, then check usage logs. HTTP success or an agent saying “done” does not establish that the image was saved.

## Errors, retries, and charges

For 400, check the model and parameters; for 401, check the key; for 403/404, check permissions, model ID, and path; for 429, check quota and rate limits. After a 5xx, timeout, or interrupted stream, inspect logs and existing results before doing anything else. Do not resend automatically, which can duplicate generation or charges. Report only redacted errors and request identifiers, not keys, complete image Base64, or private image content.

Real generation and editing may incur charges. Confirm the model, dimensions, image count, and output location before calling. Increasing `n`, selecting a higher tier, changing models, or retrying requires renewed confirmation. Parallel requests have separate rate limits, timeouts, and charges; `n` is the image count in a single request, not concurrency. Current model pricing and usage logs determine the final charge.

## Official references

* [OpenAI image generation guide](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Images API](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [OpenAI vision input](https\://developers.openai.com/api/docs/guides/images-vision)