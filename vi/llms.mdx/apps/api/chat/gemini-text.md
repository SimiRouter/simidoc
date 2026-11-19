# Sinh văn bản Gemini

## Tổng quan API

`POST /v1beta/models/{model}:generateContent` nhận Gemini contents/parts và trả GenerateContentResponse đầy đủ khi không luồng. Khác messages hay input OpenAI.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. Google trực tiếp dùng `https://generativelanguage.googleapis.com`, thường với `x-goog-api-key: $GEMINI_API_KEY`, không phải khóa Bearer cổng. Chọn mô hình có quyền và hỗ trợ khả năng cần dùng.

## Bắt đầu nhanh

1. **Chuẩn bị cấu hình**\: tạo khóa tại Quản lý khóa API và sao chép ID mô hình đầy đủ hỗ trợ generateContent từ Mô hình và giá.
2. **Gửi yêu cầu tối thiểu**\: đặt ID mô hình trực tiếp trong đường dẫn (không kèm tiền tố `models/`) và đặt `generationConfig.maxOutputTokens` ở giá trị nhỏ.
3. **Đọc kết quả**\: chỉ thành công khi HTTP 2xx và `candidates[]` không rỗng; nội dung thường nằm ở `candidates[0].content.parts[].text`.
4. **Kiểm tra**\: xem `finishReason` và `promptFeedback`, sau đó đối chiếu nhật ký sử dụng.

```bash
API_URL="https://api.dwchainless.com/v1beta/models/MODEL_ID:generateContent"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"role": "user", "parts": [{"text": "用一句话解释机器学习。"}]}],
    "generationConfig": {"maxOutputTokens": 256}
  }'
```

Thay `PASTE_API_KEY_HERE` và `MODEL_ID` trong đường dẫn bằng giá trị thực; để streaming, chuyển sang `streamGenerateContent?alt=sse`.

## Tham số yêu cầu

Thân JSON; trường REST dùng lowerCamelCase. Không chép máy móc tên snake\_case Python SDK vào REST.

| Trường                                     | Kiểu             | Bắt buộc     | Mô tả                                                                           |
| ------------------------------------------ | ---------------- | ------------ | ------------------------------------------------------------------------------- |
| model (đường dẫn)                          | string           | Có           | ID mô hình không tiền tố models/; tài nguyên gốc là models/\{model}.            |
| contents                                   | array            | Có           | Lịch sử và tin hiện tại theo thứ tự.                                            |
| contents\[].role                           | string           | Không        | user hoặc model, chỉ định rõ trong nhiều lượt.                                  |
| contents\[].parts                          | array            | Có           | Phần nội dung, ít nhất một mục.                                                 |
| parts\[].text                              | string           | Có điều kiện | Phần chữ; phương tiện dùng inlineData hoặc fileData.                            |
| systemInstruction.parts\[].text            | string           | Không        | Chỉ dẫn hệ thống, không thay bằng role=system.                                  |
| generationConfig.maxOutputTokens           | integer          | Không        | Giới hạn token sinh theo quy tắc tính token suy luận của mô hình.               |
| generationConfig.responseMimeType          | string           | Không        | Dùng application/json cho đầu ra cấu trúc nếu mô hình hỗ trợ.                   |
| generationConfig.responseJsonSchema        | object           | Không        | JSON Schema phản hồi, thường đặt cùng application/json.                         |
| generationConfig.temperature / topP / topK | number / integer | Không        | Chỉ dùng mô hình hỗ trợ cấu hình lấy mẫu; không tái dùng số cố định qua thế hệ. |
| generationConfig.stopSequences             | array            | Không        | Chuỗi dừng khi mô hình hỗ trợ.                                                  |
| safetySettings                             | array            | Không        | Loại và ngưỡng an toàn; không tắt được mọi bảo vệ của mọi mô hình.              |
| tools / toolConfig                         | array / object   | Không        | Định nghĩa công cụ, cấu hình gọi Google Search, hàm và công cụ khác.            |

### Ví dụ yêu cầu

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "用一句话解释机器学习。"
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 256
  }
}
```

Nhiều lượt xen role=user và role=model, cuối là câu hỏi hiện tại. Máy chủ không tự giữ hội thoại từ kết nối HTTP trước.

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
            "text": "机器学习让计算机通过数据学习规律并完成预测。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 12,
    "candidatesTokenCount": 20,
    "totalTokenCount": 32
  }
}
```

### Phản hồi luồng

Đổi đường dẫn thành `/v1beta/models/{model}:streamGenerateContent?alt=sse`, giữ thân. Phân tích từng GenerateContentResponse trong data, gộp parts theo candidate.index; không chờ dấu OpenAI `[DONE]`. Cuối kiểm tra finishReason, promptFeedback và mức dùng. SSE là phần tăng dần của cùng lần sinh, không phải tác vụ nền hay nhiều yêu cầu song song.

## Ví dụ mã

Đặt `SIMIROUTER_API_KEY`, `SIMIROUTER_GEMINI_MODEL`; `SIMIROUTER_BASE_URL` để ghi đè địa chỉ cổng mặc định; không thêm `/v1`. Ví dụ Python 3, Node.js 18+ và Go chỉ dùng thư viện chuẩn; ví dụ curl dùng Python 3 để mã hóa JSON an toàn.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
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
                text: '用一句话解释机器学习。',
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 256,
        },
      };
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
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
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
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }`), &body); err != nil { log.Fatal(err) }
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

Đối tượng lỗi Google gồm `error.code` (mã HTTP), `error.status` (tên enum), `error.message` và có thể có `details`. Cổng có thể báo xác thực, định tuyến hoặc hạn mức trước hãng; mã HTTP không chứng minh nguồn lỗi. candidates rỗng hoặc finishReason=SAFETY dưới HTTP 200 có thể là chặn nội dung, không phải lỗi mạng.

Phản hồi dài và yêu cầu streaming có thể mất từ vài chục giây đến vài phút; hãy đặt thời gian chờ đủ lớn, khi luồng bị ngắt thì dựa trên phần đã nhận và lý do kết thúc thay vì tự động gửi lại. Với 429 và 5xx, xem nội dung phản hồi và nhật ký sử dụng trước; khi bị chính sách nội dung từ chối, hãy sửa prompt hoặc đầu vào thay vì thử lại nguyên trạng.

## Tham khảo chính thức

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Sinh văn bản Google](https\://ai.google.dev/gemini-api/docs/text-generation)
* [Khắc phục sự cố Google](https\://ai.google.dev/gemini-api/docs/troubleshooting)