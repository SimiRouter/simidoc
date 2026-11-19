# 嵌入（不支援）

**SimiRouter 暫不支援嵌入介面。** 本節用於理解廠商通訊協定，範例只能使用相應廠商帳戶與金鑰直連。

## 概覽

嵌入把文字或模型允許的其他輸入對應成定長向量，用於語義檢索、聚類和相似度分析。它不回傳聊天答案，也不直接執行搜尋；檢索流程通常由「嵌入召回候選 + 重新排序精排 + 模型生成答案」三段組成。介面與參數見[OpenAI 嵌入](/simidoc/zh-Hant/apps/api/pending/embeddings/openai)與[Gemini 嵌入](/simidoc/zh-Hant/apps/api/pending/embeddings/gemini)。

| 你要做的事     | 輸入         | 輸出           | 端點                                                                             |
| --------- | ---------- | ------------ | ------------------------------------------------------------------------------ |
| 生成文字向量    | 單條或多條文字    | 定長浮點陣列       | OpenAI `POST /v1/embeddings`；Google `POST /v1beta/models/{model}:embedContent` |
| 生成圖像等媒體向量 | 模型支援的多模態內容 | 同一向量空間中的浮點陣列 | 僅 `gemini-embedding-2` 等支援多模態的模型                                               |
| 批次建立索引    | 多條文字       | 與輸入順序對齊的向量清單 | `batchEmbedContents` 或 Batch API，非同步批任務另立                                      |

## 核心概念

* **維度**：OpenAI `text-embedding-3-small` 預設 1536 維、`text-embedding-3-large` 預設 3072 維；Gemini Embedding 2 支援 128–3072 維（建議 768、1536 或 3072），而 `gemini-embedding-001` 預設為 3072 維。維度可在模型範圍內調低，但不能超過上限；兩家都把向量庫的儲存與檢索成本直接綁定在維度上。
* **正規化與相似度**：OpenAI 回傳長度為 1 的向量，點積即餘弦相似度；Gemini 在非 3072 維時需要重新正規化（`gemini-embedding-2` 自動處理，`gemini-embedding-001` 需手動）。向量庫必須固定一種度量方式。
* **索引與查詢必須同構**：同一批文件與查詢要用同一模型、同一維度、同一任務設定。換模型或改維度後，舊索引與新向量不可比，需要重建。
* **`index` 不是排名**：回應裡的 `index` 只表示該向量對應第幾個輸入，用來和原文對齊；相關性排序是重新排序的職責，見[重新排序](/simidoc/zh-Hant/apps/api/pending/rerank)。
* **同步與批次**：嵌入是同步請求，沒有 SSE；大批量走 Batch API 或 `batchEmbedContents`，不要用迴圈單條呼叫硬湊。

## 模擬呼叫

OpenAI 官方直連請求與回應示意。送出請求時使用專案金鑰 `$OPENAI_API_KEY`。

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

實際向量有 1536 個浮點數，這裡只保留前三個；`usage` 按輸入 Token 計費，與輸出長度無關。

## 檢索使用要點

這兩套回應不是同一種結構，不能只替換模型名稱。通常沒有 SSE 或 Realtime；非同步批任務也不是即時向量流。同一向量庫的文件與查詢應使用相同模型、維度與正規化策略，更換模型後通常需要重建索引。

## 官方參考

* [OpenAI Embeddings](https\://developers.openai.com/api/docs/guides/embeddings)
* [OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings)
* [Google Embeddings](https\://ai.google.dev/gemini-api/docs/embeddings)