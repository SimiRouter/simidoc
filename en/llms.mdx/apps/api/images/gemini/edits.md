# Gemini image editing and image-to-image

## Endpoint overview

`POST /v1beta/models/{model}:generateContent` accepts editing instructions and reference images together in parts for editing, image-to-image, style transfer, background replacement, or multi-image composition. There is no separate native `/images/edits` Gemini path.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $API_KEY` . Direct Google access uses `https://generativelanguage.googleapis.com`, usually with `x-goog-api-key: $GEMINI_API_KEY`, not the gateway Bearer key. Select a model available to the account that supports the required capability.

Upload only images you are authorized to process. Editing does not guarantee pixel-perfect preservation of identities, text, trademarks, or product details. Manually inspect important content before use.

## Request parameters

| Field                                    | Type   | Required                     | Description                                                                                               |
| ---------------------------------------- | ------ | ---------------------------- | --------------------------------------------------------------------------------------------------------- |
| model (path)                             | string | Yes                          | A Gemini image model supporting both generateContent and image output; not a text-only model.             |
| contents                                 | array  | Yes                          | Message list; text-to-image usually needs one user message.                                               |
| contents\[].role                         | string | No                           | user; use model for model replies in conversation history.                                                |
| contents\[].parts\[].text                | string | Yes                          | Image description or editing instructions.                                                                |
| generationConfig.responseModalities      | array  | No                           | For example, \["TEXT","IMAGE"] to request text and images; available combinations vary by model.          |
| generationConfig.imageConfig.aspectRatio | string | No                           | Ratios such as 1\:1, 16\:9, 9\:16 where supported.                                                        |
| generationConfig.imageConfig.imageSize   | string | No                           | Sizes such as 1K, 2K, or 4K where supported; match the selected model. Not all image models support them. |
| contents\[].parts\[].inlineData          | object | Yes (inline reference image) | A separate Part from text, containing mimeType and data.                                                  |
| inlineData.mimeType                      | string | Yes                          | The reference image’s actual MIME type, such as image/png, image/jpeg, or image/webp.                     |
| inlineData.data                          | string | Yes                          | Pure Base64 reference-file bytes, without a data\: prefix.                                                |
| contents\[].parts\[].fileData            | object | Conditional                  | An alternative to inline content, requiring an authorized fileUri/mimeType accessible to the vendor.      |

Use one Part per image. Add image Parts for multiple references and explain each image’s purpose in text. Image-count, resolution, and multi-turn consistency limits vary by model; one fixed number does not cover every Gemini image model.

### Image specifications\: 1K, 2K and 4K

K is a common resolution label, not file size or a quality setting. Actual dimensions depend on the model and aspect ratio. At the same ratio, doubling both edges quadruples the pixel count. The examples below explain the terms; they are not universally accepted sizes.

Where supported, Gemini uses `generationConfig.imageConfig.imageSize` to select `1K`, `2K` or `4K`, and `generationConfig.imageConfig.aspectRatio` for the ratio. Check the selected model for actual dimensions.

| Resolution label | Common pixel examples (not a model support guarantee)       |
| ---------------- | ----------------------------------------------------------- |
| 1K               | 1024×1024 · About one thousand pixels per edge              |
| 2K               | 2048×2048 · About two thousand pixels per edge              |
| 4K               | 4096×4096 / 3840×2160 · About four thousand pixels per edge |

The site’s per-image billing tiers are separate rules; do not use these illustrative resolution labels as the billing standard. [Image specifications and billing rules](/simidoc/en/apps/api/images).

### Request structure

Replace `BASE64_IMAGE_BYTES` with the pure Base64 of the authorized image.

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。"
        },
        {
          "inlineData": {
            "mimeType": "image/png",
            "data": "BASE64_IMAGE_BYTES"
          }
        }
      ]
    }
  ],
  "generationConfig": {
    "responseModalities": [
      "TEXT",
      "IMAGE"
    ]
  }
}
```

## Response

| Field                          | Type    | Description                                                                                                       |
| ------------------------------ | ------- | ----------------------------------------------------------------------------------------------------------------- |
| candidates\[]                  | array   | Candidate list; may be empty after safety filtering.                                                              |
| candidates\[].content.parts\[] | array   | Ordered text, image, or thinking parts; do not read only the first item.                                          |
| parts\[].text                  | string  | Explanatory text; its presence is model-dependent.                                                                |
| parts\[].inlineData.mimeType   | string  | The actual image MIME type, such as image/png or image/jpeg.                                                      |
| parts\[].inlineData.data       | string  | Pure Base64 image data, without a data\: prefix.                                                                  |
| parts\[].thought               | boolean | Optional thinking-part flag; do not treat thought=true intermediate images as final output.                       |
| parts\[].thoughtSignature      | string  | Optional opaque signature; preserve it unchanged for multi-turn editing rather than constructing or modifying it. |
| candidates\[].finishReason     | string  | STOP means normal completion; handle MAX\_TOKENS, SAFETY, and other reasons separately.                           |
| promptFeedback                 | object  | Optional input-blocking information.                                                                              |
| usageMetadata                  | object  | Input, candidate, thinking, and total token usage; fields vary by model.                                          |

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "已根据描述生成图片。"
          },
          {
            "inlineData": {
              "mimeType": "image/png",
              "data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
            }
          }
        ]
      },
      "finishReason": "STOP"
    }
  ]
}
```

