# Google Lyria 音楽生成

以下のページは Google 公式 API に沿って整理しています。SimiRouter はこの機能をまだ提供していないため、例はすべて Google AI Studio Gemini API に直接接続し、`https://generativelanguage.googleapis.com` と Google API キーを使用します。Vertex AI には別のプロトコルが必要で、このページでは検証していないため、アドレスだけを直接置き換えないでください。

## API の説明

`POST https://generativelanguage.googleapis.com/v1beta/interactions` を使用し、認証には `x-goog-api-key: $GEMINI_API_KEY` を使用します。Lyria は Interactions を使用し、generateContent でも `/audio/speech` でもありません。

| モデル                    | 用途                  | 長さと出力                                   |
| ---------------------- | ------------------- | --------------------------------------- |
| `lyria-3-clip-preview` | クリップ、ループ、短時間の試聴     | 固定 30 秒。デフォルトは MP3。                     |
| `lyria-3.5`            | ヴァース、コーラス、ブリッジを含む楽曲 | プロンプトで数分間の楽曲を指定。デフォルトは MP3 で、WAV も要求可能。 |

## リクエストパラメータ

| フィールド                      | 型              | 必須   | 説明                                                  |
| -------------------------- | -------------- | ---- | --------------------------------------------------- |
| model                      | string         | はい   | 上記 Lyria モデルのいずれか。                                  |
| input                      | string / array | はい   | 音楽の説明、または text/image のマルチモーダルコンテンツ配列。               |
| input\[].text              | string         | 条件付き | ジャンル、テンポ、雰囲気、楽器、歌詞、構成。                              |
| input\[].mime\_type / data | string         | 条件付き | 画像入力は image 項目、実際の MIME、Base64 data を使用。            |
| response\_format           | object         | いいえ  | \{"type"\:"audio"} で WAV を要求できます。実際の MIME に従ってください。 |

長さの指定は厳密な保証ではありません。特定の歌手の模倣を要求するより、ジャンルや楽器の特徴を説明する方が安全な利用に適しています。

## 戻り値

| フィールド                              | 説明                                              |
| ---------------------------------- | ----------------------------------------------- |
| `id` / `status`                    | Interaction の識別子と処理状態。                          |
| `steps[].content[]`                | model\_output は音声、歌詞、曲構成を含みます。項目ごとに解析する必要があります。 |
| 音声項目 `type` / `mime_type` / `data` | type=audio。data は Base64 であり、URL ではありません。       |
| テキスト項目 `text`                      | 歌詞、構成、その他のテキスト。                                 |

SDK の `output_audio` / `output_text` は便宜的なプロパティです。複雑に交互配置された結果は steps を走査してください。最後の区間だけを取得すると内容が欠落します。以下はレスポンス構造の抜粋です。

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"[Instrumental]"},{"type":"audio","mime_type":"audio/mpeg","data":"<Base64音频>"}]}]}
```

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

次を設定します：`GEMINI_API_KEY`。この例は JSON を返し、audio 項目の data をデコードして MP3 として保存します。model を `lyria-3.5` に変更すると、楽曲全体を生成できます。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY'], 'Api-Revision': '2026-05-20'}
    response = requests.request('POST', url, headers=headers, json={'model': 'lyria-3-clip-preview', 'input': '30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY, "Api-Revision": "2026-05-20" };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "lyria-3-clip-preview",
      "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
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
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Api-Revision: 2026-05-20" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "lyria-3-clip-preview",
        "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
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
      "model": "lyria-3-clip-preview",
      "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Api-Revision", "2026-05-20")
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

| HTTP ステータス            | 意味と対処                                                                  |
| --------------------- | ---------------------------------------------------------------------- |
| 400                   | リクエスト項目またはモデルパラメータが不正。修正してから再送してください。                                  |
| 401                   | API Key がない、無効、または期限切れ。                                                |
| 403                   | 現在のプロジェクトまたはモデルへの権限がありません。                                             |
| 404                   | モデルまたはルートが存在しません。アドレスとモデル ID を確認してください。                                |
| 429                   | レートまたは割り当て制限。残高不足とバックオフ可能な制限を区別してください。                                 |
| 500 / 502 / 503 / 504 | サービスまたは上流異常。リクエスト ID を保持して一時的な障害は間隔を空けて再試行し、同じ有料リクエストを無制限に繰り返さないでください。 |

Google のエラーオブジェクトは `error.code`、`error.status`、`error.message` を使用します。HTTP の数字だけで発生元を判断しないでください。このインターフェースは同期リクエストです。タスク ID やポーリング段階はありません。エラー本文を音声データとしてデコードしないでください。

## 公式資料

[Google Lyria 音楽生成](https\://ai.google.dev/gemini-api/docs/music-generation)、[Interactions](https\://ai.google.dev/gemini-api/docs/interactions)。