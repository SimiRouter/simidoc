# Tích hợp âm thanh MiMo

## Tổng quan API

MiMo hỗ trợ tổng hợp, chép lời, thiết kế và nhân bản giọng tham chiếu. Phân biệt hai giao diện\:

| Giao thức                            | Địa chỉ / điểm cuối                                                    | Xác thực                                       | Đầu ra                              |
| ------------------------------------ | ---------------------------------------------------------------------- | ---------------------------------------------- | ----------------------------------- |
| Dịch vụ âm thanh tương thích độc lập | Địa chỉ triển khai cộng `/v1/audio/speech`, `/v1/audio/transcriptions` | Khóa Bearer riêng dịch vụ; cũng nhận x-api-key | Byte âm thanh hoặc kết quả chép lời |
| API gốc Xiaomi                       | `https://api.xiaomimimo.com/v1/chat/completions`                       | api-key hoặc khóa Bearer MiMo chính thức       | Chat Completions JSON / SSE         |

**Tuyến tương thích không phải điểm cuối gốc Xiaomi.** Ví dụ tương thích mặc định kết nối dịch vụ độc lập tại `http://127.0.0.1:8080`; thay máy chủ, cổng nếu triển khai nơi khác. Xác nhận riêng tuyến công khai SimiRouter; không dùng lẫn khóa dịch vụ độc lập.

## Tham số yêu cầu

### Tổng hợp giọng\: POST /v1/audio/speech

| Trường           | Kiểu            | Bắt buộc | Mô tả                                                                                              |
| ---------------- | --------------- | -------- | -------------------------------------------------------------------------------------------------- |
| model            | string          | Có       | mimo-v2.5-tts, mimo-v2.5-tts-voicedesign, mimo-v2.5-tts-voiceclone.                                |
| input            | string          | Có       | Văn bản không rỗng; mặc định tối đa 4096 ký tự, triển khai có thể chỉnh.                           |
| voice            | string / object | Có       | Giọng có sẵn; nhân bản dùng data URL âm thanh hoặc \{"id"\:"voice\_..."} do dịch vụ tạo.           |
| instructions     | string          | Không    | Chỉ dẫn giọng điệu/phong cách, tối đa 4096 ký tự.                                                  |
| style            | string          | Không    | Trường mở rộng dịch vụ tương thích, ưu tiên hơn instructions; voicedesign dùng mô tả giọng.        |
| speed            | number          | Không    | 0.25–4, mặc định 1; chuyển thành lời nhắc phong cách, không bảo đảm đổi tốc độ chính xác từng mẫu. |
| response\_format | string          | Không    | wav, mp3, opus, aac, flac, pcm. MiMo trực tiếp mặc định wav; nên chỉ định rõ.                      |
| stream\_format   | string          | Không    | Chỉ nhận audio; sse trả 400. Không cung cấp luồng tổng hợp độ trễ thấp thượng nguồn.               |

Ánh xạ giọng\: alloy→Bingtang, echo→Moli, fable→Baihua, onyx→Suda, nova→Mia, shimmer→Chloe, dean→Dean, milo→Milo. Là ánh xạ dịch vụ, không phải giọng OpenAI cùng tên.

### Chép lời\: POST /v1/audio/transcriptions

| Trường                      | Kiểu      | Bắt buộc | Mô tả                                                                               |
| --------------------------- | --------- | -------- | ----------------------------------------------------------------------------------- |
| file                        | file      | Có       | Tệp multipart; mặc định tối đa 25 MiB, có thể cấu hình.                             |
| model                       | string    | Có       | mimo-v2.5-asr.                                                                      |
| language                    | string    | Không    | auto (mặc định), zh, en.                                                            |
| languages\[]                | string\[] | Không    | Ngôn ngữ ứng viên, không dùng cùng language; nhiều ứng viên gộp thành tự nhận dạng. |
| response\_format            | string    | Không    | json (mặc định), text, verbose\_json, srt, vtt. Không hỗ trợ diarized\_json.        |
| stream                      | boolean   | Không    | Phát SSE sau khi chép xong, không phải vừa nghe vừa chép ở thượng nguồn.            |
| timestamp\_granularities\[] | string\[] | Không    | Không hỗ trợ; giá trị không rỗng trả 400, không giả mốc từ/phân đoạn.               |

Dịch vụ nhận mp3, wav, aac, flac, m4a, mp4, mpeg, mpga, oga, ogg, opus, webm; định dạng không gốc cần bộ chuyển đổi. ASR gốc Xiaomi chỉ nhận MP3/WAV; không dùng lẫn giới hạn.

## Phản hồi

* TTS thành công trả byte âm thanh đúng MIME sau khi tổng hợp xong, không có task\_id công khai.
* ASR JSON là `{"text":"识别文字"}`; text trả văn bản thuần.
* verbose\_json có task, language, duration, text và segments rỗng, **không cung cấp mốc phân đoạn thật**. SRT/VTT là phụ đề toàn đoạn, không căn từng từ.
* stream=true chỉ bọc bản chép cuối trong SSE, không chứng minh thượng nguồn nhận dạng thời gian thực.

## Ví dụ mã

Ví dụ Python cần `python3 -m pip install requests`; Node.js 18+ dùng fetch tích hợp, Go dùng thư viện chuẩn.

### Văn bản thành giọng nói