The Base64 above illustrates structure only. Use the actual MIME type when saving results. For multi-turn editing, append the complete previous model content to history, preserve opaque fields such as thoughtSignature, then add the next user edit. Do not copy image bytes alone and discard required signatures or modify those fields.

Native Gemini editing describes regions in natural language; OpenAI’s mask is not a universal parameter here. For precise region constraints, verify the selected model’s input support rather than inferring equivalent fields.

## Code examples

Fill in `API_URL` and `API_KEY` at the top of the code; the examples use `gemini-3-pro-image` and replace `BASE64_IMAGE_BYTES` with the pure Base64 of the authorized image (no data\: prefix). `API_URL` is the full request URL and defaults to the gateway `https://api.dwchainless.com`. The examples use standard libraries only, send one request, and print the returned JSON to stdout; they do not save images automatically.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY = "PASTE_API_KEY_HERE"
    IMAGE_BASE64 = "BASE64_IMAGE_BYTES"
    body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "保留主体和构图，将背景改为浅蓝色。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": IMAGE_BASE64
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "responseModalities": [
          "TEXT",
          "IMAGE"
        ]
      }
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
    const API_URL = 'https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const IMAGE_BASE64 = 'BASE64_IMAGE_BYTES';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '保留主体和构图，将背景改为浅蓝色。'
              },
              {
                inlineData: {
                  mimeType: 'image/png',
                  data: IMAGE_BASE64
                }
              }
            ]
          }
        ],
        generationConfig: {
          responseModalities: [
            'TEXT',
            'IMAGE'
          ]
        }
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY="PASTE_API_KEY_HERE"
    IMAGE_BASE64="BASE64_IMAGE_BYTES"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary @- <<JSON
      {
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              },
              {
                "inlineData": {
                  "mimeType": "image/png",
                  "data": "$IMAGE_BASE64"
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "responseModalities": [
            "TEXT",
            "IMAGE"
          ]
        }
      }
    JSON
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "contents": [
                {
                    "role": "user",
                    "parts": [
                        {
                            "text": "保留主体和构图，将背景改为浅蓝色。"
                        },
                        {
                            "inlineData": {
                                "mimeType": "image/png",
                                "data": "BASE64_IMAGE_BYTES"
                            }
                        }
                    ]
                }
            ],
            "generationConfig": {
                "responseModalities": [
                    "TEXT",
                    "IMAGE"
                ]
            }
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

Copy this task to an agent that can run local scripts and inspect the response. Fill in API\_URL, API\_KEY, and MODEL directly in the example first using [the protocol configuration](/simidoc/en/apps/api/images/gemini). Never put the key in the prompt.

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

## Errors

| HTTP status | Meaning or vendor error type          | Action                                                                          |
| ----------- | ------------------------------------- | ------------------------------------------------------------------------------- |
| 400         | `INVALID_ARGUMENT` and similar errors | Check JSON, model parameters, media MIME type, and input length.                |
| 403         | `PERMISSION_DENIED`                   | Check the key, project permissions, region, or billing restrictions.            |
| 404         | `NOT_FOUND`                           | Check the model name and API version.                                           |
| 429         | `RESOURCE_EXHAUSTED`                  | Check rate limits and quotas; use bounded backoff when retrying is appropriate. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`            | Record the request identifier and retry a limited number of times or later.     |

Google’s native error object contains `error.code` (HTTP number), `error.status` (enum name), and `error.message`, optionally with `details`. The gateway may return authentication, routing, or quota errors before contacting the vendor; an HTTP number alone does not establish an upstream error. Handle model refusals, missing images, non-STOP termination, and HTTP errors separately. Never pass off the input image as an edited result.

## Official reference

* [Google image generation and editing](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google image understanding and media input](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Google troubleshooting](https\://ai.google.dev/gemini-api/docs/troubleshooting)