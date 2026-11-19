# Kimi 影片理解

## 介面說明

`kimi-k3` 原生支援影片理解，可以根據已有影片生成摘要、回答畫面問題或分析事件。影片理解回傳文字，不生成影片，也不承諾逐影格識別或精確時間對齊。

**介面位址**：`POST https://api.moonshot.cn/v1/chat/completions`。使用中國站 Moonshot API Key，通過 `Authorization: Bearer $MOONSHOT_API_KEY` 身分驗證。國際站使用 `https://api.moonshot.ai` 和國際站 Key，兩站帳戶及 Key 不能混用。

本頁範例為 **Moonshot 官方直連**。模型具備影片能力，不代表 SimiRouter 已開放相同模型、媒體輸入方式或檔案儲存通訊協定；不能將 `ms://` 檔案 ID 直接遷移到其他廠商或閘道。

* **非串流**：`stream: false`，同一 HTTP 請求等待完整 JSON 回應。
* **串流**：`stream: true`，同一連接逐步回傳 SSE，輸出推理和本文增量；不是非同步影片生成任務。
* **檔案引用**：先上傳檔案，再在聊天請求中使用 `ms://<file_id>`，檔案上傳不代替聊天請求。

## 請求參數

內容型別為 `application/json`。

| 欄位                             | 型別                       | 必填 | 說明                                                                               |
| ------------------------------ | ------------------------ | -- | -------------------------------------------------------------------------------- |
| `model`                        | string                   | 是  | 本頁為 `kimi-k3`，不是介面顯示名或模型簡稱。                                                      |
| `messages`                     | array                    | 是  | 訊息清單。影片請求的使用者訊息使用內容陣列。                                                           |
| `messages[].role`              | string                   | 是  | 影片與問題放在 `user` 訊息中；可另設 `system` 指令。                                              |
| `messages[].content`           | array                    | 是  | 包含 `video_url` 影片項和 `text` 問題項，不能把陣列序列化成字串。                                      |
| `content[].type`               | string                   | 是  | 影片為 `video_url`，文字為 `text`。                                                      |
| `content[].video_url.url`      | string                   | 條件 | `data:video/mp4;base64,...` 等匹配真實 MIME 的資料 URL，或 Moonshot 檔案引用 `ms://<file_id>`。 |
| `content[].text`               | string                   | 條件 | 要求模型完成的分析，例如摘要、事件順序或指定時間段問答。                                                     |
| `reasoning_effort`             | string                   | 否  | K3 始終啟用思考，使用頂層 `low`、`high` 或 `max`，預設 `max`。                                    |
| `max_completion_tokens`        | integer                  | 否  | 生成 Token 上限，須為推理與最終答案留足預算；達到上限時 `finish_reason` 為 `length`。                      |
| `stream`                       | boolean                  | 否  | 預設 `false`；`true` 回傳 SSE。                                                        |
| `stream_options.include_usage` | boolean                  | 否  | 配合串流請求，在結束前取得用量統計塊。                                                              |
| `response_format`              | object                   | 否  | 支援的結構化輸出格式；需要 JSON 時按官方 JSON Mode 或 JSON Schema 設定。                              |
| `tools` / `tool_choice`        | array / string or object | 否  | 可使用工具呼叫；本頁影片分析範例不啟用工具。                                                           |

K3 不使用 K2.x 的 `thinking` 開關。`temperature` 固定為 `1.0`、`top_p` 固定為 `0.95`、`n` 固定為 `1`，重複懲罰固定為 `0`；建議省略這些欄位，其他取值會發生錯誤。`max_tokens` 是舊參數，新整合使用 `max_completion_tokens`。

### 影片輸入限制

官方視覺頁列出 MP4、MPEG、MOV、AVI、FLV、MPG、WebM、WMV 和 3GPP 影片型別，建議影片解析度不高於 1080p。請求 Body 不超過官方的 100M 限制；Base64 會增大請求主體，不能把原影片大小直接當成 JSON 請求大小。

本頁範例採用更保守的 **20 MiB 本機影片上限**，這是範例保護值，不是模型最大影片容量或時長承諾。較大影片或反復引用的影片應採用官方檔案上傳流程。不要將普通網頁位址、小紅書分享頁或本機檔案路徑填寫為 `video_url.url`；本頁使用已確認的 Base64 和 `ms://` 兩種輸入方式。

### 使用已上傳的影片

呼叫 Moonshot `POST /v1/files`，以 multipart 提交 `file` 和 `purpose=video`，讀取上傳回傳的 `id`，然後在影片項中使用 `{"type":"video_url","video_url":{"url":"ms://<file_id>"}}`。不需要再讀取檔案的文字抽取內容。

官方上傳參考列出單檔案 100 MiB 上限；使用新版本檔案通訊協定時按其 `kimi-api-version` 要求處理，不要將檔案端點的版本頭要求套用於 Chat Completions。上傳資源應由相同平台和帳戶存取，使用完畢按業務保留規則刪除。

