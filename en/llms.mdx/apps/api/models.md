# Model lists

Model lists help configure an integration\: obtain the model ID, then consult vendor capabilities to choose chat, vision, image, audio, or tool endpoints. Visibility does not guarantee callability, and a model list is not a realtime health check.

## Overview

| What you need to confirm               | Where to look                                        | Note                                                                         |
| -------------------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------- |
| Which model IDs exist                  | The list endpoints in this section                   | Returns only models visible to the current credentials                       |
| Whether a model can actually be called | Models and pricing plus one real request             | Visible, routable, and funded are three different things                     |
| Which inputs and outputs it supports   | Model capability documentation                       | List metadata is usually incomplete                                          |
| When it shuts down                     | The vendor’s official deprecation or shutdown notice | Deprecation is not immediate unavailability, but do not add new integrations |

## Core concepts

* **Model ID**\: the unique identifier used in request bodies. It is usually case-sensitive and must be copied in full without abbreviating. Display names, aliases, and the actual request ID may differ.
* **Visible vs. callable**\: the list only reflects models within your permissions; requests still fail when a channel is unconfigured, the balance is insufficient, or rate limits apply.
* **Context window**\: the input-plus-output Token limit, per model; list endpoints often do not return it.
* **Billing unit**\: text models mostly bill per Token, image models per image or per Token, video models per second or per request; it can differ even within one model family.
* **Shutdown date**\: the date the vendor plans to stop serving. Migration should finish before that date, not be discovered after it.

## List endpoints

| Documentation             | Request            | Response structure                           |
| ------------------------- | ------------------ | -------------------------------------------- |
| [OpenAI format](/simidoc/en/apps/api/models/openai) | GET /v1/models     | data\[].id, for OpenAI-compatible clients.   |
| [Gemini format](/simidoc/en/apps/api/models/gemini) | GET /v1beta/models | models\[].name, for Gemini-protocol clients. |

## Request mode

Listing is a synchronous JSON request, not SSE or an asynchronous task. Different accounts may query concurrently, but credentials and results must remain separate. Expire cached lists and refresh when models become unavailable; do not send actual generation requests merely to refresh a list.

## Simulated call

Send a GET request with no body. This example shows a SimiRouter gateway response\:

```bash
curl "https://api.dwchainless.com/v1/models" \
  -H "Authorization: Bearer $SIMIROUTER_API_KEY"
```

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

The gateway returns a context length and endpoint types. The length may be a platform default. Check the model documentation for pricing, input and output modalities, and tool support. An empty list usually means no models are visible to the current credentials.

## Metadata boundaries

OpenAI model objects contain id, object, created, and owned\_by; native Google objects may include methods and token limits. The gateway may return reduced metadata, so missing fields do not justify guessing context limits, modalities, or tool support.

## Official reference

* [OpenAI Models API](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [Google Models API](https\://ai.google.dev/api/models)