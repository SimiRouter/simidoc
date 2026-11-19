# OpenAI 格式图片接口

本节使用 OpenAI 格式，区分生成、编辑、对话式生图与图片理解。先完成一次单张调用，再增加数量或接入智能体；只有具备相应图像能力的模型才能完成对应任务。

## 调用顺序

1. **准备配置**：在 [API 密钥管理](https://api.dwchainless.com/keys) 创建密钥，从[模型与价格](https://api.dwchainless.com/zh/pricing/)复制支持的完整模型 ID；请求地址为网关 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $API_KEY`。
2. **选择端点**：文字生图用 `POST /v1/images/generations`，编辑 / 以图生图用 `POST /v1/images/edits`，对话式生图用 `POST /v1/responses`，图片理解用 `POST /v1/chat/completions`。
3. **先发最小请求**：只请求一张、不使用流式，确认鉴权、模型和参数都有效，再增加数量、尺寸或接入智能体。
4. **读取并验收**：从 `data[]` 解码 Base64 或下载 URL，检查文件可打开、尺寸与内容符合要求，再核对使用日志。

完整参数、示例与错误处理见下方各协议页面；第一次调用建议从[生成](/simidoc/zh/apps/api/images/openai/generations)开始。

## 请求格式与参数

| API       | 请求格式                                         | 主要参数                                                 | 详细文档                        |
| --------- | -------------------------------------------- | ---------------------------------------------------- | --------------------------- |
| 文字生图      | `POST /v1/images/generations`，JSON           | `model`、`prompt`；按模型设置 `n`、`size`、`quality`          | [生成参数与四语言代码](/simidoc/zh/apps/api/images/openai/generations) |
| 编辑 / 以图生图 | `POST /v1/images/edits`，JSON 或 multipart 二选一 | `model`、`prompt`、`images[]` 或文件 `image`；可用时添加 `mask` | [编辑参数与四语言代码](/simidoc/zh/apps/api/images/openai/edits)       |
| 对话式生图     | `POST /v1/responses`，JSON                    | `input`、图像生成工具及对应模型配置                                | [对话式图片生成](/simidoc/zh/apps/api/images/openai/chat-format)    |
| 图片理解      | `POST /v1/chat/completions`，JSON             | `messages` 内的文字与 `image_url` 内容项                     | [图片理解](/simidoc/zh/apps/api/images/openai/vision)            |

编辑提示词应分别说明“保留什么、修改什么”。风格转换、背景替换和增删元素是编辑目标，不是另一套 API；蒙版、多图和透明背景必须由选定模型支持，不能保证人物、商品或文字逐像素保持不变。

### 图片规格

`size` 表示像素宽高，例如 `1024x1024`，不是通用的 `1K` / `2K` / `4K` 枚举；可接受尺寸随模型变化。`quality` 控制质量，`output_format` 控制 PNG/JPEG/WebP 编码，不能用它们代替分辨率。透明背景还需模型支持 `background: transparent`，并使用 PNG 或 WebP。

尺寸的三种写法、14 种比例速查与 1K/2K/4K 按张计费档位统一见[图片规格与计费总览](/simidoc/zh/apps/api/images)。计费表只适用于[模型与价格](https://api.dwchainless.com/zh/pricing/)明确采用该规则的模型，不保证示例尺寸均可请求。

## 返回参数

| 返回字段 / 事件                                             | 含义与处理                                                  |
| ----------------------------------------------------- | ------------------------------------------------------ |
| Images `data[].b64_json`                              | GPT Image 的 Base64 图片数据，解码后保存二进制图片；不要把整份 JSON 改名为 PNG。 |
| Images `data[].url`                                   | 仅支持 URL 输出的旧或兼容模型可能返回；及时下载，不能假定 GPT Image 必有此字段。       |
| Images `usage`                                        | 可选用量数据；字段出现不代表一定按 Token 收费。                            |
| `image_generation.completed` / `image_edit.completed` | Images 流式生成 / 编辑的最终事件；`partial_image` 只是中间预览。          |
| Responses `output[]`                                  | 对话式生图按图像工具输出项处理，不照搬 Images `data[]`。                   |
| Chat `choices[].message.content`                      | 图片理解返回文字分析，不是生成图片。                                     |

## 调用示例

### 准备配置

在 [API 密钥管理](https://api.dwchainless.com/keys)创建密钥，并从[模型与价格](https://api.dwchainless.com/zh/pricing/)复制可用的完整图像模型 ID。请直接在示例代码中填写 API\_URL、API\_KEY 和 MODEL。

| 变量          | 用途                                            |
| ----------- | --------------------------------------------- |
| `API_KEY`   | 必填；直接在示例中填写，不粘贴到提示词、源文件、截图或 Git。              |
| `MODEL`     | 必填；生成和编辑分别确认模型支持对应端点。                         |
| `API_URL`   | 完整请求地址；示例使用网关 `https://api.dwchainless.com`。  |
| `IMAGE_URL` | 编辑示例使用的 HTTPS 图片地址，须为服务端可访问的 PNG、JPEG 或 WebP。 |

[生成示例](/simidoc/zh/apps/api/images/openai/generations)和[编辑示例](/simidoc/zh/apps/api/images/openai/edits)均提供 Python、Node.js、curl、Go。先选一种语言、只请求一张非流式图片。Python 3.8+ 与 Node.js 20+ 示例使用标准库；将生成代码保存为 `generate.py` 或 `generate.mjs`，编辑代码保存为 `edit.py` 或 `edit.mjs`，运行对应文件，例如 `python3 generate.py` 或 `node generate.mjs`。Python 和 Node.js 编辑示例都使用 JSON `images[].image_url`，不使用 multipart 上传。

### 智能体生成 Demo

智能体须具备运行本地脚本、读取授权图片和检查返回结果的能力；本页不会安装 Skill，也不会让纯文字客户端自动获得工具能力。保留已有连接，不擅自换服务。

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

### 智能体编辑 Demo

先确认参考图的处理权限，检查个人信息或商业机密；只授权所需文件。提示词中的“保留”是目标，不是像素级保证。

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

## 保存与完成标准

* 保存前检查 HTTP 状态、最终图片字段、解码结果与实际文件格式；仅改扩展名不能转换格式。失败时清理本次新建的无效文件，不删除原有文件。
* 先使用单张非流式请求。流式必须等相应 `completed`，按图片索引处理多张结果；没有终态不能把预览标记完成。标准 Images 不是先返回任务 ID 再轮询的通用异步队列。
* 确认文件存在、可打开、尺寸与内容符合要求，再核对使用日志。HTTP 成功或智能体口头说“完成”不等于图片已保存。

## 错误、重试与费用

400 先核对模型与参数，401 检查密钥，403/404 检查权限、模型 ID 与路径，429 检查额度及速率限制。5xx、超时或流式中断后先查看日志和已有结果，不自动重发，避免重复生成或扣费。只报告脱敏错误与请求标识，不输出密钥、完整图片 Base64 或私密图片内容。

真实生成与编辑可能产生费用。调用前确认模型、尺寸、张数和输出位置；增加 `n`、改高档位、换模型或重试须重新确认。并行请求分别限流、超时和计费；`n` 是单次请求的数量，不是并行度。最终费用以当前模型价格和使用日志为准。

## 官方参考

* [OpenAI 图像生成指南](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Images API](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [OpenAI 视觉输入](https\://developers.openai.com/api/docs/guides/images-vision)