## 回傳值

成功的非串流回應為 HTTP 200 JSON，沿用 Chat Completions 結構。

| 欄位                                    | 型別      | 說明                                                 |
| ------------------------------------- | ------- | -------------------------------------------------- |
| `id`                                  | string  | 本次補全的識別碼。                                          |
| `object`                              | string  | 非串流為 `chat.completion`。                            |
| `created`                             | integer | 建立時間，Unix 秒。                                       |
| `model`                               | string  | 回應模型識別碼。                                           |
| `choices[].index`                     | integer | 候選位置。                                              |
| `choices[].message.role`              | string  | 助手訊息為 `assistant`。                                 |
| `choices[].message.content`           | string  | 最終影片分析答案。                                          |
| `choices[].message.reasoning_content` | string  | 可能回傳的推理內容；不是最終答案，不能與 `content` 混為一項。               |
| `choices[].finish_reason`             | string  | `stop` 正常結束；`length` 達到生成上限；`tool_calls` 要求業務執行工具。 |
| `usage.prompt_tokens`                 | integer | 輸入用量，包含按模型計算的影片輸入。                                 |
| `usage.completion_tokens`             | integer | 生成用量。                                              |
| `usage.total_tokens`                  | integer | 總用量；可另帶快取與推理明細。                                    |

下列 ID、時間和用量僅為結構範例，不是實測記錄：

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

### 串流解析

SSE 的 `data:` JSON 中，`choices[].delta.reasoning_content` 為推理增量，`choices[].delta.content` 為本文增量；分別追加，不要覆蓋。檢查最終 `finish_reason`，並等待 `data: [DONE]`。開啟用量後，統計塊可能為 `choices: []`，從頂層 `usage` 讀取，不能固定存取 `choices[0]`。

多輪對話應保留完整 assistant 訊息，包括回傳的 `reasoning_content`；下一輪繼續帶入所需影片和問題上下文。連接中斷或收到 `length` 不能當作完整答案。

## 程式碼範例

先設定 `MOONSHOT_API_KEY` 和 `VIDEO_FILE`，後者為有權上傳的真實本機影片。`VIDEO_MIME` 選用，預設 `video/mp4`，須匹配實際檔案；範例不會把任意檔案轉換為 MP4。`MOONSHOT_BASE_URL` 選用，預設為 `https://api.moonshot.cn`，根位址不含 `/v1`，可用於經授權代理或本機 mock 測試。

Python 3、Node.js 18+ 和 Go 範例使用標準函式庫；curl 範例需要 Python 3 編碼請求和解析結果。四種範例均限制影片 20 MiB、設定逾時、拒絕不完整結果，不自動重試計費請求。

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

## 錯誤碼

| HTTP 狀態               | 常見錯誤型別                                                                              | 處理方式                                          |
| --------------------- | ----------------------------------------------------------------------------------- | --------------------------------------------- |
| 400                   | `invalid_request_error`、`content_filter`                                            | 檢查內容陣列、Base64/MIME、請求主體大小、固定參數及上下文；按安全要求調整輸入。 |
| 401                   | `invalid_authentication_error`、`incorrect_api_key_error`                            | 檢查 Key 和端點所屬站點，不混用中國站、國際站或 SimiRouter Key。    |
| 403                   | `permission_denied_error`                                                           | 檢查模型權限、組織允許清單與功能開放範圍。                         |
| 404                   | `resource_not_found_error`                                                          | 核對模型 ID、檔案 ID 與資源歸屬。                          |
| 429                   | `engine_overloaded_error`、`exceeded_current_quota_error`、`rate_limit_reached_error` | 分清容量、餘額和速率限制；額度不足不能靠重複請求解決。                   |
| 499 / 500 / 503 / 504 | `client_closed_request`、`server_error` 等                                            | 保留請求 ID，檢查連接與服務狀態；長請求可改用 SSE。                 |

錯誤通常包含 `error.type` 和 `error.message`，部分回應另帶 `error.code`。逾時不證明請求未執行，重試前先核對用量；不要在記錄中記錄 Key 或完整影片 Base64。

## 官方參考

* [Kimi K3：模型與影片檔案範例](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart)
* [Kimi 視覺輸入：影片型別與限制](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Kimi Chat Completions API：影片資料 URL、請求與回傳](https\://platform.kimi.com/docs/api/chat)
* [Kimi 模型參數參考](https\://platform.kimi.com/docs/api/models-overview)
* [Kimi 串流輸出](https\://platform.kimi.com/docs/guide/utilize-the-streaming-output-feature-of-kimi-api)
* [Moonshot 檔案上傳](https\://platform.kimi.com/docs/api/files-upload)
* [Kimi 錯誤碼](https\://platform.kimi.com/docs/api/errors)