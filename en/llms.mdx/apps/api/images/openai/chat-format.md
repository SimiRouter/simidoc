# Conversational image generation

## Endpoint overview

`POST /v1/responses` declares image\_generation in tools so a tool-capable main model can generate images from input. The main model is a conversation model; choose actual image-tool model settings within the official current support range.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $API_KEY`. Direct OpenAI access uses `https://api.openai.com` and Bearer authentication, but requires an OpenAI key. Select a model available to the account that supports the required capability.

Native OpenAI conversational image generation uses Responses image\_generation, not a convention of Markdown image links from ordinary Chat Completions. Compatible vendors returning image links through Chat use their own extensions, not the OpenAI standard.

## Request parameters

| Field                                | Type            | Required | Description                                                                                                              |
| ------------------------------------ | --------------- | -------- | ------------------------------------------------------------------------------------------------------------------------ |
| model                                | string          | Yes      | A Responses main model supporting image\_generation.                                                                     |
| input                                | string / array  | Yes      | A text prompt; editing may include input\_image.                                                                         |
| tools\[].type                        | string          | Yes      | image\_generation.                                                                                                       |
| tools\[].output\_format              | string          | No       | png, jpeg, or webp; the example uses png.                                                                                |
| tools\[].size / quality / background | string          | No       | Size, quality, and background settings supported by the tool.                                                            |
| tool\_choice                         | string / object | No       | auto lets the model decide whether to generate; force a tool using its supported selection format.                       |
| previous\_response\_id               | string          | No       | Continue a retained upstream response within the same accessible context; the gateway has no general retrieval endpoint. |
| stream                               | boolean         | No       | true uses the Responses event stream.                                                                                    |

### Request example

```json
{
  "model": "gpt-5.5",
  "input": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。",
  "tools": [
    {
      "type": "image_generation",
      "model": "gpt-image-2",
      "output_format": "png"
    }
  ],
  "stream": false
}
```

## Response

| Field                       | Type          | Description                                                                    |
| --------------------------- | ------------- | ------------------------------------------------------------------------------ |
| id / status                 | string        | Response ID and final state; completed indicates a complete response.          |
| output\[].type              | string        | Image tool results use image\_generation\_call; message items may also appear. |
| output\[].id / status       | string        | Image-call ID and tool execution status.                                       |
| output\[].result            | string        | Base64 of the final image-call result, not data\[].b64\_json.                  |
| output\[].revised\_prompt   | string        | The image tool’s revised prompt, where supported.                              |
| output\[].content\[].text   | string        | Optional explanatory text in message items.                                    |
| usage                       | object        | Main-model usage; image-tool charges must not be treated as text tokens alone. |
| error / incomplete\_details | object / null | Failure and incomplete reasons.                                                |

```json
{
  "id": "resp_image_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ig_example",
      "type": "image_generation_call",
      "status": "completed",
      "result": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "error": null,
  "incomplete_details": null
}
```

The Base64 here is a minimal PNG illustrating structure only. For subsequent edits, send the image as input\_image with new instructions, or use previous\_response\_id where supported and context is retained. Arbitrary response IDs are not cross-channel file resources.

## Code examples

Fill in `API_URL` and `API_KEY` at the top of the code; the examples use `gpt-5.5` as the main model and `gpt-image-2` as the image tool model. `API_URL` is the full request URL and defaults to the gateway `https://api.dwchainless.com`. The examples use standard libraries only, send one request, and print the returned JSON to stdout; they do not save images automatically.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/responses"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
      "tools": [
        {
          "type": "image_generation",
          "model": "gpt-image-2"
        }
      ]
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
    const API_URL = 'https://api.dwchainless.com/v1/responses';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        input: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。',
        tools: [
          {
            type: 'image_generation',
            model: 'gpt-image-2'
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/responses"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
        "tools": [
          {
            "type": "image_generation",
            "model": "gpt-image-2"
          }
        ]
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/responses"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
            "tools": [
                {
                    "type": "image_generation",
                    "model": "gpt-image-2"
                }
            ]
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

## Errors

| HTTP status | Meaning or vendor error type           | Action                                                                                                           |
| ----------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| 400         | Invalid request                        | Check required fields, JSON, model parameters, and context length.                                               |
| 401         | Authentication failed                  | Check that the key exists, is valid, and belongs to the correct service.                                         |
| 403 / 404   | Access denied / resource not found     | Check model permissions, resource IDs, and the URL.                                                              |
| 429         | Rate or quota limit                    | Distinguish rate limits from insufficient quota using the response body; retrying cannot fix insufficient quota. |
| 500 / 503   | Server error / temporarily unavailable | Retain the request identifier and use bounded backoff for transient failures.                                    |

Native OpenAI errors usually contain `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` may be `null`; do not assume these fields always exist or equal the HTTP status. The gateway may return authentication, routing, or quota errors before contacting the vendor; the status alone does not establish an upstream error. A completed main response without image\_generation\_call.result may contain only text. Check tool selection and returned items; never fabricate an image result.

## Official reference

* [OpenAI conversational image generation](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI error handling](https\://developers.openai.com/api/docs/guides/error-codes)