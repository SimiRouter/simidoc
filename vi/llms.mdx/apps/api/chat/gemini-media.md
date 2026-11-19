# Hiểu phương tiện Gemini

## Tổng quan API

`POST /v1beta/models/{model}:generateContent` kết hợp chữ và phương tiện trong parts, mô hình trả mô tả, chép lời hay phân tích. Hiểu phương tiện không tạo/chỉnh ảnh.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. Google trực tiếp dùng `https://generativelanguage.googleapis.com`, thường với `x-goog-api-key: $GEMINI_API_KEY`, không phải khóa Bearer cổng. Chọn mô hình có quyền và hỗ trợ khả năng cần dùng.

Ví dụ đọc tệp cục bộ và gửi nội tuyến, không phụ thuộc URL ngoài hay Files API; script ánh xạ đuôi ảnh, âm thanh, video và PDF thông dụng sang MIME. Âm thanh/video/PDF phải dùng MIME phù hợp và mô hình hỗ trợ; đổi đuôi thành ảnh chưa đủ.

## Bắt đầu nhanh

1. **Chuẩn bị cấu hình**\: tạo khóa tại Quản lý khóa API và sao chép ID mô hình đầy đủ hỗ trợ loại media đích từ Mô hình và giá.
2. **Chuẩn bị tư liệu**\: chọn ảnh, âm thanh, video hoặc PDF mà bạn có quyền dùng và xác nhận đúng kiểu MIME.
3. **Gửi yêu cầu tối thiểu**\: mã hóa byte của tệp thành Base64 thuần vào `inlineData.data` và đặt câu hỏi văn bản trong cùng `parts`; thử với một ảnh trước.
4. **Đọc kết quả**\: chỉ thành công khi HTTP 2xx và `candidates[]` không rỗng; phần phân tích nằm ở `candidates[0].content.parts[].text`.
5. **Kiểm tra**\: xem `finishReason` và căn cứ của kết luận; trường hợp rủi ro cao cần người kiểm tra lại.

Ảnh phải được mã hóa Base64 trước; xem mục "Ví dụ mã" bên dưới để có script tối thiểu, không tự ghép chuỗi Base64 dài.

## Tham số yêu cầu

| Trường                             | Kiểu           | Bắt buộc     | Mô tả                                                                                |
| ---------------------------------- | -------------- | ------------ | ------------------------------------------------------------------------------------ |
| model (đường dẫn)                  | string         | Có           | ID mô hình hỗ trợ đầu vào phương tiện cần dùng.                                      |
| contents\[].parts\[].text          | string         | Có điều kiện | Câu hỏi gửi cùng phương tiện.                                                        |
| contents\[].parts\[].inlineData    | object         | Có điều kiện | Phương tiện nội tuyến có mimeType và data; không trộn text/fileData trong cùng Part. |
| inlineData.mimeType                | string         | Có           | MIME thực như image/png, image/jpeg, audio/mpeg, video/mp4, application/pdf.         |
| inlineData.data                    | string         | Có           | Base64 thuần byte tệp, không tiền tố data\: và không phải đường dẫn máy.             |
| contents\[].parts\[].fileData      | object         | Có điều kiện | Nguồn khác gồm mimeType, fileUri; chỉ URI có phép và hãng đọc được.                  |
| contents\[].role                   | string         | Không        | Một lượt thường là user.                                                             |
| generationConfig.maxOutputTokens   | integer        | Không        | Giới hạn token đầu ra.                                                               |
| systemInstruction / safetySettings | object / array | Không        | Chỉ dẫn hệ thống và an toàn.                                                         |

Mỗi Part một loại nội dung. Tệp lớn cần cách đầu vào chính thức; không mặc định cổng có Files tải lên và truy vấn Google. Base64 tăng kích thước; phải đáp ứng cổng, hãng, mô hình.

### Cấu trúc yêu cầu

