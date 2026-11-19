# Seedance 影片

## 介面說明

Seedance 支援文字生成影片和模型允許的圖片、影片、音訊參考輸入。火山方舟官方流程為建立非同步任務、查詢狀態、成功後下載。

| 操作 | 官方路徑                                          | 文件               |
| -- | --------------------------------------------- | ---------------- |
| 建立 | `POST /api/v3/contents/generations/tasks`     | [建立任務](/simidoc/zh-Hant/apps/api/video/seedance/create) |
| 查詢 | `GET /api/v3/contents/generations/tasks/{id}` | [查詢任務](/simidoc/zh-Hant/apps/api/video/seedance/status) |

官方基礎位址 `https://ark.cn-beijing.volces.com`，使用 `ARK_API_KEY` Bearer 身分驗證。`/v1/video/generations` 是閘道相容路徑，不是火山方舟官方位址；只有管道明確提供對應時才使用，不能把 id/status 自動改寫成其他廠商格式。

狀態為 `queued → running → succeeded`，失敗終態包括 failed、expired、cancelled。它不是 SSE 或 Realtime。模型版本決定有聲影片、參考素材、時長和解析度的支援範圍。

## 官方參考

[建立影片任務](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)、[查詢任務](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)、[影片教學](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh)。