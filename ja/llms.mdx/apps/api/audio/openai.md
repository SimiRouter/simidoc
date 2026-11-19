# OpenAI 音声形式

## API の説明

OpenAI 音声形式には 3 つの独立した HTTP エンドポイントがあり、いずれも `Authorization: Bearer $SIMIROUTER_API_KEY` を使用します。

| エンドポイント                         | コンテンツタイプ            | 戻り値                          | 文書                          |
| ------------------------------- | ------------------- | ---------------------------- | --------------------------- |
| `POST /v1/audio/speech`         | JSON                | 音声バイト列。モデルが対応する場合は SSE も利用可能 | [音声合成](/simidoc/ja/apps/api/audio/speech)            |
| `POST /v1/audio/transcriptions` | multipart/form-data | 文字起こしの JSON、テキスト、字幕          | [音声文字起こし](/simidoc/ja/apps/api/audio/transcriptions) |
| `POST /v1/audio/translations`   | multipart/form-data | 英訳のテキストまたは字幕                 | [音声翻訳](/simidoc/ja/apps/api/audio/translations)      |

リクエストの `model` には、アカウントで利用可能な音声モデルを指定する必要があります。TTS の `voice`、文字起こしの出力形式、タイムスタンプ、ストリーミング機能はモデルごとに異なり、相互に置き換えられません。ファイルの文字起こしはマイクの継続的なセッションを提供しません。その用途は [Realtime](/simidoc/ja/apps/api/pending/realtime) を参照してください。

本ページは OpenAI API 形式のリファレンスです。モデルのライフサイクルとメーカー固有パラメーターについては、各エンドポイントの公式 API リファレンスを参照してください。ゲートウェイの Key と OpenAI 公式 Key は共用できません。