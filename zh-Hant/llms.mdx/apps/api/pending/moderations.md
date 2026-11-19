# 內容審核

## 介面說明

`POST https://api.openai.com/v1/moderations` 同步評估文字或影像的安全分類，使用 `Authorization: Bearer $OPENAI_API_KEY`。SimiRouter 路由、模型和權限需另行確認，下方為 OpenAI 官方直連範例。

審核結果是風險訊號，不是法律合規結論，也不能保證沒有漏判。影像與文字支援的分類可能不同，必須查看 category\_applied\_input\_types，不能用某類不支援的輸入推導安全。

## 請求參數

| 欄位                      | 型別                             | 必填 | 說明                                        |
| ----------------------- | ------------------------------ | -- | ----------------------------------------- |
| model                   | string                         | 否  | 如 omni-moderation-latest；明確固定模型可減少別名更新影響。 |
| input                   | string / string\[] / object\[] | 是  | 文字或多模態內容項。                                |
| input\[].type           | string                         | 條件 | text 或 image\_url。                        |
| input\[].text           | string                         | 條件 | 文字審核內容。                                   |
| input\[].image\_url.url | string                         | 條件 | 影像 URL 或 data URL，須符合模型輸入要求。              |

## 回傳值

| 欄位                                       | 說明                   |
| ---------------------------------------- | -------------------- |
| `id` / `model`                           | 請求識別碼與審核模型。          |
| `results[].flagged`                      | 任一分類是否觸發風險。          |
| `results[].categories`                   | 按分類回傳布林值。            |
| `results[].category_scores`              | 分類分數，非人工判斷或跨模型恆定門檻值。 |
| `results[].category_applied_input_types` | 各分類適用的輸入型別。          |

```json
{"id":"modr_example","model":"omni-moderation-latest","results":[{"flagged":false,"categories":{},"category_scores":{},"category_applied_input_types":{}}]}
```

範例省略分類鍵，真實回應包含分類明細。應用應儲存必要的風險證據而非無期限保留全部使用者原文。

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

設定 `OPENAI_API_KEY`。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/moderations'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'omni-moderation-latest', 'input': '这是一段需要进行安全审核的示例文本。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/moderations";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
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
    curl "https://api.openai.com/v1/moderations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "omni-moderation-latest",
        "input": "这是一段需要进行安全审核的示例文本。"
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
      "model": "omni-moderation-latest",
      "input": "这是一段需要进行安全审核的示例文本。"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/moderations", body); check(err)
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

| HTTP 狀態               | 含義與處理                           |
| --------------------- | ------------------------------- |
| 400 / 422             | 請求欄位、檔案格式或模型參數不合法，修正後再提交。       |
| 401                   | API Key 缺失、無效或已過期。              |
| 403                   | 目前項目或模型沒有權限。                    |
| 404                   | 模型或路由不存在，檢查位址與專案歸屬。             |
| 413 / 415             | 上傳過大或媒體型別不受支援。                  |
| 429                   | 速率或配額限制，區分餘額不足與可退避重試的限流。        |
| 500 / 502 / 503 / 504 | 服務或上游異常，保留請求 ID，先查看回應本文再決定是否重試。 |

錯誤本文中的 `error.message`、`error.type`、`error.code` 比 HTTP 狀態提供更具體的原因。不要把錯誤本文當作審核結果保存。

## 官方參考

[OpenAI Create moderation](https\://developers.openai.com/api/reference/resources/moderations/methods/create)。