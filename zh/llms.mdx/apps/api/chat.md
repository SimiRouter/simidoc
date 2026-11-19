# 聊天与内容生成

聊天 API 用一段对话或一条指令换取模型输出。它既能只回答文字，也能读取图片、音频、文件，或调用外部工具后继续作答。协议决定请求与响应的形状，模型决定可用的输入模态、上下文长度和工具能力。

## 概览

| 你想做的事               | 选择                                      | 关键点                |
| ------------------- | --------------------------------------- | ------------------ |
| 普通问答、写作、摘要          | [Chat Completions](/simidoc/zh/apps/api/chat/openai-chat)       | 最通用，客户端支持最广        |
| 让模型查资料、调用函数、返回结构化数据 | [Responses](/simidoc/zh/apps/api/chat/openai-responses)         | 有类型的输入输出与内置工具      |
| 迁移已有 Claude 客户端     | [Claude Messages](/simidoc/zh/apps/api/chat/claude)             | Anthropic 内容块与工具协议 |
| 迁移已有 Gemini 客户端     | [Gemini generateContent](/simidoc/zh/apps/api/chat/gemini-text) | parts 多模态输入        |
| 维护旧式补全集成            | [Completions](/simidoc/zh/apps/api/chat/openai-completions)     | 仅文本 prompt，逐步淘汰    |
| 让模型读图、听音频、看视频或 PDF  | [Gemini 媒体理解](/simidoc/zh/apps/api/chat/gemini-media)           | 输入是媒体，输出仍是文字       |

所有协议共用同一套网关鉴权：基址 `https://api.dwchainless.com`，请求头 `Authorization: Bearer $SIMIROUTER_API_KEY`。换协议不需要换 Key，但换模型要确认新模型支持你要的输入模态和参数。

## 核心概念

先弄清这几个词，后面所有参数才有意义。

* **Token（词元）**：模型读写文本的最小计费单位。英文约 4 个字符、中文约 1 到 2 个字算 1 个 Token，具体以模型分词器为准。输入 Token 与输出 Token 分开计价。
* **上下文窗口（context window）**：单次请求里输入加输出的 Token 总上限。历史越长，留给回答的空间越小；超出上限时请求可能被拒绝，或被截断并返回 `finish_reason` 为 `length`。
* **消息角色（role）**：`system` 或 `developer` 设定行为边界，`user` 是用户输入，`assistant` 是模型输出，`tool` 回传工具执行结果。角色顺序本身就是对话历史。
* **无状态**：服务端不保存你的对话。每次请求都要把需要的历史重新发一遍，历史越长费用越高。
* **流式（streaming）**：服务端用 SSE 逐段返回增量，客户端边收边渲染。它降低的是首字等待时间，不改变总耗时和总费用，也不是异步任务。
* **工具调用（tool calling）**：模型不直接执行函数，而是返回结构化的调用意图；由你的程序执行后，把结果作为新消息交回模型，模型再继续作答。

## 规格与能力

| 指标     | 说明                                                                      |
| ------ | ----------------------------------------------------------------------- |
| 输入模态   | 文本；图片、音频、PDF、视频取决于模型                                                    |
| 输出模态   | 文本；部分模型支持结构化 JSON 或图像                                                   |
| 上下文长度  | 按模型区分，常见 8K 到 1M Token                                                  |
| 单次输出上限 | Chat 用 `max_completion_tokens`，Responses 用 `max_output_tokens`，且受模型上限约束 |
| 并发     | 由你的额度与渠道限流决定，与 `n`、`parallel_tool_calls` 无关                             |
| 计费     | 按输入与输出 Token 分别计价，工具与思考 Token 可能另计                                      |

参数不是越多越好：`temperature`、`top_p`、`reasoning_effort` 等采样与推理参数在不同模型上支持程度不同，网关会透传给渠道，渠道不支持时可能报错或被忽略。先发最小请求，再逐项加参数。

## 调用流程

