# 上傳檔案

上傳本機檔案，取得供 OpenAI 其他介面引用的檔案 ID。

**SimiRouter 暫不支援此介面。以下為 OpenAI 官方 API 參考，呼叫位址為 `api.openai.com`，需要 OpenAI 項目的金鑰，不能使用 SimiRouter Key。**

## 介面說明

* **方法**：`POST`
* **介面位址**：`/v1/files`
* **身分驗證**：`Authorization: Bearer $OPENAI_API_KEY`
* **請求型別**：`multipart/form-data`。

HTTP 請求回傳檔案物件，不代表依賴該檔案的訓練、批處理或索引任務已經完成。單檔案上限512 MB；Batch 輸入另有200 MB上限，微調輸入必須為JSONL。不要手寫 multipart boundary，由用戶端生成。

## 請求參數

| 參數              | 型別     | 必填 | 說明                                                                                        |
| --------------- | ------ | -- | ----------------------------------------------------------------------------------------- |
| `file`          | binary | 是  | 檔案本體，而不是檔名字串。                                                                             |
| `purpose`       | string | 是  | 用途：`assistants`、`batch`、`fine-tune`、`vision`、`user_data` 或 `evals`。                       |
| `expires_after` | object | 否  | 過期策略；`anchor` 固定為 `created_at`，`seconds` 為 3600～2592000。未設定時 batch 檔案預設30天過期，其他檔案保留至手動刪除。 |

## 回傳值

| 欄位               | 型別                   | 說明                                                                  |
| ---------------- | -------------------- | ------------------------------------------------------------------- |
| `id`             | string               | 檔案 ID，供後續請求引用。                                                      |
| `object`         | string               | 固定為 `file`。                                                         |
| `bytes`          | integer / null       | 檔案大小，單位為位元組；尚未取得大小時可能為 null。                                        |
| `created_at`     | integer              | 建立時間，Unix 秒級時間戳。                                                    |
| `filename`       | string               | 上傳時的檔名。                                                             |
| `purpose`        | string               | 檔案用途，例如 `fine-tune`、`user_data`；生成的結果檔案可能使用 `fine-tune-results` 等值。 |
| `expires_at`     | integer / null，選用    | 過期時間，Unix 秒級時間戳；未設定過期策略時可能為空。                                       |
| `status`         | string，已棄用           | 舊狀態欄位：`uploaded`、`processed` 或 `error`。不要用它替代消費端點自身的處理狀態。           |
| `status_details` | string / null，選用，已棄用 | 舊狀態說明；微調資料驗證錯誤應讀取任務的 `error`。                                       |

回應範例（ID 與時間僅用於說明結構）：

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

## 程式碼範例

執行要求：Python 3、Node.js 20 或更新版本、curl、Go 1.20 或更新版本。各語言範例分別儲存為 `.py`、`.cjs`、`.sh`、`.go` 檔案後執行。

範例上傳用於微調的 JSONL 檔案。先設定 `OPENAI_API_KEY` 與 `INPUT_FILE`；訓練集必須符合所選微調方法的資料格式。上傳本身不啟動訓練。

範例為清晰展示 multipart 建立而將檔案載入記憶體；大檔案應改用串流上傳。

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

## 錯誤碼

以下為 OpenAI 官方直連請求的常見 HTTP 錯誤，不是 SimiRouter 的支援狀態。

| HTTP 狀態碼      | 含義                | 處理方式                                       |
| ------------- | ----------------- | ------------------------------------------ |
| `400`         | 參數、檔案用途或資源狀態不符合要求 | 讀取 `error.message` 和 `error.param`，修正後再提交。 |
| `401`         | 金鑰無效或缺失           | 檢查 OpenAI 金鑰及其所屬項目。                        |
| `403`         | 無權存取項目或資源         | 檢查項目、組織和角色權限。                              |
| `404`         | 檔案、任務或模型不存在       | 核對 ID，並使用資源所屬項目的金鑰。                        |
| `429`         | 速率限制或額度不足         | 區分限流與額度錯誤；限流時退避，額度不足時不要重複提交。               |
| `500` / `503` | 伺服器端異常或暫不可用       | 保留請求 ID；寫入請求先核對是否已建立資源，避免重複上傳或重複訓練。        |

非成功回應通常包含 `error.message`、`error.type`、`error.param` 和 `error.code`；欄位可能為空。

## 官方參考

* [OpenAI 上傳檔案](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [OpenAI 錯誤碼](https\://developers.openai.com/api/docs/guides/error-codes)