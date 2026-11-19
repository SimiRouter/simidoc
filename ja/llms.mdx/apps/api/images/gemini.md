# Gemini 画像 API

この節は Gemini GenerateContent のネイティブ `contents/parts` 形式を使用します。生成と編集には画像出力モデルが必要です。通常のテキストモデルにパラメータを追加しても画像生成はできません。まず 1 枚の処理を完了してから、枚数を増やすかエージェントに接続します。

## リクエスト形式とパラメータ

| API           | リクエスト形式                                            | 主なパラメータ                                             | 詳細                                       |
| ------------- | -------------------------------------------------- | --------------------------------------------------- | ---------------------------------------- |
| テキストから画像生成    | `POST /v1beta/models/{model}:generateContent`、JSON | `contents[].parts[].text`、`generationConfig`        | [生成パラメータと 4 言語のコード](/simidoc/ja/apps/api/images/gemini/generate)          |
| 編集 / 画像から画像生成 | 同じ `generateContent`                               | `text` と独立した画像 Part：`inlineData` または対応する `fileData` | [編集パラメータと 4 言語のコード](/simidoc/ja/apps/api/images/gemini/edits)             |
| 画像理解          | 同じ `generateContent`                               | 画像と質問。画像出力ではなくテキスト分析が目的                             | [Gemini メディア認識](/simidoc/ja/apps/api/chat/gemini-media) |

生成はテキストだけを送り、編集では参考画像を加えて残す部分と変更部分を説明します。スタイル変換、背景変更、複数画像の組み合わせは編集の目標であり、独立した `/images/edits` ではありません。GenerateContent の `contents`、`candidates` と Interactions の `input`、`steps`、`response_format` は異なり、混在できません。

### 画像の仕様

対応モデルでは `generationConfig.imageConfig.aspectRatio` に `1:1` などの比率、`generationConfig.imageConfig.imageSize` に `1K`、`2K`、`4K` などの対応解像度を設定します。全 Gemini 画像モデルの共通機能ではなく、OpenAI の `size` に置き換えられません。実ピクセル数は比率とモデルに依存し、形式は実際の MIME で判断します。

| 当サイトの画像単位課金区分 | リクエストサイズの長辺        | ピクセル例     |
| ------------- | ------------------ | --------- |
| 1K            | 1024 ピクセル以下        | 1024×1024 |
| 2K            | 1024 超、2048 ピクセル以下 | 1536×1024 |
| 4K            | 2048 ピクセル超         | 2560×1440 |