BASE64\_MEDIA\_BYTES là byte tệp đã mã hóa; mã bốn ngôn ngữ tạo từ tệp cục bộ.

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "描述这份素材的主要内容，并指出不确定之处。"
        },
        {
          "inlineData": {
            "mimeType": "image/png",
            "data": "BASE64_MEDIA_BYTES"
          }
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 512
  }
}
```

## Phản hồi

| Trường                                | Kiểu           | Mô tả                                                                               |
| ------------------------------------- | -------------- | ----------------------------------------------------------------------------------- |
| candidates\[]                         | array          | Kết quả ứng viên; có thể rỗng khi chặn.                                             |
| candidates\[].index                   | integer        | Vị trí ứng viên.                                                                    |
| candidates\[].content.role / parts\[] | string / array | Vai trò và phần nội dung, chữ thường ở parts\[].text.                               |
| candidates\[].finishReason            | string         | STOP kết thúc thường; MAX\_TOKENS đạt giới hạn; SAFETY, RECITATION cần xử lý riêng. |
| candidates\[].safetyRatings           | array          | Đánh giá an toàn tùy chọn.                                                          |
| candidates\[].groundingMetadata       | object         | Nguồn và trích dẫn khi dùng công cụ grounding như tìm kiếm.                         |
| promptFeedback.blockReason            | string         | Lý do đầu vào bị chặn; có thể không có ứng viên.                                    |
| usageMetadata.promptTokenCount        | integer        | Token đầu vào.                                                                      |
| usageMetadata.candidatesTokenCount    | integer        | Token đầu ra ứng viên.                                                              |
| usageMetadata.thoughtsTokenCount      | integer        | Token suy nghĩ tùy chọn, không phải văn bản hiển thị trực tiếp.                     |
| usageMetadata.totalTokenCount         | integer        | Tổng token yêu cầu, có thể gồm công cụ hoặc suy nghĩ.                               |
| modelVersion / responseId             | string         | Phiên bản mô hình và ID phản hồi tùy chọn.                                          |

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "图片中可见一张桌子和一个杯子；杯中内容无法确定。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 280,
    "candidatesTokenCount": 30,
    "totalTokenCount": 310
  }
}
```

Truyền luồng dùng streamGenerateContent?alt=sse và gộp theo chỉ số ứng viên; không phải mọi part là chữ. Mô hình có thể hiểu sai; kết luận rủi ro cao về y tế, danh tính hay giấy tờ cần người kiểm tra.

## Ví dụ mã

