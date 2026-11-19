# 图片编辑与以图生图

## 接口说明

`POST /v1/images/edits` 接收参考图片及编辑指令，返回编辑后的图片。适用于修改背景、风格转换、加入或删除元素，也可组合多张参考图。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

支持 JSON 的 images\[] 引用方式以及 multipart 文件上传。下面的示例用 JSON `images[].image_url` 传入服务端可访问的 HTTPS 图片地址，不依赖 multipart 上传。

## 快速开始

1. **准备配置**：在 [API 密钥管理](https://api.dwchainless.com/keys) 创建密钥，从[模型与价格](https://api.dwchainless.com/zh/pricing/)复制支持编辑的图像模型 ID。
2. **准备参考图**：使用服务端可访问的 HTTPS 图片地址，或通过 multipart 上传本地文件；不要同时混用两种方式。
3. **发送请求**：向 `https://api.dwchainless.com/v1/images/edits` 发送 `model`、`prompt` 和图片引用；请求头使用 `Authorization: Bearer $API_KEY`。
4. **读取并验收**：HTTP 2xx 且 `data[]` 非空才算成功；从 `data[].b64_json` 解码或下载 `data[].url`，再检查文件、尺寸和内容。

第一次调用建议只编辑一张图、不使用流式；确认可用后，再增加参考图数量或开启流式。

## 请求参数

| 字段                   | 类型      | 必填           | 说明                                                                                                          |
| -------------------- | ------- | ------------ | ----------------------------------------------------------------------------------------------------------- |
| model                | string  | 是（网关）        | 显式选择支持编辑的图像模型，避免依赖上游默认值。                                                                                    |
| images               | array   | 是（JSON）      | 图片引用列表，原生 GPT Image 最多16张，模型还可有更严格限制。                                                                       |
| images\[].image\_url | string  | 条件           | HTTPS 图片 URL 或 data\:image/...;base64,...；本页示例使用 HTTPS URL。                                                 |
| images\[].file\_id   | string  | 条件           | 官方 Files 上传资源 ID，与 image\_url 二选一；网关不可假定可用。                                                                 |
| prompt               | string  | 是            | 明确需要改变和需要保留的内容。                                                                                             |
| mask                 | object  | 否            | JSON 时引用 mask.image\_url 或 mask.file\_id；掩码规则随模型变化。                                                         |
| image / image\[]     | file    | 是（multipart） | multipart 的一张或多张图片字段，不与 JSON images 混写。                                                                     |
| mask（multipart）      | file    | 否            | PNG 掩码，透明区域标记编辑范围；与源图尺寸及模型要求匹配。                                                                             |
| input\_fidelity      | string  | 否            | 仅支持该参数的模型可用，不能假定所有 GPT Image 代际接受。                                                                          |
| n                    | integer | 否            | 生成数量，OpenAI GPT Image 原生范围为 1–10，示例为 1。                                                                     |
| size                 | string  | 否            | OpenAI 原生写法为 WIDTHxHEIGHT（宽高均为 16 的倍数，比例需在 1\:3–3\:1 之间）或 auto；SimiRouter 另接受比例与 resolution 组合，可用值和上限随模型变化。 |
| resolution           | string  | 否            | SimiRouter 扩展字段：与比例配合的档位 1k、2k 或 4k，不是像素值；OpenAI 原生接口没有该字段。                                                 |
| aspect\_ratio        | string  | 否            | SimiRouter 扩展字段：单独的比例，如 3\:4；size 已写比例时以 size 为准。                                                           |
| quality              | string  | 否            | auto、low、medium、high；部分新模型另支持 xhigh、max。                                                                    |
| output\_format       | string  | 否            | png、jpeg（示例）、webp；官方规范还列出 gif、svg，需模型与项目权限支持。                                                               |
| output\_compression  | integer | 否            | JPEG/WebP 压缩质量 0–100，不用于 PNG。                                                                               |
| background           | string  | 否            | auto、opaque、transparent；透明背景需支持的模型与 PNG/WebP。                                                               |
| moderation           | string  | 否            | auto 或支持的 low；不保证请求一定通过内容策略。                                                                                |
| response\_format     | string  | 否            | 部分兼容模型支持 url 或 b64\_json；GPT Image 原生不使用。                                                                   |
| stream               | boolean | 否            | true 使用图像 SSE 事件。                                                                                           |
| partial\_images      | integer | 否            | stream=true 时请求 0–3 个中间图像，仍需等最终完成事件。                                                                        |

JSON 与 multipart 二选一；multipart 的 Content-Type 必须由客户端自动生成 boundary。蒙版不能保证像素级精确修改，最终图需人工检查。

## 选择传图方式

参考图有四种传入方式，按运行环境选择一种，不能在同一次请求里混写：

| 方式           | 字段                              | 适用场景                     |
| ------------ | ------------------------------- | ------------------------ |
| JSON URL     | `images[].image_url`            | 图片已在公网，服务端可直接访问          |
| JSON Base64  | `images[].image_url` 的 data URL | 图片较小，且不想暴露公网地址           |
| multipart 文件 | `image` 或 `image[]`             | 本地文件，由客户端直接上传            |
| Files 资源 ID  | `images[].file_id`              | 已通过官方 Files 上传，且网关支持该 ID |

JSON 请求使用 `Content-Type: application/json`；multipart 的 `Content-Type` 必须由客户端生成 boundary，不要手写。

### JSON 请求结构

JSON 示例直接使用服务端可访问的 HTTPS 图片 URL。

```json
{
  "model": "gpt-image-2",
  "images": [
    {
      "image_url": "https://example.com/reference.png"
    }
  ],
  "prompt": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

### multipart 请求结构

单个本地参考图使用 `image` 字段；多张图使用 `image[]`，并按顺序说明各图用途：

```bash
API_URL="https://api.dwchainless.com/v1/images/edits"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -F "model=gpt-image-2" \
  -F "prompt=保留主体和构图，将背景改为浅蓝色。" \
  -F "image=@reference.png" \
  -F "size=1024x1024" \
  -F "n=1"
```

## 编辑提示词写法

编辑提示词应同时说明保留项和修改项，只写“改成水彩”容易让模型重绘整个画面。建议按“保留 + 修改 + 约束”组织：

| 场景      | 提示词要点                 | 例子                         |
| ------- | --------------------- | -------------------------- |
| 保留人物或商品 | 明确主体、姿势、构图和文字保持不变     | 保留人物姿势和服装，只把背景改为浅蓝色。       |
| 风格转换    | 说明目标风格和需要保留的布局        | 改为水彩插画风格，保留原有构图和主体位置。      |
| 局部修改    | 指出修改区域；模型支持时配合 `mask` | 只修改画面左下角的杯子，其余保持不变。        |
| 多图组合    | 说明每张图的用途、主体关系和最终布局    | 第一张图是人物，第二张图是场景，将人物置于场景中央。 |

“保留”是目标而不是像素级保证；人物、商品和文字细节都可能变化，涉及身份或品牌的内容必须人工核对。透明背景需要模型支持 `background: transparent`，并使用 PNG 或 WebP 输出。

## 尺寸与格式

`size` 填写模型允许的像素宽高，如 `1024x1024`；`quality` 控制质量，`output_format` 控制 PNG/JPEG/WebP 编码。编辑结果的尺寸由 `size` 决定（省略时默认 `auto`，由模型选择）；不要求与参考图完全一致。

本站 1K、2K、4K 按张计费档位与厂商的分辨率称呼是两套规则；尺寸的三种写法、14 种比例速查和计费边界统一见[图片规格与计费](/simidoc/zh/apps/api/images)。

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

示例 Base64 为最小 PNG，仅表示字段结构。返回的 data\[].url 可能有有效期，下载图片时不要附带 API Key。流式编辑使用 image\_edit.partial\_image 和 image\_edit.completed 事件；只有最终事件可标记编辑完成。以图生图不能保证人物、商品或文字的细节逐像素保持不变。

## 代码调用

在代码顶部填写 `API_URL`、`API_KEY`，示例使用 `gpt-image-2`。`API_URL` 是完整请求地址，默认使用网关 `https://api.dwchainless.com`。`IMAGE_URL` 指向服务端可访问的 HTTPS 图片地址。示例只用标准库，发送一次请求并把返回 JSON 打印到标准输出，不自动保存图片。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "images": [{"image_url": "https://example.com/reference.png"}],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        images: [
          {
            image_url: 'https://example.com/reference.png',
          },
        ],
        prompt: '保留主体和构图，将背景改为浅蓝色。',
        size: '1024x1024',
        n: 1,
      }),
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
        "model": "gpt-image-2",
        "images": [
          {
            "image_url": "https://example.com/reference.png"
          }
        ],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
        apiURL := "https://api.dwchainless.com/v1/images/edits"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "images": [
                {
                    "image_url": "https://example.com/reference.png"
                }
            ],
            "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
