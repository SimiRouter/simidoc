# 畫圖

先選 **API 協議**，再確定要做的 **效果**，最後核對 **尺寸、品質、格式和張數**。協議決定請求與回應結構，效果由模型能力和提示詞共同決定，規格決定輸出要求；三者不能混為一談。

生成和編輯回傳圖片；圖片理解以圖片為輸入，回傳文字或結構化結果。普通文字模型不會因為加入圖片參數就獲得生圖能力。呼叫前從[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)確認準確模型 ID、介面支援、計費分組和額度，真實請求可能產生費用。

## 概覽

| 你要做什麼     | 輸入             | 輸出        | 典型端點                          |
| --------- | -------------- | --------- | ----------------------------- |
| 從文字生成圖片   | 提示詞            | 新圖片       | `POST /v1/images/generations` |
| 修改已有圖片    | 提示詞 + 一張或多張參考圖 | 編輯後的圖片    | `POST /v1/images/edits`       |
| 在對話中邊聊邊生圖 | 對話訊息 + 圖像工具    | 圖片與文字混合結果 | `POST /v1/responses`          |
| 讓模型看圖說話   | 圖片 + 問題        | 文字，不是新圖片  | `POST /v1/chat/completions`   |

## 核心概念

先分清三類數字，後面的參數和價格才說得通：

* **像素尺寸**：真實的寬 × 高，例如 `1024x1024`。它決定檔案的實際解析度，不是檔案大小，也不等於品質檔位。
* **寬高比**：`1:1`、`16:9`、`9:16` 這類比例，只決定畫幅形狀。同一比例可以對應多種像素尺寸；只說比例不等於指定了輸出大小。
* **解析度檔位**：`1K`、`2K`、`4K` 這類檔位。廠商的原生檔位按最長邊或產品線定義，本站的按張計費檔位則按最長邊歸檔；兩者名稱相同，邊界不一定相同，不能直接互相推斷。

還有三個常見誤解：`quality` 控制渲染品質，不是壓縮品質；PNG、JPEG、WebP 是檔案格式，改副檔名不會轉換格式；Base64 與 URL 只是交付方式，不是解析度。逐項對照見下文「四、圖片規格與計費」。

## 一、各種 API：按協議選擇

三套協議各有獨立的請求參數、回傳參數和範例。指令碼呼叫、智慧代理使用、結果儲存與失敗處理也在各自協議中說明，不需要先讀一套僅適用於 OpenAI 的通用教學。

| 協議        | API / 能力         | 請求端點                                                  | 主要結果                                      | 文件                                          |
| --------- | ---------------- | ----------------------------------------------------- | ----------------------------------------- | ------------------------------------------- |
| OpenAI    | 文生圖              | `POST /v1/images/generations`                         | `data[].b64_json`；相容模型也可能回傳 URL           | [生成](/simidoc/zh-Hant/apps/api/images/openai/generations)                  |
| OpenAI    | 圖片編輯 / 以圖生圖      | `POST /v1/images/edits`                               | 編輯後的圖片                                    | [編輯](/simidoc/zh-Hant/apps/api/images/openai/edits)                        |
| OpenAI    | 對話式生圖            | `POST /v1/responses`，使用 `image_generation` 工具         | `output[]` 中的圖像工具結果                       | [對話式生圖](/simidoc/zh-Hant/apps/api/images/openai/chat-format)               |
| OpenAI    | 圖片理解             | `POST /v1/chat/completions`，輸入 `image_url`            | 文字分析，不是生成圖片                               | [圖片理解](/simidoc/zh-Hant/apps/api/images/openai/vision)                     |
| Gemini    | 文生圖              | `POST /v1beta/models/{model}:generateContent`         | `candidates[].content.parts[].inlineData` | [生成](/simidoc/zh-Hant/apps/api/images/gemini/generate)                     |
| Gemini    | 圖片編輯 / 多輪改圖      | 同上，混合輸入文字和圖片                                          | 回傳內容項中的圖片                                 | [編輯](/simidoc/zh-Hant/apps/api/images/gemini/edits)                        |
| Gemini    | 圖片理解             | 同上，使用支援視覺輸入的模型                                        | 文字分析                                      | [媒體識別](/simidoc/zh-Hant/apps/api/chat/gemini-media)                |
| 通義千問      | 文生圖 / 圖片編輯       | `POST /v1/images/generations`、`POST /v1/images/edits` | `data[].url` 或 `data[].b64_json`          | [生成](/simidoc/zh-Hant/apps/api/images/qwen/generations)、[編輯](/simidoc/zh-Hant/apps/api/images/qwen/edits) |
| 即夢 / 火山方舟 | 文生圖 / 參考圖生成      | `POST /api/v3/images/generations`                     | `data[].url` 或 `data[].b64_json`          | [生成](/simidoc/zh-Hant/apps/api/images/jimeng)                              |
| xAI Grok  | 文生圖 / 多張生成       | `POST /v1/images/generations`                         | `data[].url` 或 `data[].b64_json`          | [生成](/simidoc/zh-Hant/apps/api/images/grok)                                |
| BFL FLUX  | 文生圖 / 參考圖生成（非同步） | `POST /v1/flux-pro-1.1` 等                             | 先取 `polling_url`，完成後取 `result.sample`     | [生成](/simidoc/zh-Hant/apps/api/images/flux)                                |

