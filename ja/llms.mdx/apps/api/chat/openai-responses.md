# Responses API

## API の説明

`POST /v1/responses` は Chat の choices/message ではなく入力項目と出力項目を使用し、ツール呼び出し、マルチモーダル、構造化出力に適しています。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。OpenAI への公式直接接続先は `https://api.openai.com` で、同じ Bearer 認証でも OpenAI のキーに置き換える必要があります。アクセス可能で目的の機能に対応するモデルを選択してください。

ゲートウェイには応答作成 API はありますが、汎用の `GET /v1/responses/{id}` やキャンセル API はありません。そのため `background: true` の OpenAI ネイティブ非同期フローはこの接続には使えません。同期または SSE を使用します。バックグラウンドが必要なら、作成・照会・キャンセルを備える公式への直接接続を使用してください。

## クイックスタート

1. **設定を準備する**：API キー管理 でキーを作成し、モデル料金 から Responses に対応した完全なモデル ID をコピーします。
2. **最小リクエストを送る**：短いテキストを `input` として送信し、`stream` は `false` のままにします。まず認証、モデル、パラメータが有効か確認します。
3. **結果を読む**：HTTP 2xx かつ `status` が `completed` の場合のみ成功です。本文は `output[].content[]` のうち `type=output_text` の項目にあります。
4. **検証する**：`error`、`incomplete_details`、実際の内容を確認し、使用ログと照合します。

```bash
API_URL="https://api.dwchainless.com/v1/responses"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "input": "用一句话解释机器学习。",
    "stream": false
  }'
```

`PASTE_API_KEY_HERE` と `MODEL_ID` を実際の値に置き換えます。確認できたら、ツールや構造化出力を追加するか、ストリーミングを有効にします。

## リクエストパラメータ

コンテンツタイプは `application/json`。

| フィールド                                                 | 型                        | 必須   | 説明                                                                                                           |
| ----------------------------------------------------- | ------------------------ | ---- | ------------------------------------------------------------------------------------------------------------ |
| model                                                 | string                   | はい   | ゲートウェイでは必須。Responses 対応モデルを選択。                                                                               |
| input                                                 | string / array           | 条件付き | テキストまたは入力項目配列。通常生成には入力が必要で、利用可能な履歴と併用できます。                                                                   |
| input\[].role                                         | string                   | 条件付き | メッセージロール：user、assistant、system、developer。                                                                    |
| input\[].content\[].type                              | string                   | 条件付き | input\_text、input\_image、input\_file などの型付き内容。                                                               |
| input\[].content\[].text                              | string                   | 条件付き | type=input\_text のテキスト。                                                                                      |
| input\[].content\[].image\_url                        | string                   | 条件付き | type=input\_image の画像 URL または data URL。                                                                      |
| input\[].content\[].file\_data / file\_url / file\_id | string                   | 条件付き | type=input\_file ではファイルソースを 1 つ選択。ファイル認識を参照。                                                                 |
| instructions                                          | string                   | いいえ  | 高優先度の指示。previous\_response\_id を使用しても必要な指示を再指定します。                                                           |
| max\_output\_tokens                                   | integer                  | いいえ  | 推論 Token を含む出力 Token 合計上限。                                                                                   |
| stream                                                | boolean                  | いいえ  | true でイベント型付き SSE ストリームを返します。                                                                                |
| previous\_response\_id                                | string                   | いいえ  | 前の応答 ID。上流状態保持と同じアクセス可能文脈に依存します。conversation と併用しないでください。                                                    |
| conversation                                          | string / object          | いいえ  | 会話オブジェクトまたは ID。previous\_response\_id と併用できません。利用可否はチャネルによります。                                               |
| store                                                 | boolean                  | いいえ  | 上流に応答保存を要求します。ゲートウェイログの保持スイッチではありません。                                                                        |
| tools / tool\_choice                                  | array / string or object | いいえ  | 関数・提供元組み込みツールと選択ルール。                                                                                         |
| parallel\_tool\_calls                                 | boolean                  | いいえ  | 1 応答内で複数の関数呼び出しを許可するか。                                                                                       |
| reasoning                                             | object                   | いいえ  | 対応する推論モデルで effort、summary を設定可能。範囲はモデル依存。                                                                    |
| text.format                                           | object                   | いいえ  | type=json\_schema などのテキスト形式。Chat の response\_format とは異なります。                                                 |
| temperature / top\_p                                  | number                   | いいえ  | モデルが対応するサンプリングパラメータ。                                                                                         |
| truncation                                            | string                   | いいえ  | OpenAI により非推奨。context\_management の使用を推奨します。disabled（既定）は文脈超過時にエラー、auto は一部を破棄できます。ゲートウェイの対応は実際の動作で確認してください。 |
| include                                               | array                    | いいえ  | reasoning.encrypted\_content、web\_search\_call.action.sources など追加データの要求。                                    |
| metadata                                              | object                   | いいえ  | 業務関連メタデータ。機密情報の保存に使わないでください。                                                                                 |

未設定の任意フィールドは省略します。`stop`、`enable_thinking` などの互換拡張は OpenAI Responses 標準フィールドではありません。`reasoning_content` も標準出力フィールドではありません。推論出力は独立した reasoning 項目を使用し、モデル内部の思考連鎖の公開を保証しません。

### リクエスト例

```json
{
  "model": "MODEL_ID",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "用一句话解释什么是机器学习。"
        }
      ]
    }
  ],
  "max_output_tokens": 256,
  "stream": false
}
```

## 戻り値

非ストリーミングの成功は HTTP 200。主なフィールドを示します。未使用の任意状態項目は null の場合があります。

