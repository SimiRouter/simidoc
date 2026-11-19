# Seedance 動画タスクの作成

## API の説明

`POST https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks`，`Authorization: Bearer $ARK_API_KEY`。本文は JSON。以下は公式への直接接続プロトコルであり、**ゲートウェイの** SimiRouter `/v1/video/generations` マッピングを保証するものではありません。

## リクエストパラメータ

| フィールド                     | 型         | 必須   | 説明                                                                                               |
| ------------------------- | --------- | ---- | ------------------------------------------------------------------------------------------------ |
| model                     | string    | はい   | 利用を有効化した Seedance モデル ID または推論エンドポイント ID。                                                        |
| content                   | object\[] | はい   | テキストと、モデルが対応する画像／動画／音声のコンテンツ項目。                                                                  |
| content\[].type           | string    | はい   | text、image\_url、video\_url、audio\_url、draft\_task。モデルの機能に応じて使用。                                  |
| content\[].draft\_task.id | string    | 条件付き | type=draft\_task のときの草稿タスク ID。草稿から正式な動画を生成する際に使用します。                                             |
| content\[].text           | string    | 条件付き | type=text のプロンプト。                                                                                |
| content\[].image\_url.url | string    | 条件付き | アクセス可能な画像、またはモデルが許可する data URL。                                                                  |
| content\[].role           | string    | いいえ  | first\_frame、last\_frame、reference\_image など。モデルと素材タイプに応じて使用。                                    |
| resolution                | string    | いいえ  | モデルが許可する解像度：480p、720p、1080p、4k（モデルによる）。草稿は 480p のみ対応します。                                         |
| ratio                     | string    | いいえ  | 16\:9、9\:16、1\:1、adaptive など。具体的な対応状況はモデル表に従います。                                                 |
| duration                  | integer   | いいえ  | 動画の長さ。範囲はモデルごとに異なります。自動長に対応するモデルは -1 を使用可能。                                                      |
| frames                    | integer   | いいえ  | フレーム数の指定。対応モデルのみ利用可能。duration と同時に指定した場合は frames が優先されます。                                        |
| generate\_audio           | boolean   | いいえ  | 音声トラックを生成するかどうか。音声付きモデルのみ対応。                                                                     |
| watermark                 | boolean   | いいえ  | 明示的な透かし設定。合成コンテンツの表示要件を順守する必要があります。                                                              |
| seed                      | integer   | いいえ  | 乱数シード。ピクセル単位の再現性は保証されません。                                                                        |
| return\_last\_frame       | boolean   | いいえ  | 末尾フレームの画像返却を要求。                                                                                  |
| callback\_url             | string    | いいえ  | 状態変更の通知先。受信側は重複通知と順序の入れ替わりに対応する必要があります。                                                          |
| execution\_expires\_after | integer   | いいえ  | タスクの有効秒数。デフォルト 172800、範囲 3600–259200。                                                            |
| service\_tier             | string    | いいえ  | default / flex。対応範囲はモデルごとに異なります。                                                                 |
| draft                     | boolean   | いいえ  | 草稿動画を生成します。既定は false で、対応モデルは 480p のみ受け付けます。草稿から正式な動画を生成するには `content[].type=draft_task` を使用します。 |
| priority                  | integer   | いいえ  | 対応モデル／サービス階層のキュー優先度。すべての呼び出しには適用されません。                                                           |

この例は Seedance 2.5 を選択し、テキストのみの入力と短い動画のパラメーターを使用します。1.0 pro / 2.0 に変更する場合は、そのバージョンの機能に合わせてフィールドを削除・変更してください。マルチモーダル参照、音声、ドラフトがすべて利用可能とは限りません。

## 戻り値

作成に成功すると `id` が返されます。完成した動画ではありません。ID を保存し、[照会 API](/simidoc/ja/apps/api/video/seedance/status) で状態を確認します。

```json
{"id":"cgt-example"}
```

リクエストのタイムアウトは、サーバーに受理されていないことを意味しません。作成リクエストを自動で無制限に再送しないでください。コールバック受信側は、タスク ID に基づいて冪等に状態を更新してください。

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

公式の `ARK_API_KEY` を設定します。呼び出すと課金される可能性のあるタスクが作成されます。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks'
    headers = {'Authorization': 'Bearer ' + os.environ['ARK_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'doubao-seedance-2-5-260628', 'content': [{'type': 'text', 'text': '海边日落时，一艘白色帆船缓缓驶过，镜头平稳。'}], 'duration': 5, 'ratio': '16:9', 'generate_audio': True, 'watermark': True}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks";
      const headers = { "Authorization": "Bearer " + process.env.ARK_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $ARK_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "doubao-seedance-2-5-260628",
        "content": [
          {
            "type": "text",
            "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
          }
        ],
        "duration": 5,
        "ratio": "16:9",
        "generate_audio": true,
        "watermark": true
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
    }`)
      req, err := http.NewRequest("POST", "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("ARK_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## エラーコード

| HTTP ステータス            | 意味と対処                                               |
| --------------------- | --------------------------------------------------- |
| 400 / 422             | リクエスト項目、ファイル形式、モデルパラメータが不正。修正して再送。                  |
| 401                   | API Key がない、無効、または期限切れ。                             |
| 403                   | 現在のプロジェクトまたはモデルへの権限がありません。                          |
| 404                   | モデル、ルート、タスクが存在しません。アドレスと所属を確認。                      |
| 413 / 415             | アップロード過大、または未対応メディア型。                               |
| 429                   | レートまたは割り当て制限。残高不足とバックオフ可能な制限を区別。                    |
| 500 / 502 / 503 / 504 | サービスまたは上流異常。ID を保持し、作成がタイムアウトしたら受理済みか確認して重複生成を防ぎます。 |

Volcengine のエラーオブジェクトは `error.code`、`error.message` を使用し、リクエスト ID も保持します。タスク実行の失敗は照会結果も読み取る必要があります。作成時の HTTP ステータスから最終成功を推測しないでください。

Volcengine のエラーは `error.code`、`error.message` とリクエスト ID を使用します。タスクの生成失敗は照会結果の error フィールドも確認する必要があります。

## 公式資料

[Volcengine Ark タスク作成](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)、[公式チュートリアル](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh)。