# Kling 圖生影片

## 介面說明

`POST https://api-singapore.klingai.com/image-to-video/kling-3.0`，身分驗證 `Authorization: Bearer $KLING_API_KEY`，本文為 JSON。範例使用 Kling 官方新版，不是 SimiRouter `/kling/v1/videos/...` 的舊版對應。

## 請求參數

| 欄位                              | 型別        | 必填 | 說明                                      |
| ------------------------------- | --------- | -- | --------------------------------------- |
| contents                        | object\[] | 是  | 影像、文字、元素等輸入內容。                          |
| contents\[].type                | string    | 是  | prompt、first\_frame、last\_frame 等支援的型別。 |
| contents\[].text                | string    | 條件 | prompt 項的動作、鏡頭和內容指令。                    |
| contents\[].url                 | string    | 條件 | first\_frame / last\_frame 的可存取圖片 URL。  |
| settings.resolution             | string    | 否  | 720p（預設）、1080p、4k；按模型權限使用。              |
| settings.duration               | integer   | 否  | 預設 5 秒；目前 3.0 參考允許 3–15 秒。              |
| settings.audio                  | string    | 否  | off（預設）或 native，生成原生音軌。                 |
| settings.multi\_shot            | boolean   | 否  | 預設 true；本範例 false 使用單鏡頭。                |
| options.callback\_url           | string    | 否  | 任務狀態回呼；需自行實現安全接收與冪等處理。                  |
| options.external\_task\_id      | string    | 否  | 帳戶內唯一自訂任務 ID，用於查詢，不覆蓋系統 ID。             |
| options.watermark\_info.enabled | boolean   | 否  | 是否同時提供有水印結果，不支援自訂水印。                    |

不同模型能力限制不能僅由欄位存在推斷。多鏡頭提示應符合官方 shot 語法，每鏡頭時長總和與總時長一致。圖生影片首尾影格、元素數量與素材格式限制以目前模型說明為準。

## 回傳值

```json
{"code":0,"message":"Success","request_id":"request_example","data":{"id":"task_example","status":"submitted","create_time":1780000000000,"update_time":1780000000000}}
```

`data.id` 是查詢使用的系統任務 ID，`data.status` 可為 submitted、processing、succeeded、failed；時間戳單位為毫秒。建立回傳沒有成品影片。不要讀取舊版 `data.task_id` 或 `task_status`。

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

設定 Kling 官方 `KLING_API_KEY`。呼叫會建立計費任務。建立後參考 [任務查詢](/simidoc/zh-Hant/apps/api/video/kling/image-status)。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api-singapore.klingai.com/image-to-video/kling-3.0'
    headers = {'Authorization': 'Bearer ' + os.environ['KLING_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'contents': [{'type': 'prompt', 'text': '镜头缓缓拉远，画面保持稳定。'}, {'type': 'first_frame', 'url': 'https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png'}], 'settings': {'resolution': '720p', 'duration': 5, 'audio': 'off', 'multi_shot': False}}, timeout=180)
    response.raise_for_status()
    result = response.json()
    if result.get("code") != 0:
        raise RuntimeError(result)
    print(result)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api-singapore.klingai.com/image-to-video/kling-3.0";
      const headers = { "Authorization": "Bearer " + process.env.KLING_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "contents": [
        {
          "type": "prompt",
          "text": "镜头缓缓拉远，画面保持稳定。"
        },
        {
          "type": "first_frame",
          "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
        }
      ],
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false
      }
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "https://api-singapore.klingai.com/image-to-video/kling-3.0" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $KLING_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "contents": [
          {
            "type": "prompt",
            "text": "镜头缓缓拉远，画面保持稳定。"
          },
          {
            "type": "first_frame",
            "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
          }
        ],
        "settings": {
          "resolution": "720p",
          "duration": 5,
          "audio": "off",
          "multi_shot": false
        }
      }'
    python3 - "$response" <<'PY_CHECK'
    import json, sys
    from pathlib import Path
    result = json.loads(Path(sys.argv[1]).read_text())
    if result.get("code") != 0:
        raise SystemExit(json.dumps(result, ensure_ascii=False))
    print(json.dumps(result, ensure_ascii=False))
    PY_CHECK
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "encoding/json"
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
      "contents": [
        {
          "type": "prompt",
          "text": "镜头缓缓拉远，画面保持稳定。"
        },
        {
          "type": "first_frame",
          "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
        }
      ],
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false
      }
    }`)
      req, err := http.NewRequest("POST", "https://api-singapore.klingai.com/image-to-video/kling-3.0", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("KLING_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      var result struct { Code int `json:"code"` }
      check(json.Unmarshal(data, &result))
      if result.Code != 0 { panic(string(data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## 錯誤碼

| HTTP / 業務碼                       | 說明                      |
| -------------------------------- | ----------------------- |
| 200 / 0                          | 請求成功，生成是否完成仍看任務 status。 |
| 400 / 1201                       | 參數錯誤，讀取 message。        |
| 404 / 1202、1203                  | 方法錯誤或模型/資源不存在。          |
| 401                              | API Key 或舊版 JWT 無效。     |
| 400 / 1300、1301                  | 平台策略或內容安全限制，修正內容，不盲目重試。 |
| 429 / 1302、1303、1304             | 速率、並行或 IP 策略限制。         |
| 500 / 5000；503 / 5001；504 / 5002 | 服務錯誤或逾時，保留 request\_id。 |

HTTP 200 不等於業務成功；首先檢查 code=0，再讀 data。

## 官方參考

[Kling 官方介面](https\://kling.ai/document-api/apiReference/model/imageToVideo)、[身分驗證](https\://kling.ai/document-api/api/get-started/authentication)、[錯誤碼](https\://kling.ai/document-api/api/get-started/error-codes)。