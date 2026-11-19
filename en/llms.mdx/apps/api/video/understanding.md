# Video understanding

Video understanding takes existing video and returns summaries, scene descriptions, event sequences, or answers; it does not generate new video from prompts. Dots, Kimi, and Gemini support video input with different content formats, file references, and authentication.

## Vendors and protocols

| Documentation                          | Official example model | Video input                                                 | Request and response                                                          |
| -------------------------------------- | ---------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------- |
| [Dots video understanding](/simidoc/en/apps/api/video/understanding/dots)     | `dots3-note-prev`      | A model-service-accessible `video_url.url`                  | Chat Completions message arrays; final text is in `choices[].message.content` |
| [Kimi video understanding](/simidoc/en/apps/api/video/understanding/kimi)     | `kimi-k3`              | Base64 video data URLs, or Moonshot `ms://` file references | Chat Completions message arrays; final text is in `choices[].message.content` |
| [Gemini video understanding](/simidoc/en/apps/api/video/understanding/gemini) | `gemini-3.8-flash`     | Inline video data or Google-supported file URIs             | This page uses Interactions; text is in `steps[].content[]`                   |

Dots video requests use the official `api-key` header; Kimi uses Bearer; Gemini uses `x-goog-api-key`. Dots and Kimi use `video_url` as a vendor-specific multimodal extension, not a video standard supported by every OpenAI-compatible service. Sharing the `/v1/chat/completions` path does not make video payloads interchangeable.

## Synchronous, streaming, and file references

* **Non-streaming**\: one HTTP request waits for a complete textual response, without a video-generation task ID.
* **Streaming**\: SSE delivers text increments. Video download, decoding, and analysis may still precede the first event. Streaming is not continuous camera upload and does not guarantee immediate first text.
* **File references**\: upload to vendor storage first, then reference it in analysis. Upload completion is not analysis completion, and file IDs are not interchangeable across vendors.
* **Parallel requests**\: the client issues independent requests, each with its own limits, context, and usage; this is not a “parallel” body parameter.

## Preparing input

Use videos you are authorized to process. Direct public links, share pages, local paths, and Base64 are different inputs and must follow the protocol. Xiaohongshu and other share pages are not downloadable video URLs; login-protected or hotlink-protected videos may also be inaccessible to the model service.

Duration, resolution, sampled frames, and file size affect latency, tokens, and cost; consult vendor limits. Verify timestamps and event judgments against the original video; they are not exact frame-level forensic evidence or forced alignment.

## SimiRouter integration

These pages provide official direct-vendor examples requiring vendor keys. For SimiRouter, verify the account’s exact model ID, channel video mapping, and file-reference support. Official model support does not establish successful platform integration. Vendor keys and SimiRouter keys are not interchangeable.

## Official reference

* [Dots\: video input](https\://dots.ai/platform/docs#video-input)
* [Kimi K3 quickstart](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart) and [Vision models](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Google\: video understanding](https\://ai.google.dev/gemini-api/docs/video-understanding)