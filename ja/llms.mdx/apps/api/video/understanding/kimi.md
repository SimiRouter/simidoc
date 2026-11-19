# Kimi 動画理解

## API の説明

`kimi-k3` はネイティブに動画理解に対応しています。既存の動画から要約を生成したり、画面に関する質問に回答したり、イベントを分析したりできます。動画理解はテキストを返す機能であり、動画は生成しません。フレーム単位の認識や厳密な時間アライメントを保証するものでもありません。

**API アドレス**：`POST https://api.moonshot.cn/v1/chat/completions`。中国向け Moonshot API Key を使用し、`Authorization: Bearer $MOONSHOT_API_KEY` で認証します。国際版は `https://api.moonshot.ai` と国際版 Key を使用します。両サイトのアカウントと Key は共用できません。

本ページの例は **Moonshot 公式への直接接続** です。モデルに動画機能があることは、SimiRouter でも同じモデル、メディア入力方式、ファイルストレージのプロトコルが利用可能であることを意味しません。`ms://` ファイル ID を別のメーカーやゲートウェイへ直接移行しないでください。

* **非ストリーミング**：`stream: false` の場合、同じ HTTP リクエストで JSON レスポンス全体を待ちます。
* **ストリーミング**：`stream: true` の場合、同じ接続で SSE を順次返し、推論と本文の増分を出力します。非同期の動画生成タスクではありません。
* **ファイル参照**：先にファイルをアップロードし、その後チャットリクエストで `ms://<file_id>` を使用します。ファイルアップロードはチャットリクエストの代わりにはなりません。

## リクエストパラメータ

コンテンツタイプは `application/json`。

| フィールド                          | 型                        | 必須   | 説明                                                                                            |
| ------------------------------ | ------------------------ | ---- | --------------------------------------------------------------------------------------------- |
| `model`                        | string                   | はい   | 本ページでは `kimi-k3` を使用します。画面の表示名やモデルの略称ではありません。                                                 |
| `messages`                     | array                    | はい   | メッセージ一覧。動画リクエストのユーザーメッセージはコンテンツ配列を使用。                                                         |
| `messages[].role`              | string                   | はい   | 動画と質問は `user` メッセージに配置します。別途 `system` 指示も設定可能。                                                |
| `messages[].content`           | array                    | はい   | 含める項目は `video_url` の動画項目と `text` の質問項目です。配列を文字列へシリアライズしないでください。                               |
| `content[].type`               | string                   | はい   | 動画は `video_url`、テキストは `text`。                                                                 |
| `content[].video_url.url`      | string                   | 条件付き | `data:video/mp4;base64,...` など、実際の MIME に一致する data URL、または Moonshot ファイル参照の `ms://<file_id>`。 |
| `content[].text`               | string                   | 条件付き | 要約、イベントの順序、指定時間範囲への質疑応答など、モデルに実行させる分析。                                                        |
| `reasoning_effort`             | string                   | いいえ  | K3 は常に思考が有効です。トップレベルで `low`、`high`、`max` のいずれかを指定し、既定値は `max` です。                             |
| `max_completion_tokens`        | integer                  | いいえ  | 生成 Token の上限。推論と最終回答の両方に十分な予算を確保する必要があります。上限に達すると `finish_reason` は `length`。                 |
| `stream`                       | boolean                  | いいえ  | デフォルトは `false`；`true` は SSE を返します。                                                            |
| `stream_options.include_usage` | boolean                  | いいえ  | ストリーミングリクエストと併用し、終了前に使用量統計のブロックを取得。                                                           |
| `response_format`              | object                   | いいえ  | 対応する構造化出力形式。JSON が必要な場合は、公式 JSON Mode または JSON Schema に従って設定。                                 |
| `tools` / `tool_choice`        | array / string or object | いいえ  | ツール呼び出しを利用可能。本ページの動画分析例ではツールを有効にしません。                                                         |

K3 は K2.x の `thinking` スイッチを使用しません。`temperature` は `1.0`、`top_p` は `0.95`、`n` は `1`、反復ペナルティは `0` 固定です。これらのフィールドは省略を推奨します。他の値はエラーになります。`max_tokens` は旧パラメーターです。新しい実装は `max_completion_tokens` を使用します。

### 動画入力の制限

公式の視覚ページは MP4、MPEG、MOV、AVI、FLV、MPG、WebM、WMV、3GPP の動画タイプを掲載し、1080p 以下の解像度を推奨しています。リクエスト Body は公式の 100M 制限を超えられません。Base64 は本体を大きくするため、元動画のサイズを JSON リクエストのサイズとして扱わないでください。

