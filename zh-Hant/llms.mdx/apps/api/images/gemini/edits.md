# Gemini 圖片編輯與以圖生圖

## 介面說明

`POST /v1beta/models/{model}:generateContent` 在 parts 中同時提交編輯指令和參考圖片，即可進行圖片編輯、以圖生圖、風格轉換、背景替換或多圖融合。沒有單獨的原生 `/images/edits` Gemini 路徑。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $API_KEY`。Google 官方直連為 `https://generativelanguage.googleapis.com`，通常使用 `x-goog-api-key: $GEMINI_API_KEY`，不是閘道的 Bearer Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

只上傳自己有權處理的圖片。編輯效果不保證像素級保留身分、文字、商標或商品細節，重要內容應在使用前人工檢查。

## 請求參數

| 欄位                                       | 型別     | 必填       | 說明                                                 |
| ---------------------------------------- | ------ | -------- | -------------------------------------------------- |
| model（路徑）                                | string | 是        | 同時支援 generateContent 和影像輸出的 Gemini 影像模型；不要使用純文字模型。 |
| contents                                 | array  | 是        | 訊息清單；文生圖通常只需一條 user 訊息。                            |
| contents\[].role                         | string | 否        | user；多輪歷史中的模型回覆使用 model。                           |
| contents\[].parts\[].text                | string | 是        | 圖片描述或編輯指令。                                         |
| generationConfig.responseModalities      | array  | 否        | 如 \["TEXT","IMAGE"]，請求文字與圖片輸出；可用組合隨模型變化。           |
| generationConfig.imageConfig.aspectRatio | string | 否        | 支援時可用 1\:1、16\:9、9\:16 等比例。                        |
| generationConfig.imageConfig.imageSize   | string | 否        | 支援時設定 1K、2K、4K 等，必須匹配選定模型；不是所有影像模型都支援。             |
| contents\[].parts\[].inlineData          | object | 是（行內參考圖） | 與 text 分開的 Part；包含 mimeType 與 data。                |
| inlineData.mimeType                      | string | 是        | 參考圖片的真實 MIME，如 image/png、image/jpeg 或 image/webp。  |
| inlineData.data                          | string | 是        | 參考檔案的純 Base64，不包含 data\: 前綴。                       |
| contents\[].parts\[].fileData            | object | 條件       | 可替代行內內容，需提供廠商可讀取且已授權的 fileUri/mimeType。            |

一張圖片對應一個 Part，多張參考圖繼續新增圖片 Part，並在文字裡說明每張圖的用途。圖片張數、解析度和多輪一致性限制隨模型變化，不應用單一數字覆蓋所有 Gemini 影像模型。

### 圖片規格：1K、2K、4K

K 是解析度的常用簡稱，不是檔案大小，也不表示品質參數。實際寬高隨模型與比例變化；相同比例下邊長加倍，總像素為四倍。以下僅作科普，不能直接當作所有模型的可用尺寸。

Gemini 在模型支援時，用 `generationConfig.imageConfig.imageSize` 選擇 `1K`、`2K`、`4K`，並以 `generationConfig.imageConfig.aspectRatio` 選擇比例；實際輸出寬高須查所選模型。

| 解析度稱呼 | 常見像素示意（不是模型支援承諾）                 |
| ----- | -------------------------------- |
| 1K    | 1024×1024 · 約 1 千像素級             |
| 2K    | 2048×2048 · 約 2 千像素級             |
| 4K    | 4096×4096 / 3840×2160 · 約 4 千像素級 |

本站按張計費級距是另一套規則，不能將上述科普示意直接套為收費標準。 [圖片規格與計費規則](/simidoc/zh-Hant/apps/api/images)。

### 請求結構

