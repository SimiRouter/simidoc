# API 指令碼串接

使用 Chat Completions 介面傳送訊息並讀取模型回覆。以下四種語言完成同一項操作：向 `POST /v1/chat/completions` 傳送非串流 JSON 請求，等待完整回應後輸出結果。

## 圖片呼叫腳本

圖片生成、參考圖編輯與儲存結果的完整範例，依協議整理於[圖片 API 總覽](/simidoc/zh-Hant/apps/api/images)。

## 準備金鑰和模型

先在[API 金鑰管理](https://api.dwchainless.com/keys)建立金鑰，再從[模型廣場](https://api.dwchainless.com/zh-Hant/pricing/)複製目前金鑰可用的完整模型 ID。範例從環境變數讀取設定，不在檔案內儲存金鑰。

* `SIMIROUTER_API_KEY`：SimiRouter API Key，必填。
* `SIMIROUTER_MODEL`：完整模型 ID，必填。
* `SIMIROUTER_BASE_URL`：選用，預設 `https://api.dwchainless.com`。此變數為根位址，不包含 `/v1`。

在本機終端機或執行平台的環境變數設定中設定以上值。不要在公開記錄中輸出金鑰。真實 API 請求可能產生費用。

## 使用 OpenAI SDK（直接替換）

若程式已使用 OpenAI 官方 SDK，只需替換 `baseURL` 與 `apiKey`，並把模型名稱換成 SimiRouter 的完整模型 ID。`baseURL` 必須以 `/v1` 結尾；SDK 方法名稱、參數與回應物件都維持 OpenAI 的形狀。

<Tabs items={["Python","Node.js"]}>
  <Tab value="Python">
    ```python
    import os
    from openai import OpenAI

    client = OpenAI(
        base_url="https://api.dwchainless.com/v1",
        api_key=os.environ["SIMIROUTER_API_KEY"],
    )
    response = client.chat.completions.create(
        model=os.environ["SIMIROUTER_MODEL"],
        messages=[{"role": "user", "content": "用一句话解释什么是机器学习。"}],
    )
    print(response.choices[0].message.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    import OpenAI from 'openai';

    const client = new OpenAI({
      baseURL: 'https://api.dwchainless.com/v1',
      apiKey: process.env.SIMIROUTER_API_KEY,
    });
    const response = await client.chat.completions.create({
      model: process.env.SIMIROUTER_MODEL,
      messages: [{ role: 'user', content: '用一句话解释什么是机器学习。' }],
    });
    console.log(response.choices[0].message.content);
    ```
  </Tab>
</Tabs>

Python 與 Node.js 需先安裝官方 SDK：`pip install openai` 或 `npm install openai`。SDK 會處理重試、逾時與 SSE 串流解析；自訂逾時、`max_retries` 等用戶端選項維持 SDK 預設語義，閘道不會改寫。

閘道以 OpenAI 相容協定回應；模型能力差異取決於所選模型，SDK 不會改變這一點。若 SDK 回報 `404`，先檢查 `baseURL` 是否誤寫成 `https://api.dwchainless.com`（缺少 `/v1`）。

## 請求和回傳

| 項目     | 說明                                                                |
| ------ | ----------------------------------------------------------------- |
| 方法與路徑  | `POST /v1/chat/completions`                                       |
| 身分驗證   | `Authorization: Bearer <API Key>`                                 |
| 內容型別   | `application/json`                                                |
| 必填參數   | `model`、`messages`                                                |
| 本例選用參數 | `max_completion_tokens: 256`、`stream: false`；須由選定模型支援             |
| 成功回應   | HTTP 200，`choices[].message.content` 包含文字回覆，`usage` 為回傳的 Token 用量 |
| 串流呼叫   | `stream: true` 時回傳 SSE，不能按單個 JSON 回應解析                            |

完整參數、工具呼叫、多模態輸入和 SSE 事件說明見 [Chat Completions](/simidoc/zh-Hant/apps/api/chat/openai-chat)。

## 程式碼範例

設定 `SIMIROUTER_API_KEY`、`SIMIROUTER_MODEL`；`SIMIROUTER_BASE_URL` 可覆蓋預設閘道位址，不要在末尾追加 `/v1`。 Python 3、Node.js 18+ 和 Go 範例只使用標準函式庫；curl 範例的 JSON 由 Python 3 安全編碼。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/chat/completions'
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
      if (!process.env.SIMIROUTER_API_KEY)
        throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        messages: [
          {
            role: 'user',
            content: '用一句话解释什么是机器学习。',
          },
        ],
        max_completion_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/chat/completions';
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
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/chat/completions" \
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
      model := os.Getenv("SIMIROUTER_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/chat/completions"
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

| HTTP 狀態 | 常見原因             | 處理方法                          |
| ------- | ---------------- | ----------------------------- |
| 400     | 請求格式錯誤、模型不支援所傳參數 | 檢查回應錯誤體，省略不支援的選用參數            |
| 401     | 金鑰缺失、失效或不正確      | 檢查目前環境變數，必要時重新建立金鑰            |
| 403     | 模型、群組或管道權限受限     | 核對金鑰和帳戶權限                     |
| 404     | 路徑或模型識別碼不正確      | 檢查是否重複追加 `/v1`，核對完整模型 ID      |
| 429     | 速率限制或額度限制        | 先檢查額度與限制，按錯誤資訊退避；不要無限重試       |
| 5xx     | 閘道或上游異常          | 保留脫敏的錯誤體和請求 ID；先核對使用記錄再決定是否重試 |

上述狀態是排查入口，具體原因以錯誤回應為準。請求逾時不保證模型未執行；不要對生成請求進行無上限的自動重試。

## 其他功能

* [Responses](/simidoc/zh-Hant/apps/api/chat/openai-responses)：使用輸入項與輸出項組織請求。
* [Claude Messages](/simidoc/zh-Hant/apps/api/chat/claude)和 [Gemini](/simidoc/zh-Hant/apps/api/chat/gemini-text)：原生訊息結構。
* [繪圖](/simidoc/zh-Hant/apps/api/images)：生成、編輯與識別。
* [音訊](/simidoc/zh-Hant/apps/api/audio)：音訊理解、語音合成、轉錄與翻譯。
* [影片](/simidoc/zh-Hant/apps/api/video)：生成任務和影片理解。
* [MiMo 音訊串接](/simidoc/zh-Hant/apps/api/audio/mimo-audio)：MiMo 語音合成、轉錄與音色能力。

## 官方參考

通訊協定欄位參考 [OpenAI Chat Completions API Reference](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)。SimiRouter 的位址和金鑰與 OpenAI 官方直連不同。