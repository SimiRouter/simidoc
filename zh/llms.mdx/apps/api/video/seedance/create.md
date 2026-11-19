# 创建 Seedance 视频任务

## 接口说明

`POST https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks`，`Authorization: Bearer $ARK_API_KEY`，JSON 正文。下方为官方直连协议，**不是** SimiRouter `/v1/video/generations` 映射保证。

## 请求参数

| 字段                        | 类型        | 必填 | 说明                                                                      |
| ------------------------- | --------- | -- | ----------------------------------------------------------------------- |
| model                     | string    | 是  | 已开通的 Seedance 模型 ID 或推理接入点 ID。                                          |
| content                   | object\[] | 是  | 文本和模型支持的图像/视频/音频内容项。                                                    |
| content\[].type           | string    | 是  | text、image\_url、video\_url、audio\_url、draft\_task，按模型能力使用。              |
| content\[].draft\_task.id | string    | 条件 | type=draft\_task 时的草稿任务 ID，用于基于草稿生成正式视频。                                |
| content\[].text           | string    | 条件 | type=text 的提示词。                                                         |
| content\[].image\_url.url | string    | 条件 | 可访问图片或模型允许的 data URL。                                                   |
| content\[].role           | string    | 否  | 如 first\_frame、last\_frame、reference\_image；按模型和素材类型使用。                 |
| resolution                | string    | 否  | 模型允许的分辨率：按模型可选 480p、720p、1080p、4k；草稿仅支持 480p。                           |
| ratio                     | string    | 否  | 如 16\:9、9\:16、1\:1、adaptive，具体支持以模型表为准。                                 |
| duration                  | integer   | 否  | 视频时长；范围按模型，支持自动时长的模型可用 -1。                                              |
| frames                    | integer   | 否  | 指定帧数，仅支持模型可用；与 duration 同时出现时以 frames 为准。                               |
| generate\_audio           | boolean   | 否  | 是否生成音轨，仅有声模型支持。                                                         |
| watermark                 | boolean   | 否  | 显式水印配置；需遵守合成内容标识要求。                                                     |
| seed                      | integer   | 否  | 随机种子，复现性并非逐像素保证。                                                        |
| return\_last\_frame       | boolean   | 否  | 请求返回尾帧图像。                                                               |
| callback\_url             | string    | 否  | 状态变化通知地址，接收方需处理重复与乱序通知。                                                 |
| execution\_expires\_after | integer   | 否  | 任务过期秒数，默认 172800，范围 3600–259200。                                        |
| service\_tier             | string    | 否  | default / flex，支持范围按模型。                                                 |
| draft                     | boolean   | 否  | 生成草稿视频，默认 false；支持的模型仅接受 480p。基于草稿生成正式视频改用 `content[].type=draft_task`。 |
| priority                  | integer   | 否  | 支持模型/服务等级的排队优先级，不适用于所有调用。                                               |

本示例选择 Seedance 2.5，使用纯文本和短视频参数。更换到 1.0 pro / 2.0 时，应按该版本能力删改字段，不能假设多模态参考、音频和草稿全部可用。

## 返回值

创建成功返回 `id`，不是完成的视频。保存 ID 后使用 [查询接口](/simidoc/zh/apps/api/video/seedance/status)。

```json
{"id":"cgt-example"}
```

请求超时不能说明服务端未受理，避免自动无限重发创建请求。回调接收端应按任务 ID 幂等更新状态。

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

设置官方 `ARK_API_KEY`；调用会创建可能计费的任务。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks'
    headers = {'Authorization': 'Bearer ' + os.environ['ARK_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'doubao-seedance-2-5-260628', 'content': [{'type': 'text', 'text': '海边日落时，一艘白色帆船缓缓驶过，镜头平稳。'}], 'duration': 5, 'ratio': '16:9', 'generate_audio': True, 'watermark': True}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks";
      const headers = { "Authorization": "Bearer " + process.env.ARK_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
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
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $ARK_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "doubao-seedance-2-5-260628",
        "content": [
          {
            "type": "text",
            "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
          }
        ],
        "duration": 5,
        "ratio": "16:9",
        "generate_audio": true,
        "watermark": true
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
      "model": "doubao-seedance-2-5-260628",
      "content": [
        {
          "type": "text",
          "text": "海边日落时，一艘白色帆船缓缓驶过，镜头平稳。"
        }
      ],
      "duration": 5,
      "ratio": "16:9",
      "generate_audio": true,
      "watermark": true
    }`)
      req, err := http.NewRequest("POST", "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("ARK_API_KEY"))
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

| HTTP 状态               | 含义与处理                                   |
| --------------------- | --------------------------------------- |
| 400 / 422             | 请求字段、文件格式或模型参数不合法，修正后再提交。               |
| 401                   | API Key 缺失、无效或已过期。                      |
| 403                   | 当前项目或模型没有权限。                            |
| 404                   | 模型、路由或任务不存在，检查地址与资源归属。                  |
| 413 / 415             | 上传过大或媒体类型不受支持。                          |
| 429                   | 速率或配额限制，区分余额不足与可退避重试的限流。                |
| 500 / 502 / 503 / 504 | 服务或上游异常，保留请求 ID；创建任务超时时先检查是否已受理，避免重复生成。 |

火山错误对象使用 `error.code`、`error.message`，并保留请求 ID。任务执行失败还需读取查询结果，不能由创建 HTTP 状态推断最终成功。

火山错误使用 `error.code`、`error.message` 和请求 ID，任务的生成失败还需在查询结果 error 字段读取。

## 官方参考

[火山方舟创建任务](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)、[官方调用教程](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh)。