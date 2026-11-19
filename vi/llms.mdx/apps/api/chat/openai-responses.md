# Responses API

## Tổng quan API

`POST /v1/responses` dùng mục vào/ra thay choices/message của Chat, phù hợp công cụ, đa phương thức và đầu ra cấu trúc.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

Cổng có tạo phản hồi, không có giao diện chung `GET /v1/responses/{id}` hoặc hủy. Vì vậy quy trình bất đồng bộ OpenAI gốc với `background: true` không dùng được tại đây; dùng đồng bộ hoặc SSE. Tác vụ nền cần kết nối chính thức đầy đủ tạo, lấy, hủy.

## Bắt đầu nhanh

1. **Chuẩn bị cấu hình**\: tạo khóa tại Quản lý khóa API và sao chép ID mô hình đầy đủ hỗ trợ Responses từ Mô hình và giá.
2. **Gửi yêu cầu tối thiểu**\: gửi một đoạn văn bản làm `input` và giữ `stream` là `false`; trước tiên xác nhận xác thực, mô hình và tham số đều hợp lệ.
3. **Đọc kết quả**\: chỉ thành công khi HTTP 2xx và `status` là `completed`; nội dung nằm ở mục `output[].content[]` có `type=output_text`.
4. **Kiểm tra**\: xem `error`, `incomplete_details` và nội dung thực tế, sau đó đối chiếu nhật ký sử dụng.

```bash
API_URL="https://api.dwchainless.com/v1/responses"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "input": "用一句话解释机器学习。",
    "stream": false
  }'
```

Thay `PASTE_API_KEY_HERE` và `MODEL_ID` bằng giá trị thực; sau khi xác nhận hoạt động, hãy thêm công cụ, đầu ra có cấu trúc hoặc bật streaming.

## Tham số yêu cầu

Loại nội dung là `application/json`.

| Trường                                                | Kiểu                     | Bắt buộc     | Mô tả                                                                                                                                                                                   |
| ----------------------------------------------------- | ------------------------ | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                                                 | string                   | Có           | Bắt buộc khi qua cổng, chọn mô hình hỗ trợ Responses.                                                                                                                                   |
| input                                                 | string / array           | Có điều kiện | Văn bản hoặc danh sách mục vào; sinh thường cần đầu vào, có thể kèm lịch sử khả dụng.                                                                                                   |
| input\[].role                                         | string                   | Có điều kiện | Vai trò\: user, assistant, system hoặc developer.                                                                                                                                       |
| input\[].content\[].type                              | string                   | Có điều kiện | Mục có kiểu input\_text, input\_image, input\_file.                                                                                                                                     |
| input\[].content\[].text                              | string                   | Có điều kiện | Văn bản cho type=input\_text.                                                                                                                                                           |
| input\[].content\[].image\_url                        | string                   | Có điều kiện | URL ảnh hoặc data URL cho type=input\_image.                                                                                                                                            |
| input\[].content\[].file\_data / file\_url / file\_id | string                   | Có điều kiện | Chọn một nguồn tệp cho type=input\_file, xem hiểu tệp.                                                                                                                                  |
| instructions                                          | string                   | Không        | Chỉ dẫn ưu tiên cao; dùng previous\_response\_id vẫn gửi lại chỉ dẫn cần.                                                                                                               |
| max\_output\_tokens                                   | integer                  | Không        | Tổng token đầu ra tối đa gồm suy luận.                                                                                                                                                  |
| stream                                                | boolean                  | Không        | true trả SSE có loại sự kiện.                                                                                                                                                           |
| previous\_response\_id                                | string                   | Không        | ID phản hồi trước, tùy lưu trạng thái và cùng ngữ cảnh truy cập được. Không cùng conversation.                                                                                          |
| conversation                                          | string / object          | Không        | Đối tượng hoặc ID hội thoại; không dùng cùng previous\_response\_id. Khả dụng tùy kênh.                                                                                                 |
| store                                                 | boolean                  | Không        | Yêu cầu thượng nguồn lưu phản hồi, không phải công tắc giữ nhật ký cổng.                                                                                                                |
| tools / tool\_choice                                  | array / string or object | Không        | Hàm hoặc công cụ hãng cùng quy tắc chọn.                                                                                                                                                |
| parallel\_tool\_calls                                 | boolean                  | Không        | Cho phép nhiều hàm trong một phản hồi hay không.                                                                                                                                        |
| reasoning                                             | object                   | Không        | Mô hình suy luận hỗ trợ có effort, summary; giá trị tùy mô hình.                                                                                                                        |
| text.format                                           | object                   | Không        | Định dạng như type=json\_schema, khác response\_format Chat.                                                                                                                            |
| temperature / top\_p                                  | number                   | Không        | Tham số lấy mẫu khi mô hình hỗ trợ.                                                                                                                                                     |
| truncation                                            | string                   | Không        | OpenAI đã đánh dấu không dùng nữa; nên chuyển sang context\_management. disabled (mặc định) báo lỗi khi quá ngữ cảnh, auto có thể bỏ bớt ngữ cảnh. Hỗ trợ của cổng tùy hành vi thực tế. |
| include                                               | array                    | Không        | Yêu cầu dữ liệu thêm như reasoning.encrypted\_content, web\_search\_call.action.sources.                                                                                                |
| metadata                                              | object                   | Không        | Siêu dữ liệu liên kết nghiệp vụ, không lưu dữ liệu nhạy cảm.                                                                                                                            |

