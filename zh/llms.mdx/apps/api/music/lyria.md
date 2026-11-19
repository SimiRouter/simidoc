# Google Lyria 音乐生成

以下页面按 Google 官方接口整理。SimiRouter 尚未开放该能力，示例均按 Google AI Studio Gemini API 直连，使用 `https://generativelanguage.googleapis.com` 与 Google API Key。Vertex AI 需要独立协议，本页未验证，不要直接替换地址调用。

## 接口说明

`POST https://generativelanguage.googleapis.com/v1beta/interactions`，鉴权为 `x-goog-api-key: $GEMINI_API_KEY`。Lyria 使用 Interactions，不是 generateContent，也不是 `/audio/speech`。

| 模型                     | 用途           | 时长与输出                        |
| ---------------------- | ------------ | ---------------------------- |
| `lyria-3-clip-preview` | 片段、循环与快速试听   | 固定 30 秒，默认 MP3。              |
| `lyria-3.5`            | 含主歌、副歌、桥段的歌曲 | 提示词控制为几分钟的歌曲，默认 MP3，可请求 WAV。 |

## 请求参数

| 字段                         | 类型             | 必填 | 说明                                      |
| -------------------------- | -------------- | -- | --------------------------------------- |
| model                      | string         | 是  | 上述 Lyria 模型之一。                          |
| input                      | string / array | 是  | 音乐描述，或 text/image 多模态内容数组。              |
| input\[].text              | string         | 条件 | 曲风、速度、情绪、乐器、歌词和结构。                      |
| input\[].mime\_type / data | string         | 条件 | 图片输入采用 image 项与真实 MIME、Base64 data。     |
| response\_format           | object         | 否  | \{"type"\:"audio"} 可请求 WAV，以实际 MIME 为准。 |

不要把时长控制当精确保证。描述曲风和器乐特征比要求模仿特定歌手更适合安全使用。

## 返回值

| 字段                                | 说明                                 |
| --------------------------------- | ---------------------------------- |
| `id` / `status`                   | Interaction 标识与处理状态。               |
| `steps[].content[]`               | model\_output 中包含音频、歌词和曲式结构，须逐项解析。 |
| 音频项 `type` / `mime_type` / `data` | type=audio，data 是 Base64，不是 URL。   |
| 文本项 `text`                        | 歌词、结构或其他文字内容。                      |

SDK 的 `output_audio` / `output_text` 是便利属性；复杂交错结果应遍历 steps，不能只取最后一段导致遗漏。以下为响应结构节选：

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"[Instrumental]"},{"type":"audio","mime_type":"audio/mpeg","data":"<Base64音频>"}]}]}
```

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

设置 `GEMINI_API_KEY`。示例返回 JSON，将 audio 项 data 解码保存 MP3；将 model 改为 `lyria-3.5` 可生成完整歌曲。

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

## 错误码

| HTTP 状态               | 含义与处理                                     |
| --------------------- | ----------------------------------------- |
| 400                   | 请求字段或模型参数不合法，修正后再提交。                      |
| 401                   | API Key 缺失、无效或已过期。                        |
| 403                   | 当前项目或模型没有权限。                              |
| 404                   | 模型或路由不存在，检查地址与模型 ID。                      |
| 429                   | 速率或配额限制，区分余额不足与可退避重试的限流。                  |
| 500 / 502 / 503 / 504 | 服务或上游异常，保留请求 ID；对暂时故障做有限次退避，不要无限重试同一付费请求。 |

Google 错误对象使用 `error.code`、`error.status`、`error.message`，不要只按 HTTP 数字判断来源。本接口是同步请求，没有任务 ID 或轮询阶段。失败时不要把错误正文当作音频数据解码。

## 官方参考

[Google Lyria 音乐生成](https\://ai.google.dev/gemini-api/docs/music-generation)、[Interactions](https\://ai.google.dev/gemini-api/docs/interactions)。