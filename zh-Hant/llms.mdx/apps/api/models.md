# 模型清單

模型清單是接入設定的入口：先取得模型 ID，再根據廠商能力文件選擇聊天、視覺、圖片、音訊或工具介面。可見不等於可呼叫，模型清單也不代表即時健康檢查。

## 概覽

| 你要確認的事   | 在哪裡看           | 說明                |
| -------- | -------------- | ----------------- |
| 有哪些模型 ID | 本節的清單介面        | 只回傳目前憑證可見的模型      |
| 能不能真正呼叫  | 模型與價格 + 一次真實請求 | 可見、可路由、有額度是三件不同的事 |
| 支援哪些輸入輸出 | 模型能力說明         | 清單元資料通常不完整        |
| 什麼時候下線   | 廠商發布的棄用或停用公告   | 棄用不等於立即不可用，但不應新接入 |

## 核心概念

* **模型 ID**：請求主體中使用的唯一識別碼，通常區分大小寫，必須完整複製，不要自行縮寫。顯示名稱、別名和實際請求 ID 可能不同。
* **可見與可呼叫**：清單只反映權限範圍內的模型，管道未設定、餘額不足或限流時仍會失敗。
* **上下文視窗**：輸入加輸出的 Token 上限，按模型區分；清單介面經常不回傳該值。
* **計費單位**：文字模型多按 Token，圖片模型可按張或按 Token，影片模型常按秒或按次；同一模型族內也可能不同。
* **下線日期**：表示廠商計畫停止服務的日期，遷移應在到期前完成，而不是到期後才發現。

## 查詢介面

| 文件                    | 請求                 | 回傳結構                            |
| --------------------- | ------------------ | ------------------------------- |
| [OpenAI 格式](/simidoc/zh-Hant/apps/api/models/openai) | GET /v1/models     | data\[].id，適合 OpenAI 相容用戶端。     |
| [Gemini 格式](/simidoc/zh-Hant/apps/api/models/gemini) | GET /v1beta/models | models\[].name，適合 Gemini 協議用戶端。 |

## 呼叫方式

清單查詢為同步 JSON 請求，不支援 SSE，也不是非同步任務。多個帳戶可分別平行查詢，但憑證和結果不能混用。清單快取應設有效期，發現模型不再可用時重新讀取；不要為重新整理清單傳送真實生成請求。

## 模擬呼叫

查詢使用 GET，無需請求主體。以下是 SimiRouter 閘道的回應範例：

```bash
curl "https://api.dwchainless.com/v1/models" \
  -H "Authorization: Bearer $SIMIROUTER_API_KEY"
```

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

閘道會回傳上下文長度和介面類型。上下文長度可能是平台預設值，價格、輸入輸出模態和工具支援仍應查閱模型說明。清單為空通常表示目前憑證沒有可見模型。

## 元資料邊界

OpenAI 模型物件包含 id、object、created、owned\_by；Google 原生模型物件可包含方法與 Token 限制。閘道可以只回傳精簡元資料，因此不能根據缺失欄位臆測上下文上限、模態或工具支援。

## 官方參考

* [OpenAI Models API](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [Google Models API](https\://ai.google.dev/api/models)