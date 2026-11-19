# 音訊翻譯

## 介面說明

`POST /v1/audio/translations` 接收錄音並輸出**英文**，不接受任意目標語言參數。身分驗證為 `Authorization: Bearer $SIMIROUTER_API_KEY`，本文為 `multipart/form-data`。本文參考 OpenAI 官方 Audio Translations API；帳戶須具有對應模型管道。

<Callout type="warn" title="端點與模型將於 2027-02-26 關停">
  OpenAI 已將 `/v1/audio/translations` 與 `whisper-1` 標記棄用，並於 2027-02-26 關停。替代方案是 Realtime API 的 `/v1/realtime/translations` 與 `gpt-realtime-translate`，需要另行改造呼叫方式。本頁只保留遷移前的參考。
</Callout>

## 請求參數

| 欄位               | 型別     | 必填 | 說明                                              |
| ---------------- | ------ | -- | ----------------------------------------------- |
| file             | file   | 是  | 錄音檔案本體；flac、mp3、mp4、mpeg、mpga、m4a、ogg、wav、webm。 |
| model            | string | 是  | 此端點使用 whisper-1，不能替換為普通轉錄模型。                    |
| prompt           | string | 否  | 英文術語或上下文提示。                                     |
| response\_format | string | 否  | json（預設）、text、srt、verbose\_json、vtt。            |
| temperature      | number | 否  | 0–1，預設 0。                                       |

## 回傳值

JSON 回傳 `text` 英文翻譯。`verbose_json` 另含 `duration`（秒）、`language`（english）、`segments[]`。字幕格式直接回傳字幕文字，不能按 JSON 解析。本端點為單次檔案請求，不提供 stream 參數；即時翻譯是獨立工作階段介面。

```json
{"text":"Welcome to today's meeting."}
```

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

準備 `speech.wav`，並設定 `SIMIROUTER_API_KEY`。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/translations'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'whisper-1', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/translations";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "whisper-1");
      form.append("response_format", "json");
      const body = form;
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.dwchainless.com/v1/audio/translations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=whisper-1" \
      -F "response_format=json"
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
      "bytes"
      "mime/multipart"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      var buffer bytes.Buffer
      writer := multipart.NewWriter(&buffer)
      source, err := os.Open("speech.wav"); check(err)
      part, err := writer.CreateFormFile("file", "speech.wav"); check(err)
      _, err = io.Copy(part, source); source.Close(); check(err)
      check(writer.WriteField("model", "whisper-1"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/translations", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", writer.FormDataContentType())
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
| 413                   | 檔案超過上傳上限，壓縮或改用更小的檔案。                      |
| 429                   | 速率或配額限制，區分餘額不足與可退避重試的限流。                  |
| 500 / 502 / 503 / 504 | 服務或上游異常，保留請求 ID；對暫時故障做有限次退避，不要無限重試同一付費請求。 |

錯誤正文中的 `error.message`、`error.type`、`error.code` 比 HTTP 狀態提供更具體的原因。本介面是同步請求，沒有任務 ID 或輪詢階段。失敗時不要把錯誤正文儲存為轉錄文字。

## 官方參考

[OpenAI Create translation](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create)。