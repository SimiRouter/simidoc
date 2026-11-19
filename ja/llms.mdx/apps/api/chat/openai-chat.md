# Chat Completions

## API の説明

`POST /v1/chat/completions` はメッセージ履歴からアシスタント応答を生成します。既存の Chat Completions クライアントとステートレスな複数ターン会話に適しています。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。OpenAI への公式直接接続先は `https://api.openai.com` で、同じ Bearer 認証でも OpenAI のキーに置き換える必要があります。アクセス可能で目的の機能に対応するモデルを選択してください。

## クイックスタート

1. **設定を準備する**：API キー管理 でキーを作成し、モデル料金 から Chat Completions に対応した完全なモデル ID をコピーします。
2. **最小リクエストを送る**：ユーザーメッセージを 1 件だけ送信し、`stream` は `false` のままにします。まず認証、モデル、パラメータが有効か確認します。
3. **結果を読む**：HTTP 2xx かつ `choices[]` が空でない場合のみ成功です。本文は `choices[0].message.content` にあります。
4. **検証する**：`finish_reason`、拒否情報、実際の内容を確認し、使用ログと照合します。

```bash
API_URL="https://api.dwchainless.com/v1/chat/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

`PASTE_API_KEY_HERE` と `MODEL_ID` を実際の値に置き換えます。確認できたら、複数ターンの履歴やツールを追加するか、ストリーミングを有効にします。

既存のプロジェクトが OpenAI SDK を使っている場合は、`baseURL` を `https://api.dwchainless.com/v1` にし、SimiRouter の Key に差し替えるだけです。メソッド名とパラメータはそのまま使えます。[API 呼び出しスクリプト](/simidoc/ja/apps/api-script)を参照してください。

## リクエストパラメータ

コンテンツタイプは `application/json` です。未使用の任意フィールドは省略し、空文字列、0、空オブジェクト、null を一括送信しないでください。

| フィールド                                  | 型                        | 必須   | 説明                                                                         |
| -------------------------------------- | ------------------------ | ---- | -------------------------------------------------------------------------- |
| model                                  | string                   | はい   | モデル ID。                                                                    |
| messages                               | array                    | はい   | 最低 1 件のメッセージ。呼び出し側が必要な履歴を順番に送信します。                                         |
| messages\[].role                       | string                   | はい   | `developer`、`system`、`user`、`assistant`、`tool`。利用できるロールはモデルに依存します。         |
| messages\[].content                    | string / array / null    | 条件付き | 通常のメッセージのテキストまたは内容配列。アシスタントメッセージに `tool_calls` がある場合は省略または null にできます。     |
| messages\[].content\[].type            | string                   | 条件付き | 内容に対応する `text`、`image_url`、`input_audio` または `file`。                       |
| messages\[].content\[].text            | string                   | 条件付き | type=text のテキスト。                                                           |
| messages\[].content\[].image\_url      | object                   | 条件付き | type=image\_url では `url` を指定し、任意で `detail` を指定します。画像理解を参照してください。           |
| messages\[].tool\_calls                | array                    | いいえ  | アシスタントが要求した関数呼び出し。id、type=function、function.name、function.arguments を含みます。 |
| messages\[].tool\_call\_id             | string                   | 条件付き | role=tool の場合は必須。アシスタントが返したツール呼び出し ID に対応。                                 |
| max\_completion\_tokens                | integer                  | いいえ  | 可視出力と推論 Token を含む生成 Token 上限。                                              |
| stream                                 | boolean                  | いいえ  | true で SSE を返します。既定は非ストリーミング。                                              |
| stream\_options.include\_usage         | boolean                  | いいえ  | ストリーム終了前に usage 集計ブロックを要求。stream も有効にします。                                  |
| temperature / top\_p                   | number                   | いいえ  | 対応モデルでのみ使用するサンプリング値。通常は一方だけを変更します。                                         |
| stop                                   | string / array           | いいえ  | 停止シーケンス。一部モデルのみ対応。                                                         |
| n                                      | integer                  | いいえ  | 候補応答数。並列リクエスト数ではありません。                                                     |
| tools / tool\_choice                   | array / string or object | いいえ  | 関数定義と呼び出し選択。ツール呼び出しを参照。                                                    |
| parallel\_tool\_calls                  | boolean                  | いいえ  | 1 つの応答に複数の関数呼び出しを許可します。アプリの代わりに関数を実行するものではありません。                           |
| response\_format                       | object                   | いいえ  | 構造化出力設定。対応時は json\_schema または json\_object を使用。                            |
| reasoning\_effort                      | string                   | いいえ  | 推論強度。選択肢はモデルに依存し、全モデル対応ではありません。                                            |
| presence\_penalty / frequency\_penalty | number                   | いいえ  | 繰り返しペナルティ。範囲は -2～2、モデル対応が必要。                                               |
| logprobs / top\_logprobs               | boolean / integer        | いいえ  | 出力 Token の確率と候補数。モデル対応が必要。                                                 |

