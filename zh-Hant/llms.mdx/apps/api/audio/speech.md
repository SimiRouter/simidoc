# 文字轉語音

## 介面說明

`POST /v1/audio/speech` 將 `input` 合成為語音。使用 SimiRouter 時，基礎位址為 `https://api.dwchainless.com`，身分驗證為 `Authorization: Bearer $SIMIROUTER_API_KEY`，本文為 `application/json`。本頁參考 OpenAI 官方 Speech API；具體模型和欄位透傳能力由所選管道決定。

<Callout type="warn" title="模型將於 2027-01-06 關停">
  `gpt-4o-mini-tts`、`tts-1`、`tts-1-hd` 已被 OpenAI 標記棄用，並於 2027-01-06 關停。官方替代為 Realtime API 的 `gpt-realtime-2.1-mini`，該模型不支援 `/v1/audio/speech`，遷移時需要改走 `/v1/realtime`。範例仍使用目前可路由的模型；呼叫前請確認管道是否已提供替代模型。
</Callout>

## 請求參數

| 欄位               | 型別              | 必填 | 說明                                     |
| ---------------- | --------------- | -- | -------------------------------------- |
| model            | string          | 是  | 可用 TTS 模型，例如 gpt-4o-mini-tts；不能使用轉錄模型。 |
| input            | string          | 是  | 朗讀文字，最多 4096 字元。                       |
| voice            | string / object | 是  | 內建音色名，或有權限的自訂聲音 \{"id"\:"voice\_..."}。 |
| instructions     | string          | 否  | 語氣、風格指令；tts-1/tts-1-hd 不支援。最多 4096 字元。 |
| response\_format | string          | 否  | mp3（預設）、opus、aac、flac、wav、pcm。         |
| speed            | number          | 否  | 0.25–4.0，預設 1。                         |
| stream\_format   | string          | 否  | audio（預設）或 sse；tts-1/tts-1-hd 不支援 sse。 |

內建音色包括 `alloy`、`ash`、`ballad`、`coral`、`echo`、`fable`、`onyx`、`nova`、`sage`、`shimmer`、`verse`、`marin`、`cedar`，具體模型可能只支援其中一部分。音色名不表示固定語言。

## 回傳值

成功時為音訊位元組，不是包含 URL 的 JSON。儲存後綴應與 `response_format` 一致；PCM 是無容器原始取樣，播放時需要匹配取樣規格。預設音訊回應可逐塊讀取以減少等待。

`stream_format: "sse"` 使用事件流；用戶端需解析事件並解碼音訊增量，不能把完整 SSE 文字儲存為 MP3。SSE 是否可用還取決於管道實現。

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

先設定 `SIMIROUTER_API_KEY`。範例選擇 MP3，並在 HTTP 失敗時停止，避免把錯誤 JSON 寫成音訊。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.dwchainless.com/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gpt-4o-mini-tts', 'input': '你好，欢迎使用语音合成。', 'voice': 'alloy', 'response_format': 'mp3'}, timeout=180)
    response.raise_for_status()
    Path('speech.mp3').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("speech.mp3", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "speech.mp3" ] || { printf '%s\n' "目标文件已存在：speech.mp3" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "https://api.dwchainless.com/v1/audio/speech" \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }' \
      --output "$temporary"; then
      mv "$temporary" "speech.mp3"
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
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }`)
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("speech.mp3", data, 0600))
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

錯誤正文中的 `error.message`、`error.type`、`error.code` 比 HTTP 狀態提供更具體的原因。本介面是同步請求，沒有任務 ID 或輪詢階段。失敗時不要把錯誤正文儲存為音訊檔案。

## 官方參考

[OpenAI Create speech](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create)。