# Gemini 媒體理解

## 介面說明

`POST /v1beta/models/{model}:generateContent` 在 parts 中組合文字和媒體資料，模型回傳描述、轉錄或分析結果。媒體理解不負責生成或修改圖片。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。Google 官方直連為 `https://generativelanguage.googleapis.com`，通常使用 `x-goog-api-key: $GEMINI_API_KEY`，不是閘道的 Bearer Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

範例讀取本機檔案並行內傳送，不依賴外部素材位址或 Files API；範例腳本會依副檔名識別常用圖片、音訊、影片和 PDF 的 MIME 型別。音訊、影片、PDF 應分別使用匹配的 MIME 型別與支援該輸入模態的模型；不要僅把副檔名改成圖片後傳送。

## 快速開始

1. **準備設定**：在 API 金鑰管理 建立金鑰，從模型與價格複製支援目標媒體輸入的完整模型 ID。
2. **準備素材**：選擇已授權的圖片、音訊、影片或 PDF，確認實際 MIME 類型。
3. **傳送最小請求**：把檔案位元組編碼為純 Base64 填入 `inlineData.data`，文字問題放在同一 `parts` 中；先用單張圖片驗證。
4. **讀取結果**：HTTP 2xx 且 `candidates[]` 非空才算成功，分析文字位於 `candidates[0].content.parts[].text`。
5. **驗收**：檢查 `finishReason` 與結論依據，高風險場景須人工複核。

圖片需要先編碼為 Base64，最小可用腳本見下方「程式碼範例」一節；不要手工拼接超長 Base64。

## 請求參數

| 欄位                                 | 型別             | 必填 | 說明                                                                     |
| ---------------------------------- | -------------- | -- | ---------------------------------------------------------------------- |
| model（路徑）                          | string         | 是  | 支援目標媒體輸入的模型 ID。                                                        |
| contents\[].parts\[].text          | string         | 條件 | 與媒體一同提交的問題。                                                            |
| contents\[].parts\[].inlineData    | object         | 條件 | 行內媒體，包含 mimeType 與 data；不能與同一 Part 的 text/fileData 混用。                 |
| inlineData.mimeType                | string         | 是  | 真實 MIME，如 image/png、image/jpeg、audio/mpeg、video/mp4 或 application/pdf。 |
| inlineData.data                    | string         | 是  | 檔案位元組的純 Base64，不含 data\: 前綴，也不是本機路徑。                                   |
| contents\[].parts\[].fileData      | object         | 條件 | 另一種媒體來源，包含 mimeType、fileUri；僅用已授權且廠商可讀取的 URI。                          |
| contents\[].role                   | string         | 否  | 單輪通常為 user。                                                            |
| generationConfig.maxOutputTokens   | integer        | 否  | 輸出 Token 上限。                                                           |
| systemInstruction / safetySettings | object / array | 否  | 系統指令與安全設定。                                                             |

單個 Part 只選擇一種內容型別。大檔案應使用官方支援的檔案輸入方法，不能假定閘道提供 Google 的 Files 上傳與輪詢介面。Base64 會擴大請求主體；限制需同時滿足閘道、廠商與模型要求。

### 請求結構

下面的 BASE64\_MEDIA\_BYTES 表示編碼後的檔案位元組；四語言程式碼會從本機檔案生成該欄位。

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "描述这份素材的主要内容，并指出不确定之处。"
        },
        {
          "inlineData": {
            "mimeType": "image/png",
            "data": "BASE64_MEDIA_BYTES"
          }
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 512
  }
}
```

## 回傳值

| 欄位                                    | 型別             | 說明                                                  |
| ------------------------------------- | -------------- | --------------------------------------------------- |
| candidates\[]                         | array          | 候選結果；被攔截時可能為空。                                      |
| candidates\[].index                   | integer        | 候選位置。                                               |
| candidates\[].content.role / parts\[] | string / array | 輸出角色和內容片段，文字通常位於 parts\[].text。                     |
| candidates\[].finishReason            | string         | STOP 正常結束；MAX\_TOKENS 達上限；SAFETY、RECITATION 等需單獨處理。 |
| candidates\[].safetyRatings           | array          | 選用安全評估。                                             |
| candidates\[].groundingMetadata       | object         | 使用搜尋等 grounding 工具時的來源與引用資訊。                        |
| promptFeedback.blockReason            | string         | 輸入被阻止的原因，可能沒有候選結果。                                  |
| usageMetadata.promptTokenCount        | integer        | 輸入 Token。                                           |
| usageMetadata.candidatesTokenCount    | integer        | 候選輸出 Token。                                         |
| usageMetadata.thoughtsTokenCount      | integer        | 選用思考 Token，不是可直接顯示的本文。                              |
| usageMetadata.totalTokenCount         | integer        | 本請求總 Token，可能還包括工具或思考等部分。                           |
| modelVersion / responseId             | string         | 選用模型版本與回應識別碼。                                       |

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "图片中可见一张桌子和一个杯子；杯中内容无法确定。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 280,
    "candidatesTokenCount": 30,
    "totalTokenCount": 310
  }
}
```

如果串流回傳，使用 streamGenerateContent?alt=sse 並按候選序號合併；不要假設輸出每個 part 都是文字。模型解讀存在誤差，醫療、身分或證件等高風險結論須經人工核對。

## 程式碼範例

