# Kling 影片

## 介面說明

Kling 官方新版影片 API 使用功能/模型路徑、settings/options 和統一任務查詢：

| 操作   | 目前官方介面                                          | 文件                                          |
| ---- | ----------------------------------------------- | ------------------------------------------- |
| 文生影片 | `POST /text-to-video/kling-3.0`                 | [建立](/simidoc/zh-Hant/apps/api/video/kling/text-create) / [查詢](/simidoc/zh-Hant/apps/api/video/kling/text-status)   |
| 圖生影片 | `POST /image-to-video/kling-3.0`                | [建立](/simidoc/zh-Hant/apps/api/video/kling/image-create) / [查詢](/simidoc/zh-Hant/apps/api/video/kling/image-status) |
| 查詢   | `GET /tasks?task_ids=...` 或 external\_task\_ids | 通用任務查詢                                      |

本節範例直連 `https://api-singapore.klingai.com`，使用 Kling 官方 API Key Bearer 身分驗證。舊帳戶 AK/SK + HS256 JWT 僅適用於舊版設計標準；不能把 SimiRouter Key 或裸 SecretKey 當 Kling Key。

## 新舊通訊協定不能混用

舊版 `/v1/videos/text2video`、`/v1/videos/image2video` 使用 model\_name、task\_id、task\_status 和 succeed；新版使用路由中的模型、data.id、status 和 succeeded。舊版 endpoint 在官方仍有 legacy 參考，但不能給新版請求補上舊版欄位。SimiRouter `/kling/...` 屬於閘道對應，需確認管道版本，不能只在新官方路徑前新增前綴。

生成是非同步過程，不是 SSE。建立後輪詢或接收 callback，只有成功終態才消費 outputs 中的 video 項。

## 官方參考

[Kling 文生影片](https\://kling.ai/document-api/apiReference/model/textToVideo)、[圖生影片](https\://kling.ai/document-api/apiReference/model/imageToVideo)、[身分驗證](https\://kling.ai/document-api/api/get-started/authentication)。