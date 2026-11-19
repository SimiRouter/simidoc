# Qwen 圖像編輯

## 介面說明

`POST /v1/images/edits`，本文為 JSON。範例使用本站閘道 `https://api.dwchainless.com`，`API_KEY` 使用本站金鑰；請求體沿用 Qwen 原生的 `model`、`input.messages`、`parameters` 結構，回傳統一為 `data[]`。

圖像編輯在 content 中放 image 項和一條文字修改指令，不使用 multipart 的 file 欄位。

## 請求參數

| 欄位                                 | 型別        | 必填 | 說明                                                     |
| ---------------------------------- | --------- | -- | ------------------------------------------------------ |
| model                              | string    | 是  | qwen-image-2.0-pro 或本站渠道支援的具體版本。                       |
| input.messages                     | object\[] | 是  | 單輪 user 訊息，恰好一項。                                       |
| input.messages\[].role             | string    | 是  | 固定 user。                                               |
| input.messages\[].content\[].text  | string    | 是  | 中文或英文指令，每輪只放一個 text 項。                                 |
| input.messages\[].content\[].image | string    | 是  | 一張或多張參考圖的可存取 URL / data URL。輸入數量和像素限制按模型版本。            |
| parameters.size                    | string    | 否  | 寬 × 高，如 2048 × 2048；2.0 系列總像素為 512×512 至 2048×2048 範圍。 |
| parameters.n                       | integer   | 否  | 預設 1；2.0 系列支援 1–6。                                     |
| parameters.negative\_prompt        | string    | 否  | 不希望出現的內容，最多 500 字元。                                    |
| parameters.prompt\_extend          | boolean   | 否  | 預設 true，自動擴展正向提示詞。                                     |
| parameters.watermark               | boolean   | 否  | 是否加顯式水印；應遵循適用的合成內容標示要求。                                |

### 圖片規格：1K、2K、4K

K 是解析度的常用簡稱，不是檔案大小，也不表示品質參數。實際寬高隨模型與比例變化；相同比例下邊長加倍，總像素為四倍。以下僅作科普，不能直接當作所有模型的可用尺寸。

Qwen 使用 `parameters.size` 填寫模型允許的寬高，格式如 `2048*2048`，不是直接填寫 `2K`。2.0 系列還有總像素限制，下面的 4K 方圖示意不代表可提交該尺寸。

| 解析度稱呼 | 常見像素示意（不是模型支援承諾）                   |
| ----- | ---------------------------------- |
| 1K    | 兩邊均 ≤ 1024 像素；如 1024×1024。         |
| 2K    | 最長邊 > 1024 且 ≤ 2048 像素；如 1280×720。 |
| 4K    | 任一邊 > 2048 像素；如 2560×1440。         |

本站按張計費檔位是另一套規則，不能把上面的科普示意直接套為收費標準。 [圖片規格與計費規則](/simidoc/zh-Hant/apps/api/images)。

## 回傳值

| 欄位                      | 說明                         |
| ----------------------- | -------------------------- |
| `created`               | 回應生成時間戳。                   |
| `data[].url`            | 生成圖片 URL；有效期由渠道決定，及時下載或轉存。 |
| `data[].b64_json`       | 部分渠道回傳純 Base64；存在時可直接解碼儲存。 |
| `data[].revised_prompt` | 渠道改寫後的提示詞；可能不存在。           |
| `error` / `message`     | 失敗時的錯誤碼與說明。                |

```json
{"created":1760000000,"data":[{"url":"https://example.com/edited.png","b64_json":null,"revised_prompt":"..."}]}
```

## 程式碼範例

在程式碼頂端填入 `API_URL`、`API_KEY`。`API_URL` 使用本站閘道位址 `https://api.dwchainless.com/v1/images/edits`，`API_KEY` 使用本站金鑰。範例只用標準函式庫，送出一次請求並印出回傳 JSON，不會自動下載或儲存圖片。

設定 `IMAGE_URL` 為已授權、雲端可存取的真實 HTTP(S) 圖片位址。程式碼只檢查 URL 形式，不證明圖片可下載或已滿足渠道的格式限制；不要使用本機路徑、localhost、需要登入的網頁或假連結。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "qwen-image-2.0-pro",
      "input": {
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "image": "https://example.com/reference.png"
              },
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              }
            ]
          }
        ]
      },
      "parameters": {
        "size": "1024*1024",
        "n": 1
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'qwen-image-2.0-pro',
        input: {
          messages: [
            {
              role: 'user',
              content: [
                {
                  image: 'https://example.com/reference.png'
                },
                {
                  text: '保留主体和构图，将背景改为浅蓝色。'
                }
              ]
            }
          ]
        },
        parameters: {
          size: '1024*1024',
          n: 1
        }
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/edits"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "qwen-image-2.0-pro",
        "input": {
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "image": "https://example.com/reference.png"
                },
                {
                  "text": "保留主体和构图，将背景改为浅蓝色。"
                }
              ]
            }
          ]
        },
        "parameters": {
          "size": "1024*1024",
          "n": 1
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/images/edits"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "qwen-image-2.0-pro",
            "input": {
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "image": "https://example.com/reference.png"
                            },
                            {
                                "text": "保留主体和构图，将背景改为浅蓝色。"
                            }
                        ]
                    }
                ]
            },
            "parameters": {
                "size": "1024*1024",
                "n": 1
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

將以下任務複製給具備本機執行與回傳結果檢查能力的智慧代理；先按[本協定設定](/simidoc/zh-Hant/apps/api/images/qwen)直接在範例程式碼中填入 API\_URL、API\_KEY，並確認 model 名稱。不要將金鑰寫入提示詞。

```text
Read this Qwen image protocol page and its editing reference first. Use the existing
API_KEY and API_URL from this site's gateway; never reveal the key or switch the
existing connection. Verify qwen-image-2.0-pro supports the edit. Use only the
authorized cloud-readable image in IMAGE_URL; do not upload unrelated local files or
publish a file. POST once to /v1/images/edits with the native Qwen body: one user
message containing that image item and one text instruction: keep the subject and
layout; change only the background to pale blue. Set parameters.n=1 and size=1024*1024
only if supported. Do not use OpenAI multipart or mask fields. Check the completed
business result, inspect data[].url or data[].b64_json without forwarding the API key,
and report it. Do not write files, change model/size/count/provider, install remote
skills, or retry automatically. If any step fails or the requested edit is not met,
report a redacted error instead of claiming success.
```

## 錯誤碼

| 錯誤                     | 處理                                  |
| ---------------------- | ----------------------------------- |
| 400 / InvalidParameter | 檢查 content 結構、圖片規格、輸出 size 和模型支援參數。 |
| 401                    | 檢查本站 API Key 是否存在、有效及歸屬正確。          |
| 403 / 404              | 檢查模型權限、渠道與資源是否存在。                   |
| 429                    | 限流或額度不足，確認原因後再退避重試。                 |
| 5xx                    | 服務異常，記錄請求標識；避免無上限重複生成。              |

## 官方參考

[Qwen-Image 編輯](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api)、[百煉錯誤碼](https\://www.alibabacloud.com/help/en/model-studio/error-code)。