# 嵌入（不支持）

**SimiRouter 暂不支持嵌入接口。** 本节用于理解厂商协议，示例只能使用相应厂商账户与密钥直连。

## 概览

嵌入把文本或模型允许的其他输入映射成定长向量，用于语义检索、聚类和相似度分析。它不返回聊天答案，也不直接执行搜索；检索流程通常由“嵌入召回候选 + 重排序精排 + 模型生成答案”三段组成。具体接口与参数见[OpenAI 嵌入](/simidoc/zh/apps/api/pending/embeddings/openai)与[Gemini 嵌入](/simidoc/zh/apps/api/pending/embeddings/gemini)。

| 你要做的事     | 输入         | 输出           | 端点                                                                             |
| --------- | ---------- | ------------ | ------------------------------------------------------------------------------ |
| 生成文本向量    | 单条或多条文本    | 定长浮点数组       | OpenAI `POST /v1/embeddings`；Google `POST /v1beta/models/{model}:embedContent` |
| 生成图像等媒体向量 | 模型支持的多模态内容 | 同一向量空间中的浮点数组 | 仅 `gemini-embedding-2` 等支持多模态的模型                                               |
| 批量建立索引    | 多条文本       | 与输入顺序对齐的向量列表 | `batchEmbedContents` 或 Batch API，异步批任务另立                                       |

## 核心概念

* **维度**：OpenAI `text-embedding-3-small` 默认 1536 维、`text-embedding-3-large` 默认 3072 维；Gemini Embedding 2 支持 128–3072 维（推荐 768、1536 或 3072），而 `gemini-embedding-001` 默认 3072 维。维度可按模型范围调低，不能超过上限；两家都把向量库的存储与检索成本直接绑定在维度上。
* **归一化与相似度**：OpenAI 返回长度为 1 的向量，点积即余弦相似度；Gemini 在非 3072 维时需要重新归一化（`gemini-embedding-2` 自动处理，`gemini-embedding-001` 需手动）。向量库必须固定一种度量方式。
* **索引与查询必须同构**：同一批文档和查询要用同一模型、同一维度、同一任务配置。换模型或改维度后，旧索引与新向量不可比，需要重建。
* **`index` 不是排名**：响应里的 `index` 只表示该向量对应第几个输入，用来和原文对齐；相关性排序是重排序的职责，见[重排序](/simidoc/zh/apps/api/pending/rerank)。
* **同步与批量**：嵌入是同步请求，没有 SSE；大批量走 Batch API 或 `batchEmbedContents`，不要用循环单条调用硬凑。

## 模拟调用

OpenAI 官方直连请求与响应示意。发送请求时使用项目密钥 `$OPENAI_API_KEY`。

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

实际向量有 1536 个浮点数，这里只保留前三个；`usage` 按输入 Token 计费，与输出长度无关。

## 检索使用要点

这两套响应不是同一种结构，不能只替换模型名。通常没有 SSE 或 Realtime；异步批任务也不是实时向量流。同一向量库的文档与查询应使用相同模型、维度与归一化策略，更换模型后通常需要重建索引。

## 官方参考

* [OpenAI Embeddings](https\://developers.openai.com/api/docs/guides/embeddings)
* [OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings)
* [Google Embeddings](https\://ai.google.dev/gemini-api/docs/embeddings)