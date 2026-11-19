# Hiểu video Gemini

## Tổng quan API

Nhận video có sẵn, trả chữ, không tạo video mới. Dưới dùng **Google Interactions chính thức**\: `POST https://generativelanguage.googleapis.com/v1beta/interactions` với xác thực `x-goog-api-key: $GEMINI_API_KEY`. Không là tạo Seedance/Kling, không chứng minh SimiRouter ánh xạ mọi đầu vào Google.

## Tham số yêu cầu

| Trường              | Kiểu    | Bắt buộc     | Mô tả                                                               |
| ------------------- | ------- | ------------ | ------------------------------------------------------------------- |
| model               | string  | Có           | Mô hình video như gemini-3.8-flash.                                 |
| input               | array   | Có           | Tài nguyên video và câu hỏi text.                                   |
| input\[].type       | string  | Có           | video hoặc text.                                                    |
| input\[].data       | string  | Có điều kiện | Base64 video ngắn, chọn nó hoặc uri.                                |
| input\[].mime\_type | string  | Có điều kiện | Như video/mp4, khớp mã hóa thật.                                    |
| input\[].uri        | string  | Có điều kiện | URI Google tải xong ACTIVE hoặc URL công khai mô hình hỗ trợ.       |
| input\[].text       | string  | Có điều kiện | Tóm tắt, hỏi đáp hoặc câu hỏi theo khoảng thời gian.                |
| stream / background | boolean | Không        | Phân tích dài có luồng/nền, cần quy trình sự kiện/tác vụ tương ứng. |

Ví dụ MP4 ngắn tổng yêu cầu dưới 20 MB. Lớn/tái dùng ưu tiên Files Google, chờ ACTIVE sau tải; FAILED dừng, không polling vô hạn. URL công khai, Cloud Storage, nội tuyến là đường khác, không đổi tùy ý.

## Phản hồi

Interactions `steps[]` chứa model\_output, mục chữ là `content[].type=text` và `text`. SDK output\_text tiện ích. Mốc thời gian do mô hình hiểu, đối chiếu bản gốc, không coi chứng cứ chính xác/từng khung.

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"00:10 出现海面上的帆船，随后镜头向右移动。"}]}]}
```

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Chuẩn bị video ngắn `video.mp4` và đặt Google chính thức `GEMINI_API_KEY`. Không gọi mô hình sinh trả phí hay quản lý tệp, nhưng suy luận vẫn có thể tính phí.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")}]}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": (await readFile("video.mp4")).toString("base64")
        }
      ]
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
    set -eu
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "encoding/base64"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      media, err := os.ReadFile("video.mp4"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
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

| Trạng thái HTTP       | Ý nghĩa và xử lý                                                                                                                                         |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Trường, định dạng tệp hoặc tham số không hợp lệ; sửa rồi gửi lại.                                                                                        |
| 401                   | Khóa API thiếu, không hợp lệ hoặc hết hạn.                                                                                                               |
| 403                   | Không có quyền dự án hoặc mô hình.                                                                                                                       |
| 404                   | Mô hình, tuyến hoặc tài nguyên đầu vào không tồn tại; kiểm tra địa chỉ, ID mô hình và trạng thái tệp.                                                    |
| 413 / 415             | Tệp quá lớn hoặc loại phương tiện không hỗ trợ.                                                                                                          |
| 429                   | Giới hạn tốc độ/hạn mức; phân biệt thiếu số dư với giới hạn có thể thử lại.                                                                              |
| 500 / 502 / 503 / 504 | Lỗi dịch vụ/thượng nguồn. Giữ ID yêu cầu; sau khi yêu cầu đồng bộ hết thời gian, kiểm tra log hoặc trạng thái trước khi thử lại để tránh tính phí trùng. |

Lỗi Google dùng `error.code`, `error.status`, `error.message`; không coi nội dung lỗi là kết quả phân tích bình thường.

## Tham khảo chính thức

[Hiểu video Google](https\://ai.google.dev/gemini-api/docs/video-understanding), [Files](https\://ai.google.dev/gemini-api/docs/files).