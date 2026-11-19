# Image understanding

## Endpoint overview

`POST /v1/chat/completions` combines a text question and images in a user message and returns textual analysis. Image understanding is not generation or editing.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $API_KEY`. Direct OpenAI access uses `https://api.openai.com` and Bearer authentication, but requires an OpenAI key. Select a model available to the account that supports the required capability.

Images can use accessible HTTPS URLs or data URLs containing actual media bytes. Examples use an accessible HTTPS image URL.

## Request parameters

| Field                       | Type    | Required    | Description                                                         |
| --------------------------- | ------- | ----------- | ------------------------------------------------------------------- |
| model                       | string  | Yes         | A chat model supporting vision input.                               |
| messages\[].role            | string  | Yes         | Image messages use user.                                            |
| messages\[].content         | array   | Yes         | Include at least a question and an image content item.              |
| content\[].type=text / text | string  | Conditional | The text-question content item.                                     |
| content\[].type=image\_url  | string  | Conditional | Declares an image content item.                                     |
| image\_url.url              | string  | Yes         | An HTTPS URL or data\:image/\{format};base64,...; not a local path. |
| image\_url.detail           | string  | No          | Model-supported detail options such as auto, low, or high.          |
| max\_completion\_tokens     | integer | No          | The output token limit.                                             |
| stream                      | boolean | No          | true returns Chat SSE.                                              |

Use matching MIME types for PNG, JPEG, WebP, and other supported formats. Image count, pixel limits, and request size must meet model requirements. Do not relabel animated GIFs, videos, or arbitrary binary data as image/png.

### Request structure

```json
{
  "model": "gpt-5.5",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "描述图片中的主要物体，并指出无法确定的细节。"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/png;base64,BASE64_IMAGE_BYTES",
            "detail": "auto"
          }
        }
      ]
    }
  ],
  "max_completion_tokens": 512,
  "stream": false
}
```

## Response

| Field                          | Type             | Description                                                                                                                                         |
| ------------------------------ | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| id / object                    | string           | Response ID; object=chat.completion.                                                                                                                |
| created / model                | integer / string | Creation time in Unix seconds and the responding model.                                                                                             |
| choices\[]                     | array            | Candidate replies; each index identifies its position.                                                                                              |
| choices\[].message.role        | string           | assistant.                                                                                                                                          |
| choices\[].message.content     | string / null    | Reply text; may be empty for tool calls or refusals, which does not itself mean the request failed.                                                 |
| choices\[].message.tool\_calls | array            | Function calls for the application to execute. arguments is a JSON string that must be parsed and validated.                                        |
| choices\[].message.refusal     | string / null    | Refusal information, if present.                                                                                                                    |
| choices\[].finish\_reason      | string           | stop means normal completion; length means the limit was reached; tool\_calls requests tool execution; content\_filter indicates content filtering. |
| usage.prompt\_tokens           | integer          | Input tokens.                                                                                                                                       |
| usage.completion\_tokens       | integer          | Generated tokens, possibly including reasoning tokens.                                                                                              |
| usage.total\_tokens            | integer          | Total input and generated tokens.                                                                                                                   |
| usage.\*\_tokens\_details      | object           | Optional usage details such as cached\_tokens and reasoning\_tokens.                                                                                |

```json
{
  "id": "chatcmpl_vision_example",
  "object": "chat.completion",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "图中可见一张桌子和一个杯子，杯内物品无法确认。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 280,
    "completion_tokens": 30,
    "total_tokens": 310
  }
}
```

Add image\_url items for multiple images. Specify their order and comparison goals in text. Merge Chat delta.content when streaming. Do not rely solely on vision output for small text, exact counts, identity, or high-risk judgments.

## Code examples

Fill in `API_URL` and `API_KEY` at the top of the code; the examples use `gpt-5.5`. `API_URL` is the full request URL and defaults to the gateway `https://api.dwchainless.com`. `IMAGE_URL` is an HTTPS image URL that the server can access. The examples use standard libraries only, send one request, and print the returned JSON to stdout; they do not save images automatically.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/chat/completions"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "描述图片中的主要物体。"
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "https://example.com/reference.png"
              }
            }
          ]
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
    const API_URL = 'https://api.dwchainless.com/v1/chat/completions';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: '描述图片中的主要物体。'
              },
              {
                type: 'image_url',
                image_url: {
                  url: 'https://example.com/reference.png'
                }
              }
            ]
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/chat/completions"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "描述图片中的主要物体。"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "https://example.com/reference.png"
                }
              }
            ]
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
        apiURL := "https://api.dwchainless.com/v1/chat/completions"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "描述图片中的主要物体。"
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": "https://example.com/reference.png"
                            }
                        }
                    ]
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

Native OpenAI errors usually contain `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` may be `null`; do not assume these fields always exist or equal the HTTP status. The gateway may return authentication, routing, or quota errors before contacting the vendor; the status alone does not establish an upstream error.

## Official reference

* [OpenAI images and vision](https\://developers.openai.com/api/docs/guides/images-vision)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI error handling](https\://developers.openai.com/api/docs/guides/error-codes)