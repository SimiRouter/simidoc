# Sora video (official API closed)

**Official OpenAI Sora 2 and Videos API closed on September 24, 2026.** The following retains interface structure only, not usable integration instructions. Any same-named SimiRouter models or third-party compatible implementations require separate source, capability, and protocol verification; they are not official direct OpenAI access.

## Endpoint overview

| Operation      | Former official endpoint            | Reference            |
| -------------- | ----------------------------------- | -------------------- |
| Create task    | `POST /v1/videos`                   | [Create](/simidoc/en/apps/api/video/sora/create)   |
| Query task     | `GET /v1/videos/{video_id}`         | [Query](/simidoc/en/apps/api/video/sora/status)    |
| Download video | `GET /v1/videos/{video_id}/content` | [Content](/simidoc/en/apps/api/video/sora/content) |

The former protocol generated asynchronously, moving from queued/in\_progress to completed or failed, with no ordinary streaming generation output. The official notice states there is no one-to-one replacement API. For other video capabilities, use the [video category](/simidoc/en/apps/api/video) to select an available provider; no automatic substitution.

## Official reference

[OpenAI closure notice](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API Reference](https\://developers.openai.com/api/reference/resources/videos/methods/create).