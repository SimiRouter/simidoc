# 従来のテキスト補完

## API の説明

`POST /v1/completions` は prompt を受け取り補完テキストを返します。messages、ツール呼び出し、Responses 出力項目は使用しません。従来の API のため、新規プロジェクトは Chat Completions または Responses を優先します。この補完プロトコルに対応するモデルが必要で、任意のチャットモデル ID は使用できません。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。OpenAI への公式直接接続先は `https://api.openai.com` で、同じ Bearer 認証でも OpenAI のキーに置き換える必要があります。アクセス可能で目的の機能に対応するモデルを選択してください。

## クイックスタート

1. **設定を準備する**：API キー管理 でキーを作成し、モデル料金 から従来の補完に対応した完全なモデル ID をコピーします。
2. **最小リクエストを送る**：`prompt` を 1 つだけ送信し、`stream` は `false` のままにします。まず認証、モデル、パラメータが有効か確認します。
3. **結果を読む**：HTTP 2xx かつ `choices[]` が空でない場合のみ成功です。補完テキストは `choices[0].text` にあります。
4. **検証する**：`finish_reason` と実際の内容を確認し、使用ログと照合します。

```bash
API_URL="https://api.dwchainless.com/v1/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "prompt": "请补全这句话：机器学习是",
    "max_tokens": 64,
    "stream": false
  }'
```

`PASTE_API_KEY_HERE` と `MODEL_ID` を実際の値に置き換えます。新しいプロジェクトでは Chat Completions または Responses を優先してください。

## リクエストパラメータ

JSON リクエスト本文。

| フィールド                                  | 型              | 必須   | 説明                                          |
| -------------------------------------- | -------------- | ---- | ------------------------------------------- |
| model                                  | string         | はい   | 従来の補完に対応するモデル ID。                           |
| prompt                                 | string / array | 条件付き | 補完対象テキスト。複数テキストや Token ID 配列も可能。例では文字列を使用。  |
| max\_tokens                            | integer        | いいえ  | 最大生成 Token 数。入力との合計がウィンドウ制限を満たす必要があります。     |
| stream                                 | boolean        | いいえ  | true で SSE、既定は false。                       |
| temperature / top\_p                   | number         | いいえ  | サンプリング制御。通常は片方だけを変更。                        |
| n                                      | integer        | いいえ  | prompt ごとの候補補完数。                            |
| stop                                   | string / array | いいえ  | 最大 4 個の停止シーケンス。返されるテキストに停止文字列は含まれません。       |
| echo                                   | boolean        | いいえ  | 入力 prompt を返される text に含めるか。                 |
| logprobs                               | integer        | いいえ  | 候補 Token の対数確率。最大 5。                        |
| presence\_penalty / frequency\_penalty | number         | いいえ  | 繰り返しペナルティ。範囲 -2～2。                          |
| suffix                                 | string         | いいえ  | 挿入補完に対応するモデルのみ利用可能。                         |
| best\_of                               | integer        | いいえ  | サーバーが複数候補を生成して選択。stream と同時利用できず、生成量が増加します。 |

### リクエスト例

```json
{
  "model": "MODEL_ID",
  "prompt": "请补全这句话：机器学习是",
  "max_tokens": 64,
  "stream": false
}
```

## 戻り値

| フィールド                                                     | 型                | 説明                             |
| --------------------------------------------------------- | ---------------- | ------------------------------ |
| id / object                                               | string           | 補完 ID。object=text\_completion。 |
| created / model                                           | integer / string | Unix 秒の時刻とモデル。                 |
| choices\[].text                                           | string           | 補完結果。message.content ではありません。  |
| choices\[].index                                          | integer          | 候補番号。                          |
| choices\[].finish\_reason                                 | string           | stop、length、content\_filter。   |
| choices\[].logprobs                                       | object / null    | Token 確率情報。未要求時は通常 null。       |
| usage.prompt\_tokens / completion\_tokens / total\_tokens | integer          | 入力、生成、合計 Token。                |

```json
{
  "id": "cmpl_example",
  "object": "text_completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "text": "一种从数据中学习规律的方法。",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 14,
    "total_tokens": 26
  }
}
```

ストリームでは choices\[].text を連結し、`[DONE]` で終了します。複数 prompt・候補は index ごとに結合します。

## コード例

次を設定します：`SIMIROUTER_API_KEY`、`SIMIROUTER_COMPLETION_MODEL`；`SIMIROUTER_BASE_URL` で既定のゲートウェイアドレスを変更できます。末尾に `/v1` を追加しないでください。Python 3、Node.js 18+、Go は標準ライブラリのみを使用します。curl 例の JSON は Python 3 で安全にエンコードします。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_COMPLETION_MODEL"): raise RuntimeError("请设置 SIMIROUTER_COMPLETION_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    path = '/v1/completions'
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
      if (!process.env.SIMIROUTER_COMPLETION_MODEL)
        throw new Error('请设置 SIMIROUTER_COMPLETION_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        prompt: '请补全这句话：机器学习是',
        max_tokens: 64,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_COMPLETION_MODEL;
      const endpoint = '/v1/completions';
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
    : "${SIMIROUTER_COMPLETION_MODEL:?请设置 SIMIROUTER_COMPLETION_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/completions" \
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
      model := os.Getenv("SIMIROUTER_COMPLETION_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_COMPLETION_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/completions"
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

OpenAI のネイティブエラーには通常 `error.message`、`error.type`、`error.param`、`error.code` が含まれます。`param`、`code` は `null` の場合があり、常に存在する、または HTTP ステータスと等しいとは限りません。ゲートウェイが各社に届く前に認証、ルーティング、残高エラーを返す場合があります。HTTP 数値だけで上流由来と判断しないでください。

長い応答やストリーミングリクエストは数十秒から数分かかることがあります。クライアント側で十分なタイムアウトを設定し、切断時は受信済みの差分と終了理由から判断して、自動で再送しないでください。429 と 5xx はまずレスポンス本文と使用ログを確認し、コンテンツポリシーによる拒否の場合はプロンプトや入力を変更し、そのまま再試行しないでください。

## 公式資料

* [OpenAI Completions API](https\://developers.openai.com/api/reference/resources/completions/methods/create)
* [OpenAI エラー処理](https\://developers.openai.com/api/docs/guides/error-codes)