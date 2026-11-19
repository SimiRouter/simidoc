# Embeddings (unsupported)

**SimiRouter does not currently support embedding endpoints.** This section explains vendor protocols. Examples require direct access with the respective vendor account and key.

## Overview

Embeddings map text or other model-allowed inputs into fixed-length vectors for semantic retrieval, clustering, and similarity analysis. They do not return chat answers or directly execute searches; a retrieval pipeline usually has three stages\: embedding recall of candidates, reranking for precision, and model generation of the answer. See [OpenAI embeddings](/simidoc/en/apps/api/pending/embeddings/openai) and [Gemini embeddings](/simidoc/en/apps/api/pending/embeddings/gemini) for endpoint details.

| What you want to do                         | Input                                     | Output                               | Endpoint                                                                        |
| ------------------------------------------- | ----------------------------------------- | ------------------------------------ | ------------------------------------------------------------------------------- |
| Generate text vectors                       | One or more text strings                  | Fixed-length float array             | OpenAI `POST /v1/embeddings`; Google `POST /v1beta/models/{model}:embedContent` |
| Generate vectors for images and other media | Multimodal content supported by the model | Float array in the same vector space | Only multimodal models such as `gemini-embedding-2`                             |
| Build an index in batch                     | Multiple text strings                     | Vector list aligned with input order | `batchEmbedContents` or the Batch API; asynchronous batch jobs are separate     |

## Core concepts

* **Dimensions**\: OpenAI `text-embedding-3-small` defaults to 1536 dimensions and `text-embedding-3-large` to 3072; Gemini Embedding 2 supports 128–3072 dimensions (recommended 768, 1536, or 3072), while `gemini-embedding-001` defaults to 3072. Dimensions can be lowered within the model range but not raised above its limit; both vendors tie vector-store storage and retrieval cost directly to dimensions.
* **Normalization and similarity**\: OpenAI returns unit-length vectors, so the dot product is cosine similarity; Gemini requires renormalization at dimensions other than 3072 (`gemini-embedding-2` handles it automatically, while `gemini-embedding-001` requires manual work). A vector store must fix one distance metric.
* **Index and query must be homogeneous**\: the same document set and queries must use the same model, dimensions, and task configuration. After changing the model or dimensions, the old index and new vectors are not comparable and must be rebuilt.
* **`index` is not a ranking**\: the `index` in the response only identifies which input the vector corresponds to, for alignment with the source text; relevance ranking is the job of reranking, see [Reranking](/simidoc/en/apps/api/pending/rerank).
* **Synchronous and batch**\: embeddings are synchronous requests with no SSE; large batches go through the Batch API or `batchEmbedContents`, not a forced loop of single calls.

## Simulated call

Illustrative request and response for direct OpenAI access. Use the project key `$OPENAI_API_KEY` when sending the request.

```json
{
  "model": "text-embedding-3-small",
  "input": ["文档检索的第一段文本", "如何计算两段文本的相似度"]
}
```

```json
{
  "object": "list",
  "data": [
    { "object": "embedding", "index": 0, "embedding": [0.0023, -0.0119, 0.0044] },
    { "object": "embedding", "index": 1, "embedding": [0.0011, 0.0087, -0.0026] }
  ],
  "model": "text-embedding-3-small",
  "usage": { "prompt_tokens": 12, "total_tokens": 12 }
}
```

The actual vector has 1536 floats; only the first three are shown here. `usage` bills by input tokens, independent of output length.

## Retrieval essentials

These two response structures are not the same; changing only the model name is not enough. Neither usually offers SSE or Realtime, and asynchronous batch jobs are not live vector streams. Documents and queries in one vector store should use the same model, dimensions, and normalization strategy; changing models usually requires rebuilding the index.

## Official references

* [OpenAI Embeddings](https\://developers.openai.com/api/docs/guides/embeddings)
* [OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings)
* [Google Embeddings](https\://ai.google.dev/gemini-api/docs/embeddings)