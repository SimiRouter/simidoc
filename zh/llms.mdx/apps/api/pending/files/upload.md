# 上传文件

上传本地文件，取得供 OpenAI 其他接口引用的文件 ID。

**SimiRouter 暂不支持此接口。以下为 OpenAI 官方 API 参考，调用地址为 `api.openai.com`，需要 OpenAI 项目的密钥，不能使用 SimiRouter Key。**

## 接口说明

* **方法**：`POST`
* **接口地址**：`/v1/files`
* **鉴权**：`Authorization: Bearer $OPENAI_API_KEY`
* **请求类型**：`multipart/form-data`。

HTTP 请求返回文件对象，不代表依赖该文件的训练、批处理或索引任务已经完成。单文件上限512 MB；Batch 输入另有200 MB上限，微调输入必须为JSONL。不要手写 multipart boundary，由客户端生成。

## 请求参数

| 参数              | 类型     | 必填 | 说明                                                                                        |
| --------------- | ------ | -- | ----------------------------------------------------------------------------------------- |
| `file`          | binary | 是  | 文件本体，而不是文件名字符串。                                                                           |
| `purpose`       | string | 是  | 用途：`assistants`、`batch`、`fine-tune`、`vision`、`user_data` 或 `evals`。                       |
| `expires_after` | object | 否  | 过期策略；`anchor` 固定为 `created_at`，`seconds` 为 3600～2592000。未设置时 batch 文件默认30天过期，其他文件保留至手动删除。 |

## 返回值

| 字段               | 类型                   | 说明                                                                  |
| ---------------- | -------------------- | ------------------------------------------------------------------- |
| `id`             | string               | 文件 ID，供后续请求引用。                                                      |
| `object`         | string               | 固定为 `file`。                                                         |
| `bytes`          | integer / null       | 文件大小，单位为字节；尚未获取大小时可能为 null。                                         |
| `created_at`     | integer              | 创建时间，Unix 秒级时间戳。                                                    |
| `filename`       | string               | 上传时的文件名。                                                            |
| `purpose`        | string               | 文件用途，例如 `fine-tune`、`user_data`；生成的结果文件可能使用 `fine-tune-results` 等值。 |
| `expires_at`     | integer / null，可选    | 过期时间，Unix 秒级时间戳；未设置过期策略时可能为空。                                       |
| `status`         | string，已弃用           | 旧状态字段：`uploaded`、`processed` 或 `error`。不要用它替代消费端点自身的处理状态。           |
| `status_details` | string / null，可选，已弃用 | 旧状态说明；微调数据校验错误应读取任务的 `error`。                                       |

响应示例（ID 与时间仅用于说明结构）：

```json
{
  "id": "file-demo",
  "object": "file",
  "bytes": 4096,
  "created_at": 1793491200,
  "filename": "training.jsonl",
  "purpose": "fine-tune",
  "expires_at": null
}
```

## 代码调用

运行要求：Python 3、Node.js 20 或更新版本、curl、Go 1.20 或更新版本。各语言示例分别保存为 `.py`、`.cjs`、`.sh`、`.go` 文件后运行。

示例上传用于微调的 JSONL 文件。先设置 `OPENAI_API_KEY` 与 `INPUT_FILE`；训练集必须符合所选微调方法的数据格式。上传本身不启动训练。

