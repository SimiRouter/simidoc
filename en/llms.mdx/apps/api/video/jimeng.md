# Jimeng video (integration pending)

## Endpoint overview

The official Jimeng video service provides text-to-video and first-frame image-to-video through **Volcengine Visual** synchronous-to-asynchronous endpoints. It differs from **Volcengine Ark Seedance** in gateway and authentication; they do not share Bearer keys.

| Step   | Official request                                                                          | Documentation             |
| ------ | ----------------------------------------------------------------------------------------- | ------------------------- |
| Submit | POST `https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31` | [Submit task](/simidoc/en/apps/api/video/jimeng/create)   |
| Query  | POST to the same host, Action=CVSync2AsyncGetResult                                       | [Query results](/simidoc/en/apps/api/video/jimeng/status) |

This section retains the official Jimeng 3.0 Pro reference, whose official page marks it as being retired. Confirm available products and versions in the Volcengine console. SimiRouter’s Jimeng capability is an integration reference, not a guarantee of unconfigured public access.

## Authentication and asynchronous flow

Official authentication uses AK/SK HMAC-SHA256 V4 signing with Region=`cn-north-1`, Service=`cv`. Authorization is not Bearer; the signature covers method, path, query, specified headers, and body hash.

After submission returns code=10000, read data.task\_id. Query with the same req\_key and task\_id. Statuses are in\_queue, generating, done, not\_found, and expired. **done means processing ended, not necessarily success**; also check code, message, and video\_url. This endpoint has no realtime video stream or SSE.

## Official reference

[Jimeng 3.0 Pro API](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh), [Volcengine official signing implementation](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py).