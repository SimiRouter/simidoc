# Gemini 音声合成

## API の説明

Gemini TTS は指定したテキストを正確に読み上げるための機能で、対話型の Live API とは異なります。以下の例は **Google 公式 Interactions API**：`POST https://generativelanguage.googleapis.com/v1beta/interactions` を使用し、認証には `x-goog-api-key: $GEMINI_API_KEY` を使用します。OpenAI の `/audio/speech` ではないため、ドメインと Key を置き換えるだけではゲートウェイを呼び出せません。

`gemini-3.8-flash-tts` と `gemini-3.8-flash-lite-tts` は本ページの構造を使用します。引き続き対応している Gemini 3.1 / 2.5 Preview TTS では、それぞれの generateContent 設定を使用します。世代の異なるリクエストを混在させないでください。SimiRouter のネイティブプロキシが Interactions を提供するかは、チャネルごとに確認が必要です。

## リクエストパラメータ

| フィールド                             | 型              | 必須   | 説明                                                        |
| --------------------------------- | -------------- | ---- | --------------------------------------------------------- |
| model                             | string         | はい   | gemini-3.8-flash-tts など。                                  |
| input                             | string / array | はい   | 読み上げるテキスト。スタイル注釈を付ける場合は user\_input/content 構造を使用。        |
| input\[].content\[].text          | string         | はい   | 一字一句読み上げる内容。                                              |
| annotations\[].type               | string         | 条件付き | スタイル注釈には speech\_metadata を使用。                            |
| annotations\[].style              | string         | いいえ  | このターンの口調、アクセント、テンポ。                                       |
| annotations\[].speaker            | string         | 条件付き | 複数話者の場合、設定内の speaker 名に対応。                                |
| response\_format                  | object         | いいえ  | この例では \{"type"\:"audio"}。返された MIME に従います。                 |
| generation\_config.speech\_config | array / object | はい   | 単一話者は \[\{"voice"\:"Kore"}]、複数話者は speakers オブジェクトを使用。     |
| stream                            | boolean        | いいえ  | モデルが対応する場合、true は増分イベントを返します。SSE テキストを音声ファイルとして扱わないでください。 |

複数話者の設定には `{"speakers":[{"speaker":"Joe","voice":"Kore"},{"speaker":"Jane","voice":"Puck"}]}` を使用します。各ターンの speech\_metadata.speaker は Joe または Jane を参照する必要があります。2 人分のせりふを話者注釈のないテキストに連結するだけでは不十分です。音声デザインと音声クローンには、対応する voice ID と利用許諾が必要です。

## 戻り値

REST は Interactions オブジェクトを返します。音声は `steps[]` 内の `type=model_output` の `content[]` に含まれ、音声項目の `type=audio`、`data` は Base64、`mime_type` は形式を示します。SDK の `output_audio` は便宜的なプロパティであり、すべての REST レスポンスのルートフィールドではありません。デフォルトの WAV はデコード後にそのまま保存できます。WAV ヘッダーを手動で追加しないでください。

```json
{"steps":[{"type":"model_output","content":[{"type":"audio","mime_type":"audio/wav","data":"<Base64音频>"}]}]}
```

## コード例

Google 公式の `GEMINI_API_KEY` を設定します。Python 3、Node.js 18+、Go は標準ライブラリを使用し、curl の結果解析には Python 3 が必要です。デフォルトでは Google に直接接続します。`GEMINI_BASE_URL` はローカルテストや、許可されたネイティブプロトコルのプロキシに使用できます。アドレスに `/v1beta` は含めません。

