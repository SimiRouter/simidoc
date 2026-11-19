# Qwen native image interfaces

This section uses the native Qwen request body but always calls through this site's gateway\: `API_URL` is `https://api.dwchainless.com/v1/images/...`, and authentication uses this site's `API_KEY`. Request parameters follow `model`, `input.messages`, and `parameters`, and the response is always `data[]`; complete one single-image call first, then increase the count or connect an agent.

## Request format and parameters

| API                      | Request format                      | Main parameters                                                     | Detailed documentation                                            |
| ------------------------ | ----------------------------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------- |
| Text-to-image            | `POST /v1/images/generations`, JSON | `model`, `input.messages[].content[].text`, `parameters`            | [Generation parameters and code in four languages](/simidoc/en/apps/api/images/qwen/generations) |
| Editing / image-to-image | `POST /v1/images/edits`, JSON       | `content[]` containing an `image` and one `text`, plus `parameters` | [Editing parameters and code in four languages](/simidoc/en/apps/api/images/qwen/edits)          |

In the 2.0-series examples on this page, `input.messages` contains one `user` message whose text describes the subject, composition, style, and text to render; for editing, add an authorized image URL or a model-supported data URL. Background replacement, style transfer, editing text within images, and multi-image fusion are editing goals; there are no separate OpenAI multipart fields, and pixel-perfect detail preservation is not guaranteed.

### Image specifications

Dimensions go in `parameters.size` in the format `width*height`, for example `"2048*2048"`, not `"2048x2048"` or `"2K"`. The 2.0 series constrains dimensions by total pixel range; check the input image, width, height, and output limits against the model. A total-pixel limit is not a longest-edge limit.

| This site's three-tier per-image billing | Longest requested edge   | Pixel example |
| ---------------------------------------- | ------------------------ | ------------- |
| 1K                                       | ≤ 1024 pixels            | 1024×1024     |
| 2K                                       | > 1024 and ≤ 2048 pixels | 1536×1024     |
| 4K                                       | > 2048 pixels            | 2560×1440     |