**通義千問這一節使用 Qwen 原生請求體，透過本站閘道的 `/v1/images/generations` 與 `/v1/images/edits` 呼叫，回傳統一為 `data[]`。** 不要把正文改寫成 OpenAI 的 `prompt` 欄位；模型 ID 應使用本站管道實際提供的名稱。即夢使用火山方舟原生請求主體；Grok 的路徑與 OpenAI Images 相同，但畫幅參數換成了 `aspect_ratio` 與 `resolution`；FLUX 沒有同步出圖，必須先提交任務再輪詢 `polling_url`。三者不能互相照搬欄位。

呼叫方式也要隨協議區分：OpenAI Images 普通請求等待完整結果，支援的模型才可使用圖像事件流；Gemini 串流使用 `streamGenerateContent?alt=sse`；本目錄通義千問與即夢範例使用同步回傳；Grok 預設同步，也可用 `deferred` 轉為延遲任務；FLUX 則固定為非同步輪詢。它們都不能僅靠新增「非同步」參數變成通用任務佇列。具體請求、輸出和完成判定見 [OpenAI](/simidoc/zh-Hant/apps/api/images/openai)、[Gemini](/simidoc/zh-Hant/apps/api/images/gemini)、[通義千問](/simidoc/zh-Hant/apps/api/images/qwen)、[即夢](/simidoc/zh-Hant/apps/api/images/jimeng)、[Grok](/simidoc/zh-Hant/apps/api/images/grok)、[FLUX](/simidoc/zh-Hant/apps/api/images/flux)各自說明。

## 二、各種效果：按目標選擇

「水彩」「換背景」「商品合成」等通常是生成或編輯任務，不是各自獨立的 API。以下是任務分類，不是全模型能力承諾；先在對應協議和模型說明中確認支援範圍。

| 想要的效果              | 輸入與提示詞重點              | 介面選擇與限制                          |
| ------------------ | --------------------- | -------------------------------- |
| 從零創作：插畫、封面、海報、寫實畫面 | 描述主體、構圖、風格、光線與需要呈現的文字 | 選文生圖；文字與細節需檢查                    |
| 參考圖變體：沿用主體或構圖重新生成  | 提供參考圖，分別說明保留項與改變項     | 選圖片編輯 / 以圖生圖；不能保證逐像素保持           |
| 風格轉換：照片轉水彩、線稿等     | 參考圖加目標風格，說明主體和佈局是否保留  | 選支援參考圖的編輯模型                      |
| 背景替換、增刪元素、局部修改     | 明確修改區域；支援時提供蒙版        | 選編輯介面；蒙版支援和規則隨模型變化               |
| 多圖組合：商品、人物與場景合成    | 給出各參考圖的用途、主體關係和最終佈局   | 選支援多圖輸入的編輯模型，核對圖片數量上限            |
| 多輪迭代：基於上一張繼續修改     | 保留協議要求的歷史內容或引用資訊      | 選支援多輪圖像工作的介面；不能只儲存一段文字就假定圖像上下文仍在 |
| 透明背景素材             | 明確需要真實透明通道，而非白底或棋盤格畫面 | 僅在模型支援時選擇透明背景和可保留透明通道的輸出格式       |
| 識圖、提取文字、圖表問答       | 輸入圖片並說明分析目標           | 選圖片理解介面，回傳文字而非編輯後的圖              |

