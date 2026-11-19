# Gemini メディア理解

## API の説明

`POST /v1beta/models/{model}:generateContent` は parts にテキストとメディアデータを組み合わせ、モデルは説明、文字起こし、分析を返します。メディア理解は画像の生成や変更を行いません。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。Google への公式直接接続先は `https://generativelanguage.googleapis.com`、通常は `x-goog-api-key: $GEMINI_API_KEY` を使用し、ゲートウェイの Bearer Key ではありません。アクセス可能で目的の入力形式に対応するモデルを選択してください。

例ではローカルファイルを読み取り、インラインで送信します。外部素材 URL や Files API に依存しません。スクリプトは一般的な画像・音声・動画・PDF の拡張子を MIME 型に対応付けます。音声、動画、PDF には実データと一致する MIME 型と対応モデルを使用してください。拡張子だけを画像に変えて送信しないでください。

## クイックスタート

1. **設定を準備する**：API キー管理 でキーを作成し、モデル料金 から対象メディア入力に対応した完全なモデル ID をコピーします。
2. **素材を準備する**：権限のある画像、音声、動画、または PDF を選び、実際の MIME タイプを確認します。
3. **最小リクエストを送る**：ファイルのバイト列を純粋な Base64 にエンコードして `inlineData.data` に入れ、テキストの質問を同じ `parts` に置きます。まず画像 1 枚で検証します。
4. **結果を読む**：HTTP 2xx かつ `candidates[]` が空でない場合のみ成功です。分析テキストは `candidates[0].content.parts[].text` にあります。
5. **検証する**：`finishReason` と結論の根拠を確認し、高リスクの場面では人による確認を行います。

画像は先に Base64 へエンコードする必要があります。最小の動作スクリプトは下の「コード例」の節を参照してください。長い Base64 を手作業で連結しないでください。

## リクエストパラメータ

| フィールド                              | 型              | 必須   | 説明                                                                       |
| ---------------------------------- | -------------- | ---- | ------------------------------------------------------------------------ |
| model（パス）                          | string         | はい   | 目的のメディア入力に対応するモデル ID。                                                    |
| contents\[].parts\[].text          | string         | 条件付き | メディアと同時に送信する質問。                                                          |
| contents\[].parts\[].inlineData    | object         | 条件付き | mimeType と data を含むインラインメディア。同じ Part の text/fileData と混在不可。              |
| inlineData.mimeType                | string         | はい   | image/png、image/jpeg、audio/mpeg、video/mp4、application/pdf など、実際の MIME 型。 |
| inlineData.data                    | string         | はい   | ファイルバイト列の純粋な Base64。data\: 接頭辞やローカルパスではありません。                            |
| contents\[].parts\[].fileData      | object         | 条件付き | 別のメディア入力方法。mimeType と fileUri を含み、認可済みで各社が読み取れる URI のみを使用。               |
| contents\[].role                   | string         | いいえ  | 単一ターンでは通常 user。                                                          |
| generationConfig.maxOutputTokens   | integer        | いいえ  | 出力 Token 上限。                                                             |
| systemInstruction / safetySettings | object / array | いいえ  | システム指示と安全性設定。                                                            |

1 つの Part には 1 種類の内容のみを指定します。大きなファイルには公式に対応する入力方法を使用してください。ゲートウェイに Google Files のアップロード・ポーリング API があるとは限りません。Base64 は本文を増大させるため、ゲートウェイ、提供元、モデルの各制限を満たす必要があります。

### リクエスト構造

