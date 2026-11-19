# Chat Completions

## 介面說明

`POST /v1/chat/completions` 根據訊息歷史生成助手回覆。適用於已有 Chat Completions 用戶端以及無狀態多輪對話。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直連為 `https://api.openai.com`，同樣使用 Bearer 身分驗證，但必須換成 OpenAI 的 Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

## 快速開始

1. **準備設定**：在 API 金鑰管理 建立金鑰，從模型與價格複製支援 Chat Completions 的完整模型 ID。
2. **傳送最小請求**：只提交一則使用者訊息，`stream` 保持 `false`，先確認驗證、模型與參數都有效。
3. **讀取結果**：HTTP 2xx 且 `choices[]` 非空才算成功，正文位於 `choices[0].message.content`。
4. **驗收**：檢查 `finish_reason`、拒絕資訊與實際內容，再核對使用記錄。

```bash
API_URL="https://api.dwchainless.com/v1/chat/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

把 `PASTE_API_KEY_HERE` 和 `MODEL_ID` 換成實際值；確認可用後，再增加多輪歷史、工具或開啟串流。

若已有 OpenAI SDK 專案，只需把 `baseURL` 指向 `https://api.dwchainless.com/v1`、換用本站 Key，方法名稱與參數不用改，見 [API 腳本接入](/simidoc/zh-Hant/apps/api-script)。

## 請求參數

內容型別為 `application/json`。未使用的選用欄位應省略，不要批量傳送空字串、0、空物件或 null。

| 欄位                                     | 型別                       | 必填 | 說明                                                                |
| -------------------------------------- | ------------------------ | -- | ----------------------------------------------------------------- |
| model                                  | string                   | 是  | 模型 ID。                                                            |
| messages                               | array                    | 是  | 至少一條訊息；呼叫方按順序提交所需歷史。                                              |
| messages\[].role                       | string                   | 是  | `developer`、`system`、`user`、`assistant`、`tool`，可用角色隨模型變化。         |
| messages\[].content                    | string / array / null    | 條件 | 普通訊息的文字或內容陣列；助手訊息帶 `tool_calls` 時可省略或為 null。                      |
| messages\[].content\[].type            | string                   | 條件 | 與內容對應的 `text`、`image_url`、`input_audio` 或 `file`。                 |
| messages\[].content\[].text            | string                   | 條件 | type=text 時的文字。                                                   |
| messages\[].content\[].image\_url      | object                   | 條件 | type=image\_url 時提供 `url`，選用 `detail`；詳見圖片理解。                     |
| messages\[].tool\_calls                | array                    | 否  | 助手請求的函式呼叫；每項包含 id、type=function、function.name、function.arguments。 |
| messages\[].tool\_call\_id             | string                   | 條件 | role=tool 時必填，對應助手給出的工具呼叫 ID。                                     |
| max\_completion\_tokens                | integer                  | 否  | 生成 Token 上限，包含可見輸出與推理 Token。                                      |
| stream                                 | boolean                  | 否  | true 回傳 SSE；預設非串流。                                                |
| stream\_options.include\_usage         | boolean                  | 否  | 串流結束前請求 usage 匯總塊，須同時開啟 stream。                                   |
| temperature / top\_p                   | number                   | 否  | 取樣參數，僅在選定模型支援時使用；通常只調整一個。                                         |
| stop                                   | string / array           | 否  | 停止序列，僅部分模型支援。                                                     |
| n                                      | integer                  | 否  | 候選回覆數量；不是並行請求數量。                                                  |
| tools / tool\_choice                   | array / string or object | 否  | 函式定義和呼叫選擇，見工具呼叫。                                                  |
| parallel\_tool\_calls                  | boolean                  | 否  | 允許一次回覆包含多個函式呼叫，不會替應用執行函式。                                         |
| response\_format                       | object                   | 否  | 結構化輸出設定，支援時可用 json\_schema 或 json\_object。                        |
| reasoning\_effort                      | string                   | 否  | 推理強度；選用值由模型決定，不是任意模型都支援。                                          |
| presence\_penalty / frequency\_penalty | number                   | 否  | 重複懲罰，範圍 -2 到 2，需模型支援。                                             |
| logprobs / top\_logprobs               | boolean / integer        | 否  | 輸出 Token 機率及候選數量，需模型支援。                                           |

`max_tokens` 是舊參數，已由 `max_completion_tokens` 取代；非 o-series 模型仍可能接受該欄位，`/v1/completions` 則仍只使用 `max_tokens`。新整合不要同時傳送兩者。`video_url`、`reasoning_content` 屬於部分相容模型擴展，不是 OpenAI Chat Completions 的通用標準欄位。

