# 建立 Seedance 影片任務

## 介面說明

`POST https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks`，`Authorization: Bearer $ARK_API_KEY`，JSON 本文。下方為官方直連通訊協定，**不是** SimiRouter `/v1/video/generations` 對應保證。

## 請求參數

| 欄位                        | 型別        | 必填 | 說明                                                                      |
| ------------------------- | --------- | -- | ----------------------------------------------------------------------- |
| model                     | string    | 是  | 已開通的 Seedance 模型 ID 或推理串接點 ID。                                          |
| content                   | object\[] | 是  | 文字和模型支援的影像/影片/音訊內容項。                                                    |
| content\[].type           | string    | 是  | text、image\_url、video\_url、audio\_url、draft\_task，按模型能力使用。              |
| content\[].draft\_task.id | string    | 條件 | type=draft\_task 時的草稿任務 ID，用於基於草稿生成正式影片。                                |
| content\[].text           | string    | 條件 | type=text 的提示詞。                                                         |
| content\[].image\_url.url | string    | 條件 | 可存取圖片或模型允許的 data URL。                                                   |
| content\[].role           | string    | 否  | 如 first\_frame、last\_frame、reference\_image；按模型和素材型別使用。                 |
| resolution                | string    | 否  | 模型允許的解析度，按模型可選 480p、720p、1080p、4k；草稿僅支援 480p。                           |
| ratio                     | string    | 否  | 如 16\:9、9\:16、1\:1、adaptive，具體支援以模型表為準。                                 |
| duration                  | integer   | 否  | 影片時長；範圍按模型，支援自動時長的模型可用 -1。                                              |
| frames                    | integer   | 否  | 指定影格數，僅支援模型可用；與 duration 同時出現時以 frames 為準。                              |
| generate\_audio           | boolean   | 否  | 是否生成音軌，僅有聲模型支援。                                                         |
| watermark                 | boolean   | 否  | 顯式水印設定；需遵守合成內容標示要求。                                                     |
| seed                      | integer   | 否  | 隨機種子，復現性並非逐像素保證。                                                        |
| return\_last\_frame       | boolean   | 否  | 請求回傳尾影格影像。                                                              |
| callback\_url             | string    | 否  | 狀態變化通知位址，接收方需處理重複與亂序通知。                                                 |
| execution\_expires\_after | integer   | 否  | 任務過期秒數，預設 172800，範圍 3600–259200。                                        |
| service\_tier             | string    | 否  | default / flex，支援範圍按模型。                                                 |
| draft                     | boolean   | 否  | 產生草稿影片，預設 false；支援的模型僅接受 480p。基於草稿生成正式影片改用 `content[].type=draft_task`。 |
| priority                  | integer   | 否  | 支援模型/服務等級的排隊優先順序，不適用於所有呼叫。                                              |

本範例選擇 Seedance 2.5，使用純文字和短影片參數。更換到 1.0 pro / 2.0 時，應按該版本能力刪改欄位，不能假設多模態參考、音訊和草稿全部可用。

## 回傳值

建立成功回傳 `id`，不是完成的影片。儲存 ID 後使用 [查詢介面](/simidoc/zh-Hant/apps/api/video/seedance/status)。

```json
{"id":"cgt-example"}
```

請求逾時不能說明伺服器端未受理，避免自動無限重發建立請求。回呼接收端應按任務 ID 冪等更新狀態。

## 程式碼範例

Python 範例需 `python3 -m pip install requests`；Node.js 範例使用 Node.js 18 或更新版本的內建 fetch；Go 使用標準函式庫。

設定官方 `ARK_API_KEY`；呼叫會建立可能計費的任務。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks'
    headers = {'Authorization': 'Bearer ' + os.environ['ARK_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'doubao-seedance-2-5-260628', 'content': [{'type': 'text', 'text': '海边日落时，一艘白色帆船缓缓驶过，镜头平稳。'}], 'duration': 5, 'ratio': '16:9', 'generate_audio': True, 'watermark': True}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks";
      const headers = { "Authorization": "Bearer " + process.env.ARK_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
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
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $ARK_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "doubao-seedance-2-5-260628",
        "content": [
          {
            "type": "text",
            "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
          }
        ],
        "duration": 5,
        "ratio": "16:9",
        "generate_audio": true,
        "watermark": true
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
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
    }`)
      req, err := http.NewRequest("POST", "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("ARK_API_KEY"))
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

| HTTP 狀態               | 含義與處理                                   |
| --------------------- | --------------------------------------- |
| 400 / 422             | 請求欄位、檔案格式或模型參數不合法，修正後再提交。               |
| 401                   | API Key 缺失、無效或已過期。                      |
| 403                   | 目前項目或模型沒有權限。                            |
| 404                   | 模型、路由或任務不存在，檢查位址與資源歸屬。                  |
| 413 / 415             | 上傳過大或媒體型別不受支援。                          |
| 429                   | 速率或配額限制，區分餘額不足與可退避重試的限流。                |
| 500 / 502 / 503 / 504 | 服務或上游異常，保留請求 ID；建立任務逾時時先檢查是否已受理，避免重複生成。 |

火山錯誤物件使用 `error.code`、`error.message`，並保留請求 ID。任務執行失敗還需讀取查詢結果，不能由建立 HTTP 狀態推斷最終成功。

火山錯誤使用 `error.code`、`error.message` 和請求 ID，任務的生成失敗還需在查詢結果 error 欄位讀取。

## 官方參考

[火山方舟建立任務](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)、[官方呼叫教學](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh)。