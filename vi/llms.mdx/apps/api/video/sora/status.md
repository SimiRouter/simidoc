# Truy vấn Sora (API chính thức đã đóng)

**Sora 2 và Videos API OpenAI đã đóng ngày 24-09-2026.** Dưới chỉ cấu trúc, không hướng dẫn dùng hiện tại. Mô hình SimiRouter cùng tên/triển khai bên thứ ba cần xác minh nguồn, khả năng, giao thức; không gọi là OpenAI trực tiếp chính thức.

## Tổng quan API

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID` là dạng yêu cầu cũ dùng khóa OpenAI Bearer, nay không gửi yêu cầu sản xuất mới.

## Tham số yêu cầu

| Trường                | Kiểu   | Bắt buộc | Mô tả             |
| --------------------- | ------ | -------- | ----------------- |
| video\_id (đường dẫn) | string | Có       | ID tác vụ tạo cũ. |

## Phản hồi

Cũ trả id, status, progress, model, created\_at, completed\_at, expires\_at, error. completed mới tải; failed đọc error.code/message.

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

**Ví dụ lưu trữ, không chứng minh vẫn chạy.** Dưới chỉ hiểu cấu trúc HTTP cũ, không dùng khóa thật thử tác vụ mới.

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

## Mã lỗi

Sau đóng không hứa phản hồi thành công. Cũ 401/403 xác thực/quyền, 404 không tài nguyên, 429 tốc độ; sinh lỗi có error.code/message. Không lặp vô hạn hay lưu lỗi thành MP4.

## Tham khảo chính thức

[Thông báo ngừng OpenAI](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create).