### 請求範例

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释什么是机器学习。"
    }
  ],
  "max_completion_tokens": 256,
  "stream": false
}
```

## 回傳值

成功的非串流回應為 HTTP 200 JSON。以下為結構範例，ID 和 Token 數僅用於說明。

| 欄位                             | 型別               | 說明                                                             |
| ------------------------------ | ---------------- | -------------------------------------------------------------- |
| id / object                    | string           | 回應 ID；object=chat.completion。                                  |
| created / model                | integer / string | 建立時間（Unix 秒）與回應模型。                                             |
| choices\[]                     | array            | 候選回覆清單，每項的 index 表示位置。                                         |
| choices\[].message.role        | string           | assistant。                                                     |
| choices\[].message.content     | string / null    | 文字回覆；工具呼叫或拒絕時可為空，不等同於請求失敗。                                     |
| choices\[].message.tool\_calls | array            | 待應用執行的函式呼叫。arguments 是 JSON 字串，須解析並驗證。                         |
| choices\[].message.refusal     | string / null    | 拒絕資訊，若有。                                                       |
| choices\[].finish\_reason      | string           | stop 正常結束；length 達到上限；tool\_calls 進入工具呼叫；content\_filter 內容過濾。 |
| usage.prompt\_tokens           | integer          | 輸入 Token。                                                      |
| usage.completion\_tokens       | integer          | 生成 Token，可能包含推理 Token。                                         |
| usage.total\_tokens            | integer          | 輸入與生成 Token 總計。                                                |
| usage.\*\_tokens\_details      | object           | 選用用量明細，如 cached\_tokens、reasoning\_tokens。                     |

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "机器学习是让计算机从数据中学习规律并用于预测或决策的方法。",
        "refusal": null
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 18,
    "completion_tokens": 24,
    "total_tokens": 42
  }
}
```

### 串流回應

設定 `stream: true` 後接收 `text/event-stream`。逐個解析 `data:` 行的 JSON，按 `choices[].index` 合併 `delta.content`；函式參數按工具 index 合併 `delta.tool_calls`。完成標記是 `data: [DONE]`，不是 JSON 物件。開啟 include\_usage 時最終用量塊的 choices 可以為空，普通塊的 usage 可以為 null。連接中斷前沒有收到結束訊號時，應將回覆標記為不完整，而不是自動當作成功。

```text
data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"content":"机器学习"},"finish_reason":null}]}

data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

## 程式碼範例

設定 `SIMIROUTER_API_KEY`、`SIMIROUTER_MODEL`；`SIMIROUTER_BASE_URL` 可覆蓋預設閘道位址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 範例只使用標準函式庫；curl 範例的 JSON 由 Python 3 安全編碼。

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

### 使用 OpenAI SDK

已安裝官方 `openai` SDK 時不必手寫 HTTP 請求：把 `baseURL` 指向閘道即可沿用官方型別定義、重試與串流解析。安裝指令為 `pip install openai` 或 `npm install openai`。

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

## 錯誤碼

| HTTP 狀態   | 含義或廠商錯誤型別    | 處理方式                       |
| --------- | ------------ | -------------------------- |
| 400       | 請求無效         | 檢查必填欄位、JSON、模型參數和上下文長度。    |
| 401       | 驗證失敗         | 檢查 Key 是否存在、有效及歸屬正確。       |
| 403 / 404 | 無權存取 / 資源不存在 | 檢查模型權限、資源 ID 和 URL。        |
| 429       | 速率或配額限制      | 結合回應主體區分限流與額度不足，後者不能靠重試解決。 |
| 500 / 503 | 服務錯誤 / 暫時不可用 | 保留請求識別碼，對暫時故障做有限次數退避。      |

OpenAI 原生錯誤通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可為 `null`，不能假定其始終存在或等於 HTTP 狀態碼。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 HTTP 200 仍需檢查 finish\_reason、拒絕資訊和串流完整性；length 與 content\_filter 不是 HTTP 錯誤。

長回覆與串流請求可能持續數十秒到數分鐘；用戶端應設定足夠逾時，斷流時依已收到的增量與終止原因判斷，不要自動重送。429 與 5xx 先查看回應內容與使用記錄，內容策略拒絕時修改提示詞或輸入，不要原樣重試。

### 錯誤回應範例

錯誤回應通常是 OpenAI 形狀的 `error` 物件，`param` 與 `code` 可能為 `null`；以下僅為示意，文案會隨閘道或上游變化，不要按字串比對。

```json
{
  "error": {
    "message": "You didn't provide an API key.",
    "type": "invalid_request_error",
    "param": null,
    "code": "invalid_api_key"
  }
}
```

```json
{
  "error": {
    "message": "Rate limit reached for requests.",
    "type": "rate_limit_error",
    "param": null,
    "code": "rate_limit_exceeded"
  }
}
```

## 常見問題

**回傳 401 或 `Invalid token` 怎麼辦？**
確認請求標頭是 `Authorization: Bearer <Key>`，Key 屬於目前閘道且未被撤銷；不要把登入密碼或廠商 Key 當成本站 Key。

**回傳 404 或提示模型不存在？**
`model` 必須是模型廣場裡的完整模型 ID，並確認目前金鑰分組有該模型權限。SDK 使用者還要檢查 `baseURL` 是否包含 `/v1`。

**429 應該重試嗎？**
先看回應內容：限流可以按指數退避重試並加入隨機抖動；額度不足或餘額耗盡是計費問題，重試不會成功，應儲值或調整額度。

**串流回應怎樣才算完整？**
收到 `data: [DONE]` 且最後一塊帶 `finish_reason` 才算正常結束。連線中斷且沒有結束標記時，把回覆當作不完整，不要自動重送已計費的請求。

**`max_tokens` 和 `max_completion_tokens` 用哪個？**
Chat Completions 用 `max_completion_tokens`；`max_tokens` 是舊欄位，僅部分模型仍接受。兩者不要同時傳送，`/v1/completions` 仍只用 `max_tokens`。

**為什麼設定了 temperature 卻沒有效果？**
部分推理模型固定取樣或只接受預設值，閘道會透傳給通路；以該模型的說明與錯誤為準，不要假定所有 OpenAI 參數都生效。

## 官方參考

* [OpenAI Chat Completions API](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI 文字生成](https\://developers.openai.com/api/docs/guides/text)
* [OpenAI 錯誤處理](https\://developers.openai.com/api/docs/guides/error-codes)