この例では `status=completed` を確認してからすべての音声項目をデコードし、`speech-1.wav` などのファイルに保存します。同名ファイルは上書きしません。サービスが別の MIME タイプを返した場合は、実際の形式に従って処理し、拡張子だけを変更しないでください。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import base64, json, os, urllib.request
    key = os.environ["GEMINI_API_KEY"]
    base = os.environ.get("GEMINI_BASE_URL", "https://generativelanguage.googleapis.com").rstrip("/")
    body = json.loads(r'''{
      "model": "gemini-3.8-flash-tts",
      "input": [
        {
          "type": "user_input",
          "content": [
            {
              "type": "text",
              "text": "祝你今天过得愉快。",
              "annotations": [
                {
                  "type": "speech_metadata",
                  "style": "温暖自然"
                }
              ]
            }
          ]
        }
      ],
      "response_format": {
        "type": "audio"
      },
      "generation_config": {
        "speech_config": [
          {
            "voice": "Kore"
          }
        ]
      }
    }''')
    request = urllib.request.Request(base + "/v1beta/interactions", data=json.dumps(body).encode(),
        headers={"x-goog-api-key": key, "Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(request, timeout=180) as response:
        result = json.load(response)
    if result.get("status") != "completed":
        raise RuntimeError("生成未完成: " + str(result.get("status")))
    audio = [part for step in result.get("steps", []) if step.get("type") == "model_output"
             for part in step.get("content", []) if part.get("type") == "audio"]
    if not audio: raise RuntimeError("响应没有音频")
    for i, part in enumerate(audio):
        if part.get("mime_type") not in ("audio/wav", "audio/x-wav", "audio/wave"):
            raise RuntimeError("响应不是 WAV: " + str(part.get("mime_type")))
        data = base64.b64decode(part["data"], validate=True)
        if not data: raise RuntimeError("音频为空")
        name = f"speech-{i + 1}.wav"
        with open(name, "xb") as output: output.write(data)
        print(name)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { writeFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const base = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "");
      const response = await fetch(base + "/v1beta/interactions", {
        method: "POST", headers: {"x-goog-api-key": process.env.GEMINI_API_KEY, "Content-Type": "application/json"},
        body: JSON.stringify({"model":"gemini-3.8-flash-tts","input":[{"type":"user_input","content":[{"type":"text","text":"祝你今天过得愉快。","annotations":[{"type":"speech_metadata","style":"温暖自然"}]}]}],"response_format":{"type":"audio"},"generation_config":{"speech_config":[{"voice":"Kore"}]}}), signal: AbortSignal.timeout(180000)
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.status !== "completed") throw new Error("生成未完成: " + result.status);
      const audio = (result.steps || []).filter(s => s.type === "model_output").flatMap(s => s.content || []).filter(p => p.type === "audio");
      if (!audio.length) throw new Error("响应没有音频");
      for (const [i, part] of audio.entries()) {
        if (!["audio/wav", "audio/x-wav", "audio/wave"].includes(part.mime_type)) throw new Error("响应不是 WAV");
        if (!part.data || !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(part.data)) throw new Error("无效 Base64");
        const data = Buffer.from(part.data, "base64");
        const name = `speech-${i + 1}.wav`;
        await writeFile(name, data, {flag: "wx"}); console.log(name);
      }
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "${base%/}/v1beta/interactions" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "model": "gemini-3.8-flash-tts",
        "input": [
          {
            "type": "user_input",
            "content": [
              {
                "type": "text",
                "text": "祝你今天过得愉快。",
                "annotations": [
                  {
                    "type": "speech_metadata",
                    "style": "温暖自然"
                  }
                ]
              }
            ]
          }
        ],
        "response_format": {
          "type": "audio"
        },
        "generation_config": {
          "speech_config": [
            {
              "voice": "Kore"
            }
          ]
        }
      }'
    python3 - "$response" <<'PY_AUDIO'
    import base64, json, sys
    with open(sys.argv[1]) as source: result = json.load(source)
    if result.get("status") != "completed": raise RuntimeError("生成未完成")
    audio = [part for step in result.get("steps", []) if step.get("type") == "model_output"
             for part in step.get("content", []) if part.get("type") == "audio"]
    if not audio: raise RuntimeError("响应没有音频")
    for i, part in enumerate(audio):
        if part.get("mime_type") not in ("audio/wav", "audio/x-wav", "audio/wave"): raise RuntimeError("响应不是 WAV")
        data = base64.b64decode(part["data"], validate=True)
        if not data: raise RuntimeError("音频为空")
        name = f"speech-{i + 1}.wav"
        with open(name, "xb") as output: output.write(data)
        print(name)
    PY_AUDIO
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import ("bytes"; "encoding/base64"; "encoding/json"; "fmt"; "io"; "net/http"; "os"; "time"; "strings")
    func check(err error) { if err != nil { panic(err) } }
    func main() {
     key:=os.Getenv("GEMINI_API_KEY"); if key=="" { panic("请设置 GEMINI_API_KEY") }
     base:=os.Getenv("GEMINI_BASE_URL"); if base=="" {base="https://generativelanguage.googleapis.com"}
     req,err:=http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", bytes.NewBufferString(`{"model":"gemini-3.8-flash-tts","input":[{"type":"user_input","content":[{"type":"text","text":"祝你今天过得愉快。","annotations":[{"type":"speech_metadata","style":"温暖自然"}]}]}],"response_format":{"type":"audio"},"generation_config":{"speech_config":[{"voice":"Kore"}]}}`));check(err)
     req.Header.Set("x-goog-api-key",key);req.Header.Set("Content-Type","application/json")
     res,err:=(&http.Client{Timeout:180*time.Second}).Do(req);check(err);defer res.Body.Close()
     raw,err:=io.ReadAll(res.Body);check(err);if res.StatusCode>=300 {panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw))}
     var result struct {Status string `json:"status"`; Steps []struct {Type string `json:"type"`;Content []struct {Type string `json:"type"`;Mime string `json:"mime_type"`;Data string `json:"data"`} `json:"content"`} `json:"steps"`}
     check(json.Unmarshal(raw,&result));if result.Status!="completed" {panic("生成未完成")}
     count:=0
     for _,step:=range result.Steps { if step.Type!="model_output" {continue}; for _,part:=range step.Content {if part.Type!="audio" {continue}
     if part.Mime!="audio/wav" && part.Mime!="audio/x-wav" && part.Mime!="audio/wave" {panic("响应不是 WAV")}
     data,err:=base64.StdEncoding.Strict().DecodeString(part.Data);check(err);if len(data)==0 {panic("音频为空")}
     count++;name:=fmt.Sprintf("speech-%d.wav",count);out,err:=os.OpenFile(name,os.O_WRONLY|os.O_CREATE|os.O_EXCL,0600);check(err)
     _,err=out.Write(data);closeErr:=out.Close();check(err);check(closeErr);fmt.Println(name)
     }};if count==0 {panic("响应没有音频")}
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

[Google Gemini TTS](https\://ai.google.dev/gemini-api/docs/speech-generation)、[Interactions](https\://ai.google.dev/gemini-api/docs/interactions)。