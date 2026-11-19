# Hiểu nội dung tệp

## Tổng quan API

`POST /v1/responses` input\_file đưa tệp vào mô hình hỗ trợ. Không là lưu trữ và không đảm bảo OCR đầy đủ/đúng.

Địa chỉ kết nối là `https://api.dwchainless.com`, header dùng `Authorization: Bearer $SIMIROUTER_API_KEY`. OpenAI trực tiếp dùng `https://api.openai.com` và Bearer nhưng cần khóa OpenAI. Chọn mô hình tài khoản có quyền và hỗ trợ khả năng cần dùng.

Cổng `/v1/files` chưa triển khai tải, lấy, xóa; trang dùng PDF Base64 không Files API. Hãng trực tiếp có thể tải rồi file\_id, nhưng không mặc định ID đó cổng truy cập được.

## Tham số yêu cầu

| Trường                   | Kiểu    | Bắt buộc     | Mô tả                                                                                                                                                                      |
| ------------------------ | ------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                    | string  | Có           | ID mô hình hỗ trợ PDF và thị giác cần.                                                                                                                                     |
| input\[].role            | string  | Có           | Ở đây user.                                                                                                                                                                |
| input\[].content\[].type | string  | Có           | Câu hỏi input\_text, tệp input\_file.                                                                                                                                      |
| input\_text.text         | string  | Có           | Tác vụ tệp như tóm tắt, trích trường, hỏi đáp.                                                                                                                             |
| input\_file.filename     | string  | Có điều kiện | Tên tệp nội tuyến, giữ đuôi thật.                                                                                                                                          |
| input\_file.file\_data   | string  | Có điều kiện | Dữ liệu Base64 của PDF; mã trong trang dùng tiền tố data\:application/pdf;base64,... . Đặc tả chính thức chỉ yêu cầu Base64, hãy bỏ tiền tố data\:... nếu kênh không nhận. |
| input\_file.file\_id     | string  | Có điều kiện | ID từ tải chính thức, tùy Files của dịch vụ đó.                                                                                                                            |
| input\_file.file\_url    | string  | Có điều kiện | URL hãng đọc được, chọn một nguồn thay dữ liệu nội tuyến.                                                                                                                  |
| max\_output\_tokens      | integer | Không        | Giới hạn đầu ra mô hình.                                                                                                                                                   |
| stream                   | boolean | Không        | true dùng Responses SSE.                                                                                                                                                   |

Không gửi đường dẫn máy làm file\_url hay cùng điền file\_data, file\_id, file\_url. Kích thước phải đáp ứng cổng và hãng. Base64 lớn hơn gốc, ảnh trang PDF tăng token.

### Cấu trúc yêu cầu

BASE64\_PDF\_BYTES là PDF Base64 gốc; bốn mã đọc PDF\_PATH để điền.

```json
{
  "model": "MODEL_ID",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "请总结PDF的主要内容，并标注无法可靠读取的部分。"
        },
        {
          "type": "input_file",
          "filename": "document.pdf",
          "file_data": "data:application/pdf;base64,BASE64_PDF_BYTES"
        }
      ]
    }
  ],
  "max_output_tokens": 1024,
  "stream": false
}
```

## Phản hồi

