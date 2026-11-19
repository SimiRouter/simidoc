# Gemini 圖片生成

## 介面說明

`POST /v1beta/models/{model}:generateContent` 使用支援影像輸出的 Gemini 模型生成圖片，輸出可以包含交錯的文字和圖片。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $API_KEY`。Google 官方直連為 `https://generativelanguage.googleapis.com`，通常使用 `x-goog-api-key: $GEMINI_API_KEY`，不是閘道的 Bearer Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

本頁使用 GenerateContent REST 通訊協定。Google 也提供 Interactions API 的影像工作流程，但其 input、steps、response\_format 與這裡的 contents、candidates、generationConfig 不是相同結構，不能混寫。

## 請求參數

| 欄位                                       | 型別     | 必填 | 說明                                                 |
| ---------------------------------------- | ------ | -- | -------------------------------------------------- |
| model（路徑）                                | string | 是  | 同時支援 generateContent 和影像輸出的 Gemini 影像模型；不要使用純文字模型。 |
| contents                                 | array  | 是  | 訊息清單；文生圖通常只需一條 user 訊息。                            |
| contents\[].role                         | string | 否  | user；多輪歷史中的模型回覆使用 model。                           |
| contents\[].parts\[].text                | string | 是  | 圖片描述或編輯指令。                                         |
| generationConfig.responseModalities      | array  | 否  | 如 \["TEXT","IMAGE"]，請求文字與圖片輸出；可用組合隨模型變化。           |
| generationConfig.imageConfig.aspectRatio | string | 否  | 支援時可用 1\:1、16\:9、9\:16 等比例。                        |
| generationConfig.imageConfig.imageSize   | string | 否  | 支援時設定 1K、2K、4K 等，必須匹配選定模型；不是所有影像模型都支援。             |

省略不需要的選用設定；不要給純文字模型新增 imageConfig 後期待自動獲得影像能力。Google 原生 generateContent 的新輸出格式設定與舊影像模型支援範圍可能不同，本頁保留 responseModalities 的清晰通訊協定範例。

### 圖片規格：1K、2K、4K

K 是解析度的常用簡稱，不是檔案大小，也不表示品質參數。實際寬高隨模型與比例變化；相同比例下邊長加倍，總像素為四倍。以下僅作科普，不能直接當作所有模型的可用尺寸。

Gemini 在模型支援時，用 `generationConfig.imageConfig.imageSize` 選擇 `1K`、`2K`、`4K`，並以 `generationConfig.imageConfig.aspectRatio` 選擇比例；實際輸出寬高須查所選模型。

| 解析度稱呼 | 常見像素示意（不是模型支援承諾）                 |
| ----- | -------------------------------- |
| 1K    | 1024×1024 · 約 1 千像素級             |
| 2K    | 2048×2048 · 約 2 千像素級             |
| 4K    | 4096×4096 / 3840×2160 · 約 4 千像素級 |

本站按張計費級距是另一套規則，不能將上述科普示意直接套為收費標準。 [圖片規格與計費規則](/simidoc/zh-Hant/apps/api/images)。

### 請求範例

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。"
        }
      ]
    }
  ],
  "generationConfig": {
    "responseModalities": [
      "TEXT",
      "IMAGE"
    ]
  }
}
```

## 回傳值

| 欄位                             | 型別      | 說明                                    |
| ------------------------------ | ------- | ------------------------------------- |
| candidates\[]                  | array   | 候選清單，安全過濾時可能為空。                       |
| candidates\[].content.parts\[] | array   | 有序的文字、影像或思考片段，不應只讀第一項。                |
| parts\[].text                  | string  | 說明文字，出現與否由模型決定。                       |
| parts\[].inlineData.mimeType   | string  | 影像實際 MIME，如 image/png 或 image/jpeg。   |
| parts\[].inlineData.data       | string  | 純 Base64 影像資料，不帶 data\: 前綴。           |
| parts\[].thought               | boolean | 選用思考片段標誌；不應將 thought=true 的中間圖當作最終圖片。 |
| parts\[].thoughtSignature      | string  | 選用不透明簽名；多輪編輯時原樣保留，不應自行建立或修改。          |
| candidates\[].finishReason     | string  | STOP 正常完成，MAX\_TOKENS、SAFETY 等需區分處理。  |
| promptFeedback                 | object  | 選用輸入攔截資訊。                             |
| usageMetadata                  | object  | 輸入、候選、思考及總 Token 用量，欄位隨模型出現。          |

以下 Base64 為最小 PNG，只展示回傳結構，不是上述提示的真實生成結果。

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "已根据描述生成图片。"
          },
          {
            "inlineData": {
              "mimeType": "image/png",
              "data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
            }
          }
        ]
      },
      "finishReason": "STOP"
    }
  ]
}
```

