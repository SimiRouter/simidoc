# Chép âm thanh

## Tổng quan API

`POST /v1/audio/transcriptions` với xác thực `Authorization: Bearer $SIMIROUTER_API_KEY`. Tải bằng `multipart/form-data`, để thư viện HTTP tạo boundary; không tự đặt Content-Type thiếu boundary.

API giữ ngôn ngữ gốc, không tự dịch Trung sang Anh. Nhận flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm. Kích thước và thời lượng còn chịu giới hạn mô hình/kênh.

<Callout type="warn" title="Một số mô hình ngừng 2027-02-26">
  `whisper-1`, `gpt-4o-transcribe` và `gpt-4o-mini-transcribe` (kể cả bản có ngày) đã bị đánh dấu ngừng dùng và sẽ dừng vào 2027-02-26. Ưu tiên `gpt-transcribe`; dùng `gpt-live-transcribe` cho thời gian thực hoặc `gpt-4o-transcribe-diarize` khi cần tách người nói.
</Callout>

## Tham số yêu cầu

| Trường                        | Kiểu            | Bắt buộc     | Mô tả                                                                                                 |
| ----------------------------- | --------------- | ------------ | ----------------------------------------------------------------------------------------------------- |
| file                          | file            | Có           | Tệp âm thanh thực, không phải chuỗi đường dẫn hay URL thường.                                         |
| model                         | string          | Có           | Như gpt-transcribe, gpt-4o-transcribe, gpt-4o-mini-transcribe, whisper-1 hoặc mô hình phân người nói. |
| language                      | string          | Không        | Mã ISO-639-1 ngôn ngữ đầu vào, như zh, en.                                                            |
| languages\[]                  | string\[]       | Không        | Danh sách ngôn ngữ ứng viên, chỉ dùng khi mô hình hỗ trợ.                                             |
| prompt                        | string          | Không        | Gợi ý thuật ngữ/ngữ cảnh cùng ngôn ngữ bản ghi; mô hình diarize không hỗ trợ.                         |
| keywords\[]                   | string\[]       | Không        | Gợi ý thuật ngữ, chỉ gpt-transcribe.                                                                  |
| response\_format              | string          | Không        | Mặc định json; text, srt, vtt, verbose\_json, diarized\_json tùy mô hình.                             |
| temperature                   | number          | Không        | 0–1, mặc định 0.                                                                                      |
| stream                        | boolean         | Không        | true trả SSE; whisper-1 không hỗ trợ.                                                                 |
| include\[]                    | string\[]       | Không        | logprobs cần mô hình hỗ trợ và response\_format=json.                                                 |
| timestamp\_granularities\[]   | string\[]       | Không        | word / segment, cần verbose\_json và mô hình hỗ trợ, không dùng diarize.                              |
| chunking\_strategy            | string / object | Có điều kiện | auto hoặc cấu hình server\_vad; bắt buộc với diarize trên 30 giây.                                    |
| known\_speaker\_names\[]      | string\[]       | Không        | Tên ngắn tối đa 4 người nói đã biết, khớp tham chiếu âm thanh.                                        |
| known\_speaker\_references\[] | string\[]       | Không        | data URL âm thanh 2–10 giây, khớp từng tên, chỉ cho mô hình hỗ trợ.                                   |

`gpt-4o-transcribe` và `gpt-4o-mini-transcribe` dùng đầu ra JSON; `whisper-1` hỗ trợ text, srt, vtt, verbose\_json và định dạng khác. Để gắn nhãn người nói, dùng mô hình diarize và `diarized_json`, không ép tham số cho mô hình thường.

## Phản hồi

| Trường                   | Mô tả                                                                          |
| ------------------------ | ------------------------------------------------------------------------------ |
| `text`                   | Bản chép đầy đủ.                                                               |
| `usage`                  | Thống kê dùng do mô hình trả, trường tùy mô hình.                              |
| `logprobs`               | Độ tin cậy token khi yêu cầu và được hỗ trợ.                                   |
| `language` / `duration`  | Ngôn ngữ và thời lượng giây trong verbose\_json.                               |
| `words[]` / `segments[]` | Phân đoạn khi hỗ trợ mốc thời gian/người nói, không phải mọi định dạng đều có. |

```json
{"text":"欢迎参加今天的会议。"}
```

`stream=true` trả phần chép tăng dần và sự kiện hoàn tất qua SSE khi hỗ trợ; phải liên tục đọc luồng. Vẫn tải toàn bộ tệp trước, không phải mic Realtime hai chiều.

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Chuẩn bị trong thư mục hiện tại `speech.wav` và đặt `SIMIROUTER_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'gpt-4o-mini-transcribe', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "gpt-4o-mini-transcribe");
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
    curl "https://api.dwchainless.com/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=gpt-4o-mini-transcribe" \
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
      check(writer.WriteField("model", "gpt-4o-mini-transcribe"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/transcriptions", &buffer); check(err)
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

[OpenAI Create transcription](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create).