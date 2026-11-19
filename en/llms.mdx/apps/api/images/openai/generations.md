# Image generation

## Endpoint overview

`POST /v1/images/generations` generates one or more images from prompt.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $API_KEY`. Direct OpenAI access uses `https://api.openai.com` and Bearer authentication, but requires an OpenAI key. Select a model available to the account that supports the required capability.

This page uses GPT Image parameters. OpenAI-compatible image models from different vendors may accept different sizes, quality levels, and output formats; these differences are not one official standard.

## Quick start

1. **Prepare configuration**\: Create a key under [API key management](https://api.dwchainless.com/keys), and copy an Images API–capable model ID from [Models and pricing](https://api.dwchainless.com/en/pricing/).
2. **Send the request**\: POST JSON to `https://api.dwchainless.com/v1/images/generations` with the header `Authorization: Bearer $API_KEY`; the body must contain at least `model` and `prompt`.
3. **Read the result**\: Success requires HTTP 2xx and a non-empty `data[]`; decode and save GPT Image's `data[].b64_json`.
4. **Confirm completion**\: Check that the file opens and matches the required dimensions, then inspect usage logs.

The minimal request follows; once it works, adjust the count, size, or streaming\:

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

## Request parameters

The request body is JSON.

| Field               | Type    | Required | Description                                                                                                                                                                     |
| ------------------- | ------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model               | string  | Yes      | An image-model ID supporting the Images API.                                                                                                                                    |
| prompt              | string  | Yes      | Describe the subject, composition, style, and text precisely.                                                                                                                   |
| n                   | integer | No       | Image count; native OpenAI GPT Image supports 1–10, with 1 in the example.                                                                                                      |
| size                | string  | No       | Native OpenAI form is WIDTHxHEIGHT (width and height divisible by 16, aspect ratio 1\:3–3\:1) or auto; SimiRouter also accepts ratio plus resolution, and limits vary by model. |
| resolution          | string  | No       | SimiRouter extension\: tier 1k, 2k, or 4k used with a ratio, not a pixel value; the native OpenAI API has no such field.                                                        |
| aspect\_ratio       | string  | No       | SimiRouter extension\: separate ratio such as 3\:4; a ratio in size takes precedence.                                                                                           |
| quality             | string  | No       | auto, low, medium, or high; some newer models also support xhigh and max.                                                                                                       |
| output\_format      | string  | No       | png, jpeg (examples), or webp; the official schema also lists gif and svg where the model and project access support them.                                                      |
| output\_compression | integer | No       | JPEG/WebP compression quality from 0–100; not applicable to PNG.                                                                                                                |
| background          | string  | No       | auto, opaque, or transparent; transparency requires a supported model and PNG/WebP.                                                                                             |
| moderation          | string  | No       | auto or supported low; does not guarantee content-policy approval.                                                                                                              |
| response\_format    | string  | No       | Some compatible models accept url or b64\_json; native GPT Image does not use it.                                                                                               |
| stream              | boolean | No       | true uses image SSE events.                                                                                                                                                     |
| partial\_images     | integer | No       | With stream=true, request 0–3 intermediate images; still wait for the final completion event.                                                                                   |

GPT Image returns Base64 directly; do not rely on the legacy response\_format=url/b64\_json. Some compatible models can use that field to choose a URL or Base64, subject to model documentation and the actual response. The old style=vivid/natural setting also does not apply; describe style in prompt.

### Request example

```json
{
  "model": "gpt-image-2",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，柔和蓝金色调，不要文字。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

## Image size and format

K is a common resolution label, not file size or a quality setting. Actual dimensions depend on the model and aspect ratio. At the same ratio, doubling both edges quadruples the pixel count. The examples below explain the terms; they are not universally accepted sizes.

OpenAI uses `size` for model-supported dimensions such as `1024x1024`, not the literal `1K`; `quality` and `output_format` independently control quality and format.

| Resolution label | Common pixel examples (not a model support guarantee)       |
| ---------------- | ----------------------------------------------------------- |
| 1K               | 1024×1024 · About one thousand pixels per edge              |
| 2K               | 2048×2048 · About two thousand pixels per edge              |
| 4K               | 4096×4096 / 3840×2160 · About four thousand pixels per edge |

The site’s per-image billing tiers are separate rules; do not use these illustrative resolution labels as the billing standard. [Image specifications and billing rules](/simidoc/en/apps/api/images).

### Three ways to write size

Some OpenAI-compatible gateways also accept a ratio plus resolution or an automatic size; whether a field takes effect depends on the model and gateway, so fall back to explicit pixels when unsupported.

| Form                          | Request fragment                   | Notes                                                              |
| ----------------------------- | ---------------------------------- | ------------------------------------------------------------------ |
| Explicit pixels (recommended) | `{"size":"1536x2048"}`             | Most direct; avoids preset conversion differences.                 |
| Ratio + resolution            | `{"size":"3:4","resolution":"2k"}` | Uses the 2K, 3\:4 preset; resolution accepts only 1k, 2k, 4k.      |
| Automatic size                | `{"size":"auto"}`                  | The model chooses width and height; fixed pixels are not promised. |

* A ratio in size takes precedence over a separate aspect\_ratio; explicit pixels or auto take precedence over ratio presets.
* Put the tier in resolution; do not send size=2k. Use a lowercase English x as the dimension separator.
* For gpt-image-2 the official arbitrary-size limit is 3840×2160; larger combinations such as 4096×4096 generally return a parameter error. The 4K row is a tier illustration, not a guaranteed pixel size.
* For a quick reference of 14 common ratios at 1K, 2K, and 4K, see [Image specifications and billing rules](/simidoc/en/apps/api/images).

## Response

| Field                                                | Type    | Description                                                                               |
| ---------------------------------------------------- | ------- | ----------------------------------------------------------------------------------------- |
| created                                              | integer | Creation time in Unix seconds.                                                            |
| data\[]                                              | array   | Generated result list; a first item is not guaranteed.                                    |
| data\[].b64\_json                                    | string  | Base64 image bytes; GPT Image uses this format.                                           |
| data\[].url                                          | string  | Present only for compatible models supporting URL output; not a required GPT Image field. |
| data\[].revised\_prompt                              | string  | Revised prompts from some older or compatible models; not required for GPT Image.         |
| output\_format / size / quality / background         | string  | Optional effective output settings.                                                       |
| usage                                                | object  | Optional usage data; availability and granularity vary by model and service.              |
| usage.input\_tokens / output\_tokens / total\_tokens | integer | Input, output, and total tokens, if returned.                                             |
| usage.input\_tokens\_details                         | object  | Optional breakdowns such as image\_tokens and text\_tokens.                               |
| X-Request-Id                                         | string  | Response header, not a JSON field; keep it for support or debugging.                      |

A returned data\[].url may expire; do not attach the API key when downloading images. The Base64 below is a minimal PNG illustrating structure, not a real result of the prompt above.

```json
{
  "created": 1760000000,
  "data": [
    {
      "b64_json": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "output_format": "png"
}
```

### Streaming generation

Supported models accept stream=true, with image\_generation.partial\_image for previews and image\_generation.completed for final images and usage. Partial images are not final results. If a stream ends without completed, do not mark a preview complete. This endpoint returns no universal pollable background-task ID.

## Code examples

Fill in `API_URL` and `API_KEY` at the top of the code; the examples use `gpt-image-2`. `API_URL` is the full request URL and defaults to the gateway `https://api.dwchainless.com`. The examples use standard libraries only, send one request, and print the returned JSON to stdout; they do not save images automatically.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/generations"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1,
    }
    request = urllib.request.Request(
        API_URL,
        data=json.dumps(body).encode(),
        method="POST",
        headers={
            "Authorization": "Bearer " + API_KEY,
            "Content-Type": "application/json",
        },
    )
    print(urllib.request.urlopen(request).read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const API_URL = 'https://api.dwchainless.com/v1/images/generations';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        prompt: '一只小机器人在图书馆阅读，水彩插画，不要文字。',
        size: '1024x1024',
        n: 1,
      }),
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/generations"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/images/generations"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
            "size": "1024x1024",
            "n": 1
        }`)
        request, _ := http.NewRequest("POST", apiURL, bytes.NewReader(body))
        request.Header.Set("Authorization", "Bearer "+apiKey)
        request.Header.Set("Content-Type", "application/json")
        response, _ := http.DefaultClient.Do(request)
        defer response.Body.Close()
        result, _ := io.ReadAll(response.Body)
        fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Agent invocation demo

Copy this task to an agent that can run local scripts and inspect the response. Fill in API\_URL, API\_KEY, and MODEL directly in the example first using [the protocol configuration](/simidoc/en/apps/api/images/openai). Never put the key in the prompt.

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

## Errors

| HTTP status     | Meaning or vendor error type                           | Action                                                                                                           |
| --------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| 400             | Invalid request                                        | Check required fields, JSON, model parameters, and context length.                                               |
| 401             | Authentication failed                                  | Check that the key exists, is valid, and belongs to the correct service.                                         |
| 403 / 404       | Access denied / resource not found                     | Check model permissions, resource IDs, and the URL.                                                              |
| 413             | Request body or image too large                        | Prefer image URLs; reduce Base64 size or image dimensions.                                                       |
| 429             | Rate or quota limit                                    | Distinguish rate limits from insufficient quota using the response body; retrying cannot fix insufficient quota. |
| 500 / 502 / 503 | Server error / busy upstream / temporarily unavailable | Retain the request identifier and use bounded backoff for transient failures.                                    |

Native OpenAI errors usually contain `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` may be `null`; do not assume these fields always exist or equal the HTTP status. The gateway may return authentication, routing, or quota errors before contacting the vendor; the status alone does not establish an upstream error. Empty data, missing image data, or intermediate previews alone do not establish completed generation under HTTP 200.

Generation and editing can take tens of seconds to minutes; set a sufficient client timeout, since a hanging request is not the same as a failure. After a timeout, broken stream, or 5xx, first confirm whether the request already executed before retrying, to avoid duplicate generation and charges. When content policy rejects a request (usually 400), revise the prompt or reference image instead of retrying unchanged.

## Official reference

* [OpenAI Create image](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [OpenAI image generation guide](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI error handling](https\://developers.openai.com/api/docs/guides/error-codes)