# 查詢 Sora 任務（官方介面已關閉）

**OpenAI 官方 Sora 2 與 Videos API 已於 2026-09-24 關閉。** 下方僅保留介面結構參考，不是可用呼叫教學。SimiRouter 若存在同名模型或第三方相容實現，其來源、能力與通訊協定應另行確認，不能稱作 OpenAI 官方直連。

## 介面說明

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID` 為原官方請求形式，使用 OpenAI Bearer Key；現在不應傳送新生產請求。

## 請求參數

| 欄位            | 型別     | 必填 | 說明        |
| ------------- | ------ | -- | --------- |
| video\_id（路徑） | string | 是  | 原建立任務 ID。 |

## 回傳值

原查詢回傳 id、status、progress、model、created\_at、completed\_at、expires\_at、error 等。completed 才可下載；failed 從 error.code/message 取得原因。

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

**歸檔範例，不可據此判斷介面仍可執行。** 以下用於理解原來的 HTTP 呼叫結構；請勿使用真實 Key 進行新任務測試。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('GET', url, headers=headers, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      const response = await fetch(url, { method: "GET", headers, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID" \
      --fail-with-body \
      --max-time 180 \
      -X GET \
      -H "Authorization: Bearer $OPENAI_API_KEY"
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
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        req, err := http.NewRequest("GET", "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID", nil); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

官方服務關閉後不再有可承諾的成功回應。原介面按 HTTP 401/403 區分驗證與權限，404 區分資源不存在，429 區分限流；生成失敗還包含 error.code/message。不要對停用端點無限重試，也不要把錯誤本文儲存為 MP4。

## 官方參考

[OpenAI 停用通知](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api)、[Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)。