本ページの例では、より安全側の制限として **ローカル動画を 20 MiB 以下に制限**しています。これは例の保護値であり、モデルの動画容量上限や長さの保証ではありません。大きな動画や繰り返し参照する動画には、公式のファイルアップロード手順を使用してください。通常の Web ページ URL、小紅書の共有ページ、ローカルファイルパスを `video_url.url` として指定しないでください。本ページは確認済みの Base64 と `ms://` の 2 つの入力方式を使用します。

### アップロード済み動画の使用

Moonshot の `POST /v1/files` を呼び出し、multipart で `file` と `purpose=video` を送信します。アップロード結果の `id` を読み取り、動画項目で `{"type":"video_url","video_url":{"url":"ms://<file_id>"}}` を使用します。ファイルの抽出テキストを別途読み取る必要はありません。

公式のアップロード参考情報では、単一ファイルの上限は 100 MiB です。新バージョンのファイルプロトコルでは、その `kimi-api-version` 要件に従って処理してください。ファイルエンドポイントのバージョンヘッダー要件を Chat Completions に適用しないでください。アップロードしたリソースには同じプラットフォームとアカウントでアクセスし、利用後は業務の保存方針に従って削除します。

## 戻り値

非ストリーミングの成功レスポンスは HTTP 200 JSON で、Chat Completions 構造に従います。

| フィールド                                 | 型       | 説明                                                                         |
| ------------------------------------- | ------- | -------------------------------------------------------------------------- |
| `id`                                  | string  | 今回の補完の識別子。                                                                 |
| `object`                              | string  | 非ストリーミングの場合は `chat.completion`。                                            |
| `created`                             | integer | 作成時刻。Unix 秒。                                                               |
| `model`                               | string  | レスポンスのモデル識別子。                                                              |
| `choices[].index`                     | integer | 候補の位置。                                                                     |
| `choices[].message.role`              | string  | アシスタントメッセージは `assistant`。                                                  |
| `choices[].message.content`           | string  | 最終的な動画分析の回答。                                                               |
| `choices[].message.reasoning_content` | string  | 返される可能性のある推論内容。最終回答ではなく、`content` と同じ項目として扱わないでください。                       |
| `choices[].finish_reason`             | string  | `stop` は正常終了。`length` は生成上限への到達を示します。`tool_calls` はアプリケーションによるツール実行を要求します。 |
| `usage.prompt_tokens`                 | integer | 入力の使用量。モデルの計算方式に基づく動画入力を含みます。                                              |
| `usage.completion_tokens`             | integer | 生成の使用量。                                                                    |
| `usage.total_tokens`                  | integer | 合計使用量。キャッシュや推論の詳細を含む場合があります。                                               |

以下の ID、時刻、使用量は構造例であり、実測記録ではありません。

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1793500000,
  "model": "kimi-k3",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "视频先展示产品外观，随后演示操作步骤，最后对比使用前后的结果。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 1200,
    "completion_tokens": 300,
    "total_tokens": 1500
  }
}
```

### ストリーミングの解析

SSE の `data:` JSON では、`choices[].delta.reasoning_content` は推論の増分、`choices[].delta.content` は本文の増分です。それぞれ追加し、上書きしないでください。最後の `finish_reason` を確認し、`data: [DONE]` を待ちます。使用量を有効にした場合、統計ブロックは `choices: []` の場合があり、トップレベルの `usage` から読み取ります。`choices[0]` に固定でアクセスしないでください。

複数ターンの会話では、返された `reasoning_content` を含む assistant メッセージ全体を保持します。次のターンでは必要な動画と質問の文脈も引き続き渡してください。接続の中断や `length` の受信は、完全な回答として扱えません。

## コード例

先に `MOONSHOT_API_KEY` と `VIDEO_FILE` を設定します。後者はアップロードする権限のある実際のローカル動画です。`VIDEO_MIME` は任意で、デフォルトは `video/mp4` も実際のファイルと一致させる必要があります。この例は任意のファイルを MP4 に変換しません。`MOONSHOT_BASE_URL` は任意で、デフォルトは `https://api.moonshot.cn` です。ルートアドレスに `/v1` です。許可されたプロキシやローカル mock テストに使用できます。

