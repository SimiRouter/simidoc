# ファイル内容の取得

読み取り可能なアップロード・結果ファイルの元データを OpenAI から取得します。

**SimiRouter は現在この API に未対応です。以下は OpenAI 公式リファレンスで、接続先は `api.openai.com`。OpenAI プロジェクトのキーが必要で、SimiRouter Key は使用できません。**

## API の説明

* **メソッド**：`GET`
* **API アドレス**：`/v1/files/{file_id}/content`
* **認証**：`Authorization: Bearer $OPENAI_API_KEY`
* **リクエスト型**：本文なし。

ダウンロード完了を待つ通常 HTTP で、モデル SSE や非同期タスクではありません。キーとリソース所属プロジェクトを一致させます。全用途のファイルを取得できるわけではありません。

## リクエストパラメータ

| パラメータ     | 型         | 必須 | 説明                     |
| --------- | --------- | -- | ---------------------- |
| `file_id` | string、パス | はい | OpenAI プロジェクトのファイル ID。 |

## 戻り値

成功応答はファイルバイト列で、`data` を含む JSON ではありません。実形式の拡張子で保存し、バイナリを UTF-8 としてデコードしないでください。失敗応答は JSON の場合があります。

| 内容         | 説明                                                  |
| ---------- | --------------------------------------------------- |
| HTTP ステータス | 成功時は `200`。                                         |
| 応答本文       | 元のファイルバイト列。JSONL 結果は行単位で解析。                         |
| ファイル名      | ダウンロード前に[ファイル情報の取得](/simidoc/ja/apps/api/pending/files/retrieve)で `filename` を確認します。 |

## コード例

実行環境：Python 3、Node.js 20+、curl、Go 1.20+。各言語の例をそれぞれ `.py`、`.cjs`、`.sh`、`.go` ファイルとして保存して実行します。

次を設定します：`OPENAI_API_KEY` と `OPENAI_FILE_ID`。任意で `OUTPUT_FILE` に出力先を指定でき、既定は `downloaded-file.bin`。Python、Node.js、Go は同名出力を上書きするため事前確認が必要です。curl は既存出力を上書きしません。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request
    from pathlib import Path

    def required(name):
        value = os.environ.get(name)
        if not value:
            raise SystemExit(f"请设置 {name}")
        return value

    key = required("OPENAI_API_KEY")
    file_id = required("OPENAI_FILE_ID")
    file_id_encoded = urllib.parse.quote(file_id, safe="")
    request = urllib.request.Request(
        f"https://api.openai.com/v1/files/{file_id_encoded}/content",
        method="GET",
        data=None,
        headers={"Authorization": "Bearer " + key},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = response.read()
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    output = Path(os.environ.get("OUTPUT_FILE", "downloaded-file.bin"))
    output.write_bytes(result)
    print(output)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { writeFile } = require("node:fs/promises");
    function required(name) {
      const value = process.env[name];
      if (!value) throw new Error(`请设置 ${name}`);
      return value;
    }
    async function main() {
      const key = required("OPENAI_API_KEY");
      const file_id = required("OPENAI_FILE_ID");
      const fileId = encodeURIComponent(file_id);
      const response = await fetch(`https://api.openai.com/v1/files/${fileId}/content`, {
        method: "GET",
        headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(120000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const output = process.env.OUTPUT_FILE || "downloaded-file.bin";
      await writeFile(output, Buffer.from(await response.arrayBuffer()));
      console.log(output);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${OPENAI_API_KEY:?请设置 OPENAI_API_KEY}"
    : "${OPENAI_FILE_ID:?请设置 OPENAI_FILE_ID}"
    [[ "$OPENAI_FILE_ID" =~ ^[A-Za-z0-9_:-]+$ ]] || { printf '%s\n' '资源 ID 格式错误' >&2; exit 1; }
    download=$(mktemp)
    trap 'rm -f "$download"' EXIT
    curl "https://api.openai.com/v1/files/${OPENAI_FILE_ID}/content" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 120 \
      --request GET \
      --header "Authorization: Bearer $OPENAI_API_KEY" \
      --output "$download"
    # 仅在 HTTP 成功后发布文件；不覆盖已有输出。
    ln "$download" "${OUTPUT_FILE:-downloaded-file.bin}"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"fmt"
    	"io"
    	"log"
    	"net/http"
    	"net/url"
    	"os"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func required(name string) string {
    	value := os.Getenv(name)
    	if value == "" {
    		log.Fatal("请设置 " + name)
    	}
    	return value
    }
    func main() {
    	key := required("OPENAI_API_KEY")
    	file_id := required("OPENAI_FILE_ID")
    	target := fmt.Sprintf("https://api.openai.com/v1/files/%s/content", url.PathEscape(file_id))
    	req, err := http.NewRequest("GET", target, nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 120 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	result, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, result)
    	}
    	output := os.Getenv("OUTPUT_FILE")
    	if output == "" {
    		output = "downloaded-file.bin"
    	}
    	check(os.WriteFile(output, result, 0600))
    	fmt.Println(output)
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

* [OpenAI ファイル内容取得](https\://developers.openai.com/api/reference/resources/files/methods/content)
* [OpenAI エラーコード](https\://developers.openai.com/api/docs/guides/error-codes)