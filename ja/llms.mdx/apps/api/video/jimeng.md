# Jimeng 動画（接続予定）

## API の説明

Jimeng 動画の公式 API は、**Volcengine Visual** の同期から非同期への変換 API を通して、テキストから動画生成と先頭フレームを使う画像から動画生成を提供します。**Volcengine Ark Seedance** とはゲートウェイと認証プロトコルが異なり、Bearer Key を共用できません。

| 手順 | 公式リクエスト                                                                                   | 文書                 |
| -- | ----------------------------------------------------------------------------------------- | ------------------ |
| 送信 | POST `https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31` | [タスクの送信](/simidoc/ja/apps/api/video/jimeng/create) |
| 照会 | 同じホストへの POST。Action=CVSync2AsyncGetResult                                                 | [結果の照会](/simidoc/ja/apps/api/video/jimeng/status)  |

本セクションは Jimeng 3.0 Pro の公式参考情報を掲載しています。公式ページには「提供終了手続き中」と記載されています。アカウントで引き続き開通可能な製品とバージョンを Volcengine コンソールで確認してください。SimiRouter の Jimeng 機能は接続予定の参考情報であり、明示的に設定されていない公開 API の呼び出しを保証しません。

## 認証と非同期フロー

公式 API は AK/SK の HMAC-SHA256 V4 署名を使用し、Region=`cn-north-1`，Service=`cv` です。Authorization は Bearer ではなく、署名の対象はメソッド、パス、query、指定の headers、本文ハッシュです。

送信で code=10000 を確認して data.task\_id を取得し、同じ req\_key と task\_id で照会します。状態は in\_queue、generating、done、not\_found、expired です。**done は処理終了のみを示し、成功は保証しません**。code、message、video\_url も確認する必要があります。この API にはリアルタイム動画ストリームや SSE はありません。

## 公式資料

[Jimeng 3.0 Pro API](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh)、[Volcengine 公式署名実装](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py)。