# Chat Completions

## Tổng quan API

`POST /v1/chat/completions` sinh trả lời từ lịch sử. Phù hợp ứng dụng Chat Completions và hội thoại nhiều lượt không trạng thái.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

## Bắt đầu nhanh

1. **Chuẩn bị cấu hình**\: tạo khóa tại Quản lý khóa API và sao chép ID mô hình đầy đủ hỗ trợ Chat Completions từ Mô hình và giá.
2. **Gửi yêu cầu tối thiểu**\: chỉ gửi một tin nhắn người dùng và giữ `stream` là `false`; trước tiên xác nhận xác thực, mô hình và tham số đều hợp lệ.
3. **Đọc kết quả**\: chỉ thành công khi HTTP 2xx và `choices[]` không rỗng; nội dung nằm ở `choices[0].message.content`.
4. **Kiểm tra**\: xem `finish_reason`, thông tin từ chối và nội dung thực tế, sau đó đối chiếu nhật ký sử dụng.

```bash
API_URL="https://api.dwchainless.com/v1/chat/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

Thay `PASTE_API_KEY_HERE` và `MODEL_ID` bằng giá trị thực; sau khi xác nhận hoạt động, hãy thêm lịch sử nhiều lượt, công cụ hoặc bật streaming.

Nếu dự án đã dùng OpenAI SDK, chỉ cần trỏ `baseURL` tới `https://api.dwchainless.com/v1` và dùng khóa SimiRouter; tên phương thức và tham số giữ nguyên. Xem [Script gọi API](/simidoc/vi/apps/api-script).

## Tham số yêu cầu

Loại nội dung là `application/json`. Bỏ trường tùy chọn chưa dùng; không gửi hàng loạt chuỗi rỗng, 0, đối tượng rỗng hay null.

| Trường                                 | Kiểu                     | Bắt buộc     | Mô tả                                                                                       |
| -------------------------------------- | ------------------------ | ------------ | ------------------------------------------------------------------------------------------- |
| model                                  | string                   | Có           | ID mô hình.                                                                                 |
| messages                               | array                    | Có           | Ít nhất một tin; bên gọi gửi lịch sử cần theo thứ tự.                                       |
| messages\[].role                       | string                   | Có           | `developer`, `system`, `user`, `assistant`, `tool`; vai trò khả dụng tùy mô hình.           |
| messages\[].content                    | string / array / null    | Có điều kiện | Chữ hoặc mảng nội dung; tin assistant có `tool_calls` có thể bỏ trường hoặc null.           |
| messages\[].content\[].type            | string                   | Có điều kiện | Loại nội dung tương ứng `text`, `image_url`, `input_audio` hoặc `file`.                     |
| messages\[].content\[].text            | string                   | Có điều kiện | Chữ khi type=text.                                                                          |
| messages\[].content\[].image\_url      | object                   | Có điều kiện | Khi type=image\_url, cung cấp `url` và tùy chọn `detail`; xem hiểu ảnh.                     |
| messages\[].tool\_calls                | array                    | Không        | Gọi hàm assistant yêu cầu; mỗi mục có id, type=function, function.name, function.arguments. |
| messages\[].tool\_call\_id             | string                   | Có điều kiện | Bắt buộc role=tool, khớp ID công cụ assistant trả.                                          |
| max\_completion\_tokens                | integer                  | Không        | Giới hạn token sinh gồm đầu ra thấy được và suy luận.                                       |
| stream                                 | boolean                  | Không        | true trả SSE; mặc định không truyền luồng.                                                  |
| stream\_options.include\_usage         | boolean                  | Không        | Yêu cầu khối tổng usage trước cuối luồng, đồng thời bật stream.                             |
| temperature / top\_p                   | number                   | Không        | Tham số lấy mẫu chỉ khi hỗ trợ; thường chỉnh một.                                           |
| stop                                   | string / array           | Không        | Chuỗi dừng chỉ vài mô hình hỗ trợ.                                                          |
| n                                      | integer                  | Không        | Số phản hồi ứng viên, không phải số yêu cầu đồng thời.                                      |
| tools / tool\_choice                   | array / string or object | Không        | Định nghĩa hàm và lựa chọn, xem gọi công cụ.                                                |
| parallel\_tool\_calls                  | boolean                  | Không        | Cho nhiều hàm trong một phản hồi, không tự thực thi thay ứng dụng.                          |
| response\_format                       | object                   | Không        | Đầu ra cấu trúc, dùng json\_schema hoặc json\_object khi hỗ trợ.                            |
| reasoning\_effort                      | string                   | Không        | Mức suy luận và giá trị tùy mô hình, không phải mô hình nào cũng có.                        |
| presence\_penalty / frequency\_penalty | number                   | Không        | Phạt lặp -2 đến 2 khi hỗ trợ.                                                               |
| logprobs / top\_logprobs               | boolean / integer        | Không        | Xác suất token và số ứng viên khi mô hình hỗ trợ.                                           |

