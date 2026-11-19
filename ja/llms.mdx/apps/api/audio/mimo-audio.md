# MiMo 音声の接続

## API の説明

MiMo は音声合成、音声文字起こし、声質デザイン、参照音声のクローンに対応しています。次の 2 種類の API を区別する必要があります。

| プロトコル              | アドレス／エンドポイント                                             | 認証                                 | 出力                          |
| ------------------ | -------------------------------------------------------- | ---------------------------------- | --------------------------- |
| 独立した音声互換サービス       | デプロイ先アドレスの `/v1/audio/speech`、`/v1/audio/transcriptions` | サービス独自の Bearer Key。x-api-key も使用可能 | 音声バイト列または文字起こし結果            |
| Xiaomi 公式ネイティブ API | `https://api.xiaomimimo.com/v1/chat/completions`         | MiMo 公式 api-key または Bearer Key     | Chat Completions JSON / SSE |

**互換ルートは Xiaomi 公式のネイティブエンドポイントではありません。** 以下の互換 API の例は、デフォルトで独立サービスの `http://127.0.0.1:8080` に直接接続します。サービスのアドレスが異なる場合はホストとポートを置き換えてください。SimiRouter の公開サービスに同じルートが設定されているかは別途確認が必要です。独立サービスの Key をそのまま使用しないでください。

## リクエストパラメータ

### 音声合成：POST /v1/audio/speech

| フィールド            | 型               | 必須  | 説明                                                                 |
| ---------------- | --------------- | --- | ------------------------------------------------------------------ |
| model            | string          | はい  | mimo-v2.5-tts、mimo-v2.5-tts-voicedesign、mimo-v2.5-tts-voiceclone。  |
| input            | string          | はい  | 空ではない読み上げテキスト。デフォルトは最大 4096 文字で、デプロイ時に設定可能。                        |
| voice            | string / object | はい  | プリセットの声質。クローン時は音声 data URL、またはサービスが作成した \{"id"\:"voice\_..."} を使用。 |
| instructions     | string          | いいえ | 口調／スタイルの指示。最大 4096 文字。                                             |
| style            | string          | いいえ | 互換サービスの拡張フィールド。instructions より優先され、voicedesign では声質の説明に使用。         |
| speed            | number          | いいえ | 0.25–4。デフォルトは 1。スタイルのプロンプトに変換されるため、サンプル単位の正確な速度変更は保証されません。         |
| response\_format | string          | いいえ | wav、mp3、opus、aac、flac、pcm。MiMo モデルの直接利用ではデフォルトは wav。明示的な設定を推奨。     |
| stream\_format   | string          | いいえ | 互換サービスは audio のみ受け付けます。sse は明示的に 400 を返し、上流の低遅延合成ストリームは提供しません。     |

プリセット声質の対応：alloy→冰糖、echo→茉莉、fable→白桦、onyx→苏打、nova→Mia、shimmer→Chloe、dean→Dean、milo→Milo。これらは互換サービスのマッピング名であり、OpenAI の同名音声とは異なります。

### 音声文字起こし：POST /v1/audio/transcriptions

| フィールド                       | 型         | 必須  | 説明                                                          |
| --------------------------- | --------- | --- | ----------------------------------------------------------- |
| file                        | file      | はい  | multipart ファイル。デフォルトは最大 25 MiB で、デプロイ時に設定可能。                |
| model                       | string    | はい  | mimo-v2.5-asr。                                              |
| language                    | string    | いいえ | auto（デフォルト）、zh、en。                                          |
| languages\[]                | string\[] | いいえ | 候補言語。language と併用不可。複数の候補は自動認識として扱います。                      |
| response\_format            | string    | いいえ | json（デフォルト）、text、verbose\_json、srt、vtt。diarized\_json は未対応。 |
| stream                      | boolean   | いいえ | 文字起こし完了後に SSE イベントを出力します。上流で音声を受信しながら文字起こしするものではありません。      |
| timestamp\_granularities\[] | string\[] | いいえ | 未対応。空でない場合は 400 を返します。単語単位／区間単位のタイムスタンプは生成しません。             |

互換サービスは mp3、wav、aac、flac、m4a、mp4、mpeg、mpga、oga、ogg、opus、webm を受け付けます。ネイティブ以外の形式にはメディア変換コンポーネントが必要です。Xiaomi 公式ネイティブ ASR の入力形式は MP3/WAV のみです。両者の制限を混同しないでください。

## 戻り値

* TTS が成功すると、対応する MIME の音声バイナリを返します。これは合成完了後の HTTP レスポンスであり、公開 task\_id はありません。
* ASR の JSON は `{"text":"识别文字"}` です。text はプレーンテキストを直接返します。
* verbose\_json は task、language、duration、text、空の segments を含み、**実際の区間タイムスタンプは提供しません**。SRT/VTT は全体を 1 区間とした字幕であり、単語単位のアライメントではありません。
* stream=true は最終的な文字起こしを SSE で包むだけです。これを根拠に、上流がリアルタイム認識に対応すると判断しないでください。

## コード例

Python 例には `python3 -m pip install requests` が必要です。Node.js は 18 以降の内蔵 fetch、Go は標準ライブラリを使用。

