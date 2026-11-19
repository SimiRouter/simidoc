# 下载 Sora 内容（官方接口已关闭）

**OpenAI 官方 Sora 2 与 Videos API 已于 2026-09-24 关闭。** 下方仅保留接口结构参考，不是可用调用教程。SimiRouter 若存在同名模型或第三方兼容实现，其来源、能力与协议应另行确认，不能称作 OpenAI 官方直连。

## 接口说明

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content` 为原官方请求形式，使用 OpenAI Bearer Key；现在不应发送新生产请求。

## 请求参数

| 字段             | 类型     | 必填 | 说明                                      |
| -------------- | ------ | -- | --------------------------------------- |
| video\_id（路径）  | string | 是  | 原创建任务 ID。                               |
| variant（query） | string | 否  | 原接口的 video、thumbnail、spritesheet 等内容类型。 |

## 返回值

原成功响应为视频 MP4 等二进制内容，不是 URL JSON；未完成时不能下载。此官方内容服务现已关闭。

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

**归档示例，不可据此判断接口仍可运行。** 以下用于理解原来的 HTTP 调用结构；请勿使用真实 Key 进行新任务测试。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('GET', url, headers=headers, timeout=180)
    response.raise_for_status()
    Path('video.mp4').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      const response = await fetch(url, { method: "GET", headers, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("video.mp4", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "video.mp4" ] || { printf '%s\n' "目标文件已存在：video.mp4" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X GET "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      --output "$temporary"; then
      mv "$temporary" "video.mp4"
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
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        req, err := http.NewRequest("GET", "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content", nil); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("video.mp4", data, 0600))
    }
    ```
  </Tab>
</Tabs>

## 错误码

官方服务关闭后不再有可承诺的成功响应。原接口按 HTTP 401/403 区分认证与权限，404 区分资源不存在，429 区分限流；生成失败还包含 error.code/message。不要对停用端点无限重试，也不要把错误正文保存为 MP4。

## 官方参考

[OpenAI 停用通知](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api)、[Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)。