下の BASE64\_MEDIA\_BYTES はエンコード済みファイルバイト列を示します。4 言語のコードはローカルファイルからこの値を作成します。

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "描述这份素材的主要内容，并指出不确定之处。"
        },
        {
          "inlineData": {
            "mimeType": "image/png",
            "data": "BASE64_MEDIA_BYTES"
          }
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 512
  }
}
```

## 戻り値

| フィールド                                 | 型              | 説明                                                         |
| ------------------------------------- | -------------- | ---------------------------------------------------------- |
| candidates\[]                         | array          | 候補結果。ブロック時は空の場合があります。                                      |
| candidates\[].index                   | integer        | 候補の位置。                                                     |
| candidates\[].content.role / parts\[] | string / array | 出力ロールとコンテンツ断片。テキストは通常 parts\[].text。                       |
| candidates\[].finishReason            | string         | STOP は正常終了、MAX\_TOKENS は上限到達。SAFETY、RECITATION などは別途処理が必要。 |
| candidates\[].safetyRatings           | array          | 任意の安全性評価。                                                  |
| candidates\[].groundingMetadata       | object         | 検索などの grounding ツール利用時の出典と引用情報。                            |
| promptFeedback.blockReason            | string         | 入力がブロックされた理由。候補が存在しない場合があります。                              |
| usageMetadata.promptTokenCount        | integer        | 入力 Token。                                                  |
| usageMetadata.candidatesTokenCount    | integer        | 候補の出力 Token。                                               |
| usageMetadata.thoughtsTokenCount      | integer        | 任意の思考 Token。直接表示する本文ではありません。                               |
| usageMetadata.totalTokenCount         | integer        | リクエスト全体の Token。ツールや思考などを含む場合があります。                         |
| modelVersion / responseId             | string         | 任意のモデルバージョンと応答識別子。                                         |

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "图片中可见一张桌子和一个杯子；杯中内容无法确定。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 280,
    "candidatesTokenCount": 30,
    "totalTokenCount": 310
  }
}
```

ストリーミングでは streamGenerateContent?alt=sse を使用し、候補番号ごとに結合します。各 part がすべてテキストとは限りません。モデルの解釈には誤りがあり、医療、身元、証明書など高リスクの判断は人が確認してください。

## コード例