示例为清晰展示 multipart 构造而将文件载入内存；大文件应改用流式上传。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.request
    import uuid
    from pathlib import Path

    key = os.environ.get("OPENAI_API_KEY")
    source = os.environ.get("INPUT_FILE")
    if not key or not source:
        raise SystemExit("请设置 OPENAI_API_KEY 和 INPUT_FILE")
    path = Path(source)
    if not path.is_file() or path.stat().st_size == 0:
        raise SystemExit("INPUT_FILE 必须是非空的本地文件")
    boundary = "upload-" + uuid.uuid4().hex
    body = (
        f'--{boundary}\r\nContent-Disposition: form-data; name="purpose"\r\n\r\nfine-tune\r\n'
        f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="training.jsonl"\r\n'
        'Content-Type: application/jsonl\r\n\r\n'
    ).encode() + path.read_bytes() + f"\r\n--{boundary}--\r\n".encode()
    request = urllib.request.Request(
        "https://api.openai.com/v1/files", method="POST", data=body,
        headers={"Authorization": "Bearer " + key,
                 "Content-Type": "multipart/form-data; boundary=" + boundary},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            print(json.dumps(json.load(response), ensure_ascii=False, indent=2))
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile, stat } = require("node:fs/promises");
    const { basename } = require("node:path");
    async function main() {
      const key = process.env.OPENAI_API_KEY;
      const path = process.env.INPUT_FILE;
      if (!key || !path) throw new Error("请设置 OPENAI_API_KEY 和 INPUT_FILE");
      const info = await stat(path);
      if (!info.isFile() || info.size === 0) throw new Error("INPUT_FILE 必须是非空的本地文件");
      const form = new FormData();
      form.append("purpose", "fine-tune");
      form.append("file", new Blob([await readFile(path)], { type: "application/jsonl" }), basename(path));
      const response = await fetch("https://api.openai.com/v1/files", {
        method: "POST", headers: { Authorization: `Bearer ${key}` }, body: form,
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.json());
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"
    : "${INPUT_FILE:?请设置 INPUT_FILE 为训练集的本地路径}"
    [[ -f "$INPUT_FILE" && -s "$INPUT_FILE" ]] || { printf '%s\n' 'INPUT_FILE 必须是非空的本地文件' >&2; exit 1; }
    curl --fail-with-body --connect-timeout 15 --max-time 120 --request POST \
      "https://api.openai.com/v1/files" \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --form "purpose=fine-tune" \
      --form "file=@${INPUT_FILE};type=application/jsonl"
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
    	"mime/multipart"
    	"net/http"
    	"os"
    	"path/filepath"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func main() {
    	key, path := os.Getenv("OPENAI_API_KEY"), os.Getenv("INPUT_FILE")
    	if key == "" || path == "" {
    		log.Fatal("请设置 OPENAI_API_KEY 和 INPUT_FILE")
    	}
    	file, err := os.Open(path)
    	check(err)
    	defer file.Close()
    	info, err := file.Stat()
    	check(err)
    	if !info.Mode().IsRegular() || info.Size() == 0 {
    		log.Fatal("INPUT_FILE 必须是非空的本地文件")
    	}
    	var body bytes.Buffer
    	form := multipart.NewWriter(&body)
    	check(form.WriteField("purpose", "fine-tune"))
    	part, err := form.CreateFormFile("file", filepath.Base(path))
    	check(err)
    	_, err = io.Copy(part, file)
    	check(err)
    	check(form.Close())
    	req, err := http.NewRequest("POST", "https://api.openai.com/v1/files", &body)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	req.Header.Set("Content-Type", form.FormDataContentType())
    	response, err := (&http.Client{Timeout: 120 * time.Second}).Do(req)
    	check(err)
    	defer response.Body.Close()
    	result, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, result)
    	}
    	fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## 错误码

以下为 OpenAI 官方直连请求的常见 HTTP 错误，不是 SimiRouter 的支持状态。

| HTTP 状态码      | 含义                | 处理方式                                       |
| ------------- | ----------------- | ------------------------------------------ |
| `400`         | 参数、文件用途或资源状态不符合要求 | 读取 `error.message` 和 `error.param`，修正后再提交。 |
| `401`         | 密钥无效或缺失           | 检查 OpenAI 密钥及其所属项目。                        |
| `403`         | 无权访问项目或资源         | 检查项目、组织和角色权限。                              |
| `404`         | 文件、任务或模型不存在       | 核对 ID，并使用资源所属项目的密钥。                        |
| `429`         | 速率限制或额度不足         | 区分限流与额度错误；限流时退避，额度不足时不要重复提交。               |
| `500` / `503` | 服务端异常或暂不可用        | 保留请求 ID；写入请求先核对是否已创建资源，避免重复上传或重复训练。        |

非成功响应通常包含 `error.message`、`error.type`、`error.param` 和 `error.code`；字段可能为空。

## 官方参考

* [OpenAI 上传文件](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [OpenAI 错误码](https\://developers.openai.com/api/docs/guides/error-codes)