### テキスト読み上げ

独立サービスの `MIMO_AUDIO_API_KEY` を設定します。この例は `mimo-speech.wav` を出力します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'http://127.0.0.1:8080/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'mimo-v2.5-tts', 'input': '你好，欢迎使用 MiMo 语音。', 'voice': 'alloy', 'response_format': 'wav'}, timeout=180)
    response.raise_for_status()
    Path('mimo-speech.wav').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("mimo-speech.wav", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "mimo-speech.wav" ] || { printf '%s\n' "目标文件已存在：mimo-speech.wav" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "http://127.0.0.1:8080/v1/audio/speech" \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }' \
      --output "$temporary"; then
      mv "$temporary" "mimo-speech.wav"
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
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }`)
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("mimo-speech.wav", data, 0600))
    }
    ```
  </Tab>
</Tabs>

### 音声からテキストへの変換

用意するファイルは `speech.wav` です。認証には引き続き独立サービスの Key を使用します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'http://127.0.0.1:8080/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'mimo-v2.5-asr', 'language': 'auto', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "mimo-v2.5-asr");
      form.append("language", "auto");
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
    curl "http://127.0.0.1:8080/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=mimo-v2.5-asr" \
      -F "language=auto" \
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
      check(writer.WriteField("model", "mimo-v2.5-asr"))
      check(writer.WriteField("language", "auto"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/transcriptions", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
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

### 声質デザインと音声クローン

声質デザインでは model を `mimo-v2.5-tts-voicedesign` に変更し、追加する項目は `style: "温暖低沉的成年男声，普通话清晰"` です。音声クローンでは model を `mimo-v2.5-tts-voiceclone` に変更し、voice を `data:audio/wav;base64,<真实参考音频>` に設定します。空の Base64、拡張子を偽装したファイル、許可のない他人の音声を送信しないでください。

```python
import base64
import os
from pathlib import Path
import requests
reference = base64.b64encode(Path("reference.wav").read_bytes()).decode("ascii")
response = requests.post("http://127.0.0.1:8080/v1/audio/speech",
    headers={"Authorization": "Bearer " + os.environ["MIMO_AUDIO_API_KEY"]},
    json={"model":"mimo-v2.5-tts-voiceclone","input":"这是一条授权声音示例。",
          "voice":"data:audio/wav;base64," + reference,"response_format":"wav"}, timeout=180)
response.raise_for_status()
Path("clone.wav").write_bytes(response.content)
```

### Xiaomi 公式ネイティブプロトコル

公式 TTS は `assistant` メッセージに読み上げテキストを入れ、`user` メッセージでスタイルを指定します。例は公式 JSON です。`/audio/speech` へ送信してはいけません：

```json
{"model":"mimo-v2.5-tts","messages":[{"role":"user","content":"温暖自然"},{"role":"assistant","content":"你好，欢迎使用 MiMo。"}],"audio":{"format":"wav","voice":"mimo_default"},"stream":false}
```

公式の返却音声は `choices[0].message.audio.data` に含まれ、Base64 デコードが必要です。ネイティブ ASR は音声を `messages[0].content`：

```json
{"model":"mimo-v2.5-asr","messages":[{"role":"user","content":[{"type":"input_audio","input_audio":{"data":"data:audio/wav;base64,<真实Base64>"}}]}],"asr_options":{"language":"auto"},"stream":false}
```

ネイティブ ASR のテキストは `choices[0].message.content` に含まれます。data URL に形式が含まれる場合は format を省略できます。生の Base64 では `format: "wav"` または `"mp3"` の指定が必須です。両方を設定する場合は一致させる必要があります。

## エラーコード

| HTTP / code                       | 意味                              |
| --------------------------------- | ------------------------------- |
| 400 / unsupported\_audio\_format  | TTS の出力形式が無効です。                 |
| 400 / speech\_sse\_not\_supported | 互換サービスは TTS SSE に対応していません。      |
| 400 / diarization\_not\_supported | ASR は話者分離形式に対応していません。           |
| 400 / timestamps\_not\_supported  | ASR はタイムスタンプ粒度に対応していません。        |
| 401 / 403                         | 独立サービスの Key または権限が正しくありません。     |
| 404 / voice\_not\_found           | カスタム音声が存在しないか、現在の Key に属していません。 |
| 413 / input\_too\_large           | テキストまたはメディアが制限を超えています。          |
| 415 / unsupported\_file\_type     | ファイル拡張子または MIME が未対応です。         |
| 422 / invalid\_audio              | メディアをデコードできません。                 |
| 502 / invalid\_audio\_output      | 上流から有効な音声が返されませんでした。            |
| 503 / audio\_failover\_exhausted  | 音声サービスを一時的に利用できません。             |

クローン音声のアップロードは状態を変更する操作です。タイムアウト後に確認せず繰り返さないでください。

## 公式資料

[MiMo TTS](https\://mimo.mi.com/docs/en-US/api/audio/tts)、[MiMo ASR](https\://mimo.mi.com/docs/en-US/api/audio/Speech-Recognition)。これらの公式ページはネイティブプロトコルを説明しており、互換サービスの拡張フィールドをメーカーのネイティブ機能として扱っていません。