設定 `SIMIROUTER_API_KEY`、`SIMIROUTER_GEMINI_MODEL`；`SIMIROUTER_BASE_URL` 可覆蓋預設閘道位址，不要在末尾追加 `/v1`。 `MEDIA_PATH` 指向已有的本機檔案。 Python 3、Node.js 18+ 和 Go 範例只使用標準函式庫；curl 範例的 JSON 由 Python 3 安全編碼。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    import base64
    from pathlib import Path
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }''')
    p = Path(os.environ["MEDIA_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.m4a': 'audio/mp4', '.flac': 'audio/flac', '.ogg': 'audio/ogg', '.mp4': 'video/mp4', '.mov': 'video/quicktime', '.webm': 'video/webm', '.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["contents"][0]["parts"][1]["inlineData"] = {"mimeType": mime, "data": encoded}
    path = "/v1beta/models/" + urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe="") + ":generateContent"
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const fs = require('node:fs');
      const path = require('node:path');
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_GEMINI_MODEL)
        throw new Error('请设置 SIMIROUTER_GEMINI_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '描述这份素材的主要内容，并指出不确定之处。',
              },
              {
                inlineData: {
                  mimeType: 'image/png',
                  data: 'BASE64_MEDIA_BYTES',
                },
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 512,
        },
      };
      const filename = process.env.MEDIA_PATH;
      if (!filename) throw new Error('请设置 MEDIA_PATH');
      const mime = {
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.webp': 'image/webp',
        '.mp3': 'audio/mpeg',
        '.wav': 'audio/wav',
        '.m4a': 'audio/mp4',
        '.flac': 'audio/flac',
        '.ogg': 'audio/ogg',
        '.mp4': 'video/mp4',
        '.mov': 'video/quicktime',
        '.webm': 'video/webm',
        '.pdf': 'application/pdf',
      }[path.extname(filename).toLowerCase()];
      if (!mime) throw new Error('不支持的文件扩展名');
      const data = fs.readFileSync(filename);
      if (!data.length) throw new Error('输入文件为空');
      const encoded = data.toString('base64');
      body.contents[0].parts[1].inlineData = { mimeType: mime, data: encoded };
      const endpoint = `/v1beta/models/${encodeURIComponent(process.env.SIMIROUTER_GEMINI_MODEL)}:generateContent`;
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000),
      });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_GEMINI_MODEL:?请设置 SIMIROUTER_GEMINI_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    import base64
    from pathlib import Path
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }''')
    p = Path(os.environ["MEDIA_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.m4a': 'audio/mp4', '.flac': 'audio/flac', '.ogg': 'audio/ogg', '.mp4': 'video/mp4', '.mov': 'video/quicktime', '.webm': 'video/webm', '.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["contents"][0]["parts"][1]["inlineData"] = {"mimeType": mime, "data": encoded}
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    MODEL_PATH=$(python3 -c 'import os, urllib.parse; print(urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe=""))')
    curl "${BASE_URL%/}/v1beta/models/${MODEL_PATH}:generateContent" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "bytes"
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
      "encoding/base64"
      "path/filepath"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_GEMINI_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_GEMINI_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }`), &body); err != nil { log.Fatal(err) }
      filename := os.Getenv("MEDIA_PATH"); if filename == "" { log.Fatal("请设置 MEDIA_PATH") }
      mime := map[string]string{".png":"image/png",".jpg":"image/jpeg",".jpeg":"image/jpeg",".webp":"image/webp",".mp3":"audio/mpeg",".wav":"audio/wav",".m4a":"audio/mp4",".flac":"audio/flac",".ogg":"audio/ogg",".mp4":"video/mp4",".mov":"video/quicktime",".webm":"video/webm",".pdf":"application/pdf"}[strings.ToLower(filepath.Ext(filename))]
      if mime == "" { log.Fatal("不支持的文件扩展名") }
      data, err := os.ReadFile(filename); if err != nil { log.Fatal(err) }; if len(data) == 0 { log.Fatal("输入文件为空") }
      encoded := base64.StdEncoding.EncodeToString(data)
      body["contents"].([]any)[0].(map[string]any)["parts"].([]any)[1].(map[string]any)["inlineData"] = map[string]any{"mimeType": mime, "data": encoded}
      endpoint := "/v1beta/models/" + model + ":generateContent"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## 錯誤碼

| HTTP 狀態   | 含義或廠商錯誤型別                  | 處理方式                        |
| --------- | -------------------------- | --------------------------- |
| 400       | `INVALID_ARGUMENT` 等       | 檢查 JSON、模型參數、媒體 MIME 和輸入長度。 |
| 403       | `PERMISSION_DENIED`        | 檢查 Key、項目權限、區域或帳單限制。        |
| 404       | `NOT_FOUND`                | 檢查模型名稱和 API 版本。             |
| 429       | `RESOURCE_EXHAUSTED`       | 檢查限流與配額；可重試情況採用有限次數退避。      |
| 500 / 503 | `INTERNAL` / `UNAVAILABLE` | 記錄請求識別碼，有限重試或稍後再試。          |

Google 原生錯誤物件包含 `error.code`（HTTP 數字）、`error.status`（枚舉名稱）、`error.message`，可能帶 `details`。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。

長回覆與串流請求可能持續數十秒到數分鐘；用戶端應設定足夠逾時，斷流時依已收到的增量與終止原因判斷，不要自動重送。429 與 5xx 先查看回應內容與使用記錄，內容策略拒絕時修改提示詞或輸入，不要原樣重試。

## 官方參考

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 圖片理解](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Google 音訊理解](https\://ai.google.dev/gemini-api/docs/audio)
* [Google 影片理解](https\://ai.google.dev/gemini-api/docs/video-understanding)
* [Google PDF 理解](https\://ai.google.dev/gemini-api/docs/document-processing)
* [Google 故障排查](https\://ai.google.dev/gemini-api/docs/troubleshooting)