Bỏ trường tùy chọn chưa cấu hình. `stop`, `enable_thinking` và mở rộng tương thích khác không là trường chuẩn Responses. `reasoning_content` cũng không là đầu ra chuẩn; suy luận dùng mục reasoning riêng và không hứa lộ chuỗi suy nghĩ nội bộ.

### Ví dụ yêu cầu

```json
{
  "model": "MODEL_ID",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "用一句话解释什么是机器学习。"
        }
      ]
    }
  ],
  "max_output_tokens": 256,
  "stream": false
}
```

## Phản hồi

Không luồng thành công trả HTTP 200. Trường chính bên dưới; trạng thái tùy chọn chưa dùng có thể null.

| Trường                                               | Kiểu             | Mô tả                                                                                                                                   |
| ---------------------------------------------------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| id / object                                          | string           | ID phản hồi; object=response.                                                                                                           |
| created\_at / model                                  | integer / string | Thời điểm Unix giây và mô hình.                                                                                                         |
| status                                               | string           | completed, incomplete, failed, queued, in\_progress hoặc cancelled; các trạng thái này có thể xuất hiện cả trong luồng và phản hồi nền. |
| output\[]                                            | array            | Mục có kiểu có thể gồm message, reasoning, function\_call, web\_search\_call; không cố định output\[0].                                 |
| output\[].type / id / status                         | string           | Loại, ID và trạng thái mục nếu áp dụng.                                                                                                 |
| output\[].role                                       | string           | Tin đầu ra thường assistant.                                                                                                            |
| output\[].content\[]                                 | array            | Nội dung\: type=output\_text cho chữ, type=refusal cho từ chối.                                                                         |
| output\[].content\[].text / annotations              | string / array   | Chữ và chú thích như trích dẫn.                                                                                                         |
| output\[].call\_id / name / arguments                | string           | ID liên kết, tên và tham số chuỗi JSON của function\_call.                                                                              |
| error                                                | object / null    | Lỗi, thường null khi hoàn tất thường.                                                                                                   |
| incomplete\_details                                  | object / null    | Lý do chưa đầy đủ như max\_output\_tokens, không coi thành công đầy đủ.                                                                 |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | Token vào, ra và tổng.                                                                                                                  |
| usage.\*\_tokens\_details                            | object           | Chi tiết tùy chọn về cache, suy luận.                                                                                                   |

```json
{
  "id": "resp_example",
  "object": "response",
  "created_at": 1760000000,
  "model": "MODEL_ID",
  "status": "completed",
  "error": null,
  "incomplete_details": null,
  "output": [
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "机器学习让计算机从数据中学习规律，用于预测和决策。",
          "annotations": []
        }
      ]
    }
  ],
  "usage": {
    "input_tokens": 18,
    "output_tokens": 22,
    "total_tokens": 40
  }
}
```

Để lấy chữ, duyệt `output` các mục có `type=message` rồi nối text của `content` dưới `type=output_text`. SDK có `output_text` là thuộc tính gộp tiện ích, không bắt buộc trong JSON REST thô.

### Phản hồi luồng

Với stream=true, phân tích SSE `event` và `data`\: response.created tạo phản hồi; response.output\_text.delta nối chữ; response.output\_item.added/done quản lý mục; response.function\_call\_arguments.delta nối tham số. Chỉ response.completed cùng kiểm tra response.status cuối chứng minh hoàn tất. Xử lý failed, incomplete, error riêng; EOF không tự nghĩa thành công.

```text
event: response.output_text.delta
data: {"type":"response.output_text.delta","item_id":"msg_example","output_index":0,"content_index":0,"delta":"机器学习","sequence_number":3}

event: response.completed
data: {"type":"response.completed","response":{"id":"resp_example","object":"response","status":"completed","output":[]},"sequence_number":12}
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/responses'
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
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        input: [
          {
            role: 'user',
            content: [
              {
                type: 'input_text',
                text: '用一句话解释什么是机器学习。',
              },
            ],
          },
        ],
        max_output_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/responses';
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/responses" \
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/responses"
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

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn tồn tại hoặc bằng HTTP. Cổng có thể báo xác thực, tuyến, hạn mức trước hãng; mã HTTP không chứng minh lỗi thượng nguồn. Dù HTTP 200 vẫn kiểm tra status, error, incomplete\_details; SSE lỗi không nhất thiết đổi HTTP đã gửi.

Phản hồi dài và yêu cầu streaming có thể mất từ vài chục giây đến vài phút; hãy đặt thời gian chờ đủ lớn, khi luồng bị ngắt thì dựa trên phần đã nhận và lý do kết thúc thay vì tự động gửi lại. Với 429 và 5xx, xem nội dung phản hồi và nhật ký sử dụng trước; khi bị chính sách nội dung từ chối, hãy sửa prompt hoặc đầu vào thay vì thử lại nguyên trạng.

## Tham khảo chính thức

* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [Sự kiện luồng OpenAI](https\://developers.openai.com/api/docs/guides/streaming-responses)
* [Trạng thái hội thoại OpenAI](https\://developers.openai.com/api/docs/guides/conversation-state)
* [Chế độ nền OpenAI](https\://developers.openai.com/api/docs/guides/background)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)