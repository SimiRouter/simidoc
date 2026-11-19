# Bổ sung văn bản cũ

## Tổng quan API

`POST /v1/completions` nhận prompt, trả chữ bổ sung, không messages, công cụ hay mục Responses. API cũ; dự án mới ưu tiên Chat Completions hoặc Responses. Chỉ mô hình hỗ trợ giao thức này, không dùng tùy ý ID chat.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

## Bắt đầu nhanh

1. **Chuẩn bị cấu hình**\: tạo khóa tại Quản lý khóa API và sao chép ID mô hình đầy đủ hỗ trợ completions truyền thống từ Mô hình và giá.
2. **Gửi yêu cầu tối thiểu**\: chỉ gửi một `prompt` và giữ `stream` là `false`; trước tiên xác nhận xác thực, mô hình và tham số đều hợp lệ.
3. **Đọc kết quả**\: chỉ thành công khi HTTP 2xx và `choices[]` không rỗng; phần bổ sung nằm ở `choices[0].text`.
4. **Kiểm tra**\: xem `finish_reason` và nội dung thực tế, sau đó đối chiếu nhật ký sử dụng.

```bash
API_URL="https://api.dwchainless.com/v1/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "prompt": "请补全这句话：机器学习是",
    "max_tokens": 64,
    "stream": false
  }'
```

Thay `PASTE_API_KEY_HERE` và `MODEL_ID` bằng giá trị thực; dự án mới nên ưu tiên Chat Completions hoặc Responses.

## Tham số yêu cầu

Thân JSON.

| Trường                                 | Kiểu           | Bắt buộc     | Mô tả                                                                                     |
| -------------------------------------- | -------------- | ------------ | ----------------------------------------------------------------------------------------- |
| model                                  | string         | Có           | ID mô hình hỗ trợ bổ sung cũ.                                                             |
| prompt                                 | string / array | Có điều kiện | Chữ cần bổ sung, có thể nhiều đoạn hoặc mảng ID token; ví dụ dùng chuỗi.                  |
| max\_tokens                            | integer        | Không        | Token sinh tối đa; tổng với đầu vào phải trong cửa sổ.                                    |
| stream                                 | boolean        | Không        | true trả SSE, mặc định false.                                                             |
| temperature / top\_p                   | number         | Không        | Điều khiển lấy mẫu, thường chỉnh một.                                                     |
| n                                      | integer        | Không        | Số ứng viên cho mỗi prompt.                                                               |
| stop                                   | string / array | Không        | Tối đa 4 chuỗi dừng; kết quả không chứa chuỗi dừng.                                       |
| echo                                   | boolean        | Không        | Có đưa prompt đầu vào vào text trả về không.                                              |
| logprobs                               | integer        | Không        | Log xác suất token ứng viên, tối đa 5.                                                    |
| presence\_penalty / frequency\_penalty | number         | Không        | Phạt lặp, -2 đến 2.                                                                       |
| suffix                                 | string         | Không        | Chỉ mô hình hỗ trợ chèn bổ sung.                                                          |
| best\_of                               | integer        | Không        | Sinh nhiều ứng viên trên máy chủ rồi chọn tốt nhất; không cùng stream và tăng lượng sinh. |

### Ví dụ yêu cầu

```json
{
  "model": "MODEL_ID",
  "prompt": "请补全这句话：机器学习是",
  "max_tokens": 64,
  "stream": false
}
```

## Phản hồi

| Trường                                                    | Kiểu             | Mô tả                                                    |
| --------------------------------------------------------- | ---------------- | -------------------------------------------------------- |
| id / object                                               | string           | ID bổ sung; object=text\_completion.                     |
| created / model                                           | integer / string | Thời điểm Unix giây và mô hình.                          |
| choices\[].text                                           | string           | Kết quả bổ sung, không phải message.content.             |
| choices\[].index                                          | integer          | Chỉ số ứng viên.                                         |
| choices\[].finish\_reason                                 | string           | stop, length hoặc content\_filter.                       |
| choices\[].logprobs                                       | object / null    | Thông tin xác suất token; thường null nếu không yêu cầu. |
| usage.prompt\_tokens / completion\_tokens / total\_tokens | integer          | Token vào, sinh và tổng.                                 |

```json
{
  "id": "cmpl_example",
  "object": "text_completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "text": "一种从数据中学习规律的方法。",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 14,
    "total_tokens": 26
  }
}
```

Luồng nối choices\[].text và kết thúc ở `[DONE]`; nhiều prompt/ứng viên gộp riêng theo index.

## Ví dụ mã

Đặt `SIMIROUTER_API_KEY`, `SIMIROUTER_COMPLETION_MODEL`; `SIMIROUTER_BASE_URL` để ghi đè địa chỉ cổng mặc định; không thêm `/v1`. Ví dụ Python 3, Node.js 18+ và Go chỉ dùng thư viện chuẩn; ví dụ curl dùng Python 3 để mã hóa JSON an toàn.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_COMPLETION_MODEL"): raise RuntimeError("请设置 SIMIROUTER_COMPLETION_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    path = '/v1/completions'
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
      if (!process.env.SIMIROUTER_COMPLETION_MODEL)
        throw new Error('请设置 SIMIROUTER_COMPLETION_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        prompt: '请补全这句话：机器学习是',
        max_tokens: 64,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_COMPLETION_MODEL;
      const endpoint = '/v1/completions';
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
    : "${SIMIROUTER_COMPLETION_MODEL:?请设置 SIMIROUTER_COMPLETION_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/completions" \
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
      model := os.Getenv("SIMIROUTER_COMPLETION_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_COMPLETION_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/completions"
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

| Trạng thái HTTP | Ý nghĩa hoặc loại lỗi hãng           | Cách xử lý                                                                                              |
| --------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------- |
| 400             | Yêu cầu không hợp lệ                 | Kiểm tra trường bắt buộc, JSON, tham số và độ dài ngữ cảnh.                                             |
| 401             | Xác thực thất bại                    | Kiểm tra khóa có, hợp lệ và thuộc đúng dịch vụ.                                                         |
| 403 / 404       | Không có quyền / không có tài nguyên | Kiểm tra quyền mô hình, ID và URL.                                                                      |
| 429             | Giới hạn tốc độ hoặc hạn mức         | Theo thân phản hồi phân biệt giới hạn tốc độ với thiếu hạn mức; thử lại không giải quyết thiếu hạn mức. |
| 500 / 503       | Lỗi máy chủ / tạm không khả dụng     | Giữ ID yêu cầu, lùi thời gian giới hạn cho lỗi tạm.                                                     |

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn tồn tại hoặc bằng HTTP. Cổng có thể báo xác thực, tuyến, hạn mức trước hãng; mã HTTP không chứng minh lỗi thượng nguồn.

Phản hồi dài và yêu cầu streaming có thể mất từ vài chục giây đến vài phút; hãy đặt thời gian chờ đủ lớn, khi luồng bị ngắt thì dựa trên phần đã nhận và lý do kết thúc thay vì tự động gửi lại. Với 429 và 5xx, xem nội dung phản hồi và nhật ký sử dụng trước; khi bị chính sách nội dung từ chối, hãy sửa prompt hoặc đầu vào thay vì thử lại nguyên trạng.

## Tham khảo chính thức

* [OpenAI Completions API](https\://developers.openai.com/api/reference/resources/completions/methods/create)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)