This table explains only the billing tiers of specific models on this site; it does not mean the models accept `1K` / `2K` / `4K` parameters. Calls through this site are billed under [Models and pricing](https://api.dwchainless.com/en/pricing/), and see the [image specifications and billing overview](/simidoc/en/apps/api/images). Larger pixel counts do not guarantee correct text or details; unsupported target specifications should return an error instead of being silently substituted.

## Response parameters

| Response field          | Meaning and handling                                                                          |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| `created`               | Response generation timestamp.                                                                |
| `data[].url`            | Final image URL; validity is determined by the channel, so download and save promptly.        |
| `data[].b64_json`       | Some channels return raw Base64; when present, decode and save directly.                      |
| `data[].revised_prompt` | Prompt rewritten by the channel; may be absent.                                               |
| `error` / `message`     | Error code and description; check business errors and image presence even when HTTP succeeds. |

The request body is the native Qwen structure, and the response is the uniform `data[]`. Do not copy another channel's `prompt`, multipart, or asynchronous `task_id` protocol; the model ID must match the actual name provided by this site's channel.

## Calling examples

### Prepare configuration

Check available models and balance under [Models and pricing](https://api.dwchainless.com/en/pricing/), and use a Key created on this site. `API_URL` always points to this site's gateway; no workspace ID, regional domain, or official Model Studio Key is needed.

| Configuration | Purpose                                                                                                                         |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `API_KEY`     | This site's Key; fill it directly in the example, and do not paste it into prompts, code, screenshots, or Git.                  |
| `API_URL`     | Full request address of this site's gateway, such as `https://api.dwchainless.com/v1/images/generations`.                       |
| `model`       | The existing example uses `qwen-image-2.0-pro`; first confirm this site's channel supports the model and required capabilities. |
| `IMAGE_URL`   | Authorized, cloud-accessible HTTP(S) image address used by the editing example; not a local path or localhost.                  |

The [generation examples](/simidoc/en/apps/api/images/qwen/generations) and [editing examples](/simidoc/en/apps/api/images/qwen/edits) provide Python, Node.js, curl, and Go. The existing code sends one request and prints JSON; it **does not download images automatically**. Save Python code as `generate.py` / `edit.py` and run `python3 generate.py` / `python3 edit.py`; save Node.js code as `generate.mjs` / `edit.mjs` and run `node generate.mjs` / `node edit.mjs`. Configure the runtime and variables as described on the corresponding page, request only one image first, then save the actual image referenced by the URL as described in the next section.

### Agent generation demo

The agent needs local scripting, network requests, and the ability to inspect returned results; this page is not an instruction to install a Skill and does not add these capabilities to a text-only client.

```text
Read this Qwen image protocol page and its generation reference first. Use the
existing API_KEY and API_URL from this site's gateway; never print, paste, commit,
or store the key in source files. Use the documented qwen-image-2.0-pro model only
after checking availability and pricing. For this one approved request, POST once
to /v1/images/generations with the native Qwen body: one user message, one text
content item, parameters.n=1 and size=1024*1024 if supported. Image brief: a calm
blue library with a small robot reading, watercolor illustration, no lettering.
Print the returned JSON and inspect data[].url or data[].b64_json; report the final
image URL without forwarding the API key. JSON or a URL alone is not a saved image.
Do not switch model/provider, increase size/count, write files, install remote
skills, or automatically retry an error or timeout. Ask before another paid request.
```

### Agent editing demo

Use only images authorized for processing and upload; check for personal information and trade secrets first. The existing example reads a URL and does not automatically publish local files to other services.

```text
Read this Qwen image protocol page and its editing reference first. Use the existing
API_KEY and API_URL from this site's gateway; never reveal the key or switch the
existing connection. Verify qwen-image-2.0-pro supports the edit. Use only the
authorized cloud-readable image in IMAGE_URL; do not upload unrelated local files or
publish a file. POST once to /v1/images/edits with the native Qwen body: one user
message containing that image item and one text instruction: keep the subject and
layout; change only the background to pale blue. Set parameters.n=1 and size=1024*1024
only if supported. Do not use OpenAI multipart or mask fields. Check the completed
business result, inspect data[].url or data[].b64_json without forwarding the API key,
and report it. Do not write files, change model/size/count/provider, install remote
skills, or retry automatically. If any step fails or the requested edit is not met,
report a redacted error instead of claiming success.
```

## Saving and completion criteria

* A synchronous response is not a polling task; this section does not use `task_id` or `X-DashScope-Async`. Do not mix in another model's asynchronous protocol, and do not treat streaming events as completion criteria.
* Check HTTP and business errors, the finish reason, and the actual image items, then traverse the image URLs. URLs have limited validity, so download promptly; JSON, an address, or an agent's verbal conclusion does not mean the file has been saved.
* When downloading, check the response status, content, and file signature; do not rename an error page to PNG. Do not send this site's Key to the result storage domain. Keep the original files, and on failure clean up only the invalid output created by this attempt.
* Confirm that the file exists, opens, and meets the dimension and content requirements, and verify the request and charge in this site's billing or usage logs. Check multiple images one by one; do not call again automatically just to make up the count.

## Errors, retries, and charges

For parameter errors, check `model`, the message structure, `size`, and the input image. For authentication errors, check this site's Key and model permissions. For quota or rate-limit errors, check the account status. After a timeout, 5xx, or unclear result, inspect the call logs and existing files first; do not resend automatically, which can duplicate generation or charges. Report only redacted errors; do not output keys, full Base64, or private images.

Real generation and editing may incur charges. Before calling, confirm the model, dimensions, image count, and output location; incremental changes, specification upgrades, or retries require renewed confirmation. Control rate limits, timeouts, and charges separately for parallel requests; `n` is the count per request. Final pricing is determined by this site's rules and billing.

## Official references

* [Qwen-Image generation](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api)
* [Qwen-Image editing](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api)