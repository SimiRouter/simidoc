# Veo 動画（Gemini API プレビューモデルは提供終了）

## 概要

Veo は Gemini API の long-running operation で動画を生成します。まず `predictLongRunning` を呼び出してタスクを開始し、operation 名を取得してから、その operation をポーリングします。完了後、レスポンス内のファイル URI から MP4 をダウンロードします。

**Gemini API 上の `veo-3.1-generate-preview`、`veo-3.1-fast-generate-preview` などのプレビューモデルは 2026-10-22 に提供終了しました。** 本ページはプロトコル構造を保持し、既存の呼び出しの理解と移行の参考に供するものです。現在、このエンドポイントを利用可能な本番インターフェースとして扱うことはできません。`gemini-omni-1.2-flash` へ移行するか、Gemini Enterprise Agent Platform 上の GA モデルを使用してください。

| やりたいこと    | 入力                       | 出力            | エンドポイント                                             |
| --------- | ------------------------ | ------------- | --------------------------------------------------- |
| 動画生成を開始   | プロンプト、先頭フレーム、末尾フレーム、参考画像 | operation 名   | `POST /v1beta/models/{MODEL_ID}:predictLongRunning` |
| 操作を照会     | operation 名              | `done`、結果、エラー | `GET /v1beta/{operation_name}`                      |
| 動画をダウンロード | 結果内のファイル URI             | MP4 バイト       | `GET {video.uri}`                                   |

## 中核となる概念

* **操作（operation）はタスク ID ではない**：作成レスポンスは `name` を返します。例えば `models/veo-3.1-generate-preview/operations/...` です。ポーリング、結果の読み取り、トラブルシューティングでは、すべてこの完全な名前を使用します。
* **完了条件は `done: true`**：`done: false` は処理中であることだけを示します。`done: true` の場合も、`error` の有無、および `response.generateVideoResponse.generatedSamples[0].video.uri` が空でないかを確認します。
* **所要時間の範囲**：公式が示す生成所要時間は最短 11 秒、最大 6 分です。ポーリングは 10〜15 秒間隔で行い、クライアント側に全体の待機上限を設定できます。
* **長さと解像度は連動する**：長さは 4、6、8 秒の 3 段階のみです。1080p、4k、参考画像、動画延長を使用する場合、長さは 8 秒でなければなりません。4 秒のリクエストをそのまま 1080p に変更することはできません。
* **音声はモデルとともに生成される**：Gemini API のドキュメントでは音声は常に有効と説明されており、独立した `generateAudio` スイッチはありません。プロンプトにはセリフ、効果音、環境音を記述できます。
* **課金はプラットフォームごとに異なる**：Gemini API と Agent Platform は 2 つの課金・クォータ体系であり、単価はベンダーの価格ページに従います。プレビューモデルの提供終了後は、新たな呼び出し費用が発生しないはずです。

## 仕様と能力

| 指標     | Gemini API プレビューモデル                                                                                                                                                                       | Agent Platform GA モデル                                                                        |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| モデル ID | `veo-3.1-generate-preview`、`veo-3.1-fast-generate-preview`、`veo-3.1-lite-generate-preview`。`veo-3.0-generate-001`、`veo-3.0-fast-generate-001`。Gemini API のドキュメントはこれらの ID を Deprecated と表示 | `veo-3.1-generate-001`、`veo-3.1-fast-generate-001`（GA）。`veo-3.1-lite-generate-001` は Preview |
| 解像度    | 既定は `720p`。`1080p` と `4k` は 8 秒のみ                                                                                                                                                         | 標準モデルは `720p`、`1080p`、`4K` を出力。Fast モデルは `720p`、`1080p` を出力                                  |
| アスペクト比 | `16:9`、`9:16`                                                                                                                                                                             | `16:9`、`9:16`                                                                                |
| 長さ     | `4`、`6`、`8` 秒                                                                                                                                                                             | `4`、`6`、`8` 秒。参考画像モードは 8 秒のみ                                                                 |
| 音声     | ネイティブ生成で常に有効                                                                                                                                                                              | 能力表に音声生成を記載                                                                                  |
| 参照素材   | `image` 先頭フレーム、`lastFrame` 末尾フレーム、最大 3 枚の `referenceImages`                                                                                                                               | アセット参考画像、先頭・末尾フレーム                                                                           |
| 動画延長   | 1 回につき 7 秒追加、最大 20 回。入力は最大 141 秒、出力は最大 148 秒。720p のみ                                                                                                                                      | 延長能力に対応。パラメータはプラットフォームのドキュメントに従う                                                             |

