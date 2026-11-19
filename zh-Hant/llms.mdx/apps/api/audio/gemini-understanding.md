# Gemini 音訊理解

## 介面說明

Gemini 音訊理解把錄音作為多模態輸入，回傳文字，可用於轉錄、摘要、說話者描述和時間段分析。它不是 TTS，也不是專用 `/audio/transcriptions`。本頁採用 Google 官方 `POST /v1beta/interactions`，身分驗證為 `x-goog-api-key: $GEMINI_API_KEY`，不是 SimiRouter 原生代理可用性保證。

## 請求參數

| 欄位                  | 型別      | 必填 | 說明                                        |
| ------------------- | ------- | -- | ----------------------------------------- |
| model               | string  | 是  | 支援音訊輸入的模型，例如 gemini-3.8-flash。            |
| input               | array   | 是  | text 指令與 audio 輸入組成的內容陣列。                 |
| input\[].type       | string  | 是  | 文字使用 text，音訊使用 audio。                     |
| input\[].data       | string  | 條件 | 行內音訊 Base64，不含 data URL 前綴。               |
| input\[].uri        | string  | 條件 | Google Files API 回傳的檔案 URI；與行內 data 選擇一種。 |
| input\[].mime\_type | string  | 條件 | 例如 audio/wav、audio/mpeg，須與真實內容一致。         |
| stream              | boolean | 否  | 可串流接收文字輸出，不等於持續上傳麥克風。                     |

較大錄音優先使用 Google Files API 上傳後引用 URI。行內檔案必須滿足模型與請求主體大小限制。不要把本機路徑當作雲端可讀取的 URI，也不要假設模型給出的時間戳具備專業強制對齊精度。

## 回傳值

文字位於 `steps[].content[]` 的 text 項，SDK 可用 `output_text`。長錄音的完整轉錄需檢查終態和截斷情況。範例回應節選：

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"录音主要介绍了会议议程。"}]}]}
```

## 程式碼範例

Python 3 使用標準函式庫；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

準備目前目錄中的短錄音 `speech.wav` 並設定 `GEMINI_API_KEY`。範例讀取真實檔案、編碼 Base64 後提交，輸出完整 JSON。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import json, urllib.request

    url = os.environ.get('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com').rstrip('/') + '/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")}]}
    headers['Content-Type'] = 'application/json'
    request = urllib.request.Request(url, data=json.dumps(body).encode(), headers=headers, method='POST')
    with urllib.request.urlopen(request, timeout=180) as response:
        print(response.read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const url = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "") + "/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": (await readFile("speech.wav")).toString("base64")
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
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "${base%/}/v1beta/interactions" \
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
      if os.Getenv("GEMINI_API_KEY")=="" { panic("请设置 GEMINI_API_KEY") }
      base:=os.Getenv("GEMINI_BASE_URL"); if base=="" { base="https://generativelanguage.googleapis.com" }
      media, err := os.ReadFile("speech.wav"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", body); check(err)
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

| HTTP 狀態               | 含義與處理                                     |
| --------------------- | ----------------------------------------- |
| 400                   | 請求欄位或模型參數不合法，修正後再提交。                      |
| 401                   | API Key 缺失、無效或已過期。                        |
| 403                   | 目前項目或模型沒有權限。                              |
| 404                   | 模型或路由不存在，檢查位址與模型 ID。                      |
| 429                   | 速率或配額限制，區分餘額不足與可退避重試的限流。                  |
| 500 / 502 / 503 / 504 | 服務或上游異常，保留請求 ID；對暫時故障做有限次退避，不要無限重試同一付費請求。 |

Google 錯誤物件使用 `error.code`、`error.status`、`error.message`，不要只按 HTTP 數字判斷來源。本介面是同步請求，沒有任務 ID 或輪詢階段。失敗時不要把錯誤正文當作轉錄或摘要結果。

## 官方參考

[Google 音訊理解](https\://ai.google.dev/gemini-api/docs/audio)、[Google Files](https\://ai.google.dev/gemini-api/docs/files)。