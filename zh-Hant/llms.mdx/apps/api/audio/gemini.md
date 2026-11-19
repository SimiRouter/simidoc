# Gemini 語音合成

## 介面說明

Gemini TTS 用於準確朗讀指定文字，區別於互動式 Live API。下列範例使用 **Google 官方 Interactions API**：`POST https://generativelanguage.googleapis.com/v1beta/interactions`，身分驗證為 `x-goog-api-key: $GEMINI_API_KEY`。它不是 OpenAI `/audio/speech`，不能僅替換網域和 Key 來呼叫閘道。

`gemini-3.8-flash-tts` 與 `gemini-3.8-flash-lite-tts` 使用本頁結構。仍支援的 Gemini 3.1 / 2.5 Preview TTS 使用各自 generateContent 設定，不能將兩代請求混用。SimiRouter 原生代理是否提供 Interactions 需按管道確認。

## 請求參數

| 欄位                                | 型別             | 必填 | 說明                                         |
| --------------------------------- | -------------- | -- | ------------------------------------------ |
| model                             | string         | 是  | 例如 gemini-3.8-flash-tts。                   |
| input                             | string / array | 是  | 需要朗讀的文字；帶風格註解時使用 user\_input/content 結構。   |
| input\[].content\[].text          | string         | 是  | 逐字朗讀內容。                                    |
| annotations\[].type               | string         | 條件 | 風格註解使用 speech\_metadata。                   |
| annotations\[].style              | string         | 否  | 本輪語氣、口音或節奏。                                |
| annotations\[].speaker            | string         | 條件 | 多人語音時，與設定中的 speaker 名稱對應。                  |
| response\_format                  | object         | 否  | 本範例 \{"type"\:"audio"}，以回傳 MIME 為準。        |
| generation\_config.speech\_config | array / object | 是  | 單人用 \[\{"voice"\:"Kore"}]；多人用 speakers 物件。 |
| stream                            | boolean        | 否  | 模型支援時 true 回傳增量事件，不能將 SSE 文字當音訊檔案。         |

多人設定使用 `{"speakers":[{"speaker":"Joe","voice":"Kore"},{"speaker":"Jane","voice":"Puck"}]}`。每輪文字的 speech\_metadata.speaker 應引用 Joe 或 Jane，不能只把兩人台詞拼成未標註文字。聲音設計和聲音復刻需要相應 voice ID 與使用授權。

## 回傳值

REST 回傳 Interactions 物件，音訊位於 `steps[]` 中 `type=model_output` 的 `content[]`，音訊項 `type=audio`、`data` 為 Base64、`mime_type` 指明格式。SDK 的 `output_audio` 是便利屬性，不是所有 REST 回傳的根欄位。預設 WAV 可解碼後直接儲存，不能再手工補 WAV 頭。

```json
{"steps":[{"type":"model_output","content":[{"type":"audio","mime_type":"audio/wav","data":"<Base64音频>"}]}]}
```

## 程式碼範例

設定 Google 官方 `GEMINI_API_KEY`。Python 3、Node.js 18+、Go 使用標準函式庫；curl 的結果解析需要 Python 3。預設直連 Google；`GEMINI_BASE_URL` 可用於本機測試或經授權的原生通訊協定代理，位址不含 `/v1beta`。

