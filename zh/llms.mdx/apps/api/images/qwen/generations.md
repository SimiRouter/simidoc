# Qwen 图像生成

## 接口说明

`POST /v1/images/generations`，正文为 JSON。示例使用本站网关 `https://api.dwchainless.com`，`API_KEY` 使用本站密钥；请求体沿用 Qwen 原生的 `model`、`input.messages`、`parameters` 结构，返回统一为 `data[]`。

文生图只需文字 content 项。输入文本描述构图、视觉风格与需要渲染的文字。

## 请求参数

| 字段                                | 类型        | 必填 | 说明                                                     |
| --------------------------------- | --------- | -- | ------------------------------------------------------ |
| model                             | string    | 是  | qwen-image-2.0-pro 或本站渠道支持的具体版本。                       |
| input.messages                    | object\[] | 是  | 单轮 user 消息，恰好一项。                                       |
| input.messages\[].role            | string    | 是  | 固定 user。                                               |
| input.messages\[].content\[].text | string    | 是  | 中文或英文指令，每轮只放一个 text 项。                                 |
| parameters.size                   | string    | 否  | 宽 × 高，如 2048 × 2048；2.0 系列总像素为 512×512 至 2048×2048 范围。 |
| parameters.n                      | integer   | 否  | 默认 1；2.0 系列支持 1–6。                                     |
| parameters.negative\_prompt       | string    | 否  | 不希望出现的内容，最多 500 字符。                                    |
| parameters.prompt\_extend         | boolean   | 否  | 默认 true，自动扩展正向提示词。                                     |
| parameters.watermark              | boolean   | 否  | 是否加显式水印；应遵循适用的合成内容标识要求。                                |

### 图片规格：1K、2K、4K

K 是分辨率的常用简称，不是文件大小，也不表示质量参数。实际宽高随模型与比例变化；同一比例下边长翻倍，总像素为四倍。以下仅作科普，不能直接当作所有模型的可用尺寸。

Qwen 使用 `parameters.size` 填写模型允许的宽高，格式如 `2048*2048`，不是直接填写 `2K`。2.0 系列还有总像素限制，下面的 4K 方图示意不代表可提交该尺寸。

| 分辨率称呼 | 常见像素示意（不是模型支持承诺）                   |
| ----- | ---------------------------------- |
| 1K    | 两边均 ≤ 1024 像素；如 1024×1024。         |
| 2K    | 最长边 > 1024 且 ≤ 2048 像素；如 1280×720。 |
| 4K    | 任一边 > 2048 像素；如 2560×1440。         |

本站按张计费档位是另一套规则，不能把上面的科普示意直接套为收费标准。 [图片规格与计费规则](/simidoc/zh/apps/api/images)。

## 返回值

| 字段                      | 说明                         |
| ----------------------- | -------------------------- |
| `created`               | 响应生成时间戳。                   |
| `data[].url`            | 生成图片 URL；有效期由渠道决定，及时下载或转存。 |
| `data[].b64_json`       | 部分渠道返回纯 Base64；存在时可直接解码保存。 |
| `data[].revised_prompt` | 渠道改写后的提示词；可能不存在。           |
| `error` / `message`     | 失败时的错误码与说明。                |

```json
{"created":1760000000,"data":[{"url":"https://example.com/generated.png","b64_json":null,"revised_prompt":"..."}]}
```

## 代码调用

在代码顶部填写 `API_URL`、`API_KEY`。`API_URL` 使用本站网关地址 `https://api.dwchainless.com/v1/images/generations`，`API_KEY` 使用本站密钥，模型可用性以[模型与价格](https://api.dwchainless.com/zh/pricing/)为准。示例只用标准库，发送一次请求并打印返回 JSON，不自动下载或保存图片。

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

## 智能体调用 Demo

复制下面的任务给具备本地执行和返回结果检查能力的智能体；先按[本协议配置](/simidoc/zh/apps/api/images/qwen)直接在示例代码中填写 API\_URL、API\_KEY，并确认 model 名称。不要把密钥写进提示词。

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

## 错误码

| 错误                     | 处理                                    |
| ---------------------- | ------------------------------------- |
| 400 / InvalidParameter | 检查 JSON、content 结构、图片规格、size 和模型支持参数。 |
| 401                    | 检查本站 API Key 是否存在、有效及归属正确。            |
| 403 / 404              | 检查模型权限、渠道与资源是否存在。                     |
| 429                    | 限流或额度不足，确认原因后再退避重试。                   |
| 5xx                    | 服务异常，记录请求标识；避免无上限重复生成。                |

## 官方参考

[Qwen-Image 生成](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api)、[百炼错误码](https\://www.alibabacloud.com/help/en/model-studio/error-code)。