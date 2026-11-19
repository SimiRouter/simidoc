# Claude Messages

## 介面說明

`POST /v1/messages` 接收 user/assistant 訊息，回傳由文字、工具呼叫或思考塊組成的 Message。頂層 system 用於系統指令，不要建立 role=system 的 messages 項。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。Anthropic 官方直連為 `https://api.anthropic.com`，使用 `x-api-key: $ANTHROPIC_API_KEY`。範例固定 `anthropic-version: 2023-06-01` 以選擇相應通訊協定版本，不代表最新版。 模型名稱應選用帳戶可存取且支援目標能力的模型。

## 快速開始

1. **準備設定**：在 API 金鑰管理 建立金鑰，從模型與價格複製支援 Claude Messages 的完整模型 ID。
2. **傳送最小請求**：只提交一則使用者訊息，保留 `anthropic-version` 請求標頭，`stream` 保持 `false`。
3. **讀取結果**：HTTP 2xx 且 `content[]` 非空才算成功，正文位於 `type=text` 的內容區塊。
4. **驗收**：檢查 `stop_reason`、`stop_sequence` 與實際內容，再核對使用記錄。

```bash
API_URL="https://api.dwchainless.com/v1/messages"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "anthropic-version: 2023-06-01" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "max_tokens": 256,
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

把 `PASTE_API_KEY_HERE` 和 `MODEL_ID` 換成實際值；`anthropic-version` 用於選擇協定版本，不代表最新版。

## 請求參數

請求主體為 JSON；範例請求標頭包含 `anthropic-version: 2023-06-01`。

| 欄位                            | 型別               | 必填 | 說明                                                    |
| ----------------------------- | ---------------- | -- | ----------------------------------------------------- |
| model                         | string           | 是  | 可存取的 Claude 模型 ID。                                    |
| max\_tokens                   | integer          | 是  | 生成 Token 上限；普通生成設為正整數，0 僅用於支援該行為的快取寫入流程。              |
| messages                      | array            | 是  | 對話訊息清單。                                               |
| messages\[].role              | string           | 是  | user 或 assistant。                                     |
| messages\[].content           | string / array   | 是  | 文字字串或內容塊陣列。                                           |
| content\[].type               | string           | 條件 | text、image、tool\_use、tool\_result 等對應型別。              |
| content\[].text               | string           | 條件 | text 塊的本文。                                            |
| content\[].source             | object           | 條件 | image 的來源，可用 base64 的 media\_type/data 或 url 型別的 url。 |
| system                        | string / array   | 否  | 系統指令；支援時可使用文字塊。                                       |
| stream                        | boolean          | 否  | true 回傳 SSE；預設非串流。                                    |
| stop\_sequences               | array            | 否  | 自訂停止序列。                                               |
| temperature / top\_p / top\_k | number / integer | 否  | 取樣設定，僅對支援該設定的模型使用。                                    |
| tools                         | array            | 否  | 函式工具定義，包含 name、description、input\_schema。             |
| tool\_choice                  | object           | 否  | auto、any、tool 或 none 等工具選擇；使用 tool 時指定 name。          |
| thinking                      | object           | 否  | 思考設定與模型代際有關；adaptive、enabled 等不是所有模型都接受。              |
| metadata.user\_id             | string           | 否  | 業務使用者識別碼，不應傳送直接身分資訊。                                  |

### 請求範例

```json
{
  "model": "MODEL_ID",
  "max_tokens": 256,
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释机器学习。"
    }
  ],
  "stream": false
}
```

## 回傳值

HTTP 200 的非串流回應為 Message。

| 欄位                                                                | 型別            | 說明                                                                     |
| ----------------------------------------------------------------- | ------------- | ---------------------------------------------------------------------- |
| id / type                                                         | string        | 訊息 ID；type=message。                                                    |
| role / model                                                      | string        | assistant 與回應模型 ID。                                                    |
| content\[]                                                        | array         | 內容塊清單；不能假定每一項都含 text。                                                  |
| content\[].type / text                                            | string        | type=text 時讀取 text；tool\_use 時讀取 id/name/input。                        |
| stop\_reason                                                      | string / null | end\_turn 自然結束；max\_tokens 達到上限；stop\_sequence 命中停止串；tool\_use 請求執行工具。 |
| stop\_sequence                                                    | string / null | 命中的停止序列，無則為 null。                                                      |
| usage.input\_tokens / output\_tokens                              | integer       | 輸入與輸出 Token。                                                           |
| usage.cache\_creation\_input\_tokens / cache\_read\_input\_tokens | integer       | 選用快取寫入與命中計量，不能簡單算作額外本文。                                                |

```json
{
  "id": "msg_example",
  "type": "message",
  "role": "assistant",
  "model": "MODEL_ID",
  "content": [
    {
      "type": "text",
      "text": "机器学习是一种从数据中提取规律并用于预测的方法。"
    }
  ],
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 14,
    "output_tokens": 24
  }
}
```

### 串流回應

stream=true 後依次處理 message\_start、content\_block\_start、content\_block\_delta、content\_block\_stop、message\_delta、message\_stop。text\_delta 追加文字；input\_json\_delta 追加工具參數的 partial\_json，串接完成後才解析。message\_delta 提供停止原因與用量更新，message\_stop 標記訊息結束；error 事件可出現在 HTTP 200 之後。

工具使用時保留收到的助手內容塊，在後續 user 訊息中用 `{"type":"tool_result","tool_use_id":"...","content":"..."}` 回傳結果。執行工具前必須驗證參數與權限。

## 程式碼範例

設定 `SIMIROUTER_API_KEY`、`SIMIROUTER_CLAUDE_MODEL`；`SIMIROUTER_BASE_URL` 可覆蓋預設閘道位址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 範例只使用標準函式庫；curl 範例的 JSON 由 Python 3 安全編碼。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_CLAUDE_MODEL"): raise RuntimeError("请设置 SIMIROUTER_CLAUDE_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    path = '/v1/messages'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={'anthropic-version': '2023-06-01', "Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
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
      if (!process.env.SIMIROUTER_CLAUDE_MODEL)
        throw new Error('请设置 SIMIROUTER_CLAUDE_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        max_tokens: 256,
        messages: [
          {
            role: 'user',
            content: '用一句话解释机器学习。',
          },
        ],
        stream: false,
      };
      body.model = process.env.SIMIROUTER_CLAUDE_MODEL;
      const endpoint = '/v1/messages';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          'anthropic-version': '2023-06-01',
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
    : "${SIMIROUTER_CLAUDE_MODEL:?请设置 SIMIROUTER_CLAUDE_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/messages" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "anthropic-version: 2023-06-01" \
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
      model := os.Getenv("SIMIROUTER_CLAUDE_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_CLAUDE_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/messages"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("anthropic-version", "2023-06-01")
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

## 錯誤碼

| HTTP 狀態         | 含義或廠商錯誤型別                                          | 處理方式                   |
| --------------- | -------------------------------------------------- | ---------------------- |
| 400             | `invalid_request_error`                            | 請求結構、參數或模型能力不匹配。       |
| 401 / 403       | `authentication_error` / `permission_error`        | Key 無效或沒有存取權限。         |
| 404             | `not_found_error`                                  | 端點、模型或資源不存在。           |
| 413             | `request_too_large`                                | 縮小請求主體。                |
| 429             | `rate_limit_error`                                 | 檢查速率與額度限制。             |
| 500 / 504 / 529 | `api_error` / `timeout_error` / `overloaded_error` | 服務異常、逾時或過載；僅對暫時故障有限重試。 |

Anthropic 原生錯誤形如 `{"type":"error","error":{"type":"invalid_request_error","message":"..."},"request_id":"..."}`。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。

長回覆與串流請求可能持續數十秒到數分鐘；用戶端應設定足夠逾時，斷流時依已收到的增量與終止原因判斷，不要自動重送。429 與 5xx 先查看回應內容與使用記錄，內容策略拒絕時修改提示詞或輸入，不要原樣重試。

## 官方參考

* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Anthropic API 版本](https\://platform.claude.com/docs/en/api/versioning)
* [Anthropic 錯誤處理](https\://platform.claude.com/docs/en/api/errors)