# Qwen 原生图片接口

本节使用 Qwen 原生请求体，但统一通过本站网关调用：`API_URL` 为 `https://api.dwchainless.com/v1/images/...`，鉴权使用本站 `API_KEY`。请求参数沿用 `model`、`input.messages`、`parameters`，返回统一为 `data[]`；先完成一次单张调用，再增加数量或接入智能体。

## 请求格式与参数

| API       | 请求格式                               | 主要参数                                                   | 详细文档                        |
| --------- | ---------------------------------- | ------------------------------------------------------ | --------------------------- |
| 文字生图      | `POST /v1/images/generations`，JSON | `model`、`input.messages[].content[].text`、`parameters` | [生成参数与四语言代码](/simidoc/zh/apps/api/images/qwen/generations) |
| 编辑 / 以图生图 | `POST /v1/images/edits`，JSON       | `content[]` 内的 `image` 与一条 `text`，加 `parameters`       | [编辑参数与四语言代码](/simidoc/zh/apps/api/images/qwen/edits)       |

当前页面的 2.0 系列示例在 `input.messages` 放一条 `user` 消息，文字描述主体、构图、风格与需渲染的文字；编辑时加入已授权的图片 URL 或模型支持的 data URL。背景替换、风格转换、图中文字修改和多图融合属于编辑目标，不另设 OpenAI multipart 字段，也不保证细节逐像素保留。

### 图片规格

尺寸写在 `parameters.size`，格式为 `width*height`，例如 `"2048*2048"`；不是 `"2048x2048"` 或 `"2K"`。2.0 系列以总像素范围约束尺寸，具体输入图、宽高及输出限制须按模型核对；总像素限制不等于最长边限制。

| 本站三档按张计费 | 请求尺寸最长边            | 像素例子      |
| -------- | ------------------ | --------- |
| 1K       | ≤ 1024 像素          | 1024×1024 |
| 2K       | > 1024 且 ≤ 2048 像素 | 1536×1024 |
| 4K       | > 2048 像素          | 2560×1440 |

此表只解释本站特定模型的计费档位，不表示模型接受 `1K` / `2K` / `4K` 参数。通过本站调用按[模型与价格](https://api.dwchainless.com/zh/pricing/)结算，并参考[图片规格与计费总览](/simidoc/zh/apps/api/images)。更大像素数不保证文字和细节正确，不支持目标规格时应报错而非静默替换。

## 返回参数

| 返回字段                    | 含义与处理                          |
| ----------------------- | ------------------------------ |
| `created`               | 响应生成时间戳。                       |
| `data[].url`            | 最终图片 URL；有效期由渠道决定，需及时下载保存。     |
| `data[].b64_json`       | 部分渠道返回纯 Base64；存在时可直接解码保存。     |
| `data[].revised_prompt` | 渠道改写后的提示词；可能不存在。               |
| `error` / `message`     | 错误码与说明；HTTP 成功也要检查业务错误和图片是否存在。 |

请求体是 Qwen 原生结构，返回是统一的 `data[]`。不要照搬其他渠道的 `prompt`、multipart 或异步 `task_id` 协议；模型 ID 必须与本站渠道实际提供的名称一致。

## 调用示例

### 准备配置

在[模型与价格](https://api.dwchainless.com/zh/pricing/)核对可用模型与余额，并使用本站创建的 Key。`API_URL` 始终指向本站网关，不需要工作空间 ID、地域域名或百炼官方 Key。

| 配置          | 用途                                                                |
| ----------- | ----------------------------------------------------------------- |
| `API_KEY`   | 本站 Key；直接在示例中填写，不粘贴到提示词、代码、截图或 Git。                               |
| `API_URL`   | 本站网关完整请求地址，如 `https://api.dwchainless.com/v1/images/generations`。 |
| `model`     | 已有示例为 `qwen-image-2.0-pro`；先确认本站渠道支持该模型与所需能力。                     |
| `IMAGE_URL` | 编辑示例所用的已授权、云端可访问 HTTP(S) 图片地址，不是本机路径或 localhost。                  |

[生成示例](/simidoc/zh/apps/api/images/qwen/generations)和[编辑示例](/simidoc/zh/apps/api/images/qwen/edits)均提供 Python、Node.js、curl、Go。现有代码发送一次请求并打印 JSON，**不自动下载图片**。将 Python 代码保存为 `generate.py` / `edit.py`，运行 `python3 generate.py` / `python3 edit.py`；Node.js 保存为 `generate.mjs` / `edit.mjs`，运行 `node generate.mjs` / `node edit.mjs`。按对应页要求配置运行时与变量，先只请求一张，随后按下节保存 URL 指向的真实图片。

### 智能体生成 Demo

智能体需要本地脚本、网络请求和返回结果检查能力；本页不是安装 Skill 的指令，也不会给纯文字客户端增加这些能力。

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

### 智能体编辑 Demo

只使用获得处理和上传授权的图片；先检查个人信息及商业机密。现有示例读取 URL，不会自动把本地文件公开上传到其他服务。

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

## 保存与完成标准

* 同步响应不是轮询任务；本节不使用 `task_id` 或 `X-DashScope-Async`。不要混入其他模型的异步协议，也不把流式事件当作完成标准。
* 检查 HTTP 与业务错误、结束原因和实际图片项，再遍历图片 URL。URL 有效期有限，尽快下载；JSON、地址或智能体的口头结论都不等于文件已保存。
* 下载时检查响应状态、内容与文件头，不把错误网页改名为 PNG；不要把本站 Key 发给结果存储域名。保留原文件，失败只清理本次创建的无效输出。
* 确认文件存在、可打开、尺寸与内容符合需求，并在本站账单或使用日志核对请求与费用。多图逐项核对，不为补足数量自动再调用。

## 错误、重试与费用

参数错误先检查 `model`、消息结构、`size` 与输入图；鉴权错误先核对本站 Key 与模型权限；额度或限流错误先检查账户状态。超时、5xx 或结果不明确时先查调用日志与已有文件，不自动重发，避免重复生成或扣费。仅报告脱敏错误，不输出密钥、完整 Base64 或私密图片。

真实生成与编辑可能产生费用。调用前确认模型、尺寸、张数与输出位置；增量、升级规格或重试须重新确认。并行请求分别控制限流、超时与费用；`n` 是单请求数量。最终计价以本站规则和账单为准。

## 官方参考

* [Qwen-Image 生成](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api)
* [Qwen-Image 编辑](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api)