範例檢查 `status=completed` 後解碼全部音訊項，儲存為 `speech-1.wav` 等檔案，不覆蓋同名檔案。若服務回傳其他 MIME 型別，按實際格式另行處理，不要直接改副檔名。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import base64, json, os, urllib.request
    key = os.environ["GEMINI_API_KEY"]
    base = os.environ.get("GEMINI_BASE_URL", "https://generativelanguage.googleapis.com").rstrip("/")
    body = json.loads(r'''{
      "model": "gemini-3.8-flash-tts",
      "input": [
        {
          "type": "user_input",
          "content": [
            {
              "type": "text",
              "text": "祝你今天过得愉快。",
              "annotations": [
                {
                  "type": "speech_metadata",
                  "style": "温暖自然"
                }
              ]
            }
          ]
        }
      ],
      "response_format": {
        "type": "audio"
      },
      "generation_config": {
        "speech_config": [
          {
            "voice": "Kore"
          }
        ]
      }
    }''')
    request = urllib.request.Request(base + "/v1beta/interactions", data=json.dumps(body).encode(),
        headers={"x-goog-api-key": key, "Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(request, timeout=180) as response:
        result = json.load(response)
    if result.get("status") != "completed":
        raise RuntimeError("生成未完成: " + str(result.get("status")))
    audio = [part for step in result.get("steps", []) if step.get("type") == "model_output"
             for part in step.get("content", []) if part.get("type") == "audio"]
    if not audio: raise RuntimeError("响应没有音频")
    for i, part in enumerate(audio):
        if part.get("mime_type") not in ("audio/wav", "audio/x-wav", "audio/wave"):
            raise RuntimeError("响应不是 WAV: " + str(part.get("mime_type")))
        data = base64.b64decode(part["data"], validate=True)
        if not data: raise RuntimeError("音频为空")
        name = f"speech-{i + 1}.wav"
        with open(name, "xb") as output: output.write(data)
        print(name)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { writeFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const base = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "");
      const response = await fetch(base + "/v1beta/interactions", {
        method: "POST", headers: {"x-goog-api-key": process.env.GEMINI_API_KEY, "Content-Type": "application/json"},
        body: JSON.stringify({"model":"gemini-3.8-flash-tts","input":[{"type":"user_input","content":[{"type":"text","text":"祝你今天过得愉快。","annotations":[{"type":"speech_metadata","style":"温暖自然"}]}]}],"response_format":{"type":"audio"},"generation_config":{"speech_config":[{"voice":"Kore"}]}}), signal: AbortSignal.timeout(180000)
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.status !== "completed") throw new Error("生成未完成: " + result.status);
      const audio = (result.steps || []).filter(s => s.type === "model_output").flatMap(s => s.content || []).filter(p => p.type === "audio");
      if (!audio.length) throw new Error("响应没有音频");
      for (const [i, part] of audio.entries()) {
        if (!["audio/wav", "audio/x-wav", "audio/wave"].includes(part.mime_type)) throw new Error("响应不是 WAV");
        if (!part.data || !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(part.data)) throw new Error("无效 Base64");
        const data = Buffer.from(part.data, "base64");
        const name = `speech-${i + 1}.wav`;
        await writeFile(name, data, {flag: "wx"}); console.log(name);
      }
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "${base%/}/v1beta/interactions" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "model": "gemini-3.8-flash-tts",
        "input": [
          {
            "type": "user_input",
            "content": [
              {
                "type": "text",
                "text": "祝你今天过得愉快。",
                "annotations": [
                  {
                    "type": "speech_metadata",
                    "style": "温暖自然"
                  }
                ]
              }
            ]
          }
        ],
        "response_format": {
          "type": "audio"
        },
        "generation_config": {
          "speech_config": [
            {
              "voice": "Kore"
            }
          ]
        }
      }'
    python3 - "$response" <<'PY_AUDIO'
    import base64, json, sys
    with open(sys.argv[1]) as source: result = json.load(source)
    if result.get("status") != "completed": raise RuntimeError("生成未完成")
    audio = [part for step in result.get("steps", []) if step.get("type") == "model_output"
             for part in step.get("content", []) if part.get("type") == "audio"]
    if not audio: raise RuntimeError("响应没有音频")
    for i, part in enumerate(audio):
        if part.get("mime_type") not in ("audio/wav", "audio/x-wav", "audio/wave"): raise RuntimeError("响应不是 WAV")
        data = base64.b64decode(part["data"], validate=True)
        if not data: raise RuntimeError("音频为空")
        name = f"speech-{i + 1}.wav"
        with open(name, "xb") as output: output.write(data)
        print(name)
    PY_AUDIO
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import ("bytes"; "encoding/base64"; "encoding/json"; "fmt"; "io"; "net/http"; "os"; "time"; "strings")
    func check(err error) { if err != nil { panic(err) } }
    func main() {
     key:=os.Getenv("GEMINI_API_KEY"); if key=="" { panic("请设置 GEMINI_API_KEY") }
     base:=os.Getenv("GEMINI_BASE_URL"); if base=="" {base="https://generativelanguage.googleapis.com"}
     req,err:=http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", bytes.NewBufferString(`{"model":"gemini-3.8-flash-tts","input":[{"type":"user_input","content":[{"type":"text","text":"祝你今天过得愉快。","annotations":[{"type":"speech_metadata","style":"温暖自然"}]}]}],"response_format":{"type":"audio"},"generation_config":{"speech_config":[{"voice":"Kore"}]}}`));check(err)
     req.Header.Set("x-goog-api-key",key);req.Header.Set("Content-Type","application/json")
     res,err:=(&http.Client{Timeout:180*time.Second}).Do(req);check(err);defer res.Body.Close()
     raw,err:=io.ReadAll(res.Body);check(err);if res.StatusCode>=300 {panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw))}
     var result struct {Status string `json:"status"`; Steps []struct {Type string `json:"type"`;Content []struct {Type string `json:"type"`;Mime string `json:"mime_type"`;Data string `json:"data"`} `json:"content"`} `json:"steps"`}
     check(json.Unmarshal(raw,&result));if result.Status!="completed" {panic("生成未完成")}
     count:=0
     for _,step:=range result.Steps { if step.Type!="model_output" {continue}; for _,part:=range step.Content {if part.Type!="audio" {continue}
     if part.Mime!="audio/wav" && part.Mime!="audio/x-wav" && part.Mime!="audio/wave" {panic("响应不是 WAV")}
     data,err:=base64.StdEncoding.Strict().DecodeString(part.Data);check(err);if len(data)==0 {panic("音频为空")}
     count++;name:=fmt.Sprintf("speech-%d.wav",count);out,err:=os.OpenFile(name,os.O_WRONLY|os.O_CREATE|os.O_EXCL,0600);check(err)
     _,err=out.Write(data);closeErr:=out.Close();check(err);check(closeErr);fmt.Println(name)
     }};if count==0 {panic("响应没有音频")}
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

[Google Gemini TTS](https\://ai.google.dev/gemini-api/docs/speech-generation)、[Interactions](https\://ai.google.dev/gemini-api/docs/interactions)。