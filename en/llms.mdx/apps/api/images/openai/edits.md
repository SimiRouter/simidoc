# Image editing and image-to-image

## Endpoint overview

`POST /v1/images/edits` accepts reference images and editing instructions and returns edited images. It can replace backgrounds, transfer styles, add or remove elements, or combine references.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $API_KEY`. Direct OpenAI access uses `https://api.openai.com` and Bearer authentication, but requires an OpenAI key. Select a model available to the account that supports the required capability.

Supports JSON images\[] references and multipart uploads. The examples pass a server-accessible HTTPS image URL through JSON `images[].image_url`; they do not use multipart uploads.

## Quick start

1. **Prepare configuration**\: Create a key under [API key management](https://api.dwchainless.com/keys), and copy an editing-capable image model ID from [Models and pricing](https://api.dwchainless.com/en/pricing/).
2. **Prepare reference images**\: Use server-accessible HTTPS image URLs, or upload local files through multipart; do not mix both in one request.
3. **Send the request**\: Send JSON to `https://api.dwchainless.com/v1/images/edits` containing `model`, `prompt`, and image references; use the header `Authorization: Bearer $API_KEY`.
4. **Read and verify**\: Success requires HTTP 2xx and a non-empty `data[]`; decode `data[].b64_json` or download `data[].url`, then check the file, dimensions, and content.

For the first call, edit a single image without streaming; once it works, add more references or enable streaming.

## Request parameters

| Field                | Type    | Required        | Description                                                                                                                                                                     |
| -------------------- | ------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                | string  | Yes (gateway)   | Explicitly choose an editing-capable image model rather than relying on upstream defaults.                                                                                      |
| images               | array   | Yes (JSON)      | Image reference list; native GPT Image allows up to 16 images, with potentially stricter model limits.                                                                          |
| images\[].image\_url | string  | Conditional     | An HTTPS image URL or data\:image/...;base64,...; this page’s example uses an HTTPS URL.                                                                                        |
| images\[].file\_id   | string  | Conditional     | An official Files resource ID; use either this or image\_url. Gateway availability must not be assumed.                                                                         |
| prompt               | string  | Yes             | Clearly describe what to change and preserve.                                                                                                                                   |
| mask                 | object  | No              | For JSON, reference mask.image\_url or mask.file\_id; mask rules vary by model.                                                                                                 |
| image / image\[]     | file    | Yes (multipart) | One or more multipart image fields; do not mix with JSON images.                                                                                                                |
| mask (multipart)     | file    | No              | A PNG mask whose transparent regions mark editing areas; match source dimensions and model requirements.                                                                        |
| input\_fidelity      | string  | No              | Only for models supporting this parameter; not every GPT Image generation accepts it.                                                                                           |
| n                    | integer | No              | Image count; native OpenAI GPT Image supports 1–10, with 1 in the example.                                                                                                      |
| size                 | string  | No              | Native OpenAI form is WIDTHxHEIGHT (width and height divisible by 16, aspect ratio 1\:3–3\:1) or auto; SimiRouter also accepts ratio plus resolution, and limits vary by model. |
| resolution           | string  | No              | SimiRouter extension\: tier 1k, 2k, or 4k used with a ratio, not a pixel value; the native OpenAI API has no such field.                                                        |
| aspect\_ratio        | string  | No              | SimiRouter extension\: separate ratio such as 3\:4; a ratio in size takes precedence.                                                                                           |
| quality              | string  | No              | auto, low, medium, or high; some newer models also support xhigh and max.                                                                                                       |
| output\_format       | string  | No              | png, jpeg (examples), or webp; the official schema also lists gif and svg where the model and project access support them.                                                      |
| output\_compression  | integer | No              | JPEG/WebP compression quality from 0–100; not applicable to PNG.                                                                                                                |
| background           | string  | No              | auto, opaque, or transparent; transparency requires a supported model and PNG/WebP.                                                                                             |
| moderation           | string  | No              | auto or supported low; does not guarantee content-policy approval.                                                                                                              |
| response\_format     | string  | No              | Some compatible models accept url or b64\_json; native GPT Image does not use it.                                                                                               |
| stream               | boolean | No              | true uses image SSE events.                                                                                                                                                     |
| partial\_images      | integer | No              | With stream=true, request 0–3 intermediate images; still wait for the final completion event.                                                                                   |

Choose JSON or multipart. Let the client generate the multipart Content-Type boundary. Masks do not guarantee pixel-perfect edits; inspect final images manually.

## Choosing how to send images

Reference images can enter the request in four ways; choose one according to your environment and do not mix them in one request\:

| Form           | Field                         | When to use                                                  |
| -------------- | ----------------------------- | ------------------------------------------------------------ |
| JSON URL       | `images[].image_url`          | The image is public and server-accessible                    |
| JSON Base64    | `images[].image_url` data URL | The image is small and should not be exposed at a public URL |
| multipart file | `image` or `image[]`          | Local files uploaded directly by the client                  |
| Files ID       | `images[].file_id`            | Uploaded through official Files and supported by the gateway |

JSON requests use `Content-Type: application/json`; for multipart, the client must generate the `Content-Type` boundary; do not write it by hand.

### JSON request structure

The JSON example uses a server-accessible HTTPS image URL directly.

```json
{
  "model": "gpt-image-2",
  "images": [
    {
      "image_url": "https://example.com/reference.png"
    }
  ],
  "prompt": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

### multipart request structure

Use the `image` field for one local reference; use `image[]` for multiple images and describe each image’s role in order\:

```bash
API_URL="https://api.dwchainless.com/v1/images/edits"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -F "model=gpt-image-2" \
  -F "prompt=保留主体和构图，将背景改为浅蓝色。" \
  -F "image=@reference.png" \
  -F "size=1024x1024" \
  -F "n=1"
```

## Writing edit prompts

An edit prompt should state both what to preserve and what to change; just writing “make it watercolor” can make the model redraw the whole scene. Organize it as “preserve + change + constraint”\:

| Scenario                     | Prompt focus                                                        | Example                                                                                                |
| ---------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Preserve a person or product | Keep the subject, pose, composition, and text unchanged             | Keep the person’s pose and clothing; change only the background to pale blue.                          |
| Style transfer               | State the target style and the layout to keep                       | Change to a watercolor illustration style while keeping the original composition and subject position. |
| Local edit                   | Name the region to change; use `mask` when the model supports it    | Change only the cup in the lower-left corner; keep everything else unchanged.                          |
| Multi-image composition      | Describe each image’s role, subject relationships, and final layout | The first image is the person, the second is the scene; place the person in the center of the scene.   |

“Preserve” is a goal, not a pixel-level guarantee; people, products, and text may still change, and identity- or brand-related content must be reviewed manually. Transparency requires model support for `background: transparent` and PNG or WebP output.

## Size and format

`size` sets the model-supported pixel dimensions, such as `1024x1024`; `quality` controls quality and `output_format` controls PNG/JPEG/WebP encoding. The edit result’s dimensions come from `size` (it defaults to `auto`, letting the model choose) and need not match the reference image exactly.

This site’s 1K, 2K, and 4K per-image billing tiers and vendor resolution labels are separate rules; see [Image specifications and billing](/simidoc/en/apps/api/images) for the three ways to write size, the 14-ratio quick reference, and billing boundaries.

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

Example Base64 is a minimal PNG illustrating fields only. A returned data\[].url may expire; do not attach the API key when downloading the image. Streaming edits use image\_edit.partial\_image and image\_edit.completed; only the final event establishes completed editing. Image-to-image does not guarantee pixel-perfect preservation of people, products, or text.

## Code examples

Fill in `API_URL` and `API_KEY` at the top of the code; the examples use `gpt-image-2`. `API_URL` is the full request URL and defaults to the gateway `https://api.dwchainless.com`. `IMAGE_URL` is an HTTPS image URL that the server can access. The examples use standard libraries only, send one request, and print the returned JSON to stdout; they do not save images automatically.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "images": [{"image_url": "https://example.com/reference.png"}],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        images: [
          {
            image_url: 'https://example.com/reference.png',
          },
        ],
        prompt: '保留主体和构图，将背景改为浅蓝色。',
        size: '1024x1024',
        n: 1,
      }),
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/edits"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-image-2",
        "images": [
          {
            "image_url": "https://example.com/reference.png"
          }
        ],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
        apiURL := "https://api.dwchainless.com/v1/images/edits"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "images": [
                {
                    "image_url": "https://example.com/reference.png"
                }
            ],
            "prompt": "保留主体和构图，将背景改为浅蓝色。",
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

