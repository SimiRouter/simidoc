# Sora タスクの照会（公式 API は提供終了）

**OpenAI 公式の Sora 2 と Videos API は 2026-09-24 に提供終了しました。** 以下は API 構造の参考情報であり、利用可能な呼び出し手順ではありません。SimiRouter に同名モデルやサードパーティーの互換実装がある場合、その提供元、機能、プロトコルは別途確認が必要です。OpenAI 公式への直接接続とは呼べません。

## API の説明

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID` は以前の公式リクエスト形式で、OpenAI Bearer Key を使用していました。現在、新しい本番リクエストを送信しないでください。

## リクエストパラメータ

| フィールド         | 型      | 必須 | 説明           |
| ------------- | ------ | -- | ------------ |
| video\_id（パス） | string | はい | 以前の作成タスク ID。 |

## 戻り値

以前の照会レスポンスは id、status、progress、model、created\_at、completed\_at、expires\_at、error などを含みます。completed の場合のみダウンロードできます。failed の原因は error.code/message から取得します。

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

**アーカイブ例です。現在も API が動作すると判断する根拠にはできません。** 以下は以前の HTTP 呼び出し構造を理解するためのものです。実際の Key で新規タスクをテストしないでください。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('GET', url, headers=headers, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      const response = await fetch(url, { method: "GET", headers, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID" \
      --fail-with-body \
      --max-time 180 \
      -X GET \
      -H "Authorization: Bearer $OPENAI_API_KEY"
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
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        req, err := http.NewRequest("GET", "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID", nil); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

公式サービスの提供終了後、成功レスポンスは保証できません。以前の API は HTTP 401/403 で認証と権限、404 でリソースの不存在、429 でレート制限を区別していました。生成失敗には error.code/message も含まれます。停止済みエンドポイントを無制限に再試行せず、エラー本文を MP4 として保存しないでください。

## 公式資料

[OpenAI 提供終了のお知らせ](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api)、[Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)。