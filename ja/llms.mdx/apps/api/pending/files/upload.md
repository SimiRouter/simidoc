# ファイルのアップロード

ローカルファイルをアップロードし、他の OpenAI API で参照する ID を取得します。

**SimiRouter は現在この API に未対応です。以下は OpenAI 公式リファレンスで、接続先は `api.openai.com`。OpenAI プロジェクトのキーが必要で、SimiRouter Key は使用できません。**

## API の説明

* **メソッド**：`POST`
* **API アドレス**：`/v1/files`
* **認証**：`Authorization: Bearer $OPENAI_API_KEY`
* **リクエスト型**：`multipart/form-data`。

HTTP 応答はファイルオブジェクトで、学習、バッチ、索引完了ではありません。単一ファイル512 MB、Batch 入力200 MB、学習は JSONL。multipart boundary は手書きせずクライアントに生成させます。

## リクエストパラメータ

| パラメータ           | 型      | 必須  | 説明                                                                                     |
| --------------- | ------ | --- | -------------------------------------------------------------------------------------- |
| `file`          | binary | はい  | ファイル名文字列ではなくファイル本体。                                                                    |
| `purpose`       | string | はい  | 用途：`assistants`、`batch`、`fine-tune`、`vision`、`user_data` または `evals`。                  |
| `expires_after` | object | いいえ | 有効期限方針。`anchor` は `created_at`，`seconds` 固定で、値は3600～2592000。省略時 batch は30日、他は手動削除まで保持。 |

## 戻り値

| フィールド            | 型                    | 説明                                                                              |
| ---------------- | -------------------- | ------------------------------------------------------------------------------- |
| `id`             | string               | 後続要求で参照するファイル ID。                                                               |
| `object`         | string               | 固定値は `file`。                                                                    |
| `bytes`          | integer / null       | ファイルサイズ（バイト）。未取得時は null の場合があります。                                               |
| `created_at`     | integer              | 作成時刻。Unix 秒。                                                                    |
| `filename`       | string               | アップロード時のファイル名。                                                                  |
| `purpose`        | string               | ファイル用途。例：`fine-tune`、`user_data`。生成結果ファイルでは `fine-tune-results` などを使用する場合があります。 |
| `expires_at`     | integer / null、任意    | 有効期限。Unix 秒。未設定時は空の場合があります。                                                     |
| `status`         | string、非推奨           | 旧状態フィールド：`uploaded`、`processed` または `error`。利用先 API 自身の処理状態の代わりにしないでください。       |
| `status_details` | string / null、任意、非推奨 | 旧状態の説明。学習データ検証エラーはタスクの `error` を確認します。                                          |

応答例（ID・時刻は構造説明用）：

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

## コード例

実行環境：Python 3、Node.js 20+、curl、Go 1.20+。各言語の例をそれぞれ `.py`、`.cjs`、`.sh`、`.go` ファイルとして保存して実行します。

例は学習用 JSONL をアップロードします。先に `OPENAI_API_KEY` と `INPUT_FILE` を設定し、選択した学習方式に合うデータを使用します。アップロード自体では学習は開始しません。

multipart を明示するためファイル全体をメモリーに読みます。大ファイルはストリーミングアップロードへ変更してください。

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

## エラーコード

以下は OpenAI 公式直接接続の一般的な HTTP エラーで、SimiRouter の対応状況ではありません。

| HTTP ステータスコード | 意味                      | 対処                                            |
| ------------- | ----------------------- | --------------------------------------------- |
| `400`         | パラメータ、ファイル用途、資源状態が要件不適合 | 次を読み取り、`error.message` と `error.param`修正後に再送。 |
| `401`         | キーがない、または無効             | OpenAI キーと所属プロジェクトを確認。                        |
| `403`         | プロジェクト・資源へのアクセス不可       | プロジェクト、組織、ロール権限を確認。                           |
| `404`         | ファイル、タスク、モデルが存在しない      | ID を確認し、資源所属プロジェクトのキーを使用。                     |
| `429`         | レート制限または残高不足            | レートと残高を区別。前者はバックオフ、後者は再送しません。                 |
| `500` / `503` | サーバー異常・一時利用不可           | ID を保持し、書き込みは作成済みか確認して重複アップロード・学習を防ぎます。       |

失敗応答には通常 `error.message`、`error.type`、`error.param` と `error.code` が含まれます。フィールドが空の場合もあります。

## 公式資料

* [OpenAI ファイルアップロード](https\://developers.openai.com/api/reference/resources/files/methods/create)
* [OpenAI エラーコード](https\://developers.openai.com/api/docs/guides/error-codes)