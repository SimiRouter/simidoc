# Dots 動画理解

## API の説明

`dots3-note-prev` は動画入力に対応しています。同じメッセージのコンテンツ配列に動画、画像、質問を入れ、テキスト分析を生成できます。公式の動画プロトコルは `POST https://note3-prev-api.askdiandian.com/v1/chat/completions`、リクエストヘッダーは `api-key: $DOTS_API_KEY` で、Bearer 認証ではありません。

本ページの例は **Dots 公式サービス** に直接接続します。Gemini の `input/steps` プロトコルでも、動画を生成する非同期タスクでもありません。SimiRouter で使用する場合は、モデルとチャネルがこの動画拡張を透過転送するか確認してください。ドメインと Key を置き換えるだけでは利用できません。

* `stream: false`：JSON 全体を待機します。最終回答は `choices[].message.content`。
* `stream: true`：SSE でテキストの増分を受信します。動画処理により最初の Token までの待機時間が長くなる場合があります。クライアントに十分なタイムアウトを設定してください。
* 動画はモデルサービスが読み取れるファイル URL である必要があります。公式の動画例では Base64、`ms://`、サンプリングフレームレート、最大長、固定のファイル容量パラメーターは示されていないため、本ページではこれらを対応済みとして扱いません。

## リクエストパラメータ

リクエスト本体は `application/json`。

| フィールド                                  | 型                        | 必須         | 説明                                                                   |
| -------------------------------------- | ------------------------ | ---------- | -------------------------------------------------------------------- |
| `model`                                | string                   | はい         | 公式例のモデルは `dots3-note-prev`。                                          |
| `messages`                             | array                    | はい         | メッセージ履歴を順番に送信。                                                       |
| `messages[].role`                      | string                   | はい         | 動画と質問は `user` に配置します。別途 `system` 指示も設定可能。                            |
| `messages[].content`                   | array                    | はい         | 動画リクエストはコンテンツ配列を使用します。1 つの文字列にシリアライズしないでください。                        |
| `content[].type`                       | string                   | はい         | `video_url` は動画、`text` は質問です。同時に `image_url` 画像も追加可能。                |
| `content[].video_url.url`              | string                   | 動画項目では必須   | モデルサービスがアクセスできる動画ファイルの URL。ローカルパスや Web サイトの共有ページではありません。             |
| `content[].text`                       | string                   | テキスト項目では必須 | 実行する分析タスク。                                                           |
| `stream`                               | boolean                  | いいえ        | 本ページの例は `false`，`true` の場合は SSE 解析に切り替えます。                           |
| `max_tokens`                           | integer                  | いいえ        | 最大出力 Token。この例は 4096。入力とこの上限の合計は、モデルの 524,288 Token のコンテキストを超えられません。 |
| `chat_template_kwargs.enable_thinking` | boolean                  | いいえ        | デフォルトは `true`；`false` で深い思考を無効化します。この例では明示的に有効化しています。                |
| `stop`                                 | string\[]                | いいえ        | 停止シーケンスの配列。一致すると生成を終了。                                               |
| `tools` / `tool_choice`                | array / string or object | いいえ        | 関数定義とツール選択。この例は動画分析のみで、ツールは呼び出しません。                                  |

公開動画リンクは Dots に渡され、ダウンロードされます。モデルサービスに読み取りを許可できる URL を使用してください。署名付き URL には十分な有効期間を確保し、アカウントのログイン認証情報を含めないでください。小紅書の共有ページ URL は、動画ファイルの直接リンクとは異なります。

## 戻り値

HTTP 200 は Chat Completions JSON を返します。以下は構造例であり、内容、ID、使用量は実測記録ではありません。

| フィールド                                            | 型                | 説明                                                                    |
| ------------------------------------------------ | ---------------- | --------------------------------------------------------------------- |
| `id` / `object`                                  | string           | リクエスト識別子。非ストリーミングの `object` は `chat.completion`。                      |
| `created` / `model`                              | integer / string | Unix 秒の時刻とレスポンスモデル。                                                   |
| `choices[].index`                                | integer          | 候補番号。                                                                 |
| `choices[].message.role`                         | string           | アシスタントメッセージは `assistant`。                                             |
| `choices[].message.content`                      | string           | 最終的なテキスト回答。                                                           |
| `choices[].message.reasoning_content`            | string、任意        | 思考を有効にした場合に返されることがある推論内容。最終回答とは分けて処理。                                 |
| `choices[].finish_reason`                        | string           | `stop` は正常終了。`length` は切り詰めを示します。`tool_calls` はアプリケーションによるツール実行が必要です。 |
| `usage.prompt_tokens`                            | integer          | 入力 Token。動画はサービスのマルチモーダル規則で計算。                                        |
| `usage.completion_tokens` / `usage.total_tokens` | integer          | 生成と合計の使用量。                                                            |
| `system_fingerprint`                             | string、任意        | サーバーが返すシステム識別子。空文字列の場合があります。                                          |

