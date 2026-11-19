# 图片理解

## 接口说明

`POST /v1/chat/completions` 在一条 user 消息中组合文本问题与图片，返回文字分析。图片理解不是图片生成或编辑。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

图片可用可访问的 HTTPS URL 或包含真实媒体字节的 data URL；本页使用可访问的 HTTPS 图片 URL。

## 请求参数

| 字段                          | 类型      | 必填 | 说明                                                      |
| --------------------------- | ------- | -- | ------------------------------------------------------- |
| model                       | string  | 是  | 支持视觉输入的聊天模型。                                            |
| messages\[].role            | string  | 是  | 图片消息使用 user。                                            |
| messages\[].content         | array   | 是  | 至少包含问题与图片内容项。                                           |
| content\[].type=text / text | string  | 条件 | 文本问题内容项。                                                |
| content\[].type=image\_url  | string  | 条件 | 声明图片内容项。                                                |
| image\_url.url              | string  | 是  | HTTPS URL 或 data\:image/\{format};base64,...；不能填本地文件路径。 |
| image\_url.detail           | string  | 否  | auto、low、high 等受模型支持的细节设置。                              |
| max\_completion\_tokens     | integer | 否  | 输出 Token 上限。                                            |
| stream                      | boolean | 否  | true 返回 Chat SSE。                                       |

PNG、JPEG、WebP 等格式应使用对应 MIME，图片数量、像素与请求体限制均需满足所选模型要求。不要将 GIF 动画、视频或任意二进制简单改成 image/png。

### 请求结构

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

## 返回值

| 字段                             | 类型               | 说明                                                             |
| ------------------------------ | ---------------- | -------------------------------------------------------------- |
| id / object                    | string           | 响应 ID；object=chat.completion。                                  |
| created / model                | integer / string | 创建时间（Unix 秒）与响应模型。                                             |
| choices\[]                     | array            | 候选回复列表，每项的 index 标识位置。                                         |
| choices\[].message.role        | string           | assistant。                                                     |
| choices\[].message.content     | string / null    | 文本回复；工具调用或拒绝时可为空，不等同于请求失败。                                     |
| choices\[].message.tool\_calls | array            | 待应用执行的函数调用。arguments 是 JSON 字符串，须解析并验证。                        |
| choices\[].message.refusal     | string / null    | 拒绝信息，若有。                                                       |
| choices\[].finish\_reason      | string           | stop 正常结束；length 达到上限；tool\_calls 进入工具调用；content\_filter 内容过滤。 |
| usage.prompt\_tokens           | integer          | 输入 Token。                                                      |
| usage.completion\_tokens       | integer          | 生成 Token，可能包含推理 Token。                                         |
| usage.total\_tokens            | integer          | 输入与生成 Token 总计。                                                |
| usage.\*\_tokens\_details      | object           | 可选用量明细，如 cached\_tokens、reasoning\_tokens。                     |

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

多图可继续添加 image\_url 内容项；需比较图片时在文字中明确次序和目标。流式返回按 Chat delta.content 拼接。对细小文字、精确计数、身份或高风险判断，不应只依赖模型视觉结果。

## 代码调用

在代码顶部填写 `API_URL`、`API_KEY`，示例使用 `gpt-5.5`。`API_URL` 是完整请求地址，默认使用网关 `https://api.dwchainless.com`。`IMAGE_URL` 指向服务端可访问的 HTTPS 图片地址。示例只用标准库，发送一次请求并把返回 JSON 打印到标准输出，不自动保存图片。

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

## 错误码

| HTTP 状态   | 含义或厂商错误类型    | 处理方式                      |
| --------- | ------------ | ------------------------- |
| 400       | 请求无效         | 检查必填字段、JSON、模型参数和上下文长度。   |
| 401       | 认证失败         | 检查 Key 是否存在、有效及归属正确。      |
| 403 / 404 | 无权访问 / 资源不存在 | 检查模型权限、资源 ID 和 URL。       |
| 429       | 速率或配额限制      | 结合响应体区分限流与额度不足，后者不能靠重试解决。 |
| 500 / 503 | 服务错误 / 暂时不可用 | 保留请求标识，对暂时故障做有限次数退避。      |

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。

## 官方参考

* [OpenAI 图片与视觉](https\://developers.openai.com/api/docs/guides/images-vision)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)