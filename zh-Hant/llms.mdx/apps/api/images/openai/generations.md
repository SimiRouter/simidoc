# 圖片生成

## 介面說明

`POST /v1/images/generations` 根據 prompt 生成一張或多張圖片。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $API_KEY`。OpenAI 官方直連為 `https://api.openai.com`，同樣使用 Bearer 身分驗證，但必須換成 OpenAI 的 Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

本頁使用 GPT Image 參數。不同廠商的 OpenAI 相容圖片模型可能接受不同尺寸、質量與回傳格式，不能把這些差異當成同一官方標準。

## 快速開始

1. **準備設定**：在 [API 金鑰管理](https://api.dwchainless.com/keys) 建立金鑰，從[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)複製支援 Images API 的模型 ID。
2. **傳送請求**：向 `https://api.dwchainless.com/v1/images/generations` 傳送 JSON，請求標頭使用 `Authorization: Bearer $API_KEY`，請求主體至少包含 `model` 和 `prompt`。
3. **讀取結果**：HTTP 2xx 且 `data[]` 非空才算成功；GPT Image 從 `data[].b64_json` 解碼儲存。
4. **確認完成**：檢查檔案能否開啟、尺寸是否符合要求，再核對使用紀錄。

最小請求如下；確認可用後，再調整數量、尺寸或開啟串流：

```bash
API_URL="https://api.dwchainless.com/v1/images/generations"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
    "n": 1,
    "size": "1024x1024",
    "output_format": "png"
  }'
```

## 請求參數

請求主體為 JSON。

| 欄位                  | 型別      | 必填 | 說明                                                                                                          |
| ------------------- | ------- | -- | ----------------------------------------------------------------------------------------------------------- |
| model               | string  | 是  | 支援 Images API 的影像模型 ID。                                                                                     |
| prompt              | string  | 是  | 具體描述主體、構圖、風格及文字內容。                                                                                          |
| n                   | integer | 否  | 生成數量，OpenAI GPT Image 原生範圍為 1–10，範例為 1。                                                                     |
| size                | string  | 否  | OpenAI 原生寫法為 WIDTHxHEIGHT（寬高均為 16 的倍數，比例需在 1\:3–3\:1 之間）或 auto；SimiRouter 另接受比例與 resolution 組合，可用值和上限隨模型變化。 |
| resolution          | string  | 否  | SimiRouter 擴充欄位：與比例配合的檔位 1k、2k 或 4k，不是像素值；OpenAI 原生介面沒有該欄位。                                                 |
| aspect\_ratio       | string  | 否  | SimiRouter 擴充欄位：單獨的比例，如 3\:4；size 已寫比例時以 size 為準。                                                           |
| quality             | string  | 否  | auto、low、medium、high；部分新模型另支援 xhigh、max。                                                                    |
| output\_format      | string  | 否  | png、jpeg（範例）、webp；官方規範還列出 gif、svg，需模型與專案權限支援。                                                               |
| output\_compression | integer | 否  | JPEG/WebP 壓縮質量 0–100，不用於 PNG。                                                                               |
| background          | string  | 否  | auto、opaque、transparent；透明背景需支援的模型與 PNG/WebP。                                                               |
| moderation          | string  | 否  | auto 或支援的 low；不保證請求一定通過內容策略。                                                                                |
| response\_format    | string  | 否  | 部分相容模型支援 url 或 b64\_json；GPT Image 原生不使用。                                                                   |
| stream              | boolean | 否  | true 使用影像 SSE 事件。                                                                                           |
| partial\_images     | integer | 否  | stream=true 時請求 0–3 個中間影像，仍需等最終完成事件。                                                                        |

GPT Image 的圖片直接以 Base64 回傳，不應依賴舊式 response\_format=url/b64\_json。部分相容模型可用該欄位選擇 URL 或 Base64，是否生效以模型說明和實際回傳為準。舊 style=vivid/natural 也不適用於 GPT Image，風格應寫進 prompt。

### 請求範例

```json
{
  "model": "gpt-image-2",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，柔和蓝金色调，不要文字。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

## 尺寸與格式

K 是解析度的常用簡稱，不是檔案大小，也不表示品質參數。實際寬高隨模型與比例變化；相同比例下邊長加倍，總像素為四倍。以下僅作科普，不能直接當作所有模型的可用尺寸。

OpenAI 使用 `size` 填寫模型允許的寬高，如 `1024x1024`，不是直接填寫 `1K`；`quality`、`output_format` 與尺寸分別控制品質和格式。

| 解析度稱呼 | 常見像素示意（不是模型支援承諾）                 |
| ----- | -------------------------------- |
| 1K    | 1024×1024 · 約 1 千像素級             |
| 2K    | 2048×2048 · 約 2 千像素級             |
| 4K    | 4096×4096 / 3840×2160 · 約 4 千像素級 |

本站按張計費級距是另一套規則，不能將上述科普示意直接套為收費標準。 [圖片規格與計費規則](/simidoc/zh-Hant/apps/api/images)。

### 尺寸的三種寫法

部分 OpenAI 相容閘道除明確像素外，還接受比例加解析度或自動尺寸；欄位是否生效取決於模型與渠道，不被支援時應退回明確像素。

| 寫法       | 請求片段                               | 說明                                     |
| -------- | ---------------------------------- | -------------------------------------- |
| 明確像素（推薦） | `{"size":"1536x2048"}`             | 最直觀，避免預設換算差異。                          |
| 比例 + 解析度 | `{"size":"3:4","resolution":"2k"}` | 使用 2K、3\:4 預設；resolution 只接受 1k、2k、4k。 |
| 自動尺寸     | `{"size":"auto"}`                  | 由模型選擇寬高，不承諾固定像素。                       |

* 比例寫進 size 時優先於單獨的 aspect\_ratio；明確像素或 auto 優先於比例預設。
* 檔位寫在 resolution，不要傳送 size=2k；尺寸分隔符使用小寫英文 x。
* OpenAI 官方對 gpt-image-2 的任意尺寸上限為 3840×2160；4096×4096 等更大組合通常回傳參數錯誤。上表 4K 只是檔位示意，不代表該像素組合一定可用。
* 14 種常用比例的 1K、2K、4K 速查見[圖片規格與計費規則](/simidoc/zh-Hant/apps/api/images)。

## 回傳值

| 欄位                                                   | 型別      | 說明                                       |
| ---------------------------------------------------- | ------- | ---------------------------------------- |
| created                                              | integer | 建立時間，Unix 秒。                             |
| data\[]                                              | array   | 生成結果清單，不可假定一定有第一項。                       |
| data\[].b64\_json                                    | string  | 圖片二進位的 Base64；GPT Image 使用此格式。           |
| data\[].url                                          | string  | 只在支援 URL 輸出的相容模型中出現，不能視為 GPT Image 必有欄位。 |
| data\[].revised\_prompt                              | string  | 部分舊或相容模型回傳的改寫提示，不是 GPT Image 必有欄位。       |
| output\_format / size / quality / background         | string  | 選用有效輸出設定。                                |
| usage                                                | object  | 選用用量資料，出現與計量粒度隨模型和服務變化。                  |
| usage.input\_tokens / output\_tokens / total\_tokens | integer | 如回傳則為輸入、輸出、總 Token。                      |
| usage.input\_tokens\_details                         | object  | 選用 image\_tokens、text\_tokens 等細分。       |
| X-Request-Id                                         | string  | 回應標頭，不是 JSON 欄位；回饋或排查問題時保留。              |

回傳的 data\[].url 可能有有效期，下載圖片時不要附帶 API Key。以下 Base64 僅為最小 PNG 的結構範例，不是上面提示的真實生成結果。

```json
{
  "created": 1760000000,
  "data": [
    {
      "b64_json": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "output_format": "png"
}
```

### 串流生成

支援的模型可設定 stream=true，以 image\_generation.partial\_image 接收中間預覽，以 image\_generation.completed 接收最終圖片和用量。部分影像不是最終結果；斷流且沒有 completed 時不要將預覽標記為已完成。生成介面不回傳可輪詢的通用背景任務 ID。

## 程式碼範例

在程式碼頂端填入 `API_URL`、`API_KEY`，範例使用 `gpt-image-2`。`API_URL` 是完整請求位址，預設使用閘道 `https://api.dwchainless.com`。範例只用標準函式庫，送出一次請求並把回傳 JSON 印到標準輸出，不會自動儲存圖片。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/generations"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1,
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
    const API_URL = 'https://api.dwchainless.com/v1/images/generations';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        prompt: '一只小机器人在图书馆阅读，水彩插画，不要文字。',
        size: '1024x1024',
        n: 1,
      }),
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/generations"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/images/generations"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
            "size": "1024x1024",
            "n": 1
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

將以下任務複製給具備本機執行與回傳結果檢查能力的智慧代理；先按[本協定設定](/simidoc/zh-Hant/apps/api/images/openai)直接在範例中填寫 API\_URL、API\_KEY 和 MODEL。不要將金鑰寫入提示詞。

```text
Read this OpenAI image protocol page and its generation reference first. Use the
SimiRouter request URL in API_URL (default gateway https://api.dwchainless.com) and the
image model in MODEL. Set API_KEY directly in the example; never print, paste, commit,
or store it in source files. For this one approved request, use POST
/v1/images/generations with n=1, size=1024x1024, stream=false and output_format=png only
after verifying the model supports these parameters. Image brief: a calm blue library
with a small robot reading, watercolor illustration, no lettering. Print the returned
JSON and inspect data[].b64_json; do not write an image file. Confirm that
data[].b64_json contains non-empty Base64 data before reporting completion. Do not
install remote skills, switch providers/models/billing groups, increase size/count,
write files, or retry after timeout or ambiguous failure without approval. If the
request or validation fails, report a redacted error, not success.
```

## 錯誤碼

| HTTP 狀態         | 含義或廠商錯誤型別           | 處理方式                          |
| --------------- | ------------------- | ----------------------------- |
| 400             | 請求無效                | 檢查必填欄位、JSON、模型參數和上下文長度。       |
| 401             | 驗證失敗                | 檢查 Key 是否存在、有效及歸屬正確。          |
| 403 / 404       | 無權存取 / 資源不存在        | 檢查模型權限、資源 ID 和 URL。           |
| 413             | 請求主體或圖片過大           | 優先使用圖片 URL；減小 Base64 體積或圖片尺寸。 |
| 429             | 速率或配額限制             | 結合回應主體區分限流與額度不足，後者不能靠重試解決。    |
| 500 / 502 / 503 | 服務錯誤 / 上游繁忙 / 暫時不可用 | 保留請求識別碼，對暫時故障做有限次數退避。         |

OpenAI 原生錯誤通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可為 `null`，不能假定其始終存在或等於 HTTP 狀態碼。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 回應 data 為空、缺少圖片資料或只有中間預覽時，不能僅憑 HTTP 200 宣稱生成完成。

生成和編輯可能耗時數十秒到數分鐘，用戶端應設定足夠逾時；請求懸置不等於失敗。逾時、斷流或 5xx 後先確認請求是否已經執行，再決定是否重試，避免重複生成和重複扣費。內容策略拒絕（通常為 400）時修改提示詞或參考圖，不要原樣重試。

## 官方參考

* [OpenAI Create image](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [OpenAI 影像生成指南](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI 錯誤處理](https\://developers.openai.com/api/docs/guides/error-codes)