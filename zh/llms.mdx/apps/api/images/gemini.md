# Gemini 图片接口

本节采用 Gemini GenerateContent 原生 `contents/parts` 格式。生成与编辑要求模型具备图像输出能力；普通文本模型不会因为添加参数获得生图能力。先完成一次单张任务，再增加数量或接入智能体。

## 请求格式与参数

| API       | 请求格式                                               | 主要参数                                             | 详细文档                                   |
| --------- | -------------------------------------------------- | ------------------------------------------------ | -------------------------------------- |
| 文字生图      | `POST /v1beta/models/{model}:generateContent`，JSON | `contents[].parts[].text`、`generationConfig`     | [生成参数与四语言代码](/simidoc/zh/apps/api/images/gemini/generate)               |
| 编辑 / 以图生图 | 同一 `generateContent` 端点                            | `text` 与独立图片 Part：`inlineData` 或模型支持的 `fileData` | [编辑参数与四语言代码](/simidoc/zh/apps/api/images/gemini/edits)                  |
| 图片理解      | 同一 `generateContent` 端点                            | 图片与问题；目标是文字分析而非图片输出                              | [Gemini 媒体识别](/simidoc/zh/apps/api/chat/gemini-media) |

文生图只放文字；编辑加入参考图片并分别说明要保留和修改的内容。风格转换、背景替换和多图组合属于编辑目标，不是独立的 `/images/edits` 路径。GenerateContent 的 `contents`、`candidates` 与 Interactions 的 `input`、`steps`、`response_format` 不同，不能混写。

### 图片规格

本协议支持时在 `generationConfig.imageConfig.aspectRatio` 设置比例，例如 `1:1`；在 `generationConfig.imageConfig.imageSize` 设置模型接受的分辨率，如 `1K`、`2K`、`4K`。这些值不是所有 Gemini 图像模型的共同能力，也不能替换成 OpenAI 的 `size`。实际像素与可用比例、模型版本相关；返回格式由实际 MIME 判断。

| 本站三档按张计费 | 请求尺寸最长边            | 像素例子      |
| -------- | ------------------ | --------- |
| 1K       | ≤ 1024 像素          | 1024×1024 |
| 2K       | > 1024 且 ≤ 2048 像素 | 1536×1024 |
| 4K       | > 2048 像素          | 2560×1440 |

此表是本站特定按张模型的计费口径，不是 Google 对分辨率名称的统一定义。只有[模型与价格](https://api.dwchainless.com/zh/pricing/)明确使用该规则时才适用；按 Token 计费或其他价格规则不套用此表。更高分辨率不保证文字或细节正确，模型不支持目标规格时应报错，不擅自降档。详见[图片规格与计费总览](/simidoc/zh/apps/api/images)。

## 返回参数

| 返回字段                                           | 含义与处理                                |
| ---------------------------------------------- | ------------------------------------ |
| `candidates[]`                                 | 候选列表；过滤或失败时可能没有可用图片。                 |
| `candidates[].content.parts[]`                 | 按顺序遍历文本与图片，不能假设第一项就是图片。              |
| `parts[].inlineData.mimeType` / `.data`        | 实际图片 MIME 与纯 Base64；按 MIME 选择扩展名并解码。 |
| `parts[].thought` / `.thoughtSignature`        | 不把思考中间图当最终图；多轮编辑保留模型返回的不透明签名。        |
| `candidates[].finishReason` / `promptFeedback` | 检查是否正常完成及是否被过滤，不能仅凭 HTTP 200 宣称成功。   |
| `usageMetadata`                                | 可选用量信息，具体费用仍以适用价格规则与日志为准。            |

## 调用示例

### 准备配置

在 [API 密钥管理](https://api.dwchainless.com/keys)创建密钥，并从[模型与价格](https://api.dwchainless.com/zh/pricing/)复制支持 GenerateContent 图像输出的模型 ID。请直接在示例代码中填写 API\_URL、API\_KEY 和 MODEL。

| 变量             | 用途                                                  |
| -------------- | --------------------------------------------------- |
| `API_KEY`      | 必填；直接在示例中填写，不放进提示词、代码、截图或 Git。                      |
| `MODEL`        | 必填；选定的 Gemini 图像模型，作为路径中的模型名称。                      |
| `API_URL`      | 完整请求地址；示例使用网关 `https://api.dwchainless.com`。        |
| `IMAGE_BASE64` | 编辑示例中替换为已授权图片的纯 Base64（不含 `data:` 前缀）；格式与尺寸须符合所选模型。 |

[生成示例](/simidoc/zh/apps/api/images/gemini/generate)和[编辑示例](/simidoc/zh/apps/api/images/gemini/edits)均有 Python、Node.js、curl、Go。先选一种语言，使用一次非流式调用。将 Python 代码保存为 `generate.py` 或 `edit.py`，用 `python3 generate.py` 或 `python3 edit.py` 运行；Node.js 示例使用顶层 await（ESM），保存为 `generate.mjs` 或 `edit.mjs`，用 `node generate.mjs` 或 `node edit.mjs` 运行。

### 智能体生成 Demo

智能体须能运行本地脚本并检查返回结果。此流程不安装远程 Skill，也不改已有连接；只有文字对话能力的客户端不能直接执行。

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

### 智能体编辑 Demo

只读取已授权的参考图，先检查个人信息或商业机密。多轮编辑需要模型返回的完整上下文，不能随意丢弃签名；“保留”要求不保证像素级一致。

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

## 保存与完成标准

* 检查 HTTP 状态、`finishReason` 与图片内容。只有文本、被过滤、缺少最终图片或格式不匹配时，明确报告未完成；不能把整个 JSON 保存为图片。
* 严格解码 Base64，核对实际文件格式与 MIME，确认文件能打开、尺寸与内容符合要求。保留原有文件，失败只清理本次新建的无效输出。
* 流式 `streamGenerateContent?alt=sse` 仅在模型支持时使用，任意片段不等于最终图片。`generateContent` 同步返回完整结果，不提供通用任务 ID 轮询；Google Batch 是独立服务，不等于本目录端点。
* 多图按内容项分别保存，核对完成数量；提示词写“生成一张”不保证每个模型严格返回一张。未获授权不为补足数量自动再调用。

## 错误、重试与费用

400 先核对模型、字段与参考图，401/403 检查密钥权限，404 检查模型与路径，429 检查额度及限流。超时、5xx 或缺少完整终态时，先查使用日志和现有文件，不自动重发。只报告脱敏错误和请求标识，不输出密钥、完整 Base64 或私密图片内容。

真实生成与编辑可能产生费用。调用前确认模型、规格、数量与输出位置；更高档位、更多图片、换模型或重试须重新确认。并行请求分别控制限流、超时与费用；用量字段出现不代表模型一定按 Token 收费。最终以当前价格与使用日志为准。

## 官方参考

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 图片生成与编辑](https\://ai.google.dev/gemini-api/docs/image-generation)