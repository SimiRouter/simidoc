# Files API (unsupported)

The Files API is OpenAI's resource-management interface for files. Uploading returns a file ID for fine-tuning, batch processing, or other official endpoints that accept file IDs. It is not the same as a model's ability to understand file content.

**SimiRouter does not currently support Files API. The following pages retain official OpenAI descriptions and direct examples, requiring a key belonging to the OpenAI project.**

## Overview

The Files API solves "upload once, reference many times"\: a file exists first as an independent resource, then fine-tuning, batch processing, and other endpoints consume it by ID. It suits training sets, batch request bodies, and assets read repeatedly; attachments in a single conversation do not go through this API and are passed directly in the request instead.

| Use case                             | Upload tag                | What to do after upload                   |
| ------------------------------------ | ------------------------- | ----------------------------------------- |
| Supervised fine-tuning training data | `purpose=fine-tune`       | Create a training job and poll its status |
| Batch requests or output             | `purpose=batch`           | Create a batch job and poll its status    |
| Other endpoints that accept file IDs | Per endpoint requirements | Follow that endpoint's documentation      |

## Core concepts

* **File IDs and scope**\: an ID belongs to the project or organization that created it and cannot be reused across providers or projects; inserting a file ID from another service into an OpenAI request returns 404 or 403.
* **purpose determines use**\: the `purpose` at upload time declares who consumes the data (such as `fine-tune` or `batch`), and consuming endpoints also validate format, size, and line count on their own.
* **Lifecycle**\: a successful upload only means the resource exists; whether training or batch processing has completed must be checked through the corresponding job status, not inferred from the upload result.
* **Content and metadata are separate**\: `filename`, `bytes`, and `status` in the file object are metadata; the content the model sees is read by the consuming endpoint, and the two do not sync automatically.

## Endpoints and execution

| Operation                                             | Official request                  | Execution                                              |
| ----------------------------------------------------- | --------------------------------- | ------------------------------------------------------ |
| [Upload file (unsupported)](/simidoc/en/apps/api/pending/files/upload)                 | `POST /v1/files`                  | Multipart upload; synchronously returns a file object. |
| [Retrieve file information (unsupported)](/simidoc/en/apps/api/pending/files/retrieve) | `GET /v1/files/{file_id}`         | Synchronously returns metadata.                        |
| [List files (unsupported)](/simidoc/en/apps/api/pending/files/list)                    | `GET /v1/files`                   | Synchronous paginated query.                           |
| [Retrieve file content (unsupported)](/simidoc/en/apps/api/pending/files/content)      | `GET /v1/files/{file_id}/content` | Downloads file bytes, not model SSE.                   |
| [Delete file (unsupported)](/simidoc/en/apps/api/pending/files/delete)                 | `DELETE /v1/files/{file_id}`      | Deletes the resource and returns a deletion result.    |

A successful file upload does not mean its consuming job has finished. Training, batch, and indexing status are queried through their respective endpoints. File purpose, format, and size limits are also determined jointly by the consuming endpoint.

## Resources and security

File IDs belong to the creating project or organization. IDs from another provider or gateway cannot be used directly with OpenAI. Examples read keys from environment variables; never commit training data, personal information, or keys to public repositories.

## Official references

* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files)
* [OpenAI upload file](https\://developers.openai.com/api/reference/resources/files/methods/create)