將 `BASE64_IMAGE_BYTES` 替換為授權圖片的純 Base64。

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。"
        },
        {
          "inlineData": {
            "mimeType": "image/png",
            "data": "BASE64_IMAGE_BYTES"
          }
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

上述 Base64 僅表示結構。儲存結果時讀取實際 MIME。多輪編輯應把上一輪完整的 model content 加入歷史，保留 thoughtSignature 等不透明欄位，再追加新的 user 編輯要求。不要只複製圖片位元組而丟棄必須的簽名，也不要改動這些欄位。

Gemini 原生編輯使用自然語言描述區域；OpenAI mask 參數不是此介面的通用參數。需要精確區域約束時應核對選定模型支援的輸入方式，不要憑欄位名類推。

## 程式碼範例

在程式碼頂端填入 `API_URL`、`API_KEY`，範例使用 `gemini-3-pro-image`，並把 `BASE64_IMAGE_BYTES` 換成授權圖片的純 Base64（不含 data\: 前綴）。`API_URL` 是完整請求位址，預設使用閘道 `https://api.dwchainless.com`。範例只用標準函式庫，送出一次請求並把回傳 JSON 印到標準輸出，不會自動儲存圖片。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY = "PASTE_API_KEY_HERE"
    IMAGE_BASE64 = "BASE64_IMAGE_BYTES"
    body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "保留主体和构图，将背景改为浅蓝色。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": IMAGE_BASE64
              }
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
    const IMAGE_BASE64 = 'BASE64_IMAGE_BYTES';
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
                text: '保留主体和构图，将背景改为浅蓝色。'
              },
              {
                inlineData: {
                  mimeType: 'image/png',
                  data: IMAGE_BASE64
                }
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
    IMAGE_BASE64="BASE64_IMAGE_BYTES"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary @- <<JSON
      {
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              },
              {
                "inlineData": {
                  "mimeType": "image/png",
                  "data": "$IMAGE_BASE64"
                }
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
    JSON
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
                            "text": "保留主体和构图，将背景改为浅蓝色。"
                        },
                        {
                            "inlineData": {
                                "mimeType": "image/png",
                                "data": "BASE64_IMAGE_BYTES"
                            }
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
Read this Gemini protocol page and its image editing reference first. Use the existing
API_KEY, MODEL and configured SimiRouter request URL; never reveal credentials or change
the existing connection. Read only the authorized local image, encode it as pure Base64,
and put it in IMAGE_BASE64. Submit its inlineData Part alongside the text instruction
through POST /v1beta/models/{model}:generateContent. Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. Keep the subject and layout; change only the background to pale blue. Request one
image, non-streaming; use aspectRatio=1:1 and imageSize=1K only if supported. Do not use
OpenAI multipart or mask fields. After the response, read only completed, non-thought
inlineData from parts; decode the Base64 in memory and report any unmet requirement; do
not write an image file. Preserve opaque signatures for later turns. Do not upload
unrelated files, overwrite results, change model/size/count/provider, install remote
skills, or retry automatically. Ask before any additional paid request.
```

## 錯誤碼

| HTTP 狀態   | 含義或廠商錯誤型別                  | 處理方式                        |
| --------- | -------------------------- | --------------------------- |
| 400       | `INVALID_ARGUMENT` 等       | 檢查 JSON、模型參數、媒體 MIME 和輸入長度。 |
| 403       | `PERMISSION_DENIED`        | 檢查 Key、項目權限、區域或帳單限制。        |
| 404       | `NOT_FOUND`                | 檢查模型名稱和 API 版本。             |
| 429       | `RESOURCE_EXHAUSTED`       | 檢查限流與配額；可重試情況採用有限次數退避。      |
| 500 / 503 | `INTERNAL` / `UNAVAILABLE` | 記錄請求識別碼，有限重試或稍後再試。          |

Google 原生錯誤物件包含 `error.code`（HTTP 數字）、`error.status`（枚舉名稱）、`error.message`，可能帶 `details`。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 模型拒絕、缺少圖片輸出、非 STOP 終止與 HTTP 錯誤須分別處理；不能用輸入圖片冒充編輯後的結果。

## 官方參考

* [Google 圖片生成與編輯](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 圖片理解與媒體輸入](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Google 故障排查](https\://ai.google.dev/gemini-api/docs/troubleshooting)