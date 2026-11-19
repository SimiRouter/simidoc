# Kling 画像から動画生成タスクの照会

## API の説明

`GET https://api-singapore.klingai.com/tasks`、認証は `Authorization: Bearer $KLING_API_KEY`。Kling 新版のテキスト／画像から動画生成は共通のタスク照会を使用し、`/v1/videos/.../{id}` は追加しません。

## リクエストパラメータ

| フィールド                      | 型      | 必須     | 説明                                               |
| -------------------------- | ------ | ------ | ------------------------------------------------ |
| task\_ids（query）           | string | どちらか一方 | システムタスク ID。複数の場合はカンマ区切り。                         |
| external\_task\_ids（query） | string | どちらか一方 | 作成時の options.external\_task\_id の値。複数の場合はカンマ区切り。 |

2 種類の照会パラメーターは併用できません。JSON 本文はありません。設定する `TASK_ID` には、作成 API が返した `data.id` を指定します。

## 戻り値

| フィールド                             | 説明                                                         |
| --------------------------------- | ---------------------------------------------------------- |
| `code` / `message` / `request_id` | 業務状態と追跡識別子。code=0 の場合のみ data を解析。                          |
| `data[]`                          | 照会条件に一致したタスクの配列。                                           |
| `data[].id` / `external_id`       | システム ID とカスタム ID。                                          |
| `data[].status`                   | submitted、processing、succeeded、failed。                     |
| `data[].message`                  | 失敗理由。                                                      |
| `data[].outputs[]`                | type で video/image/audio などを区別します。旧版 task\_result ではありません。 |
| `outputs[].url` / `watermark_url` | video 結果の URL と、利用可能な透かし付きバージョン。                           |
| `outputs[].duration`              | 出力動画の秒数。                                                   |
| `create_time` / `update_time`     | Unix ミリ秒タイムスタンプ。                                           |
| `billing[]`                       | タスクが返す課金単位などの情報。                                           |

```json
{"code":0,"message":"Success","request_id":"request_example","data":[{"id":"task_example","status":"succeeded","outputs":[{"type":"video","url":"https://example.com/video.mp4","duration":"5"}]}]}
```

status=succeeded で、type=video の有効な出力が存在する場合のみダウンロードします。リンクにはホットリンク防止や保存期限の制限があるため、速やかに保存してください。失敗時はポーリングを停止します。HTTP が成功でも data=\[] の場合は、ID とアカウントを確認し、生成成功として扱わないでください。

## コード例

次を設定します：`KLING_API_KEY` と `TASK_ID`；`TASK_ID` には、作成 API が返した実際のタスク ID が必要です。Python 3、Node.js 18 以降、Go の例は標準ライブラリのみを使用します。curl は `--data-urlencode` で照会パラメーターをエンコードします。5～10 秒ごとの照会と、アプリケーション側での総待機時間の上限設定を推奨します。例は 1 回のみ照会します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    key = os.environ.get("KLING_API_KEY")
    task_id = os.environ.get("TASK_ID")
    if not key or not task_id or not task_id.strip():
        raise SystemExit("请设置 KLING_API_KEY 和 TASK_ID")
    url = "https://api-singapore.klingai.com/tasks?" + urllib.parse.urlencode({"task_ids": task_id})
    request = urllib.request.Request(url, headers={"Authorization": "Bearer " + key}, method="GET")
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            print(json.dumps(json.load(response), ensure_ascii=False, indent=2))
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const key = process.env.KLING_API_KEY;
      const taskId = process.env.TASK_ID;
      if (!key || !taskId?.trim()) throw new Error("请设置 KLING_API_KEY 和 TASK_ID");
      const url = new URL("https://api-singapore.klingai.com/tasks");
      url.searchParams.set("task_ids", taskId);
      const response = await fetch(url, {
        method: "GET", headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(180000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${KLING_API_KEY:?请设置 KLING_API_KEY}"
    : "${TASK_ID:?请设置 TASK_ID 为创建接口返回的真实任务 ID}"
    [[ "$TASK_ID" =~ [^[:space:]] ]] || { printf '%s\n' 'TASK_ID 不能为空白' >&2; exit 1; }
    curl "https://api-singapore.klingai.com/tasks" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      --get \
      --data-urlencode "task_ids=$TASK_ID" \
      --header "Authorization: Bearer $KLING_API_KEY"
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
    	"strings"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		log.Fatal(err)
    	}
    }
    func main() {
    	key, taskID := os.Getenv("KLING_API_KEY"), os.Getenv("TASK_ID")
    	if key == "" || strings.TrimSpace(taskID) == "" {
    		log.Fatal("请设置 KLING_API_KEY 和 TASK_ID")
    	}
    	query := url.Values{"task_ids": []string{taskID}}
    	endpoint := "https://api-singapore.klingai.com/tasks?" + query.Encode()
    	req, err := http.NewRequest("GET", endpoint, nil)
    	check(err)
    	req.Header.Set("Authorization", "Bearer "+key)
    	client := &http.Client{Timeout: 180 * time.Second}
    	response, err := client.Do(req)
    	check(err)
    	defer response.Body.Close()
    	data, err := io.ReadAll(response.Body)
    	check(err)
    	if response.StatusCode < 200 || response.StatusCode >= 300 {
    		log.Fatalf("HTTP %d: %s", response.StatusCode, data)
    	}
    	fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## エラーコード

| HTTP / 業務コード                     | 説明                                                 |
| -------------------------------- | -------------------------------------------------- |
| 200 / 0                          | リクエスト成功。生成が完了したかはタスクの status で判断。                  |
| 400 / 1201                       | パラメーターエラー。message を確認。                             |
| 404 / 1202、1203                  | メソッドが正しくないか、モデル／リソースが存在しません。                       |
| 401                              | API Key または旧版 JWT が無効です。                           |
| 400 / 1300、1301                  | プラットフォームポリシーまたはコンテンツの安全性制限。内容を修正し、確認せず繰り返さないでください。 |
| 429 / 1302、1303、1304             | レート、同時実行数、IP ポリシーの制限。                              |
| 500 / 5000；503 / 5001；504 / 5002 | サービスエラーまたはタイムアウト。request\_id を保存。                  |

HTTP 200 は業務上の成功を意味しません。まず code=0 を確認してから data を読み取ってください。

## 公式資料

[Kling 公式タスク照会](https\://kling.ai/document-api/apiReference/model/imageToVideo)。