# 音訊轉錄

## 介面說明

`POST /v1/audio/transcriptions`，身分驗證為 `Authorization: Bearer $SIMIROUTER_API_KEY`。上傳使用 `multipart/form-data`，讓 HTTP 函式庫生成 boundary，不要手寫不帶 boundary 的 Content-Type。

本介面保留原語言，不把中文自動翻成英文。支援的檔案格式包括 flac、mp3、mp4、mpeg、mpga、m4a、ogg、wav、webm。檔案大小與錄音時長還受模型和管道限制。

<Callout type="warn" title="部分模型將於 2027-02-26 關停">
  `whisper-1`、`gpt-4o-transcribe`、`gpt-4o-mini-transcribe`（含日期快照版本）已被 OpenAI 標記棄用，並於 2027-02-26 關停。優先選擇 `gpt-transcribe`；需要即時或說話者分離時，分別使用 `gpt-live-transcribe` 或 `gpt-4o-transcribe-diarize`。
</Callout>

## 請求參數

| 欄位                            | 型別              | 必填 | 說明                                                                             |
| ----------------------------- | --------------- | -- | ------------------------------------------------------------------------------ |
| file                          | file            | 是  | 音訊檔案本體，不是檔案路徑字串或普通 URL。                                                        |
| model                         | string          | 是  | 如 gpt-transcribe、gpt-4o-transcribe、gpt-4o-mini-transcribe、whisper-1 或分離說話者的模型。 |
| language                      | string          | 否  | 輸入語言 ISO-639-1 代碼，例如 zh、en。                                                    |
| languages\[]                  | string\[]       | 否  | 候選語言清單，僅支援此欄位的模型使用。                                                            |
| prompt                        | string          | 否  | 術語和上下文提示，應與錄音語言一致；diarize 模型不支援。                                               |
| keywords\[]                   | string\[]       | 否  | 術語提示，僅 gpt-transcribe。                                                         |
| response\_format              | string          | 否  | 預設 json；text、srt、vtt、verbose\_json、diarized\_json 的支援情況按模型區分。                  |
| temperature                   | number          | 否  | 0–1，預設 0。                                                                      |
| stream                        | boolean         | 否  | true 回傳 SSE；whisper-1 不支援。                                                     |
| include\[]                    | string\[]       | 否  | logprobs 僅適用於支援的模型且 response\_format=json。                                     |
| timestamp\_granularities\[]   | string\[]       | 否  | word / segment，要求 verbose\_json 與支援的模型，不適用於 diarize。                           |
| chunking\_strategy            | string / object | 條件 | auto 或 server\_vad 設定；diarize 輸入超過 30 秒時必須設定。                                  |
| known\_speaker\_names\[]      | string\[]       | 否  | 最多 4 位已知說話者的短名稱，需與音訊參考對應。                                                      |
| known\_speaker\_references\[] | string\[]       | 否  | 2–10 秒的音訊 data URL，與名稱一一對應，用於支援此能力的模型。                                         |

`gpt-4o-transcribe` 與 `gpt-4o-mini-transcribe` 使用 JSON 輸出；`whisper-1` 支援 text、srt、vtt、verbose\_json 等格式。需要說話者標註時使用支援 diarize 的模型與 `diarized_json`，不要給普通模型強加該參數。

## 回傳值

| 欄位                       | 說明                          |
| ------------------------ | --------------------------- |
| `text`                   | 完整轉錄文字。                     |
| `usage`                  | 模型提供的消耗統計，欄位隨模型變化。          |
| `logprobs`               | 請求並支援時回傳的 token 信心資訊。       |
| `language` / `duration`  | verbose\_json 的語言及音訊秒數。     |
| `words[]` / `segments[]` | 支援時間戳或說話者格式時的片段，不保證每種輸出都具備。 |

```json
{"text":"欢迎参加今天的会议。"}
```

`stream=true` 在支援的模型上回傳 SSE 轉錄增量和完成事件，接收方必須持續讀流。它仍然先上傳整個檔案，不是雙向麥克風 Realtime。

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

準備目前目錄下的 `speech.wav` 並設定 `SIMIROUTER_API_KEY`。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'gpt-4o-mini-transcribe', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "gpt-4o-mini-transcribe");
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
    curl "https://api.dwchainless.com/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=gpt-4o-mini-transcribe" \
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
      check(writer.WriteField("model", "gpt-4o-mini-transcribe"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/transcriptions", &buffer); check(err)
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

[OpenAI Create transcription](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create)。