Read this OpenAI image protocol page and its editing reference first. Set API_KEY,
MODEL, and API_URL directly in the example; use the configured SimiRouter request URL;
never reveal the key or change the existing connection. Use only the authorized HTTPS
image URL in IMAGE_URL. Use POST /v1/images/edits with JSON images[]; do not set
multipart Content-Type or send local files. Keep the subject and layout; change only the
background to pale blue. Request one PNG at 1024x1024 with stream=false only if the
selected model supports it. Print the returned JSON and inspect data[].b64_json; do not
write an image file. Confirm that data[].b64_json contains non-empty Base64 data and
report any unmet requirement. Do not upload unrelated files, change
size/count/model/provider, install remote skills, or retry automatically after an error
or timeout. Ask before another paid request.
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

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 无效图片、MIME 不匹配、掩码尺寸不符或模型不接受参数是输入错误，应先修正而不是重复提交。

编辑可能耗时数十秒到数分钟，客户端应设置足够超时；请求挂起不等于失败。超时、断流或 5xx 后先确认请求是否已经执行，再决定是否重试，避免重复生成和重复扣费。内容策略拒绝（通常为 400）时修改提示词或参考图，不要原样重试。

## 官方参考

* [OpenAI Create image edit](https\://developers.openai.com/api/reference/resources/images/methods/edit)
* [OpenAI 图像生成与编辑](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)