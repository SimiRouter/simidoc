# Tổng hợp giọng nói Gemini

## Tổng quan API

Gemini TTS đọc chính xác văn bản được chỉ định, khác Live API tương tác. Ví dụ dùng **Google Interactions API chính thức**\: `POST https://generativelanguage.googleapis.com/v1beta/interactions` với xác thực `x-goog-api-key: $GEMINI_API_KEY`. Không phải OpenAI `/audio/speech`; đổi tên miền và khóa không biến thành lệnh gọi cổng.

`gemini-3.8-flash-tts` và `gemini-3.8-flash-lite-tts` dùng cấu trúc này. Gemini 3.1/2.5 Preview TTS còn hỗ trợ dùng cấu hình generateContent riêng; không trộn hai thế hệ. Kiểm tra hỗ trợ Interactions theo kênh SimiRouter.

## Tham số yêu cầu

| Trường                            | Kiểu           | Bắt buộc     | Mô tả                                                                      |
| --------------------------------- | -------------- | ------------ | -------------------------------------------------------------------------- |
| model                             | string         | Có           | Ví dụ gemini-3.8-flash-tts.                                                |
| input                             | string / array | Có           | Văn bản đọc; chú thích phong cách dùng cấu trúc user\_input/content.       |
| input\[].content\[].text          | string         | Có           | Nội dung đọc nguyên văn.                                                   |
| annotations\[].type               | string         | Có điều kiện | Chú thích phong cách dùng speech\_metadata.                                |
| annotations\[].style              | string         | Không        | Giọng điệu, âm sắc địa phương hoặc nhịp lượt này.                          |
| annotations\[].speaker            | string         | Có điều kiện | Với nhiều người, khớp tên speaker trong cấu hình.                          |
| response\_format                  | object         | Không        | Ví dụ dùng \{"type"\:"audio"}; theo MIME trả về.                           |
| generation\_config.speech\_config | array / object | Có           | Một người dùng \[\{"voice"\:"Kore"}]; nhiều người dùng đối tượng speakers. |
| stream                            | boolean        | Không        | true trả sự kiện tăng dần khi hỗ trợ; không lưu SSE thành tệp âm thanh.    |

Cấu hình nhiều người dùng `{"speakers":[{"speaker":"Joe","voice":"Kore"},{"speaker":"Jane","voice":"Puck"}]}`. speech\_metadata.speaker mỗi lượt phải tham chiếu Joe hoặc Jane, không chỉ ghép lời thoại chưa gắn nhãn. Thiết kế/nhân bản giọng cần voice ID và quyền sử dụng.

## Phản hồi

REST trả đối tượng Interactions; âm thanh nằm trong `steps[]` dưới `type=model_output` — `content[]`; mục âm thanh có `type=audio`, `data` là Base64 và `mime_type` chỉ định định dạng. SDK có `output_audio` là thuộc tính tiện ích, không phải trường gốc REST luôn có. WAV mặc định giải mã và lưu trực tiếp; không thêm đầu WAV nữa.

```json
{"steps":[{"type":"model_output","content":[{"type":"audio","mime_type":"audio/wav","data":"<Base64音频>"}]}]}
```

## Ví dụ mã

Đặt Google chính thức `GEMINI_API_KEY`. Python 3, Node.js 18+ và Go dùng thư viện chuẩn; curl cần Python 3 phân tích. Mặc định trực tiếp Google; `GEMINI_BASE_URL` dùng kiểm thử cục bộ hoặc proxy giao thức gốc được phép, địa chỉ không có `/v1beta`.

