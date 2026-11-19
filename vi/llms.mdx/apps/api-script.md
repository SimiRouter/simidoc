# Tích hợp API bằng script

Dùng Chat Completions để gửi tin nhắn và đọc phản hồi. Bốn ví dụ thực hiện cùng một thao tác\: gửi yêu cầu JSON không truyền luồng đến `POST /v1/chat/completions`, chờ phản hồi đầy đủ rồi xuất kết quả.

## Script gọi ảnh

Ví dụ đầy đủ về tạo ảnh, chỉnh sửa ảnh tham chiếu và lưu kết quả được sắp xếp theo giao thức trong [tổng quan API hình ảnh](/simidoc/vi/apps/api/images).

## Chuẩn bị khóa và mô hình

Trước tiên, mở [Quản lý khóa API](https://api.dwchainless.com/keys) để tạo khóa, sau đó từ [Danh mục mô hình](https://api.dwchainless.com/vi/pricing/) sao chép ID mô hình đầy đủ mà khóa được phép dùng. Ví dụ đọc cấu hình từ biến môi trường, không lưu khóa trong tệp.

* `SIMIROUTER_API_KEY`\: Khóa API SimiRouter, bắt buộc.
* `SIMIROUTER_MODEL`\: ID mô hình đầy đủ, bắt buộc.
* `SIMIROUTER_BASE_URL`\: Tùy chọn, mặc định `https://api.dwchainless.com`. Đây là địa chỉ gốc, không gồm `/v1`.

Đặt các giá trị trên trong terminal hoặc biến môi trường của nền tảng chạy. Không in khóa trong nhật ký công khai. Yêu cầu API thật có thể phát sinh phí.

## Thay thế trực tiếp bằng OpenAI SDK

Nếu mã đã dùng SDK chính thức của OpenAI, chỉ cần thay `baseURL` và `apiKey`, rồi dùng ID mô hình đầy đủ của SimiRouter. `baseURL` phải kết thúc bằng `/v1`; tên phương thức, tham số và đối tượng phản hồi vẫn giữ hình dạng OpenAI.

<Tabs items={["Python","Node.js"]}>
  <Tab value="Python">
    ```python
    import os
    from openai import OpenAI

    client = OpenAI(
        base_url="https://api.dwchainless.com/v1",
        api_key=os.environ["SIMIROUTER_API_KEY"],
    )
    response = client.chat.completions.create(
        model=os.environ["SIMIROUTER_MODEL"],
        messages=[{"role": "user", "content": "用一句话解释什么是机器学习。"}],
    )
    print(response.choices[0].message.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    import OpenAI from 'openai';

    const client = new OpenAI({
      baseURL: 'https://api.dwchainless.com/v1',
      apiKey: process.env.SIMIROUTER_API_KEY,
    });
    const response = await client.chat.completions.create({
      model: process.env.SIMIROUTER_MODEL,
      messages: [{ role: 'user', content: '用一句话解释什么是机器学习。' }],
    });
    console.log(response.choices[0].message.content);
    ```
  </Tab>
</Tabs>

Cài SDK chính thức trước\: `pip install openai` hoặc `npm install openai`. SDK tự xử lý thử lại, thời gian chờ và phân tích SSE; các tùy chọn máy khách như thời gian chờ riêng và `max_retries` giữ nguyên ngữ nghĩa SDK, gateway không viết lại.

Gateway trả về theo giao thức tương thích OpenAI; khả năng của mô hình vẫn do mô hình bạn chọn quyết định. Nếu SDK báo `404`, hãy kiểm tra `baseURL` có đang là `https://api.dwchainless.com` mà thiếu `/v1` hay không.

## Yêu cầu và phản hồi

| Mục                          | Mô tả                                                                                                |
| ---------------------------- | ---------------------------------------------------------------------------------------------------- |
| Phương thức và đường dẫn     | `POST /v1/chat/completions`                                                                          |
| Xác thực                     | `Authorization: Bearer <API Key>`                                                                    |
| Loại nội dung                | `application/json`                                                                                   |
| Tham số bắt buộc             | `model`, `messages`                                                                                  |
| Tham số tùy chọn trong ví dụ | `max_completion_tokens: 256`, `stream: false`; mô hình đã chọn phải hỗ trợ                           |
| Phản hồi thành công          | HTTP 200, `choices[].message.content` chứa câu trả lời văn bản; `usage` cho biết lượng token sử dụng |
| Truyền luồng                 | `stream: true` trả về SSE, không thể phân tích như một phản hồi JSON duy nhất                        |

Tham số đầy đủ, gọi công cụ, đầu vào đa phương thức và sự kiện SSE được mô tả tại [Chat Completions](/simidoc/vi/apps/api/chat/openai-chat).

## Ví dụ mã

Đặt `SIMIROUTER_API_KEY`, `SIMIROUTER_MODEL`; `SIMIROUTER_BASE_URL` để ghi đè địa chỉ cổng mặc định; không thêm `/v1`. Ví dụ Python 3, Node.js 18+ và Go chỉ dùng thư viện chuẩn; ví dụ curl dùng Python 3 để mã hóa JSON an toàn.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/chat/completions'
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
      if (!process.env.SIMIROUTER_API_KEY)
        throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        messages: [
          {
            role: 'user',
            content: '用一句话解释什么是机器学习。',
          },
        ],
        max_completion_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/chat/completions';
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
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/chat/completions" \
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
      model := os.Getenv("SIMIROUTER_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/chat/completions"
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

| Trạng thái HTTP | Nguyên nhân thường gặp                                  | Cách xử lý                                                                                         |
| --------------- | ------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| 400             | Sai định dạng yêu cầu hoặc mô hình không hỗ trợ tham số | Đọc nội dung lỗi và bỏ tham số tùy chọn không được hỗ trợ                                          |
| 401             | Khóa bị thiếu, hết hạn hoặc không đúng                  | Kiểm tra biến môi trường, tạo khóa mới nếu cần                                                     |
| 403             | Quyền mô hình, nhóm hoặc kênh bị hạn chế                | Kiểm tra khóa và quyền tài khoản                                                                   |
| 404             | Sai đường dẫn hoặc ID mô hình                           | Kiểm tra việc thêm trùng `/v1` và đối chiếu ID mô hình đầy đủ                                      |
| 429             | Giới hạn tốc độ hoặc hạn mức                            | Kiểm tra hạn mức và giới hạn trước, lùi thời gian theo lỗi; không thử lại vô hạn                   |
| 5xx             | Lỗi cổng hoặc dịch vụ thượng nguồn                      | Giữ nội dung lỗi đã che dữ liệu nhạy cảm và ID yêu cầu; kiểm tra lịch sử sử dụng trước khi thử lại |

Các trạng thái trên chỉ là điểm bắt đầu chẩn đoán; nguyên nhân cụ thể nằm trong phản hồi lỗi. Hết thời gian chờ không chứng minh mô hình chưa chạy. Không tự động thử lại yêu cầu sinh nội dung vô hạn.

## Khả năng khác

* [Responses](/simidoc/vi/apps/api/chat/openai-responses)\: tổ chức yêu cầu bằng các mục đầu vào và đầu ra.
* [Claude Messages](/simidoc/vi/apps/api/chat/claude) và [Gemini](/simidoc/vi/apps/api/chat/gemini-text)\: cấu trúc tin nhắn gốc.
* [Tạo ảnh](/simidoc/vi/apps/api/images)\: tạo, chỉnh sửa và nhận dạng.
* [Âm thanh](/simidoc/vi/apps/api/audio)\: hiểu âm thanh, tổng hợp giọng nói, chép lời và dịch.
* [Video](/simidoc/vi/apps/api/video)\: tác vụ tạo video và hiểu video.
* [Tích hợp âm thanh MiMo](/simidoc/vi/apps/api/audio/mimo-audio)\: tổng hợp giọng nói, chép lời và khả năng giọng của MiMo.

## Tham khảo chính thức

Các trường giao thức tham khảo [OpenAI Chat Completions API Reference](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create). Địa chỉ và khóa SimiRouter khác với kết nối trực tiếp OpenAI.