# Qwen 图像编辑

## 接口说明

`POST /v1/images/edits`，正文为 JSON。示例使用本站网关 `https://api.dwchainless.com`，`API_KEY` 使用本站密钥；请求体沿用 Qwen 原生的 `model`、`input.messages`、`parameters` 结构，返回统一为 `data[]`。

图像编辑在 content 中放 image 项和一条文字修改指令，不使用 multipart 的 file 字段。

## 请求参数

| 字段                                 | 类型        | 必填 | 说明                                                     |
| ---------------------------------- | --------- | -- | ------------------------------------------------------ |
| model                              | string    | 是  | qwen-image-2.0-pro 或本站渠道支持的具体版本。                       |
| input.messages                     | object\[] | 是  | 单轮 user 消息，恰好一项。                                       |
| input.messages\[].role             | string    | 是  | 固定 user。                                               |
| input.messages\[].content\[].text  | string    | 是  | 中文或英文指令，每轮只放一个 text 项。                                 |
| input.messages\[].content\[].image | string    | 是  | 一张或多张参考图的可访问 URL / data URL。输入数量和像素限制按模型版本。            |
| parameters.size                    | string    | 否  | 宽 × 高，如 2048 × 2048；2.0 系列总像素为 512×512 至 2048×2048 范围。 |
| parameters.n                       | integer   | 否  | 默认 1；2.0 系列支持 1–6。                                     |
| parameters.negative\_prompt        | string    | 否  | 不希望出现的内容，最多 500 字符。                                    |
| parameters.prompt\_extend          | boolean   | 否  | 默认 true，自动扩展正向提示词。                                     |
| parameters.watermark               | boolean   | 否  | 是否加显式水印；应遵循适用的合成内容标识要求。                                |

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
{"created":1760000000,"data":[{"url":"https://example.com/edited.png","b64_json":null,"revised_prompt":"..."}]}
```

## 代码调用

在代码顶部填写 `API_URL`、`API_KEY`。`API_URL` 使用本站网关地址 `https://api.dwchainless.com/v1/images/edits`，`API_KEY` 使用本站密钥。示例只用标准库，发送一次请求并打印返回 JSON，不自动下载或保存图片。

设置 `IMAGE_URL` 为已授权、云端可访问的真实 HTTP(S) 图片地址。代码只检查 URL 形式，不证明图片可下载或已满足渠道的格式限制；不要使用本机路径、localhost、需要登录的网页或假链接。

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

## 智能体调用 Demo

复制下面的任务给具备本地执行和返回结果检查能力的智能体；先按[本协议配置](/simidoc/zh/apps/api/images/qwen)直接在示例代码中填写 API\_URL、API\_KEY，并确认 model 名称。不要把密钥写进提示词。

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

## 错误码

| 错误                     | 处理                                  |
| ---------------------- | ----------------------------------- |
| 400 / InvalidParameter | 检查 content 结构、图片规格、输出 size 和模型支持参数。 |
| 401                    | 检查本站 API Key 是否存在、有效及归属正确。          |
| 403 / 404              | 检查模型权限、渠道与资源是否存在。                   |
| 429                    | 限流或额度不足，确认原因后再退避重试。                 |
| 5xx                    | 服务异常，记录请求标识；避免无上限重复生成。              |

## 官方参考

[Qwen-Image 编辑](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api)、[百炼错误码](https\://www.alibabacloud.com/help/en/model-studio/error-code)。