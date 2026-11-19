# 文件重新排序

## 介面說明

重新排序把一個 query 與候選文件清單比較，回傳按相關性排序的 index 和分數，不生成答案，也不回傳嵌入向量。SimiRouter 的 `/v1/rerank` 是否可用需確認管道；下面只演示 **Cohere 官方** `POST https://api.cohere.com/v2/rerank`，使用 `Authorization: Bearer $COHERE_API_KEY`。

## 請求參數

| 欄位                    | 型別        | 必填 | 說明                                           |
| --------------------- | --------- | -- | -------------------------------------------- |
| model                 | string    | 是  | 例如 rerank-v5.0-pro，使用帳戶已開通的模型。               |
| query                 | string    | 是  | 搜尋查詢。                                        |
| documents             | string\[] | 是  | 候選文字陣列；官方建議單次不超過 1000 條。結構化內容可先序列化為 YAML 字串。 |
| top\_n                | integer   | 否  | 至少 1，不傳則回傳全部結果。                              |
| max\_tokens\_per\_doc | integer   | 否  | 預設 4096，長文件會截斷。                              |
| relevant\_spans       | object    | 否  | v5 及更新模型可回傳相關文字區間。                           |
| priority              | integer   | 否  | 0–999，預設 0；數字越小優先順序越高。                       |

Cohere v2 的 documents 是字串陣列，不能混入未定義物件；`return_documents` 屬於其他通訊協定版本，不在本範例里傳送。

## 回傳值

`results[]` 依相關性排序：`index` 指向原文件索引，`relevance_score` 為相關性分數；啟用並支援時回傳 `relevant_spans[]`。分數不是正確率或可跨模型比較的統一機率。`meta.billed_units` 記錄計量。

```json
{"results":[{"index":1,"relevance_score":0.95},{"index":0,"relevance_score":0.12}],"id":"request_example","meta":{"api_version":{"version":"2"}}}
```

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

設定 Cohere 官方 `COHERE_API_KEY`。範例 top\_n 為正數，不使用空 query 或空文件。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.cohere.com/v2/rerank'
    headers = {'Authorization': 'Bearer ' + os.environ['COHERE_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'rerank-v5.0-pro', 'query': '法国首都是哪里？', 'documents': ['柏林是德国首都。', '巴黎是法国首都。'], 'top_n': 2}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.cohere.com/v2/rerank";
      const headers = { "Authorization": "Bearer " + process.env.COHERE_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
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
    curl "https://api.cohere.com/v2/rerank" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $COHERE_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "rerank-v5.0-pro",
        "query": "法国首都是哪里？",
        "documents": [
          "柏林是德国首都。",
          "巴黎是法国首都。"
        ],
        "top_n": 2
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
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
    }`)
      req, err := http.NewRequest("POST", "https://api.cohere.com/v2/rerank", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("COHERE_API_KEY"))
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

| HTTP 狀態               | 說明                     |
| --------------------- | ---------------------- |
| 400 / 422             | 參數或模型不接受的輸入。           |
| 401 / 498             | 驗證失敗或 token 無效。        |
| 403 / 404             | 權限不足或資源不存在。            |
| 429                   | 限流，檢查配額並有限退避。          |
| 499                   | 用戶端已關閉請求。              |
| 500 / 501 / 503 / 504 | 服務內部錯誤、未實現或逾時；保留請求 ID。 |

## 官方參考

[Cohere Rerank v2](https\://docs.cohere.com/reference/rerank)。