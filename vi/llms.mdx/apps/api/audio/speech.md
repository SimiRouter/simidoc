# Văn bản thành giọng

## Tổng quan API

`POST /v1/audio/speech` tổng hợp `input` thành giọng nói. Với SimiRouter, địa chỉ gốc là `https://api.dwchainless.com` với xác thực `Authorization: Bearer $SIMIROUTER_API_KEY`, thân yêu cầu là `application/json`. Tham khảo Speech API OpenAI chính thức; mô hình và truyền tham số tùy kênh đã chọn.

<Callout type="warn" title="Mô hình ngừng hoạt động 2027-01-06">
  `gpt-4o-mini-tts`, `tts-1` và `tts-1-hd` đã bị OpenAI đánh dấu không còn dùng và sẽ ngừng vào 2027-01-06. Mô hình thay thế chính thức là `gpt-realtime-2.1-mini` trên Realtime API, không hỗ trợ `/v1/audio/speech`, nên cần chuyển sang `/v1/realtime`. Ví dụ vẫn dùng mô hình hiện có thể định tuyến; hãy xác nhận kênh đã cung cấp mô hình thay thế trước khi gọi.
</Callout>

## Tham số yêu cầu

| Trường           | Kiểu            | Bắt buộc | Mô tả                                                                          |
| ---------------- | --------------- | -------- | ------------------------------------------------------------------------------ |
| model            | string          | Có       | Mô hình TTS khả dụng như gpt-4o-mini-tts; không dùng mô hình chép lời.         |
| input            | string          | Có       | Văn bản đọc, tối đa 4096 ký tự.                                                |
| voice            | string / object | Có       | Tên giọng tích hợp hoặc giọng tùy chỉnh có quyền \{"id"\:"voice\_..."}.        |
| instructions     | string          | Không    | Chỉ dẫn giọng điệu/phong cách, tối đa 4096 ký tự; tts-1/tts-1-hd không hỗ trợ. |
| response\_format | string          | Không    | mp3 (mặc định), opus, aac, flac, wav, pcm.                                     |
| speed            | number          | Không    | 0.25–4.0, mặc định 1.                                                          |
| stream\_format   | string          | Không    | audio (mặc định) hoặc sse; tts-1/tts-1-hd không hỗ trợ sse.                    |

Giọng tích hợp gồm `alloy`, `ash`, `ballad`, `coral`, `echo`, `fable`, `onyx`, `nova`, `sage`, `shimmer`, `verse`, `marin`, `cedar`; mô hình có thể chỉ hỗ trợ một phần. Tên giọng không chỉ ngôn ngữ cố định.

## Phản hồi

Thành công trả byte âm thanh, không phải JSON chứa URL. Đuôi tệp phải khớp `response_format`. PCM là mẫu thô không container, cần thông số phát phù hợp. Phản hồi mặc định có thể đọc từng khối để giảm chờ.

`stream_format: "sse"` dùng luồng sự kiện; phân tích và giải mã phần âm thanh tăng dần, không lưu toàn bộ SSE thành MP3. Khả dụng SSE cũng tùy kênh.

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

Trước tiên đặt `SIMIROUTER_API_KEY`. Ví dụ chọn MP3 và dừng khi HTTP lỗi, tránh lưu JSON lỗi thành âm thanh.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.dwchainless.com/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gpt-4o-mini-tts', 'input': '你好，欢迎使用语音合成。', 'voice': 'alloy', 'response_format': 'mp3'}, timeout=180)
    response.raise_for_status()
    Path('speech.mp3').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("speech.mp3", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "speech.mp3" ] || { printf '%s\n' "目标文件已存在：speech.mp3" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "https://api.dwchainless.com/v1/audio/speech" \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }' \
      --output "$temporary"; then
      mv "$temporary" "speech.mp3"
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
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }`)
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("speech.mp3", data, 0600))
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

Các trường `error.message`, `error.type` và `error.code` trong thân lỗi cho biết nguyên nhân cụ thể hơn mã HTTP. Giao diện này là yêu cầu đồng bộ\: không có ID tác vụ hay giai đoạn thăm dò. Không bao giờ lưu nội dung lỗi thành tệp âm thanh.

## Tham khảo chính thức

[OpenAI Create speech](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create).