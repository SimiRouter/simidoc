# Công cụ tìm kiếm web

## Tổng quan API

`POST /v1/responses` khai báo công cụ web\_search OpenAI trong tools để mô hình hỗ trợ tìm, đọc, trả lời trích dẫn. Không là điểm cuối chung độc lập `/search` hay tên hàm mọi Chat dùng được.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

`{"type":"web_search"}` dành Responses; không nhét vào tools Chat thường (dùng function). Chat tìm kiếm chính thức có mô hình và web\_search\_options riêng, giao thức khác.

## Tham số yêu cầu

| Trường                            | Kiểu            | Bắt buộc | Mô tả                                                                                               |
| --------------------------------- | --------------- | -------- | --------------------------------------------------------------------------------------------------- |
| model                             | string          | Có       | Mô hình hỗ trợ Responses web\_search.                                                               |
| input                             | string / array  | Có       | Câu hỏi và bối cảnh cần.                                                                            |
| tools\[].type                     | string          | Có       | web\_search.                                                                                        |
| tools\[].search\_context\_size    | string          | Không    | low, medium, high ngữ cảnh tìm khi hỗ trợ.                                                          |
| tools\[].filters.allowed\_domains | array           | Không    | Giới hạn miền cho phép khi hỗ trợ, không tiền tố giao thức.                                         |
| tools\[].user\_location           | object          | Không    | Vị trí gần đúng type=approximate, country, city, region, timezone; tránh vị trí riêng tư chính xác. |
| tool\_choice                      | string / object | Không    | auto để mô hình chọn; required bắt công cụ.                                                         |
| include                           | array           | Không    | Dùng web\_search\_call.action.sources lấy toàn nguồn.                                               |
| stream                            | boolean         | Không    | true dùng sự kiện Responses SSE.                                                                    |

### Ví dụ yêu cầu

```json
{
  "model": "MODEL_ID",
  "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
  "tools": [
    {
      "type": "web_search"
    }
  ],
  "stream": false
}
```

## Phản hồi

| Trường                                   | Kiểu            | Mô tả                                                          |
| ---------------------------------------- | --------------- | -------------------------------------------------------------- |
| output\[].type=web\_search\_call         | object          | Một lần tìm/đọc; chỉ có mục này chưa chứng minh đáp án đầy đủ. |
| web\_search\_call.status                 | string          | Trạng thái công cụ.                                            |
| web\_search\_call.action                 | object          | search, open\_page, find và truy vấn/URL.                      |
| output\[].type=message                   | object          | Tin cuối mô hình.                                              |
| content\[].type / text                   | string          | Chữ mục output\_text.                                          |
| content\[].annotations\[]                | array           | Danh sách trích dẫn, thường url\_citation.                     |
| annotations\[].url / title               | string          | URL và tên nguồn.                                              |
| annotations\[].start\_index / end\_index | integer         | Khoảng văn bản gắn trích dẫn.                                  |
| status / error / incomplete\_details     | string / object | Trạng thái cuối và lý do lỗi/chưa đủ.                          |
| usage                                    | object          | Token mô hình; không chứng minh tìm kiếm không phí thêm.       |

```json
{
  "id": "resp_search_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ws_example",
      "type": "web_search_call",
      "status": "completed",
      "action": {
        "type": "search",
        "query": "site:developers.openai.com Responses API"
      }
    },
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "Responses API 支持有类型的输入输出以及工具调用。",
          "annotations": [
            {
              "type": "url_citation",
              "start_index": 0,
              "end_index": 36,
              "title": "Responses API",
              "url": "https://developers.openai.com/api/docs/guides/responses"
            }
          ]
        }
      ]
    }
  ]
}
```

Hiện trích dẫn rõ, nhấp được cùng đáp án và giữ tác giả nguồn. Trang web là dữ liệu, không chạy lệnh hay lộ khóa. Kết quả có thể cũ/mâu thuẫn; kết luận rủi ro cao kiểm nguồn gốc.

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
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
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
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      if (!process.env.SIMIROUTER_MODEL) throw new Error("请设置 SIMIROUTER_MODEL");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const body = {
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = "/v1/responses";
      const response = await fetch(base + endpoint, { method: "POST",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
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
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
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
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
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

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn có hoặc bằng HTTP. Cổng có thể lỗi trước hãng; HTTP không chứng minh nguồn lỗi. HTTP 200 vẫn phân biệt trạng thái tìm, đáp án và trích dẫn; thiếu nguồn không tuyên bố đã kiểm chứng.

## Tham khảo chính thức

* [Tìm kiếm web OpenAI](https\://developers.openai.com/api/docs/guides/tools-web-search)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)