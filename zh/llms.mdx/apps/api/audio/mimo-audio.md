# MiMo 音频接入

## 接口说明

MiMo 支持语音合成、语音转录、音色设计与参考声音克隆。需要区分两种接口：

| 协议       | 地址/端点                                               | 鉴权                             | 输出                          |
| -------- | --------------------------------------------------- | ------------------------------ | --------------------------- |
| 独立音频兼容服务 | 部署地址的 `/v1/audio/speech`、`/v1/audio/transcriptions` | 服务自身的 Bearer Key，也接受 x-api-key | 音频字节或转录结果                   |
| 小米官方原生   | `https://api.xiaomimimo.com/v1/chat/completions`    | MiMo 官方 api-key 或 Bearer Key   | Chat Completions JSON / SSE |

**兼容路由不是小米官方原生端点。** 下方兼容示例默认直连独立服务 `http://127.0.0.1:8080`；若服务位于其他地址，替换主机和端口。SimiRouter 公网是否配置了相同路由需单独确认，不能直接套用独立服务 Key。

## 请求参数

### 语音合成：POST /v1/audio/speech

| 字段               | 类型              | 必填 | 说明                                                                |
| ---------------- | --------------- | -- | ----------------------------------------------------------------- |
| model            | string          | 是  | mimo-v2.5-tts、mimo-v2.5-tts-voicedesign、mimo-v2.5-tts-voiceclone。 |
| input            | string          | 是  | 非空朗读文本；默认最大 4096 字符，部署可配置。                                        |
| voice            | string / object | 是  | 预设音色；克隆时用音频 data URL，或服务创建的 \{"id"\:"voice\_..."}。                |
| instructions     | string          | 否  | 语气/风格指令，最多 4096 字符。                                               |
| style            | string          | 否  | 兼容服务扩展字段，优先于 instructions；voicedesign 用它描述音色。                     |
| speed            | number          | 否  | 0.25–4，默认 1；转换为风格提示，不保证逐采样精确变速。                                   |
| response\_format | string          | 否  | wav、mp3、opus、aac、flac、pcm。直接 MiMo 模型默认 wav，建议显式设置。                |
| stream\_format   | string          | 否  | 兼容服务只接受 audio；sse 明确返回 400，不提供上游低延迟合成流。                           |

预设音色映射：alloy→冰糖、echo→茉莉、fable→白桦、onyx→苏打、nova→Mia、shimmer→Chloe、dean→Dean、milo→Milo。名称是兼容服务的映射，不等同于 OpenAI 同名声音。

### 语音转录：POST /v1/audio/transcriptions

| 字段                          | 类型        | 必填 | 说明                                                      |
| --------------------------- | --------- | -- | ------------------------------------------------------- |
| file                        | file      | 是  | multipart 文件；默认最大 25 MiB，部署可配置。                         |
| model                       | string    | 是  | mimo-v2.5-asr。                                          |
| language                    | string    | 否  | auto（默认）、zh、en。                                         |
| languages\[]                | string\[] | 否  | 候选语言，与 language 互斥；多候选归并为自动识别。                          |
| response\_format            | string    | 否  | json（默认）、text、verbose\_json、srt、vtt。diarized\_json 不支持。 |
| stream                      | boolean   | 否  | 转录完成后输出 SSE 事件，不是上游边听边转录。                               |
| timestamp\_granularities\[] | string\[] | 否  | 不支持；非空返回 400，不伪造词级/分段时间戳。                               |

兼容服务可接收 mp3、wav、aac、flac、m4a、mp4、mpeg、mpga、oga、ogg、opus、webm；非原生格式需要媒体转换组件。小米官方原生 ASR 的输入范围只有 MP3/WAV，不能互相套用限制。

## 返回值

* TTS 成功返回相应 MIME 的音频二进制；这是完成合成后的 HTTP 响应，没有公开 task\_id。
* ASR JSON 为 `{"text":"识别文字"}`；text 直接返回纯文本。
* verbose\_json 含 task、language、duration、text 与空 segments，**不提供真实分段时间戳**。SRT/VTT 是整段字幕，不是词级对齐。
* stream=true 只将最终转录包装为 SSE，客户端不能据此判断上游支持实时识别。

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

### 文字转语音

设置独立服务 `MIMO_AUDIO_API_KEY`。示例输出 `mimo-speech.wav`。

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

### 语音转文字

准备 `speech.wav`。鉴权仍使用独立服务 Key。

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

### 音色设计与声音克隆

音色设计将 model 改为 `mimo-v2.5-tts-voicedesign`，添加 `style: "温暖低沉的成年男声，普通话清晰"`。声音克隆将 model 改为 `mimo-v2.5-tts-voiceclone`，voice 设置为 `data:audio/wav;base64,<真实参考音频>`。不要发送空 Base64、伪装扩展名或未经授权的他人声音。

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

### 小米官方原生协议

官方 TTS 使用 `assistant` 消息承载朗读文字、`user` 消息提供风格说明。示例为官方 JSON，不得发到 `/audio/speech`：

```json
{"model":"mimo-v2.5-tts","messages":[{"role":"user","content":"温暖自然"},{"role":"assistant","content":"你好，欢迎使用 MiMo。"}],"audio":{"format":"wav","voice":"mimo_default"},"stream":false}
```

官方返回音频在 `choices[0].message.audio.data`，需 Base64 解码。原生 ASR 把音频放入 `messages[0].content`：

```json
{"model":"mimo-v2.5-asr","messages":[{"role":"user","content":[{"type":"input_audio","input_audio":{"data":"data:audio/wav;base64,<真实Base64>"}}]}],"asr_options":{"language":"auto"},"stream":false}
```

原生 ASR 文字在 `choices[0].message.content`。data URL 已包含格式时 format 可选；裸 Base64 必须指定 `format: "wav"` 或 `"mp3"`，两者同时设置时须一致。

## 错误码

| HTTP / code                       | 含义                  |
| --------------------------------- | ------------------- |
| 400 / unsupported\_audio\_format  | TTS 输出格式非法。         |
| 400 / speech\_sse\_not\_supported | 兼容服务不支持 TTS SSE。    |
| 400 / diarization\_not\_supported | ASR 不支持说话人分离格式。     |
| 400 / timestamps\_not\_supported  | ASR 不支持时间戳粒度。       |
| 401 / 403                         | 独立服务 Key 或权限错误。     |
| 404 / voice\_not\_found           | 自定义声音不存在或不属于当前 Key。 |
| 413 / input\_too\_large           | 文本或媒体超出限制。          |
| 415 / unsupported\_file\_type     | 文件扩展名或 MIME 不受支持。   |
| 422 / invalid\_audio              | 媒体不能解码。             |
| 502 / invalid\_audio\_output      | 上游没有返回有效音频。         |
| 503 / audio\_failover\_exhausted  | 音频服务暂不可用。           |

克隆声音上传属于有状态操作，不应在超时后盲目重复。

## 官方参考

[MiMo TTS](https\://mimo.mi.com/docs/en-US/api/audio/tts)、[MiMo ASR](https\://mimo.mi.com/docs/en-US/api/audio/Speech-Recognition)。这些官方页面说明原生协议，不把兼容服务的扩展字段列为厂商原生能力。