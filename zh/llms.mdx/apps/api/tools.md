# 工具调用

工具调用连接模型与数据、计算及外部服务。模型负责选择工具和组织参数，应用或厂商工具服务负责执行；工具返回值与最终自然语言回答是不同阶段。

## 概览

| 能力    | 谁执行  | 你看到的结果          | 典型场景              |
| ----- | ---- | --------------- | ----------------- |
| 客户端函数 | 你的程序 | 调用意图 + 你回传的执行结果 | 查数据库、调用内部 API、扣库存 |
| 服务端搜索 | 厂商   | 最终回答与引用来源       | 查最新资料、核对事实        |

## 核心概念

* **工具定义**：名称、用途说明和参数 JSON Schema。说明写得越清楚，模型选错工具或编造参数的概率越低。
* **调用意图**：模型不执行代码，只返回 `tool_calls`，其中 `arguments` 是 JSON 字符串。它在流式响应中可能分片到达，必须收齐再解析。
* **执行与回传**：你的程序校验参数、执行函数，再把结果以 `role` 为 `tool`、带同一个 `tool_call_id` 的消息发回，模型才能继续。
* **服务端工具**：检索由厂商完成，你只拿到答案与引用，无法控制中间过程，也不能把客户端函数的用法套上去。

## 模拟调用

一次客户端函数的请求、模型响应和回传结果，字段形态如下（内容为示意）：

```json
{
  "model": "gpt-5.5",
  "messages": [{ "role": "user", "content": "上海今天多少度？" }],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "查询指定城市的实时天气",
        "parameters": {
          "type": "object",
          "properties": { "city": { "type": "string" } },
          "required": ["city"]
        }
      }
    }
  ]
}
```

模型返回调用意图而不是温度：

```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": null,
        "tool_calls": [
          {
            "id": "call_abc",
            "type": "function",
            "function": {
              "name": "get_weather",
              "arguments": "{\"city\":\"上海\"}"
            }
          }
        ]
      },
      "finish_reason": "tool_calls"
    }
  ]
}
```

执行函数后，把结果作为新消息追加并再次请求：

```json
{
  "role": "tool",
  "tool_call_id": "call_abc",
  "content": "{\"temp_c\": 18}"
}
```

第三次响应才是给用户看的自然语言答案。整条链路里，模型从未真正访问天气服务；你的程序才是执行者。

### 服务端搜索

服务端工具只有一次往返：你声明工具，厂商完成检索，一次响应里同时给出检索记录和最终回答。

```json
{
  "model": "gpt-5.5",
  "input": "查找 OpenAI 官方文档中关于 Responses API 的说明，并提供来源链接。",
  "tools": [{ "type": "web_search" }],
  "stream": false
}
```

返回的 `output[]` 通常先出现检索动作，再出现最终消息与引用：

```json
{
  "status": "completed",
  "output": [
    {
      "type": "web_search_call",
      "status": "completed",
      "action": { "type": "search", "query": "site:developers.openai.com Responses API" }
    },
    {
      "type": "message",
      "role": "assistant",
      "content": [
        {
          "type": "output_text",
          "text": "Responses API 用于生成模型响应……",
          "annotations": [
            {
              "type": "url_citation",
              "url": "https://developers.openai.com/api/docs/guides/text",
              "title": "OpenAI text generation"
            }
          ]
        }
      ]
    }
  ]
}
```

`status` 为 `completed` 且存在 `message` 才代表回答可用；只看到 `web_search_call` 说明检索阶段结束，不等于回答完整。引用来自 `annotations[]`，应用应原样展示，不要自行改写来源 URL。

## 工具类型

| 文档                      | 请求                                        | 执行方                            |
| ----------------------- | ----------------------------------------- | ------------------------------ |
| [函数调用](/simidoc/zh/apps/api/tools/function-call) | POST /v1/chat/completions；也有 Responses 格式 | 应用定义 JSON Schema、校验参数并执行自己的函数。 |
| [网络搜索](/simidoc/zh/apps/api/tools/web-search)    | POST /v1/responses + web\_search          | 厂商托管检索，返回网页来源与引用。              |

## 同步、流式与并行

* **同步**：单次请求返回完整工具调用或最终回答；自定义函数通常需要应用执行后再发下一轮请求。
* **流式**：工具名或参数以片段出现，须在参数收齐后解析，不能执行半截 JSON。
* **异步**：耗时业务工具可以由应用建立后台任务，但必须自行提供任务状态与结果关联；声明 tools 不会自动创建异步服务。
* **并行**：parallel\_tool\_calls 允许模型在同一轮提出多个函数调用；应用只应并行执行已授权且相互独立的操作。它不自动提升限流配额，也不代表多条 HTTP 请求。

## 安全边界

固定工具白名单、校验类型和业务范围，对读写权限分离。对外发送、付费、删除和权限变更等副作用应设置确认及幂等控制。工具输出可能含不可信文本，不得将其作为新的系统指令。

## 官方参考

* [OpenAI 函数调用](https\://developers.openai.com/api/docs/guides/function-calling)
* [OpenAI 网络搜索](https\://developers.openai.com/api/docs/guides/tools-web-search)