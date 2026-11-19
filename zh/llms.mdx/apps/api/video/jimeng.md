# 即梦视频（待接入）

## 接口说明

即梦视频官方通过**火山视觉**的同步转异步接口提供文生视频与首帧图生视频。它与**火山方舟 Seedance**是不同网关、不同鉴权协议，不共用 Bearer Key。

| 步骤 | 官方请求                                                                                      | 文档               |
| -- | ----------------------------------------------------------------------------------------- | ---------------- |
| 提交 | POST `https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31` | [提交任务](/simidoc/zh/apps/api/video/jimeng/create) |
| 查询 | POST 同主机，Action=CVSync2AsyncGetResult                                                     | [查询结果](/simidoc/zh/apps/api/video/jimeng/status) |

本节保留即梦 3.0 Pro 官方参考；该官方页面标注“下线中”，需在火山控制台确认账号仍可开通的产品和版本。SimiRouter 的即梦能力为待接入参考，不提供未经明确配置的公网调用承诺。

## 鉴权与异步流程

官方使用 AK/SK 的 HMAC-SHA256 V4 签名，Region=`cn-north-1`，Service=`cv`。Authorization 不是 Bearer，签名覆盖方法、路径、query、指定 headers 和正文哈希。

提交 code=10000 后获取 data.task\_id；查询相同 req\_key 与 task\_id。状态为 in\_queue、generating、done、not\_found、expired。**done 仅表示处理结束，不保证成功**；还要检查 code、message 和 video\_url。此接口没有视频实时流或 SSE。

## 官方参考

[即梦 3.0 Pro 接口](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh)、[火山官方签名实现](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py)。