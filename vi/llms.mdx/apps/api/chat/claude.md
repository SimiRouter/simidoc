# Claude Messages

## Tổng quan API

`POST /v1/messages` nhận tin user/assistant và trả Message gồm khối chữ, công cụ hoặc suy nghĩ. Chỉ dẫn hệ thống đặt ở system cấp cao nhất; không tạo messages role=system.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. Anthropic trực tiếp dùng `https://api.anthropic.com` và `x-api-key: $ANTHROPIC_API_KEY`. Ví dụ cố định `anthropic-version: 2023-06-01` để chọn phiên bản giao thức, không nghĩa mới nhất. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

## Bắt đầu nhanh

1. **Chuẩn bị cấu hình**\: tạo khóa tại Quản lý khóa API và sao chép ID mô hình đầy đủ hỗ trợ Claude Messages từ Mô hình và giá.
2. **Gửi yêu cầu tối thiểu**\: gửi một tin nhắn người dùng, giữ tiêu đề `anthropic-version` và để `stream` là `false`.
3. **Đọc kết quả**\: chỉ thành công khi HTTP 2xx và `content[]` không rỗng; nội dung nằm trong khối nội dung có `type=text`.
4. **Kiểm tra**\: xem `stop_reason`, `stop_sequence` và nội dung thực tế, sau đó đối chiếu nhật ký sử dụng.

