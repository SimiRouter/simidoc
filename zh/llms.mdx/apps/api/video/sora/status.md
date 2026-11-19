# 查询 Sora 任务（官方接口已关闭）

**OpenAI 官方 Sora 2 与 Videos API 已于 2026-09-24 关闭。** 下方仅保留接口结构参考，不是可用调用教程。SimiRouter 若存在同名模型或第三方兼容实现，其来源、能力与协议应另行确认，不能称作 OpenAI 官方直连。

## 接口说明

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID` 为原官方请求形式，使用 OpenAI Bearer Key；现在不应发送新生产请求。

## 请求参数

| 字段            | 类型     | 必填 | 说明        |
| ------------- | ------ | -- | --------- |
| video\_id（路径） | string | 是  | 原创建任务 ID。 |

## 返回值

原查询返回 id、status、progress、model、created\_at、completed\_at、expires\_at、error 等。completed 才可下载；failed 从 error.code/message 获取原因。

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

**归档示例，不可据此判断接口仍可运行。** 以下用于理解原来的 HTTP 调用结构；请勿使用真实 Key 进行新任务测试。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('GET', url, headers=headers, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      const response = await fetch(url, { method: "GET", headers, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID" \
      --fail-with-body \
      --max-time 180 \
      -X GET \
      -H "Authorization: Bearer $OPENAI_API_KEY"
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
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        req, err := http.NewRequest("GET", "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID", nil); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

官方服务关闭后不再有可承诺的成功响应。原接口按 HTTP 401/403 区分认证与权限，404 区分资源不存在，429 区分限流；生成失败还包含 error.code/message。不要对停用端点无限重试，也不要把错误正文保存为 MP4。

## 官方参考

[OpenAI 停用通知](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api)、[Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)。