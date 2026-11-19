# Sora 影片（官方介面已關閉）

**OpenAI 官方 Sora 2 與 Videos API 已於 2026-09-24 關閉。** 下方僅保留介面結構參考，不是可用呼叫教學。SimiRouter 若存在同名模型或第三方相容實現，其來源、能力與通訊協定應另行確認，不能稱作 OpenAI 官方直連。

## 介面說明

| 操作   | 原官方端點                               | 參考              |
| ---- | ----------------------------------- | --------------- |
| 建立任務 | `POST /v1/videos`                   | [建立](/simidoc/zh-Hant/apps/api/video/sora/create)  |
| 查詢任務 | `GET /v1/videos/{video_id}`         | [查詢](/simidoc/zh-Hant/apps/api/video/sora/status)  |
| 下載影片 | `GET /v1/videos/{video_id}/content` | [內容](/simidoc/zh-Hant/apps/api/video/sora/content) |

原通訊協定為非同步生成，status 從 queued/in\_progress 進入 completed 或 failed；沒有普通串流生成輸出。官方停用通知明確沒有一對一替代 API。其他影片能力請按 [影片分類](/simidoc/zh-Hant/apps/api/video) 選擇可用供應商，不做自動替換。

## 官方參考

[OpenAI 關閉通知](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api)、[Videos API Reference](https\://developers.openai.com/api/reference/resources/videos/methods/create)。