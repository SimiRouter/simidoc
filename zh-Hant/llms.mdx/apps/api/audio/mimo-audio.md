# MiMo 音訊串接

## 介面說明

MiMo 支援語音合成、語音轉錄、音色設計與參考聲音複製。需要區分兩種介面：

| 通訊協定     | 位址/端點                                               | 身分驗證                           | 輸出                          |
| -------- | --------------------------------------------------- | ------------------------------ | --------------------------- |
| 獨立音訊相容服務 | 部署位址的 `/v1/audio/speech`、`/v1/audio/transcriptions` | 服務自身的 Bearer Key，也接受 x-api-key | 音訊位元組或轉錄結果                  |
| 小米官方原生   | `https://api.xiaomimimo.com/v1/chat/completions`    | MiMo 官方 api-key 或 Bearer Key   | Chat Completions JSON / SSE |

**相容路由不是小米官方原生端點。** 下方相容範例預設直連獨立服務 `http://127.0.0.1:8080`；若服務位於其他位址，替換主機和連接埠。SimiRouter 公網是否設定了相同路由需單獨確認，不能直接套用獨立服務 Key。

## 請求參數

### 語音合成：POST /v1/audio/speech

| 欄位               | 型別              | 必填 | 說明                                                                |
| ---------------- | --------------- | -- | ----------------------------------------------------------------- |
| model            | string          | 是  | mimo-v2.5-tts、mimo-v2.5-tts-voicedesign、mimo-v2.5-tts-voiceclone。 |
| input            | string          | 是  | 非空朗讀文字；預設最大 4096 字元，部署可設定。                                        |
| voice            | string / object | 是  | 預設音色；複製時用音訊 data URL，或服務建立的 \{"id"\:"voice\_..."}。                |
| instructions     | string          | 否  | 語氣/風格指令，最多 4096 字元。                                               |
| style            | string          | 否  | 相容服務擴展欄位，優先於 instructions；voicedesign 用它描述音色。                     |
| speed            | number          | 否  | 0.25–4，預設 1；轉換為風格提示，不保證逐取樣精確變速。                                   |
| response\_format | string          | 否  | wav、mp3、opus、aac、flac、pcm。直接 MiMo 模型預設 wav，建議顯式設定。                |
| stream\_format   | string          | 否  | 相容服務只接受 audio；sse 明確回傳 400，不提供上游低延遲合成流。                           |

預設音色對應：alloy→冰糖、echo→茉莉、fable→白樺、onyx→蘇打、nova→Mia、shimmer→Chloe、dean→Dean、milo→Milo。名稱是相容服務的對應，不等同於 OpenAI 同名聲音。

### 語音轉錄：POST /v1/audio/transcriptions

| 欄位                          | 型別        | 必填 | 說明                                                      |
| --------------------------- | --------- | -- | ------------------------------------------------------- |
| file                        | file      | 是  | multipart 檔案；預設最大 25 MiB，部署可設定。                         |
| model                       | string    | 是  | mimo-v2.5-asr。                                          |
| language                    | string    | 否  | auto（預設）、zh、en。                                         |
| languages\[]                | string\[] | 否  | 候選語言，與 language 互斥；多候選歸並為自動識別。                          |
| response\_format            | string    | 否  | json（預設）、text、verbose\_json、srt、vtt。diarized\_json 不支援。 |
| stream                      | boolean   | 否  | 轉錄完成後輸出 SSE 事件，不是上游邊聽邊轉錄。                               |
| timestamp\_granularities\[] | string\[] | 否  | 不支援；非空回傳 400，不偽造詞級/分段時間戳。                               |

相容服務可接收 mp3、wav、aac、flac、m4a、mp4、mpeg、mpga、oga、ogg、opus、webm；非原生格式需要媒體轉換元件。小米官方原生 ASR 的輸入範圍只有 MP3/WAV，不能互相套用限制。

## 回傳值

* TTS 成功回傳相應 MIME 的音訊二進位；這是完成合成後的 HTTP 回應，沒有公開 task\_id。
* ASR JSON 為 `{"text":"识别文字"}`；text 直接回傳純文字。
* verbose\_json 含 task、language、duration、text 與空 segments，**不提供真實分段時間戳**。SRT/VTT 是整段字幕，不是詞級對齊。
* stream=true 只將最終轉錄包裝為 SSE，用戶端不能據此判斷上游支援即時識別。

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

### 文字轉語音