`max_tokens` là tham số cũ, thay bằng `max_completion_tokens`; mô hình không thuộc o-series vẫn có thể nhận, còn `/v1/completions` chỉ dùng `max_tokens`. tích hợp mới không gửi cả hai. `video_url`, `reasoning_content` là mở rộng một số mô hình tương thích, không phải trường chuẩn chung Chat Completions.

### Ví dụ yêu cầu

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释什么是机器学习。"
    }
  ],
  "max_completion_tokens": 256,
  "stream": false
}
```

## Phản hồi

Không luồng thành công trả HTTP 200 JSON; ID và token sau chỉ minh họa cấu trúc.

| Trường                         | Kiểu             | Mô tả                                                                                              |
| ------------------------------ | ---------------- | -------------------------------------------------------------------------------------------------- |
| id / object                    | string           | ID phản hồi; object=chat.completion.                                                               |
| created / model                | integer / string | Thời điểm Unix giây và mô hình phản hồi.                                                           |
| choices\[]                     | array            | Danh sách ứng viên, index là vị trí.                                                               |
| choices\[].message.role        | string           | assistant.                                                                                         |
| choices\[].message.content     | string / null    | Chữ trả lời có thể rỗng khi công cụ/từ chối, không tự nghĩa thất bại.                              |
| choices\[].message.tool\_calls | array            | Hàm ứng dụng cần chạy. arguments là chuỗi JSON, phải phân tích và kiểm tra.                        |
| choices\[].message.refusal     | string / null    | Thông tin từ chối nếu có.                                                                          |
| choices\[].finish\_reason      | string           | stop kết thúc thường; length chạm giới hạn; tool\_calls gọi công cụ; content\_filter lọc nội dung. |
| usage.prompt\_tokens           | integer          | Token đầu vào.                                                                                     |
| usage.completion\_tokens       | integer          | Token sinh, có thể gồm suy luận.                                                                   |
| usage.total\_tokens            | integer          | Tổng token đầu vào và sinh.                                                                        |
| usage.\*\_tokens\_details      | object           | Chi tiết tùy chọn như cached\_tokens, reasoning\_tokens.                                           |

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "机器学习是让计算机从数据中学习规律并用于预测或决策的方法。",
        "refusal": null
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 18,
    "completion_tokens": 24,
    "total_tokens": 42
  }
}
```

### Phản hồi luồng

Đặt `stream: true` rồi nhận `text/event-stream`. Phân tích JSON từng dòng `data:`; dùng `choices[].index` để nhóm và nối `delta.content`; nhóm tham số hàm từ `delta.tool_calls` theo chỉ số công cụ. Dấu hoàn tất là `data: [DONE]`, không phải JSON. Với include\_usage, khối cuối có thể choices rỗng, khối thường usage=null. Ngắt kết nối chưa nhận kết thúc phải đánh dấu chưa đầy đủ, không tự coi thành công.

