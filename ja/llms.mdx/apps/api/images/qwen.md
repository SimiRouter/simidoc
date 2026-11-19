# Qwen ネイティブ画像 API

このセクションでは Qwen ネイティブのリクエスト本文を使いますが、呼び出しは統一して当サイトのゲートウェイ経由で行います。`API_URL` は `https://api.dwchainless.com/v1/images/...`、認証には当サイトの `API_KEY` を使います。リクエストパラメータは `model`、`input.messages`、`parameters` をそのまま使い、返却は統一して `data[]` です。まず単発の 1 枚呼び出しを完了してから、枚数を増やすかエージェントに接続します。

## リクエスト形式とパラメータ

| API           | リクエスト形式                            | 主なパラメータ                                                | 詳細ドキュメント                           |
| ------------- | ---------------------------------- | ------------------------------------------------------ | ---------------------------------- |
| テキストから画像生成    | `POST /v1/images/generations`、JSON | `model`、`input.messages[].content[].text`、`parameters` | [生成パラメータと 4 言語のコード](/simidoc/ja/apps/api/images/qwen/generations) |
| 編集 / 画像から画像生成 | `POST /v1/images/edits`、JSON       | `content[]` 内の `image` と 1 つの `text`、`parameters`      | [編集パラメータと 4 言語のコード](/simidoc/ja/apps/api/images/qwen/edits)       |

このページの 2.0 シリーズの例では、`input.messages` に 1 つの `user` メッセージを入れ、主体、構図、スタイル、描画する文字をテキストで記述します。編集時は権限を取得済みの画像 URL またはモデルが対応する data URL を追加します。背景置換、スタイル変換、画像内文字の修正、複数画像の合成は編集の目的であり、OpenAI multipart フィールドを別途設けず、細部のピクセル単位の保持も保証しません。

### 画像仕様

サイズは `parameters.size` に指定し、形式は `width*height`、例えば `"2048*2048"` です。`"2048x2048"` や `"2K"` ではありません。2.0 シリーズは総画素数の範囲でサイズを制約するため、具体的な入力画像、幅と高さ、出力の制限はモデルごとに確認する必要があります。総画素数の制限は長辺の制限と同じではありません。

| 当サイトの 3 段階の画像単位課金 | リクエストサイズの長辺           | ピクセル例     |
| ----------------- | --------------------- | --------- |
| 1K                | ≤ 1024 ピクセル           | 1024×1024 |
| 2K                | > 1024 かつ ≤ 2048 ピクセル | 1536×1024 |
| 4K                | > 2048 ピクセル           | 2560×1440 |

