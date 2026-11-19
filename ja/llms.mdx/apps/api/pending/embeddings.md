# 埋め込み（未対応）

**SimiRouter は現在、埋め込み API に未対応です。** この節は提供元プロトコルの説明用で、例は各社アカウント・キーによる直接接続のみです。

## 概要

埋め込みは、テキストやモデルが許可するその他の入力を固定長のベクトルに写像し、意味検索、クラスタリング、類似度分析に使用します。チャットの回答を返すことも、検索を直接実行することもありません。検索の流れは通常、「埋め込みで候補を検索して絞り込み、再ランキングで精密に並べ替え、モデルが回答を生成する」という 3 段階で構成されます。エンドポイントの詳細は[OpenAI 埋め込み](/simidoc/ja/apps/api/pending/embeddings/openai)と[Gemini 埋め込み](/simidoc/ja/apps/api/pending/embeddings/gemini)を参照してください。

| やりたいこと              | 入力                   | 出力                | エンドポイント                                                                        |
| ------------------- | -------------------- | ----------------- | ------------------------------------------------------------------------------ |
| テキストのベクトルを生成する      | 単一または複数のテキスト         | 固定長の浮動小数点配列       | OpenAI `POST /v1/embeddings`、Google `POST /v1beta/models/{model}:embedContent` |
| 画像などのメディアのベクトルを生成する | モデルが対応するマルチモーダルコンテンツ | 同じベクトル空間内の浮動小数点配列 | `gemini-embedding-2` などマルチモーダル対応モデルのみ                                          |
| インデックスを一括で構築する      | 複数のテキスト              | 入力順に対応したベクトル一覧    | `batchEmbedContents` または Batch API。非同期バッチタスクは別途                                |

## 中核となる概念

* **次元**：OpenAI の `text-embedding-3-small` はデフォルト 1536 次元、`text-embedding-3-large` はデフォルト 3072 次元です。Gemini Embedding 2 は 128〜3072 次元（768、1536、3072 を推奨）に対応し、`gemini-embedding-001` のデフォルトは 3072 次元です。モデルの範囲内で下げられますが、上限を超えることはできません。両社とも、ベクトルストアの保存と検索のコストを次元に直接結び付けています。
* **正規化と類似度**：OpenAI は長さ 1 のベクトルを返すため、内積がそのままコサイン類似度になります。Gemini は 3072 次元以外では再正規化が必要です（`gemini-embedding-2` は自動処理、`gemini-embedding-001` は手動）。ベクトルストアは 1 つの距離尺度に固定する必要があります。
* **インデックスとクエリは同型でなければならない**：同じ文書群とクエリには、同じモデル、同じ次元、同じタスク設定を使用します。モデルを変えたり次元を変更したりすると、古いインデックスと新しいベクトルは比較できなくなり、再構築が必要です。
* **`index` は順位ではない**：レスポンスの `index` は、そのベクトルが何番目の入力に対応するかを示すだけで、原文との対応付けに使用します。関連度の並べ替えは再ランキングの役割であり、[再ランキング](/simidoc/ja/apps/api/pending/rerank)を参照してください。
* **同期とバッチ**：埋め込みは同期リクエストで、SSE はありません。大量の処理には Batch API または `batchEmbedContents` を使用し、単発呼び出しをループして無理に処理しないでください。

## シミュレーション呼び出し

OpenAI へ直接接続する際のリクエストとレスポンスの例です。送信にはプロジェクトのキー `$OPENAI_API_KEY` を使用します。

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

実際のベクトルは 1536 個の浮動小数点数で、ここでは先頭の 3 つのみを保持しています。`usage` は入力 Token で課金され、出力の長さとは関係ありません。

## 検索利用時の要点

これら 2 つのレスポンスは同じ構造ではないため、モデル名だけを置き換えることはできません。通常、SSE や Realtime はなく、非同期バッチタスクもリアルタイムのベクトルストリームではありません。同じベクトルストアの文書とクエリには同じモデル、次元、正規化戦略を使用し、モデルを変更した後は通常インデックスの再構築が必要です。

## 公式リファレンス

* [OpenAI Embeddings](https\://developers.openai.com/api/docs/guides/embeddings)
* [OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings)
* [Google Embeddings](https\://ai.google.dev/gemini-api/docs/embeddings)