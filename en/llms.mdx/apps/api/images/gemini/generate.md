# Gemini image generation

## Endpoint overview

`POST /v1beta/models/{model}:generateContent` generates images with a Gemini model supporting image output; results may interleave text and images.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $API_KEY` . Direct Google access uses `https://generativelanguage.googleapis.com`, usually with `x-goog-api-key: $GEMINI_API_KEY`, not the gateway Bearer key. Select a model available to the account that supports the required capability.

This page uses GenerateContent REST. Google also offers Interactions image workflows, but their input, steps, and response\_format are not the same as contents, candidates, and generationConfig here; do not mix them.

## Request parameters

| Field                                    | Type   | Required | Description                                                                                               |
| ---------------------------------------- | ------ | -------- | --------------------------------------------------------------------------------------------------------- |
| model (path)                             | string | Yes      | A Gemini image model supporting both generateContent and image output; not a text-only model.             |
| contents                                 | array  | Yes      | Message list; text-to-image usually needs one user message.                                               |
| contents\[].role                         | string | No       | user; use model for model replies in conversation history.                                                |
| contents\[].parts\[].text                | string | Yes      | Image description or editing instructions.                                                                |
| generationConfig.responseModalities      | array  | No       | For example, \["TEXT","IMAGE"] to request text and images; available combinations vary by model.          |
| generationConfig.imageConfig.aspectRatio | string | No       | Ratios such as 1\:1, 16\:9, 9\:16 where supported.                                                        |
| generationConfig.imageConfig.imageSize   | string | No       | Sizes such as 1K, 2K, or 4K where supported; match the selected model. Not all image models support them. |

Omit unnecessary optional settings. Adding imageConfig to a text-only model does not grant image capabilities. New native generateContent output-format settings may differ from older image-model support; this page retains a clear responseModalities protocol example.

### Image specifications\: 1K, 2K and 4K

K is a common resolution label, not file size or a quality setting. Actual dimensions depend on the model and aspect ratio. At the same ratio, doubling both edges quadruples the pixel count. The examples below explain the terms; they are not universally accepted sizes.

Where supported, Gemini uses `generationConfig.imageConfig.imageSize` to select `1K`, `2K` or `4K`, and `generationConfig.imageConfig.aspectRatio` for the ratio. Check the selected model for actual dimensions.

| Resolution label | Common pixel examples (not a model support guarantee)       |
| ---------------- | ----------------------------------------------------------- |
| 1K               | 1024×1024 · About one thousand pixels per edge              |
| 2K               | 2048×2048 · About two thousand pixels per edge              |
| 4K               | 4096×4096 / 3840×2160 · About four thousand pixels per edge |

The site’s per-image billing tiers are separate rules; do not use these illustrative resolution labels as the billing standard. [Image specifications and billing rules](/simidoc/en/apps/api/images).

### Request example

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。"
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

The Base64 below is a minimal PNG illustrating response structure, not a real result generated from the prompt above.

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

Iterate through parts in order, read non-thought inlineData images, and select file extensions by mimeType. Do not assume parts\[0] is an image. Responses may contain only text or no images after filtering; report that no image was generated in those cases.

### Streaming and batches

Streaming-capable models can use streamGenerateContent?alt=sse, but image fragments may not be independently decodable final files; follow the selected model’s event format. generateContent is synchronous and returns no pollable task. Google’s official Batch API is a separate asynchronous service; gateway generation endpoints are not batch endpoints.

## Code examples

Fill in `API_URL` and `API_KEY` at the top of the code; the examples use `gemini-3-pro-image`. `API_URL` is the full request URL and defaults to the gateway `https://api.dwchainless.com`. The examples use standard libraries only, send one request, and print the returned JSON to stdout; they do not save images automatically.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
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
                text: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。'
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
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
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
      }'
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
                            "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
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

## Errors

| HTTP status | Meaning or vendor error type          | Action                                                                          |
| ----------- | ------------------------------------- | ------------------------------------------------------------------------------- |
| 400         | `INVALID_ARGUMENT` and similar errors | Check JSON, model parameters, media MIME type, and input length.                |
| 403         | `PERMISSION_DENIED`                   | Check the key, project permissions, region, or billing restrictions.            |
| 404         | `NOT_FOUND`                           | Check the model name and API version.                                           |
| 429         | `RESOURCE_EXHAUSTED`                  | Check rate limits and quotas; use bounded backoff when retrying is appropriate. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`            | Record the request identifier and retry a limited number of times or later.     |

Google’s native error object contains `error.code` (HTTP number), `error.status` (enum name), and `error.message`, optionally with `details`. The gateway may return authentication, routing, or quota errors before contacting the vendor; an HTTP number alone does not establish an upstream error. HTTP 200 without a non-thought image must not be labeled successful image generation based on text alone.

## Official reference

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google image generation and editing](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Google model catalog](https\://ai.google.dev/gemini-api/docs/models)
* [Google troubleshooting](https\://ai.google.dev/gemini-api/docs/troubleshooting)