この表は当サイトの特定モデルの課金区分を説明するだけで、モデルが `1K` / `2K` / `4K` パラメータを受け入れることを示すものではありません。当サイト経由の呼び出しは[モデルと料金](https://api.dwchainless.com/ja/pricing/)で精算し、[画像仕様と課金の概要](/simidoc/ja/apps/api/images)も参照してください。ピクセル数が大きければ文字や細部が正しくなる保証はなく、目標の仕様に対応しない場合は黙って置き換えるのではなくエラーを返すべきです。

## 戻り値パラメータ

| 返却フィールド                 | 意味と処理                                              |
| ----------------------- | -------------------------------------------------- |
| `created`               | レスポンス生成のタイムスタンプ。                                   |
| `data[].url`            | 最終画像の URL。有効期限はチャネルが決めるため、速やかにダウンロードして保存する必要があります。 |
| `data[].b64_json`       | 一部のチャネルは純粋な Base64 を返します。存在する場合はそのままデコードして保存できます。  |
| `data[].revised_prompt` | チャネルが書き換えたプロンプト。存在しない場合があります。                      |
| `error` / `message`     | エラーコードと説明。HTTP が成功しても業務エラーと画像の存在を確認してください。         |

リクエスト本文は Qwen ネイティブの構造で、返却は統一して `data[]` です。他のチャネルの `prompt`、multipart、非同期の `task_id` プロトコルをそのまま流用しないでください。モデル ID は当サイトのチャネルが実際に提供する名前と一致させる必要があります。

## 呼び出し例

### 設定の準備

[モデルと料金](https://api.dwchainless.com/ja/pricing/)で利用可能なモデルと残高を確認し、当サイトで作成した Key を使用します。`API_URL` は常に当サイトのゲートウェイを指し、ワークスペース ID、リージョンのドメイン、Bailian 公式 Key は必要ありません。

| 設定          | 用途                                                                              |
| ----------- | ------------------------------------------------------------------------------- |
| `API_KEY`   | 当サイトの Key。サンプルに直接記入し、プロンプト、コード、スクリーンショット、Git に貼り付けない。                           |
| `API_URL`   | 当サイトのゲートウェイの完全なリクエストアドレス。例：`https://api.dwchainless.com/v1/images/generations`。 |
| `model`     | 既存の例は `qwen-image-2.0-pro`。当サイトのチャネルがこのモデルと必要な機能に対応していることを先に確認。                 |
| `IMAGE_URL` | 編集例で使う、権限を取得済みでクラウドからアクセス可能な HTTP(S) 画像アドレス。ローカルパスや localhost ではない。             |

[生成例](/simidoc/ja/apps/api/images/qwen/generations)と[編集例](/simidoc/ja/apps/api/images/qwen/edits)はいずれも Python、Node.js、curl、Go を提供します。既存のコードは 1 回リクエストを送って JSON を表示し、**画像を自動ダウンロードしません**。Python コードは `generate.py` / `edit.py` に保存して `python3 generate.py` / `python3 edit.py` を実行し、Node.js は `generate.mjs` / `edit.mjs` に保存して `node generate.mjs` / `node edit.mjs` を実行します。対応するページの要件に従ってランタイムと変数を設定し、まず 1 枚だけリクエストした後、次の節に従って URL が指す実際の画像を保存します。

### エージェントによる生成 Demo

エージェントにはローカルスクリプト、ネットワークリクエスト、返却結果の確認能力が必要です。本ページは Skill のインストール指示ではなく、テキスト専用クライアントにこれらの能力を追加するものでもありません。

```text
Read this Qwen image protocol page and its generation reference first. Use the
existing API_KEY and API_URL from this site's gateway; never print, paste, commit,
or store the key in source files. Use the documented qwen-image-2.0-pro model only
after checking availability and pricing. For this one approved request, POST once
to /v1/images/generations with the native Qwen body: one user message, one text
content item, parameters.n=1 and size=1024*1024 if supported. Image brief: a calm
blue library with a small robot reading, watercolor illustration, no lettering.
Print the returned JSON and inspect data[].url or data[].b64_json; report the final
image URL without forwarding the API key. JSON or a URL alone is not a saved image.
Do not switch model/provider, increase size/count, write files, install remote
skills, or automatically retry an error or timeout. Ask before another paid request.
```

### エージェントによる編集 Demo

処理とアップロードの許可を得た画像だけを使用し、個人情報や営業秘密を先に確認してください。既存の例は URL を読み取るだけで、ローカルファイルを他のサービスへ自動的に公開アップロードすることはありません。

```text
Read this Qwen image protocol page and its editing reference first. Use the existing
API_KEY and API_URL from this site's gateway; never reveal the key or switch the
existing connection. Verify qwen-image-2.0-pro supports the edit. Use only the
authorized cloud-readable image in IMAGE_URL; do not upload unrelated local files or
publish a file. POST once to /v1/images/edits with the native Qwen body: one user
message containing that image item and one text instruction: keep the subject and
layout; change only the background to pale blue. Set parameters.n=1 and size=1024*1024
only if supported. Do not use OpenAI multipart or mask fields. Check the completed
business result, inspect data[].url or data[].b64_json without forwarding the API key,
and report it. Do not write files, change model/size/count/provider, install remote
skills, or retry automatically. If any step fails or the requested edit is not met,
report a redacted error instead of claiming success.
```

## 保存と完了の基準

* 同期レスポンスはポーリングタスクではありません。本セクションでは `task_id` や `X-DashScope-Async` を使用しません。他のモデルの非同期プロトコルを混ぜず、ストリーミングイベントを完了基準にしないでください。
* HTTP と業務エラー、終了理由、実際の画像項目を確認してから画像 URL を走査します。URL の有効期限は限られているため、できるだけ早くダウンロードしてください。JSON、アドレス、エージェントの口頭結論はいずれもファイルが保存済みであることを意味しません。
* ダウンロード時はレスポンスステータス、内容、ファイルヘッダーを確認し、エラーページを PNG に改名しないでください。当サイトの Key を結果保存用ドメインへ送信しないでください。元のファイルは保持し、失敗時は今回作成した無効な出力だけを削除します。
* ファイルが存在し、開けて、サイズと内容が要件を満たすことを確認し、当サイトの請求または使用ログでリクエストと費用を照合します。複数画像は 1 枚ずつ確認し、枚数を補うために自動で再呼び出ししないでください。

## エラー、再試行と料金

パラメータエラーではまず `model`、メッセージ構造、`size`、入力画像を確認します。認証エラーでは当サイトの Key とモデル権限を先に照合します。残高やレート制限のエラーではアカウント状態を先に確認します。タイムアウト、5xx、結果が不明な場合は呼び出しログと既存ファイルを先に調べ、自動再送は行わず、重複生成や二重課金を避けます。報告するのは秘匿化したエラーだけとし、キー、完全な Base64、非公開画像を出力しません。

実際の生成と編集には費用が発生する場合があります。呼び出し前にモデル、サイズ、枚数、出力先を確認してください。追加、仕様のアップグレード、再試行には改めて確認が必要です。並行リクエストはそれぞれレート制限、タイムアウト、費用を管理し、`n` は 1 リクエストあたりの数量です。最終的な課金は当サイトのルールと請求に基づきます。

## 公式リファレンス

* [Qwen-Image 生成](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api)
* [Qwen-Image 編集](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api)