# Gemini 音声理解

## API の説明

Gemini 音声理解は録音をマルチモーダル入力として受け取り、テキストを返します。文字起こし、要約、話者の説明、時間区間の分析に利用できます。TTS でも専用の `/audio/transcriptions` でもありません。本ページでは Google 公式の `POST /v1beta/interactions` を使用し、認証には `x-goog-api-key: $GEMINI_API_KEY` を使用します。SimiRouter のネイティブプロキシで利用できることを保証するものではありません。

## リクエストパラメータ

| フィールド               | 型       | 必須   | 説明                                                   |
| ------------------- | ------- | ---- | ---------------------------------------------------- |
| model               | string  | はい   | gemini-3.8-flash など、音声入力に対応するモデル。                    |
| input               | array   | はい   | text 指示と audio 入力で構成されるコンテンツ配列。                      |
| input\[].type       | string  | はい   | テキストは text、音声は audio を使用。                            |
| input\[].data       | string  | 条件付き | インライン音声の Base64。data URL のプレフィックスは含めません。             |
| input\[].uri        | string  | 条件付き | Google Files API が返すファイル URI。インライン data とはどちらか一方を選択。 |
| input\[].mime\_type | string  | 条件付き | audio/wav、audio/mpeg など。実際の内容と一致させます。                |
| stream              | boolean | いいえ  | テキスト出力をストリーミングで受信できますが、マイク音声の継続アップロードとは異なります。        |

大きな録音は Google Files API にアップロードし、URI で参照する方法を推奨します。インラインファイルはモデルとリクエスト本体のサイズ制限内である必要があります。ローカルパスをクラウドから読み取れる URI として扱わないでください。また、モデルが返すタイムスタンプが専門的な強制アライメントの精度を備えるとは限りません。

## 戻り値

テキストは `steps[].content[]` の text 項目に含まれ、SDK では `output_text` を利用できます。長い録音の全文文字起こしでは、終了状態と出力の切り詰めを確認してください。レスポンスの抜粋例：

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"录音主要介绍了会议议程。"}]}]}
```

## コード例

Python 3 は標準ライブラリを使用します。Node.js の例は Node.js 18 以降の組み込み fetch を使用し、Go は標準ライブラリを使用します。

カレントディレクトリに短い録音 `speech.wav` を用意し、`GEMINI_API_KEY` を設定します。例では実際のファイルを読み込んで Base64 に変換し、送信後に JSON 全体を出力します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import json, urllib.request

    url = os.environ.get('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com').rstrip('/') + '/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")}]}
    headers['Content-Type'] = 'application/json'
    request = urllib.request.Request(url, data=json.dumps(body).encode(), headers=headers, method='POST')
    with urllib.request.urlopen(request, timeout=180) as response:
        print(response.read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const url = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "") + "/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": (await readFile("speech.wav")).toString("base64")
        }
      ]
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "${base%/}/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "encoding/base64"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      if os.Getenv("GEMINI_API_KEY")=="" { panic("请设置 GEMINI_API_KEY") }
      base:=os.Getenv("GEMINI_BASE_URL"); if base=="" { base="https://generativelanguage.googleapis.com" }
      media, err := os.ReadFile("speech.wav"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## エラーコード

| HTTP ステータス            | 意味と対処                                                                  |
| --------------------- | ---------------------------------------------------------------------- |
| 400                   | リクエスト項目またはモデルパラメータが不正。修正してから再送してください。                                  |
| 401                   | API Key がない、無効、または期限切れ。                                                |
| 403                   | 現在のプロジェクトまたはモデルへの権限がありません。                                             |
| 404                   | モデルまたはルートが存在しません。アドレスとモデル ID を確認してください。                                |
| 429                   | レートまたは割り当て制限。残高不足とバックオフ可能な制限を区別してください。                                 |
| 500 / 502 / 503 / 504 | サービスまたは上流異常。リクエスト ID を保持して一時的な障害は間隔を空けて再試行し、同じ有料リクエストを無制限に繰り返さないでください。 |

Google のエラーオブジェクトは `error.code`、`error.status`、`error.message` を使用します。HTTP の数字だけで発生元を判断しないでください。このインターフェースは同期リクエストです。タスク ID やポーリング段階はありません。エラー本文を文字起こしや要約の結果として扱わないでください。

## 公式資料

[Google 音声理解](https\://ai.google.dev/gemini-api/docs/audio)、[Google Files](https\://ai.google.dev/gemini-api/docs/files)。