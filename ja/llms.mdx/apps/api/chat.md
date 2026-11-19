# チャットとコンテンツ生成

チャット API は、会話または 1 つの指示をモデルの出力に変換します。テキストだけで応答することも、画像・音声・ファイルを読み取ることも、外部ツールを呼び出してから回答を続けることもできます。プロトコルがリクエストとレスポンスの形を定め、モデルが利用可能な入力モダリティ、コンテキスト長、ツール機能を定めます。

## 概要

| やりたいこと                           | 選択肢                                     | ポイント                          |
| -------------------------------- | --------------------------------------- | ----------------------------- |
| 通常の Q\&A、執筆、要約                   | [Chat Completions](/simidoc/ja/apps/api/chat/openai-chat)       | 最も汎用的で、クライアントの対応が最も広い         |
| モデルに情報を調べさせ、関数を呼び出させ、構造化データを返させる | [Responses](/simidoc/ja/apps/api/chat/openai-responses)         | 型付きの入出力と組み込みツール               |
| 既存の Claude クライアントを移行する           | [Claude Messages](/simidoc/ja/apps/api/chat/claude)             | Anthropic のコンテンツブロックとツールプロトコル |
| 既存の Gemini クライアントを移行する           | [Gemini generateContent](/simidoc/ja/apps/api/chat/gemini-text) | parts によるマルチモーダル入力            |
| 旧式の補完連携を維持する                     | [Completions](/simidoc/ja/apps/api/chat/openai-completions)     | テキスト prompt のみ、段階的に廃止         |
| モデルに画像を見せ、音声を聞かせ、動画や PDF を読ませる   | [Gemini メディア理解](/simidoc/ja/apps/api/chat/gemini-media)         | 入力はメディア、出力はテキストのまま            |

すべてのプロトコルは同一のゲートウェイ認証を共有します。ベース URL は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。プロトコルを変えてもキーは変わりませんが、モデルを変える場合は、新しいモデルが必要な入力モダリティとパラメータに対応していることを確認してください。

## 中核概念

まずこれらの用語を理解してください。以降のすべてのパラメータはこれを前提としています。

* **Token（トークン）**：モデルがテキストを読み書きする際の最小の課金単位です。英語では約 4 文字、中国語では約 1〜2 文字が 1 Token と数えられ、具体的にはモデルのトークナイザーに依存します。入力 Token と出力 Token は別々に課金されます。
* **コンテキストウィンドウ（context window）**：1 回のリクエストにおける入力と出力を合わせた Token の上限です。履歴が長いほど回答に残せる余白は小さくなり、上限を超えるとリクエストが拒否されたり、切り詰められて `finish_reason` が `length` で返されたりすることがあります。
* **メッセージロール（role）**：`system` または `developer` は動作の境界を設定し、`user` はユーザー入力、`assistant` はモデル出力、`tool` はツールの実行結果を返します。ロールの順序自体が会話履歴です。
* **ステートレス**：サーバーは会話を保存しません。各リクエストで必要な履歴を毎回送り直す必要があり、履歴が長いほど費用が高くなります。
* **ストリーミング（streaming）**：サーバーは SSE で増分を逐次返し、クライアントは受信しながら描画します。短縮されるのは最初の文字までの待ち時間であり、総所要時間や総費用は変わりません。非同期タスクでもありません。
* **ツール呼び出し（tool calling）**：モデルは関数を直接実行しません。構造化された呼び出し意図を返し、プログラムがそれを実行して結果を新しいメッセージとしてモデルに戻すと、モデルが回答を続けます。

## 仕様と機能

| 指標       | 説明                                                                             |
| -------- | ------------------------------------------------------------------------------ |
| 入力モダリティ  | テキスト。画像、音声、PDF、動画はモデルに依存                                                       |
| 出力モダリティ  | テキスト。一部のモデルは構造化 JSON または画像に対応                                                  |
| コンテキスト長  | モデルごとに異なり、一般に 8K〜1M Token                                                      |
| 1 回の出力上限 | Chat は `max_completion_tokens`、Responses は `max_output_tokens` で制御し、モデルの上限にも従う |
| 同時実行     | ご利用のクォータとチャネルのレート制限で決まり、`n` や `parallel_tool_calls` とは無関係                      |
| 課金       | 入力 Token と出力 Token を別々に計算し、ツールと推論の Token は別途課金される場合がある                         |

パラメータは多ければよいわけではありません。`temperature`、`top_p`、`reasoning_effort` などのサンプリング・推論パラメータは、モデルによって対応度が異なります。ゲートウェイはこれらをチャネルにそのまま渡すため、チャネルが対応していない場合はエラーになったり無視されたりすることがあります。まず最小のリクエストを送り、その後で 1 つずつパラメータを追加してください。

## 呼び出しフロー

