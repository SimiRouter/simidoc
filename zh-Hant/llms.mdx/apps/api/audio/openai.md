# OpenAI 音訊格式

## 介面說明

OpenAI 音訊格式包含三個獨立 HTTP 端點，均使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。

| 端點                              | 內容型別                | 回傳值               | 文件                       |
| ------------------------------- | ------------------- | ----------------- | ------------------------ |
| `POST /v1/audio/speech`         | JSON                | 音訊位元組；模型支援時可用 SSE | [語音合成](/simidoc/zh-Hant/apps/api/audio/speech)         |
| `POST /v1/audio/transcriptions` | multipart/form-data | 轉錄 JSON、文字或字幕     | [語音轉錄](/simidoc/zh-Hant/apps/api/audio/transcriptions) |
| `POST /v1/audio/translations`   | multipart/form-data | 英文翻譯文字或字幕         | [語音翻譯](/simidoc/zh-Hant/apps/api/audio/translations)   |

請求 `model` 必須是帳戶可用的音訊模型。TTS 的 `voice`、轉錄輸出格式、時間戳和串流能力按具體模型區分，不能相互替換。檔案轉錄不提供持續麥克風工作階段；此場景參考 [Realtime](/simidoc/zh-Hant/apps/api/pending/realtime)。

本文為 OpenAI API 格式參考，模型生命週期和廠商參數以各端點的官方 API Reference 為準。閘道 Key 與 OpenAI 官方 Key 不可混用。