Ví dụ kiểm tra `status=completed` rồi giải mã mọi mục âm thanh, lưu thành `speech-1.wav` và các tệp khác, không ghi đè. Nếu MIME khác, xử lý theo định dạng thực, không chỉ đổi đuôi.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import base64, json, os, urllib.request
    key = os.environ["GEMINI_API_KEY"]
    base = os.environ.get("GEMINI_BASE_URL", "https://generativelanguage.googleapis.com").rstrip("/")
    body = json.loads(r'''{
      "model": "gemini-3.8-flash-tts",
      "input": [
        {
          "type": "user_input",
          "content": [
            {
              "type": "text",
              "text": "祝你今天过得愉快。",
              "annotations": [
                {
                  "type": "speech_metadata",
                  "style": "温暖自然"
                }
              ]
            }
          ]
        }
      ],
      "response_format": {
        "type": "audio"
      },
      "generation_config": {
        "speech_config": [
          {
            "voice": "Kore"
          }
        ]
      }
    }''')
    request = urllib.request.Request(base + "/v1beta/interactions", data=json.dumps(body).encode(),
        headers={"x-goog-api-key": key, "Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(request, timeout=180) as response:
        result = json.load(response)
    if result.get("status") != "completed":
        raise RuntimeError("生成未完成: " + str(result.get("status")))
    audio = [part for step in result.get("steps", []) if step.get("type") == "model_output"
             for part in step.get("content", []) if part.get("type") == "audio"]
    if not audio: raise RuntimeError("响应没有音频")
    for i, part in enumerate(audio):
        if part.get("mime_type") not in ("audio/wav", "audio/x-wav", "audio/wave"):
            raise RuntimeError("响应不是 WAV: " + str(part.get("mime_type")))
        data = base64.b64decode(part["data"], validate=True)
        if not data: raise RuntimeError("音频为空")
        name = f"speech-{i + 1}.wav"
        with open(name, "xb") as output: output.write(data)
        print(name)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { writeFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const base = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "");
      const response = await fetch(base + "/v1beta/interactions", {
        method: "POST", headers: {"x-goog-api-key": process.env.GEMINI_API_KEY, "Content-Type": "application/json"},
        body: JSON.stringify({"model":"gemini-3.8-flash-tts","input":[{"type":"user_input","content":[{"type":"text","text":"祝你今天过得愉快。","annotations":[{"type":"speech_metadata","style":"温暖自然"}]}]}],"response_format":{"type":"audio"},"generation_config":{"speech_config":[{"voice":"Kore"}]}}), signal: AbortSignal.timeout(180000)
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.status !== "completed") throw new Error("生成未完成: " + result.status);
      const audio = (result.steps || []).filter(s => s.type === "model_output").flatMap(s => s.content || []).filter(p => p.type === "audio");
      if (!audio.length) throw new Error("响应没有音频");
      for (const [i, part] of audio.entries()) {
        if (!["audio/wav", "audio/x-wav", "audio/wave"].includes(part.mime_type)) throw new Error("响应不是 WAV");
        if (!part.data || !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(part.data)) throw new Error("无效 Base64");
        const data = Buffer.from(part.data, "base64");
        const name = `speech-${i + 1}.wav`;
        await writeFile(name, data, {flag: "wx"}); console.log(name);
      }
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "${base%/}/v1beta/interactions" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "model": "gemini-3.8-flash-tts",
        "input": [
          {
            "type": "user_input",
            "content": [
              {
                "type": "text",
                "text": "祝你今天过得愉快。",
                "annotations": [
                  {
                    "type": "speech_metadata",
                    "style": "温暖自然"
                  }
                ]
              }
            ]
          }
        ],
        "response_format": {
          "type": "audio"
        },
        "generation_config": {
          "speech_config": [
            {
              "voice": "Kore"
            }
          ]
        }
      }'
    python3 - "$response" <<'PY_AUDIO'
    import base64, json, sys
    with open(sys.argv[1]) as source: result = json.load(source)
    if result.get("status") != "completed": raise RuntimeError("生成未完成")
    audio = [part for step in result.get("steps", []) if step.get("type") == "model_output"
             for part in step.get("content", []) if part.get("type") == "audio"]
    if not audio: raise RuntimeError("响应没有音频")
    for i, part in enumerate(audio):
        if part.get("mime_type") not in ("audio/wav", "audio/x-wav", "audio/wave"): raise RuntimeError("响应不是 WAV")
        data = base64.b64decode(part["data"], validate=True)
        if not data: raise RuntimeError("音频为空")
        name = f"speech-{i + 1}.wav"
        with open(name, "xb") as output: output.write(data)
        print(name)
    PY_AUDIO
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main
    import ("bytes"; "encoding/base64"; "encoding/json"; "fmt"; "io"; "net/http"; "os"; "time"; "strings")
    func check(err error) { if err != nil { panic(err) } }
    func main() {
     key:=os.Getenv("GEMINI_API_KEY"); if key=="" { panic("请设置 GEMINI_API_KEY") }
     base:=os.Getenv("GEMINI_BASE_URL"); if base=="" {base="https://generativelanguage.googleapis.com"}
     req,err:=http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", bytes.NewBufferString(`{"model":"gemini-3.8-flash-tts","input":[{"type":"user_input","content":[{"type":"text","text":"祝你今天过得愉快。","annotations":[{"type":"speech_metadata","style":"温暖自然"}]}]}],"response_format":{"type":"audio"},"generation_config":{"speech_config":[{"voice":"Kore"}]}}`));check(err)
     req.Header.Set("x-goog-api-key",key);req.Header.Set("Content-Type","application/json")
     res,err:=(&http.Client{Timeout:180*time.Second}).Do(req);check(err);defer res.Body.Close()
     raw,err:=io.ReadAll(res.Body);check(err);if res.StatusCode>=300 {panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,raw))}
     var result struct {Status string `json:"status"`; Steps []struct {Type string `json:"type"`;Content []struct {Type string `json:"type"`;Mime string `json:"mime_type"`;Data string `json:"data"`} `json:"content"`} `json:"steps"`}
     check(json.Unmarshal(raw,&result));if result.Status!="completed" {panic("生成未完成")}
     count:=0
     for _,step:=range result.Steps { if step.Type!="model_output" {continue}; for _,part:=range step.Content {if part.Type!="audio" {continue}
     if part.Mime!="audio/wav" && part.Mime!="audio/x-wav" && part.Mime!="audio/wave" {panic("响应不是 WAV")}
     data,err:=base64.StdEncoding.Strict().DecodeString(part.Data);check(err);if len(data)==0 {panic("音频为空")}
     count++;name:=fmt.Sprintf("speech-%d.wav",count);out,err:=os.OpenFile(name,os.O_WRONLY|os.O_CREATE|os.O_EXCL,0600);check(err)
     _,err=out.Write(data);closeErr:=out.Close();check(err);check(closeErr);fmt.Println(name)
     }};if count==0 {panic("响应没有音频")}
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

[Google Gemini TTS](https\://ai.google.dev/gemini-api/docs/speech-generation), [Interactions](https\://ai.google.dev/gemini-api/docs/interactions).