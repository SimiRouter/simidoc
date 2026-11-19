# Gemini 文字生成

## 介面說明

`POST /v1beta/models/{model}:generateContent` 接收 Gemini contents/parts 結構，非串流回傳完整 GenerateContentResponse。該介面與 OpenAI 的 messages 或 input 格式不同。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。Google 官方直連為 `https://generativelanguage.googleapis.com`，通常使用 `x-goog-api-key: $GEMINI_API_KEY`，不是閘道的 Bearer Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

## 快速開始

1. **準備設定**：在 API 金鑰管理 建立金鑰，從模型與價格複製支援 generateContent 的完整模型 ID。
2. **傳送最小請求**：把模型 ID 直接寫進路徑（不要帶 `models/` 前綴），`generationConfig.maxOutputTokens` 設為較小值。
3. **讀取結果**：HTTP 2xx 且 `candidates[]` 非空才算成功，正文通常位於 `candidates[0].content.parts[].text`。
4. **驗收**：檢查 `finishReason` 與 `promptFeedback`，再核對使用記錄。

```bash
API_URL="https://api.dwchainless.com/v1beta/models/MODEL_ID:generateContent"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"role": "user", "parts": [{"text": "用一句话解释机器学习。"}]}],
    "generationConfig": {"maxOutputTokens": 256}
  }'
```

把 `PASTE_API_KEY_HERE` 和路徑中的 `MODEL_ID` 換成實際值；串流需改用 `streamGenerateContent?alt=sse`。

## 請求參數

請求主體為 JSON。REST 欄位統一使用 lowerCamelCase；不要把 Python SDK 的 snake\_case 參數名機械複製到 REST 請求中。

| 欄位                                         | 型別               | 必填 | 說明                                          |
| ------------------------------------------ | ---------------- | -- | ------------------------------------------- |
| model（路徑）                                  | string           | 是  | 模型 ID，不帶 models/ 前綴；原生資源名為 models/\{model}。 |
| contents                                   | array            | 是  | 按順序包含歷史和目前訊息。                               |
| contents\[].role                           | string           | 否  | user 或 model；多輪對話顯式指定。                      |
| contents\[].parts                          | array            | 是  | 訊息內容片段，至少一項。                                |
| parts\[].text                              | string           | 條件 | 文字片段；媒體片段改用 inlineData 或 fileData。          |
| systemInstruction.parts\[].text            | string           | 否  | 系統指令，不要使用 role=system 代替。                   |
| generationConfig.maxOutputTokens           | integer          | 否  | 生成 Token 上限，需結合模型對推理 Token 的計量規則。           |
| generationConfig.responseMimeType          | string           | 否  | 需要結構化輸出時可使用 application/json，須模型支援。         |
| generationConfig.responseJsonSchema        | object           | 否  | 回應 JSON Schema，通常與 application/json 一同設定。   |
| generationConfig.temperature / topP / topK | number / integer | 否  | 僅支援該取樣設定的模型使用；不要跨代重複使用固定參數。                 |
| generationConfig.stopSequences             | array            | 否  | 模型支援時的停止串。                                  |
| safetySettings                             | array            | 否  | 安全類別與門檻值，不能關閉所有模型的全部安全機制。                   |
| tools / toolConfig                         | array / object   | 否  | Google 搜尋、函式呼叫等工具定義與呼叫設定。                   |

### 請求範例

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "用一句话解释机器学习。"
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 256
  }
}
```

多輪對話交替加入 role=user 和 role=model，最後一項是目前問題；伺服器不會根據前一次 HTTP 連接自動儲存本次對話。

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
            "text": "机器学习让计算机通过数据学习规律并完成预测。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 12,
    "candidatesTokenCount": 20,
    "totalTokenCount": 32
  }
}
```

### 串流回應

將路徑改為 `/v1beta/models/{model}:streamGenerateContent?alt=sse`，請求主體不變。逐個解析 data 中的 GenerateContentResponse，按 candidate.index 合併 parts 文字；不要等待 OpenAI 的 `[DONE]` 標記。最終檢查 finishReason、promptFeedback 與用量。SSE 是同一次生成的增量交付，不是背景任務，也不等於多個請求平行。

## 程式碼範例

設定 `SIMIROUTER_API_KEY`、`SIMIROUTER_GEMINI_MODEL`；`SIMIROUTER_BASE_URL` 可覆蓋預設閘道位址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 範例只使用標準函式庫；curl 範例的 JSON 由 Python 3 安全編碼。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
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
                text: '用一句话解释机器学习。',
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 256,
        },
      };
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
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
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
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }`), &body); err != nil { log.Fatal(err) }
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

Google 原生錯誤物件包含 `error.code`（HTTP 數字）、`error.status`（枚舉名稱）、`error.message`，可能帶 `details`。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 HTTP 200 下 candidates 為空或 finishReason=SAFETY 可能表示內容被阻止，不是網路故障。

長回覆與串流請求可能持續數十秒到數分鐘；用戶端應設定足夠逾時，斷流時依已收到的增量與終止原因判斷，不要自動重送。429 與 5xx 先查看回應內容與使用記錄，內容策略拒絕時修改提示詞或輸入，不要原樣重試。

## 官方參考

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 文字生成](https\://ai.google.dev/gemini-api/docs/text-generation)
* [Google 故障排查](https\://ai.google.dev/gemini-api/docs/troubleshooting)