次を設定します：`SIMIROUTER_API_KEY`、`SIMIROUTER_GEMINI_MODEL`；`SIMIROUTER_BASE_URL` で既定のゲートウェイアドレスを変更できます。末尾に `/v1` を追加しないでください。 `MEDIA_PATH` には既存のローカルファイルを指定します。Python 3、Node.js 18+、Go は標準ライブラリのみを使用し、curl の JSON は Python 3 で安全にエンコードします。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    import base64
    from pathlib import Path
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }''')
    p = Path(os.environ["MEDIA_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.m4a': 'audio/mp4', '.flac': 'audio/flac', '.ogg': 'audio/ogg', '.mp4': 'video/mp4', '.mov': 'video/quicktime', '.webm': 'video/webm', '.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["contents"][0]["parts"][1]["inlineData"] = {"mimeType": mime, "data": encoded}
    path = "/v1beta/models/" + urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe="") + ":generateContent"
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
      const fs = require('node:fs');
      const path = require('node:path');
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_GEMINI_MODEL)
        throw new Error('请设置 SIMIROUTER_GEMINI_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '描述这份素材的主要内容，并指出不确定之处。',
              },
              {
                inlineData: {
                  mimeType: 'image/png',
                  data: 'BASE64_MEDIA_BYTES',
                },
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 512,
        },
      };
      const filename = process.env.MEDIA_PATH;
      if (!filename) throw new Error('请设置 MEDIA_PATH');
      const mime = {
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.webp': 'image/webp',
        '.mp3': 'audio/mpeg',
        '.wav': 'audio/wav',
        '.m4a': 'audio/mp4',
        '.flac': 'audio/flac',
        '.ogg': 'audio/ogg',
        '.mp4': 'video/mp4',
        '.mov': 'video/quicktime',
        '.webm': 'video/webm',
        '.pdf': 'application/pdf',
      }[path.extname(filename).toLowerCase()];
      if (!mime) throw new Error('不支持的文件扩展名');
      const data = fs.readFileSync(filename);
      if (!data.length) throw new Error('输入文件为空');
      const encoded = data.toString('base64');
      body.contents[0].parts[1].inlineData = { mimeType: mime, data: encoded };
      const endpoint = `/v1beta/models/${encodeURIComponent(process.env.SIMIROUTER_GEMINI_MODEL)}:generateContent`;
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
    : "${SIMIROUTER_GEMINI_MODEL:?请设置 SIMIROUTER_GEMINI_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    import base64
    from pathlib import Path
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }''')
    p = Path(os.environ["MEDIA_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.m4a': 'audio/mp4', '.flac': 'audio/flac', '.ogg': 'audio/ogg', '.mp4': 'video/mp4', '.mov': 'video/quicktime', '.webm': 'video/webm', '.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["contents"][0]["parts"][1]["inlineData"] = {"mimeType": mime, "data": encoded}
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    MODEL_PATH=$(python3 -c 'import os, urllib.parse; print(urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe=""))')
    curl "${BASE_URL%/}/v1beta/models/${MODEL_PATH}:generateContent" \
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
      "encoding/base64"
      "path/filepath"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_GEMINI_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_GEMINI_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }`), &body); err != nil { log.Fatal(err) }
      filename := os.Getenv("MEDIA_PATH"); if filename == "" { log.Fatal("请设置 MEDIA_PATH") }
      mime := map[string]string{".png":"image/png",".jpg":"image/jpeg",".jpeg":"image/jpeg",".webp":"image/webp",".mp3":"audio/mpeg",".wav":"audio/wav",".m4a":"audio/mp4",".flac":"audio/flac",".ogg":"audio/ogg",".mp4":"video/mp4",".mov":"video/quicktime",".webm":"video/webm",".pdf":"application/pdf"}[strings.ToLower(filepath.Ext(filename))]
      if mime == "" { log.Fatal("不支持的文件扩展名") }
      data, err := os.ReadFile(filename); if err != nil { log.Fatal(err) }; if len(data) == 0 { log.Fatal("输入文件为空") }
      encoded := base64.StdEncoding.EncodeToString(data)
      body["contents"].([]any)[0].(map[string]any)["parts"].([]any)[1].(map[string]any)["inlineData"] = map[string]any{"mimeType": mime, "data": encoded}
      endpoint := "/v1beta/models/" + model + ":generateContent"
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

| HTTP ステータス | 意味または各社のエラー型               | 対処                                      |
| ---------- | -------------------------- | --------------------------------------- |
| 400        | `INVALID_ARGUMENT` など      | JSON、モデルパラメータ、メディア MIME、入力長を確認します。      |
| 403        | `PERMISSION_DENIED`        | キー、プロジェクト権限、地域、請求上の制限を確認します。            |
| 404        | `NOT_FOUND`                | モデル名と API バージョンを確認します。                  |
| 429        | `RESOURCE_EXHAUSTED`       | レートと割り当てを確認し、再試行可能な場合のみ回数制限付きでバックオフします。 |
| 500 / 503  | `INTERNAL` / `UNAVAILABLE` | リクエスト識別子を記録し、回数制限付きの再試行または後で再実行します。     |

Google のネイティブエラーオブジェクトには `error.code`（HTTP 数値）、`error.status`（列挙名）、`error.message` が含まれ、追加で `details` が含まれる場合があります。ゲートウェイが各社へ到達する前に認証、ルーティング、残高エラーを返す場合があります。HTTP の数値だけで上流由来と判断しないでください。

長い応答やストリーミングリクエストは数十秒から数分かかることがあります。クライアント側で十分なタイムアウトを設定し、切断時は受信済みの差分と終了理由から判断して、自動で再送しないでください。429 と 5xx はまずレスポンス本文と使用ログを確認し、コンテンツポリシーによる拒否の場合はプロンプトや入力を変更し、そのまま再試行しないでください。

## 公式資料

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 画像理解](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Google 音声理解](https\://ai.google.dev/gemini-api/docs/audio)
* [Google 動画理解](https\://ai.google.dev/gemini-api/docs/video-understanding)
* [Google PDF 理解](https\://ai.google.dev/gemini-api/docs/document-processing)
* [Google トラブルシューティング](https\://ai.google.dev/gemini-api/docs/troubleshooting)