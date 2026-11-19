# Chat and content generation

The chat API turns a conversation or a single instruction into model output. It can answer with text alone, read images, audio, and files, or call external tools before answering. The protocol decides the shape of requests and responses; the model decides the available input modalities, context length, and tool capabilities.

## Overview

| What you want to do                                                  | Choose                                       | Key point                                    |
| -------------------------------------------------------------------- | -------------------------------------------- | -------------------------------------------- |
| Ordinary Q\&A, writing, summarization                                | [Chat Completions](/simidoc/en/apps/api/chat/openai-chat)            | Most universal, widest client support        |
| Let the model look things up, call functions, return structured data | [Responses](/simidoc/en/apps/api/chat/openai-responses)              | Typed inputs and outputs plus built-in tools |
| Migrate an existing Claude client                                    | [Claude Messages](/simidoc/en/apps/api/chat/claude)                  | Anthropic content blocks and tool protocol   |
| Migrate an existing Gemini client                                    | [Gemini generateContent](/simidoc/en/apps/api/chat/gemini-text)      | Multimodal parts input                       |
| Maintain a legacy completion integration                             | [Completions](/simidoc/en/apps/api/chat/openai-completions)          | Text prompts only, being phased out          |
| Let the model read images, hear audio, watch video, or read PDFs     | [Gemini media understanding](/simidoc/en/apps/api/chat/gemini-media) | Input is media, output is still text         |

All protocols share one gateway authentication\: base URL `https://api.dwchainless.com` and header `Authorization: Bearer $SIMIROUTER_API_KEY`. Switching protocols does not change the key, but switching models requires confirming the new model supports the input modalities and parameters you need.

## Core concepts

Understand these terms first; every parameter below depends on them.

* **Token**\: the smallest billing unit for text the model reads and writes. Roughly 4 English characters or 1 to 2 Chinese characters count as one token, depending on the model tokenizer. Input tokens and output tokens are priced separately.
* **Context window**\: the combined input-plus-output token limit for one request. Longer history leaves less room for the answer; exceeding the limit can reject the request or truncate it and return `finish_reason` as `length`.
* **Message role**\: `system` or `developer` sets behavioral boundaries, `user` is user input, `assistant` is model output, and `tool` returns a tool result. The order of roles is itself the conversation history.
* **Stateless**\: the server does not store your conversation. Every request must resend the needed history, and longer history costs more.
* **Streaming**\: the server returns increments over SSE so the client can render as it receives. It reduces time to first token, not total duration or cost, and it is not an asynchronous task.
* **Tool calling**\: the model does not execute functions. It returns a structured call intent; your program executes it and sends the result back as a new message, and the model continues.

## Specifications and capabilities

| Indicator                 | Description                                                                                       |
| ------------------------- | ------------------------------------------------------------------------------------------------- |
| Input modalities          | Text; images, audio, PDF, and video depend on the model                                           |
| Output modalities         | Text; some models support structured JSON or images                                               |
| Context length            | Model-specific, commonly 8K to 1M tokens                                                          |
| Per-response output limit | Chat uses `max_completion_tokens`, Responses uses `max_output_tokens`, bounded by the model limit |
| Concurrency               | Set by your quota and channel rate limits, unrelated to `n` and `parallel_tool_calls`             |
| Billing                   | Input and output tokens priced separately; tool and reasoning tokens may be billed separately     |

More parameters is not better\: `temperature`, `top_p`, `reasoning_effort`, and other sampling or reasoning parameters are supported to different degrees across models. The gateway passes them through to the channel; unsupported ones may error or be ignored. Send a minimal request first, then add parameters one at a time.

## Call flow

1. **Prepare configuration**\: create a key in API key management and copy the full model ID from models and pricing.
2. **Choose the interface**\: Chat Completions for general use; Responses when you need tools, structured output, or background mode; the native protocol when migrating a client.
3. **Send a non-streaming request first**\: request a single reply to confirm authentication, model, and parameters, then enable streaming or tools.
4. **Read and validate**\: check the HTTP status, `finish_reason`, refusal information, and actual content, then verify the usage log and cost.

## Simulated call

The following minimal request shows three shapes\: the request body, the full response, and a streamed response. All values and text are illustrative, not a real account response.

**Request**

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

**Full response (non-streaming)**

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

**Streamed response (`"stream": true`)**

The server pushes increments as SSE events. The client concatenates `delta.content` in order and stops at `[DONE]`\:

```text
data: {"choices":[{"index":0,"delta":{"role":"assistant"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":"Token"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" is a small unit of text processed by the model."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

Success is not "some data arrived". It means HTTP 2xx, a sensible final `finish_reason`, and complete concatenated text. If the stream breaks, finish with what you received rather than automatically resending the same paid request.

## Tool calling

Tool calling comes in two kinds, and mixing them up is a common source of bugs\:

* **Client-side functions (function calling)**\: you declare the function signature, the model returns a call intent, your program executes it and returns the result. Both data and execution stay on your side.
* **Server-side tools**\: executed on the model side, such as the built-in web search in Responses. You only see the final answer and citations, not the intermediate retrieval.

A complete client-side function round trip looks like this\:

```text
1. Request: declare get_weather in tools and ask, "What is the weather in Paris today?"
2. Response: finish_reason = "tool_calls"
   tool_calls[0] = { id: "call_abc", function: { name: "get_weather", arguments: "{\"city\":\"Paris\"}" } }
3. Your program runs get_weather("Paris") and receives {"temp_c": 18}
4. Send another request with the assistant tool_calls message and role = "tool", tool_call_id = "call_abc", content = "{\"temp_c\": 18}"
5. Response: the model produces its final natural-language answer from the tool result
```

Key points\: `arguments` is a JSON string, not an object; the tool result must carry the matching `tool_call_id`; one turn may contain several tool calls, and `parallel_tool_calls` controls whether they are requested in parallel. Tool calling consumes extra tokens, and retries after errors may be billed again.

## Invocation modes

* **Synchronous, non-streaming**\: the connection stays open until generation ends and returns one complete JSON body. Good for short replies and backend batch jobs.
* **Streaming**\: the same request returns events incrementally over SSE. You must handle termination reasons and mid-stream breaks.
* **Asynchronous background tasks**\: obtain a task or response ID, then collect the result via polling or a webhook. Native OpenAI Responses offers a background workflow, but this gateway has no matching retrieval or cancel endpoint, so do not simply add the `background` parameter.
* **Parallel requests**\: the client sends several independent HTTP requests and handles success, rate limiting, and cost separately. `n` is the number of candidates, and `parallel_tool_calls` is multiple tool calls within one turn; neither equals HTTP concurrency.

## Access and sessions

Ordinary message endpoints are stateless; send the needed history each time. Stateful response IDs are also subject to upstream routing and data retention limits. A vendor-direct connection must change both the vendor domain and the credentials; replacing only the model name is not enough.

## Official references

* [OpenAI text generation](https\://developers.openai.com/api/docs/guides/text)
* [OpenAI background mode](https\://developers.openai.com/api/docs/guides/background)
* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)