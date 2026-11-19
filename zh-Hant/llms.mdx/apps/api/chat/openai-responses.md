# Responses API

## 介面說明

`POST /v1/responses` 使用輸入項與輸出項而不是 Chat 的 choices/message 結構，適合工具呼叫、多模態與結構化輸出。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直連為 `https://api.openai.com`，同樣使用 Bearer 身分驗證，但必須換成 OpenAI 的 Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

閘道提供建立回應介面，不提供通用的 `GET /v1/responses/{id}` 與取消介面。因此 `background: true` 的 OpenAI 原生非同步工作流程不適用於此串接；使用同步或 SSE。需要背景任務時，應使用具有完整建立、查詢、取消能力的官方直連串接。

## 快速開始

1. **準備設定**：在 API 金鑰管理 建立金鑰，從模型與價格複製支援 Responses 的完整模型 ID。
2. **傳送最小請求**：用一段文字作為 `input`，`stream` 保持 `false`，先確認驗證、模型與參數都有效。
3. **讀取結果**：HTTP 2xx 且 `status` 為 `completed` 才算成功，正文位於 `output[].content[]` 中 `type=output_text` 的項目。
4. **驗收**：檢查 `error`、`incomplete_details` 與實際內容，再核對使用記錄。

```bash
API_URL="https://api.dwchainless.com/v1/responses"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "input": "用一句话解释机器学习。",
    "stream": false
  }'
```

把 `PASTE_API_KEY_HERE` 和 `MODEL_ID` 換成實際值；確認可用後，再增加工具、結構化輸出或開啟串流。

## 請求參數

內容型別為 `application/json`。

| 欄位                                                    | 型別                       | 必填 | 說明                                                                                   |
| ----------------------------------------------------- | ------------------------ | -- | ------------------------------------------------------------------------------------ |
| model                                                 | string                   | 是  | 閘道呼叫必填，選擇支援 Responses 的模型。                                                           |
| input                                                 | string / array           | 條件 | 文字或輸入項清單；普通生成需提供輸入，也可結合可用的歷史上下文。                                                     |
| input\[].role                                         | string                   | 條件 | 訊息角色：user、assistant、system 或 developer。                                              |
| input\[].content\[].type                              | string                   | 條件 | input\_text、input\_image 或 input\_file 等有型別的內容項。                                     |
| input\[].content\[].text                              | string                   | 條件 | type=input\_text 時的文字。                                                               |
| input\[].content\[].image\_url                        | string                   | 條件 | type=input\_image 時的圖片 URL 或 data URL。                                               |
| input\[].content\[].file\_data / file\_url / file\_id | string                   | 條件 | type=input\_file 時選擇一種檔案來源，詳見檔案識別。                                                   |
| instructions                                          | string                   | 否  | 高優先順序指令；使用 previous\_response\_id 時仍應重新提供所需指令。                                       |
| max\_output\_tokens                                   | integer                  | 否  | 輸出總 Token 上限，包含推理 Token。                                                             |
| stream                                                | boolean                  | 否  | true 回傳帶事件型別的 SSE 流。                                                                 |
| previous\_response\_id                                | string                   | 否  | 上一回應 ID；依賴上游狀態保留與同一可存取上下文。不要與 conversation 同用。                                       |
| conversation                                          | string / object          | 否  | 會話物件或 ID；不能與 previous\_response\_id 同用。是否開放取決於通路。                                    |
| store                                                 | boolean                  | 否  | 請求上游儲存回應；不是閘道記錄保留開關。                                                                 |
| tools / tool\_choice                                  | array / string or object | 否  | 函式或廠商內建工具及選擇規則。                                                                      |
| parallel\_tool\_calls                                 | boolean                  | 否  | 控制一個回應中是否允許多個函式呼叫。                                                                   |
| reasoning                                             | object                   | 否  | 支援的推理模型可設定 effort、summary；範圍隨模型變化。                                                   |
| text.format                                           | object                   | 否  | 文字格式，如 type=json\_schema；與 Chat 的 response\_format 不同。                               |
| temperature / top\_p                                  | number                   | 否  | 模型支援時的取樣參數。                                                                          |
| truncation                                            | string                   | 否  | 官方已標記棄用，建議改用 context\_management；disabled（預設）超過上下文發生錯誤，auto 允許丟棄部分上下文。閘道是否支援以實際行為為準。 |
| include                                               | array                    | 否  | 請求附加資料，如 reasoning.encrypted\_content、web\_search\_call.action.sources。              |
| metadata                                              | object                   | 否  | 業務關聯元資料，不應用於儲存敏感資訊。                                                                  |

