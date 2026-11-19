# Files and content understanding

File workflows have two layers\: upload APIs manage resources, while model-input APIs read file content and generate answers. Attaching a file to a generation request does not store it as a reusable resource.

## Overview

| What you want to do                  | Input method                        | Where the file goes      | Upload first?               |
| ------------------------------------ | ----------------------------------- | ------------------------ | --------------------------- |
| Have the model read a PDF            | Inline Base64 or a reachable URL    | Only inside this request | No                          |
| Reuse a file across several requests | file\_id or a vendor file reference | Vendor file resource     | Yes (official Files API)    |
| Preprocess large or numerous files   | Upload, then wait for processing    | Vendor file resource     | Yes, and it has a lifecycle |

## Core concepts

* **Inline input**\: the file is encoded into the request body and sent with the message. It ends with the request, there is no file\_id, and there is no later delete step.
* **File resource**\: upload first to obtain an id, then reference it in multiple requests. The resource has an owner, an expiry, and a quota, and must be deleted explicitly.
* **Lifecycle**\: a finished upload is neither a finished text extraction nor a model that already understands the file; poll until it is processable before reasoning over it.
* **Size and format**\: limits are set separately for file size, page count, and duration; compressing an image does not convert its file type, and scanned PDFs still need OCR capability.
* **Data retention**\: vendors differ on how they retain file content and recognition results; for sensitive material, confirm authorization and deletion methods first.

## Requests and capabilities

| Purpose                                            | Request                                       | Boundary                                                                               |
| -------------------------------------------------- | --------------------------------------------- | -------------------------------------------------------------------------------------- |
| [PDF content understanding](/simidoc/en/apps/api/upload/file-recognition)    | POST /v1/responses + input\_file              | Inline Base64; no Files API required.                                                  |
| Chat PDF input                                     | POST /v1/chat/completions + type=file         | Uses Chat’s file object, not the Responses structure.                                  |
| [Files API](/simidoc/en/apps/api/pending/files)                      | /v1/files                                     | Not implemented in the gateway; official native uploads do not imply platform support. |
| [Gemini media understanding](/simidoc/en/apps/api/chat/gemini-media) | POST /v1beta/models/\{model}\:generateContent | inlineData or applicable fileData.                                                     |

## Request mode

Inline understanding can return synchronous JSON or streamed text events; both are one model request. Some official upload or preprocessing workflows wait for resources to become usable. This is a resource lifecycle, not automatic background model execution. Multiple files can share one supported request or use parallel requests, with different context, cost, and total-size limits.

Before uploading sensitive files, confirm authorization and provider data policies. Select relevant pages or excerpts from large documents rather than increasing input without limit. Preserve uncertainty in recognition results; manually verify important amounts, identifiers, and legal or medical conclusions.

## Simulated call

Inline understanding completes in one request, with the file carried as Base64 inside `input_file`\:

```json
{
  "model": "gpt-5.5",
  "input": [
    {
      "role": "user",
      "content": [
        { "type": "input_text", "text": "总结这份合同的付款条款。" },
        { "type": "input_file", "filename": "contract.pdf", "file_data": "data:application/pdf;base64,JVBERi0xLjQK..." }
      ]
    }
  ]
}
```

The response is an ordinary model message, and the result sits in `output_text`\:

```json
{
  "status": "completed",
  "output": [
    {
      "type": "message",
      "content": [
        { "type": "output_text", "text": "（示意）合同约定分三期付款……" }
      ]
    }
  ]
}
```

Nothing is uploaded and no reusable file\_id appears; asking about the same file again means resubmitting the Base64 or switching to official file resources.

## Official reference

* [OpenAI file input](https\://developers.openai.com/api/docs/guides/file-inputs)
* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [Google file input](https\://ai.google.dev/gemini-api/docs/file-input-methods)