## Errors

| HTTP status     | Meaning or vendor error type                           | Action                                                                                                           |
| --------------- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| 400             | Invalid request                                        | Check required fields, JSON, model parameters, and context length.                                               |
| 401             | Authentication failed                                  | Check that the key exists, is valid, and belongs to the correct service.                                         |
| 403 / 404       | Access denied / resource not found                     | Check model permissions, resource IDs, and the URL.                                                              |
| 413             | Request body or image too large                        | Prefer image URLs; reduce Base64 size or image dimensions.                                                       |
| 429             | Rate or quota limit                                    | Distinguish rate limits from insufficient quota using the response body; retrying cannot fix insufficient quota. |
| 500 / 502 / 503 | Server error / busy upstream / temporarily unavailable | Retain the request identifier and use bounded backoff for transient failures.                                    |

Native OpenAI errors usually contain `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` may be `null`; do not assume these fields always exist or equal the HTTP status. The gateway may return authentication, routing, or quota errors before contacting the vendor; the status alone does not establish an upstream error. Invalid images, MIME mismatches, incompatible mask dimensions, or unsupported parameters are input errors; correct them instead of resubmitting unchanged.

Editing can take tens of seconds to minutes; set a sufficient client timeout, since a hanging request is not a failure. After a timeout, broken stream, or 5xx, first confirm whether the request already executed before retrying, to avoid duplicate generation and charges. When content policy rejects a request (usually 400), revise the prompt or reference image instead of retrying unchanged.

## Official reference

* [OpenAI Create image edit](https\://developers.openai.com/api/reference/resources/images/methods/edit)
* [OpenAI image generation and editing](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI error handling](https\://developers.openai.com/api/docs/guides/error-codes)