```json
{
  "id": "dots_video_example",
  "object": "chat.completion",
  "created": 1793500000,
  "model": "dots3-note-prev",
  "choices": [{
    "index": 0,
    "message": {"role": "assistant", "content": "视频先展示室外场景，随后人物走入画面。"},
    "finish_reason": "stop"
  }],
  "usage": {"prompt_tokens": 1200, "completion_tokens": 100, "total_tokens": 1300}
}
```

ストリーミングレスポンスは Chat Completions の増分構造を使用し、本文は `choices[].delta.content` から読み取り、思考フィールドは別途蓄積します。クライアントは SSE のイベント区切り、終了状態、ストリーム終了を処理する必要があります。ネットワークの 1 回の読み取りを完全な 1 イベントとして扱わないでください。接続の中断や `length` は完全な回答として扱いません。

## コード例

次を設定します：`DOTS_API_KEY` と `VIDEO_URL`。`VIDEO_URL` は、モデルサービスが直接読み取れる HTTP(S) の動画ファイル URL である必要があります。4 種類の例はいずれも、動画を先にローカルへダウンロードしません。`DOTS_BASE_URL` は任意で、デフォルトは `https://note3-prev-api.askdiandian.com` です。ルートアドレスに `/v1` は含めません。許可されたネイティブプロトコルのプロキシやローカルテストの場合のみ変更してください。

