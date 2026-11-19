# Gemini 图片生成

## 接口说明

`POST /v1beta/models/{model}:generateContent` 使用支持图像输出的 Gemini 模型生成图片，输出可以包含交错的文字和图片。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $API_KEY`。Google 官方直连为 `https://generativelanguage.googleapis.com`，通常使用 `x-goog-api-key: $GEMINI_API_KEY`，不是网关的 Bearer Key。 模型名称应选用账户可访问且支持目标能力的模型。

本页使用 GenerateContent REST 协议。Google 也提供 Interactions API 的图像工作流，但其 input、steps、response\_format 与这里的 contents、candidates、generationConfig 不是相同结构，不能混写。

## 请求参数

| 字段                                       | 类型     | 必填 | 说明                                                 |
| ---------------------------------------- | ------ | -- | -------------------------------------------------- |
| model（路径）                                | string | 是  | 同时支持 generateContent 和图像输出的 Gemini 图像模型；不要使用纯文本模型。 |
| contents                                 | array  | 是  | 消息列表；文生图通常只需一条 user 消息。                            |
| contents\[].role                         | string | 否  | user；多轮历史中的模型回复使用 model。                           |
| contents\[].parts\[].text                | string | 是  | 图片描述或编辑指令。                                         |
| generationConfig.responseModalities      | array  | 否  | 如 \["TEXT","IMAGE"]，请求文本与图片输出；可用组合随模型变化。           |
| generationConfig.imageConfig.aspectRatio | string | 否  | 支持时可用 1\:1、16\:9、9\:16 等比例。                        |
| generationConfig.imageConfig.imageSize   | string | 否  | 支持时设置 1K、2K、4K 等，必须匹配选定模型；不是所有图像模型都支持。             |

省略不需要的可选设置；不要给纯文本模型添加 imageConfig 后期待自动获得图像能力。Google 原生 generateContent 的新输出格式配置与旧图像模型支持范围可能不同，本页保留 responseModalities 的清晰协议示例。

### 图片规格：1K、2K、4K

K 是分辨率的常用简称，不是文件大小，也不表示质量参数。实际宽高随模型与比例变化；同一比例下边长翻倍，总像素为四倍。以下仅作科普，不能直接当作所有模型的可用尺寸。

Gemini 在模型支持时，用 `generationConfig.imageConfig.imageSize` 选择 `1K`、`2K`、`4K`，并以 `generationConfig.imageConfig.aspectRatio` 选择比例；实际输出宽高须查所选模型。

| 分辨率称呼 | 常见像素示意（不是模型支持承诺）                   |
| ----- | ---------------------------------- |
| 1K    | 两边均 ≤ 1024 像素；如 1024×1024。         |
| 2K    | 最长边 > 1024 且 ≤ 2048 像素；如 1280×720。 |
| 4K    | 任一边 > 2048 像素；如 2560×1440。         |

本站按张计费档位是另一套规则，不能把上面的科普示意直接套为收费标准。 [图片规格与计费规则](/simidoc/zh/apps/api/images)。

### 请求示例

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

## 返回值

| 字段                             | 类型      | 说明                                    |
| ------------------------------ | ------- | ------------------------------------- |
| candidates\[]                  | array   | 候选列表，安全过滤时可能为空。                       |
| candidates\[].content.parts\[] | array   | 有序的文本、图像或思考片段，不应只读第一项。                |
| parts\[].text                  | string  | 说明文字，出现与否由模型决定。                       |
| parts\[].inlineData.mimeType   | string  | 图像实际 MIME，如 image/png 或 image/jpeg。   |
| parts\[].inlineData.data       | string  | 纯 Base64 图像数据，不带 data\: 前缀。           |
| parts\[].thought               | boolean | 可选思考片段标志；不应将 thought=true 的中间图当作最终图片。 |
| parts\[].thoughtSignature      | string  | 可选不透明签名；多轮编辑时原样保留，不应自行构造或修改。          |
| candidates\[].finishReason     | string  | STOP 正常完成，MAX\_TOKENS、SAFETY 等需区分处理。  |
| promptFeedback                 | object  | 可选输入拦截信息。                             |
| usageMetadata                  | object  | 输入、候选、思考及总 Token 用量，字段随模型出现。          |

以下 Base64 为最小 PNG，只展示返回结构，不是上述提示的真实生成结果。

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

按 parts 顺序遍历，读取非 thought 的 inlineData 图片并按 mimeType 选择文件扩展名；不能固定假设 parts\[0] 是图片。响应可能只有文本或被过滤而没有图像，此时应报告未生成图片。

### 流式与批量

支持流式输出的模型可使用 streamGenerateContent?alt=sse，但图像片段不一定是可独立解码的最终文件，应遵循所选模型的事件格式。generateContent 本身是同步生成，不返回可轮询任务。Google 官方 Batch API 是独立异步服务，不能把网关生成端点当成批任务端点。

## 代码调用

在代码顶部填写 `API_URL`、`API_KEY`，示例使用 `gemini-3-pro-image`。`API_URL` 是完整请求地址，默认使用网关 `https://api.dwchainless.com`。示例只用标准库，发送一次请求并把返回 JSON 打印到标准输出，不自动保存图片。

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

## 智能体调用 Demo

复制下面的任务给具备本地执行和返回结果检查能力的智能体；先按[本协议配置](/simidoc/zh/apps/api/images/gemini)直接在示例代码中填写 API\_URL、API\_KEY 和 MODEL。不要把密钥写进提示词。

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

## 错误码

| HTTP 状态   | 含义或厂商错误类型                  | 处理方式                        |
| --------- | -------------------------- | --------------------------- |
| 400       | `INVALID_ARGUMENT` 等       | 检查 JSON、模型参数、媒体 MIME 和输入长度。 |
| 403       | `PERMISSION_DENIED`        | 检查 Key、项目权限、区域或账单限制。        |
| 404       | `NOT_FOUND`                | 检查模型名和 API 版本。              |
| 429       | `RESOURCE_EXHAUSTED`       | 检查限流与配额；可重试情况采用有限次数退避。      |
| 500 / 503 | `INTERNAL` / `UNAVAILABLE` | 记录请求标识，有限重试或稍后再试。           |

Google 原生错误对象包含 `error.code`（HTTP 数字）、`error.status`（枚举名称）、`error.message`，可能带 `details`。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 HTTP 200 但没有非 thought 图像时，不能把仅文本回答标记为图片生成成功。

## 官方参考

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 图片生成与编辑](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Google 模型目录](https\://ai.google.dev/gemini-api/docs/models)
* [Google 故障排查](https\://ai.google.dev/gemini-api/docs/troubleshooting)