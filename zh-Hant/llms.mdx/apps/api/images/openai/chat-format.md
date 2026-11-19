# 對話式圖片生成

## 介面說明

`POST /v1/responses` 在 tools 中聲明 image\_generation，讓支援工具呼叫的主模型結合輸入生成圖片。主 model 是對話模型；實際影像工具模型的選用設定須按官方目前支援範圍選擇。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $API_KEY`。OpenAI 官方直連為 `https://api.openai.com`，同樣使用 Bearer 身分驗證，但必須換成 OpenAI 的 Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

OpenAI 原生對話式生圖使用 Responses 的 image\_generation 工具，不是普通 Chat Completions 回傳 Markdown 圖片連結的約定。相容廠商若透過 Chat 回傳圖片連結，屬於其擴展格式，不能寫成 OpenAI 標準。

## 請求參數

| 欄位                                   | 型別              | 必填 | 說明                                      |
| ------------------------------------ | --------------- | -- | --------------------------------------- |
| model                                | string          | 是  | 支援 image\_generation 工具的 Responses 主模型。 |
| input                                | string / array  | 是  | 文字提示；編輯時可包含 input\_image。               |
| tools\[].type                        | string          | 是  | image\_generation。                      |
| tools\[].output\_format              | string          | 否  | png、jpeg、webp，範例為 png。                  |
| tools\[].size / quality / background | string          | 否  | 工具支援時的尺寸、質量與背景設定。                       |
| tool\_choice                         | string / object | 否  | auto 由模型決定是否生成；強制工具的格式須按該工具支援方式設定。      |
| previous\_response\_id               | string          | 否  | 延續保留的上游回應，需相同可存取的上下文；閘道不提供通用查詢介面。       |
| stream                               | boolean         | 否  | true 使用 Responses 事件流。                  |

### 請求範例

```json
{
  "model": "gpt-5.5",
  "input": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。",
  "tools": [
    {
      "type": "image_generation",
      "model": "gpt-image-2",
      "output_format": "png"
    }
  ],
  "stream": false
}
```

## 回傳值

| 欄位                          | 型別            | 說明                                              |
| --------------------------- | ------------- | ----------------------------------------------- |
| id / status                 | string        | 回應 ID 和終態，completed 才表示完整回應完成。                  |
| output\[].type              | string        | 影像工具結果為 image\_generation\_call；也可能同時有 message。 |
| output\[].id / status       | string        | 影像呼叫 ID 與工具執行狀態。                                |
| output\[].result            | string        | 影像呼叫最終結果的 Base64；不是 data\[].b64\_json。          |
| output\[].revised\_prompt   | string        | 支援時回傳影像工具所用的改寫提示。                               |
| output\[].content\[].text   | string        | message 項中可能附帶的說明。                              |
| usage                       | object        | 主模型用量；影像工具費用不應被視為只含文字 Token。                    |
| error / incomplete\_details | object / null | 失敗與不完整原因。                                       |

```json
{
  "id": "resp_image_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ig_example",
      "type": "image_generation_call",
      "status": "completed",
      "result": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "error": null,
  "incomplete_details": null
}
```

此處 Base64 僅為最小 PNG 的結構範例。後續編輯可把圖片作為 input\_image 與新指令一同傳送，或在支援且保留上下文的服務中使用 previous\_response\_id。不要把任意回應 ID 當成跨管道通用檔案資源。

## 程式碼範例

在程式碼頂端填入 `API_URL`、`API_KEY`，範例主模型使用 `gpt-5.5`，圖像工具模型使用 `gpt-image-2`。`API_URL` 是完整請求位址，預設使用閘道 `https://api.dwchainless.com`。範例只用標準函式庫，送出一次請求並把回傳 JSON 印到標準輸出，不會自動儲存圖片。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/responses"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
      "tools": [
        {
          "type": "image_generation",
          "model": "gpt-image-2"
        }
      ]
    }
    request = urllib.request.Request(
        API_URL,
        data=json.dumps(body).encode(),
        method="POST",
        headers={
            "Authorization": "Bearer " + API_KEY,
            "Content-Type": "application/json",
        },
    )
    print(urllib.request.urlopen(request).read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const API_URL = 'https://api.dwchainless.com/v1/responses';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        input: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。',
        tools: [
          {
            type: 'image_generation',
            model: 'gpt-image-2'
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/responses"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
        "tools": [
          {
            "type": "image_generation",
            "model": "gpt-image-2"
          }
        ]
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/responses"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
            "tools": [
                {
                    "type": "image_generation",
                    "model": "gpt-image-2"
                }
            ]
        }`)
        request, _ := http.NewRequest("POST", apiURL, bytes.NewReader(body))
        request.Header.Set("Authorization", "Bearer "+apiKey)
        request.Header.Set("Content-Type", "application/json")
        response, _ := http.DefaultClient.Do(request)
        defer response.Body.Close()
        result, _ := io.ReadAll(response.Body)
        fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## 錯誤碼

| HTTP 狀態   | 含義或廠商錯誤型別    | 處理方式                       |
| --------- | ------------ | -------------------------- |
| 400       | 請求無效         | 檢查必填欄位、JSON、模型參數和上下文長度。    |
| 401       | 驗證失敗         | 檢查 Key 是否存在、有效及歸屬正確。       |
| 403 / 404 | 無權存取 / 資源不存在 | 檢查模型權限、資源 ID 和 URL。        |
| 429       | 速率或配額限制      | 結合回應主體區分限流與額度不足，後者不能靠重試解決。 |
| 500 / 503 | 服務錯誤 / 暫時不可用 | 保留請求識別碼，對暫時故障做有限次數退避。      |

OpenAI 原生錯誤通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可為 `null`，不能假定其始終存在或等於 HTTP 狀態碼。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 主回應 completed 但沒有 image\_generation\_call.result 時，可能只生成了文字；應檢查工具選擇與回傳項，不得偽造圖片結果。

## 官方參考

* [OpenAI 對話式影像生成](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI 錯誤處理](https\://developers.openai.com/api/docs/guides/error-codes)