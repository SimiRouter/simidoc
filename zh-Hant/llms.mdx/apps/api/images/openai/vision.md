# 圖片理解

## 介面說明

`POST /v1/chat/completions` 在一條 user 訊息中組合文字問題與圖片，回傳文字分析。圖片理解不是圖片生成或編輯。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $API_KEY`。OpenAI 官方直連為 `https://api.openai.com`，同樣使用 Bearer 身分驗證，但必須換成 OpenAI 的 Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

圖片可用可存取的 HTTPS URL 或包含真實媒體位元組的 data URL；本頁使用可存取的 HTTPS 圖片 URL。

## 請求參數

| 欄位                          | 型別      | 必填 | 說明                                                      |
| --------------------------- | ------- | -- | ------------------------------------------------------- |
| model                       | string  | 是  | 支援視覺輸入的聊天模型。                                            |
| messages\[].role            | string  | 是  | 圖片訊息使用 user。                                            |
| messages\[].content         | array   | 是  | 至少包含問題與圖片內容項。                                           |
| content\[].type=text / text | string  | 條件 | 文字問題內容項。                                                |
| content\[].type=image\_url  | string  | 條件 | 聲明圖片內容項。                                                |
| image\_url.url              | string  | 是  | HTTPS URL 或 data\:image/\{format};base64,...；不能填本機檔案路徑。 |
| image\_url.detail           | string  | 否  | auto、low、high 等受模型支援的細節設定。                              |
| max\_completion\_tokens     | integer | 否  | 輸出 Token 上限。                                            |
| stream                      | boolean | 否  | true 回傳 Chat SSE。                                       |

PNG、JPEG、WebP 等格式應使用對應 MIME，圖片數量、像素與請求主體限制均需滿足所選模型要求。不要將 GIF 動畫、影片或任意二進位簡單改成 image/png。

### 請求結構

```json
{
  "model": "gpt-5.5",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "描述图片中的主要物体，并指出无法确定的细节。"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/png;base64,BASE64_IMAGE_BYTES",
            "detail": "auto"
          }
        }
      ]
    }
  ],
  "max_completion_tokens": 512,
  "stream": false
}
```

## 回傳值

| 欄位                             | 型別               | 說明                                                             |
| ------------------------------ | ---------------- | -------------------------------------------------------------- |
| id / object                    | string           | 回應 ID；object=chat.completion。                                  |
| created / model                | integer / string | 建立時間（Unix 秒）與回應模型。                                             |
| choices\[]                     | array            | 候選回覆清單，每項的 index 表示位置。                                         |
| choices\[].message.role        | string           | assistant。                                                     |
| choices\[].message.content     | string / null    | 文字回覆；工具呼叫或拒絕時可為空，不等同於請求失敗。                                     |
| choices\[].message.tool\_calls | array            | 待應用執行的函式呼叫。arguments 是 JSON 字串，須解析並驗證。                         |
| choices\[].message.refusal     | string / null    | 拒絕資訊，若有。                                                       |
| choices\[].finish\_reason      | string           | stop 正常結束；length 達到上限；tool\_calls 進入工具呼叫；content\_filter 內容過濾。 |
| usage.prompt\_tokens           | integer          | 輸入 Token。                                                      |
| usage.completion\_tokens       | integer          | 生成 Token，可能包含推理 Token。                                         |
| usage.total\_tokens            | integer          | 輸入與生成 Token 總計。                                                |
| usage.\*\_tokens\_details      | object           | 選用用量明細，如 cached\_tokens、reasoning\_tokens。                     |

```json
{
  "id": "chatcmpl_vision_example",
  "object": "chat.completion",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "图中可见一张桌子和一个杯子，杯内物品无法确认。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 280,
    "completion_tokens": 30,
    "total_tokens": 310
  }
}
```

多圖可繼續新增 image\_url 內容項；需比較圖片時在文字中明確次序和目標。串流回傳按 Chat delta.content 串接。對細小文字、精確計數、身分或高風險判斷，不應只依賴模型視覺結果。

## 程式碼範例

在程式碼頂端填入 `API_URL`、`API_KEY`，範例使用 `gpt-5.5`。`API_URL` 是完整請求位址，預設使用閘道 `https://api.dwchainless.com`。`IMAGE_URL` 指向伺服器可存取的 HTTPS 圖片位址。範例只用標準函式庫，送出一次請求並把回傳 JSON 印到標準輸出，不會自動儲存圖片。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/chat/completions"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "描述图片中的主要物体。"
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "https://example.com/reference.png"
              }
            }
          ]
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
    const API_URL = 'https://api.dwchainless.com/v1/chat/completions';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: '描述图片中的主要物体。'
              },
              {
                type: 'image_url',
                image_url: {
                  url: 'https://example.com/reference.png'
                }
              }
            ]
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/chat/completions"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "描述图片中的主要物体。"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "https://example.com/reference.png"
                }
              }
            ]
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
        apiURL := "https://api.dwchainless.com/v1/chat/completions"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "描述图片中的主要物体。"
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": "https://example.com/reference.png"
                            }
                        }
                    ]
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

OpenAI 原生錯誤通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可為 `null`，不能假定其始終存在或等於 HTTP 狀態碼。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。

## 官方參考

* [OpenAI 圖片與視覺](https\://developers.openai.com/api/docs/guides/images-vision)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI 錯誤處理](https\://developers.openai.com/api/docs/guides/error-codes)