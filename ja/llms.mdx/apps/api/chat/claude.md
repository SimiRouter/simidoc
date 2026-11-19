# Claude Messages

## API の説明

`POST /v1/messages` は user/assistant メッセージを受け取り、テキスト、ツール呼び出し、思考ブロックで構成される Message を返します。トップレベルの system はシステム指示用です。messages に role=system の項目を作成しないでください。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。Anthropic への公式直接接続先は `https://api.anthropic.com`、認証は `x-api-key: $ANTHROPIC_API_KEY` です。例では `anthropic-version: 2023-06-01` を固定してプロトコルバージョンを選択しており、最新版を意味しません。アカウントからアクセスでき、目的の機能に対応するモデルを選択してください。

## クイックスタート

1. **設定を準備する**：API キー管理 でキーを作成し、モデル料金 から Claude Messages に対応した完全なモデル ID をコピーします。
2. **最小リクエストを送る**：ユーザーメッセージを 1 件だけ送信し、`anthropic-version` ヘッダーを維持して `stream` は `false` のままにします。
3. **結果を読む**：HTTP 2xx かつ `content[]` が空でない場合のみ成功です。本文は `type=text` のコンテンツブロックにあります。
4. **検証する**：`stop_reason`、`stop_sequence`、実際の内容を確認し、使用ログと照合します。