選用欄位未設定時應省略。`stop`、`enable_thinking` 等相容擴展不是 OpenAI Responses 標準欄位。`reasoning_content` 也不是標準輸出欄位；推理輸出使用獨立 reasoning 項，且不承諾暴露模型內部思維鏈。

### 請求範例

```json
{
  "model": "MODEL_ID",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "用一句话解释什么是机器学习。"
        }
      ]
    }
  ],
  "max_output_tokens": 256,
  "stream": false
}
```

## 回傳值

非串流成功回傳 HTTP 200。以下展示主要欄位；未使用的選用狀態欄位可以為 null。

| 欄位                                                   | 型別               | 說明                                                                                  |
| ---------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------- |
| id / object                                          | string           | 回應 ID；object=response。                                                              |
| created\_at / model                                  | integer / string | 建立時間（Unix 秒）與模型。                                                                    |
| status                                               | string           | completed、incomplete、failed、queued、in\_progress、cancelled；串流與背景回應都可能出現這些狀態。         |
| output\[]                                            | array            | 有型別的輸出項，可能混合 message、reasoning、function\_call、web\_search\_call 等；不可固定讀 output\[0]。 |
| output\[].type / id / status                         | string           | 輸出項型別、ID 和項狀態（視型別出現）。                                                               |
| output\[].role                                       | string           | 訊息輸出通常為 assistant。                                                                  |
| output\[].content\[]                                 | array            | 訊息內容項，文字為 type=output\_text；拒絕為 type=refusal。                                       |
| output\[].content\[].text / annotations              | string / array   | 本文與引用等注釋。                                                                           |
| output\[].call\_id / name / arguments                | string           | function\_call 的關聯 ID、函式名、JSON 字串參數。                                                |
| error                                                | object / null    | 失敗資訊；正常完成時通常為 null。                                                                 |
| incomplete\_details                                  | object / null    | 不完整原因，如 max\_output\_tokens，不應當作完整成功。                                               |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | 輸入、輸出和總 Token。                                                                      |
| usage.\*\_tokens\_details                            | object           | 選用快取和推理等用量明細。                                                                       |

```json
{
  "id": "resp_example",
  "object": "response",
  "created_at": 1760000000,
  "model": "MODEL_ID",
  "status": "completed",
  "error": null,
  "incomplete_details": null,
  "output": [
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "机器学习让计算机从数据中学习规律，用于预测和决策。",
          "annotations": []
        }
      ]
    }
  ],
  "usage": {
    "input_tokens": 18,
    "output_tokens": 22,
    "total_tokens": 40
  }
}
```

提取本文時，遍歷 `output` 內 `type=message` 的項，再串接其 `content` 中 `type=output_text` 的 text。SDK 的 `output_text` 是便捷聚合屬性，不應當作原始 REST JSON 必有欄位。

### 串流回應

設定 stream=true 後，按 SSE 的 `event` 和 `data` 解析：response.created 建立回應；response.output\_text.delta 追加文字；response.output\_item.added/done 管理輸出項；response.function\_call\_arguments.delta 串接工具參數。只有收到 response.completed 並檢查最終 response.status 後，才能判定完整完成；response.failed、response.incomplete 或 error 要單獨處理。不要只靠網路 EOF 判定成功。

```text
event: response.output_text.delta
data: {"type":"response.output_text.delta","item_id":"msg_example","output_index":0,"content_index":0,"delta":"机器学习","sequence_number":3}

event: response.completed
data: {"type":"response.completed","response":{"id":"resp_example","object":"response","status":"completed","output":[]},"sequence_number":12}
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/responses'
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
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        input: [
          {
            role: 'user',
            content: [
              {
                type: 'input_text',
                text: '用一句话解释什么是机器学习。',
              },
            ],
          },
        ],
        max_output_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/responses';
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/responses" \
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/responses"
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

OpenAI 原生錯誤通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可為 `null`，不能假定其始終存在或等於 HTTP 狀態碼。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 即使 HTTP 200，也必須檢查 status、error 和 incomplete\_details；SSE 中的失敗事件不一定改變已經傳送的 HTTP 狀態。

長回覆與串流請求可能持續數十秒到數分鐘；用戶端應設定足夠逾時，斷流時依已收到的增量與終止原因判斷，不要自動重送。429 與 5xx 先查看回應內容與使用記錄，內容策略拒絕時修改提示詞或輸入，不要原樣重試。

## 官方參考

* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI 串流事件](https\://developers.openai.com/api/docs/guides/streaming-responses)
* [OpenAI 對話狀態](https\://developers.openai.com/api/docs/guides/conversation-state)
* [OpenAI 背景模式](https\://developers.openai.com/api/docs/guides/background)
* [OpenAI 錯誤處理](https\://developers.openai.com/api/docs/guides/error-codes)