解像度と長さは独立した選択肢ではありません。1080p、4k、参考画像、延長はいずれも 8 秒が必要で、4 秒または 6 秒は 720p としか組み合わせられません。参考画像は最大 3 枚で、先頭フレームと末尾フレームは画面の制約であり、スタイルの参考ではありません。音声は常に生成され、パラメータで無効にできません。Agent Platform へ移行すると、モデル ID、認証、クォータが別体系になるため、本文のエンドポイントを GA モデル名に置き換えるだけで使い続けることはできません。

## 呼び出しフロー

1. プラットフォームと認証情報を確認します。Gemini API は `x-goog-api-key` を使用し、Agent Platform はプラットフォーム独自の認証方式を使用します。両者は相互に交換できません。
2. `POST /v1beta/models/{MODEL_ID}:predictLongRunning` に `instances` と `parameters` を送信します。プロンプトは `instances[0].prompt` に、先頭フレームは `instances[0].image` に置きます。
3. レスポンスの `name` を保存します。作成の成功は操作が確立されたことだけを示し、動画をダウンロードできることは示しません。
4. `GET /v1beta/{operation_name}` を `done: true` になるまでポーリングします。`error` が存在する場合は、エラー内容に従って終了し、待機を続けないでください。
5. `response.generateVideoResponse.generatedSamples[0].video.uri` からダウンロードアドレスを読み取り、API キーを付けてその URI をリクエストし、HTTP リダイレクトを許可します。
6. ファイルを自分のストレージへ転送保存します。公式ドキュメントによると生成動画の保持期間は 2 日で、延長参照はタイマーをリセットします。長期間有効なベンダー URL に依存しないでください。

## シミュレーション呼び出し

以下はアーカイブ用の例示で、元の Gemini API のメッセージ構造を説明するものです。プレビューモデルは 2026-10-22 に提供終了したため、現在これに基づいて新しいタスクが生成されることはありません。operation 名と URL はすべて例示値です。

開始リクエスト：

```json
{
  "instances": [
    {
      "prompt": "示例：海边日落，镜头缓慢推进。"
    }
  ],
  "parameters": {
    "aspectRatio": "16:9",
    "resolution": "720p",
    "numberOfVideos": 1,
    "durationSeconds": 8,
    "personGeneration": "allow_all"
  }
}
```

作成レスポンスには操作名のみが含まれます：

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": false
}
```

完了後の操作レスポンス：

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": true,
  "response": {
    "generateVideoResponse": {
      "generatedSamples": [
        {
          "video": {
            "uri": "https://example.com/demo-veo.mp4"
          }
        }
      ]
    }
  }
}
```

`done: true` でも `generatedSamples` がない、または URI が空の場合は、失敗として扱い operation 名を保存します。

## 接続とセッション

* **ベースアドレス**：`https://generativelanguage.googleapis.com/v1beta`。
* **認証ヘッダー**：`x-goog-api-key: PASTE_API_KEY_HERE`。同時に `Content-Type: application/json` を送信します。
* **2 組のアドレス**：Gemini API への直接接続では `https://generativelanguage.googleapis.com/v1beta` を使い、認証ヘッダーは `x-goog-api-key` です。`https://api.dwchainless.com` と `Authorization: Bearer` および当サイトのキーは、チャネルがこのゲートウェイへのマッピングを明示的に確認した場合だけ使用します。アドレスと認証を置き換えるだけでは不十分です。SimiRouter が同名モデルを提供する場合、パス、フィールド、ポーリング方式はチャネルのマッピングで決まります。Agent Platform の GA モデルは `https://{region}-aiplatform.googleapis.com` のようなリージョンアドレスとプロジェクト認証を使用し、`generativelanguage` のアドレスでも、モデル文字列の置き換えでもありません。
* **タイムアウトと冪等性**：開始リクエストがタイムアウトした後は、operation がすでに作成されていないかを先に確認します。HTTP ステータスを保存するよりも `name` を保存する方が重要です。待機時間が長いという理由で同じタスクを重複して開始しないでください。
* **移行のヒント**：`gemini-omni-1.2-flash` のインターフェース形態は `predictLongRunning` とは異なり、既存のポーリングコードは書き直しが必要になる場合があります。移行前に公式の移行ドキュメントとアカウントで利用可能なモデル一覧を基準にしてください。

## 公式リファレンス

* [Gemini API：Veo 動画生成](https\://aistudio.google.com/docs/veo)
* [Veo 3.1 プレビューモデルの提供終了について](https\://aistudio.google.com/docs/models/veo-3.1-generate-preview)
* [Gemini Enterprise Agent Platform：Veo 3.1](https\://docs.cloud.google.com/gemini-enterprise-agent-platform/models/veo/3-1-generate)