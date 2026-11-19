# Veo video (Gemini API preview models retired)

## Overview

Veo generates video through a Gemini API long-running operation\: call `predictLongRunning` to start a task, get the operation name, then poll that operation and download an MP4 from the file URI in the response when it completes.

**On the Gemini API, preview models such as `veo-3.1-generate-preview` and `veo-3.1-fast-generate-preview` were retired on 2026-10-22.** This page keeps the protocol structure for understanding existing calls and as a migration reference; the endpoint is no longer usable as a production interface. Migrate to `gemini-omni-1.2-flash`, or use a GA model on the Gemini Enterprise Agent Platform.

| What you want to do    | Input                                                | Output                   | Endpoint                                            |
| ---------------------- | ---------------------------------------------------- | ------------------------ | --------------------------------------------------- |
| Start video generation | Prompt, first frame, last frame, or reference images | Operation name           | `POST /v1beta/models/{MODEL_ID}:predictLongRunning` |
| Query the operation    | Operation name                                       | `done`, result, or error | `GET /v1beta/{operation_name}`                      |
| Download the video     | File URI in the result                               | MP4 bytes                | `GET {video.uri}`                                   |

## Core concepts

* **An operation is not a task ID**\: the creation response returns `name`, for example `models/veo-3.1-generate-preview/operations/...`. Use this full name for polling, reading results, and troubleshooting.
* **Completion requires `done: true`**\: `done: false` only means processing continues. With `done: true`, also check whether an `error` exists and whether `response.generateVideoResponse.generatedSamples[0].video.uri` is empty.
* **Duration range**\: the vendor states at least 11 seconds and up to 6 minutes at peak. Poll at 10–15 second intervals and set a client-side overall wait limit.
* **Duration and resolution are linked**\: duration has only three values, 4, 6, and 8 seconds. With 1080p, 4k, reference images, or video extension, duration must be 8 seconds; you cannot change a 4-second request directly to 1080p.
* **Audio is generated with the model**\: the Gemini API documentation describes audio as always on, with no separate `generateAudio` switch. Prompts can include dialogue, sound effects, and ambient sound.
* **Billing differs by platform**\: the Gemini API and the Agent Platform have separate billing and quota systems, and unit prices follow the vendor's pricing page. After the preview models were retired, new calls should no longer incur charges.

## Specifications and capabilities

| Metric          | Gemini API preview models                                                                                                                                                                                     | Agent Platform GA models                                                                         |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Model ID        | `veo-3.1-generate-preview`, `veo-3.1-fast-generate-preview`, `veo-3.1-lite-generate-preview`; `veo-3.0-generate-001`, `veo-3.0-fast-generate-001`. The Gemini API documentation marks these IDs as Deprecated | `veo-3.1-generate-001`, `veo-3.1-fast-generate-001` (GA); `veo-3.1-lite-generate-001` is Preview |
| Resolution      | Default `720p`; `1080p` and `4k` are limited to 8 seconds                                                                                                                                                     | Standard models output `720p`, `1080p`, `4K`; Fast models output `720p`, `1080p`                 |
| Aspect ratio    | `16:9`, `9:16`                                                                                                                                                                                                | `16:9`, `9:16`                                                                                   |
| Duration        | `4`, `6`, `8` seconds                                                                                                                                                                                         | `4`, `6`, `8` seconds; reference-image mode is 8 seconds only                                    |
| Audio           | Natively generated, always on                                                                                                                                                                                 | The capability table lists sound generation                                                      |
| Reference media | `image` first frame, `lastFrame` last frame, up to 3 `referenceImages`                                                                                                                                        | Asset reference images, first and last frames                                                    |
| Video extension | Adds 7 seconds per call, up to 20 times; input up to 141 seconds, output up to 148 seconds; 720p only                                                                                                         | Extension is supported; parameters follow the platform documentation                             |

Resolution and duration are not independent options\: 1080p, 4k, reference images, and extension all require 8 seconds; 4 or 6 seconds can only use 720p. At most 3 reference images are allowed, and the first and last frames constrain the picture rather than serving as style references. Audio is always generated and cannot be disabled through a parameter. After migrating to the Agent Platform, the model IDs, authentication, and quotas all change, so you cannot keep using this page's endpoint by simply swapping in a GA model name.

## Call workflow

1. Confirm the platform and credentials. The Gemini API uses `x-goog-api-key`; the Agent Platform uses its own authentication, and the two are not interchangeable.
2. Submit to `POST /v1beta/models/{MODEL_ID}:predictLongRunning` with `instances` and `parameters`. Put the prompt in `instances[0].prompt` and the first frame in `instances[0].image`.
3. Save the `name` from the response. A successful creation only means the operation was created, not that the video is downloadable.
4. Poll `GET /v1beta/{operation_name}` until `done: true`. If an `error` exists, stop according to the error rather than continuing to wait.
5. Read the download address from `response.generateVideoResponse.generatedSamples[0].video.uri`, request that URI with the API key, and allow HTTP redirects.
6. Copy the file to your own storage. The official documentation says generated videos are retained for 2 days, and an extension reference resets the timer; do not rely on a long-lived vendor URL.

## Simulated call

The following archive illustration shows the payload structure of the original Gemini API. The preview models were retired on 2026-10-22, so it does not create new tasks today; the operation name and URL are illustrative values.

Start request\:

```json
{
  "instances": [
    {
      "prompt": "示例：海边日落，镜头缓慢推进。"
    }
  ],
  "parameters": {
    "aspectRatio": "16:9",
    "resolution": "720p",
    "numberOfVideos": 1,
    "durationSeconds": 8,
    "personGeneration": "allow_all"
  }
}
```

The creation response contains only the operation name\:

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": false
}
```

The completed operation response\:

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": true,
  "response": {
    "generateVideoResponse": {
      "generatedSamples": [
        {
          "video": {
            "uri": "https://example.com/demo-veo.mp4"
          }
        }
      ]
    }
  }
}
```

If `done: true` but there are no `generatedSamples` or the URI is empty, treat it as a failure and keep the operation name.

## Access and session

* **Base URL**\: `https://generativelanguage.googleapis.com/v1beta`.
* **Auth header**\: `x-goog-api-key: PASTE_API_KEY_HERE`, sent together with `Content-Type: application/json`.
* **Two addresses**\: direct Gemini API access uses `https://generativelanguage.googleapis.com/v1beta` with the `x-goog-api-key` header; use `https://api.dwchainless.com` and `Authorization: Bearer` plus this site's key only when the channel explicitly confirms this gateway mapping; do not assume that replacing the address and authentication is sufficient. If SimiRouter provides a model with the same name, the path, fields, and polling method depend on the channel mapping. GA models on the Agent Platform use regional addresses such as `https://{region}-aiplatform.googleapis.com` and project authentication; that is neither a `generativelanguage` address nor a model-string substitution.
* **Timeout and idempotency**\: after a start-request timeout, first check whether an operation was created; saving `name` matters more than saving the HTTP status. Do not restart the same task just because the wait is long.
* **Migration note**\: the interface shape of `gemini-omni-1.2-flash` differs from `predictLongRunning`, so existing polling code may have to be rewritten. Before migrating, rely on the official migration documentation and the model list available to your account.

## Official references

* [Gemini API\: Veo video generation](https\://aistudio.google.com/docs/veo)
* [Veo 3.1 preview model retirement note](https\://aistudio.google.com/docs/models/veo-3.1-generate-preview)
* [Gemini Enterprise Agent Platform\: Veo 3.1](https\://docs.cloud.google.com/gemini-enterprise-agent-platform/models/veo/3-1-generate)