# Dots 影片理解

## 介面說明

`dots3-note-prev` 支援影片輸入，可將影片、圖片與問題放入同一訊息內容陣列，生成文字分析。官方影片通訊協定為 `POST https://note3-prev-api.askdiandian.com/v1/chat/completions`，請求標頭使用 `api-key: $DOTS_API_KEY`，不是 Bearer 身分驗證。

本頁範例直連 **Dots 官方服務**。它不是 Gemini 的 `input/steps` 通訊協定，也不是生成影片的非同步任務。透過 SimiRouter 使用時須確認模型與管道是否透傳此影片擴展，不能只替換網域和金鑰。

* `stream: false`：等待完整 JSON，最終答案位於 `choices[].message.content`。
* `stream: true`：按 SSE 接收文字增量；影片處理可能使首 Token 等待時間增加，應給用戶端保留足夠逾時。
* 影片必須是模型服務可讀取的檔案 URL。官方影片範例未給出 Base64、`ms://`、取樣影格率、最大時長或固定檔案容量參數，本頁不將這些方式視為已支援。

## 請求參數

請求主體為 `application/json`。

| 欄位                                     | 型別                       | 必填    | 說明                                                   |
| -------------------------------------- | ------------------------ | ----- | ---------------------------------------------------- |
| `model`                                | string                   | 是     | 官方範例模型為 `dots3-note-prev`。                           |
| `messages`                             | array                    | 是     | 按順序提交訊息歷史。                                           |
| `messages[].role`                      | string                   | 是     | 影片和問題置於 `user`；可另設 `system` 指令。                      |
| `messages[].content`                   | array                    | 是     | 影片請求使用內容陣列，不要序列化成一個字串。                               |
| `content[].type`                       | string                   | 是     | `video_url` 為影片，`text` 為問題；可同時加入 `image_url` 圖片。     |
| `content[].video_url.url`              | string                   | 影片項必填 | 模型服務可存取的影片檔案位址，非本機路徑或網站分享頁。                          |
| `content[].text`                       | string                   | 文字項必填 | 需要執行的分析任務。                                           |
| `stream`                               | boolean                  | 否     | 本頁範例為 `false`，`true` 時改用 SSE 解析。                     |
| `max_tokens`                           | integer                  | 否     | 最大輸出 Token，本例 4096。輸入與該上限之和不能超過模型 524,288 Token 上下文。 |
| `chat_template_kwargs.enable_thinking` | boolean                  | 否     | 預設 `true`；`false` 關閉深度思考，本例顯式開啟。                     |
| `stop`                                 | string\[]                | 否     | 停止序列陣列，匹配時結束生成。                                      |
| `tools` / `tool_choice`                | array / string or object | 否     | 函式定義和工具選擇；本例僅分析影片，不呼叫工具。                             |

公網影片連結會交給 Dots 下載。使用有權公開給模型服務讀取的位址；簽名 URL 應保留足夠有效期，不要包含帳戶登入憑證。小紅書分享頁位址不等於影片檔案直鏈。

## 回傳值

HTTP 200 回傳 Chat Completions JSON。下面為結構範例，內容、ID 與用量不代表實測記錄。

| 欄位                                               | 型別               | 說明                                               |
| ------------------------------------------------ | ---------------- | ------------------------------------------------ |
| `id` / `object`                                  | string           | 請求識別碼；非串流 `object` 為 `chat.completion`。          |
| `created` / `model`                              | integer / string | Unix 秒級時間與回應模型。                                  |
| `choices[].index`                                | integer          | 候選序號。                                            |
| `choices[].message.role`                         | string           | 助手訊息為 `assistant`。                               |
| `choices[].message.content`                      | string           | 最終文字答案。                                          |
| `choices[].message.reasoning_content`            | string，選用        | 開啟思考時可能回傳的推理內容；與最終答案分開處理。                        |
| `choices[].finish_reason`                        | string           | `stop` 正常結束；`length` 表示截斷；`tool_calls` 需要應用執行工具。 |
| `usage.prompt_tokens`                            | integer          | 輸入 Token，影片按服務的多模態規則計算。                          |
| `usage.completion_tokens` / `usage.total_tokens` | integer          | 生成與總用量。                                          |
| `system_fingerprint`                             | string，選用        | 伺服器端回傳的系統識別碼，可為空字串。                              |

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

串流回應使用 Chat Completions 增量結構，本文讀取 `choices[].delta.content`，思考欄位單獨累積。用戶端應處理 SSE 事件分隔、終態和流結束，不能把一次網路讀取當作一個完整事件；連接中斷或 `length` 不視為完整答案。

## 程式碼範例

設定 `DOTS_API_KEY` 與 `VIDEO_URL`。`VIDEO_URL` 必須是模型服務能直接讀取的 HTTP(S) 影片檔案位址，四種範例均不會先在本機下載該影片。`DOTS_BASE_URL` 選用，預設 `https://note3-prev-api.askdiandian.com`，根位址不含 `/v1`；僅在使用經授權原生通訊協定代理或本機測試時修改。

Python 3、Node.js 18+ 和 Go 使用標準函式庫；curl 範例依賴 Python 3 安全建立 JSON 並檢查回傳結果。請求最多等待 300 秒，不自動重試。範例僅在 `finish_reason=stop` 且答案非空時輸出本文。

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

## 錯誤碼

| HTTP 狀態 | 官方含義          | 處理                           |
| ------- | ------------- | ---------------------------- |
| 400     | 參數或 JSON 格式錯誤 | 檢查多模態陣列、影片連結、模型名稱和上下文長度      |
| 401     | API Key 缺失或無效 | 核對 Dots Key 與 `api-key` 請求標頭 |
| 403     | Key 無權存取資源    | 核對平台權限                       |
| 429     | 請求過於頻繁        | 降低並行，有限次數退避                  |
| 500     | 服務內部錯誤        | 保留脫敏錯誤本文與回應識別碼，避免無上限重試       |

HTTP 200 不代表結果一定完整；應繼續檢查 `finish_reason` 與文字答案。影片位址失效、無法下載或解析失敗時，按實際錯誤本文排查，不把它誤判為身分驗證失敗。用戶端逾時不保證服務未執行，重新提交前注意重複消耗。

## 官方參考

[Dots API：影片輸入](https\://dots.ai/platform/docs#video-input)、[請求參數](https\://dots.ai/platform/docs#request-parameters)、[身分驗證](https\://dots.ai/platform/docs#authentication)和[回應狀態](https\://dots.ai/platform/docs#error-codes)。