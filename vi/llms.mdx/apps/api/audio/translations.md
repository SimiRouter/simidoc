# Dịch âm thanh

## Tổng quan API

`POST /v1/audio/translations` nhận bản ghi và xuất **tiếng Anh**, không nhận tham số ngôn ngữ đích tùy ý. Xác thực dùng `Authorization: Bearer $SIMIROUTER_API_KEY`, thân yêu cầu là `multipart/form-data`. Tham khảo Audio Translations API OpenAI; tài khoản cần kênh mô hình tương ứng.

<Callout type="warn" title="Endpoint và mô hình ngừng 2027-02-26">
  OpenAI đã đánh dấu ngừng dùng `/v1/audio/translations` và `whisper-1`, dừng vào 2027-02-26. Thay thế là Realtime API `/v1/realtime/translations` với `gpt-realtime-translate`, cần thay đổi tích hợp riêng. Trang này chỉ giữ làm tham khảo trước khi chuyển đổi.
</Callout>

## Tham số yêu cầu

| Trường           | Kiểu   | Bắt buộc | Mô tả                                                              |
| ---------------- | ------ | -------- | ------------------------------------------------------------------ |
| file             | file   | Có       | Tệp ghi thực\: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm.    |
| model            | string | Có       | Điểm cuối dùng whisper-1, không thay bằng mô hình chép lời thường. |
| prompt           | string | Không    | Gợi ý thuật ngữ/ngữ cảnh tiếng Anh.                                |
| response\_format | string | Không    | json (mặc định), text, srt, verbose\_json, vtt.                    |
| temperature      | number | Không    | 0–1, mặc định 0.                                                   |

## Phản hồi

JSON trả `text` chứa bản dịch Anh. `verbose_json` còn có `duration` (giây) và `language` (english) , `segments[]`. Định dạng phụ đề trả văn bản trực tiếp, không phân tích JSON. Một yêu cầu xử lý tệp, không có stream; dịch thời gian thực là giao diện phiên riêng.

```json
{"text":"Welcome to today's meeting."}
```

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Chuẩn bị `speech.wav` và đặt `SIMIROUTER_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/translations'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'whisper-1', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/translations";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "whisper-1");
      form.append("response_format", "json");
      const body = form;
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.dwchainless.com/v1/audio/translations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=whisper-1" \
      -F "response_format=json"
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
      "bytes"
      "mime/multipart"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      var buffer bytes.Buffer
      writer := multipart.NewWriter(&buffer)
      source, err := os.Open("speech.wav"); check(err)
      part, err := writer.CreateFormFile("file", "speech.wav"); check(err)
      _, err = io.Copy(part, source); source.Close(); check(err)
      check(writer.WriteField("model", "whisper-1"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/translations", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", writer.FormDataContentType())
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
| 413                   | Tệp vượt giới hạn tải lên; nén hoặc dùng tệp nhỏ hơn.                                                                   |
| 429                   | Giới hạn tốc độ hoặc hạn mức; phân biệt thiếu số dư với giới hạn có thể thử lại.                                        |
| 500 / 502 / 503 / 504 | Lỗi dịch vụ hoặc thượng nguồn. Giữ ID yêu cầu và chờ trước khi thử lại; không lặp lại vô hạn cùng một yêu cầu tính phí. |

Các trường `error.message`, `error.type` và `error.code` trong thân lỗi cho biết nguyên nhân cụ thể hơn mã HTTP. Giao diện này là yêu cầu đồng bộ\: không có ID tác vụ hay giai đoạn thăm dò. Không bao giờ lưu nội dung lỗi thành bản ghi lời.

## Tham khảo chính thức

[OpenAI Create translation](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create).