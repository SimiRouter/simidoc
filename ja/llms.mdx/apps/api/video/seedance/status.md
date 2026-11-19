# Seedance 動画タスクの照会

## API の説明

`GET https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/{id}`。認証は `Authorization: Bearer $ARK_API_KEY`。本ページは Volcengine Ark の公式プロトコルであり、ゲートウェイの汎用動画状態と混同しないでください。

## リクエストパラメータ

| フィールド  | 型      | 必須 | 説明                                        |
| ------ | ------ | -- | ----------------------------------------- |
| id（パス） | string | はい | 作成時に返される cgt- タスク ID。同じアカウント／リージョンに属するもの。 |

JSON 本文はありません。タスク ID は通常 7 日間有効です。新しく作成した一部の Draft タスクには別の有効期間があります。タスク API を永続アーカイブとして使用しないでください。

## 戻り値

| フィールド                                                   | 説明                                                 |
| ------------------------------------------------------- | -------------------------------------------------- |
| `id` / `model`                                          | タスク ID とモデルのバージョン。                                 |
| `status`                                                | queued、running、succeeded、failed、expired、cancelled。 |
| `content.video_url`                                     | 成功後の結果リンク。有効期間は通常 24 時間。速やかに保存。                    |
| `content.last_frame_url`                                | 末尾フレームの返却を要求し、モデルが対応する場合の画像 URL。                   |
| `error.code` / `error.message`                          | 失敗理由。空の場合があります。                                    |
| `created_at` / `updated_at`                             | Unix 秒タイムスタンプ。                                     |
| `usage`                                                 | タスクの使用量。モデルに応じて返されます。                              |
| `duration` / `ratio` / `resolution` / `framespersecond` | 実際の動画仕様。                                           |
| `seed` / `service_tier` / `execution_expires_after`     | 実行設定と再現の手掛かり。                                      |

```json
{"id":"cgt-example","model":"doubao-seedance-2-5-260628","status":"succeeded","content":{"video_url":"https://example.com/video.mp4"},"error":null,"created_at":1780000000,"updated_at":1780000120}
```

succeeded かつ video\_url が空でない場合のみダウンロードします。failed、expired、cancelled の場合は直ちにポーリングを停止してください。例の URL はフィールドの説明用です。

## コード例

次を設定します：`ARK_API_KEY` と `TASK_ID`；`TASK_ID` には、作成 API が返した実際のタスク ID が必要です。Python 3、Node.js 18 以降、Go の例は標準ライブラリのみを使用します。curl の例には、パスを安全にエンコードするために Python 3 も必要です。5～10 秒ごとの照会と、アプリケーション側での総待機時間の上限設定を推奨します。例は 1 回のみ照会します。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import os
    import urllib.error
    import urllib.parse
    import urllib.request

    key = os.environ.get("ARK_API_KEY")
    task_id = os.environ.get("TASK_ID")
    if not key or not task_id or not task_id.strip():
        raise SystemExit("请设置 ARK_API_KEY 和 TASK_ID")
    url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + urllib.parse.quote(task_id, safe="")
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
      const key = process.env.ARK_API_KEY;
      const taskId = process.env.TASK_ID;
      if (!key || !taskId?.trim()) throw new Error("请设置 ARK_API_KEY 和 TASK_ID");
      const url = "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + encodeURIComponent(taskId);
      const response = await fetch(url, {
        method: "GET", headers: { Authorization: `Bearer ${key}` },
        signal: AbortSignal.timeout(180000),
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error.message); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${ARK_API_KEY:?请设置 ARK_API_KEY}"
    : "${TASK_ID:?请设置 TASK_ID 为创建接口返回的真实任务 ID}"
    TASK_PATH=$(python3 - <<'PY_TASK'
    import os, urllib.parse
    task_id = os.environ["TASK_ID"]
    if not task_id.strip():
        raise SystemExit("TASK_ID 不能为空白")
    print(urllib.parse.quote(task_id, safe=""))
    PY_TASK
    )
    curl "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/${TASK_PATH}" \
      --fail-with-body \
      --connect-timeout 15 \
      --max-time 180 \
      --header "Authorization: Bearer $ARK_API_KEY"
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
    	key, taskID := os.Getenv("ARK_API_KEY"), os.Getenv("TASK_ID")
    	if key == "" || strings.TrimSpace(taskID) == "" {
    		log.Fatal("请设置 ARK_API_KEY 和 TASK_ID")
    	}
    	endpoint := "https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/" + url.PathEscape(taskID)
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

| HTTP ステータス            | 意味と対処                                               |
| --------------------- | --------------------------------------------------- |
| 400 / 422             | リクエスト項目、ファイル形式、モデルパラメータが不正。修正して再送。                  |
| 401                   | API Key がない、無効、または期限切れ。                             |
| 403                   | 現在のプロジェクトまたはモデルへの権限がありません。                          |
| 404                   | モデル、ルート、タスクが存在しません。アドレスと所属を確認。                      |
| 413 / 415             | アップロード過大、または未対応メディア型。                               |
| 429                   | レートまたは割り当て制限。残高不足とバックオフ可能な制限を区別。                    |
| 500 / 502 / 503 / 504 | サービスまたは上流異常。ID を保持し、作成がタイムアウトしたら受理済みか確認して重複生成を防ぎます。 |

Volcengine のエラーオブジェクトは `error.code`、`error.message` を使用し、リクエスト ID も保持します。照会の HTTP が成功しても、タスクの status と error を確認する必要があります。

## 公式資料

[Volcengine Ark タスク照会](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)。