Đặt của dịch vụ độc lập `MIMO_AUDIO_API_KEY`. Đầu ra là `mimo-speech.wav`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'http://127.0.0.1:8080/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'mimo-v2.5-tts', 'input': '你好，欢迎使用 MiMo 语音。', 'voice': 'alloy', 'response_format': 'wav'}, timeout=180)
    response.raise_for_status()
    Path('mimo-speech.wav').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("mimo-speech.wav", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "mimo-speech.wav" ] || { printf '%s\n' "目标文件已存在：mimo-speech.wav" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "http://127.0.0.1:8080/v1/audio/speech" \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }' \
      --output "$temporary"; then
      mv "$temporary" "mimo-speech.wav"
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
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }`)
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("mimo-speech.wav", data, 0600))
    }
    ```
  </Tab>
</Tabs>

### Giọng nói thành văn bản

Chuẩn bị `speech.wav`. Xác thực vẫn dùng khóa dịch vụ độc lập.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'http://127.0.0.1:8080/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'mimo-v2.5-asr', 'language': 'auto', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "mimo-v2.5-asr");
      form.append("language", "auto");
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
    curl "http://127.0.0.1:8080/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=mimo-v2.5-asr" \
      -F "language=auto" \
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
      check(writer.WriteField("model", "mimo-v2.5-asr"))
      check(writer.WriteField("language", "auto"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/transcriptions", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
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

### Thiết kế và nhân bản giọng

Để thiết kế giọng, đổi model thành `mimo-v2.5-tts-voicedesign`, thêm `style: "温暖低沉的成年男声，普通话清晰"`. Để nhân bản, đổi model thành `mimo-v2.5-tts-voiceclone`, đặt voice thành `data:audio/wav;base64,<真实参考音频>`. Không gửi Base64 rỗng, giả đuôi tệp hoặc giọng người khác chưa cho phép.

```python
import base64
import os
from pathlib import Path
import requests
reference = base64.b64encode(Path("reference.wav").read_bytes()).decode("ascii")
response = requests.post("http://127.0.0.1:8080/v1/audio/speech",
    headers={"Authorization": "Bearer " + os.environ["MIMO_AUDIO_API_KEY"]},
    json={"model":"mimo-v2.5-tts-voiceclone","input":"这是一条授权声音示例。",
          "voice":"data:audio/wav;base64," + reference,"response_format":"wav"}, timeout=180)
response.raise_for_status()
Path("clone.wav").write_bytes(response.content)
```

### Giao thức gốc Xiaomi

TTS chính thức dùng `assistant` tin nhắn chứa lời đọc, `user` tin nhắn chứa phong cách. Đây là JSON chính thức, không gửi tới `/audio/speech`\:

```json
{"model":"mimo-v2.5-tts","messages":[{"role":"user","content":"温暖自然"},{"role":"assistant","content":"你好，欢迎使用 MiMo。"}],"audio":{"format":"wav","voice":"mimo_default"},"stream":false}
```

Âm thanh trả về chính thức nằm tại `choices[0].message.audio.data`, cần giải Base64. ASR gốc đặt âm thanh vào `messages[0].content`\:

```json
{"model":"mimo-v2.5-asr","messages":[{"role":"user","content":[{"type":"input_audio","input_audio":{"data":"data:audio/wav;base64,<真实Base64>"}}]}],"asr_options":{"language":"auto"},"stream":false}
```

Văn bản ASR gốc nằm tại `choices[0].message.content`. Nếu data URL có định dạng, format tùy chọn; Base64 thuần bắt buộc `format: "wav"` hoặc `"mp3"`, nếu cùng đặt phải khớp.

## Mã lỗi

| HTTP / code                       | Ý nghĩa                                                       |
| --------------------------------- | ------------------------------------------------------------- |
| 400 / unsupported\_audio\_format  | Định dạng đầu ra TTS không hợp lệ.                            |
| 400 / speech\_sse\_not\_supported | Dịch vụ tương thích không hỗ trợ TTS SSE.                     |
| 400 / diarization\_not\_supported | ASR không hỗ trợ đầu ra phân người nói.                       |
| 400 / timestamps\_not\_supported  | ASR không hỗ trợ độ chi tiết mốc thời gian.                   |
| 401 / 403                         | Sai khóa hoặc quyền dịch vụ độc lập.                          |
| 404 / voice\_not\_found           | Giọng tùy chỉnh không tồn tại hoặc không thuộc khóa hiện tại. |
| 413 / input\_too\_large           | Văn bản hoặc phương tiện vượt giới hạn.                       |
| 415 / unsupported\_file\_type     | Đuôi tệp hoặc MIME không hỗ trợ.                              |
| 422 / invalid\_audio              | Không giải mã được phương tiện.                               |
| 502 / invalid\_audio\_output      | Thượng nguồn không trả âm thanh hợp lệ.                       |
| 503 / audio\_failover\_exhausted  | Dịch vụ âm thanh tạm không khả dụng.                          |

Tải giọng nhân bản thay đổi trạng thái; không lặp lại mù quáng sau hết thời gian.

## Tham khảo chính thức

[MiMo TTS](https\://mimo.mi.com/docs/en-US/api/audio/tts), [MiMo ASR](https\://mimo.mi.com/docs/en-US/api/audio/Speech-Recognition). Các trang này mô tả giao thức gốc, không coi mở rộng tương thích là khả năng gốc của hãng.