# 音樂（不支援）

本節整理 Google Lyria 的公開生成通訊協定。SimiRouter 尚未開放該能力，以下範例均直接連接 Google AI Studio Gemini API，使用 `https://generativelanguage.googleapis.com` 與 Google API 金鑰。Vertex AI 需要獨立通訊協定，本頁尚未驗證，請勿直接替換位址呼叫。

## 概覽

| 能力     | 輸入           | 產物              | 本節性質   |
| ------ | ------------ | --------------- | ------ |
| 生成音樂片段 | 文字描述或圖片      | 約 30 秒音訊，預設 MP3 | 官方介面參考 |
| 生成完整歌曲 | 含主歌、副歌描述的提示  | 數分鐘歌曲，可帶歌詞與曲式   | 官方介面參考 |
| 即時演奏   | 持續下發的提示與播放控制 | 連續 PCM 音訊塊      | 官方介面參考 |

## 核心概念

* **片段與歌曲**：片段固定 30 秒，適合試聽與循環；歌曲由提示詞控制長度和結構，時長不是精確保證。
* **即時會話**：雙向 WebSocket，連接期間持續下發提示和 PLAY、PAUSE 控制，不是把一次性請求改成 stream 開關。
* **音訊格式**：預設 MP3，可請求 WAV；即時介面回傳原始 PCM 塊，需應用自行緩衝並封裝。
* **Key 與位址**：本頁範例只使用 Google AI Studio Gemini API 的位址與 Google API 金鑰；SimiRouter 尚未代理音樂模型，Vertex AI 的獨立通訊協定也未在本頁驗證。

時長上限、取樣率與位元率由模型決定，逐項見 [Lyria](/simidoc/zh-Hant/apps/api/music/lyria) 與 [RealTime](/simidoc/zh-Hant/apps/api/music/realtime) 的參數表。

## 介面說明

| 模式      | 官方通訊協定                      | 能力             | 文件                           |
| ------- | --------------------------- | -------------- | ---------------------------- |
| 一次性音樂生成 | `POST /v1beta/interactions` | 文字或圖片生成片段/完整歌曲 | [Lyria 音樂生成](/simidoc/zh-Hant/apps/api/music/lyria)        |
| 即時音樂    | 雙向 WebSocket                | 持續產生並動態調整器樂音訊  | [Lyria RealTime](/simidoc/zh-Hant/apps/api/music/realtime) |

Lyria Clip 生成 30 秒片段；Lyria 3.5 面向較完整歌曲。RealTime 是實驗能力，使用持久連接，不是 Interactions 的 stream 開關。音樂模型不負責普通文字朗讀，需要 TTS 時使用 [音訊](/simidoc/zh-Hant/apps/api/audio)。

## 模擬呼叫

Google 官方一次性生成使用 Interactions，請求描述曲風與結構：

```json
{
  "model": "lyria-3-clip-preview",
  "input": "温暖的钢琴与弦乐，节奏舒缓，适合纪录片开场"
}
```

回應裡的音訊是 Base64，不是下載位址：

```json
{
  "steps": [
    {
      "type": "model_output",
      "content": [
        { "type": "text", "text": "[Instrumental]" },
        { "type": "audio", "data": "<Base64音频>" }
      ]
    }
  ]
}
```

音訊與文字項可能交錯出現，必須遍歷 `content[]` 按 `type` 取用；只取最後一項會漏掉歌詞或曲式說明。

## 身分驗證與權利

Google 官方 Interactions 使用 `x-goog-api-key: $GEMINI_API_KEY`，即時連接使用官方 SDK 或其 WebSocket 通訊協定。生成內容仍須遵守 Google 使用條款、著作權與聲音授權要求。模型供應、地域和配額由 Google 帳戶決定。

## 官方參考

[Google 音樂生成](https\://ai.google.dev/gemini-api/docs/music-generation)、[即時音樂](https\://ai.google.dev/gemini-api/docs/realtime-music-generation)。