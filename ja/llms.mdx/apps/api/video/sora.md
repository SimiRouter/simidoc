# Sora 動画（公式 API は提供終了）

**OpenAI 公式の Sora 2 と Videos API は 2026-09-24 に提供終了しました。** 以下は API 構造の参考情報であり、利用可能な呼び出し手順ではありません。SimiRouter に同名モデルやサードパーティーの互換実装がある場合、その提供元、機能、プロトコルは別途確認が必要です。OpenAI 公式への直接接続とは呼べません。

## API の説明

| 操作        | 以前の公式エンドポイント                        | 参考              |
| --------- | ----------------------------------- | --------------- |
| タスクの作成    | `POST /v1/videos`                   | [作成](/simidoc/ja/apps/api/video/sora/create)  |
| タスクの照会    | `GET /v1/videos/{video_id}`         | [照会](/simidoc/ja/apps/api/video/sora/status)  |
| 動画のダウンロード | `GET /v1/videos/{video_id}/content` | [内容](/simidoc/ja/apps/api/video/sora/content) |

以前のプロトコルは非同期生成で、status が queued/in\_progress から completed または failed に変化します。通常のストリーミング生成出力はありません。公式の提供終了告知では、直接対応する代替 API はないと明記されています。ほかの動画機能は [動画カテゴリ](/simidoc/ja/apps/api/video) から利用可能なプロバイダーを選択してください。自動置換は行いません。

## 公式資料

[OpenAI 提供終了のお知らせ](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api)、[Videos API Reference](https\://developers.openai.com/api/reference/resources/videos/methods/create)。