```bash
API_URL="https://api.dwchainless.com/v1/messages"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "anthropic-version: 2023-06-01" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "max_tokens": 256,
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

`PASTE_API_KEY_HERE` と `MODEL_ID` を実際の値に置き換えます。`anthropic-version` はプロトコルバージョンの選択に使用し、最新版を意味するものではありません。

## リクエストパラメータ

リクエスト本文は JSON です。例のヘッダーには `anthropic-version: 2023-06-01` を含めます。

| フィールド                         | 型                | 必須   | 説明                                                           |
| ----------------------------- | ---------------- | ---- | ------------------------------------------------------------ |
| model                         | string           | はい   | アクセス可能な Claude モデル ID。                                       |
| max\_tokens                   | integer          | はい   | 生成 Token 上限。通常の生成では正の整数を指定します。0 は対応するキャッシュ書き込みフロー専用です。       |
| messages                      | array            | はい   | 会話メッセージの配列。                                                  |
| messages\[].role              | string           | はい   | user または assistant。                                          |
| messages\[].content           | string / array   | はい   | テキスト文字列、またはコンテンツブロック配列。                                      |
| content\[].type               | string           | 条件付き | text、image、tool\_use、tool\_result などの種類。                     |
| content\[].text               | string           | 条件付き | text ブロックの本文。                                                |
| content\[].source             | object           | 条件付き | image のソース。base64 の media\_type/data、または url 型の url を使用。     |
| system                        | string / array   | いいえ  | システム指示。対応する場合はテキストブロックを使用できます。                               |
| stream                        | boolean          | いいえ  | true で SSE を返します。既定は非ストリーミング。                                |
| stop\_sequences               | array            | いいえ  | 独自の停止シーケンス。                                                  |
| temperature / top\_p / top\_k | number / integer | いいえ  | サンプリング設定。対応するモデルにのみ指定します。                                    |
| tools                         | array            | いいえ  | 関数ツール定義。name、description、input\_schema を含みます。                |
| tool\_choice                  | object           | いいえ  | auto、any、tool、none などのツール選択。tool の場合は name を指定。              |
| thinking                      | object           | いいえ  | 思考設定はモデル世代に依存します。adaptive、enabled などをすべてのモデルが受け付けるわけではありません。 |
| metadata.user\_id             | string           | いいえ  | アプリケーションのユーザー識別子。直接的な個人識別情報は送信しません。                          |

### リクエスト例

```json
{
  "model": "MODEL_ID",
  "max_tokens": 256,
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释机器学习。"
    }
  ],
  "stream": false
}
```

## 戻り値

HTTP 200 の非ストリーミング応答は Message です。

| フィールド                                                             | 型             | 説明                                                                              |
| ----------------------------------------------------------------- | ------------- | ------------------------------------------------------------------------------- |
| id / type                                                         | string        | メッセージ ID。type=message。                                                          |
| role / model                                                      | string        | assistant と応答モデル ID。                                                            |
| content\[]                                                        | array         | コンテンツブロック配列。すべての項目が text を持つとは限りません。                                            |
| content\[].type / text                                            | string        | type=text は text、tool\_use は id/name/input を読み取ります。                             |
| stop\_reason                                                      | string / null | end\_turn は自然終了、max\_tokens は上限到達、stop\_sequence は停止文字列への一致、tool\_use はツール実行要求。 |
| stop\_sequence                                                    | string / null | 一致した停止シーケンス。なければ null。                                                          |
| usage.input\_tokens / output\_tokens                              | integer       | 入力・出力 Token。                                                                    |
| usage.cache\_creation\_input\_tokens / cache\_read\_input\_tokens | integer       | 任意のキャッシュ書き込み・ヒット計量。単純に追加の本文として数えないでください。                                        |

```json
{
  "id": "msg_example",
  "type": "message",
  "role": "assistant",
  "model": "MODEL_ID",
  "content": [
    {
      "type": "text",
      "text": "机器学习是一种从数据中提取规律并用于预测的方法。"
    }
  ],
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 14,
    "output_tokens": 24
  }
}
```

### ストリーミング応答

stream=true では message\_start、content\_block\_start、content\_block\_delta、content\_block\_stop、message\_delta、message\_stop を順に処理します。text\_delta はテキストを追加し、input\_json\_delta はツール引数の partial\_json を追加します。連結完了後に解析してください。message\_delta は停止理由と用量更新、message\_stop はメッセージ終了を示します。HTTP 200 の後にも error イベントが発生する場合があります。

ツール利用時は受信したアシスタントのコンテンツブロックを保持し、後続の user メッセージで `{"type":"tool_result","tool_use_id":"...","content":"..."}` を使用して結果を返します。実行前に引数と権限を必ず検証してください。

## コード例

次を設定します：`SIMIROUTER_API_KEY`、`SIMIROUTER_CLAUDE_MODEL`；`SIMIROUTER_BASE_URL` で既定のゲートウェイアドレスを変更できます。末尾に `/v1` を追加しないでください。Python 3、Node.js 18+、Go は標準ライブラリのみを使用します。curl 例の JSON は Python 3 で安全にエンコードします。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_CLAUDE_MODEL"): raise RuntimeError("请设置 SIMIROUTER_CLAUDE_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    path = '/v1/messages'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={'anthropic-version': '2023-06-01', "Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
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
      if (!process.env.SIMIROUTER_CLAUDE_MODEL)
        throw new Error('请设置 SIMIROUTER_CLAUDE_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        max_tokens: 256,
        messages: [
          {
            role: 'user',
            content: '用一句话解释机器学习。',
          },
        ],
        stream: false,
      };
      body.model = process.env.SIMIROUTER_CLAUDE_MODEL;
      const endpoint = '/v1/messages';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          'anthropic-version': '2023-06-01',
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
    : "${SIMIROUTER_CLAUDE_MODEL:?请设置 SIMIROUTER_CLAUDE_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/messages" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "anthropic-version: 2023-06-01" \
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
      model := os.Getenv("SIMIROUTER_CLAUDE_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_CLAUDE_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/messages"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("anthropic-version", "2023-06-01")
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

| HTTP ステータス      | 意味または各社のエラー型                                       | 対処                                       |
| --------------- | -------------------------------------------------- | ---------------------------------------- |
| 400             | `invalid_request_error`                            | リクエスト構造、パラメータ、モデル機能が不一致。                 |
| 401 / 403       | `authentication_error` / `permission_error`        | キーが無効、またはアクセス権がありません。                    |
| 404             | `not_found_error`                                  | エンドポイント、モデル、リソースが存在しません。                 |
| 413             | `request_too_large`                                | リクエスト本文を小さくします。                          |
| 429             | `rate_limit_error`                                 | レート制限と残高を確認します。                          |
| 500 / 504 / 529 | `api_error` / `timeout_error` / `overloaded_error` | サービス異常、タイムアウト、過負荷。一時的な障害のみ回数を制限して再試行します。 |

Anthropic のネイティブエラーは `{"type":"error","error":{"type":"invalid_request_error","message":"..."},"request_id":"..."}` の形式です。ゲートウェイが各社へ到達する前に認証、ルーティング、残高エラーを返す場合があります。HTTP の数値だけで上流由来と判断しないでください。

長い応答やストリーミングリクエストは数十秒から数分かかることがあります。クライアント側で十分なタイムアウトを設定し、切断時は受信済みの差分と終了理由から判断して、自動で再送しないでください。429 と 5xx はまずレスポンス本文と使用ログを確認し、コンテンツポリシーによる拒否の場合はプロンプトや入力を変更し、そのまま再試行しないでください。

## 公式資料

* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Anthropic API バージョン](https\://platform.claude.com/docs/en/api/versioning)
* [Anthropic エラー処理](https\://platform.claude.com/docs/en/api/errors)