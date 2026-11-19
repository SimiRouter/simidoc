# Other capabilities and integration references

This section collects endpoints not yet offered as general SimiRouter capabilities\: embeddings, files, fine-tuning, Realtime, moderation, and reranking. The difference from launched capabilities is not protocol difficulty but whether the gateway provides routing, authentication, and billing.

## Overview

Check the status first, then decide whether to write code. Being in this section does not mean the status is the same.

| Status                        | Meaning                                                                                               | What you can do now                                                             |
| ----------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Explicitly unsupported        | The gateway does not provide this capability, and it will not become available by changing the domain | Only use vendor-direct references with a vendor key                             |
| Not currently supported       | Not open yet, though the protocol itself is stable                                                    | Validate against vendor-direct references; do not document it as a gateway call |
| Channel confirmation required | Availability depends on the account and channel configuration                                         | Confirm the model and route first, then decide whether to depend on it          |

## Core concepts

* **Direct references**\: the addresses and authentication in this section's examples belong to the vendor. Replacing `api.openai.com` with the gateway domain does not make a capability available; paths, field mappings, and permissions all require explicit channel support.
* **Key ownership**\: vendor keys and SimiRouter keys are not interchangeable. Direct examples must use the corresponding vendor key; a gateway key cannot be substituted.
* **Resource ownership**\: file IDs, task IDs, and session IDs are held by the project or organization that created them, and cannot be reused across vendors or projects.
* **Status and billing**\: asynchronous tasks return an ID first, then status is queried; successful creation is not successful execution, and cancelling a task does not reverse usage already incurred.

## Capabilities

| Category        | SimiRouter status                       | Protocol type                                                     | Reference                           |
| --------------- | --------------------------------------- | ----------------------------------------------------------------- | ----------------------------------- |
| Embeddings      | Not currently supported                 | Synchronous vector responses; separate batch jobs                 | [Embeddings](/simidoc/en/apps/api/pending/embeddings)          |
| File management | Unsupported                             | Upload, listing, metadata, download, and deletion                 | [Files](/simidoc/en/apps/api/pending/files)                    |
| Fine-tuning     | Unsupported                             | Create asynchronous training jobs, status, and events             | [Fine-tuning](/simidoc/en/apps/api/pending/fine-tuning)        |
| Realtime        | Dedicated channel confirmation required | Stateful WebRTC / WebSocket sessions                              | [Realtime](/simidoc/en/apps/api/pending/realtime)              |
| Moderation      | Model and route confirmation required   | Synchronous safety classification, not a chat-filtering guarantee | [Content moderation](/simidoc/en/apps/api/pending/moderations) |
| Reranking       | Model and route confirmation required   | Synchronous document-relevance ranking                            | [Reranking](/simidoc/en/apps/api/pending/rerank)               |

For music APIs, see [Music (unsupported)](/simidoc/en/apps/api/music). Realtime sessions, uploaded resources, and training jobs commonly involve extra permissions, storage, and cost. Define data retention and deletion policies before integration.