# 圖片編輯與以圖生圖

## 介面說明

`POST /v1/images/edits` 接收參考圖片及編輯指令，回傳編輯後的圖片。適用於修改背景、風格轉換、加入或刪除元素，也可組合多張參考圖。

串接位址為 `https://api.dwchainless.com`，請求標頭使用 `Authorization: Bearer $API_KEY`。OpenAI 官方直連為 `https://api.openai.com`，同樣使用 Bearer 身分驗證，但必須換成 OpenAI 的 Key。 模型名稱應選用帳戶可存取且支援目標能力的模型。

支援 JSON 的 images\[] 引用方式以及 multipart 檔案上傳。下面的範例用 JSON `images[].image_url` 傳入伺服器可存取的 HTTPS 圖片位址，不依賴 multipart 上傳。

## 快速開始

1. **準備設定**：在 [API 金鑰管理](https://api.dwchainless.com/keys) 建立金鑰，從[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)複製支援編輯的影像模型 ID。
2. **準備參考圖**：使用伺服器可存取的 HTTPS 圖片位址，或透過 multipart 上傳本機檔案；不要同時混用兩種方式。
3. **傳送請求**：向 `https://api.dwchainless.com/v1/images/edits` 傳送包含 `model`、`prompt` 和圖片引用的 JSON；請求標頭使用 `Authorization: Bearer $API_KEY`。
4. **讀取並驗收**：HTTP 2xx 且 `data[]` 非空才算成功；從 `data[].b64_json` 解碼或下載 `data[].url`，再檢查檔案、尺寸和內容。

第一次呼叫建議只編輯一張圖、不使用串流；確認可用後，再增加參考圖數量或開啟串流。

## 請求參數

| 欄位                   | 型別      | 必填           | 說明                                                                                                          |
| -------------------- | ------- | ------------ | ----------------------------------------------------------------------------------------------------------- |
| model                | string  | 是（閘道）        | 顯式選擇支援編輯的影像模型，避免依賴上游預設值。                                                                                    |
| images               | array   | 是（JSON）      | 圖片引用清單，原生 GPT Image 最多16張，模型還可有更嚴格限制。                                                                       |
| images\[].image\_url | string  | 條件           | HTTPS 圖片 URL 或 data\:image/...;base64,...；本頁範例使用 HTTPS URL。                                                 |
| images\[].file\_id   | string  | 條件           | 官方 Files 上傳資源 ID，與 image\_url 二選一；閘道不可假定可用。                                                                 |
| prompt               | string  | 是            | 明確需要改變和需要保留的內容。                                                                                             |
| mask                 | object  | 否            | JSON 時引用 mask.image\_url 或 mask.file\_id；掩碼規則隨模型變化。                                                         |
| image / image\[]     | file    | 是（multipart） | multipart 的一張或多張圖片欄位，不與 JSON images 混寫。                                                                     |
| mask（multipart）      | file    | 否            | PNG 掩碼，透明區域標記編輯範圍；與源圖尺寸及模型要求匹配。                                                                             |
| input\_fidelity      | string  | 否            | 僅支援該參數的模型可用，不能假定所有 GPT Image 代際接受。                                                                          |
| n                    | integer | 否            | 生成數量，OpenAI GPT Image 原生範圍為 1–10，範例為 1。                                                                     |
| size                 | string  | 否            | OpenAI 原生寫法為 WIDTHxHEIGHT（寬高均為 16 的倍數，比例需在 1\:3–3\:1 之間）或 auto；SimiRouter 另接受比例與 resolution 組合，可用值和上限隨模型變化。 |
| resolution           | string  | 否            | SimiRouter 擴充欄位：與比例配合的檔位 1k、2k 或 4k，不是像素值；OpenAI 原生介面沒有該欄位。                                                 |
| aspect\_ratio        | string  | 否            | SimiRouter 擴充欄位：單獨的比例，如 3\:4；size 已寫比例時以 size 為準。                                                           |
| quality              | string  | 否            | auto、low、medium、high；部分新模型另支援 xhigh、max。                                                                    |
| output\_format       | string  | 否            | png、jpeg（範例）、webp；官方規範還列出 gif、svg，需模型與專案權限支援。                                                               |
| output\_compression  | integer | 否            | JPEG/WebP 壓縮質量 0–100，不用於 PNG。                                                                               |
| background           | string  | 否            | auto、opaque、transparent；透明背景需支援的模型與 PNG/WebP。                                                               |
| moderation           | string  | 否            | auto 或支援的 low；不保證請求一定通過內容策略。                                                                                |
| response\_format     | string  | 否            | 部分相容模型支援 url 或 b64\_json；GPT Image 原生不使用。                                                                   |
| stream               | boolean | 否            | true 使用影像 SSE 事件。                                                                                           |
| partial\_images      | integer | 否            | stream=true 時請求 0–3 個中間影像，仍需等最終完成事件。                                                                        |

JSON 與 multipart 二選一；multipart 的 Content-Type 必須由用戶端自動生成 boundary。蒙版不能保證像素級精確修改，最終圖需人工檢查。

## 選擇傳圖方式

參考圖有四種傳入方式，按執行環境選擇一種，不能在同一次請求裡混寫：

| 方式           | 欄位                              | 適用場景                     |
| ------------ | ------------------------------- | ------------------------ |
| JSON URL     | `images[].image_url`            | 圖片已在公網，伺服器可直接存取          |
| JSON Base64  | `images[].image_url` 的 data URL | 圖片較小，且不想公開位址             |
| multipart 檔案 | `image` 或 `image[]`             | 本機檔案，由用戶端直接上傳            |
| Files 資源 ID  | `images[].file_id`              | 已透過官方 Files 上傳，且閘道支援該 ID |

JSON 請求使用 `Content-Type: application/json`；multipart 的 `Content-Type` 必須由用戶端生成 boundary，不要手寫。

### JSON 請求結構

JSON 範例直接使用伺服器可存取的 HTTPS 圖片 URL。

```json
{
  "model": "gpt-image-2",
  "images": [
    {
      "image_url": "https://example.com/reference.png"
    }
  ],
  "prompt": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

### multipart 請求結構

單一本機參考圖使用 `image` 欄位；多張圖使用 `image[]`，並按順序說明各圖用途：

```bash
API_URL="https://api.dwchainless.com/v1/images/edits"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -F "model=gpt-image-2" \
  -F "prompt=保留主体和构图，将背景改为浅蓝色。" \
  -F "image=@reference.png" \
  -F "size=1024x1024" \
  -F "n=1"
```

## 編輯提示詞寫法

編輯提示詞應同時說明保留項和修改項，只寫「改成水彩」容易讓模型重繪整個畫面。建議按「保留 + 修改 + 約束」組織：

| 場景      | 提示詞要點                 | 例子                         |
| ------- | --------------------- | -------------------------- |
| 保留人物或商品 | 明確主體、姿勢、構圖和文字保持不變     | 保留人物姿勢和服裝，只把背景改為淺藍色。       |
| 風格轉換    | 說明目標風格和需要保留的佈局        | 改為水彩插畫風格，保留原有構圖和主體位置。      |
| 局部修改    | 指出修改區域；模型支援時配合 `mask` | 只修改畫面左下角的杯子，其餘保持不變。        |
| 多圖組合    | 說明每張圖的用途、主體關係和最終佈局    | 第一張圖是人物，第二張圖是場景，將人物置於場景中央。 |

「保留」是目標而不是像素級保證；人物、商品和文字細節都可能變化，涉及身分或品牌的內容必須人工核對。透明背景需要模型支援 `background: transparent`，並使用 PNG 或 WebP 輸出。

## 尺寸與格式

`size` 填寫模型允許的像素寬高，如 `1024x1024`；`quality` 控制品質，`output_format` 控制 PNG/JPEG/WebP 編碼。編輯結果的尺寸由 `size` 決定（省略時預設 `auto`，由模型選擇）；不要求與參考圖完全一致。

本站 1K、2K、4K 按張計費級距與廠商的解析度稱呼是兩套規則；尺寸的三種寫法、14 種比例速查和計費邊界統一見[圖片規格與計費](/simidoc/zh-Hant/apps/api/images)。

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

範例 Base64 為最小 PNG，僅表示欄位結構。回傳的 data\[].url 可能有有效期，下載圖片時不要附帶 API Key。串流編輯使用 image\_edit.partial\_image 和 image\_edit.completed 事件；只有最終事件可標記編輯完成。以圖生圖不能保證人物、商品或文字的細節逐像素保持不變。

## 程式碼範例

在程式碼頂端填入 `API_URL`、`API_KEY`，範例使用 `gpt-image-2`。`API_URL` 是完整請求位址，預設使用閘道 `https://api.dwchainless.com`。`IMAGE_URL` 指向伺服器可存取的 HTTPS 圖片位址。範例只用標準函式庫，送出一次請求並把回傳 JSON 印到標準輸出，不會自動儲存圖片。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "images": [{"image_url": "https://example.com/reference.png"}],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        images: [
          {
            image_url: 'https://example.com/reference.png',
          },
        ],
        prompt: '保留主体和构图，将背景改为浅蓝色。',
        size: '1024x1024',
        n: 1,
      }),
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
        "model": "gpt-image-2",
        "images": [
          {
            "image_url": "https://example.com/reference.png"
          }
        ],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
        apiURL := "https://api.dwchainless.com/v1/images/edits"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "images": [
                {
                    "image_url": "https://example.com/reference.png"
                }
            ],
            "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