`max_tokens` は旧パラメータで、`max_completion_tokens` に置き換えられています。o-series 以外のモデルは引き続き受け付ける場合があり、`/v1/completions` は `max_tokens` のみを使用します。新規連携では両方を同時送信しないでください。`video_url`、`reasoning_content` は一部互換モデルの拡張であり、OpenAI Chat Completions の汎用標準フィールドではありません。

### リクエスト例

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释什么是机器学习。"
    }
  ],
  "max_completion_tokens": 256,
  "stream": false
}
```

## 戻り値

成功した非ストリーミング応答は HTTP 200 JSON です。以下は構造例で、ID と Token 数は説明用です。

| フィールド                          | 型                | 説明                                                                     |
| ------------------------------ | ---------------- | ---------------------------------------------------------------------- |
| id / object                    | string           | 応答 ID。object=chat.completion。                                          |
| created / model                | integer / string | 作成時刻（Unix 秒）と応答モデル。                                                    |
| choices\[]                     | array            | 候補応答配列。各 index が位置を示します。                                               |
| choices\[].message.role        | string           | assistant。                                                             |
| choices\[].message.content     | string / null    | テキスト応答。ツール呼び出しや拒否時は空の場合があり、リクエスト失敗とは限りません。                             |
| choices\[].message.tool\_calls | array            | アプリが実行する関数呼び出し。arguments は JSON 文字列なので解析・検証が必要。                        |
| choices\[].message.refusal     | string / null    | 存在する場合の拒否情報。                                                           |
| choices\[].finish\_reason      | string           | stop は正常終了、length は上限到達、tool\_calls はツール呼び出し、content\_filter はフィルタリング。 |
| usage.prompt\_tokens           | integer          | 入力 Token。                                                              |
| usage.completion\_tokens       | integer          | 推論 Token を含む場合がある生成 Token。                                             |
| usage.total\_tokens            | integer          | 入力と生成 Token の合計。                                                       |
| usage.\*\_tokens\_details      | object           | cached\_tokens、reasoning\_tokens など任意の用量内訳。                            |

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "机器学习是让计算机从数据中学习规律并用于预测或决策的方法。",
        "refusal": null
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 18,
    "completion_tokens": 24,
    "total_tokens": 42
  }
}
```

### ストリーミング応答

次を設定します：`stream: true` を設定すると `text/event-stream` を受信します。順に `data:` 行の JSON を解析し、`choices[].index` ごとに `delta.content` を結合します。関数引数はツール index ごとに `delta.tool_calls` を結合します。完了マーカーは `data: [DONE]` であり JSON ではありません。include\_usage を有効にした最後の用量ブロックでは choices が空、通常ブロックでは usage が null の場合があります。終了信号前に切断されたら、成功ではなく不完全な応答として扱います。

