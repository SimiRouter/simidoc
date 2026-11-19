# 下載 Sora 內容（官方介面已關閉）

**OpenAI 官方 Sora 2 與 Videos API 已於 2026-09-24 關閉。** 下方僅保留介面結構參考，不是可用呼叫教學。SimiRouter 若存在同名模型或第三方相容實現，其來源、能力與通訊協定應另行確認，不能稱作 OpenAI 官方直連。

## 介面說明

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content` 為原官方請求形式，使用 OpenAI Bearer Key；現在不應傳送新生產請求。

## 請求參數

| 欄位             | 型別     | 必填 | 說明                                      |
| -------------- | ------ | -- | --------------------------------------- |
| video\_id（路徑）  | string | 是  | 原建立任務 ID。                               |
| variant（query） | string | 否  | 原介面的 video、thumbnail、spritesheet 等內容型別。 |

## 回傳值

原成功回應為影片 MP4 等二進位內容，不是 URL JSON；未完成時不能下載。此官方內容服務現已關閉。

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

**歸檔範例，不可據此判斷介面仍可執行。** 以下用於理解原來的 HTTP 呼叫結構；請勿使用真實 Key 進行新任務測試。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('GET', url, headers=headers, timeout=180)
    response.raise_for_status()
    Path('video.mp4').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      const response = await fetch(url, { method: "GET", headers, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("video.mp4", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "video.mp4" ] || { printf '%s\n' "目标文件已存在：video.mp4" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X GET "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      --output "$temporary"; then
      mv "$temporary" "video.mp4"
    else
      status=$?
      cat "$temporary" >&2
      exit "$status"
    fi
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
        req, err := http.NewRequest("GET", "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content", nil); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("video.mp4", data, 0600))
    }
    ```
  </Tab>
</Tabs>

## 錯誤碼

官方服務關閉後不再有可承諾的成功回應。原介面按 HTTP 401/403 區分驗證與權限，404 區分資源不存在，429 區分限流；生成失敗還包含 error.code/message。不要對停用端點無限重試，也不要把錯誤本文儲存為 MP4。

## 官方參考

[OpenAI 停用通知](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api)、[Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)。