Read this OpenAI image protocol page and its editing reference first. Set API_KEY,
MODEL, and API_URL directly in the example; use the configured SimiRouter request URL;
never reveal the key or change the existing connection. Use only the authorized HTTPS
image URL in IMAGE_URL. Use POST /v1/images/edits with JSON images[]; do not set
multipart Content-Type or send local files. Keep the subject and layout; change only the
background to pale blue. Request one PNG at 1024x1024 with stream=false only if the
selected model supports it. Print the returned JSON and inspect data[].b64_json; do not
write an image file. Confirm that data[].b64_json contains non-empty Base64 data and
report any unmet requirement. Do not upload unrelated files, change
size/count/model/provider, install remote skills, or retry automatically after an error
or timeout. Ask before another paid request.
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

OpenAI 原生錯誤通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可為 `null`，不能假定其始終存在或等於 HTTP 狀態碼。 閘道可能在請求到達廠商前回傳驗證、路由或額度錯誤；不得僅憑 HTTP 數字判定錯誤來自上游。 無效圖片、MIME 不匹配、掩碼尺寸不符或模型不接受參數是輸入錯誤，應先修正而不是重複提交。

編輯可能耗時數十秒到數分鐘，用戶端應設定足夠逾時；請求懸置不等於失敗。逾時、斷流或 5xx 後先確認請求是否已經執行，再決定是否重試，避免重複生成和重複扣費。內容策略拒絕（通常為 400）時修改提示詞或參考圖，不要原樣重試。

## 官方參考

* [OpenAI Create image edit](https\://developers.openai.com/api/reference/resources/images/methods/edit)
* [OpenAI 影像生成與編輯](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI 錯誤處理](https\://developers.openai.com/api/docs/guides/error-codes)