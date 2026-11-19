# 音訊

音訊 API 用於把文字變為語音、把錄音轉為文字，以及理解音訊內容。語音、音樂生成和影片音軌是不同能力，不應混用模型和端點。

## 概覽

| 你想做的事     | 方向        | 典型輸出          | 計費單位          |
| --------- | --------- | ------------- | ------------- |
| 朗讀文字、做配音  | 文字 → 語音   | MP3、WAV 等音訊檔案 | 輸入字元數或音訊時長    |
| 把錄音轉成文字   | 語音 → 文字   | 原語言文字、時間戳     | 音訊秒數或分鐘數      |
| 把外語錄音轉成英文 | 語音 → 英文文字 | 英文文字，不保留原語言   | 音訊時長          |
| 理解錄音內容    | 語音 → 分析文字 | 摘要、說話人、結論     | 輸入音訊對應的 Token |
| 與人即時對話    | 雙向音訊流     | 連續音訊與事件       | 工作階段時長或 Token |

## 核心概念

* **取樣率**：每秒取樣次數，常見 16kHz（語音辨識夠用）與 24kHz、44.1kHz（音質更高）。取樣率不匹配會導致播放變調或轉錄品質下降。
* **位元深度與聲道**：16 bit 單聲道是語音場景的通用選擇；立體聲與更高位元深度會增加檔案體積，模型未必利用。
* **容器與編碼**：MP3 有損、體積小；WAV 通常無壓縮、體積大；PCM 是沒有容器的原始取樣，播放時需要手動指定取樣規格。
* **時長與大小**：上傳限制常以檔案大小和時長同時約束，轉成高取樣率不會提高辨識準確率，只會更容易超限。
* **同步與串流**：TTS 回傳音訊位元組，ASR 回傳 JSON。串流降低首字或首段等待時間，不改變計費總量。

規格數值（最大時長、支援格式、取樣率範圍）由模型決定，逐項見各介面頁的請求參數表。

## 介面說明

| 能力          | 輸入 → 輸出              | 請求方式                                     | 文件                              |
| ----------- | -------------------- | ---------------------------------------- | ------------------------------- |
| 語音合成（TTS）   | 文字 → 音訊              | 單次 HTTP；部分模型可分塊或 SSE                     | [文字轉語音](/simidoc/zh-Hant/apps/api/audio/speech)               |
| 語音轉錄（ASR）   | 音訊檔案 → 原語言文字         | multipart 上傳；部分模型支援轉錄 SSE                | [音訊轉錄](/simidoc/zh-Hant/apps/api/audio/transcriptions)        |
| 語音翻譯        | 多語言音訊檔案 → 英文文字       | multipart 單次請求                           | [音訊翻譯](/simidoc/zh-Hant/apps/api/audio/translations)          |
| Gemini 語音合成 | 文字 → 單人/多人音訊         | 原生 Interactions，支援的舊模型另用 generateContent | [Gemini TTS](/simidoc/zh-Hant/apps/api/audio/gemini)          |
| Gemini 音訊理解 | 錄音 → 摘要、轉錄、分析文字      | 原生多模態請求                                  | [音訊理解](/simidoc/zh-Hant/apps/api/audio/gemini-understanding)  |
| MiMo 語音     | 文字/參考聲音 → 語音；錄音 → 文字 | 獨立相容路由或官方 Chat Completions               | [MiMo](/simidoc/zh-Hant/apps/api/audio/mimo-audio)            |
| 即時語音        | 持續輸入與輸出              | WebRTC / 雙向 WebSocket                    | [Realtime](/simidoc/zh-Hant/apps/api/pending/realtime) |

## 同步、非同步與串流的區別

* **同步 HTTP**：一條請求回傳音訊檔案或完整轉錄，沒有任務 ID 和輪詢步驟。
* **HTTP 串流**：同一回應逐塊回傳音訊或 SSE 事件，不等於雙向即時工作階段。不要對二進位流呼叫 JSON 解析。
* **非同步任務**：先得到任務 ID，再查詢狀態；影片生成通常採用此方式，普通 TTS/ASR 不是這種流程。
* **Realtime**：工作階段保持連接，用戶端可持續送入音訊、打斷播放並處理事件，不能用檔案上傳代替。

## 模擬呼叫

語音合成的請求主體是 JSON，回應卻是音訊位元組而不是 JSON：

```json
{
  "model": "gpt-4o-mini-tts",
  "voice": "alloy",
  "input": "欢迎使用 SimiRouter。",
  "response_format": "mp3"
}
```

回傳的標頭決定如何儲存檔案，主體直接寫入 `.mp3`：

```text
HTTP/1.1 200 OK
Content-Type: audio/mpeg
Content-Length: 24576

<二进制音频数据>
```

轉錄走 multipart 上傳，回傳 JSON：

```json
{"text":"欢迎使用 SimiRouter。"}
```

同一個「音訊」分類裡，合成回傳二進位、轉錄回傳 JSON，解析器不能混用。範例模型 `gpt-4o-mini-tts` 已被廠商標記棄用，替代模型與遷移方式見[文字轉語音](/simidoc/zh-Hant/apps/api/audio/speech)。

## 使用前提

OpenAI 相容頁使用 SimiRouter 位址與 SimiRouter Key；廠商原生參考使用廠商位址與對應 Key。模型是否可用由帳戶模型清單和管道權限決定，不能把廠商所有能力視為閘道已全部提供。上傳錄音前應取得必要授權；複製聲音需擁有聲音使用權並向聽眾揭露合成語音。

## 官方參考

* [OpenAI 語音合成](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create)
* [OpenAI 語音轉錄](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create)
* [OpenAI 語音翻譯](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create)
* [Google 音訊理解](https\://ai.google.dev/gemini-api/docs/audio)
* [Google Gemini TTS](https\://ai.google.dev/gemini-api/docs/speech-generation)