Python 3、Node.js 18+、Go は標準ライブラリを使用します。curl の例は、JSON の安全な構築と結果確認に Python 3 を使用します。リクエストの最大待機時間は 300 秒で、自動再試行はしません。例は `finish_reason=stop` かつ回答が空でない場合のみ本文を出力します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, urllib.error, urllib.parse, urllib.request
    key, video = os.environ.get("DOTS_API_KEY"), os.environ.get("VIDEO_URL")
    if not key or not video: raise SystemExit("请设置 DOTS_API_KEY 和 VIDEO_URL")
    url = urllib.parse.urlsplit(video)
    if url.scheme not in ("http", "https") or not url.hostname or url.username is not None or url.password is not None:
        raise SystemExit("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")
    body = {"model": "dots3-note-prev", "messages": [{"role": "user", "content": [
        {"type": "video_url", "video_url": {"url": video}},
        {"type": "text", "text": "概括视频内容，并按顺序列出关键事件。"}
    ]}], "stream": False, "max_tokens": 4096, "chat_template_kwargs": {"enable_thinking": True}}
    base = os.environ.get("DOTS_BASE_URL", "https://note3-prev-api.askdiandian.com").rstrip("/")
    request = urllib.request.Request(base + "/v1/chat/completions", data=json.dumps(body).encode(),
        headers={"api-key": key, "Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=300) as response: result = json.load(response)
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop": raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const key = process.env.DOTS_API_KEY, video = process.env.VIDEO_URL;
      if (!key || !video) throw new Error("请设置 DOTS_API_KEY 和 VIDEO_URL");
      const url = new URL(video);
      if (!["http:", "https:"].includes(url.protocol) || !url.hostname || url.username || url.password)
        throw new Error("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址");
      const body = {model:"dots3-note-prev",messages:[{role:"user",content:[
        {type:"video_url",video_url:{url:video}},
        {type:"text",text:"概括视频内容，并按顺序列出关键事件。"}
      ]}],stream:false,max_tokens:4096,chat_template_kwargs:{enable_thinking:true}};
      const base = (process.env.DOTS_BASE_URL || "https://note3-prev-api.askdiandian.com").replace(/\/$/, "");
      const response = await fetch(base + "/v1/chat/completions", {method:"POST",
        headers:{"api-key":key,"Content-Type":"application/json"},body:JSON.stringify(body),signal:AbortSignal.timeout(300000)});
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json(), choice = result.choices?.[0];
      if (choice?.finish_reason !== "stop") throw new Error("视频分析未正常完成");
      const answer = choice.message?.content;
      if (typeof answer !== "string" || !answer.trim()) throw new Error("响应没有最终文字答案");
      console.log(answer);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${DOTS_API_KEY:?请设置 DOTS_API_KEY}"
    : "${VIDEO_URL:?请设置 VIDEO_URL}"
    request=$(mktemp)
    response=$(mktemp)
    trap 'rm -f "$request" "$response"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import json, os, urllib.parse
    video = os.environ["VIDEO_URL"]
    url = urllib.parse.urlsplit(video)
    if url.scheme not in ("http", "https") or not url.hostname or url.username is not None or url.password is not None:
        raise SystemExit("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")
    print(json.dumps({"model":"dots3-note-prev","messages":[{"role":"user","content":[
        {"type":"video_url","video_url":{"url":video}},
        {"type":"text","text":"概括视频内容，并按顺序列出关键事件。"}
    ]}],"stream":False,"max_tokens":4096,"chat_template_kwargs":{"enable_thinking":True}}))
    PY_BODY
    base="${DOTS_BASE_URL:-https://note3-prev-api.askdiandian.com}"
    curl "${base%/}/v1/chat/completions" \
      --fail-with-body \
      --connect-timeout 20 \
      --max-time 300 \
      -H "api-key: $DOTS_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request" \
      --output "$response"
    python3 - "$response" <<'PY_ANSWER'
    import json, sys
    with open(sys.argv[1]) as source: result = json.load(source)
    choices = result.get("choices") or []
    if not choices or choices[0].get("finish_reason") != "stop": raise RuntimeError("视频分析未正常完成")
    answer = choices[0].get("message", {}).get("content")
    if not isinstance(answer, str) or not answer.strip(): raise RuntimeError("响应没有最终文字答案")
    print(answer)
    PY_ANSWER
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import ("bytes"; "encoding/json"; "fmt"; "io"; "net/http"; "net/url"; "os"; "strings"; "time")
    func check(err error) { if err != nil { panic(err) } }
    func main() {
     key,video:=os.Getenv("DOTS_API_KEY"),os.Getenv("VIDEO_URL")
     if key=="" || video=="" {panic("请设置 DOTS_API_KEY 和 VIDEO_URL")}
     parsed,err:=url.Parse(video);check(err)
     if (parsed.Scheme!="http" && parsed.Scheme!="https") || parsed.Hostname()=="" || parsed.User!=nil {panic("VIDEO_URL 必须是不含登录凭据的 HTTP(S) 视频文件地址")}
     body:=map[string]any{"model":"dots3-note-prev","messages":[]any{map[string]any{"role":"user","content":[]any{
     map[string]any{"type":"video_url","video_url":map[string]string{"url":video}},
     map[string]string{"type":"text","text":"概括视频内容，并按顺序列出关键事件。"},
     }}},"stream":false,"max_tokens":4096,"chat_template_kwargs":map[string]bool{"enable_thinking":true}}
     data,err:=json.Marshal(body);check(err)
     base:=os.Getenv("DOTS_BASE_URL");if base=="" {base="https://note3-prev-api.askdiandian.com"}
     req,err:=http.NewRequest("POST",strings.TrimRight(base,"/")+"/v1/chat/completions",bytes.NewReader(data));check(err)
     req.Header.Set("api-key",key);req.Header.Set("Content-Type","application/json")
     res,err:=(&http.Client{Timeout:300*time.Second}).Do(req);check(err);defer res.Body.Close()
     raw,err:=io.ReadAll(res.Body);check(err)
     if res.StatusCode<200 || res.StatusCode>=300 {panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw))}
     var result struct {Choices []struct {Finish string `json:"finish_reason"`;Message struct {Content string `json:"content"`} `json:"message"`} `json:"choices"`}
     check(json.Unmarshal(raw,&result))
     if len(result.Choices)==0 || result.Choices[0].Finish!="stop" {panic("视频分析未正常完成")}
     answer:=result.Choices[0].Message.Content;if strings.TrimSpace(answer)=="" {panic("响应没有最终文字答案")};fmt.Println(answer)
    }
    ```
  </Tab>
</Tabs>

## エラーコード

| HTTP ステータス | 公式での意味                | 対処                                     |
| ---------- | --------------------- | -------------------------------------- |
| 400        | パラメーターまたは JSON 形式のエラー | マルチモーダル配列、動画リンク、モデル名、コンテキスト長を確認        |
| 401        | API Key がないか無効        | Dots Key と `api-key` ヘッダーを確認           |
| 403        | Key にリソースへのアクセス権がない   | プラットフォームの権限を確認                         |
| 429        | リクエスト頻度が高すぎる          | 同時実行数を減らし、回数を制限してバックオフ                 |
| 500        | サービス内部エラー             | 機密情報を除いたエラー本文とレスポンス識別子を保存し、無制限の再試行を避ける |

HTTP 200 でも結果が完全とは限りません。引き続き `finish_reason` とテキスト回答を確認してください。動画 URL の期限切れ、ダウンロード不可、解析失敗の場合は、実際のエラー本文に従って調査し、認証エラーと誤認しないでください。クライアントのタイムアウトは、サービスが未実行であることを保証しません。再送信前に重複消費に注意してください。

## 公式資料

[Dots API：動画入力](https\://dots.ai/platform/docs#video-input)、[リクエストパラメータ](https\://dots.ai/platform/docs#request-parameters)、[認証](https\://dots.ai/platform/docs#authentication)と[レスポンス状態](https\://dots.ai/platform/docs#error-codes)。