Đặt `SIMIROUTER_API_KEY`, `SIMIROUTER_GEMINI_MODEL`; `SIMIROUTER_BASE_URL` để ghi đè địa chỉ cổng mặc định; không thêm `/v1`. `MEDIA_PATH` trỏ tới tệp cục bộ có thật. Python 3, Node.js 18+ và Go dùng thư viện chuẩn; curl dùng Python 3 mã hóa JSON an toàn.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    import base64
    from pathlib import Path
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }''')
    p = Path(os.environ["MEDIA_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.m4a': 'audio/mp4', '.flac': 'audio/flac', '.ogg': 'audio/ogg', '.mp4': 'video/mp4', '.mov': 'video/quicktime', '.webm': 'video/webm', '.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["contents"][0]["parts"][1]["inlineData"] = {"mimeType": mime, "data": encoded}
    path = "/v1beta/models/" + urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe="") + ":generateContent"
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const fs = require('node:fs');
      const path = require('node:path');
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_GEMINI_MODEL)
        throw new Error('请设置 SIMIROUTER_GEMINI_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '描述这份素材的主要内容，并指出不确定之处。',
              },
              {
                inlineData: {
                  mimeType: 'image/png',
                  data: 'BASE64_MEDIA_BYTES',
                },
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 512,
        },
      };
      const filename = process.env.MEDIA_PATH;
      if (!filename) throw new Error('请设置 MEDIA_PATH');
      const mime = {
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.webp': 'image/webp',
        '.mp3': 'audio/mpeg',
        '.wav': 'audio/wav',
        '.m4a': 'audio/mp4',
        '.flac': 'audio/flac',
        '.ogg': 'audio/ogg',
        '.mp4': 'video/mp4',
        '.mov': 'video/quicktime',
        '.webm': 'video/webm',
        '.pdf': 'application/pdf',
      }[path.extname(filename).toLowerCase()];
      if (!mime) throw new Error('不支持的文件扩展名');
      const data = fs.readFileSync(filename);
      if (!data.length) throw new Error('输入文件为空');
      const encoded = data.toString('base64');
      body.contents[0].parts[1].inlineData = { mimeType: mime, data: encoded };
      const endpoint = `/v1beta/models/${encodeURIComponent(process.env.SIMIROUTER_GEMINI_MODEL)}:generateContent`;
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000),
      });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_GEMINI_MODEL:?请设置 SIMIROUTER_GEMINI_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    import base64
    from pathlib import Path
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }''')
    p = Path(os.environ["MEDIA_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.mp3': 'audio/mpeg', '.wav': 'audio/wav', '.m4a': 'audio/mp4', '.flac': 'audio/flac', '.ogg': 'audio/ogg', '.mp4': 'video/mp4', '.mov': 'video/quicktime', '.webm': 'video/webm', '.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["contents"][0]["parts"][1]["inlineData"] = {"mimeType": mime, "data": encoded}
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    MODEL_PATH=$(python3 -c 'import os, urllib.parse; print(urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe=""))')
    curl "${BASE_URL%/}/v1beta/models/${MODEL_PATH}:generateContent" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "bytes"
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
      "encoding/base64"
      "path/filepath"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_GEMINI_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_GEMINI_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "描述这份素材的主要内容，并指出不确定之处。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": "BASE64_MEDIA_BYTES"
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 512
      }
    }`), &body); err != nil { log.Fatal(err) }
      filename := os.Getenv("MEDIA_PATH"); if filename == "" { log.Fatal("请设置 MEDIA_PATH") }
      mime := map[string]string{".png":"image/png",".jpg":"image/jpeg",".jpeg":"image/jpeg",".webp":"image/webp",".mp3":"audio/mpeg",".wav":"audio/wav",".m4a":"audio/mp4",".flac":"audio/flac",".ogg":"audio/ogg",".mp4":"video/mp4",".mov":"video/quicktime",".webm":"video/webm",".pdf":"application/pdf"}[strings.ToLower(filepath.Ext(filename))]
      if mime == "" { log.Fatal("不支持的文件扩展名") }
      data, err := os.ReadFile(filename); if err != nil { log.Fatal(err) }; if len(data) == 0 { log.Fatal("输入文件为空") }
      encoded := base64.StdEncoding.EncodeToString(data)
      body["contents"].([]any)[0].(map[string]any)["parts"].([]any)[1].(map[string]any)["inlineData"] = map[string]any{"mimeType": mime, "data": encoded}
      endpoint := "/v1beta/models/" + model + ":generateContent"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Mã lỗi

| Trạng thái HTTP | Ý nghĩa hoặc loại lỗi hãng         | Cách xử lý                                                                  |
| --------------- | ---------------------------------- | --------------------------------------------------------------------------- |
| 400             | `INVALID_ARGUMENT` và lỗi tương tự | Kiểm tra JSON, tham số, MIME phương tiện và độ dài đầu vào.                 |
| 403             | `PERMISSION_DENIED`                | Kiểm tra khóa, quyền dự án, vùng hoặc giới hạn thanh toán.                  |
| 404             | `NOT_FOUND`                        | Kiểm tra tên mô hình và phiên bản API.                                      |
| 429             | `RESOURCE_EXHAUSTED`               | Kiểm tra tốc độ, hạn mức; lùi thời gian số lần giới hạn nếu có thể thử lại. |
| 500 / 503       | `INTERNAL` / `UNAVAILABLE`         | Ghi ID yêu cầu, thử lại có giới hạn hoặc sau đó.                            |

Đối tượng lỗi Google gồm `error.code` (mã HTTP), `error.status` (tên enum), `error.message` và có thể có `details`. Cổng có thể báo xác thực, định tuyến hoặc hạn mức trước khi tới hãng; chỉ mã HTTP không chứng minh lỗi thượng nguồn.

Phản hồi dài và yêu cầu streaming có thể mất từ vài chục giây đến vài phút; hãy đặt thời gian chờ đủ lớn, khi luồng bị ngắt thì dựa trên phần đã nhận và lý do kết thúc thay vì tự động gửi lại. Với 429 và 5xx, xem nội dung phản hồi và nhật ký sử dụng trước; khi bị chính sách nội dung từ chối, hãy sửa prompt hoặc đầu vào thay vì thử lại nguyên trạng.

## Tham khảo chính thức

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Hiểu ảnh Google](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Hiểu âm thanh Google](https\://ai.google.dev/gemini-api/docs/audio)
* [Hiểu video Google](https\://ai.google.dev/gemini-api/docs/video-understanding)
* [Hiểu PDF Google](https\://ai.google.dev/gemini-api/docs/document-processing)
* [Khắc phục sự cố Google](https\://ai.google.dev/gemini-api/docs/troubleshooting)