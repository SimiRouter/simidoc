# API スクリプトによる接続

Chat Completions API でメッセージを送信し、モデルの応答を読み取ります。以下の 4 言語はいずれも、`POST /v1/chat/completions` に非ストリーミングの JSON リクエストを送信し、レスポンス全体を待って結果を出力します。

## 画像 API 呼び出しスクリプト

画像生成、参照画像の編集、結果保存の完全な例は、プロトコル別に[画像 API の概要](/simidoc/ja/apps/api/images)に整理されています。

## Key とモデルの準備

まず、[API Key 管理](https://api.dwchainless.com/keys)で Key を作成し、次に[モデル一覧](https://api.dwchainless.com/ja/pricing/)から現在の Key で利用可能な完全なモデル ID をコピーします。例は環境変数から設定を読み取り、ファイルに Key を保存しません。

* `SIMIROUTER_API_KEY`：SimiRouter API Key。必須。
* `SIMIROUTER_MODEL`：完全なモデル ID。必須。
* `SIMIROUTER_BASE_URL`：任意。デフォルトは `https://api.dwchainless.com`。これはルートアドレスであり、`/v1` は含めません。

上記の値をローカルターミナルまたは実行環境の環境変数に設定してください。公開ログに Key を出力しないでください。実際の API リクエストは課金される場合があります。

## OpenAI SDK にそのまま置き換える

既存のコードが OpenAI 公式 SDK を使っている場合は、`baseURL` と `apiKey` だけを置き換え、モデル名を SimiRouter の完全なモデル ID にします。`baseURL` は `/v1` で終わる必要があり、メソッド名・パラメータ・レスポンスの形は OpenAI のままです。

<Tabs items={["Python","Node.js"]}>
  <Tab value="Python">
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
  </Tab>

  <Tab value="Node.js">
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
  </Tab>
</Tabs>

先に公式 SDK をインストールします\: `pip install openai` または `npm install openai`。SDK が再試行・タイムアウト・SSE 解析を処理し、カスタムタイムアウトや `max_retries` などのクライアント設定も SDK の意味のままです。ゲートウェイは書き換えません。

ゲートウェイは OpenAI 互換プロトコルで応答します。モデルの能力差は選択したモデル次第で、SDK はそれを変えません。SDK が `404` を返す場合は、`baseURL` が `https://api.dwchainless.com` のままで `/v1` が抜けていないか確認してください。

## リクエストとレスポンス

| 項目           | 説明                                                                          |
| ------------ | --------------------------------------------------------------------------- |
| メソッドとパス      | `POST /v1/chat/completions`                                                 |
| 認証           | `Authorization: Bearer <API Key>`                                           |
| コンテンツタイプ     | `application/json`                                                          |
| 必須パラメーター     | `model`、`messages`                                                          |
| この例の任意パラメーター | `max_completion_tokens: 256`、`stream: false`。選択したモデルが対応している必要があります          |
| 成功レスポンス      | HTTP 200，`choices[].message.content` にテキストの応答が含まれ、`usage` は返された Token 使用量です |
| ストリーミング呼び出し  | `stream: true` の場合は SSE を返し、単一の JSON レスポンスとして解析できません                        |

全パラメーター、ツール呼び出し、マルチモーダル入力、SSE イベントの説明は [Chat Completions](/simidoc/ja/apps/api/chat/openai-chat) を参照してください。

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

## エラーコード

| HTTP ステータス | よくある原因                       | 対処方法                                         |
| ---------- | ---------------------------- | -------------------------------------------- |
| 400        | リクエスト形式のエラー、モデルが送信パラメーターに未対応 | エラーレスポンス本体を確認し、未対応の任意パラメーターを省略               |
| 401        | Key がない、失効している、正しくない         | 現在の環境変数を確認し、必要に応じて Key を再作成                  |
| 403        | モデル、グループ、チャネルの権限が制限されている     | Key とアカウントの権限を確認                             |
| 404        | パスまたはモデル識別子が正しくない            | 重複して `/v1` を追加していないか確認し、完全なモデル ID を照合        |
| 429        | レート制限または割り当て制限               | まず残高と制限を確認し、エラー内容に従ってバックオフ。無制限に再試行しない        |
| 5xx        | ゲートウェイまたは上流のエラー              | 機密情報を除いたエラー本体とリクエスト ID を保存。使用履歴を確認してから再試行を判断 |

上記のステータスは調査の入口であり、具体的な原因はエラーレスポンスに従います。タイムアウトはモデルが未実行であることを保証しません。生成リクエストを自動で無制限に再試行しないでください。

## その他の機能

* [Responses](/simidoc/ja/apps/api/chat/openai-responses)：入力項目と出力項目でリクエストを構成します。
* [Claude Messages](/simidoc/ja/apps/api/chat/claude)と [Gemini](/simidoc/ja/apps/api/chat/gemini-text)：ネイティブのメッセージ構造。
* [画像](/simidoc/ja/apps/api/images)：生成、編集、認識。
* [音声](/simidoc/ja/apps/api/audio)：音声理解、音声合成、文字起こし、翻訳。
* [動画](/simidoc/ja/apps/api/video)：生成タスクと動画理解。
* [MiMo 音声の接続](/simidoc/ja/apps/api/audio/mimo-audio)：MiMo の音声合成、文字起こし、声質機能。

## 公式資料

プロトコルのフィールドは [OpenAI Chat Completions API Reference](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create) を参照してください。SimiRouter のアドレスと Key は、OpenAI 公式への直接接続とは異なります。