設定獨立服務 `MIMO_AUDIO_API_KEY`。範例輸出 `mimo-speech.wav`。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'http://127.0.0.1:8080/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'mimo-v2.5-tts', 'input': '你好，欢迎使用 MiMo 语音。', 'voice': 'alloy', 'response_format': 'wav'}, timeout=180)
    response.raise_for_status()
    Path('mimo-speech.wav').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("mimo-speech.wav", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "mimo-speech.wav" ] || { printf '%s\n' "目标文件已存在：mimo-speech.wav" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "http://127.0.0.1:8080/v1/audio/speech" \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }' \
      --output "$temporary"; then
      mv "$temporary" "mimo-speech.wav"
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
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }`)
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("mimo-speech.wav", data, 0600))
    }
    ```
  </Tab>
</Tabs>

### 語音轉文字

準備 `speech.wav`。身分驗證仍使用獨立服務 Key。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'http://127.0.0.1:8080/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'mimo-v2.5-asr', 'language': 'auto', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "mimo-v2.5-asr");
      form.append("language", "auto");
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
    curl "http://127.0.0.1:8080/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=mimo-v2.5-asr" \
      -F "language=auto" \
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
      check(writer.WriteField("model", "mimo-v2.5-asr"))
      check(writer.WriteField("language", "auto"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/transcriptions", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
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

### 音色設計與聲音複製

音色設計將 model 改為 `mimo-v2.5-tts-voicedesign`，新增 `style: "温暖低沉的成年男声，普通话清晰"`。聲音複製將 model 改為 `mimo-v2.5-tts-voiceclone`，voice 設定為 `data:audio/wav;base64,<真实参考音频>`。不要傳送空 Base64、偽裝副檔名或未經授權的他人聲音。

```python
import base64
import os
from pathlib import Path
import requests
reference = base64.b64encode(Path("reference.wav").read_bytes()).decode("ascii")
response = requests.post("http://127.0.0.1:8080/v1/audio/speech",
    headers={"Authorization": "Bearer " + os.environ["MIMO_AUDIO_API_KEY"]},
    json={"model":"mimo-v2.5-tts-voiceclone","input":"这是一条授权声音示例。",
          "voice":"data:audio/wav;base64," + reference,"response_format":"wav"}, timeout=180)
response.raise_for_status()
Path("clone.wav").write_bytes(response.content)
```

### 小米官方原生通訊協定

官方 TTS 使用 `assistant` 訊息承載朗讀文字、`user` 訊息提供風格說明。範例為官方 JSON，不得發到 `/audio/speech`：

```json
{"model":"mimo-v2.5-tts","messages":[{"role":"user","content":"温暖自然"},{"role":"assistant","content":"你好，欢迎使用 MiMo。"}],"audio":{"format":"wav","voice":"mimo_default"},"stream":false}
```

官方回傳音訊在 `choices[0].message.audio.data`，需 Base64 解碼。原生 ASR 把音訊放入 `messages[0].content`：

```json
{"model":"mimo-v2.5-asr","messages":[{"role":"user","content":[{"type":"input_audio","input_audio":{"data":"data:audio/wav;base64,<真实Base64>"}}]}],"asr_options":{"language":"auto"},"stream":false}
```

原生 ASR 文字在 `choices[0].message.content`。data URL 已包含格式時 format 選用；裸 Base64 必須指定 `format: "wav"` 或 `"mp3"`，兩者同時設定時須一致。

## 錯誤碼

| HTTP / code                       | 含義                 |
| --------------------------------- | ------------------ |
| 400 / unsupported\_audio\_format  | TTS 輸出格式非法。        |
| 400 / speech\_sse\_not\_supported | 相容服務不支援 TTS SSE。   |
| 400 / diarization\_not\_supported | ASR 不支援說話者分離格式。    |
| 400 / timestamps\_not\_supported  | ASR 不支援時間戳粒度。      |
| 401 / 403                         | 獨立服務 Key 或權限錯誤。    |
| 404 / voice\_not\_found           | 自訂聲音不存在或不屬於目前 Key。 |
| 413 / input\_too\_large           | 文字或媒體超出限制。         |
| 415 / unsupported\_file\_type     | 檔案副檔名或 MIME 不受支援。  |
| 422 / invalid\_audio              | 媒體不能解碼。            |
| 502 / invalid\_audio\_output      | 上游沒有回傳有效音訊。        |
| 503 / audio\_failover\_exhausted  | 音訊服務暫不可用。          |

複製聲音上傳屬於有狀態操作，不應在逾時後盲目重複。

## 官方參考

[MiMo TTS](https\://mimo.mi.com/docs/en-US/api/audio/tts)、[MiMo ASR](https\://mimo.mi.com/docs/en-US/api/audio/Speech-Recognition)。這些官方頁面說明原生通訊協定，不把相容服務的擴展欄位列為廠商原生能力。