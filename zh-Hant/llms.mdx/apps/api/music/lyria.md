# Google Lyria 音樂生成

以下頁面依 Google 官方 API 整理。SimiRouter 尚未開放此能力，範例均直接連接 Google AI Studio Gemini API，使用 `https://generativelanguage.googleapis.com` 與 Google API 金鑰。Vertex AI 需要獨立通訊協定，本頁尚未驗證，請勿直接替換位址呼叫。

## 介面說明

`POST https://generativelanguage.googleapis.com/v1beta/interactions`，身分驗證為 `x-goog-api-key: $GEMINI_API_KEY`。Lyria 使用 Interactions，不是 generateContent，也不是 `/audio/speech`。

| 模型                     | 用途           | 時長與輸出                        |
| ---------------------- | ------------ | ---------------------------- |
| `lyria-3-clip-preview` | 片段、循環與快速試聽   | 固定 30 秒，預設 MP3。              |
| `lyria-3.5`            | 含主歌、副歌、橋段的歌曲 | 提示詞控制為幾分鐘的歌曲，預設 MP3，可請求 WAV。 |

## 請求參數

| 欄位                         | 型別             | 必填 | 說明                                      |
| -------------------------- | -------------- | -- | --------------------------------------- |
| model                      | string         | 是  | 上述 Lyria 模型之一。                          |
| input                      | string / array | 是  | 音樂描述，或 text/image 多模態內容陣列。              |
| input\[].text              | string         | 條件 | 曲風、速度、情緒、樂器、歌詞和結構。                      |
| input\[].mime\_type / data | string         | 條件 | 圖片輸入採用 image 項與真實 MIME、Base64 data。     |
| response\_format           | object         | 否  | \{"type"\:"audio"} 可請求 WAV，以實際 MIME 為準。 |

不要把時長控制當精確保證。描述曲風和器樂特徵比要求模仿特定歌手更適合安全使用。

## 回傳值

| 欄位                                | 說明                                 |
| --------------------------------- | ---------------------------------- |
| `id` / `status`                   | Interaction 識別碼與處理狀態。              |
| `steps[].content[]`               | model\_output 中包含音訊、歌詞和曲式結構，須逐項解析。 |
| 音訊項 `type` / `mime_type` / `data` | type=audio，data 是 Base64，不是 URL。   |
| 文字項 `text`                        | 歌詞、結構或其他文字內容。                      |

SDK 的 `output_audio` / `output_text` 是便利屬性；複雜交錯結果應遍歷 steps，不能只取最後一段導致遺漏。以下為回應結構節選：

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"[Instrumental]"},{"type":"audio","mime_type":"audio/mpeg","data":"<Base64音频>"}]}]}
```

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

設定 `GEMINI_API_KEY`。範例回傳 JSON，將 audio 項 data 解碼儲存 MP3；將 model 改為 `lyria-3.5` 可生成完整歌曲。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY'], 'Api-Revision': '2026-05-20'}
    response = requests.request('POST', url, headers=headers, json={'model': 'lyria-3-clip-preview', 'input': '30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY, "Api-Revision": "2026-05-20" };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "lyria-3-clip-preview",
      "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
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
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Api-Revision: 2026-05-20" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "lyria-3-clip-preview",
        "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
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
      "model": "lyria-3-clip-preview",
      "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Api-Revision", "2026-05-20")
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

Google 錯誤物件使用 `error.code`、`error.status`、`error.message`，不要只按 HTTP 數字判斷來源。本介面是同步請求，沒有任務 ID 或輪詢階段。失敗時不要把錯誤正文當作音訊資料解碼。

## 官方參考

[Google Lyria 音樂生成](https\://ai.google.dev/gemini-api/docs/music-generation)、[Interactions](https\://ai.google.dev/gemini-api/docs/interactions)。