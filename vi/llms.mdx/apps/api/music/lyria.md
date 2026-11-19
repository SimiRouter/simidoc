# Tạo nhạc Google Lyria

Các trang dưới đây theo API chính thức của Google. SimiRouter chưa mở khả năng này; mọi ví dụ kết nối trực tiếp Gemini API của Google AI Studio qua `https://generativelanguage.googleapis.com` bằng khóa Google API. Vertex AI cần giao thức riêng chưa được kiểm chứng trong trang này; không chỉ thay địa chỉ để gọi.

## Tổng quan API

`POST https://generativelanguage.googleapis.com/v1beta/interactions` với xác thực `x-goog-api-key: $GEMINI_API_KEY`. Lyria dùng Interactions, không generateContent hay `/audio/speech`.

| Mô hình                | Mục đích                               | Thời lượng và đầu ra                                        |
| ---------------------- | -------------------------------------- | ----------------------------------------------------------- |
| `lyria-3-clip-preview` | Đoạn, vòng lặp và nghe thử nhanh       | Cố định 30 giây, mặc định MP3.                              |
| `lyria-3.5`            | Bài có phiên khúc, điệp khúc, đoạn cầu | Lời nhắc điều khiển bài vài phút, mặc định MP3, có thể WAV. |

## Tham số yêu cầu

| Trường                     | Kiểu           | Bắt buộc     | Mô tả                                                  |
| -------------------------- | -------------- | ------------ | ------------------------------------------------------ |
| model                      | string         | Có           | Một mô hình Lyria bên trên.                            |
| input                      | string / array | Có           | Mô tả nhạc hoặc mảng text/image đa phương thức.        |
| input\[].text              | string         | Có điều kiện | Thể loại, nhịp, cảm xúc, nhạc cụ, lời và cấu trúc.     |
| input\[].mime\_type / data | string         | Có điều kiện | Ảnh dùng mục image, MIME thực và data Base64.          |
| response\_format           | object         | Không        | \{"type"\:"audio"} có thể yêu cầu WAV; theo MIME thực. |

Thời lượng không bảo đảm chính xác. Mô tả thể loại và nhạc cụ an toàn hơn yêu cầu giả giọng ca sĩ cụ thể.

## Phản hồi

| Trường                                     | Mô tả                                                         |
| ------------------------------------------ | ------------------------------------------------------------- |
| `id` / `status`                            | ID Interaction và trạng thái xử lý.                           |
| `steps[].content[]`                        | model\_output có âm thanh, lời, cấu trúc; phân tích từng mục. |
| Mục âm thanh `type` / `mime_type` / `data` | type=audio, data là Base64, không URL.                        |
| Mục văn bản `text`                         | Lời, cấu trúc hoặc chữ khác.                                  |

SDK có `output_audio` / `output_text` là tiện ích; kết quả xen kẽ cần duyệt steps, không chỉ lấy phần cuối gây sót. Trích cấu trúc\:

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"[Instrumental]"},{"type":"audio","mime_type":"audio/mpeg","data":"<Base64音频>"}]}]}
```

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Đặt `GEMINI_API_KEY`. Ví dụ nhận JSON, giải data mục audio lưu MP3; đổi model thành `lyria-3.5` để tạo bài đầy đủ.

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

## Mã lỗi

| Trạng thái HTTP       | Ý nghĩa và xử lý                                                                                                        |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 400                   | Trường yêu cầu hoặc tham số mô hình không hợp lệ; sửa rồi gửi lại.                                                      |
| 401                   | Khóa API thiếu, không hợp lệ hoặc hết hạn.                                                                              |
| 403                   | Không có quyền dự án hoặc mô hình.                                                                                      |
| 404                   | Không tìm thấy mô hình hoặc tuyến; kiểm tra địa chỉ và ID mô hình.                                                      |
| 429                   | Giới hạn tốc độ hoặc hạn mức; phân biệt thiếu số dư với giới hạn có thể thử lại.                                        |
| 500 / 502 / 503 / 504 | Lỗi dịch vụ hoặc thượng nguồn. Giữ ID yêu cầu và chờ trước khi thử lại; không lặp lại vô hạn cùng một yêu cầu tính phí. |

Đối tượng lỗi Google dùng `error.code`, `error.status` và `error.message`; đừng chỉ dựa vào con số HTTP để đoán nguồn. Giao diện này là yêu cầu đồng bộ\: không có ID tác vụ hay giai đoạn thăm dò. Không bao giờ giải mã nội dung lỗi thành dữ liệu âm thanh.

## Tham khảo chính thức

[Tạo nhạc Google Lyria](https\://ai.google.dev/gemini-api/docs/music-generation), [Interactions](https\://ai.google.dev/gemini-api/docs/interactions).