```text
data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"content":"机器学习"},"finish_reason":null}]}

data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

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

### Dùng OpenAI SDK

Khi đã cài SDK `openai` chính thức, không cần tự viết yêu cầu HTTP\: trỏ `baseURL` tới gateway để dùng lại kiểu dữ liệu, cơ chế thử lại và phân tích luồng của SDK. Cài bằng `pip install openai` hoặc `npm install openai`.

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

## Mã lỗi

| Trạng thái HTTP | Ý nghĩa hoặc loại lỗi hãng           | Cách xử lý                                                                                              |
| --------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------- |
| 400             | Yêu cầu không hợp lệ                 | Kiểm tra trường bắt buộc, JSON, tham số và độ dài ngữ cảnh.                                             |
| 401             | Xác thực thất bại                    | Kiểm tra khóa có, hợp lệ và thuộc đúng dịch vụ.                                                         |
| 403 / 404       | Không có quyền / không có tài nguyên | Kiểm tra quyền mô hình, ID và URL.                                                                      |
| 429             | Giới hạn tốc độ hoặc hạn mức         | Theo thân phản hồi phân biệt giới hạn tốc độ với thiếu hạn mức; thử lại không giải quyết thiếu hạn mức. |
| 500 / 503       | Lỗi máy chủ / tạm không khả dụng     | Giữ ID yêu cầu, lùi thời gian giới hạn cho lỗi tạm.                                                     |

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn tồn tại hoặc bằng HTTP. Cổng có thể lỗi xác thực, tuyến, hạn mức trước hãng; mã HTTP không chứng minh nguồn lỗi. HTTP 200 vẫn kiểm tra finish\_reason, từ chối và đầy đủ luồng; length/content\_filter không là lỗi HTTP.

Phản hồi dài và yêu cầu streaming có thể mất từ vài chục giây đến vài phút; hãy đặt thời gian chờ đủ lớn, khi luồng bị ngắt thì dựa trên phần đã nhận và lý do kết thúc thay vì tự động gửi lại. Với 429 và 5xx, xem nội dung phản hồi và nhật ký sử dụng trước; khi bị chính sách nội dung từ chối, hãy sửa prompt hoặc đầu vào thay vì thử lại nguyên trạng.

### Ví dụ phản hồi lỗi

Phản hồi lỗi thường là đối tượng `error` theo hình dạng OpenAI, với `param` và `code` có thể là `null`. Các ví dụ dưới đây chỉ mang tính minh họa; nội dung thay đổi theo gateway hoặc nhà cung cấp, đừng so khớp theo chuỗi.

```json
{
  "error": {
    "message": "You didn't provide an API key.",
    "type": "invalid_request_error",
    "param": null,
    "code": "invalid_api_key"
  }
}
```

```json
{
  "error": {
    "message": "Rate limit reached for requests.",
    "type": "rate_limit_error",
    "param": null,
    "code": "rate_limit_exceeded"
  }
}
```

## Câu hỏi thường gặp

**Gặp 401 hoặc `Invalid token` thì làm gì?**
Kiểm tra header là `Authorization: Bearer <Key>`, khóa thuộc gateway này và chưa bị thu hồi, đồng thời bạn không dán mật khẩu đăng nhập hay khóa của nhà cung cấp.

**Vì sao trả về 404 hoặc báo không tìm thấy mô hình?**
`model` phải là ID đầy đủ trong Mô hình và giá, và nhóm của khóa phải có quyền dùng mô hình đó. Người dùng SDK cũng nên kiểm tra `baseURL` có `/v1` hay không.

**Có nên thử lại khi gặp 429?**
Hãy đọc nội dung phản hồi trước. Với giới hạn tốc độ, thử lại với backoff lũy thừa kèm jitter; với hạn mức hoặc số dư đã cạn, thử lại không thể thành công — hãy nạp thêm hoặc điều chỉnh hạn mức.

**Khi nào phản hồi streaming được coi là hoàn chỉnh?**
Chỉ sau khi nhận `data: [DONE]` và khối cuối có `finish_reason`. Nếu kết nối đứt mà không có dấu kết thúc, hãy coi phản hồi là chưa hoàn chỉnh và không tự động gửi lại yêu cầu đã bị tính phí.

**Dùng `max_tokens` hay `max_completion_tokens`?**
Với Chat Completions hãy dùng `max_completion_tokens`. `max_tokens` là trường cũ và chỉ một số mô hình còn chấp nhận. Không gửi cả hai; `/v1/completions` vẫn chỉ dùng `max_tokens`.

**Vì sao đặt temperature mà không có tác dụng?**
Một số mô hình suy luận cố định cách lấy mẫu hoặc chỉ nhận giá trị mặc định, còn gateway chuyển tiếp nguyên giá trị cho nhà cung cấp. Hãy theo tài liệu và lỗi của mô hình, đừng cho rằng mọi tham số OpenAI đều có hiệu lực.

## Tham khảo chính thức

* [OpenAI Chat Completions API](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [Sinh văn bản OpenAI](https\://developers.openai.com/api/docs/guides/text)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)