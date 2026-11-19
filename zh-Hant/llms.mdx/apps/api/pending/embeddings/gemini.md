# Gemini 嵌入

**SimiRouter 暫不支援本介面。以下為 Google 官方直連參考。** 本頁範例使用 Google AI Studio 的 Gemini API 金鑰。Vertex AI 的請求路徑、專案設定與驗證方式請依 Google Cloud 文件串接。

## 介面說明

`POST https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent`，使用 `x-goog-api-key: $GEMINI_API_KEY`。範例為文字輸入；Gemini Embedding 2 也可處理模型支援的多模態內容，但不能將這些能力套給舊文字嵌入模型。

## 請求參數

| 欄位                                      | 型別        | 必填 | 說明                                          |
| --------------------------------------- | --------- | -- | ------------------------------------------- |
| model（路徑）                               | string    | 是  | models/gemini-embedding-2；必須是可用的嵌入模型。       |
| content                                 | object    | 是  | 要嵌入的 Content 物件，文字放 parts\[].text。          |
| content.parts                           | object\[] | 是  | 文字項，或該模型支援的 inline\_data / file\_data 多模態項。 |
| embedContentConfig                      | object    | 否  | 嵌入設定。支援項以模型版本和 API Reference 為準。            |
| embedContentConfig.outputDimensionality | integer   | 否  | 模型支援的輸出維度；索引端和查詢端保持一致。                      |

`gemini-embedding-2` 不支援 `embedContentConfig.taskType` / `title`，檢索任務改用輸入前綴：

* 查詢：`task: search result | query: {content}`
* 文件：`title: {title} | text: {content}`；沒有標題時用 `title: none`
* 對稱任務：`task: {task} | query: {content}`

`taskType` / `title` 僅適用於 `gemini-embedding-001`。`gemini-embedding-2` 不支援這些欄位，請改用上面的輸入前綴，不要依賴未定義的欄位處理。embedding-2 與 embedding-001 的向量空間不相容，索引端和查詢端必須使用同一模型。

舊版頂層 `taskType`、`title`、`outputDimensionality` 屬於舊設定入口；SDK 使用 config 設定物件，不要混用 SDK snake\_case 與 HTTP JSON 的 camelCase。

## 回傳值

同步單次回傳 `embedding.values` 浮點陣列。`batchEmbedContents` 接收 requests 陣列，回傳 `embeddings[]` 按輸入順序對應。非同步 `asyncBatchEmbedContent` 會回傳長任務資源，需另行管理狀態與輸出檔案，不是本頁同步請求。

```json
{"embedding":{"values":[0.01,-0.02,0.03]}}
```

向量為節選範例。若縮短維度，應按模型指南處理正規化，不能把向量前三項當完整向量。

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

先設定 `GEMINI_API_KEY`。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent'
    headers = {'x-goog-api-key': os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'models/gemini-embedding-2', 'content': {'parts': [{'text': 'task: search result | query: 如何让文档检索理解语义？'}]}}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent";
      const headers = { "x-goog-api-key": process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "models/gemini-embedding-2",
        "content": {
          "parts": [
            {
              "text": "task: search result | query: 如何让文档检索理解语义？"
            }
          ]
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent", body); check(err)
      req.Header.Set("x-goog-api-key", os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## 錯誤碼

| HTTP 狀態               | 含義與處理                                     |
| --------------------- | ----------------------------------------- |
| 400                   | 請求欄位或模型參數不合法，修正後再提交。                      |
| 401                   | API Key 缺失、無效或已過期。                        |
| 403                   | 目前項目或模型沒有權限。                              |
| 404                   | 模型或路由不存在，檢查位址與模型 ID。                      |
| 429                   | 速率或配額限制，區分餘額不足與可退避重試的限流。                  |
| 500 / 502 / 503 / 504 | 服務或上游異常，保留請求 ID；對暫時故障做有限次退避，不要無限重試同一付費請求。 |

Google 錯誤物件使用 `error.code`、`error.status`、`error.message`，不要只按 HTTP 數字判斷來源。本介面是同步請求，沒有任務 ID 或輪詢階段。失敗時不要把錯誤正文當作向量結果解析。

## 官方參考

[Google Embeddings guide](https\://ai.google.dev/gemini-api/docs/embeddings)、[Embedding API](https\://ai.google.dev/api/embeddings)。