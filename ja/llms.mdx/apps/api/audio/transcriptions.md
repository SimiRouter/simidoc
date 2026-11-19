# 音声文字起こし

## API の説明

`POST /v1/audio/transcriptions` を使用し、認証には `Authorization: Bearer $SIMIROUTER_API_KEY` を使用します。アップロードは `multipart/form-data` を使用し、boundary は HTTP ライブラリに生成させます。boundary のない Content-Type を手書きしないでください。

この API は元の言語を保持し、中国語を自動的に英語へ翻訳しません。対応形式は flac、mp3、mp4、mpeg、mpga、m4a、ogg、wav、webm です。ファイルサイズと録音時間は、モデルとチャネルの制限も受けます。

<Callout type="warn" title="一部モデルは 2027-02-26 に終了">
  `whisper-1`、`gpt-4o-transcribe`、`gpt-4o-mini-transcribe`（日付付きスナップショットを含む）は非推奨となり、2027-02-26 に終了します。`gpt-transcribe` を優先し、リアルタイムは `gpt-live-transcribe`、話者分離は `gpt-4o-transcribe-diarize` を使用してください。
</Callout>

## リクエストパラメータ

| フィールド                         | 型               | 必須   | 説明                                                                              |
| ----------------------------- | --------------- | ---- | ------------------------------------------------------------------------------- |
| file                          | file            | はい   | 音声ファイル本体。ファイルパス文字列や通常の URL ではありません。                                             |
| model                         | string          | はい   | gpt-transcribe、gpt-4o-transcribe、gpt-4o-mini-transcribe、whisper-1、または話者分離モデルなど。 |
| language                      | string          | いいえ  | 入力言語の ISO-639-1 コード。zh、en など。                                                   |
| languages\[]                  | string\[]       | いいえ  | 候補言語の一覧。このフィールドに対応するモデルでのみ使用。                                                   |
| prompt                        | string          | いいえ  | 用語と文脈のヒント。録音の言語と合わせます。diarize モデルは未対応。                                          |
| keywords\[]                   | string\[]       | いいえ  | 用語のヒント。gpt-transcribe のみ。                                                       |
| response\_format              | string          | いいえ  | デフォルトは json。text、srt、vtt、verbose\_json、diarized\_json の対応状況はモデルごとに異なります。        |
| temperature                   | number          | いいえ  | 0–1。デフォルトは 0。                                                                   |
| stream                        | boolean         | いいえ  | true は SSE を返します。whisper-1 は未対応。                                                |
| include\[]                    | string\[]       | いいえ  | logprobs は対応モデルかつ response\_format=json の場合のみ使用可能。                              |
| timestamp\_granularities\[]   | string\[]       | いいえ  | word / segment。verbose\_json と対応モデルが必要。diarize には適用不可。                          |
| chunking\_strategy            | string / object | 条件付き | auto または server\_vad 設定。diarize で入力が 30 秒を超える場合は必須。                             |
| known\_speaker\_names\[]      | string\[]       | いいえ  | 最大 4 人の既知話者の短い名前。参照音声と対応させる必要があります。                                             |
| known\_speaker\_references\[] | string\[]       | いいえ  | 2–10 秒の音声 data URL。名前と 1 対 1 で対応し、この機能をサポートするモデルで使用。                            |

`gpt-4o-transcribe` と `gpt-4o-mini-transcribe` は JSON 出力を使用します。`whisper-1` は text、srt、vtt、verbose\_json などの形式に対応します。話者ラベルが必要な場合は diarize 対応モデルと `diarized_json` を使用し、通常のモデルにそのパラメーターを無理に適用しないでください。

## 戻り値

| フィールド                    | 説明                                                |
| ------------------------ | ------------------------------------------------- |
| `text`                   | 文字起こしの全文。                                         |
| `usage`                  | モデルが返す使用量統計。フィールドはモデルによって異なります。                   |
| `logprobs`               | 要求され、モデルが対応する場合に返される token の信頼度情報。                |
| `language` / `duration`  | verbose\_json の言語と音声の秒数。                          |
| `words[]` / `segments[]` | タイムスタンプ形式または話者形式に対応する場合のセグメント。すべての出力で含まれるとは限りません。 |

```json
{"text":"欢迎参加今天的会议。"}
```

`stream=true` は、対応モデルで文字起こしの増分と完了イベントを SSE で返します。受信側はストリームを継続して読み取る必要があります。ただし、先にファイル全体をアップロードする方式であり、双方向のマイク Realtime ではありません。

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

カレントディレクトリに `speech.wav` を用意し、`SIMIROUTER_API_KEY` を設定します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'gpt-4o-mini-transcribe', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "gpt-4o-mini-transcribe");
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
    curl "https://api.dwchainless.com/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=gpt-4o-mini-transcribe" \
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
      check(writer.WriteField("model", "gpt-4o-mini-transcribe"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/transcriptions", &buffer); check(err)
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

[OpenAI Create transcription](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create)。