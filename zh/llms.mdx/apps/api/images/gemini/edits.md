# Gemini 图片编辑与以图生图

## 接口说明

`POST /v1beta/models/{model}:generateContent` 在 parts 中同时提交编辑指令和参考图片，即可进行图片编辑、以图生图、风格转换、背景替换或多图融合。没有单独的原生 `/images/edits` Gemini 路径。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $API_KEY`。Google 官方直连为 `https://generativelanguage.googleapis.com`，通常使用 `x-goog-api-key: $GEMINI_API_KEY`，不是网关的 Bearer Key。 模型名称应选用账户可访问且支持目标能力的模型。

只上传自己有权处理的图片。编辑效果不保证像素级保留身份、文字、商标或商品细节，重要内容应在使用前人工检查。

## 请求参数

| 字段                                       | 类型     | 必填       | 说明                                                 |
| ---------------------------------------- | ------ | -------- | -------------------------------------------------- |
| model（路径）                                | string | 是        | 同时支持 generateContent 和图像输出的 Gemini 图像模型；不要使用纯文本模型。 |
| contents                                 | array  | 是        | 消息列表；文生图通常只需一条 user 消息。                            |
| contents\[].role                         | string | 否        | user；多轮历史中的模型回复使用 model。                           |
| contents\[].parts\[].text                | string | 是        | 图片描述或编辑指令。                                         |
| generationConfig.responseModalities      | array  | 否        | 如 \["TEXT","IMAGE"]，请求文本与图片输出；可用组合随模型变化。           |
| generationConfig.imageConfig.aspectRatio | string | 否        | 支持时可用 1\:1、16\:9、9\:16 等比例。                        |
| generationConfig.imageConfig.imageSize   | string | 否        | 支持时设置 1K、2K、4K 等，必须匹配选定模型；不是所有图像模型都支持。             |
| contents\[].parts\[].inlineData          | object | 是（内联参考图） | 与 text 分开的 Part；包含 mimeType 与 data。                |
| inlineData.mimeType                      | string | 是        | 参考图片的真实 MIME，如 image/png、image/jpeg 或 image/webp。  |
| inlineData.data                          | string | 是        | 参考文件的纯 Base64，不包含 data\: 前缀。                       |
| contents\[].parts\[].fileData            | object | 条件       | 可替代内联内容，需提供厂商可读取且已授权的 fileUri/mimeType。            |

一张图片对应一个 Part，多张参考图继续添加图片 Part，并在文字里说明每张图的用途。图片张数、分辨率和多轮一致性限制随模型变化，不应用单一数字覆盖所有 Gemini 图像模型。

### 图片规格：1K、2K、4K

K 是分辨率的常用简称，不是文件大小，也不表示质量参数。实际宽高随模型与比例变化；同一比例下边长翻倍，总像素为四倍。以下仅作科普，不能直接当作所有模型的可用尺寸。

Gemini 在模型支持时，用 `generationConfig.imageConfig.imageSize` 选择 `1K`、`2K`、`4K`，并以 `generationConfig.imageConfig.aspectRatio` 选择比例；实际输出宽高须查所选模型。

| 分辨率称呼 | 常见像素示意（不是模型支持承诺）                   |
| ----- | ---------------------------------- |
| 1K    | 两边均 ≤ 1024 像素；如 1024×1024。         |
| 2K    | 最长边 > 1024 且 ≤ 2048 像素；如 1280×720。 |
| 4K    | 任一边 > 2048 像素；如 2560×1440。         |

本站按张计费档位是另一套规则，不能把上面的科普示意直接套为收费标准。 [图片规格与计费规则](/simidoc/zh/apps/api/images)。

### 请求结构

将 `BASE64_IMAGE_BYTES` 替换为授权图片的纯 Base64。

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

上述 Base64 仅表示结构。保存结果时读取实际 MIME。多轮编辑应把上一轮完整的 model content 加入历史，保留 thoughtSignature 等不透明字段，再追加新的 user 编辑要求。不要只复制图片字节而丢弃必须的签名，也不要改动这些字段。

Gemini 原生编辑使用自然语言描述区域；OpenAI mask 参数不是此接口的通用参数。需要精确区域约束时应核对选定模型支持的输入方式，不要凭字段名类推。

## 代码调用

在代码顶部填写 `API_URL`、`API_KEY`，示例使用 `gemini-3-pro-image`，并把 `BASE64_IMAGE_BYTES` 替换为授权图片的纯 Base64（不含 data\: 前缀）。`API_URL` 是完整请求地址，默认使用网关 `https://api.dwchainless.com`。示例只用标准库，发送一次请求并把返回 JSON 打印到标准输出，不自动保存图片。

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

## 智能体调用 Demo

复制下面的任务给具备本地执行和返回结果检查能力的智能体；先按[本协议配置](/simidoc/zh/apps/api/images/gemini)直接在示例代码中填写 API\_URL、API\_KEY 和 MODEL。不要把密钥写进提示词。

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

## 错误码

| HTTP 状态   | 含义或厂商错误类型                  | 处理方式                        |
| --------- | -------------------------- | --------------------------- |
| 400       | `INVALID_ARGUMENT` 等       | 检查 JSON、模型参数、媒体 MIME 和输入长度。 |
| 403       | `PERMISSION_DENIED`        | 检查 Key、项目权限、区域或账单限制。        |
| 404       | `NOT_FOUND`                | 检查模型名和 API 版本。              |
| 429       | `RESOURCE_EXHAUSTED`       | 检查限流与配额；可重试情况采用有限次数退避。      |
| 500 / 503 | `INTERNAL` / `UNAVAILABLE` | 记录请求标识，有限重试或稍后再试。           |

Google 原生错误对象包含 `error.code`（HTTP 数字）、`error.status`（枚举名称）、`error.message`，可能带 `details`。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 模型拒绝、缺少图片输出、非 STOP 终止与 HTTP 错误须分别处理；不能用输入图片冒充编辑后的结果。

## 官方参考

* [Google 图片生成与编辑](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 图片理解与媒体输入](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Google 故障排查](https\://ai.google.dev/gemini-api/docs/troubleshooting)