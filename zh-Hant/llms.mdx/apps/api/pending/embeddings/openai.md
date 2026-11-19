# OpenAI 嵌入

**SimiRouter 暫不支援本介面。以下為 OpenAI 官方直連參考。**

## 介面說明

`POST https://api.openai.com/v1/embeddings`，`Content-Type: application/json`，`Authorization: Bearer $OPENAI_API_KEY`。一次請求回傳完整向量，不支援 SSE。

## 請求參數

| 欄位               | 型別                           | 必填 | 說明                                                                  |
| ---------------- | ---------------------------- | -- | ------------------------------------------------------------------- |
| model            | string                       | 是  | text-embedding-3-small、text-embedding-3-large 等帳戶可用嵌入模型。            |
| input            | string / string\[] / token陣列 | 是  | 非空文字或 token 輸入；陣列最多 2048 項，單輸入最多 8192 tokens，單請求合計最多 300000 tokens。 |
| dimensions       | integer                      | 否  | 正整數，text-embedding-3 及後續支援的模型可縮短維度。                                 |
| encoding\_format | string                       | 否  | float（預設）回傳浮點陣列，base64 回傳編碼字串。                                      |
| user             | string                       | 否  | 不包含個人明文資訊的終端使用者識別碼。                                                 |

## 回傳值

| 欄位                                           | 說明                                    |
| -------------------------------------------- | ------------------------------------- |
| `object`                                     | list。                                 |
| `data[].object`                              | embedding。                            |
| `data[].index`                               | 對應輸入陣列的位置。                            |
| `data[].embedding`                           | 向量陣列或 Base64 字串，取決於 encoding\_format。 |
| `model`                                      | 使用的模型。                                |
| `usage.prompt_tokens` / `usage.total_tokens` | token 統計。                             |

以下省略向量中間元素，僅說明結構：

```json
{"object":"list","data":[{"object":"embedding","index":0,"embedding":[0.01,-0.02]}],"model":"text-embedding-3-small","usage":{"prompt_tokens":3,"total_tokens":3}}
```

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

設定 `OPENAI_API_KEY`。範例為同步批量輸入，結果按 index 與兩條輸入對應。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/embeddings'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'text-embedding-3-small', 'input': ['语义搜索', '文档检索'], 'encoding_format': 'float'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/embeddings";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
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
    curl "https://api.openai.com/v1/embeddings" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "text-embedding-3-small",
        "input": [
          "语义搜索",
          "文档检索"
        ],
        "encoding_format": "float"
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
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/embeddings", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

錯誤正文中的 `error.message`、`error.type`、`error.code` 比 HTTP 狀態提供更具體的原因。本介面是同步請求，沒有任務 ID 或輪詢階段。失敗時不要把錯誤正文當作向量結果解析。

## 官方參考

[OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings/methods/create)、[Embeddings guide](https\://developers.openai.com/api/docs/guides/embeddings)。