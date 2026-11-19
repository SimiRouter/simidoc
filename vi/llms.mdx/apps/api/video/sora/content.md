# Tải Sora (API chính thức đã đóng)

**Sora 2 và Videos API OpenAI đã đóng ngày 24-09-2026.** Dưới chỉ cấu trúc, không hướng dẫn dùng hiện tại. Mô hình SimiRouter cùng tên/triển khai bên thứ ba cần xác minh nguồn, khả năng, giao thức; không gọi là OpenAI trực tiếp chính thức.

## Tổng quan API

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content` là dạng yêu cầu cũ dùng khóa OpenAI Bearer, nay không gửi yêu cầu sản xuất mới.

## Tham số yêu cầu

| Trường                | Kiểu   | Bắt buộc | Mô tả                                           |
| --------------------- | ------ | -------- | ----------------------------------------------- |
| video\_id (đường dẫn) | string | Có       | ID tác vụ tạo cũ.                               |
| variant (query)       | string | Không    | Loại nội dung cũ video, thumbnail, spritesheet. |

## Phản hồi

Thành công cũ trả nhị phân MP4, không URL JSON, chỉ tải khi xong. Dịch vụ hiện đã đóng.

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

**Ví dụ lưu trữ, không chứng minh vẫn chạy.** Dưới chỉ hiểu cấu trúc HTTP cũ, không dùng khóa thật thử tác vụ mới.

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

## Mã lỗi

Sau đóng không hứa phản hồi thành công. Cũ 401/403 xác thực/quyền, 404 không tài nguyên, 429 tốc độ; sinh lỗi có error.code/message. Không lặp vô hạn hay lưu lỗi thành MP4.

## Tham khảo chính thức

[Thông báo ngừng OpenAI](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create).