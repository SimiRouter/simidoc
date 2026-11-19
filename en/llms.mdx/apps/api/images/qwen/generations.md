# Qwen image generation

## Endpoint overview

`POST /v1/images/generations`, with a JSON body. The examples use this site's gateway `https://api.dwchainless.com` and a key from this site for `API_KEY`; the request body follows Qwen's native `model`, `input.messages`, and `parameters` structure, and the response is always `data[]`.

Text-to-image needs only text content items. Describe composition, visual style, and text to render in the input text.

## Request parameters

| Field                             | Type      | Required | Description                                                                                          |
| --------------------------------- | --------- | -------- | ---------------------------------------------------------------------------------------------------- |
| model                             | string    | Yes      | qwen-image-2.0-pro or a specific version supported by this site's channel.                           |
| input.messages                    | object\[] | Yes      | A single-round user message, exactly one.                                                            |
| input.messages\[].role            | string    | Yes      | Always user.                                                                                         |
| input.messages\[].content\[].text | string    | Yes      | Chinese or English instructions; only one text item per turn.                                        |
| parameters.size                   | string    | No       | Width × height, such as 2048 × 2048; the 2.0 series supports total pixels from 512×512 to 2048×2048. |
| parameters.n                      | integer   | No       | Default 1; the 2.0 series supports 1–6.                                                              |
| parameters.negative\_prompt       | string    | No       | Content you do not want, up to 500 characters.                                                       |
| parameters.prompt\_extend         | boolean   | No       | Default true; automatically expands the positive prompt.                                             |
| parameters.watermark              | boolean   | No       | Whether to add a visible watermark; follow applicable synthetic-content labeling requirements.       |

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
{"created":1760000000,"data":[{"url":"https://example.com/generated.png","b64_json":null,"revised_prompt":"..."}]}
```

## Code examples

Fill in `API_URL` and `API_KEY` at the top of the code. `API_URL` uses this site's gateway address `https://api.dwchainless.com/v1/images/generations`, `API_KEY` uses a key from this site, and model availability is subject to [Models and pricing](https://api.dwchainless.com/en/pricing/). The examples use standard libraries only, send one request, and print the returned JSON; they do not download or save images automatically.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/generations"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "qwen-image-2.0-pro",
      "input": {
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "text": "生成一张浅蓝色背景的活动海报，不要文字。"
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
    const API_URL = 'https://api.dwchainless.com/v1/images/generations';
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
                  text: '生成一张浅蓝色背景的活动海报，不要文字。'
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
    API_URL="https://api.dwchainless.com/v1/images/generations"
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
                  "text": "生成一张浅蓝色背景的活动海报，不要文字。"
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
        apiURL := "https://api.dwchainless.com/v1/images/generations"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "qwen-image-2.0-pro",
            "input": {
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "text": "生成一张浅蓝色背景的活动海报，不要文字。"
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

## Errors

| Error                  | Action                                                                                         |
| ---------------------- | ---------------------------------------------------------------------------------------------- |
| 400 / InvalidParameter | Check the JSON, content structure, image specifications, size, and model-supported parameters. |
| 401                    | Check that this site's API Key exists, is valid, and belongs to the right account.             |
| 403 / 404              | Check model permissions, the channel, and whether the resource exists.                         |
| 429                    | Rate limited or insufficient quota; confirm the cause before retrying with backoff.            |
| 5xx                    | Service error; record the request identifier and avoid unlimited repeated generation.          |

## Official reference

[Qwen-Image generation](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api), [Model Studio error codes](https\://www.alibabacloud.com/help/en/model-studio/error-code).