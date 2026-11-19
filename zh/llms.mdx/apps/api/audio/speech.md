# 文本转语音

## 接口说明

`POST /v1/audio/speech` 将 `input` 合成为语音。使用 SimiRouter 时，基础地址为 `https://api.dwchainless.com`，鉴权为 `Authorization: Bearer $SIMIROUTER_API_KEY`，正文为 `application/json`。本页参考 OpenAI 官方 Speech API；具体模型和字段透传能力由所选渠道决定。

<Callout type="warn" title="模型将于 2027-01-06 关停">
  `gpt-4o-mini-tts`、`tts-1`、`tts-1-hd` 已被 OpenAI 标记弃用，并于 2027-01-06 关停。官方替代为 Realtime API 的 `gpt-realtime-2.1-mini`，该模型不支持 `/v1/audio/speech`，迁移时需要改走 `/v1/realtime`。示例仍使用当前可路由的模型；调用前请确认渠道是否已提供替代模型。
</Callout>

## 请求参数

| 字段               | 类型              | 必填 | 说明                                      |
| ---------------- | --------------- | -- | --------------------------------------- |
| model            | string          | 是  | 可用 TTS 模型，例如 gpt-4o-mini-tts；不能使用转录模型。  |
| input            | string          | 是  | 朗读文本，最多 4096 字符。                        |
| voice            | string / object | 是  | 内置音色名，或有权限的自定义声音 \{"id"\:"voice\_..."}。 |
| instructions     | string          | 否  | 语气、风格指令；tts-1/tts-1-hd 不支持。最多 4096 字符。  |
| response\_format | string          | 否  | mp3（默认）、opus、aac、flac、wav、pcm。          |
| speed            | number          | 否  | 0.25–4.0，默认 1。                          |
| stream\_format   | string          | 否  | audio（默认）或 sse；tts-1/tts-1-hd 不支持 sse。  |

内置音色包括 `alloy`、`ash`、`ballad`、`coral`、`echo`、`fable`、`onyx`、`nova`、`sage`、`shimmer`、`verse`、`marin`、`cedar`，具体模型可能只支持其中一部分。音色名不表示固定语言。

## 返回值

成功时为音频字节，不是包含 URL 的 JSON。保存后缀应与 `response_format` 一致；PCM 是无容器原始采样，播放时需要匹配采样规格。默认音频响应可逐块读取以减少等待。

`stream_format: "sse"` 使用事件流；客户端需解析事件并解码音频增量，不能把完整 SSE 文本保存为 MP3。SSE 是否可用还取决于渠道实现。

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

先设置 `SIMIROUTER_API_KEY`。示例选择 MP3，并在 HTTP 失败时停止，避免把错误 JSON 写成音频。

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

## 错误码

| HTTP 状态               | 含义与处理                                     |
| --------------------- | ----------------------------------------- |
| 400                   | 请求字段或模型参数不合法，修正后再提交。                      |
| 401                   | API Key 缺失、无效或已过期。                        |
| 403                   | 当前项目或模型没有权限。                              |
| 404                   | 模型或路由不存在，检查地址与模型 ID。                      |
| 429                   | 速率或配额限制，区分余额不足与可退避重试的限流。                  |
| 500 / 502 / 503 / 504 | 服务或上游异常，保留请求 ID；对暂时故障做有限次退避，不要无限重试同一付费请求。 |

错误正文中的 `error.message`、`error.type`、`error.code` 比 HTTP 状态提供更具体的原因。本接口是同步请求，没有任务 ID 或轮询阶段。失败时不要把错误正文保存为音频文件。

## 官方参考

[OpenAI Create speech](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create)。