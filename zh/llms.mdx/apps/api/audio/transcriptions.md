# 音频转录

## 接口说明

`POST /v1/audio/transcriptions`，鉴权为 `Authorization: Bearer $SIMIROUTER_API_KEY`。上传使用 `multipart/form-data`，让 HTTP 库生成 boundary，不要手写不带 boundary 的 Content-Type。

本接口保留原语言，不把中文自动翻成英文。支持的文件格式包括 flac、mp3、mp4、mpeg、mpga、m4a、ogg、wav、webm。文件大小与录音时长还受模型和渠道限制。

<Callout type="warn" title="部分模型将于 2027-02-26 关停">
  `whisper-1`、`gpt-4o-transcribe`、`gpt-4o-mini-transcribe`（含日期快照版本）已被 OpenAI 标记弃用，并于 2027-02-26 关停。优先选择 `gpt-transcribe`；需要实时或说话人分离时，分别使用 `gpt-live-transcribe` 或 `gpt-4o-transcribe-diarize`。
</Callout>

## 请求参数

| 字段                            | 类型              | 必填 | 说明                                                                             |
| ----------------------------- | --------------- | -- | ------------------------------------------------------------------------------ |
| file                          | file            | 是  | 音频文件本体，不是文件路径字符串或普通 URL。                                                       |
| model                         | string          | 是  | 如 gpt-transcribe、gpt-4o-transcribe、gpt-4o-mini-transcribe、whisper-1 或分离说话人的模型。 |
| language                      | string          | 否  | 输入语言 ISO-639-1 代码，例如 zh、en。                                                    |
| languages\[]                  | string\[]       | 否  | 候选语言列表，仅支持此字段的模型使用。                                                            |
| prompt                        | string          | 否  | 术语和上下文提示，应与录音语言一致；diarize 模型不支持。                                               |
| keywords\[]                   | string\[]       | 否  | 术语提示，仅 gpt-transcribe。                                                         |
| response\_format              | string          | 否  | 默认 json；text、srt、vtt、verbose\_json、diarized\_json 的支持情况按模型区分。                  |
| temperature                   | number          | 否  | 0–1，默认 0。                                                                      |
| stream                        | boolean         | 否  | true 返回 SSE；whisper-1 不支持。                                                     |
| include\[]                    | string\[]       | 否  | logprobs 仅适用于支持的模型且 response\_format=json。                                     |
| timestamp\_granularities\[]   | string\[]       | 否  | word / segment，要求 verbose\_json 与支持的模型，不适用于 diarize。                           |
| chunking\_strategy            | string / object | 条件 | auto 或 server\_vad 配置；diarize 输入超过 30 秒时必须设置。                                  |
| known\_speaker\_names\[]      | string\[]       | 否  | 最多 4 位已知说话人的短名称，需与音频参考对应。                                                      |
| known\_speaker\_references\[] | string\[]       | 否  | 2–10 秒的音频 data URL，与名称一一对应，用于支持此能力的模型。                                         |

`gpt-4o-transcribe` 与 `gpt-4o-mini-transcribe` 使用 JSON 输出；`whisper-1` 支持 text、srt、vtt、verbose\_json 等格式。需要说话人标注时使用支持 diarize 的模型与 `diarized_json`，不要给普通模型强加该参数。

## 返回值

| 字段                       | 说明                          |
| ------------------------ | --------------------------- |
| `text`                   | 完整转录文本。                     |
| `usage`                  | 模型提供的消耗统计，字段随模型变化。          |
| `logprobs`               | 请求并支持时返回的 token 置信信息。       |
| `language` / `duration`  | verbose\_json 的语言及音频秒数。     |
| `words[]` / `segments[]` | 支持时间戳或说话人格式时的片段，不保证每种输出都具备。 |

```json
{"text":"欢迎参加今天的会议。"}
```

`stream=true` 在支持的模型上返回 SSE 转录增量和完成事件，接收方必须持续读流。它仍然先上传整个文件，不是双向麦克风 Realtime。

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

准备当前目录下的 `speech.wav` 并设置 `SIMIROUTER_API_KEY`。

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

## 错误码

| HTTP 状态               | 含义与处理                                     |
| --------------------- | ----------------------------------------- |
| 400                   | 请求字段或模型参数不合法，修正后再提交。                      |
| 401                   | API Key 缺失、无效或已过期。                        |
| 403                   | 当前项目或模型没有权限。                              |
| 404                   | 模型或路由不存在，检查地址与模型 ID。                      |
| 413                   | 文件超过上传上限，压缩或改用更小的文件。                      |
| 429                   | 速率或配额限制，区分余额不足与可退避重试的限流。                  |
| 500 / 502 / 503 / 504 | 服务或上游异常，保留请求 ID；对暂时故障做有限次退避，不要无限重试同一付费请求。 |

错误正文中的 `error.message`、`error.type`、`error.code` 比 HTTP 状态提供更具体的原因。本接口是同步请求，没有任务 ID 或轮询阶段。失败时不要把错误正文保存为转录文本。

## 官方参考

[OpenAI Create transcription](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create)。