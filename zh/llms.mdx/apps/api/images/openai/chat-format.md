# 对话式图片生成

## 接口说明

`POST /v1/responses` 在 tools 中声明 image\_generation，让支持工具调用的主模型结合输入生成图片。主 model 是对话模型；实际图像工具模型的可选配置须按官方当前支持范围选择。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

OpenAI 原生对话式生图使用 Responses 的 image\_generation 工具，不是普通 Chat Completions 返回 Markdown 图片链接的约定。兼容厂商若通过 Chat 返回图片链接，属于其扩展格式，不能写成 OpenAI 标准。

## 请求参数

| 字段                                   | 类型              | 必填 | 说明                                      |
| ------------------------------------ | --------------- | -- | --------------------------------------- |
| model                                | string          | 是  | 支持 image\_generation 工具的 Responses 主模型。 |
| input                                | string / array  | 是  | 文字提示；编辑时可包含 input\_image。               |
| tools\[].type                        | string          | 是  | image\_generation。                      |
| tools\[].model                       | string          | 否  | 图像工具模型，例如 gpt-image-2；省略时使用官方默认模型。      |
| tools\[].output\_format              | string          | 否  | png、jpeg、webp，示例为 png。                  |
| tools\[].size / quality / background | string          | 否  | 工具支持时的尺寸、质量与背景配置。                       |
| tool\_choice                         | string / object | 否  | auto 由模型决定是否生成；强制工具的格式须按该工具支持方式设置。      |
| previous\_response\_id               | string          | 否  | 延续保留的上游响应，需相同可访问的上下文；网关不提供通用查询接口。       |
| stream                               | boolean         | 否  | true 使用 Responses 事件流。                  |

### 请求示例

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

## 返回值

| 字段                          | 类型            | 说明                                              |
| --------------------------- | ------------- | ----------------------------------------------- |
| id / status                 | string        | 响应 ID 和终态，completed 才表示完整响应完成。                  |
| output\[].type              | string        | 图像工具结果为 image\_generation\_call；也可能同时有 message。 |
| output\[].id / status       | string        | 图像调用 ID 与工具执行状态。                                |
| output\[].result            | string        | 图像调用最终结果的 Base64；不是 data\[].b64\_json。          |
| output\[].revised\_prompt   | string        | 支持时返回图像工具所用的改写提示。                               |
| output\[].content\[].text   | string        | message 项中可能附带的说明。                              |
| usage                       | object        | 主模型用量；图像工具费用不应被视为只含文字 Token。                    |
| error / incomplete\_details | object / null | 失败与不完整原因。                                       |

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

此处 Base64 仅为最小 PNG 的结构示例。后续编辑可把图片作为 input\_image 与新指令一同发送，或在支持且保留上下文的服务中使用 previous\_response\_id。不要把任意响应 ID 当成跨渠道通用文件资源。

## 代码调用

在代码顶部填写 `API_URL`、`API_KEY`，示例主模型使用 `gpt-5.5`，图像工具模型使用 `gpt-image-2`。`API_URL` 是完整请求地址，默认使用网关 `https://api.dwchainless.com`。示例只用标准库，发送一次请求并把返回 JSON 打印到标准输出，不自动保存图片。

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

## 错误码

| HTTP 状态   | 含义或厂商错误类型    | 处理方式                      |
| --------- | ------------ | ------------------------- |
| 400       | 请求无效         | 检查必填字段、JSON、模型参数和上下文长度。   |
| 401       | 认证失败         | 检查 Key 是否存在、有效及归属正确。      |
| 403 / 404 | 无权访问 / 资源不存在 | 检查模型权限、资源 ID 和 URL。       |
| 429       | 速率或配额限制      | 结合响应体区分限流与额度不足，后者不能靠重试解决。 |
| 500 / 503 | 服务错误 / 暂时不可用 | 保留请求标识，对暂时故障做有限次数退避。      |

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 主响应 completed 但没有 image\_generation\_call.result 时，可能只生成了文字；应检查工具选择与返回项，不得伪造图片结果。

## 官方参考

* [OpenAI 对话式图像生成](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)