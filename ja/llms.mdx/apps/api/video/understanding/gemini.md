# Gemini 動画理解

## API の説明

動画理解は既存の動画を受け取り、テキスト分析を返します。新しい動画は生成しません。以下は **Google 公式 Interactions**：`POST https://generativelanguage.googleapis.com/v1beta/interactions` を使用し、認証には `x-goog-api-key: $GEMINI_API_KEY` を使用します。Seedance/Kling のタスク作成として扱わないでください。また、SimiRouter が Google の全メディア入力機能をマッピング済みであることも意味しません。

## リクエストパラメータ

| フィールド               | 型       | 必須   | 説明                                                          |
| ------------------- | ------- | ---- | ----------------------------------------------------------- |
| model               | string  | はい   | gemini-3.8-flash など、動画入力に対応するモデル。                           |
| input               | array   | はい   | video 素材と text の質問。                                         |
| input\[].type       | string  | はい   | video または text。                                             |
| input\[].data       | string  | 条件付き | 短い動画の Base64 内容。uri とはどちらか一方。                               |
| input\[].mime\_type | string  | 条件付き | video/mp4 など。実際のエンコードと合わせる必要があります。                          |
| input\[].uri        | string  | 条件付き | アップロード済みで ACTIVE 状態の Google ファイル URI、またはモデルが対応する公開動画 URL。   |
| input\[].text       | string  | 条件付き | 要約、質疑応答、具体的な時間範囲を指定した質問。                                    |
| stream / background | boolean | いいえ  | 長い分析ではストリーミングまたはバックグラウンドモードを使用できます。対応するイベント／タスクの処理フローが必要です。 |

この例では安全側の制限として、リクエスト全体が 20 MB 未満の短い MP4 を使用します。大きい動画や繰り返し使う動画は Google Files API を優先してください。アップロード完了後も ACTIVE を待つ必要があり、FAILED の場合は停止します。無制限にポーリングしないでください。公開動画 URL、Cloud Storage、直接のインライン入力は異なる入力経路であり、任意に置き換えられません。

## 戻り値

Interactions の `steps[]` に model\_output が含まれ、テキスト項目は `content[].type=text` と `text` です。SDK の output\_text は便宜的なプロパティです。時点の情報はモデルによる理解結果であり、元の動画と照合してください。厳密な証拠分析やフレーム単位の注釈として自動的に扱わないでください。

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"00:10 出现海面上的帆船，随后镜头向右移动。"}]}]}
```

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

短い動画 `video.mp4` を用意し、Google 公式の `GEMINI_API_KEY` を設定します。この例は有料の生成モデルやファイル管理操作を呼び出しませんが、推論リクエスト自体は課金される場合があります。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")}]}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": (await readFile("video.mp4")).toString("base64")
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
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
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
      media, err := os.ReadFile("video.mp4"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
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

| HTTP ステータス            | 意味と対処                                                            |
| --------------------- | ---------------------------------------------------------------- |
| 400 / 422             | リクエスト項目、ファイル形式、モデルパラメータが不正。修正して再送。                               |
| 401                   | API Key がない、無効、または期限切れ。                                          |
| 403                   | 現在のプロジェクトまたはモデルへの権限がありません。                                       |
| 404                   | モデル、ルート、入力リソースが存在しません。アドレス、モデル ID、ファイル状態を確認。                     |
| 413 / 415             | アップロード過大、または未対応メディア型。                                            |
| 429                   | レートまたは割り当て制限。残高不足とバックオフ可能な制限を区別。                                 |
| 500 / 502 / 503 / 504 | サービスまたは上流異常。ID を保持し、同期リクエストがタイムアウトしたらログや状態を確認してから再試行し、重複課金を防ぎます。 |

Google のエラーは `error.code`、`error.status`、`error.message` を使用します。エラー本文を正常な分析結果として扱わないでください。

## 公式資料

[Google 動画理解](https\://ai.google.dev/gemini-api/docs/video-understanding)、[Files](https\://ai.google.dev/gemini-api/docs/files)。