```text
data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"content":"机器学习"},"finish_reason":null}]}

data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
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
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/chat/completions'
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
      if (!process.env.SIMIROUTER_API_KEY)
        throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        messages: [
          {
            role: 'user',
            content: '用一句话解释什么是机器学习。',
          },
        ],
        max_completion_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/chat/completions';
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
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/chat/completions" \
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
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/chat/completions"
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

### OpenAI SDK を使う

公式の `openai` SDK が入っていれば、HTTP リクエストを手書きする必要はありません。`baseURL` をゲートウェイに向けるだけで、公式の型定義・再試行・ストリーム解析をそのまま利用できます。インストールは `pip install openai` または `npm install openai` です。

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://api.dwchainless.com/v1",
    api_key=os.environ["SIMIROUTER_API_KEY"],
)
response = client.chat.completions.create(
    model=os.environ["SIMIROUTER_MODEL"],
    messages=[{"role": "user", "content": "用一句话解释什么是机器学习。"}],
)
print(response.choices[0].message.content)
```

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'https://api.dwchainless.com/v1',
  apiKey: process.env.SIMIROUTER_API_KEY,
});
const response = await client.chat.completions.create({
  model: process.env.SIMIROUTER_MODEL,
  messages: [{ role: 'user', content: '用一句话解释什么是机器学习。' }],
});
console.log(response.choices[0].message.content);
```

## エラーコード

| HTTP ステータス | 意味または各社のエラー型   | 対処                                      |
| ---------- | -------------- | --------------------------------------- |
| 400        | 無効なリクエスト       | 必須項目、JSON、モデルパラメータ、文脈長を確認。              |
| 401        | 認証失敗           | キーの存在、有効性、所属を確認。                        |
| 403 / 404  | アクセス拒否／リソースなし  | モデル権限、リソース ID、URL を確認。                  |
| 429        | レートまたは割り当て制限   | 応答本文でレート制限と残高不足を区別します。残高不足は再試行では解消しません。 |
| 500 / 503  | サービスエラー／一時利用不可 | リクエスト識別子を保持し、一時障害のみ回数制限付きでバックオフ。        |

OpenAI のネイティブエラーには通常 `error.message`、`error.type`、`error.param`、`error.code` が含まれます。`param`、`code` は `null` の場合があり、常に存在する、または HTTP ステータスと等しいとは限りません。ゲートウェイが各社に届く前に認証、ルーティング、残高エラーを返す場合もあります。HTTP の数値だけで上流由来と判断しないでください。HTTP 200 でも finish\_reason、拒否、ストリームの完全性を確認します。length と content\_filter は HTTP エラーではありません。

長い応答やストリーミングリクエストは数十秒から数分かかることがあります。クライアント側で十分なタイムアウトを設定し、切断時は受信済みの差分と終了理由から判断して、自動で再送しないでください。429 と 5xx はまずレスポンス本文と使用ログを確認し、コンテンツポリシーによる拒否の場合はプロンプトや入力を変更し、そのまま再試行しないでください。

### エラー応答の例

エラー応答は通常 OpenAI 形式の `error` オブジェクトで、`param` と `code` は `null` のことがあります。以下は例示であり、文言はゲートウェイやプロバイダーによって変わるため、文字列で判定しないでください。

```json
{
  "error": {
    "message": "You didn't provide an API key.",
    "type": "invalid_request_error",
    "param": null,
    "code": "invalid_api_key"
  }
}
```

```json
{
  "error": {
    "message": "Rate limit reached for requests.",
    "type": "rate_limit_error",
    "param": null,
    "code": "rate_limit_exceeded"
  }
}
```

## よくある質問

**401 または `Invalid token` が返る場合は？**
ヘッダーが `Authorization: Bearer <Key>` であること、Key がこのゲートウェイのもので失効していないこと、ログインパスワードやプロバイダーの Key を貼り付けていないことを確認してください。

**404 やモデルが見つからないエラーになる場合は？**
`model` はモデルと料金にある完全なモデル ID である必要があり、Key のグループにそのモデルの権限が必要です。SDK 利用時は `baseURL` に `/v1` が含まれるかも確認してください。

**429 は再試行すべきですか？**
まずレスポンス本文を確認します。レート制限なら指数バックオフとジッターで再試行します。割り当てや残高の不足は課金の問題で、再試行しても成功しません。チャージするか上限を調整してください。

**ストリーミング応答が完了したかはどう判断しますか？**
`data: [DONE]` を受け取り、最後のチャンクに `finish_reason` がある場合だけ正常終了です。終了マーカーなしで接続が切れた場合は未完了として扱い、課金済みのリクエストを自動で再送しないでください。

**`max_tokens` と `max_completion_tokens` のどちらを使いますか？**
Chat Completions では `max_completion_tokens` を使います。`max_tokens` は旧フィールドで、一部のモデルだけが受け付けます。両方は送らず、`/v1/completions` は引き続き `max_tokens` のみを使います。

**temperature を設定しても効かないのはなぜですか？**
一部の推論モデルはサンプリングを固定するか既定値のみ受け付け、ゲートウェイはそのままプロバイダーへ渡します。すべての OpenAI パラメータが有効とは考えず、モデルのドキュメントとエラーに従ってください。

## 公式資料

* [OpenAI Chat Completions API](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI テキスト生成](https\://developers.openai.com/api/docs/guides/text)
* [OpenAI エラー処理](https\://developers.openai.com/api/docs/guides/error-codes)