Python 3、Node.js 18+、Go の例は標準ライブラリを使用します。curl の例には、リクエストのエンコードと結果の解析に Python 3 が必要です。4 種類の例はいずれも動画を 20 MiB に制限し、タイムアウトを設定し、不完全な結果を拒否します。課金リクエストは自動再試行しません。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import base64
    import json
    import os
    import urllib.error
    import urllib.request
    from pathlib import Path

    key = os.environ.get("MOONSHOT_API_KEY")
    filename = os.environ.get("VIDEO_FILE")
    if not key or not filename:
        raise SystemExit("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE")
    path = Path(filename)
    if not path.is_file() or not 0 < path.stat().st_size <= 20 * 1024 * 1024:
        raise SystemExit("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
    mime = os.environ.get("VIDEO_MIME", "video/mp4")
    allowed = {"video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
               "video/mpg", "video/webm", "video/wmv", "video/3gpp"}
    if mime not in allowed:
        raise SystemExit("VIDEO_MIME 不在本页列出的格式范围内")
    video = base64.b64encode(path.read_bytes()).decode("ascii")
    body = {
        "model": "kimi-k3",
        "messages": [{"role": "user", "content": [
            {"type": "video_url", "video_url": {"url": f"data:{mime};base64,{video}"}},
            {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"},
        ]}],
        "reasoning_effort": "low",
        "max_completion_tokens": 4096,
        "stream": False,
    }
    base = os.environ.get("MOONSHOT_BASE_URL", "https://api.moonshot.cn").rstrip("/")
    request = urllib.request.Request(
        base + "/v1/chat/completions", data=json.dumps(body).encode("utf-8"),
        headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=300) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop":
        raise RuntimeError("视频分析未正常完成，请检查 finish_reason 与错误信息")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip():
        raise RuntimeError("响应没有最终文字答案")
    print(answer)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile, stat } = require("node:fs/promises");

    async function main() {
      const key = process.env.MOONSHOT_API_KEY;
      const filename = process.env.VIDEO_FILE;
      if (!key || !filename) throw new Error("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE");
      const info = await stat(filename);
      if (!info.isFile() || info.size <= 0 || info.size > 20 * 1024 * 1024)
        throw new Error("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件");
      const mime = process.env.VIDEO_MIME || "video/mp4";
      const allowed = ["video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
        "video/mpg", "video/webm", "video/wmv", "video/3gpp"];
      if (!allowed.includes(mime)) throw new Error("不支持的 VIDEO_MIME");
      const video = (await readFile(filename)).toString("base64");
      const body = {
        model: "kimi-k3",
        messages: [{ role: "user", content: [
          { type: "video_url", video_url: { url: `data:${mime};base64,${video}` } },
          { type: "text", text: "概括视频内容，并按顺序列出关键事件。" },
        ] }],
        reasoning_effort: "low", max_completion_tokens: 4096, stream: false,
      };
      const base = (process.env.MOONSHOT_BASE_URL || "https://api.moonshot.cn").replace(/\/+$/, "");
      const response = await fetch(base + "/v1/chat/completions", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body: JSON.stringify(body), signal: AbortSignal.timeout(300000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      const choice = result.choices?.[0];
      if (choice?.finish_reason !== "stop") throw new Error("视频分析未正常完成");
      const answer = choice.message?.content;
      if (typeof answer !== "string" || !answer.trim()) throw new Error("响应没有最终文字答案");
      console.log(answer);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${MOONSHOT_API_KEY:?请设置 MOONSHOT_API_KEY}"
    : "${VIDEO_FILE:?请设置 VIDEO_FILE}"
    base="${MOONSHOT_BASE_URL:-https://api.moonshot.cn}"
    request=$(mktemp)
    response=$(mktemp)
    trap 'rm -f "$request" "$response"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json, os
    from pathlib import Path
    path = Path(os.environ["VIDEO_FILE"])
    if not path.is_file() or not 0 < path.stat().st_size <= 20 * 1024 * 1024:
        raise SystemExit("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
    mime = os.environ.get("VIDEO_MIME", "video/mp4")
    allowed = {"video/mp4", "video/mpeg", "video/mov", "video/avi", "video/x-flv",
               "video/mpg", "video/webm", "video/wmv", "video/3gpp"}
    if mime not in allowed: raise SystemExit("不支持的 VIDEO_MIME")
    video = base64.b64encode(path.read_bytes()).decode("ascii")
    print(json.dumps({
        "model": "kimi-k3",
        "messages": [{"role": "user", "content": [
            {"type": "video_url", "video_url": {"url": f"data:{mime};base64,{video}"}},
            {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"},
        ]}],
        "reasoning_effort": "low", "max_completion_tokens": 4096, "stream": False,
    }, ensure_ascii=False))
    PY_BODY
    if curl --fail-with-body --connect-timeout 15 --max-time 300 \
      "${base%/}/v1/chat/completions" \
      -H "Authorization: Bearer $MOONSHOT_API_KEY" \
      -H "Content-Type: application/json" --data-binary "@$request" --output "$response"; then
      python3 - "$response" <<'PY_RESULT'
    import json, sys
    with open(sys.argv[1], encoding="utf-8") as source: result = json.load(source)
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop":
        raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    PY_RESULT
    else
      status=$?
      cat "$response" >&2
      exit "$status"
    fi
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
        "bytes"
        "encoding/base64"
        "encoding/json"
        "fmt"
        "io"
        "net/http"
        "os"
        "strings"
        "time"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        key, filename := os.Getenv("MOONSHOT_API_KEY"), os.Getenv("VIDEO_FILE")
        if key == "" || filename == "" { panic("请设置 MOONSHOT_API_KEY 和 VIDEO_FILE") }
        info, err := os.Stat(filename); check(err)
        if !info.Mode().IsRegular() || info.Size() <= 0 || info.Size() > 20*1024*1024 {
            panic("VIDEO_FILE 必须是非空且不超过 20 MiB 的文件")
        }
        mime := os.Getenv("VIDEO_MIME"); if mime == "" { mime = "video/mp4" }
        allowed := map[string]bool{"video/mp4":true, "video/mpeg":true, "video/mov":true,
            "video/avi":true, "video/x-flv":true, "video/mpg":true, "video/webm":true,
            "video/wmv":true, "video/3gpp":true}
        if !allowed[mime] { panic("不支持的 VIDEO_MIME") }
        video, err := os.ReadFile(filename); check(err)
        body := map[string]any{
            "model":"kimi-k3",
            "messages":[]any{map[string]any{"role":"user", "content":[]any{
                map[string]any{"type":"video_url", "video_url":map[string]string{
                    "url":"data:"+mime+";base64,"+base64.StdEncoding.EncodeToString(video)}},
                map[string]string{"type":"text", "text":"概括视频内容，并按顺序列出关键事件。"},
            }}},
            "reasoning_effort":"low", "max_completion_tokens":4096, "stream":false,
        }
        payload, err := json.Marshal(body); check(err)
        base := os.Getenv("MOONSHOT_BASE_URL"); if base == "" { base = "https://api.moonshot.cn" }
        req, err := http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1/chat/completions", bytes.NewReader(payload)); check(err)
        req.Header.Set("Authorization","Bearer "+key); req.Header.Set("Content-Type","application/json")
        res, err := (&http.Client{Timeout:300*time.Second}).Do(req); check(err); defer res.Body.Close()
        raw, err := io.ReadAll(res.Body); check(err)
        if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw)) }
        var result struct { Choices []struct {
            Finish string `json:"finish_reason"`
            Message struct { Content string `json:"content"` } `json:"message"`
        } `json:"choices"` }
        check(json.Unmarshal(raw,&result))
        if len(result.Choices)==0 || result.Choices[0].Finish!="stop" { panic("视频分析未正常完成") }
        answer := result.Choices[0].Message.Content
        if strings.TrimSpace(answer)=="" { panic("响应没有最终文字答案") }
        fmt.Println(answer)
    }
    ```
  </Tab>
</Tabs>

## エラーコード

| HTTP ステータス            | よくあるエラータイプ                                                                          | 対処                                                                |
| --------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| 400                   | `invalid_request_error`、`content_filter`                                            | コンテンツ配列、Base64/MIME、リクエスト本体サイズ、固定パラメーター、コンテキストを確認し、安全要件に従って入力を調整。 |
| 401                   | `invalid_authentication_error`、`incorrect_api_key_error`                            | Key とエンドポイントが属するサイトを確認。中国向け、国際版、SimiRouter の Key を混在させないでください。    |
| 403                   | `permission_denied_error`                                                           | モデル権限、組織の許可リスト、機能の提供範囲を確認。                                        |
| 404                   | `resource_not_found_error`                                                          | モデル ID、ファイル ID、リソースの所属を確認。                                        |
| 429                   | `engine_overloaded_error`、`exceeded_current_quota_error`、`rate_limit_reached_error` | 容量、残高、レート制限を区別。割り当て不足はリクエストの繰り返しでは解決しません。                         |
| 499 / 500 / 503 / 504 | `client_closed_request`、`server_error` など                                           | リクエスト ID を保存し、接続とサービス状態を確認。長時間のリクエストでは SSE に変更できます。               |

エラーには通常 `error.type` と `error.message` が含まれ、一部のレスポンスには追加で `error.code` が含まれます。タイムアウトはリクエストが未実行であることを示しません。再試行の前に使用量を確認し、Key や動画の Base64 全体をログに記録しないでください。

## 公式資料

* [Kimi K3：モデルと動画ファイルの例](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart)
* [Kimi 視覚入力：動画タイプと制限](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Kimi Chat Completions API：動画 data URL、リクエスト、レスポンス](https\://platform.kimi.com/docs/api/chat)
* [Kimi モデルパラメーターリファレンス](https\://platform.kimi.com/docs/api/models-overview)
* [Kimi ストリーミング出力](https\://platform.kimi.com/docs/guide/utilize-the-streaming-output-feature-of-kimi-api)
* [Moonshot ファイルアップロード](https\://platform.kimi.com/docs/api/files-upload)
* [Kimi エラーコード](https\://platform.kimi.com/docs/api/errors)