この表は当サイトの一部モデルに使う課金基準で、Google の解像度名称の統一定義ではありません。[モデルと料金](https://api.dwchainless.com/ja/pricing/)で明示した場合だけに適用し、Token 課金や別料金方式には使いません。高解像度でも文字や細部の正確性は保証されません。未対応の仕様では失敗を報告し、無断で小さくしないでください。詳細は[画像仕様と課金の概要](/simidoc/ja/apps/api/images)を参照してください。

## レスポンスパラメータ

| フィールド                                          | 意味と処理                                          |
| ---------------------------------------------- | ---------------------------------------------- |
| `candidates[]`                                 | 候補一覧。フィルタや失敗で使用可能な画像がない場合があります。                |
| `candidates[].content.parts[]`                 | テキストと画像を順に走査し、先頭が画像とは仮定しません。                   |
| `parts[].inlineData.mimeType` / `.data`        | 画像の実 MIME と純粋な Base64。MIME に応じた拡張子でデコード・保存します。 |
| `parts[].thought` / `.thoughtSignature`        | 思考中の画像を最終結果にせず、複数ターン編集では不透明な署名を保持します。          |
| `candidates[].finishReason` / `promptFeedback` | 正常完了とフィルタを確認し、HTTP 200 だけで成功にしません。             |
| `usageMetadata`                                | 任意の使用量情報。料金は適用される価格方式とログに従います。                 |

## 呼び出し例

### 設定の準備

[API Key 管理](https://api.dwchainless.com/keys)で Key を作り、[モデルと料金](https://api.dwchainless.com/ja/pricing/)から利用可能で GenerateContent 画像出力に対応する完全なモデル ID をコピーします。グループ、残高、編集能力も確認してください。

| 変数             | 用途                                                              |
| -------------- | --------------------------------------------------------------- |
| `API_KEY`      | 必須。例に直接記入、プロンプト、コード、画面写真、Git に入れません。                            |
| `MODEL`        | 必須。パスに使用する Gemini 画像モデル名。                                       |
| `API_URL`      | 完全なリクエスト URL。例ではゲートウェイ `https://api.dwchainless.com` を使用します。    |
| `IMAGE_BASE64` | 許可済み画像の純粋な Base64（`data:` 接頭辞なし）に置き換えます。形式とサイズは選択したモデルの要件に従います。 |

[生成例](/simidoc/ja/apps/api/images/gemini/generate)と[編集例](/simidoc/ja/apps/api/images/gemini/edits)には Python、Node.js、curl、Go があります。1 言語を選び、最初は 1 回の非ストリーム呼び出しにします。Python を `generate.py` / `edit.py` に保存し、`python3 generate.py` / `python3 edit.py` で実行します。Node.js 例はトップレベル await（ESM）なので、`generate.mjs` / `edit.mjs` に保存し、`node generate.mjs` / `node edit.mjs` で実行します。

### エージェントによる生成 Demo

エージェントにはローカルスクリプト実行、応答確認能力が必要です。リモート Skill のインストールや既存接続の変更は行わず、テキスト専用クライアントでは実行できません。

```text
Read this Gemini protocol page and the GenerateContent image generation reference first.
Use the configured SimiRouter request URL in API_URL (default gateway
https://api.dwchainless.com) and MODEL. Set API_KEY directly in the example; never
print, paste, commit, or store it in source files. For this one approved task, call POST
/v1beta/models/{model}:generateContent once, non-streaming, Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. with a text Part describing a calm blue library with a small robot reading,
watercolor, no lettering. Request one image; use imageConfig aspectRatio=1:1 and
imageSize=1K only if the model supports them. Do not invent an n parameter or mix
Interactions fields into GenerateContent. After the response, read only completed,
non-thought inlineData from parts; decode the Base64 in memory and report any unmet
requirement; do not write an image file. Do not switch providers/models/billing groups,
increase size/count, write files, install remote skills, or retry an ambiguous failure
without approval. Report a redacted error instead of false success.
```

### エージェントによる編集 Demo

許可済み参考画像だけを読み取り、個人情報や機密を確認します。複数ターン編集には完全なモデル応答文脈が必要で、署名を勝手に捨てないでください。「保持する」はピクセル単位の保証ではありません。

```text
Read this Gemini protocol page and its image editing reference first. Use the existing
API_KEY, MODEL and configured SimiRouter request URL; never reveal credentials or change
the existing connection. Read only the authorized local image, encode it as pure Base64,
and put it in IMAGE_BASE64. Submit its inlineData Part alongside the text instruction
through POST /v1beta/models/{model}:generateContent. Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. Keep the subject and layout; change only the background to pale blue. Request one
image, non-streaming; use aspectRatio=1:1 and imageSize=1K only if supported. Do not use
OpenAI multipart or mask fields. After the response, read only completed, non-thought
inlineData from parts; decode the Base64 in memory and report any unmet requirement; do
not write an image file. Preserve opaque signatures for later turns. Do not upload
unrelated files, overwrite results, change model/size/count/provider, install remote
skills, or retry automatically. Ask before any additional paid request.
```

## 保存と完了の判定

* HTTP 状態、`finishReason`、画像内容を確認します。テキストのみ、フィルタ、最終画像なし、形式不一致は未完了として報告し、JSON 全体を画像として保存しません。
* Base64 を厳格にデコードし、実形式と MIME、表示できること、サイズと内容を確認します。既存ファイルを保持し、失敗時は今回新規作成した無効出力だけを削除します。
* `streamGenerateContent?alt=sse` は対応モデルのみで使用し、任意の断片を最終画像とはみなしません。`generateContent` は同期の完全結果で、汎用タスク ID のポーリングではありません。Google Batch は別サービスです。
* 複数画像は項目ごとに保存して枚数を確認します。「1 枚」と書いても全モデルが厳密に 1 枚返す保証はなく、不足を補うために無断で再送しません。

## エラー、再試行、料金

400 はモデル・フィールド・参考画像、401/403 は権限、404 はモデルとパス、429 は残高と制限を確認します。タイムアウト、5xx、完全な終端がない場合はログと保存済みファイルを先に確認し、自動再送しません。機密を除いたエラーとリクエスト ID だけを報告し、Key、完全な Base64、非公開画像の内容は出力しません。

生成・編集には料金が発生する場合があります。モデル、仕様、枚数、保存先を事前確認し、上位仕様、枚数増加、モデル変更、再試行では承認を得てください。並行リクエストは個別にレート、タイムアウト、料金を管理します。使用量フィールドがあっても Token 課金とは限りません。最終料金は現在の価格と使用ログに従います。

## 公式資料

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google 画像生成・編集](https\://ai.google.dev/gemini-api/docs/image-generation)