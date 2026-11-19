# Hiểu âm thanh Gemini

## Tổng quan API

Gemini nhận bản ghi như đầu vào đa phương thức, trả văn bản cho chép lời, tóm tắt, mô tả người nói và phân tích theo thời gian. Không phải TTS hay API chuyên dụng `/audio/transcriptions`. Trang dùng Google chính thức `POST /v1beta/interactions` với xác thực `x-goog-api-key: $GEMINI_API_KEY`; không đảm bảo proxy gốc SimiRouter khả dụng.

## Tham số yêu cầu

| Trường              | Kiểu    | Bắt buộc     | Mô tả                                                         |
| ------------------- | ------- | ------------ | ------------------------------------------------------------- |
| model               | string  | Có           | Mô hình nhận âm thanh, như gemini-3.8-flash.                  |
| input               | array   | Có           | Mảng kết hợp chỉ dẫn text và đầu vào audio.                   |
| input\[].type       | string  | Có           | Dùng text cho chỉ dẫn, audio cho bản ghi.                     |
| input\[].data       | string  | Có điều kiện | Âm thanh Base64 nội tuyến, không có tiền tố data URL.         |
| input\[].uri        | string  | Có điều kiện | URI do Google Files API trả về; chọn URI hoặc data nội tuyến. |
| input\[].mime\_type | string  | Có điều kiện | Ví dụ audio/wav, audio/mpeg; phải khớp nội dung thực.         |
| stream              | boolean | Không        | Có thể nhận văn bản theo luồng, không phải tải mic liên tục.  |

Bản ghi lớn nên tải qua Google Files API rồi tham chiếu URI. Nội tuyến phải đáp ứng giới hạn mô hình và thân yêu cầu. Đường dẫn cục bộ không phải URI đám mây đọc được; mốc thời gian mô hình không phải căn chỉnh cưỡng bức chuyên nghiệp.

## Phản hồi

Văn bản nằm trong `steps[].content[]` ở các mục text; SDK có `output_text`. Với bản ghi dài, kiểm tra trạng thái kết thúc và cắt ngắn. Trích phản hồi\:

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"录音主要介绍了会议议程。"}]}]}
```

## Ví dụ mã

Python 3 và Go dùng thư viện chuẩn; Node.js 18+ dùng fetch tích hợp.

Chuẩn bị bản ghi ngắn trong thư mục hiện tại `speech.wav` và đặt `GEMINI_API_KEY`. Ví dụ đọc tệp thật, mã hóa Base64, gửi rồi xuất JSON đầy đủ.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import json, urllib.request

    url = os.environ.get('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com').rstrip('/') + '/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")}]}
    headers['Content-Type'] = 'application/json'
    request = urllib.request.Request(url, data=json.dumps(body).encode(), headers=headers, method='POST')
    with urllib.request.urlopen(request, timeout=180) as response:
        print(response.read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const url = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "") + "/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": (await readFile("speech.wav")).toString("base64")
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
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "${base%/}/v1beta/interactions" \
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
      if os.Getenv("GEMINI_API_KEY")=="" { panic("请设置 GEMINI_API_KEY") }
      base:=os.Getenv("GEMINI_BASE_URL"); if base=="" { base="https://generativelanguage.googleapis.com" }
      media, err := os.ReadFile("speech.wav"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", body); check(err)
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

| Trạng thái HTTP       | Ý nghĩa và xử lý                                                                                                        |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 400                   | Trường yêu cầu hoặc tham số mô hình không hợp lệ; sửa rồi gửi lại.                                                      |
| 401                   | Khóa API thiếu, không hợp lệ hoặc hết hạn.                                                                              |
| 403                   | Không có quyền dự án hoặc mô hình.                                                                                      |
| 404                   | Không tìm thấy mô hình hoặc tuyến; kiểm tra địa chỉ và ID mô hình.                                                      |
| 429                   | Giới hạn tốc độ hoặc hạn mức; phân biệt thiếu số dư với giới hạn có thể thử lại.                                        |
| 500 / 502 / 503 / 504 | Lỗi dịch vụ hoặc thượng nguồn. Giữ ID yêu cầu và chờ trước khi thử lại; không lặp lại vô hạn cùng một yêu cầu tính phí. |

Đối tượng lỗi Google dùng `error.code`, `error.status` và `error.message`; đừng chỉ dựa vào con số HTTP để đoán nguồn. Giao diện này là yêu cầu đồng bộ\: không có ID tác vụ hay giai đoạn thăm dò. Không bao giờ coi nội dung lỗi là bản ghi hay bản tóm tắt.

## Tham khảo chính thức

[Hiểu âm thanh Google](https\://ai.google.dev/gemini-api/docs/audio), [Google Files](https\://ai.google.dev/gemini-api/docs/files).