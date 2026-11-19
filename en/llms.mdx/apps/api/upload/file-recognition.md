# File content understanding

## Endpoint overview

`POST /v1/responses` input\_file items let supported models process files. File understanding is not file storage and does not guarantee complete or accurate OCR.

The gateway URL is `https://api.dwchainless.com`, with the request header `Authorization: Bearer $SIMIROUTER_API_KEY`. Direct OpenAI access uses `https://api.openai.com` and Bearer authentication, but requires an OpenAI key. Select a model available to the account that supports the required capability.

The gateway’s `/v1/files` upload, retrieval, and deletion endpoints are unimplemented. This page inlines Base64 PDFs without Files API dependencies. Direct official access can upload a file and reference file\_id, but an official file\_id is not automatically gateway-accessible.

## Request parameters

| Field                    | Type    | Required    | Description                                                                                                                                                                             |
| ------------------------ | ------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                    | string  | Yes         | A model ID supporting PDF input and the required vision capabilities.                                                                                                                   |
| input\[].role            | string  | Yes         | user here.                                                                                                                                                                              |
| input\[].content\[].type | string  | Yes         | Use input\_text for questions and input\_file for files.                                                                                                                                |
| input\_text.text         | string  | Yes         | The file task, such as summarizing, extracting fields, or answering questions.                                                                                                          |
| input\_file.filename     | string  | Conditional | The inline file’s name, retaining its real extension.                                                                                                                                   |
| input\_file.file\_data   | string  | Conditional | The PDF’s Base64 data; this page’s code uses a data\:application/pdf;base64,... prefix. The official spec only requires Base64, so drop the data\:... prefix if the channel rejects it. |
| input\_file.file\_id     | string  | Conditional | A file ID from an official upload; depends on the corresponding service’s Files support.                                                                                                |
| input\_file.file\_url    | string  | Conditional | A file URL readable by the vendor; select one source rather than combining with inline data.                                                                                            |
| max\_output\_tokens      | integer | No          | The model output limit.                                                                                                                                                                 |
| stream                   | boolean | No          | true uses Responses SSE.                                                                                                                                                                |

Do not send a local path as file\_url or populate file\_data, file\_id, and file\_url together. Request size must satisfy both gateway and official file-input limits. Base64 is larger than the source, and PDF page images increase model input tokens.

### Request structure

BASE64\_PDF\_BYTES represents the original PDF’s Base64; the four language examples populate it after reading PDF\_PATH.

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

## Response

File input returns a standard Responses object, not a separate file-task ID.

| Field                                                | Type             | Description                                                                                                                           |
| ---------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| id / object                                          | string           | Response ID; object=response.                                                                                                         |
| created\_at / model                                  | integer / string | Creation time in Unix seconds and model.                                                                                              |
| status                                               | string           | completed, incomplete, failed, queued, in\_progress, or cancelled; these states can appear in both streamed and background responses. |
| output\[]                                            | array            | Typed output items may mix message, reasoning, function\_call, web\_search\_call, and more; do not hard-code output\[0].              |
| output\[].type / id / status                         | string           | Output item type, ID, and status, where applicable.                                                                                   |
| output\[].role                                       | string           | Message output usually uses assistant.                                                                                                |
| output\[].content\[]                                 | array            | Message content items\: type=output\_text for text, type=refusal for refusals.                                                        |
| output\[].content\[].text / annotations              | string / array   | Response text and annotations such as citations.                                                                                      |
| output\[].call\_id / name / arguments                | string           | The function\_call correlation ID, name, and JSON-string arguments.                                                                   |
| error                                                | object / null    | Failure information; usually null on normal completion.                                                                               |
| incomplete\_details                                  | object / null    | The incomplete reason, such as max\_output\_tokens; do not treat it as complete success.                                              |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | Input, output, and total tokens.                                                                                                      |
| usage.\*\_tokens\_details                            | object           | Optional usage details such as caching and reasoning.                                                                                 |

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

Chat Completions also supports `type=file` and nested file.filename/file\_data for PDFs, but differs from Responses input\_file. Base64 for arbitrary TXT files, spreadsheets, or archives is not universally supported. Applications can decode text and send it as text; verify vendor and model support for other formats first.

## Code examples

Set `SIMIROUTER_API_KEY`, `SIMIROUTER_FILE_MODEL`; `SIMIROUTER_BASE_URL` overrides the default gateway root; do not append `/v1`. `PDF_PATH` points to an existing local file. Python 3, Node.js 18+, and Go examples use only standard libraries; the curl example uses Python 3 to encode JSON safely.

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

## Errors

| HTTP status | Meaning or vendor error type           | Action                                                                                                           |
| ----------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| 400         | Invalid request                        | Check required fields, JSON, model parameters, and context length.                                               |
| 401         | Authentication failed                  | Check that the key exists, is valid, and belongs to the correct service.                                         |
| 403 / 404   | Access denied / resource not found     | Check model permissions, resource IDs, and the URL.                                                              |
| 429         | Rate or quota limit                    | Distinguish rate limits from insufficient quota using the response body; retrying cannot fix insufficient quota. |
| 500 / 503   | Server error / temporarily unavailable | Retain the request identifier and use bounded backoff for transient failures.                                    |

Native OpenAI errors usually contain `error.message`, `error.type`, `error.param`, `error.code`; `param`, `code` may be `null`; do not assume these fields always exist or equal the HTTP status. The gateway may return authentication, routing, or quota errors before contacting the vendor; the status alone does not establish an upstream error. Correct damaged, password-protected, oversized, or unsupported files; do not repeatedly retry an invalid file or fabricate successful recognition.

## Official reference

* [OpenAI file input](https\://developers.openai.com/api/docs/guides/file-inputs)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [OpenAI error handling](https\://developers.openai.com/api/docs/guides/error-codes)