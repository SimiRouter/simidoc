# 傳統文字補全

## 介面說明

`POST /v1/completions` 接收 prompt 並回傳補全文字，不使用 messages、工具呼叫或 Responses 輸出項。它是傳統介面；新項目優先採用 Chat Completions 或 Responses。只有支援該補全通訊協定的模型才能呼叫，不可把任意聊天模型 ID 直接放入。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直連為 `https://api.openai.com`，同樣使用 Bearer 身分驗證，但必須換成 OpenAI 的 Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

## 快速開始

1. **準備設定**：在 API 金鑰管理 建立金鑰，從模型與價格複製支援傳統補全的完整模型 ID。
2. **傳送最小請求**：只提交一個 `prompt`，`stream` 保持 `false`，先確認驗證、模型與參數都有效。
3. **讀取結果**：HTTP 2xx 且 `choices[]` 非空才算成功，補全文字位於 `choices[0].text`。
4. **驗收**：檢查 `finish_reason` 與實際內容，再核對使用記錄。

```bash
API_URL="https://api.dwchainless.com/v1/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "prompt": "请补全这句话：机器学习是",
    "max_tokens": 64,
    "stream": false
  }'
```

把 `PASTE_API_KEY_HERE` 和 `MODEL_ID` 換成實際值；新專案優先使用 Chat Completions 或 Responses。

## 請求參數

JSON 請求主體。

| 欄位                                     | 型別             | 必填 | 說明                                  |
| -------------------------------------- | -------------- | -- | ----------------------------------- |
| model                                  | string         | 是  | 支援傳統補全的模型 ID。                       |
| prompt                                 | string / array | 條件 | 待補全文字；也可為多段文字或 Token ID 陣列。範例使用字串。  |
| max\_tokens                            | integer        | 否  | 最多生成的 Token 數，需與輸入總量共同滿足視窗限制。       |
| stream                                 | boolean        | 否  | true 回傳 SSE；預設 false。               |
| temperature / top\_p                   | number         | 否  | 取樣控制，通常只調整一個。                       |
| n                                      | integer        | 否  | 每個 prompt 的候選補全數。                   |
| stop                                   | string / array | 否  | 最多 4 個停止序列；回傳文字不包含停止串。              |
| echo                                   | boolean        | 否  | 是否把輸入 prompt 包含在回傳 text 中。          |
| logprobs                               | integer        | 否  | 回傳候選 Token 的對數機率，最大值 5。             |
| presence\_penalty / frequency\_penalty | number         | 否  | 重複懲罰，範圍 -2 到 2。                     |
| suffix                                 | string         | 否  | 僅支援插入補全的模型可用。                       |
| best\_of                               | integer        | 否  | 伺服器端生成多候選後擇優，不能與 stream 同用，且會增加生成量。 |

### 請求範例

```json
{
  "model": "MODEL_ID",
  "prompt": "请补全这句话：机器学习是",
  "max_tokens": 64,
  "stream": false
}
```

## 回傳值

| 欄位                                                        | 型別               | 說明                             |
| --------------------------------------------------------- | ---------------- | ------------------------------ |
| id / object                                               | string           | 補全 ID；object=text\_completion。 |
| created / model                                           | integer / string | Unix 秒時間戳與模型。                  |
| choices\[].text                                           | string           | 補全結果，不是 message.content。       |
| choices\[].index                                          | integer          | 候選序號。                          |
| choices\[].finish\_reason                                 | string           | stop、length 或 content\_filter。 |
| choices\[].logprobs                                       | object / null    | Token 機率資訊；未請求時通常為 null。       |
| usage.prompt\_tokens / completion\_tokens / total\_tokens | integer          | 輸入、生成與總 Token。                 |

```json
{
  "id": "cmpl_example",
  "object": "text_completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "text": "一种从数据中学习规律的方法。",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 14,
    "total_tokens": 26
  }
}
```

串流時串接 choices\[].text，以 `[DONE]` 結束；多 prompt 或多候選時按 index 分別合併。

## 程式碼範例

設定 `SIMIROUTER_API_KEY`、`SIMIROUTER_COMPLETION_MODEL`；`SIMIROUTER_BASE_URL` 可覆蓋預設閘道位址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 範例只使用標準函式庫；curl 範例的 JSON 由 Python 3 安全編碼。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_COMPLETION_MODEL"): raise RuntimeError("请设置 SIMIROUTER_COMPLETION_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    path = '/v1/completions'
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
      if (!process.env.SIMIROUTER_COMPLETION_MODEL)
        throw new Error('请设置 SIMIROUTER_COMPLETION_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        prompt: '请补全这句话：机器学习是',
        max_tokens: 64,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_COMPLETION_MODEL;
      const endpoint = '/v1/completions';
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
    : "${SIMIROUTER_COMPLETION_MODEL:?请设置 SIMIROUTER_COMPLETION_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/completions" \
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
      model := os.Getenv("SIMIROUTER_COMPLETION_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_COMPLETION_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/completions"
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

## 錯誤碼

| HTTP 狀態   | 含義或廠商錯誤型別    | 處理方式                       |
| --------- | ------------ | -------------------------- |
| 400       | 請求無效         | 檢查必填欄位、JSON、模型參數和上下文長度。    |
| 401       | 驗證失敗         | 檢查 Key 是否存在、有效及歸屬正確。       |
| 403 / 404 | 無權存取 / 資源不存在 | 檢查模型權限、資源 ID 和 URL。        |
| 429       | 速率或配額限制      | 結合回應主體區分限流與額度不足，後者不能靠重試解決。 |
| 500 / 503 | 服務錯誤 / 暫時不可用 | 保留請求識別碼，對暫時故障做有限次數退避。      |

OpenAI 原生錯誤通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可為 `null`，不能假定其始終存在或等於 HTTP 狀態碼。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。

長回覆與串流請求可能持續數十秒到數分鐘；用戶端應設定足夠逾時，斷流時依已收到的增量與終止原因判斷，不要自動重送。429 與 5xx 先查看回應內容與使用記錄，內容策略拒絕時修改提示詞或輸入，不要原樣重試。

## 官方參考

* [OpenAI Completions API](https\://developers.openai.com/api/reference/resources/completions/methods/create)
* [OpenAI 錯誤處理](https\://developers.openai.com/api/docs/guides/error-codes)