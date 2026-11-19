# Tạo Sora (API chính thức đã đóng)

**Sora 2 và Videos API OpenAI đã đóng ngày 24-09-2026.** Dưới chỉ cấu trúc, không hướng dẫn dùng hiện tại. Mô hình SimiRouter cùng tên/triển khai bên thứ ba cần xác minh nguồn, khả năng, giao thức; không gọi là OpenAI trực tiếp chính thức.

## Tổng quan API

`POST https://api.openai.com/v1/videos` là dạng yêu cầu cũ dùng khóa OpenAI Bearer, nay không gửi yêu cầu sản xuất mới.

## Tham số yêu cầu

| Trường           | Kiểu   | Bắt buộc | Mô tả                                                   |
| ---------------- | ------ | -------- | ------------------------------------------------------- |
| prompt           | string | Có       | Mô tả video bằng chữ.                                   |
| model            | string | Không    | Mô hình cũ sora-2/sora-2-pro đã đóng.                   |
| seconds          | string | Không    | Thời lượng cũ như 4, 8, 12, chỉ cấu trúc tham khảo.     |
| size             | string | Không    | Độ phân giải cũ như 1280x720.                           |
| input\_reference | object | Không    | Đối tượng ảnh tham chiếu chọn image\_url hoặc file\_id. |

## Phản hồi

Tạo cũ trả id, object, status, progress, model, created\_at, seconds, size. queued/in\_progress chưa xong.

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

**Ví dụ lưu trữ, không chứng minh vẫn chạy.** Dưới chỉ hiểu cấu trúc HTTP cũ, không dùng khóa thật thử tác vụ mới.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/videos'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'sora-2', 'prompt': '海边日落，平稳镜头。', 'seconds': '4', 'size': '1280x720'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "sora-2",
      "prompt": "海边日落，平稳镜头。",
      "seconds": "4",
      "size": "1280x720"
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
    curl "https://api.openai.com/v1/videos" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "sora-2",
        "prompt": "海边日落，平稳镜头。",
        "seconds": "4",
        "size": "1280x720"
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
      "model": "sora-2",
      "prompt": "海边日落，平稳镜头。",
      "seconds": "4",
      "size": "1280x720"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/videos", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

## Mã lỗi

Sau đóng không hứa phản hồi thành công. Cũ 401/403 xác thực/quyền, 404 không tài nguyên, 429 tốc độ; sinh lỗi có error.code/message. Không lặp vô hạn hay lưu lỗi thành MP4.

## Tham khảo chính thức

[Thông báo ngừng OpenAI](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create).