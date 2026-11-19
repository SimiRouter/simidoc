# OpenAI 形式の画像 API

この節では OpenAI 形式を使用し、生成、編集、対話型画像生成、画像理解を区別します。まず 1 枚の呼び出しを完了し、その後で枚数を増やすかエージェントに接続してください。各処理には対応する画像機能を持つモデルが必要です。

## 呼び出し順序

1. **設定を準備する**\: [API キー管理](https://api.dwchainless.com/keys) でキーを作成し、[モデルと価格](https://api.dwchainless.com/ja/pricing/) から対応する完全なモデル ID をコピーします。リクエスト先はゲートウェイ `https://api.dwchainless.com`、ヘッダーは `Authorization: Bearer $API_KEY` です。
2. **エンドポイントを選ぶ**\: テキストから画像生成は `POST /v1/images/generations`、編集 / 画像から画像生成は `POST /v1/images/edits`、対話型画像生成は `POST /v1/responses`、画像理解は `POST /v1/chat/completions` です。
3. **まず最小リクエストを送る**\: 1 枚だけをストリーミングなしで要求し、認証、モデル、パラメータが有効であることを確認してから、枚数やサイズを増やすかエージェントに接続します。
4. **結果を読み取り検証する**\: `data[]` の Base64 をデコードするか URL をダウンロードし、ファイルが開けること、サイズと内容が要件を満たすことを確認してから使用ログを照合します。

完全なパラメータ、例、エラー処理は以下の各プロトコルページにあります。最初の呼び出しは[生成](/simidoc/ja/apps/api/images/openai/generations)から始めてください。

## リクエスト形式とパラメータ

| API           | リクエスト形式                                          | 主なパラメータ                                                 | 詳細                                 |
| ------------- | ------------------------------------------------ | ------------------------------------------------------- | ---------------------------------- |
| テキストから画像生成    | `POST /v1/images/generations`、JSON               | `model`、`prompt`。モデルに応じて `n`、`size`、`quality`           | [生成パラメータと 4 言語のコード](/simidoc/ja/apps/api/images/openai/generations) |
| 編集 / 画像から画像生成 | `POST /v1/images/edits`、JSON または multipart のいずれか | `model`、`prompt`、`images[]` またはファイル `image`。対応時は `mask` | [編集パラメータと 4 言語のコード](/simidoc/ja/apps/api/images/openai/edits)       |
| 対話型画像生成       | `POST /v1/responses`、JSON                        | `input`、画像生成ツールと対応モデルの設定                                | [対話型画像生成](/simidoc/ja/apps/api/images/openai/chat-format)           |
| 画像理解          | `POST /v1/chat/completions`、JSON                 | `messages` 内のテキストと `image_url` 項目                       | [画像理解](/simidoc/ja/apps/api/images/openai/vision)                   |

編集指示では「残すもの」と「変更するもの」を分けて説明します。スタイル変換、背景変更、要素の追加・削除は編集の目的であり、別の API ではありません。マスク、複数画像、透明背景にはモデルの対応が必要で、人物・商品・文字をピクセル単位で保持する保証はありません。

### 画像の仕様

`size` は `1024x1024` などのピクセル幅と高さであり、共通の `1K` / `2K` / `4K` 列挙値ではありません。対応サイズはモデルごとに異なります。`quality` は生成品質、`output_format` は PNG/JPEG/WebP の形式を制御し、解像度の代わりにはなりません。透明背景には `background: transparent` 対応モデルと PNG または WebP が必要です。

size の 3 通りの書き方、14 比率の早見表、1K/2K/4K の画像単位課金段階は[画像仕様と課金の概要](/simidoc/ja/apps/api/images)にまとめています。課金表は[モデルと料金](https://api.dwchainless.com/ja/pricing/)でこの方式を明示したモデルだけに適用され、すべての例示サイズへの対応を保証しません。

## レスポンスパラメータ

| フィールド / イベント                                          | 意味と処理                                                                        |
| ----------------------------------------------------- | ---------------------------------------------------------------------------- |
| Images `data[].b64_json`                              | GPT Image の Base64 画像。デコードしてバイナリで保存し、JSON 全体を PNG に改名しないでください。               |
| Images `data[].url`                                   | URL 出力に対応する旧モデルや互換モデルのみで返る場合があります。有効なうちにダウンロードし、GPT Image の必須項目とはみなさないでください。 |
| Images `usage`                                        | 任意の使用量情報。存在するだけで Token 課金とは限りません。                                            |
| `image_generation.completed` / `image_edit.completed` | Images のストリーム生成 / 編集の最終イベント。`partial_image` は途中のプレビューです。                     |
| Responses `output[]`                                  | 対話型生成の画像ツール出力に従い、Images の `data[]` を流用しません。                                  |
| Chat `choices[].message.content`                      | 画像理解によるテキスト分析であり、生成画像ではありません。                                                |

## 呼び出し例

### 設定の準備

[API Key 管理](https://api.dwchainless.com/keys)で Key を作り、[モデルと料金](https://api.dwchainless.com/ja/pricing/)から現在の Key で使える完全な画像モデル ID をコピーします。権限、グループ、残高も確認してください。

| 変数          | 用途                                                           |
| ----------- | ------------------------------------------------------------ |
| `API_KEY`   | 必須。例に直接記入、プロンプト、ソース、画面写真、Git に含めません。                         |
| `MODEL`     | 必須。生成と編集それぞれのエンドポイントに対応するか確認します。                             |
| `API_URL`   | 完全なリクエスト URL。例ではゲートウェイ `https://api.dwchainless.com` を使用します。 |
| `IMAGE_URL` | 編集例で使う HTTPS 画像 URL。サーバーから PNG、JPEG、WebP にアクセスできる必要があります。    |

[生成例](/simidoc/ja/apps/api/images/openai/generations)と[編集例](/simidoc/ja/apps/api/images/openai/edits)には Python、Node.js、curl、Go があります。1 言語を選び、最初は 1 枚の非ストリームリクエストだけを送ります。Python 3.8+ と Node.js 20+ の例は標準ライブラリのみを使用します。生成コードを `generate.py` / `generate.mjs`、編集コードを `edit.py` / `edit.mjs` に保存し、`python3 generate.py` または `node generate.mjs` などで実行します。Python と Node.js の編集例はいずれも JSON `images[].image_url` を使用し、multipart は使いません。

### エージェントによる生成 Demo

エージェントにはローカルスクリプト実行、許可済み画像の読み取り、応答確認の機能が必要です。このページは Skill をインストールせず、テキスト専用クライアントにツール機能を付与しません。既存の接続を維持し、無断でサービスを変更しないでください。

```text
Read this OpenAI image protocol page and its generation reference first. Use the
SimiRouter request URL in API_URL (default gateway https://api.dwchainless.com) and the
image model in MODEL. Set API_KEY directly in the example; never print, paste, commit,
or store it in source files. For this one approved request, use POST
/v1/images/generations with n=1, size=1024x1024, stream=false and output_format=png only
after verifying the model supports these parameters. Image brief: a calm blue library
with a small robot reading, watercolor illustration, no lettering. Print the returned
JSON and inspect data[].b64_json; do not write an image file. Confirm that
data[].b64_json contains non-empty Base64 data before reporting completion. Do not
install remote skills, switch providers/models/billing groups, increase size/count,
write files, or retry after timeout or ambiguous failure without approval. If the
request or validation fails, report a redacted error, not success.
```

### エージェントによる編集 Demo

参考画像の処理権限を確認し、個人情報や機密情報を点検してください。必要なファイルだけを許可します。「保持する」という指示は目標であり、ピクセル単位の保証ではありません。

```text
Read this OpenAI image protocol page and its editing reference first. Set API_KEY,
MODEL, and API_URL directly in the example; use the configured SimiRouter request URL;
never reveal the key or change the existing connection. Use only the authorized HTTPS
image URL in IMAGE_URL. Use POST /v1/images/edits with JSON images[]; do not set
multipart Content-Type or send local files. Keep the subject and layout; change only the
background to pale blue. Request one PNG at 1024x1024 with stream=false only if the
selected model supports it. Print the returned JSON and inspect data[].b64_json; do not
write an image file. Confirm that data[].b64_json contains non-empty Base64 data and
report any unmet requirement. Do not upload unrelated files, change
size/count/model/provider, install remote skills, or retry automatically after an error
or timeout. Ask before another paid request.
```

## 保存と完了の判定

* HTTP 状態、最終画像フィールド、デコード結果、実際の形式を確認します。拡張子の変更は変換になりません。失敗時は今回新規作成した無効ファイルだけを削除し、既存ファイルは残します。
* 最初は 1 枚の非ストリームリクエストにします。ストリームでは該当する `completed` を待ち、複数画像はインデックス別に処理します。終端がなければプレビューを完成扱いにできません。標準 Images はタスク ID を先に返してポーリングする汎用非同期キューではありません。
* ファイルの存在、表示、サイズ、内容を確認してから使用ログを照合します。HTTP 成功やエージェントの発言だけでは保存完了とはいえません。

## エラー、再試行、料金

400 はモデルとパラメータ、401 は Key、403/404 は権限・モデル ID・パス、429 は残高とレート制限を確認します。5xx、タイムアウト、ストリーム切断後はログと既存の結果を先に調べ、重複生成や課金を防ぐため自動再送しません。エラーとリクエスト ID は機密部分を除いて報告し、Key、画像の完全な Base64、非公開画像の内容を出力しません。

実際の生成・編集には料金が発生する場合があります。送信前にモデル、サイズ、枚数、保存先を確認し、`n` の増加、上位サイズ、モデル変更、再試行では改めて承認を得てください。並行リクエストは個別にレート、タイムアウト、料金を管理します。`n` は 1 リクエストの枚数で、並行数ではありません。最終料金は現在のモデル料金と使用ログに従います。

## 公式資料

* [OpenAI 画像生成ガイド](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Images API](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [OpenAI 画像入力](https\://developers.openai.com/api/docs/guides/images-vision)