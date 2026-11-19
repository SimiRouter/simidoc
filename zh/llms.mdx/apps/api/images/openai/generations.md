# 图片生成

## 接口说明

`POST /v1/images/generations` 根据 prompt 生成一张或多张图片。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

本页使用 GPT Image 参数。不同厂商的 OpenAI 兼容图片模型可能接受不同尺寸、质量与返回格式，不能把这些差异当成同一官方标准。

## 快速开始

1. **准备配置**：在 [API 密钥管理](https://api.dwchainless.com/keys) 创建密钥，从[模型与价格](https://api.dwchainless.com/zh/pricing/)复制支持 Images API 的模型 ID。
2. **发送请求**：向 `https://api.dwchainless.com/v1/images/generations` 发送 JSON，请求头使用 `Authorization: Bearer $API_KEY`，请求体至少包含 `model` 和 `prompt`。
3. **读取结果**：HTTP 2xx 且 `data[]` 非空才算成功；GPT Image 从 `data[].b64_json` 解码保存。
4. **确认完成**：检查文件能否打开、尺寸是否符合要求，再核对使用日志。

最小请求如下；确认可用后，再调整数量、尺寸或开启流式：

```bash
API_URL="https://api.dwchainless.com/v1/images/generations"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
    "n": 1,
    "size": "1024x1024",
    "output_format": "png"
  }'
```

## 请求参数

请求体为 JSON。

| 字段                  | 类型      | 必填 | 说明                                                                                                          |
| ------------------- | ------- | -- | ----------------------------------------------------------------------------------------------------------- |
| model               | string  | 是  | 支持 Images API 的图像模型 ID。                                                                                     |
| prompt              | string  | 是  | 具体描述主体、构图、风格及文字内容。                                                                                          |
| n                   | integer | 否  | 生成数量，OpenAI GPT Image 原生范围为 1–10，示例为 1。                                                                     |
| size                | string  | 否  | OpenAI 原生写法为 WIDTHxHEIGHT（宽高均为 16 的倍数，比例需在 1\:3–3\:1 之间）或 auto；SimiRouter 另接受比例与 resolution 组合，可用值和上限随模型变化。 |
| resolution          | string  | 否  | SimiRouter 扩展字段：与比例配合的档位 1k、2k 或 4k，不是像素值；OpenAI 原生接口没有该字段。                                                 |
| aspect\_ratio       | string  | 否  | SimiRouter 扩展字段：单独的比例，如 3\:4；size 已写比例时以 size 为准。                                                           |
| quality             | string  | 否  | auto、low、medium、high；部分新模型另支持 xhigh、max。                                                                    |
| output\_format      | string  | 否  | png、jpeg（示例）、webp；官方规范还列出 gif、svg，需模型与项目权限支持。                                                               |
| output\_compression | integer | 否  | JPEG/WebP 压缩质量 0–100，不用于 PNG。                                                                               |
| background          | string  | 否  | auto、opaque、transparent；透明背景需支持的模型与 PNG/WebP。                                                               |
| moderation          | string  | 否  | auto 或支持的 low；不保证请求一定通过内容策略。                                                                                |
| response\_format    | string  | 否  | 部分兼容模型支持 url 或 b64\_json；GPT Image 原生不使用。                                                                   |
| stream              | boolean | 否  | true 使用图像 SSE 事件。                                                                                           |
| partial\_images     | integer | 否  | stream=true 时请求 0–3 个中间图像，仍需等最终完成事件。                                                                        |

GPT Image 的图片直接以 Base64 返回，不应依赖旧式 response\_format=url/b64\_json。部分兼容模型可用该字段选择 URL 或 Base64，是否生效以模型说明和实际返回为准。旧 style=vivid/natural 也不适用于 GPT Image，风格应写进 prompt。

### 请求示例

```json
{
  "model": "gpt-image-2",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，柔和蓝金色调，不要文字。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

## 尺寸与格式

K 是分辨率的常用简称，不是文件大小，也不表示质量参数。实际宽高随模型与比例变化；同一比例下边长翻倍，总像素为四倍。以下仅作科普，不能直接当作所有模型的可用尺寸。

OpenAI 使用 `size` 填写模型允许的宽高，如 `1024x1024`，不是直接填写 `1K`；`quality`、`output_format` 与尺寸分别控制质量和格式。

| 分辨率称呼 | 常见像素示意（不是模型支持承诺）                   |
| ----- | ---------------------------------- |
| 1K    | 两边均 ≤ 1024 像素；如 1024×1024。         |
| 2K    | 最长边 > 1024 且 ≤ 2048 像素；如 1280×720。 |
| 4K    | 任一边 > 2048 像素；如 2560×1440。         |

本站按张计费档位是另一套规则，不能把上面的科普示意直接套为收费标准。 [图片规格与计费规则](/simidoc/zh/apps/api/images)。

### 尺寸的三种写法

部分 OpenAI 兼容网关除明确像素外，还接受比例加分辨率或自动尺寸；字段是否生效取决于模型与渠道，不被支持时应退回明确像素。

| 写法       | 请求片段                               | 说明                                     |
| -------- | ---------------------------------- | -------------------------------------- |
| 明确像素（推荐） | `{"size":"1536x2048"}`             | 最直观，避免预设换算差异。                          |
| 比例 + 分辨率 | `{"size":"3:4","resolution":"2k"}` | 使用 2K、3\:4 预设；resolution 只接受 1k、2k、4k。 |
| 自动尺寸     | `{"size":"auto"}`                  | 由模型选择宽高，不承诺固定像素。                       |

* 比例写进 size 时优先于单独的 aspect\_ratio；明确像素或 auto 优先于比例预设。
* 档位写在 resolution，不要发送 size=2k；尺寸分隔符使用小写英文 x。
* OpenAI 官方对 gpt-image-2 的任意尺寸上限为 3840×2160；4096×4096 等更大组合通常返回参数错误。上表 4K 只是档位示意，不代表该像素组合一定可用。
* 14 种常用比例的 1K、2K、4K 速查见[图片规格与计费规则](/simidoc/zh/apps/api/images)。

## 返回值

| 字段                                                   | 类型      | 说明                                       |
| ---------------------------------------------------- | ------- | ---------------------------------------- |
| created                                              | integer | 创建时间，Unix 秒。                             |
| data\[]                                              | array   | 生成结果列表，不可假定一定有第一项。                       |
| data\[].b64\_json                                    | string  | 图片二进制的 Base64；GPT Image 使用此格式。           |
| data\[].url                                          | string  | 只在支持 URL 输出的兼容模型中出现，不能视为 GPT Image 必有字段。 |
| data\[].revised\_prompt                              | string  | 部分旧或兼容模型返回的改写提示，不是 GPT Image 必有字段。       |
| output\_format / size / quality / background         | string  | 可选有效输出配置。                                |
| usage                                                | object  | 可选用量数据，出现与计量粒度随模型和服务变化。                  |
| usage.input\_tokens / output\_tokens / total\_tokens | integer | 如返回则为输入、输出、总 Token。                      |
| usage.input\_tokens\_details                         | object  | 可选 image\_tokens、text\_tokens 等细分。       |
| X-Request-Id                                         | string  | 响应头，不是 JSON 字段；反馈或排查问题时保留。               |

返回的 data\[].url 可能有有效期，下载图片时不要附带 API Key。以下 Base64 仅为最小 PNG 的结构示例，不是上面提示的真实生成结果。

```json
{
  "created": 1760000000,
  "data": [
    {
      "b64_json": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "output_format": "png"
}
```

### 流式生成

支持的模型可设置 stream=true，以 image\_generation.partial\_image 接收中间预览，以 image\_generation.completed 接收最终图片和用量。部分图像不是最终结果；断流且没有 completed 时不要将预览标记为已完成。生成接口不返回可轮询的通用后台任务 ID。

## 代码调用

在代码顶部填写 `API_URL`、`API_KEY`，示例使用 `gpt-image-2`。`API_URL` 是完整请求地址，默认使用网关 `https://api.dwchainless.com`。示例只用标准库，发送一次请求并把返回 JSON 打印到标准输出，不自动保存图片。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/generations"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1,
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
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        prompt: '一只小机器人在图书馆阅读，水彩插画，不要文字。',
        size: '1024x1024',
        n: 1,
      }),
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
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1
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
            "model": "gpt-image-2",
            "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
            "size": "1024x1024",
            "n": 1
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

复制下面的任务给具备本地执行和返回结果检查能力的智能体；先按[本协议配置](/simidoc/zh/apps/api/images/openai)直接在示例代码中填写 API\_URL、API\_KEY 和 MODEL。不要把密钥写进提示词。

```text
Read this OpenAI image protocol page and its generation reference first. Use the
SimiRouter request URL in API_URL (default gateway https://api.dwchainless.com) and the
image model in MODEL. Set API_KEY directly in the example; never print, paste, commit,
or store it in source files. For this one approved request, use POST
/v1/images/generations with n=1, size=1024x1024, stream=false and output_format=png only
after verifying the model supports these parameters. Image brief: a calm blue library
with a small robot reading, watercolor illustration, no lettering. Print the returned
JSON and inspect data[].b64_json; do not write an image file. Confirm that
data[].b64_json contains non-empty Base64 data before reporting completion. Do not
install remote skills, switch providers/models/billing groups, increase size/count,
write files, or retry after timeout or ambiguous failure without approval. If the
request or validation fails, report a redacted error, not success.
```

## 错误码

| HTTP 状态         | 含义或厂商错误类型           | 处理方式                          |
| --------------- | ------------------- | ----------------------------- |
| 400             | 请求无效                | 检查必填字段、JSON、模型参数和上下文长度。       |
| 401             | 认证失败                | 检查 Key 是否存在、有效及归属正确。          |
| 403 / 404       | 无权访问 / 资源不存在        | 检查模型权限、资源 ID 和 URL。           |
| 413             | 请求体或图片过大            | 优先使用图片 URL；减小 Base64 体积或图片尺寸。 |
| 429             | 速率或配额限制             | 结合响应体区分限流与额度不足，后者不能靠重试解决。     |
| 500 / 502 / 503 | 服务错误 / 上游繁忙 / 暂时不可用 | 保留请求标识，对暂时故障做有限次数退避。          |

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 响应 data 为空、缺少图片数据或只有中间预览时，不能仅凭 HTTP 200 宣称生成完成。

生成和编辑可能耗时数十秒到数分钟，客户端应设置足够超时；请求挂起不等于失败。超时、断流或 5xx 后先确认请求是否已经执行，再决定是否重试，避免重复生成和重复扣费。内容策略拒绝（通常为 400）时修改提示词或参考图，不要原样重试。

## 官方参考

* [OpenAI Create image](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [OpenAI 图像生成指南](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)