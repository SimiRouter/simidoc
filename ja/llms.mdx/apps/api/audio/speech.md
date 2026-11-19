# テキスト読み上げ

## API の説明

`POST /v1/audio/speech` は `input` を音声に合成します。SimiRouter を使用する場合、ベース URL に `https://api.dwchainless.com` を使用し、認証には `Authorization: Bearer $SIMIROUTER_API_KEY`、リクエスト本体は `application/json` です。本ページは OpenAI 公式 Speech API を参考にしています。利用可能なモデルとフィールドの透過転送は、選択したチャネルによって決まります。

<Callout type="warn" title="モデルは 2027-01-06 に停止">
  `gpt-4o-mini-tts`、`tts-1`、`tts-1-hd` は OpenAI により非推奨とされ、2027-01-06 に停止します。公式の代替は Realtime API の `gpt-realtime-2.1-mini` で、`/v1/audio/speech` には対応しないため `/v1/realtime` へ移行してください。例では現在ルーティング可能なモデルを使用しています。呼び出し前に、チャネルが代替モデルを提供しているか確認してください。
</Callout>

## リクエストパラメータ

| フィールド            | 型               | 必須  | 説明                                                 |
| ---------------- | --------------- | --- | -------------------------------------------------- |
| model            | string          | はい  | gpt-4o-mini-tts など、利用可能な TTS モデル。文字起こしモデルは使用できません。 |
| input            | string          | はい  | 読み上げテキスト。最大 4096 文字。                               |
| voice            | string / object | はい  | 組み込みの声質名、または権限のあるカスタム音声 \{"id"\:"voice\_..."}。     |
| instructions     | string          | いいえ | 口調とスタイルの指示。tts-1/tts-1-hd は未対応。最大 4096 文字。         |
| response\_format | string          | いいえ | mp3（デフォルト）、opus、aac、flac、wav、pcm。                  |
| speed            | number          | いいえ | 0.25–4.0。デフォルトは 1。                                 |
| stream\_format   | string          | いいえ | audio（デフォルト）または sse。tts-1/tts-1-hd は sse に未対応。     |

組み込みの声質には `alloy`、`ash`、`ballad`、`coral`、`echo`、`fable`、`onyx`、`nova`、`sage`、`shimmer`、`verse`、`marin`、`cedar` があります。モデルによっては一部のみ対応します。声質名は特定の言語を意味しません。

## 戻り値

成功時は音声バイト列であり、URL を含む JSON ではありません。保存する拡張子は `response_format` と一致させてください。PCM はコンテナを持たない生サンプルのため、再生時にサンプリング仕様を合わせる必要があります。デフォルトの音声レスポンスは、待ち時間を短縮するためにチャンク単位で読み取れます。

`stream_format: "sse"` はイベントストリームを使用します。クライアントはイベントを解析し、音声の増分をデコードする必要があります。SSE テキスト全体を MP3 として保存しないでください。SSE の利用可否はチャネルの実装にも依存します。

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

先に `SIMIROUTER_API_KEY` を設定します。この例は MP3 を選択し、HTTP エラー時には停止して、エラー JSON が音声として保存されることを防ぎます。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.dwchainless.com/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gpt-4o-mini-tts', 'input': '你好，欢迎使用语音合成。', 'voice': 'alloy', 'response_format': 'mp3'}, timeout=180)
    response.raise_for_status()
    Path('speech.mp3').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("speech.mp3", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "speech.mp3" ] || { printf '%s\n' "目标文件已存在：speech.mp3" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "https://api.dwchainless.com/v1/audio/speech" \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }' \
      --output "$temporary"; then
      mv "$temporary" "speech.mp3"
    else
      status=$?
      cat "$temporary" >&2
      exit "$status"
    fi
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
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }`)
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("speech.mp3", data, 0600))
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

エラー本文の `error.message`、`error.type`、`error.code` は HTTP ステータスより具体的な原因を示します。このインターフェースは同期リクエストです。タスク ID やポーリング段階はありません。エラー本文を音声ファイルとして保存しないでください。

## 公式資料

[OpenAI Create speech](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create)。