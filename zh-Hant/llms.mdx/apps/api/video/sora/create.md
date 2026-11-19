# 建立 Sora 影片（官方介面已關閉）

**OpenAI 官方 Sora 2 與 Videos API 已於 2026-09-24 關閉。** 下方僅保留介面結構參考，不是可用呼叫教學。SimiRouter 若存在同名模型或第三方相容實現，其來源、能力與通訊協定應另行確認，不能稱作 OpenAI 官方直連。

## 介面說明

`POST https://api.openai.com/v1/videos` 為原官方請求形式，使用 OpenAI Bearer Key；現在不應傳送新生產請求。

## 請求參數

| 欄位               | 型別     | 必填 | 說明                               |
| ---------------- | ------ | -- | -------------------------------- |
| prompt           | string | 是  | 影片文字描述。                          |
| model            | string | 否  | 原模型 sora-2 / sora-2-pro，現已關閉。    |
| seconds          | string | 否  | 原介面支援的時長，例如 4、8、12；保留為結構參考。      |
| size             | string | 否  | 原介面支援解析度，例如 1280x720。            |
| input\_reference | object | 否  | 參考圖物件，image\_url 與 file\_id 二選一。 |

## 回傳值

原建立回傳影片物件：id、object、status、progress、model、created\_at、seconds、size。status=queued / in\_progress 不表示已完成。

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

**歸檔範例，不可據此判斷介面仍可執行。** 以下用於理解原來的 HTTP 呼叫結構；請勿使用真實 Key 進行新任務測試。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/videos'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'sora-2', 'prompt': '海边日落，平稳镜头。', 'seconds': '4', 'size': '1280x720'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "sora-2",
      "prompt": "海边日落，平稳镜头。",
      "seconds": "4",
      "size": "1280x720"
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
    curl "https://api.openai.com/v1/videos" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "sora-2",
        "prompt": "海边日落，平稳镜头。",
        "seconds": "4",
        "size": "1280x720"
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
      "model": "sora-2",
      "prompt": "海边日落，平稳镜头。",
      "seconds": "4",
      "size": "1280x720"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/videos", body); check(err)
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

官方服務關閉後不再有可承諾的成功回應。原介面按 HTTP 401/403 區分驗證與權限，404 區分資源不存在，429 區分限流；生成失敗還包含 error.code/message。不要對停用端點無限重試，也不要把錯誤本文儲存為 MP4。

## 官方參考

[OpenAI 停用通知](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api)、[Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)。