```bash
API_URL="https://api.dwchainless.com/v1/messages"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "anthropic-version: 2023-06-01" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "max_tokens": 256,
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

Thay `PASTE_API_KEY_HERE` và `MODEL_ID` bằng giá trị thực; `anthropic-version` chọn phiên bản giao thức, không có nghĩa là phiên bản mới nhất.

## Tham số yêu cầu

Thân yêu cầu JSON; header ví dụ gồm `anthropic-version: 2023-06-01`.

| Trường                        | Kiểu             | Bắt buộc     | Mô tả                                                                                       |
| ----------------------------- | ---------------- | ------------ | ------------------------------------------------------------------------------------------- |
| model                         | string           | Có           | ID mô hình Claude có quyền truy cập.                                                        |
| max\_tokens                   | integer          | Có           | Giới hạn token sinh; bình thường dùng số nguyên dương, 0 chỉ cho luồng ghi cache có hỗ trợ. |
| messages                      | array            | Có           | Danh sách tin nhắn hội thoại.                                                               |
| messages\[].role              | string           | Có           | user hoặc assistant.                                                                        |
| messages\[].content           | string / array   | Có           | Chuỗi văn bản hoặc mảng khối nội dung.                                                      |
| content\[].type               | string           | Có điều kiện | Loại tương ứng như text, image, tool\_use, tool\_result.                                    |
| content\[].text               | string           | Có điều kiện | Nội dung khối text.                                                                         |
| content\[].source             | object           | Có điều kiện | Nguồn image\: base64 với media\_type/data hoặc kiểu url với url.                            |
| system                        | string / array   | Không        | Chỉ dẫn hệ thống; có thể dùng khối văn bản khi hỗ trợ.                                      |
| stream                        | boolean          | Không        | true trả SSE; mặc định không truyền luồng.                                                  |
| stop\_sequences               | array            | Không        | Chuỗi dừng tùy chỉnh.                                                                       |
| temperature / top\_p / top\_k | number / integer | Không        | Cài lấy mẫu, chỉ dùng mô hình hỗ trợ.                                                       |
| tools                         | array            | Không        | Định nghĩa hàm gồm name, description, input\_schema.                                        |
| tool\_choice                  | object           | Không        | Chọn công cụ auto, any, tool, none; dùng tool phải có name.                                 |
| thinking                      | object           | Không        | Cấu hình suy nghĩ tùy thế hệ; không phải mọi mô hình nhận adaptive, enabled.                |
| metadata.user\_id             | string           | Không        | ID người dùng nghiệp vụ, không gửi thông tin định danh trực tiếp.                           |

### Ví dụ yêu cầu

```json
{
  "model": "MODEL_ID",
  "max_tokens": 256,
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释机器学习。"
    }
  ],
  "stream": false
}
```

## Phản hồi

Phản hồi HTTP 200 không truyền luồng là Message.

| Trường                                                            | Kiểu          | Mô tả                                                                                                             |
| ----------------------------------------------------------------- | ------------- | ----------------------------------------------------------------------------------------------------------------- |
| id / type                                                         | string        | ID tin nhắn; type=message.                                                                                        |
| role / model                                                      | string        | assistant và ID mô hình phản hồi.                                                                                 |
| content\[]                                                        | array         | Danh sách khối, không mặc định mọi mục đều có text.                                                               |
| content\[].type / text                                            | string        | Đọc text khi type=text, đọc id/name/input khi tool\_use.                                                          |
| stop\_reason                                                      | string / null | end\_turn kết thúc thường; max\_tokens chạm trần; stop\_sequence khớp chuỗi dừng; tool\_use yêu cầu chạy công cụ. |
| stop\_sequence                                                    | string / null | Chuỗi dừng đã khớp, không có là null.                                                                             |
| usage.input\_tokens / output\_tokens                              | integer       | Token vào và ra.                                                                                                  |
| usage.cache\_creation\_input\_tokens / cache\_read\_input\_tokens | integer       | Lượng ghi/đọc cache tùy chọn, không đơn giản coi là văn bản thêm.                                                 |

```json
{
  "id": "msg_example",
  "type": "message",
  "role": "assistant",
  "model": "MODEL_ID",
  "content": [
    {
      "type": "text",
      "text": "机器学习是一种从数据中提取规律并用于预测的方法。"
    }
  ],
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 14,
    "output_tokens": 24
  }
}
```

### Phản hồi luồng

Với stream=true, lần lượt xử lý message\_start, content\_block\_start, content\_block\_delta, content\_block\_stop, message\_delta, message\_stop. Nối text\_delta và partial\_json của input\_json\_delta, chỉ phân tích khi đủ. message\_delta cập nhật lý do dừng và dùng; message\_stop kết thúc. Sự kiện error có thể tới sau HTTP 200.

Khi dùng công cụ, giữ khối assistant và trong tin user tiếp theo dùng `{"type":"tool_result","tool_use_id":"...","content":"..."}` để trả kết quả. Kiểm tra tham số, quyền trước thực thi.

## Ví dụ mã

Đặt `SIMIROUTER_API_KEY`, `SIMIROUTER_CLAUDE_MODEL`; `SIMIROUTER_BASE_URL` để ghi đè địa chỉ cổng mặc định; không thêm `/v1`. Ví dụ Python 3, Node.js 18+ và Go chỉ dùng thư viện chuẩn; ví dụ curl dùng Python 3 để mã hóa JSON an toàn.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_CLAUDE_MODEL"): raise RuntimeError("请设置 SIMIROUTER_CLAUDE_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    path = '/v1/messages'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={'anthropic-version': '2023-06-01', "Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
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
      if (!process.env.SIMIROUTER_CLAUDE_MODEL)
        throw new Error('请设置 SIMIROUTER_CLAUDE_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        max_tokens: 256,
        messages: [
          {
            role: 'user',
            content: '用一句话解释机器学习。',
          },
        ],
        stream: false,
      };
      body.model = process.env.SIMIROUTER_CLAUDE_MODEL;
      const endpoint = '/v1/messages';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          'anthropic-version': '2023-06-01',
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
    : "${SIMIROUTER_CLAUDE_MODEL:?请设置 SIMIROUTER_CLAUDE_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/messages" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "anthropic-version: 2023-06-01" \
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
      model := os.Getenv("SIMIROUTER_CLAUDE_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_CLAUDE_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/messages"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("anthropic-version", "2023-06-01")
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

| Trạng thái HTTP | Ý nghĩa hoặc loại lỗi hãng                         | Cách xử lý                                                               |
| --------------- | -------------------------------------------------- | ------------------------------------------------------------------------ |
| 400             | `invalid_request_error`                            | Cấu trúc, tham số hoặc khả năng mô hình không khớp.                      |
| 401 / 403       | `authentication_error` / `permission_error`        | Khóa không hợp lệ hoặc không có quyền.                                   |
| 404             | `not_found_error`                                  | Điểm cuối, mô hình hoặc tài nguyên không tồn tại.                        |
| 413             | `request_too_large`                                | Giảm kích thước yêu cầu.                                                 |
| 429             | `rate_limit_error`                                 | Kiểm tra tốc độ và hạn mức.                                              |
| 500 / 504 / 529 | `api_error` / `timeout_error` / `overloaded_error` | Lỗi dịch vụ, timeout hoặc quá tải; chỉ thử lại lỗi tạm thời có giới hạn. |

Lỗi gốc Anthropic có dạng `{"type":"error","error":{"type":"invalid_request_error","message":"..."},"request_id":"..."}`. Cổng có thể báo xác thực, định tuyến hoặc hạn mức trước khi tới hãng; chỉ mã HTTP không chứng minh lỗi thượng nguồn.

Phản hồi dài và yêu cầu streaming có thể mất từ vài chục giây đến vài phút; hãy đặt thời gian chờ đủ lớn, khi luồng bị ngắt thì dựa trên phần đã nhận và lý do kết thúc thay vì tự động gửi lại. Với 429 và 5xx, xem nội dung phản hồi và nhật ký sử dụng trước; khi bị chính sách nội dung từ chối, hãy sửa prompt hoặc đầu vào thay vì thử lại nguyên trạng.

## Tham khảo chính thức

* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Phiên bản API Anthropic](https\://platform.claude.com/docs/en/api/versioning)
* [Xử lý lỗi Anthropic](https\://platform.claude.com/docs/en/api/errors)