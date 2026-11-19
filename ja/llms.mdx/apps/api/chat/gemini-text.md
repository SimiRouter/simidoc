# Gemini テキスト生成

## API の説明

`POST /v1beta/models/{model}:generateContent` は Gemini の contents/parts 構造を受け取り、非ストリーミングでは完全な GenerateContentResponse を返します。OpenAI の messages や input とは異なる API です。

接続先は `https://api.dwchainless.com`、リクエストヘッダーは `Authorization: Bearer $SIMIROUTER_API_KEY` です。Google への公式直接接続先は `https://generativelanguage.googleapis.com`、通常は `x-goog-api-key: $GEMINI_API_KEY` を使用し、ゲートウェイの Bearer Key ではありません。アクセス可能で目的の入力形式に対応するモデルを選択してください。

## クイックスタート

1. **設定を準備する**：API キー管理 でキーを作成し、モデル料金 から generateContent に対応した完全なモデル ID をコピーします。
2. **最小リクエストを送る**：モデル ID をパスに直接記述し（`models/` プレフィックスを付けない）、`generationConfig.maxOutputTokens` を小さめの値にします。
3. **結果を読む**：HTTP 2xx かつ `candidates[]` が空でない場合のみ成功です。本文は通常 `candidates[0].content.parts[].text` にあります。
4. **検証する**：`finishReason` と `promptFeedback` を確認し、使用ログと照合します。

```bash
API_URL="https://api.dwchainless.com/v1beta/models/MODEL_ID:generateContent"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"role": "user", "parts": [{"text": "用一句话解释机器学习。"}]}],
    "generationConfig": {"maxOutputTokens": 256}
  }'
```

`PASTE_API_KEY_HERE` とパス内の `MODEL_ID` を実際の値に置き換えます。ストリーミングでは `streamGenerateContent?alt=sse` に切り替えます。

## リクエストパラメータ

本文は JSON です。REST フィールドは lowerCamelCase を使用し、Python SDK の snake\_case 名をそのままコピーしないでください。

| フィールド                                      | 型                | 必須   | 説明                                                   |
| ------------------------------------------ | ---------------- | ---- | ---------------------------------------------------- |
| model（パス）                                  | string           | はい   | models/ 接頭辞を含まないモデル ID。ネイティブのリソース名は models/\{model}。 |
| contents                                   | array            | はい   | 履歴と現在のメッセージを順番に格納。                                   |
| contents\[].role                           | string           | いいえ  | user または model。複数ターンでは明示指定。                          |
| contents\[].parts                          | array            | はい   | メッセージ内容の断片。最低 1 項目。                                  |
| parts\[].text                              | string           | 条件付き | テキスト断片。メディアは inlineData または fileData を使用。            |
| systemInstruction.parts\[].text            | string           | いいえ  | システム指示。role=system で代用しないでください。                      |
| generationConfig.maxOutputTokens           | integer          | いいえ  | 生成 Token 上限。モデルの思考 Token 計量も考慮します。                   |
| generationConfig.responseMimeType          | string           | いいえ  | 構造化出力には、モデルが対応する場合 application/json を指定できます。         |
| generationConfig.responseJsonSchema        | object           | いいえ  | 応答の JSON Schema。通常 application/json と同時に設定。          |
| generationConfig.temperature / topP / topK | number / integer | いいえ  | 該当サンプリング設定に対応するモデルのみ使用し、世代をまたいで固定値を流用しないでください。       |
| generationConfig.stopSequences             | array            | いいえ  | モデルが対応する停止文字列。                                       |
| safetySettings                             | array            | いいえ  | 安全性カテゴリと閾値。すべてのモデルの安全機構を無効化できるわけではありません。             |
| tools / toolConfig                         | array / object   | いいえ  | Google 検索や関数呼び出しなどのツール定義・設定。                         |

### リクエスト例

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "用一句话解释机器学习。"
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 256
  }
}
```

複数ターンでは role=user と role=model を交互に追加し、最後を現在の質問にします。サーバーが以前の HTTP 接続から履歴を自動保持するわけではありません。

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
            "text": "机器学习让计算机通过数据学习规律并完成预测。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 12,
    "candidatesTokenCount": 20,
    "totalTokenCount": 32
  }
}
```

### ストリーミング応答

パスを `/v1beta/models/{model}:streamGenerateContent?alt=sse` に変更し、本文は変えません。data 内の GenerateContentResponse を順に解析し、candidate.index ごとに parts のテキストを結合します。OpenAI の `[DONE]` マーカーを待たないでください。最後に finishReason、promptFeedback、用量を確認します。SSE は同じ生成の増分配信であり、バックグラウンドタスクや複数リクエストの並列実行ではありません。

## コード例

次を設定します：`SIMIROUTER_API_KEY`、`SIMIROUTER_GEMINI_MODEL`；`SIMIROUTER_BASE_URL` で既定のゲートウェイアドレスを変更できます。末尾に `/v1` を追加しないでください。Python 3、Node.js 18+、Go は標準ライブラリのみを使用します。curl 例の JSON は Python 3 で安全にエンコードします。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
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
                text: '用一句话解释机器学习。',
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 256,
        },
      };
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
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
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
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }`), &body); err != nil { log.Fatal(err) }
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

Google のネイティブエラーオブジェクトには `error.code`（HTTP 数値）、`error.status`（列挙名）、`error.message` が含まれ、追加で `details` が含まれる場合があります。ゲートウェイが各社へ到達する前に認証、ルーティング、残高エラーを返す場合があります。HTTP の数値だけで上流由来と判断しないでください。HTTP 200 でも candidates が空、または finishReason=SAFETY なら内容がブロックされた可能性があり、ネットワーク障害ではありません。

長い応答やストリーミングリクエストは数十秒から数分かかることがあります。クライアント側で十分なタイムアウトを設定し、切断時は受信済みの差分と終了理由から判断して、自動で再送しないでください。429 と 5xx はまずレスポンス本文と使用ログを確認し、コンテンツポリシーによる拒否の場合はプロンプトや入力を変更し、そのまま再試行しないでください。

## 公式資料

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google テキスト生成](https\://ai.google.dev/gemini-api/docs/text-generation)
* [Google トラブルシューティング](https\://ai.google.dev/gemini-api/docs/troubleshooting)