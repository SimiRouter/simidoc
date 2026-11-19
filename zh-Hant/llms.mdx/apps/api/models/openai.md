# OpenAI 格式模型清單

## 介面說明

`GET /v1/models` 回傳目前 Key 可見的模型清單。清單可用於設定介面的模型選擇，不證明模型具備所有模態、工具、可用額度或即時服務能力。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直連為 `https://api.openai.com`，同樣使用 Bearer 身分驗證，但必須換成 OpenAI 的 Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

只傳送 Bearer 驗證，不混用 x-api-key 或 x-goog-api-key，以免觸發閘道其他回傳格式。

## 請求參數

該清單請求無 JSON 請求主體，也沒有必填查詢參數。

| 欄位            | 型別            | 必填 | 說明                |
| ------------- | ------------- | -- | ----------------- |
| Authorization | header string | 是  | Bearer 後攜帶閘道 Key。 |

## 回傳值

| 欄位                                | 型別                     | 說明                                            |
| --------------------------------- | ---------------------- | --------------------------------------------- |
| object                            | string                 | list。                                         |
| data                              | array                  | 模型清單，允許為空。                                    |
| data\[].id                        | string                 | 呼叫生成介面時使用的模型 ID。                              |
| data\[].object                    | string                 | model。                                        |
| data\[].created                   | integer                | Unix 秒時間戳；閘道元資料不一定等於廠商模型發佈日期。                 |
| data\[].owned\_by                 | string                 | 模型歸屬標籤，不能據此證明請求一定路由到某一廠商。                     |
| success                           | boolean                | 閘道可附加的業務結果標誌，不是 OpenAI 標準欄位。                  |
| `data[].context_length`           | integer                | 閘道提供的上下文長度（Token），未設定時使用平台預設值。以模型說明和實際介面限制為準。 |
| `data[].supported_endpoint_types` | `array<string>` / null | 閘道公布的介面類型。可作為選擇介面的參考。                         |

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

空陣列是合法清單，不要直接存取 data\[0]。閘道查詢使用者群組失敗時可回傳 HTTP 200 且 success=false/message；用戶端仍須識別業務失敗。官方 OpenAI 另有 GET /v1/models/\{model} 查詢單模型，不應將清單元資料當作完整能力說明。

## 程式碼範例

設定 `SIMIROUTER_API_KEY`。可用 `SIMIROUTER_BASE_URL` 覆寫預設閘道根位址，末尾須去掉版本路徑。所有範例都傳送無請求主體的 GET。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1/models'
    request = urllib.request.Request(base + path, method="GET",
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
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const endpoint = "/v1/models";
      const response = await fetch(base + endpoint, { method: "GET",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    curl "${BASE_URL%/}/v1/models" \
      --fail-with-body \
      --max-time 120 \
      -X GET \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      endpoint := "/v1/models"
      req, err := http.NewRequest("GET", base + endpoint, nil); if err != nil { log.Fatal(err) }
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

OpenAI 原生錯誤通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可為 `null`，不能假定其始終存在或等於 HTTP 狀態碼。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 還需檢查閘道 success=false 的業務錯誤；這與 HTTP 傳輸成功不同。

## 官方參考

* [OpenAI List models](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [OpenAI Retrieve model](https\://developers.openai.com/api/reference/resources/models/methods/retrieve)
* [OpenAI 錯誤處理](https\://developers.openai.com/api/docs/guides/error-codes)