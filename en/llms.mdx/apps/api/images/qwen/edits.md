# Qwen image editing

## Endpoint overview

`POST /v1/images/edits`, with a JSON body. The examples use this site's gateway `https://api.dwchainless.com` and a key from this site for `API_KEY`; the request body follows Qwen's native `model`, `input.messages`, and `parameters` structure, and the response is always `data[]`.

Image editing places an image item and one text modification instruction in content; do not use the multipart file field.

## Request parameters

| Field                              | Type      | Required | Description                                                                                                        |
| ---------------------------------- | --------- | -------- | ------------------------------------------------------------------------------------------------------------------ |
| model                              | string    | Yes      | qwen-image-2.0-pro or a specific version supported by this site's channel.                                         |
| input.messages                     | object\[] | Yes      | A single-round user message, exactly one.                                                                          |
| input.messages\[].role             | string    | Yes      | Always user.                                                                                                       |
| input.messages\[].content\[].text  | string    | Yes      | Chinese or English instructions; only one text item per turn.                                                      |
| input.messages\[].content\[].image | string    | Yes      | Accessible URL / data URL for one or more reference images. Input count and pixel limits follow the model version. |
| parameters.size                    | string    | No       | Width × height, such as 2048 × 2048; the 2.0 series supports total pixels from 512×512 to 2048×2048.               |
| parameters.n                       | integer   | No       | Default 1; the 2.0 series supports 1–6.                                                                            |
| parameters.negative\_prompt        | string    | No       | Content you do not want, up to 500 characters.                                                                     |
| parameters.prompt\_extend          | boolean   | No       | Default true; automatically expands the positive prompt.                                                           |
| parameters.watermark               | boolean   | No       | Whether to add a visible watermark; follow applicable synthetic-content labeling requirements.                     |

### Image specifications\: 1K, 2K and 4K

K is a common shorthand for resolution; it is not file size and does not indicate a quality parameter. Actual width and height vary by model and aspect ratio; at the same ratio, doubling the edge length quadruples total pixels. The following is background only and must not be treated directly as the available sizes for every model.

Qwen uses `parameters.size` to enter the width and height allowed by the model, in a format such as `2048*2048`, not `2K` directly. The 2.0 series also has a total-pixel limit; the 4K square illustration below does not mean that size can be submitted.

| Resolution label | Common pixel illustration (not a model support guarantee) |
| ---------------- | --------------------------------------------------------- |
| 1K               | Both edges ≤ 1024 pixels; e.g. 1024×1024.                 |
| 2K               | Longest edge > 1024 and ≤ 2048 pixels; e.g. 1280×720.     |
| 4K               | Either edge > 2048 pixels; e.g. 2560×1440.                |

This site's per-image billing tiers are a separate rule; do not apply the illustrative labels above directly as billing standards. [Image specifications and billing rules](/simidoc/en/apps/api/images).

## Response

| Field                   | Description                                                                               |
| ----------------------- | ----------------------------------------------------------------------------------------- |
| `created`               | Response generation timestamp.                                                            |
| `data[].url`            | Generated image URL; validity is determined by the channel, so download or copy promptly. |
| `data[].b64_json`       | Some channels return raw Base64; when present, decode and save directly.                  |
| `data[].revised_prompt` | Prompt rewritten by the channel; may be absent.                                           |
| `error` / `message`     | Error code and description on failure.                                                    |

```json
{"created":1760000000,"data":[{"url":"https://example.com/edited.png","b64_json":null,"revised_prompt":"..."}]}
```

## Code examples

Fill in `API_URL` and `API_KEY` at the top of the code. `API_URL` uses this site's gateway address `https://api.dwchainless.com/v1/images/edits`, and `API_KEY` uses a key from this site. The examples use standard libraries only, send one request, and print the returned JSON; they do not download or save images automatically.

Set `IMAGE_URL` to a real, authorized, cloud-accessible HTTP(S) image address. The code checks URL form only and does not prove the image is downloadable or meets the channel's format limits; do not use local paths, localhost, login-protected pages, or fake links.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "qwen-image-2.0-pro",
      "input": {
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "image": "https://example.com/reference.png"
              },
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              }
            ]
          }
        ]
      },
      "parameters": {
        "size": "1024*1024",
        "n": 1
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'qwen-image-2.0-pro',
        input: {
          messages: [
            {
              role: 'user',
              content: [
                {
                  image: 'https://example.com/reference.png'
                },
                {
                  text: '保留主体和构图，将背景改为浅蓝色。'
                }
              ]
            }
          ]
        },
        parameters: {
          size: '1024*1024',
          n: 1
        }
      })
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
        "model": "qwen-image-2.0-pro",
        "input": {
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "image": "https://example.com/reference.png"
                },
                {
                  "text": "保留主体和构图，将背景改为浅蓝色。"
                }
              ]
            }
          ]
        },
        "parameters": {
          "size": "1024*1024",
          "n": 1
        }
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
            "model": "qwen-image-2.0-pro",
            "input": {
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "image": "https://example.com/reference.png"
                            },
                            {
                                "text": "保留主体和构图，将背景改为浅蓝色。"
                            }
                        ]
                    }
                ]
            },
            "parameters": {
                "size": "1024*1024",
                "n": 1
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

Copy the task below to an agent that can run code locally and inspect returned results; first fill in API\_URL and API\_KEY directly in the example code according to [this protocol configuration](/simidoc/en/apps/api/images/qwen) and confirm the model name. Do not put the key in the prompt.

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

## Errors

| Error                  | Action                                                                                          |
| ---------------------- | ----------------------------------------------------------------------------------------------- |
| 400 / InvalidParameter | Check the content structure, image specifications, output size, and model-supported parameters. |
| 401                    | Check that this site's API Key exists, is valid, and belongs to the right account.              |
| 403 / 404              | Check model permissions, the channel, and whether the resource exists.                          |
| 429                    | Rate limited or insufficient quota; confirm the cause before retrying with backoff.             |
| 5xx                    | Service error; record the request identifier and avoid unlimited repeated generation.           |

## Official reference

[Qwen-Image editing](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api), [Model Studio error codes](https\://www.alibabacloud.com/help/en/model-studio/error-code).