1. **設定を準備する**：API キー管理 でキーを作成し、モデルと価格 から完全なモデル ID をコピーします。
2. **インターフェースを選択する**：一般的な用途には Chat Completions、ツール・構造化出力・バックグラウンドモードが必要な場合は Responses、クライアントを移行する場合は対応するネイティブプロトコルを使用します。
3. **まず非ストリーミングリクエストを送る**：応答を 1 件だけ要求し、認証、モデル、パラメータが有効であることを確認してから、ストリーミングやツールを有効にします。
4. **読み取って検証する**：HTTP ステータス、`finish_reason`、拒否情報、実際の内容を確認し、その後で使用ログと費用を照合します。

## シミュレーション呼び出し

以下の最小リクエストで 3 つの形式を示します。リクエストボディ、完全なレスポンス、ストリーミングレスポンスです。数値と文言はすべて例示であり、実際のアカウントの応答ではありません。

**リクエスト**

```json
{
  "model": "gpt-5.5",
  "messages": [
    { "role": "system", "content": "You are a concise technical documentation assistant." },
    { "role": "user", "content": "Explain what a token is in three sentences." }
  ],
  "max_completion_tokens": 300,
  "stream": false
}
```

**完全なレスポンス（非ストリーミング）**

```json
{
  "id": "chatcmpl_demo_0001",
  "object": "chat.completion",
  "model": "gpt-5.5",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "A token is a small unit of text processed by the model. It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 42,
    "completion_tokens": 58,
    "total_tokens": 100
  }
}
```

**ストリーミングレスポンス（`"stream": true`）**

サーバーは SSE で増分を 1 件ずつ送信し、クライアントは `delta.content` を順に連結して `[DONE]` を受け取ると終了します。

```text
data: {"choices":[{"index":0,"delta":{"role":"assistant"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":"Token"},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" is a small unit of text processed by the model."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{"content":" It is not always a word or character, because tokenizers split text into pieces. Input and output tokens are billed separately."},"finish_reason":null}]}

data: {"choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

成功を判断する基準は「データを受信したこと」ではなく、HTTP ステータスが 2xx であること、最終的な `finish_reason` が妥当であること、連結後のテキストが完全であることです。途中でストリームが途切れた場合は、受信済みの内容で終了してください。同じ有料リクエストを自動的に再送しないでください。

## ツール呼び出し

ツール呼び出しには 2 種類があり、混同するとよく問題の原因になります。

* **クライアント側関数（function calling）**：関数シグネチャを宣言すると、モデルが呼び出し意図を返します。プログラムで実行した結果をモデルに戻します。データと実行の両方があなたの側にあります。
* **サーバー側ツール（server-side tools）**：モデル側で直接実行されます。たとえば Responses の組み込みウェブ検索です。最終的な回答と引用だけが見え、中間の取得処理は見えません。

クライアント側関数の完全な往復は次のとおりです。

```text
1. Request: declare get_weather in tools and ask, "What is the weather in Paris today?"
2. Response: finish_reason = "tool_calls"
   tool_calls[0] = { id: "call_abc", function: { name: "get_weather", arguments: "{\"city\":\"Paris\"}" } }
3. Your program runs get_weather("Paris") and receives {"temp_c": 18}
4. Send another request with the assistant tool_calls message and role = "tool", tool_call_id = "call_abc", content = "{\"temp_c\": 18}"
5. Response: the model produces its final natural-language answer from the tool result
```

要点：`arguments` はオブジェクトではなく JSON 文字列です。ツール結果には対応する `tool_call_id` を必ず付けて返す必要があります。1 ターンに複数のツール呼び出しを含めることができ、`parallel_tool_calls` が並列に要求するかどうかを制御します。ツール呼び出しは余分な Token を消費し、エラー後の再試行でも二重に課金される可能性があります。

## 呼び出し方式

* **同期・非ストリーミング**：生成が終わるまで接続を保持し、完全な JSON を一度に受け取ります。短い応答やバックエンドのバッチ処理に適しています。
* **ストリーミング**：同じリクエストで SSE によりイベントを増分で返します。終了理由と途中の切断を処理する必要があります。
* **非同期バックグラウンドタスク**：まずタスクまたはレスポンスの ID を取得し、ポーリングまたは Webhook で結果を受け取ります。OpenAI ネイティブの Responses は background ワークフローを提供しますが、当サイトのゲートウェイには対応する照会・キャンセルのエンドポイントがないため、`background` パラメータを追加するだけにしないでください。
* **並列リクエスト**：クライアントが複数の独立した HTTP リクエストを同時に送信し、成功、レート制限、費用をそれぞれ処理します。`n` は候補の数、`parallel_tool_calls` は同一ターン内の複数のツール呼び出しであり、どちらも HTTP の同時実行数を意味しません。

## 接続とセッション

通常のメッセージエンドポイントはステートレスであり、毎回必要な履歴を送る必要があります。状態を持つレスポンス ID も、上流のルーティングとデータ保持の制限を受けます。公式への直接接続では、ベンダーのドメインと認証情報の両方を変更する必要があり、モデル名の置き換えだけでは不十分です。

## 公式リファレンス

* [OpenAI テキスト生成](https\://developers.openai.com/api/docs/guides/text)
* [OpenAI バックグラウンドモード](https\://developers.openai.com/api/docs/guides/background)
* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)