這些能力與限制可參考 [OpenAI 圖像生成](https\://developers.openai.com/api/docs/guides/image-generation)、[Gemini 圖像生成與編輯](https\://ai.google.dev/gemini-api/docs/image-generation)、[Qwen 圖像編輯](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api)。官方範例不代表目前閘道管道已開放相同能力。

## 三、發起呼叫：四步完成第一張圖

無論選擇哪套協議，呼叫都遵循同一順序：確認設定、選擇端點、傳送最小請求、讀取並驗收結果。下面只描述通用流程，具體欄位以對應協議頁面為準。

### 1. 確認請求位址、金鑰與模型

* **請求位址**：本站閘道為 `https://api.dwchainless.com`，端點路徑隨協議和操作變化。
* **金鑰**：在 [API 金鑰管理](https://api.dwchainless.com/keys) 建立，請求時透過 `Authorization: Bearer $API_KEY` 攜帶；不要寫進提示詞、原始碼、截圖或 Git。
* **模型**：從[模型與價格](https://api.dwchainless.com/zh-Hant/pricing/)複製完整模型 ID，並確認它支援目標端點。生成、編輯和圖片理解可能由不同模型提供。

### 2. 選擇端點與請求格式

按上方的協議表選擇端點，再確認請求主體格式：

| 操作          | 端點（OpenAI 格式）                 | 請求格式                        |
| ----------- | ----------------------------- | --------------------------- |
| 文字生圖        | `POST /v1/images/generations` | JSON                        |
| 圖片編輯 / 以圖生圖 | `POST /v1/images/edits`       | JSON `images[]` 或 multipart |
| 對話式生圖       | `POST /v1/responses`          | JSON，啟用圖像工具                 |
| 圖片理解        | `POST /v1/chat/completions`   | JSON，內容項含 `image_url`       |

Gemini、通義千問、即夢、Grok 和 FLUX 使用各自的原生請求欄位，不能把 OpenAI 欄位直接照搬過去。

### 3. 傳送最小請求

第一次呼叫只生成一張、不使用串流，先確認鑑權、模型和參數都有效。以下以 OpenAI 生圖為例：

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

確認回傳正常後，再按需增加 `n`、調整尺寸或開啟串流。完整的多語言範例見[生成](/simidoc/zh-Hant/apps/api/images/openai/generations)和[編輯](/simidoc/zh-Hant/apps/api/images/openai/edits)。

**回傳形態（示意）**：真實回應的 Base64 很長，這裡只保留開頭；成功時看 `data[]` 而不只是 HTTP 200。

```json
{
  "created": 1763366400,
  "data": [{ "b64_json": "iVBORw0KGgoAAAANSUhEUg..." }],
  "usage": { "input_tokens": 28, "output_tokens": 4160, "total_tokens": 4188 }
}
```

### 4. 讀取結果並驗收

1. **檢查狀態**：只有 2xx 表示請求成功；4xx 檢查參數和權限，5xx 或逾時先確認請求是否已執行。
2. **讀取結果**：從 `data[]` 取圖片，GPT Image 回傳 `data[].b64_json`，相容模型可能回傳 `data[].url`；不要假定一定有第一項。
3. **儲存圖片**：Base64 先解碼為二進位，並按實際 MIME 類型選擇副檔名；URL 及時下載，下載時不要附帶 API Key。
4. **驗收**：檢查檔案能否開啟、實際像素尺寸、透明效果和內容，再核對使用紀錄。HTTP 200、空 `data[]` 或串流中間預覽都不等於最終圖片已經儲存。

## 四、圖片規格與計費

### 請求中各項規格分別控制什麼

| 規格    | 含義與例子                              | 容易混淆的地方                                    |
| ----- | ---------------------------------- | ------------------------------------------ |
| 像素尺寸  | 實際寬 × 高，例如 `1024x1024`、`1536x1024` | 不是檔案大小，也不自動代表品質檔位                          |
| 寬高比   | `1:1` 方圖、`16:9` 橫圖、`9:16` 直式圖      | 相同比例可有多種解析度；只選比例沒有指定全部像素尺寸                 |
| 解析度檔位 | 某些模型使用 `1K`、`2K`、`4K` 等原生參數        | 廠商檔位的實際寬高還取決於模型和比例，不應直接等同本站按張計費的像素邊界       |
| 生成品質  | 如 OpenAI 的 `quality`，控制模型的渲染品質選擇   | 不是 `size`，也不是 JPEG/WebP 的壓縮品質；不同模型不一定有同名參數 |
| 檔案格式  | PNG、JPEG、WebP 等，以實際回傳的 MIME 類型為準   | Base64 和 URL 是交付方式，不是圖片格式；改副檔名不能轉換格式       |
| 透明背景  | 圖片包含透明通道，適合素材疊加                    | 需要模型、參數和檔案格式共同支援；寫「透明背景」不保證結果一定帶透明通道       |
| 張數    | 生成數量或候選數量，欄位和上限隨協議、模型變化            | 提示詞寫「生成三張」不等於設定 API 張數；多圖輸入也不等於多圖輸出        |

同一寬高比下，邊長翻倍會讓總像素數變為四倍，但不保證畫面細節或清晰度按同樣倍數提升。選擇時先滿足使用場景，再核對模型支援、耗時與價格，不必一律使用最高檔。

具體欄位、可用值和程式碼範例分別見 [OpenAI 請求格式](/simidoc/zh-Hant/apps/api/images/openai/generations)、[Gemini 請求格式](/simidoc/zh-Hant/apps/api/images/gemini/generate)、[通義千問請求格式](/simidoc/zh-Hant/apps/api/images/qwen/generations)、[即夢請求格式](/simidoc/zh-Hant/apps/api/images/jimeng)、[Grok 請求格式](/simidoc/zh-Hant/apps/api/images/grok)、[FLUX 請求格式](/simidoc/zh-Hant/apps/api/images/flux)。其中 OpenAI 的輸出品質、格式和透明參數見[官方輸出設定](https\://developers.openai.com/api/docs/guides/image-generation#customize-image-output)；Qwen 的尺寸與輸出要求見[官方規格](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api)。不要把某個協議的參數直接複製給另一協議。

### 本站 1K、2K、4K 按張計費有什麼區別

只有在[模型價格](https://api.dwchainless.com/zh-Hant/pricing/)中明確採用 1K / 2K / 4K 三檔按張計費的模型，才適用下表。按 Token 計費或其他固定單價的模型仍按各自規則結算，不能僅憑「圖片模型」名稱判斷收費方式。

| 計費檔位 | 最長邊                    | 範例尺寸（像素）            |
| ---- | ---------------------- | ------------------- |
| 1K   | 兩邊均 ≤ 1024 像素          | 1024×1024           |
| 2K   | 最長邊 > 1024 且 ≤ 2048 像素 | 1280×720、1536×1024  |
| 4K   | 任一邊 > 2048 像素          | 2560×1440、3840×2160 |

**總價 = 目前檔位單張價格 × 計費張數。** 支援按完成結果結算的介面按實際完成張數計費；串流中間預覽不算完成圖片。單張價格、分組和最終扣費以目前模型價格及使用紀錄為準，本頁不固定價格數值。

採用上述三檔按張規則時，只有在未指定其他有效尺寸檔位的情況下，省略 `size` 或使用 `auto` 才預設按 1K 檔計費；顯式指定的原生解析度欄位仍決定計費檔位。按以下邊界歸檔：1K 為兩邊均 ≤ 1024；2K 為最長邊 > 1024 且 ≤ 2048；4K 為任一邊 > 2048。例如 `1280x720` 屬於 2K，`2560x1440` 屬於 4K。

**計費檔位不是輸出尺寸承諾。** Gemini 的 `generationConfig.imageConfig.imageSize` 是模型的原生解析度選擇，實際像素尺寸應結合模型與比例確認；本站按支援的請求欄位計算計費檔位，不據此承諾統一的輸出寬高。不要同時填寫相互衝突的尺寸欄位，也不要把按張規則套用到官方直連或按 Token 計費模型。

### 常用比例速查：14 種比例 × 1K / 2K / 4K

下表按比例列出常見的 1K、2K、4K 預設尺寸，方便快速挑選畫幅。它是尺寸速查，不是模型支援清單：可用比例、預設名稱和單邊上限隨模型與管道變化，請求前仍須以模型說明或介面錯誤為準。

K 檔位是預設名稱，不是本頁的按張計費檔位。部分「1K」預設的最長邊已超過 1024 像素，按本站規則會歸入 2K 檔；例如 16\:9 的 1K 預設 `1536x864` 屬於 2K。計費始終按實際請求尺寸和[模型價格](https://api.dwchainless.com/zh-Hant/pricing/)計算。

| 比例        | 常見用途        | 1K size     | 2K size     | 4K size     |
| :-------- | :---------- | :---------- | :---------- | :---------- |
| `1:1`     | 方形頭像 / 產品圖  | `1024x1024` | `2048x2048` | `3840x3840` |
| `4:3`     | 橫向插畫 / 展示圖  | `1152x896`  | `2048x1536` | `3840x2880` |
| `3:4`     | 直式海報 / 人像   | `896x1152`  | `1536x2048` | `2880x3840` |
| `16:9`    | 橫屏封面 / 簡報   | `1536x864`  | `2048x1152` | `3840x2160` |
| `9:16`    | 直式封面 / 手機背景 | `864x1536`  | `1152x2048` | `2160x3840` |
| `3:2`     | 橫向攝影        | `1536x1024` | `2048x1360` | `3840x2560` |
| `2:3`     | 直式攝影        | `1024x1536` | `1360x2048` | `2560x3840` |
| `5:4`     | 橫向商品展示      | `1280x1024` | `2560x2048` | `3840x3072` |
| `4:5`     | 直式商品 / 社群圖  | `1024x1280` | `2048x2560` | `3072x3840` |
| `21:9`    | 寬幅場景 / 橫幅   | `1792x768`  | `2048x880`  | `3840x1648` |
| `1:4`     | 窄長直幅        | `512x2048`  | `768x3072`  | **超出單邊上限**  |
| `4:1`     | 窄長橫幅        | `2048x512`  | `3072x768`  | **超出單邊上限**  |
| `1.414:1` | 近似 A 系列橫向紙張 | `1440x1024` | `2048x1456` | `3840x2720` |
| `1:1.414` | 近似 A 系列直式紙張 | `1024x1440` | `1456x2048` | `2720x3840` |

### size 的三種正確寫法

部分 OpenAI 相容閘道支援以下寫法；欄位是否生效取決於模型與管道，不被支援時應退回明確像素。

| 寫法       | 請求片段                               | 用途               |
| :------- | :--------------------------------- | :--------------- |
| 明確像素（推薦） | `{"size":"1536x2048"}`             | 最直觀，避免預設換算差異     |
| 比例 + 解析度 | `{"size":"3:4","resolution":"2k"}` | 按 2K / 3\:4 預設換算 |
| 自動尺寸     | `{"size":"auto"}`                  | 由模型按能力選擇，不承諾固定寬高 |

* K 檔位填 `resolution`，`size` 填像素或比例；不要把 `2k` 寫進 `size`。
* 尺寸分隔符使用小寫英文字母 `x`，不要用乘號 ×、大寫 X、陣列或帶乘號的字串。
* 比例寫進 `size` 時優先於單獨的 `aspect_ratio`；明確像素或 `auto` 優先於比例預設。
* OpenAI 官方對 gpt-image-2 的任意尺寸上限為 3840×2160；`1:4`、`4:1` 的 4K 組合超過該上限，因此標註超出單邊上限。其他模型的上限以模型說明為準。
* Gemini 與 Qwen 使用各自的尺寸欄位，不能直接套用上述寫法。

### 常用尺寸參考：28 種

以下標記僅表示上述按張規則的計費檔位，不保證所選模型支援這些尺寸。先檢查模型介面支援範圍，再選擇尺寸；不要把計費檔位直接當成介面參數值。

| 用途 / 比例              | 尺寸（像素）與計費檔位                                                              |
| -------------------- | ------------------------------------------------------------------------ |
| 通用方圖 · 1\:1          | 1024×1024 · 1K；1536×1536 · 2K；2048×2048 · 2K                             |
| 橫版封面 · 16\:9         | 1280×720 · 2K；1536×864 · 2K；2048×1152 · 2K；2560×1440 · 4K；3840×2160 · 4K |
| 直式影片 / Story · 9\:16 | 720×1280 · 2K；864×1536 · 2K；1152×2048 · 2K；1440×2560 · 4K；2160×3840 · 4K |
| 文章配圖 · 3\:2          | 1536×1024 · 2K；1920×1280 · 2K；2400×1600 · 4K                             |
| 直式海報 · 2\:3          | 1024×1536 · 2K；1280×1920 · 2K；1600×2400 · 4K                             |
| 寬橫幅 · 2\:1           | 1536×768 · 2K；2048×1024 · 2K；2560×1280 · 4K；3840×1920 · 4K               |
| 超寬橫幅 · 3\:1          | 1536×512 · 2K；1920×640 · 2K；2400×800 · 4K；3072×1024 · 4K；3840×1280 · 4K  |

## 五、按協議深入

各協議的完整參數、回傳結構、程式碼範例和錯誤處理：

* [OpenAI 格式](/simidoc/zh-Hant/apps/api/images/openai)
* [Gemini 格式](/simidoc/zh-Hant/apps/api/images/gemini)
* [通義千問格式](/simidoc/zh-Hant/apps/api/images/qwen)
* [即夢 / 火山方舟格式](/simidoc/zh-Hant/apps/api/images/jimeng)
* [xAI Grok 格式](/simidoc/zh-Hant/apps/api/images/grok)
* [BFL FLUX 格式](/simidoc/zh-Hant/apps/api/images/flux)