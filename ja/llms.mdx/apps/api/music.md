# 音楽（未対応）

本節は Google Lyria の公開生成プロトコルを整理したものです。SimiRouter はこの機能をまだ提供していないため、例はすべて Google AI Studio Gemini API に直接接続し、`https://generativelanguage.googleapis.com` と Google API キーを使用します。Vertex AI には別のプロトコルが必要で、このページでは検証していないため、アドレスだけを直接置き換えないでください。

## 概要

| 能力        | 入力                   | 出力                  | 本節の性質         |
| --------- | -------------------- | ------------------- | ------------- |
| 音楽クリップの生成 | テキスト記述または画像          | 約 30 秒の音声、デフォルト MP3 | 公式インターフェースの参考 |
| 曲全体の生成    | ヴァースとコーラスの記述を含むプロンプト | 数分の曲、歌詞と曲構成を含められる   | 公式インターフェースの参考 |
| リアルタイム演奏  | 継続的に送信するプロンプトと再生制御   | 連続した PCM 音声ブロック     | 公式インターフェースの参考 |

## 中核概念

* **クリップと曲**：クリップは 30 秒固定で、試聴やループに適しています。曲はプロンプトで長さと構成を制御し、長さは正確に保証されるものではありません。
* **リアルタイムセッション**：双方向 WebSocket で、接続中はプロンプトと PLAY、PAUSE 制御を継続的に送信します。一度きりのリクエストを stream スイッチに変えるものではありません。
* **音声形式**：デフォルトは MP3 で、WAV も要求できます。リアルタイムインターフェースは生の PCM ブロックを返すため、アプリ側でバッファリングしてカプセル化する必要があります。
* **Key とアドレス**：このページの例は Google AI Studio Gemini API のアドレスと Google API キーだけを使用します。SimiRouter は音楽モデルをプロキシしておらず、Vertex AI の別プロトコルもここでは検証していません。

長さの上限、サンプリングレート、ビットレートはモデルによって決まります。項目ごとに [Lyria](/simidoc/ja/apps/api/music/lyria) と [RealTime](/simidoc/ja/apps/api/music/realtime) のパラメータ表を参照してください。

## API の説明

| モード      | 公式プロトコル                     | 能力                       | 文書                           |
| -------- | --------------------------- | ------------------------ | ---------------------------- |
| 単発の音楽生成  | `POST /v1beta/interactions` | テキストまたは画像からクリップ／曲全体を生成   | [Lyria 音楽生成](/simidoc/ja/apps/api/music/lyria)        |
| リアルタイム音楽 | 双方向 WebSocket               | インストゥルメンタル音声を継続生成し、動的に調整 | [Lyria RealTime](/simidoc/ja/apps/api/music/realtime) |

Lyria Clip は 30 秒のクリップを生成します。Lyria 3.5 はより完全な楽曲を対象とします。RealTime は試験的な機能で、持続接続を使用し、Interactions の stream スイッチとは異なります。音楽モデルは通常のテキスト読み上げ用ではありません。TTS が必要な場合は [音声](/simidoc/ja/apps/api/audio) を参照してください。

## シミュレーション呼び出し

Google 公式の単発生成は Interactions を使用し、リクエストで曲調と構成を記述します。

```json
{
  "model": "lyria-3-clip-preview",
  "input": "温暖的钢琴与弦乐，节奏舒缓，适合纪录片开场"
}
```

レスポンスの音声は Base64 であり、ダウンロードアドレスではありません。

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

音声とテキストの項目は交互に現れる可能性があるため、`content[]` を走査して `type` に従って取得する必要があります。最後の項目だけを取得すると、歌詞や曲構成の説明を見落とします。

## 認証と権利

Google 公式 Interactions は `x-goog-api-key: $GEMINI_API_KEY` を使用します。リアルタイム接続には公式 SDK またはその WebSocket プロトコルを使用します。生成コンテンツには Google の利用規約、著作権、音声の利用許諾が適用されます。モデルの提供状況、地域、割り当ては Google アカウントによって決まります。

## 公式資料

[Google 音楽生成](https\://ai.google.dev/gemini-api/docs/music-generation)、[リアルタイム音楽](https\://ai.google.dev/gemini-api/docs/realtime-music-generation)。