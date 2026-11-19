# Gemini 格式模型清單

## 介面說明

`GET /v1beta/models` 回傳 Gemini 格式的模型清單。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。Google 官方直連為 `https://generativelanguage.googleapis.com`，通常使用 `x-goog-api-key: $GEMINI_API_KEY`，不是閘道的 Bearer Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

閘道清單主要用於發現模型名稱，不能視為 Google 原生完整模型能力目錄。

## 請求參數

閘道請求無請求主體，不要求分頁參數。Google 原生 models.list 支援 pageSize（預設 50、最大 1000）和 pageToken，但目前閘道回傳完整清單，不提供相同的分頁與模型元資料保證。

| 欄位                   | 型別                     | 必填   | 說明                               |
| -------------------- | ---------------------- | ---- | -------------------------------- |
| Authorization        | header string          | 是    | Bearer 閘道 Key；官方直連改用 Google Key。 |
| pageSize / pageToken | query integer / string | 原生選用 | 僅官方原生清單的分頁請求；不要依賴閘道處理它們。         |

## 回傳值

| 欄位                                           | 型別             | 說明                                         |
| -------------------------------------------- | -------------- | ------------------------------------------ |
| models                                       | array          | 模型清單，可為空。                                  |
| models\[].name                               | string         | 模型資源名；官方通常為 models/\{id}，閘道也可能直接回傳模型 ID。   |
| models\[].displayName                        | string         | 可讀名稱。                                      |
| nextPageToken                                | string / null  | 官方的下一頁權杖；閘道可回傳 null 表示無分頁。                 |
| models\[].version / description              | string / null  | 官方可提供的版本與說明；閘道清單可缺失或為 null。                |
| models\[].inputTokenLimit / outputTokenLimit | integer / null | 官方可提供的輸入與輸出限制，不應從缺失值推斷。                    |
| models\[].supportedGenerationMethods         | array / null   | 官方可提供 generateContent 等方法名；閘道清單可缺失或為 null。 |

```json
{
  "models": [
    {
      "name": "MODEL_ID",
      "displayName": "MODEL_ID"
    }
  ],
  "nextPageToken": null
}
```

以上為閘道精簡結構範例。將 name 用於路徑前，應只去掉一次開頭的 models/。即使 models.list 成功，後續 generateContent 仍可能因權限、模型能力或配額失敗。

## 程式碼範例

設定 `SIMIROUTER_API_KEY`。可用 `SIMIROUTER_BASE_URL` 覆寫預設閘道根位址，末尾須去掉版本路徑。所有範例都傳送無請求主體的 GET。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1beta/models'
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
      const endpoint = "/v1beta/models";
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
    curl "${BASE_URL%/}/v1beta/models" \
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
      endpoint := "/v1beta/models"
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

| HTTP 狀態   | 含義或廠商錯誤型別                  | 處理方式                        |
| --------- | -------------------------- | --------------------------- |
| 400       | `INVALID_ARGUMENT` 等       | 檢查 JSON、模型參數、媒體 MIME 和輸入長度。 |
| 403       | `PERMISSION_DENIED`        | 檢查 Key、項目權限、區域或帳單限制。        |
| 404       | `NOT_FOUND`                | 檢查模型名稱和 API 版本。             |
| 429       | `RESOURCE_EXHAUSTED`       | 檢查限流與配額；可重試情況採用有限次數退避。      |
| 500 / 503 | `INTERNAL` / `UNAVAILABLE` | 記錄請求識別碼，有限重試或稍後再試。          |

Google 原生錯誤物件包含 `error.code`（HTTP 數字）、`error.status`（枚舉名稱）、`error.message`，可能帶 `details`。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 閘道內部查詢還可能回傳 success=false 的 HTTP 200 業務錯誤，須同時檢查回應結構。

## 官方參考

* [Google Models API](https\://ai.google.dev/api/models)
* [Google 模型目錄](https\://ai.google.dev/gemini-api/docs/models)
* [Google 故障排查](https\://ai.google.dev/gemini-api/docs/troubleshooting)