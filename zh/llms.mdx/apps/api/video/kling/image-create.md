# Kling 图生视频

## 接口说明

`POST https://api-singapore.klingai.com/image-to-video/kling-3.0`，鉴权 `Authorization: Bearer $KLING_API_KEY`，正文为 JSON。示例使用 Kling 官方新版，不是 SimiRouter `/kling/v1/videos/...` 的旧版映射。

## 请求参数

| 字段                              | 类型        | 必填 | 说明                                      |
| ------------------------------- | --------- | -- | --------------------------------------- |
| contents                        | object\[] | 是  | 图像、文本、元素等输入内容。                          |
| contents\[].type                | string    | 是  | prompt、first\_frame、last\_frame 等支持的类型。 |
| contents\[].text                | string    | 条件 | prompt 项的动作、镜头和内容指令。                    |
| contents\[].url                 | string    | 条件 | first\_frame / last\_frame 的可访问图片 URL。  |
| settings.resolution             | string    | 否  | 720p（默认）、1080p、4k；按模型权限使用。              |
| settings.duration               | integer   | 否  | 默认 5 秒；当前 3.0 参考允许 3–15 秒。              |
| settings.audio                  | string    | 否  | off（默认）或 native，生成原生音轨。                 |
| settings.multi\_shot            | boolean   | 否  | 默认 true；本示例 false 使用单镜头。                |
| options.callback\_url           | string    | 否  | 任务状态回调；需自行实现安全接收与幂等处理。                  |
| options.external\_task\_id      | string    | 否  | 账户内唯一自定义任务 ID，用于查询，不覆盖系统 ID。            |
| options.watermark\_info.enabled | boolean   | 否  | 是否同时提供有水印结果，不支持自定义水印。                   |

不同模型能力限制不能仅由字段存在推断。多镜头提示应符合官方 shot 语法，每镜头时长总和与总时长一致。图生视频首尾帧、元素数量与素材格式限制以当前模型说明为准。

## 返回值

```json
{"code":0,"message":"Success","request_id":"request_example","data":{"id":"task_example","status":"submitted","create_time":1780000000000,"update_time":1780000000000}}
```

`data.id` 是查询使用的系统任务 ID，`data.status` 可为 submitted、processing、succeeded、failed；时间戳单位为毫秒。创建返回没有成品视频。不要读取旧版 `data.task_id` 或 `task_status`。

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

设置 Kling 官方 `KLING_API_KEY`。调用会创建计费任务。创建后参考 [任务查询](/simidoc/zh/apps/api/video/kling/image-status)。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api-singapore.klingai.com/image-to-video/kling-3.0'
    headers = {'Authorization': 'Bearer ' + os.environ['KLING_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'contents': [{'type': 'prompt', 'text': '镜头缓缓拉远，画面保持稳定。'}, {'type': 'first_frame', 'url': 'https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png'}], 'settings': {'resolution': '720p', 'duration': 5, 'audio': 'off', 'multi_shot': False}}, timeout=180)
    response.raise_for_status()
    result = response.json()
    if result.get("code") != 0:
        raise RuntimeError(result)
    print(result)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api-singapore.klingai.com/image-to-video/kling-3.0";
      const headers = { "Authorization": "Bearer " + process.env.KLING_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "contents": [
        {
          "type": "prompt",
          "text": "镜头缓缓拉远，画面保持稳定。"
        },
        {
          "type": "first_frame",
          "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
        }
      ],
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false
      }
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "https://api-singapore.klingai.com/image-to-video/kling-3.0" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $KLING_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "contents": [
          {
            "type": "prompt",
            "text": "镜头缓缓拉远，画面保持稳定。"
          },
          {
            "type": "first_frame",
            "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
          }
        ],
        "settings": {
          "resolution": "720p",
          "duration": 5,
          "audio": "off",
          "multi_shot": false
        }
      }'
    python3 - "$response" <<'PY_CHECK'
    import json, sys
    from pathlib import Path
    result = json.loads(Path(sys.argv[1]).read_text())
    if result.get("code") != 0:
        raise SystemExit(json.dumps(result, ensure_ascii=False))
    print(json.dumps(result, ensure_ascii=False))
    PY_CHECK
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "encoding/json"
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
      "contents": [
        {
          "type": "prompt",
          "text": "镜头缓缓拉远，画面保持稳定。"
        },
        {
          "type": "first_frame",
          "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
        }
      ],
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false
      }
    }`)
      req, err := http.NewRequest("POST", "https://api-singapore.klingai.com/image-to-video/kling-3.0", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("KLING_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      var result struct { Code int `json:"code"` }
      check(json.Unmarshal(data, &result))
      if result.Code != 0 { panic(string(data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## 错误码

| HTTP / 业务码                       | 说明                      |
| -------------------------------- | ----------------------- |
| 200 / 0                          | 请求成功，生成是否完成仍看任务 status。 |
| 400 / 1201                       | 参数错误，读取 message。        |
| 404 / 1202、1203                  | 方法错误或模型/资源不存在。          |
| 401                              | API Key 或旧版 JWT 无效。     |
| 400 / 1300、1301                  | 平台策略或内容安全限制，修正内容，不盲目重试。 |
| 429 / 1302、1303、1304             | 速率、并发或 IP 策略限制。         |
| 500 / 5000；503 / 5001；504 / 5002 | 服务错误或超时，保留 request\_id。 |

HTTP 200 不等于业务成功；首先检查 code=0，再读 data。

## 官方参考

[Kling 官方接口](https\://kling.ai/document-api/apiReference/model/imageToVideo)、[鉴权](https\://kling.ai/document-api/api/get-started/authentication)、[错误码](https\://kling.ai/document-api/api/get-started/error-codes)。