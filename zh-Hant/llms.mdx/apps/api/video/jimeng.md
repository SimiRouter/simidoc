# 即夢影片（待串接）

## 介面說明

即夢影片官方通過**火山視覺**的同步轉非同步介面提供文生影片與首影格圖生影片。它與**火山方舟 Seedance**是不同閘道、不同身分驗證通訊協定，不共用 Bearer Key。

| 步驟 | 官方請求                                                                                      | 文件               |
| -- | ----------------------------------------------------------------------------------------- | ---------------- |
| 提交 | POST `https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31` | [提交任務](/simidoc/zh-Hant/apps/api/video/jimeng/create) |
| 查詢 | POST 同主機，Action=CVSync2AsyncGetResult                                                     | [查詢結果](/simidoc/zh-Hant/apps/api/video/jimeng/status) |

本節保留即夢 3.0 Pro 官方參考；該官方頁面標註“下線中”，需在火山控制台確認帳號仍可開通的產品和版本。SimiRouter 的即夢能力為待串接參考，不提供未經明確設定的公網呼叫承諾。

## 身分驗證與非同步流程

官方使用 AK/SK 的 HMAC-SHA256 V4 簽名，Region=`cn-north-1`，Service=`cv`。Authorization 不是 Bearer，簽名覆蓋方法、路徑、query、指定 headers 和本文雜湊。

提交 code=10000 後取得 data.task\_id；查詢相同 req\_key 與 task\_id。狀態為 in\_queue、generating、done、not\_found、expired。**done 僅表示處理結束，不保證成功**；還要檢查 code、message 和 video\_url。此介面沒有影片即時流或 SSE。

## 官方參考

[即夢 3.0 Pro 介面](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh)、[火山官方簽名實現](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py)。