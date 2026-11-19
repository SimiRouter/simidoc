# Gemini 影片理解

## 介面說明

影片理解接收已有影片，回傳文字分析，不生成新影片。下方使用 **Google 官方 Interactions**：`POST https://generativelanguage.googleapis.com/v1beta/interactions`，身分驗證為 `x-goog-api-key: $GEMINI_API_KEY`。不能把它當 Seedance/Kling 建立任務，也不意味著 SimiRouter 已對應 Google 全部媒體輸入能力。

## 請求參數

| 欄位                  | 型別      | 必填 | 說明                                        |
| ------------------- | ------- | -- | ----------------------------------------- |
| model               | string  | 是  | 支援影片輸入的模型，例如 gemini-3.8-flash。            |
| input               | array   | 是  | video 素材與 text 問題。                        |
| input\[].type       | string  | 是  | video 或 text。                             |
| input\[].data       | string  | 條件 | 短影片 Base64 內容，與 uri 二選一。                  |
| input\[].mime\_type | string  | 條件 | 如 video/mp4，應匹配真實編碼。                      |
| input\[].uri        | string  | 條件 | 已上傳並 ACTIVE 的 Google 檔案 URI，或模型支援的公開影片位址。 |
| input\[].text       | string  | 條件 | 摘要、問答或帶具體時間範圍的問題。                         |
| stream / background | boolean | 否  | 長分析可採用串流或背景模式，須使用對應事件/任務處理流程。             |

本範例保守選擇總請求小於 20 MB 的短 MP4。較大或重複使用的影片優先走 Google Files API；檔案完成上傳後還需等待 ACTIVE，FAILED 必須停止，不能無上限輪詢。公開影片 URL、Cloud Storage 與直接行內是不同輸入路徑，不能隨意互換。

## 回傳值

Interactions 的 `steps[]` 中包含 model\_output，文字項為 `content[].type=text` 與 `text`。SDK 的 output\_text 是便利屬性。時間點屬於模型理解結果，應按原影片複核，不能自動視為精確取證或逐影格標註。

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"00:10 出现海面上的帆船，随后镜头向右移动。"}]}]}
```

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

準備短影片 `video.mp4` 並設定 Google 官方 `GEMINI_API_KEY`。範例沒有呼叫付費生成模型，也沒有發起檔案管理操作，但推理請求本身仍可能計費。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")}]}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": (await readFile("video.mp4")).toString("base64")
        }
      ]
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
    set -eu
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "encoding/base64"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      media, err := os.ReadFile("video.mp4"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
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

| HTTP 狀態               | 含義與處理                                             |
| --------------------- | ------------------------------------------------- |
| 400 / 422             | 請求欄位、檔案格式或模型參數不合法，修正後再提交。                         |
| 401                   | API Key 缺失、無效或已過期。                                |
| 403                   | 目前項目或模型沒有權限。                                      |
| 404                   | 模型、路由或輸入資源不存在，檢查位址、模型 ID 與檔案狀態。                   |
| 413 / 415             | 上傳過大或媒體型別不受支援。                                    |
| 429                   | 速率或配額限制，區分餘額不足與可退避重試的限流。                          |
| 500 / 502 / 503 / 504 | 服務或上游異常，保留請求 ID；同步請求逾時後先查看日誌或請求狀態，再決定是否重試，避免重複計費。 |

Google 錯誤物件使用 `error.code`、`error.status`、`error.message`；請求失敗時不要把錯誤正文當作正常分析結果。

## 官方參考

[Google 影片理解](https\://ai.google.dev/gemini-api/docs/video-understanding)、[Files](https\://ai.google.dev/gemini-api/docs/files)。