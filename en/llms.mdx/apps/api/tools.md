# Tool calling

Tools connect models with data, computation, and external services. Models select tools and construct arguments; the application or vendor service executes them. Tool results and final natural-language answers are separate stages.

## Overview

| Capability           | Who executes | What you see                                  | Typical use                                             |
| -------------------- | ------------ | --------------------------------------------- | ------------------------------------------------------- |
| Client-side function | Your program | The call intent plus the result you send back | Query a database, call an internal API, decrement stock |
| Server-side search   | The vendor   | The final answer with cited sources           | Look up recent information, verify facts                |

## Core concepts

* **Tool definition**\: a name, a description of purpose, and a JSON Schema for the parameters. The clearer the description, the lower the chance the model picks the wrong tool or invents arguments.
* **Call intent**\: the model does not execute code; it returns `tool_calls`, where `arguments` is a JSON string. It may arrive in fragments during streaming, so collect it fully before parsing.
* **Execution and return**\: your program validates the arguments, runs the function, and sends the result back as a message with `role` set to `tool` and the same `tool_call_id`; only then does the model continue.
* **Server-side tool**\: retrieval happens on the vendor side. You only receive the answer and citations, cannot control the intermediate steps, and cannot apply client-side function usage to it.

## Simulated call

The field shapes for one client-side function call, the model response, and the returned result are as follows (content is illustrative)\:

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

The model returns a call intent rather than a temperature\:

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

After executing the function, append the result as a new message and request again\:

```json
{
  "role": "tool",
  "tool_call_id": "call_abc",
  "content": "{\"temp_c\": 18}"
}
```

The third response is the natural-language answer shown to the user. Throughout the chain, the model never actually reached a weather service; your program is the executor.

### Server-side search

A server-side tool takes only one round trip\: you declare the tool, the vendor performs the retrieval, and a single response contains both the retrieval record and the final answer.

```json
{
  "model": "gpt-5.5",
  "input": "查找 OpenAI 官方文档中关于 Responses API 的说明，并提供来源链接。",
  "tools": [{ "type": "web_search" }],
  "stream": false
}
```

The returned `output[]` usually shows the retrieval action first, then the final message with citations\:

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

The answer is usable only when `status` is `completed` and a `message` exists; a `web_search_call` alone means retrieval finished, not that the answer is complete. Citations come from `annotations[]` and should be displayed as-is, without rewriting the source URLs.

## Tool types

| Documentation                       | Request                                                    | Executor                                                                                  |
| ----------------------------------- | ---------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| [Function calling](/simidoc/en/apps/api/tools/function-call) | POST /v1/chat/completions; Responses format also available | The application defines JSON Schema, validates arguments, and executes its own functions. |
| [Web search](/simidoc/en/apps/api/tools/web-search)          | POST /v1/responses + web\_search                           | Vendor-hosted retrieval with webpage sources and citations.                               |

## Synchronous, streaming, and parallel execution

* **Synchronous**\: one request returns complete tool calls or a final answer. Custom functions usually require another request after application execution.
* **Streaming**\: tool names or arguments arrive in fragments. Parse only after receiving all arguments; never execute partial JSON.
* **Asynchronous**\: applications can implement background jobs for slow business tools, but must provide status and result correlation. Declaring tools does not automatically create an asynchronous service.
* **Parallel**\: parallel\_tool\_calls lets the model request multiple functions in one turn. The application should parallelize only authorized, independent operations. It does not raise rate limits or represent multiple HTTP requests.

## Security boundaries

Use a fixed allowlist, validate types and business limits, and separate read/write permissions. Sending externally, payments, deletion, and permission changes require confirmation and idempotency controls. Tool output may contain untrusted text; never treat it as new system instructions.

## Official reference

* [OpenAI function calling](https\://developers.openai.com/api/docs/guides/function-calling)
* [OpenAI web search](https\://developers.openai.com/api/docs/guides/tools-web-search)