按 parts 順序遍歷，讀取非 thought 的 inlineData 圖片並按 mimeType 選擇檔案副檔名；不能固定假設 parts\[0] 是圖片。回應可能只有文字或被過濾而沒有影像，此時應報告未生成圖片。

### 串流與批量

支援串流輸出的模型可使用 streamGenerateContent?alt=sse，但影像片段不一定是可獨立解碼的最終檔案，應遵循所選模型的事件格式。generateContent 本身是同步生成，不回傳可輪詢任務。Google 官方 Batch API 是獨立非同步服務，不能把閘道生成端點當成批任務端點。

## 程式碼範例

在程式碼頂端填入 `API_URL`、`API_KEY`，範例使用 `gemini-3-pro-image`。`API_URL` 是完整請求位址，預設使用閘道 `https://api.dwchainless.com`。範例只用標準函式庫，送出一次請求並把回傳 JSON 印到標準輸出，不會自動儲存圖片。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
            }
          ]
        }
      ],
      "generationConfig": {
        "responseModalities": [
          "TEXT",
          "IMAGE"
        ]
      }
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
    const API_URL = 'https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。'
              }
            ]
          }
        ],
        generationConfig: {
          responseModalities: [
            'TEXT',
            'IMAGE'
          ]
        }
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
              }
            ]
          }
        ],
        "generationConfig": {
          "responseModalities": [
            "TEXT",
            "IMAGE"
          ]
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "contents": [
                {
                    "role": "user",
                    "parts": [
                        {
                            "text": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。"
                        }
                    ]
                }
            ],
            "generationConfig": {
                "responseModalities": [
                    "TEXT",
                    "IMAGE"
                ]
            }
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

## 智慧代理呼叫 Demo

將以下任務複製給具備本機執行與回傳結果檢查能力的智慧代理；先按[本協定設定](/simidoc/zh-Hant/apps/api/images/gemini)直接在範例中填寫 API\_URL、API\_KEY 和 MODEL。不要將金鑰寫入提示詞。

```text
Read this Gemini protocol page and the GenerateContent image generation reference first.
Use the configured SimiRouter request URL in API_URL (default gateway
https://api.dwchainless.com) and MODEL. Set API_KEY directly in the example; never
print, paste, commit, or store it in source files. For this one approved task, call POST
/v1beta/models/{model}:generateContent once, non-streaming, Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. with a text Part describing a calm blue library with a small robot reading,
watercolor, no lettering. Request one image; use imageConfig aspectRatio=1:1 and
imageSize=1K only if the model supports them. Do not invent an n parameter or mix
Interactions fields into GenerateContent. After the response, read only completed,
non-thought inlineData from parts; decode the Base64 in memory and report any unmet
requirement; do not write an image file. Do not switch providers/models/billing groups,
increase size/count, write files, install remote skills, or retry an ambiguous failure
without approval. Report a redacted error instead of false success.
```

## 錯誤碼

| HTTP 狀態   | 含義或廠商錯誤型別                  | 處理方式                        |
| --------- | -------------------------- | --------------------------- |
| 400       | `INVALID_ARGUMENT` 等       | 檢查 JSON、模型參數、媒體 MIME 和輸入長度。 |
| 403       | `PERMISSION_DENIED`        | 檢查 Key、項目權限、區域或帳單限制。        |
| 404       | `NOT_FOUND`                | 檢查模型名稱和 API 版本。             |
| 429       | `RESOURCE_EXHAUSTED`       | 檢查限流與配額；可重試情況採用有限次數退避。      |
| 500 / 503 | `INTERNAL` / `UNAVAILABLE` | 記錄請求識別碼，有限重試或稍後再試。          |

Google 原生錯誤物件包含 `error.code`（HTTP 數字）、`error.status`（枚舉名稱）、`error.message`，可能帶 `details`。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 HTTP 200 但沒有非 thought 影像時，不能把僅文字回答標記為圖片生成成功。

## 官方參考

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 圖片生成與編輯](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Google 模型目錄](https\://ai.google.dev/gemini-api/docs/models)
* [Google 故障排查](https\://ai.google.dev/gemini-api/docs/troubleshooting)