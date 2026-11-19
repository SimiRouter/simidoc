# 音频翻译

## 接口说明

`POST /v1/audio/translations` 接收录音并输出**英文**，不接受任意目标语言参数。鉴权为 `Authorization: Bearer $SIMIROUTER_API_KEY`，正文为 `multipart/form-data`。本文参考 OpenAI 官方 Audio Translations API；账户须具有对应模型渠道。

<Callout type="warn" title="端点与模型将于 2027-02-26 关停">
  OpenAI 已将 `/v1/audio/translations` 与 `whisper-1` 标记弃用，并于 2027-02-26 关停。替代方案是 Realtime API 的 `/v1/realtime/translations` 与 `gpt-realtime-translate`，需要单独改造调用方式。本页只保留迁移前的参考。
</Callout>

## 请求参数

| 字段               | 类型     | 必填 | 说明                                              |
| ---------------- | ------ | -- | ----------------------------------------------- |
| file             | file   | 是  | 录音文件本体；flac、mp3、mp4、mpeg、mpga、m4a、ogg、wav、webm。 |
| model            | string | 是  | 此端点使用 whisper-1，不能替换为普通转录模型。                    |
| prompt           | string | 否  | 英文术语或上下文提示。                                     |
| response\_format | string | 否  | json（默认）、text、srt、verbose\_json、vtt。            |
| temperature      | number | 否  | 0–1，默认 0。                                       |

## 返回值

JSON 返回 `text` 英文翻译。`verbose_json` 另含 `duration`（秒）、`language`（english）、`segments[]`。字幕格式直接返回字幕文本，不能按 JSON 解析。本端点为单次文件请求，不提供 stream 参数；实时翻译是独立会话接口。

```json
{"text":"Welcome to today's meeting."}
```

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

准备 `speech.wav`，并设置 `SIMIROUTER_API_KEY`。

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

[OpenAI Create translation](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create)。