| フィールド                                                | 型                | 説明                                                                                    |
| ---------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------- |
| id / object                                          | string           | 応答 ID。object=response。                                                                |
| created\_at / model                                  | integer / string | 作成時刻（Unix 秒）とモデル。                                                                     |
| status                                               | string           | completed、incomplete、failed、queued、in\_progress、cancelled。ストリーミングとバックグラウンドの両方で出現し得ます。 |
| output\[]                                            | array            | message、reasoning、function\_call、web\_search\_call などの型付き出力項目。output\[0] に固定しないでください。 |
| output\[].type / id / status                         | string           | 出力項目の型、ID、状態（型に応じて存在）。                                                                |
| output\[].role                                       | string           | メッセージ出力は通常 assistant。                                                                 |
| output\[].content\[]                                 | array            | メッセージの内容項目。本文は type=output\_text、拒否は type=refusal。                                    |
| output\[].content\[].text / annotations              | string / array   | 本文と引用などの注釈。                                                                           |
| output\[].call\_id / name / arguments                | string           | function\_call の関連 ID、関数名、JSON 文字列の引数。                                                |
| error                                                | object / null    | 失敗情報。正常完了時は通常 null。                                                                   |
| incomplete\_details                                  | object / null    | max\_output\_tokens などの不完全理由。完全成功として扱わないでください。                                        |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | 入力、出力、合計 Token。                                                                       |
| usage.\*\_tokens\_details                            | object           | 任意のキャッシュ・推論などの用量内訳。                                                                   |

```json
{
  "id": "resp_example",
  "object": "response",
  "created_at": 1760000000,
  "model": "MODEL_ID",
  "status": "completed",
  "error": null,
  "incomplete_details": null,
  "output": [
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "机器学习让计算机从数据中学习规律，用于预测和决策。",
          "annotations": []
        }
      ]
    }
  ],
  "usage": {
    "input_tokens": 18,
    "output_tokens": 22,
    "total_tokens": 40
  }
}
```

本文を抽出するときは `output` 内の `type=message` 項目を走査し、その `content` 内の `type=output_text` の text を連結します。SDK の `output_text` は便利な集約属性であり、生の REST JSON に必ずあるフィールドではありません。

### ストリーミング応答

stream=true では SSE の `event` と `data` を解析します。response.created は応答開始、response.output\_text.delta はテキスト追加、response.output\_item.added/done は項目管理、response.function\_call\_arguments.delta はツール引数の連結です。response.completed を受信し最終 response.status を確認して初めて完全完了と判断します。response.failed、response.incomplete、error は別処理します。ネットワーク EOF だけで成功判定しないでください。

```text
event: response.output_text.delta
data: {"type":"response.output_text.delta","item_id":"msg_example","output_index":0,"content_index":0,"delta":"机器学习","sequence_number":3}

event: response.completed
data: {"type":"response.completed","response":{"id":"resp_example","object":"response","status":"completed","output":[]},"sequence_number":12}
```

## コード例

次を設定します：`SIMIROUTER_API_KEY`、`SIMIROUTER_MODEL`；`SIMIROUTER_BASE_URL` で既定のゲートウェイアドレスを変更できます。末尾に `/v1` を追加しないでください。Python 3、Node.js 18+、Go は標準ライブラリのみを使用します。curl 例の JSON は Python 3 で安全にエンコードします。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/responses'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        input: [
          {
            role: 'user',
            content: [
              {
                type: 'input_text',
                text: '用一句话解释什么是机器学习。',
              },
            ],
          },
        ],
        max_output_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/responses';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000),
      });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/responses" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "bytes"
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/responses"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## エラーコード

| HTTP ステータス | 意味または各社のエラー型   | 対処                                      |
| ---------- | -------------- | --------------------------------------- |
| 400        | 無効なリクエスト       | 必須項目、JSON、モデルパラメータ、文脈長を確認。              |
| 401        | 認証失敗           | キーの存在、有効性、所属を確認。                        |
| 403 / 404  | アクセス拒否／リソースなし  | モデル権限、リソース ID、URL を確認。                  |
| 429        | レートまたは割り当て制限   | 応答本文でレート制限と残高不足を区別します。残高不足は再試行では解消しません。 |
| 500 / 503  | サービスエラー／一時利用不可 | リクエスト識別子を保持し、一時障害のみ回数制限付きでバックオフ。        |

OpenAI のネイティブエラーには通常 `error.message`、`error.type`、`error.param`、`error.code` が含まれます。`param`、`code` は `null` の場合があり、常に存在する、または HTTP ステータスと同じとは限りません。ゲートウェイが提供元到達前に認証、ルーティング、残高エラーを返すこともあります。HTTP 200 でも status、error、incomplete\_details を確認します。SSE の失敗イベントは送信済み HTTP 状態を変えない場合があります。

長い応答やストリーミングリクエストは数十秒から数分かかることがあります。クライアント側で十分なタイムアウトを設定し、切断時は受信済みの差分と終了理由から判断して、自動で再送しないでください。429 と 5xx はまずレスポンス本文と使用ログを確認し、コンテンツポリシーによる拒否の場合はプロンプトや入力を変更し、そのまま再試行しないでください。

## 公式資料

* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI ストリームイベント](https\://developers.openai.com/api/docs/guides/streaming-responses)
* [OpenAI 会話状態](https\://developers.openai.com/api/docs/guides/conversation-state)
* [OpenAI バックグラウンドモード](https\://developers.openai.com/api/docs/guides/background)
* [OpenAI エラー処理](https\://developers.openai.com/api/docs/guides/error-codes)