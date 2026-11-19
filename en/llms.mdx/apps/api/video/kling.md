# Kling video

## Endpoint overview

Kling’s official new video API uses capability/model paths, settings/options, and unified task queries\:

| Operation      | Current official endpoints                       | Documentation                                      |
| -------------- | ------------------------------------------------ | -------------------------------------------------- |
| Text-to-video  | `POST /text-to-video/kling-3.0`                  | [Create](/simidoc/en/apps/api/video/kling/text-create) / [Query](/simidoc/en/apps/api/video/kling/text-status)   |
| Image-to-video | `POST /image-to-video/kling-3.0`                 | [Create](/simidoc/en/apps/api/video/kling/image-create) / [Query](/simidoc/en/apps/api/video/kling/image-status) |
| Query          | `GET /tasks?task_ids=...` or external\_task\_ids | General task query                                 |

Examples connect directly to `https://api-singapore.klingai.com` using official Kling API-key Bearer authentication. Legacy account AK/SK + HS256 JWT applies only to the legacy design; SimiRouter keys or raw SecretKeys are not Kling keys.

## Do not mix protocol generations

The legacy `/v1/videos/text2video`, `/v1/videos/image2video` endpoints use model\_name, task\_id, task\_status, and succeed; the new protocol uses models in paths, data.id, status, and succeeded. Legacy endpoints remain officially referenced, but do not add their fields to new requests. SimiRouter’s `/kling/...` is a gateway mapping requiring channel-version confirmation; do not merely prefix the new official path.

Generation is asynchronous, not SSE. Poll after creation or receive a callback; consume video items in outputs only after successful termination.

## Official reference

[Kling text-to-video](https\://kling.ai/document-api/apiReference/model/textToVideo), [Image-to-video](https\://kling.ai/document-api/apiReference/model/imageToVideo), [Authentication](https\://kling.ai/document-api/api/get-started/authentication).