Trả đối tượng Responses chuẩn, không ID tác vụ tệp riêng.

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
  "id": "resp_file_example",
  "object": "response",
  "status": "completed",
  "error": null,
  "incomplete_details": null,
  "output": [
    {
      "id": "msg_file_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "这份文档主要讨论项目背景、实施步骤和风险。部分扫描页较模糊，无法确认细小文字。",
          "annotations": []
        }
      ]
    }
  ],
  "usage": {
    "input_tokens": 1800,
    "output_tokens": 75,
    "total_tokens": 1875
  }
}
```

Chat Completions cũng hỗ trợ `type=file` và file.filename/file\_data lồng cho PDF, khác Responses input\_file. TXT, bảng hay zip Base64 không được mọi API hỗ trợ. Ứng dụng có thể giải chữ rồi gửi dạng chữ; loại khác kiểm hãng/mô hình.

## Ví dụ mã

Đặt `SIMIROUTER_API_KEY`, `SIMIROUTER_FILE_MODEL`; `SIMIROUTER_BASE_URL` để ghi đè địa chỉ cổng mặc định; không thêm `/v1`. `PDF_PATH` trỏ tới tệp cục bộ có thật. Python 3, Node.js 18+ và Go dùng thư viện chuẩn; curl dùng Python 3 mã hóa JSON an toàn.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    import base64
    from pathlib import Path
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_FILE_MODEL"): raise RuntimeError("请设置 SIMIROUTER_FILE_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "请总结PDF的主要内容，并标注无法可靠读取的部分。"
            },
            {
              "type": "input_file",
              "filename": "document.pdf",
              "file_data": "data:application/pdf;base64,BASE64_PDF_BYTES"
            }
          ]
        }
      ],
      "max_output_tokens": 1024,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_FILE_MODEL"]
    p = Path(os.environ["PDF_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["input"][0]["content"][1].update({"filename": p.name, "file_data": "data:" + mime + ";base64," + encoded})
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
      const fs = require("node:fs");
      const path = require("node:path");
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      if (!process.env.SIMIROUTER_FILE_MODEL) throw new Error("请设置 SIMIROUTER_FILE_MODEL");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const body = {
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "请总结PDF的主要内容，并标注无法可靠读取的部分。"
            },
            {
              "type": "input_file",
              "filename": "document.pdf",
              "file_data": "data:application/pdf;base64,BASE64_PDF_BYTES"
            }
          ]
        }
      ],
      "max_output_tokens": 1024,
      "stream": false
    };
      body.model = process.env.SIMIROUTER_FILE_MODEL;
      const filename = process.env.PDF_PATH;
      if (!filename) throw new Error("请设置 PDF_PATH");
      const mime = {".pdf": "application/pdf"}[path.extname(filename).toLowerCase()];
      if (!mime) throw new Error("不支持的文件扩展名");
      const data = fs.readFileSync(filename);
      if (!data.length) throw new Error("输入文件为空");
      const encoded = data.toString("base64");
      Object.assign(body.input[0].content[1], { filename: path.basename(filename), file_data: `data:${mime};base64,${encoded}` });
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
    : "${SIMIROUTER_FILE_MODEL:?请设置 SIMIROUTER_FILE_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    import base64
    from pathlib import Path
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "请总结PDF的主要内容，并标注无法可靠读取的部分。"
            },
            {
              "type": "input_file",
              "filename": "document.pdf",
              "file_data": "data:application/pdf;base64,BASE64_PDF_BYTES"
            }
          ]
        }
      ],
      "max_output_tokens": 1024,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_FILE_MODEL"]
    p = Path(os.environ["PDF_PATH"])
    if not p.is_file(): raise FileNotFoundError(p)
    mime = {'.pdf': 'application/pdf'}.get(p.suffix.lower())
    if not mime: raise ValueError("不支持的文件扩展名")
    data = p.read_bytes()
    if not data: raise ValueError("输入文件为空")
    encoded = base64.b64encode(data).decode("ascii")
    body["input"][0]["content"][1].update({"filename": p.name, "file_data": "data:" + mime + ";base64," + encoded})
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
      "encoding/base64"
      "path/filepath"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_FILE_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_FILE_MODEL") }
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
              "text": "请总结PDF的主要内容，并标注无法可靠读取的部分。"
            },
            {
              "type": "input_file",
              "filename": "document.pdf",
              "file_data": "data:application/pdf;base64,BASE64_PDF_BYTES"
            }
          ]
        }
      ],
      "max_output_tokens": 1024,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      filename := os.Getenv("PDF_PATH"); if filename == "" { log.Fatal("请设置 PDF_PATH") }
      mime := map[string]string{".pdf":"application/pdf"}[strings.ToLower(filepath.Ext(filename))]
      if mime == "" { log.Fatal("不支持的文件扩展名") }
      data, err := os.ReadFile(filename); if err != nil { log.Fatal(err) }; if len(data) == 0 { log.Fatal("输入文件为空") }
      encoded := base64.StdEncoding.EncodeToString(data)
      item := body["input"].([]any)[0].(map[string]any)["content"].([]any)[1].(map[string]any); item["filename"] = filepath.Base(filename); item["file_data"] = "data:" + mime + ";base64," + encoded
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

Lỗi OpenAI gốc thường gồm `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` có thể là `null`; không mặc định luôn có hoặc bằng HTTP. Cổng có thể lỗi trước hãng. Tệp hỏng, khóa mật khẩu, quá giới hạn, không hỗ trợ cần sửa; không thử nguyên tệp lỗi hay giả nhận dạng thành công.

## Tham khảo chính thức

* [Đầu vào tệp OpenAI](https\://developers.openai.com/api/docs/guides/file-inputs)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [Xử lý lỗi OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)