1. **准备配置**：在 API 密钥管理 创建密钥，从模型与价格复制完整模型 ID。
2. **选择接口**：通用场景用 Chat Completions；需要工具、结构化输出或后台模式时用 Responses；迁移客户端时用对应原生协议。
3. **先发非流式请求**：只请求一条回复，确认鉴权、模型与参数有效，再开启流式或接入工具。
4. **读取并验收**：检查 HTTP 状态、`finish_reason`、拒绝信息和实际内容，再核对使用日志与费用。

## 模拟调用

下面用一条最小请求展示三种形态：请求体、完整响应、流式响应。数值与文案均为示意，不是真实账户的返回。

**请求**

```json
{
  "model": "gpt-5.5",
  "messages": [
    { "role": "system", "content": "You are a concise technical documentation assistant." },
    { "role": "user", "content": "Explain what a token is in three sentences." }
  ],
  "max_completion_tokens": 300,
  "stream": false
}
```

**完整响应（非流式）**

```json
{
  "id": "chatcmpl_demo_0001",
  "object": "chat.completion",
  "model": "gpt-5.5",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "A token is a small unit of text processed by the model. It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 42,
    "completion_tokens": 58,
    "total_tokens": 100
  }
}
```

**流式响应（`"stream": true`）**

服务端按 SSE 逐条推送增量，客户端把 `delta.content` 依次拼接，收到 `[DONE]` 结束：

```text
data: {"choices":[{"index":0,"delta":{"role":"assistant"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":"Token"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" is a small unit of text processed by the model."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

判断是否成功的标准不是“收到了数据”，而是：HTTP 状态为 2xx、最终 `finish_reason` 合理、拼接后的文本完整。中途断流时应按已收到的内容结束，不要自动重发同一付费请求。

## 工具调用

工具调用分两类，混用是常见错误来源：

* **客户端函数（function calling）**：你声明函数签名，模型返回调用意图，你的程序执行后把结果交回模型。数据和执行都在你这边。
* **服务端工具（server-side tools）**：模型侧直接执行，例如 Responses 的内置网页搜索。你只看到最终答案与引用，看不到中间抓取过程。

一条客户端函数的完整往返如下：

```text
1. Request: declare get_weather in tools and ask, "What is the weather in Paris today?"
2. Response: finish_reason = "tool_calls"
   tool_calls[0] = { id: "call_abc", function: { name: "get_weather", arguments: "{\"city\":\"Paris\"}" } }
3. Your program runs get_weather("Paris") and receives {"temp_c": 18}
4. Send another request with the assistant tool_calls message and role = "tool", tool_call_id = "call_abc", content = "{\"temp_c\": 18}"
5. Response: the model produces its final natural-language answer from the tool result
```

要点：`arguments` 是 JSON 字符串而不是对象；工具结果必须带回对应的 `tool_call_id`；一轮里可以有多个工具调用，`parallel_tool_calls` 控制是否并行请求。工具调用会额外消耗 Token，错误重试也可能重复计费。

## 调用方式

* **同步非流式**：连接保持到生成结束，一次接收完整 JSON。适合短回复和后端批处理。
* **流式**：同一请求通过 SSE 增量返回事件。必须处理终止原因与中途断流。
* **异步后台任务**：先取得任务或响应 ID，再通过查询或 Webhook 收取结果。OpenAI 原生 Responses 提供 background 工作流，但本站网关没有配套的查询与取消端点，不应仅添加 `background` 参数。
* **并行请求**：客户端同时发起多次独立 HTTP 请求，分别处理成功、限流和费用。`n` 是候选数量，`parallel_tool_calls` 是同一轮中多个工具调用，两者均不等于 HTTP 并发。

## 接入与会话

普通消息接口是无状态的，每次应带上所需历史；有状态响应 ID 也受上游路由与数据保留限制。官方直连必须同时更换厂商域名和认证信息，不能只替换模型名。

## 官方参考

* [OpenAI 文本生成](https\://developers.openai.com/api/docs/guides/text)
* [OpenAI 后台模式](https\://developers.openai.com/api/docs/guides/background)
* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)