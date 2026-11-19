# 文件内容识别

## 接口说明

`POST /v1/responses` 的 input\_file 内容项可以把文件交给支持该格式的模型处理。文件识别不是文件存储服务，也不等于 OCR 已保证完整正确。

接入地址为 `https://api.dwchainless.com`，请求头使用 `Authorization: Bearer $SIMIROUTER_API_KEY`。OpenAI 官方直连为 `https://api.openai.com`，同样使用 Bearer 鉴权，但必须换成 OpenAI 的 Key。 模型名称应选用账户可访问且支持目标能力的模型。

网关的 `/v1/files` 上传、查询和删除端点未实现；本页使用 Base64 内联 PDF，不依赖 Files API。官方直连还可先上传文件再用 file\_id 引用，但不能把官方 file\_id 自动当作网关可访问资源。

## 请求参数

| 字段                       | 类型      | 必填 | 说明                                                                                                 |
| ------------------------ | ------- | -- | -------------------------------------------------------------------------------------------------- |
| model                    | string  | 是  | 支持 PDF 输入及相关视觉能力的模型 ID。                                                                            |
| input\[].role            | string  | 是  | 此处为 user。                                                                                          |
| input\[].content\[].type | string  | 是  | 问题用 input\_text，文件用 input\_file。                                                                   |
| input\_text.text         | string  | 是  | 对文件提出的任务，如总结、提取字段或问答。                                                                              |
| input\_file.filename     | string  | 条件 | 内联数据的文件名，保留真实扩展名。                                                                                  |
| input\_file.file\_data   | string  | 条件 | PDF 的 Base64 数据；本页代码使用 data\:application/pdf;base64,... 前缀。官方规范只要求 Base64，渠道不接受前缀时去掉 data\:... 部分。 |
| input\_file.file\_id     | string  | 条件 | 官方上传后得到的文件 ID；依赖对应服务的 Files 支持。                                                                    |
| input\_file.file\_url    | string  | 条件 | 厂商可访问的文件 URL；与内联数据选择一种来源。                                                                          |
| max\_output\_tokens      | integer | 否  | 模型输出上限。                                                                                            |
| stream                   | boolean | 否  | true 使用 Responses SSE。                                                                             |

不要发送本地路径作为 file\_url，也不要同时填满 file\_data、file\_id 和 file\_url。单次请求大小必须同时满足网关限制与官方文件输入限制；Base64 比原文件更大，PDF 的页图还会增加模型输入 Token。

### 请求结构

BASE64\_PDF\_BYTES 表示原始 PDF 的 Base64；四语言代码读取 PDF\_PATH 后填入。

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

## 返回值

文件输入不会返回独立文件任务 ID；返回标准 Responses 对象。

| 字段                                                   | 类型               | 说明                                                                                  |
| ---------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------- |
| id / object                                          | string           | 响应 ID；object=response。                                                              |
| created\_at / model                                  | integer / string | 创建时间（Unix 秒）与模型。                                                                    |
| status                                               | string           | completed、incomplete、failed、queued、in\_progress、cancelled；流式与后台响应都可能出现这些状态。         |
| output\[]                                            | array            | 有类型的输出项，可能混合 message、reasoning、function\_call、web\_search\_call 等；不可固定读 output\[0]。 |
| output\[].type / id / status                         | string           | 输出项类型、ID 和项状态（视类型出现）。                                                               |
| output\[].role                                       | string           | 消息输出通常为 assistant。                                                                  |
| output\[].content\[]                                 | array            | 消息内容项，文本为 type=output\_text；拒绝为 type=refusal。                                       |
| output\[].content\[].text / annotations              | string / array   | 正文与引用等注释。                                                                           |
| output\[].call\_id / name / arguments                | string           | function\_call 的关联 ID、函数名、JSON 字符串参数。                                               |
| error                                                | object / null    | 失败信息；正常完成时通常为 null。                                                                 |
| incomplete\_details                                  | object / null    | 不完整原因，如 max\_output\_tokens，不应当作完整成功。                                               |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | 输入、输出和总 Token。                                                                      |
| usage.\*\_tokens\_details                            | object           | 可选缓存和推理等用量明细。                                                                       |

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

Chat Completions 也支持 `type=file`、嵌套 file.filename/file\_data 的 PDF 输入，但结构与 Responses 的 input\_file 不同。不要把任意 TXT、表格或压缩包的 Base64 当成所有接口都支持的文件格式；文本可由应用解码后作为文本发送，其他文件类型应先核对厂商与模型能力。

## 代码调用

设置 `SIMIROUTER_API_KEY`、`SIMIROUTER_FILE_MODEL`；`SIMIROUTER_BASE_URL` 可覆盖默认网关地址，不要在末尾追加 `/v1`。 `PDF_PATH` 指向已有的本地文件。 Python 3、Node.js 18+ 和 Go 示例只使用标准库；curl 示例的 JSON 由 Python 3 安全编码。

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

## 错误码

| HTTP 状态   | 含义或厂商错误类型    | 处理方式                      |
| --------- | ------------ | ------------------------- |
| 400       | 请求无效         | 检查必填字段、JSON、模型参数和上下文长度。   |
| 401       | 认证失败         | 检查 Key 是否存在、有效及归属正确。      |
| 403 / 404 | 无权访问 / 资源不存在 | 检查模型权限、资源 ID 和 URL。       |
| 429       | 速率或配额限制      | 结合响应体区分限流与额度不足，后者不能靠重试解决。 |
| 500 / 503 | 服务错误 / 暂时不可用 | 保留请求标识，对暂时故障做有限次数退避。      |

OpenAI 原生错误通常包含 `error.message`、`error.type`、`error.param`、`error.code`；`param`、`code` 可为 `null`，不能假定其始终存在或等于 HTTP 状态码。 网关可能在请求到达厂商前返回认证、路由或额度错误；不得仅凭 HTTP 数字判定错误来自上游。 文件损坏、密码保护、超限或模型不支持该文件格式，应修正输入；不要重试同一错误文件并伪造识别成功。

## 官方参考

* [OpenAI 文件输入](https\://developers.openai.com/api/docs/guides/file-inputs)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [OpenAI 错误处理](https\://developers.openai.com/api/docs/guides/error-codes)