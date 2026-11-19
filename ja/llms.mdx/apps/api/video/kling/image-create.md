# Kling 画像から動画生成

## API の説明

`POST https://api-singapore.klingai.com/image-to-video/kling-3.0`。認証は `Authorization: Bearer $KLING_API_KEY`、本文は JSON です。例は Kling 公式新版を使用しており、SimiRouter の `/kling/v1/videos/...` の旧マッピングではありません。

## リクエストパラメータ

| フィールド                           | 型         | 必須   | 説明                                            |
| ------------------------------- | --------- | ---- | --------------------------------------------- |
| contents                        | object\[] | はい   | 画像、テキスト、エレメントなどの入力内容。                         |
| contents\[].type                | string    | はい   | prompt、first\_frame、last\_frame などの対応タイプ。     |
| contents\[].text                | string    | 条件付き | prompt 項目の動き、カメラワーク、内容の指示。                    |
| contents\[].url                 | string    | 条件付き | first\_frame / last\_frame のアクセス可能な画像 URL。    |
| settings.resolution             | string    | いいえ  | 720p（デフォルト）、1080p、4k。モデルの権限に応じて使用。            |
| settings.duration               | integer   | いいえ  | デフォルトは 5 秒。現在の 3.0 の参考仕様では 3–15 秒。            |
| settings.audio                  | string    | いいえ  | off（デフォルト）または native。ネイティブ音声トラックを生成。          |
| settings.multi\_shot            | boolean   | いいえ  | デフォルトは true。この例は false で単一ショットを使用。            |
| options.callback\_url           | string    | いいえ  | タスク状態のコールバック。安全な受信と冪等処理は独自に実装が必要。             |
| options.external\_task\_id      | string    | いいえ  | アカウント内で一意のカスタムタスク ID。照会に使用し、システム ID を置き換えません。 |
| options.watermark\_info.enabled | boolean   | いいえ  | 透かし付きの結果も提供するかどうか。独自の透かしは未対応。                 |

フィールドが存在するだけでは、異なるモデルの機能制限を判断できません。複数ショットのプロンプトは公式の shot 構文に従い、各ショットの長さの合計を総再生時間と一致させてください。画像から動画生成の先頭／末尾フレーム、エレメント数、素材形式の制限は、現在のモデル説明に従ってください。

## 戻り値

```json
{"code":0,"message":"Success","request_id":"request_example","data":{"id":"task_example","status":"submitted","create_time":1780000000000,"update_time":1780000000000}}
```

`data.id` は照会に使うシステムタスク ID です。`data.status` は submitted、processing、succeeded、failed のいずれかです。タイムスタンプの単位はミリ秒です。作成レスポンスに完成した動画は含まれません。旧版の `data.task_id` や `task_status` を読み取らないでください。

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

Kling 公式の `KLING_API_KEY` を設定します。呼び出すと課金対象のタスクが作成されます。作成後は [タスク照会](/simidoc/ja/apps/api/video/kling/image-status) で状態を確認します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api-singapore.klingai.com/image-to-video/kling-3.0'
    headers = {'Authorization': 'Bearer ' + os.environ['KLING_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'contents': [{'type': 'prompt', 'text': '镜头缓缓拉远，画面保持稳定。'}, {'type': 'first_frame', 'url': 'https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png'}], 'settings': {'resolution': '720p', 'duration': 5, 'audio': 'off', 'multi_shot': False}}, timeout=180)
    response.raise_for_status()
    result = response.json()
    if result.get("code") != 0:
        raise RuntimeError(result)
    print(result)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api-singapore.klingai.com/image-to-video/kling-3.0";
      const headers = { "Authorization": "Bearer " + process.env.KLING_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "contents": [
        {
          "type": "prompt",
          "text": "镜头缓缓拉远，画面保持稳定。"
        },
        {
          "type": "first_frame",
          "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
        }
      ],
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false
      }
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "https://api-singapore.klingai.com/image-to-video/kling-3.0" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $KLING_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "contents": [
          {
            "type": "prompt",
            "text": "镜头缓缓拉远，画面保持稳定。"
          },
          {
            "type": "first_frame",
            "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
          }
        ],
        "settings": {
          "resolution": "720p",
          "duration": 5,
          "audio": "off",
          "multi_shot": false
        }
      }'
    python3 - "$response" <<'PY_CHECK'
    import json, sys
    from pathlib import Path
    result = json.loads(Path(sys.argv[1]).read_text())
    if result.get("code") != 0:
        raise SystemExit(json.dumps(result, ensure_ascii=False))
    print(json.dumps(result, ensure_ascii=False))
    PY_CHECK
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "encoding/json"
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
      "contents": [
        {
          "type": "prompt",
          "text": "镜头缓缓拉远，画面保持稳定。"
        },
        {
          "type": "first_frame",
          "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
        }
      ],
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false
      }
    }`)
      req, err := http.NewRequest("POST", "https://api-singapore.klingai.com/image-to-video/kling-3.0", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("KLING_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      var result struct { Code int `json:"code"` }
      check(json.Unmarshal(data, &result))
      if result.Code != 0 { panic(string(data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## エラーコード

| HTTP / 業務コード                     | 説明                                                 |
| -------------------------------- | -------------------------------------------------- |
| 200 / 0                          | リクエスト成功。生成が完了したかはタスクの status で判断。                  |
| 400 / 1201                       | パラメーターエラー。message を確認。                             |
| 404 / 1202、1203                  | メソッドが正しくないか、モデル／リソースが存在しません。                       |
| 401                              | API Key または旧版 JWT が無効です。                           |
| 400 / 1300、1301                  | プラットフォームポリシーまたはコンテンツの安全性制限。内容を修正し、確認せず繰り返さないでください。 |
| 429 / 1302、1303、1304             | レート、同時実行数、IP ポリシーの制限。                              |
| 500 / 5000；503 / 5001；504 / 5002 | サービスエラーまたはタイムアウト。request\_id を保存。                  |

HTTP 200 は業務上の成功を意味しません。まず code=0 を確認してから data を読み取ってください。

## 公式資料

[Kling 公式 API](https\://kling.ai/document-api/apiReference/model/imageToVideo)、[認証](https\://kling.ai/document-api/api/get-started/authentication)、[エラーコード](https\://kling.ai/document-api/api/get-started/error-codes)。