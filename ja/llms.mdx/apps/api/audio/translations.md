# 音声翻訳

## API の説明

`POST /v1/audio/translations` は録音を受け取り、出力言語は**英語**です。任意の翻訳先言語パラメーターは受け付けません。認証は `Authorization: Bearer $SIMIROUTER_API_KEY`、リクエスト本体は `multipart/form-data` です。本ページは OpenAI 公式 Audio Translations API を参考にしています。アカウントには対応モデルのチャネルが必要です。

<Callout type="warn" title="エンドポイントとモデルは 2027-02-26 に終了">
  OpenAI は `/v1/audio/translations` と `whisper-1` を非推奨とし、2027-02-26 に終了します。代替は Realtime API の `/v1/realtime/translations` と `gpt-realtime-translate` で、別途の実装変更が必要です。このページは移行前の参考としてのみ残しています。
</Callout>

## リクエストパラメータ

| フィールド            | 型      | 必須  | 説明                                                     |
| ---------------- | ------ | --- | ------------------------------------------------------ |
| file             | file   | はい  | 録音ファイル本体。flac、mp3、mp4、mpeg、mpga、m4a、ogg、wav、webm。      |
| model            | string | はい  | このエンドポイントは whisper-1 を使用します。通常の文字起こしモデルに置き換えることはできません。 |
| prompt           | string | いいえ | 英語の用語または文脈のヒント。                                        |
| response\_format | string | いいえ | json（デフォルト）、text、srt、verbose\_json、vtt。                |
| temperature      | number | いいえ | 0–1。デフォルトは 0。                                          |

## 戻り値

JSON は `text` に英訳を返します。`verbose_json` には追加で `duration`（秒）、`language`（english）、`segments[]` が含まれます。字幕形式は字幕テキストを直接返すため、JSON として解析できません。このエンドポイントは単一のファイルリクエストであり、stream パラメーターはありません。リアルタイム翻訳は別のセッション API です。

```json
{"text":"Welcome to today's meeting."}
```

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

`speech.wav` を用意し、`SIMIROUTER_API_KEY` を設定します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/translations'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'whisper-1', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/translations";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "whisper-1");
      form.append("response_format", "json");
      const body = form;
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.dwchainless.com/v1/audio/translations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=whisper-1" \
      -F "response_format=json"
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
      "bytes"
      "mime/multipart"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      var buffer bytes.Buffer
      writer := multipart.NewWriter(&buffer)
      source, err := os.Open("speech.wav"); check(err)
      part, err := writer.CreateFormFile("file", "speech.wav"); check(err)
      _, err = io.Copy(part, source); source.Close(); check(err)
      check(writer.WriteField("model", "whisper-1"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/translations", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", writer.FormDataContentType())
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
| 413                   | ファイルがアップロード上限を超えています。圧縮するか小さいファイルを使用してください。                            |
| 429                   | レートまたは割り当て制限。残高不足とバックオフ可能な制限を区別してください。                                 |
| 500 / 502 / 503 / 504 | サービスまたは上流異常。リクエスト ID を保持して一時的な障害は間隔を空けて再試行し、同じ有料リクエストを無制限に繰り返さないでください。 |

エラー本文の `error.message`、`error.type`、`error.code` は HTTP ステータスより具体的な原因を示します。このインターフェースは同期リクエストです。タスク ID やポーリング段階はありません。エラー本文を文字起こし結果として保存しないでください。

## 公式資料

[OpenAI Create translation](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create)。