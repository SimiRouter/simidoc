# Jimeng 動画の結果照会（接続予定）

## API の説明

`POST https://visual.volcengineapi.com/?Action=CVSync2AsyncGetResult&Version=2022-08-31`。本文は JSON。公式 API は AK/SK V4 署名が必要で、Region=`cn-north-1`、Service=`cv` です。通常の Bearer は使用できません。

本ページは Jimeng 3.0 Pro のメーカー参考情報です。公式ではこのバージョンは「提供終了手続き中」とされています。アカウントに権限があり、サービスが引き続き提供される場合のみ利用できます。SimiRouter の `/jimeng/` の公開マッピングではありません。以下の署名実装はプロキシを呼び出さず、必須の署名を省略しません。

## リクエストパラメータ

| フィールド          | 型      | 必須  | 説明                                                                   |
| -------------- | ------ | --- | -------------------------------------------------------------------- |
| Action（query）  | string | はい  | CVSync2AsyncGetResult。                                               |
| Version（query） | string | はい  | 2022-08-31。                                                          |
| req\_key       | string | はい  | 本製品では jimeng\_ti2v\_v30\_pro 固定です。jimeng\_video\_generation ではありません。 |
| task\_id       | string | はい  | 送信成功時に返されたタスク ID。                                                    |
| req\_json      | string | いいえ | aigc\_meta 設定などの JSON シリアライズ文字列。仕様にないオブジェクト形式では送信できません。              |

署名対象の headers は Content-Type、Host、X-Date（UTC）、X-Content-Sha256 を含みます。実際に送信する本文と query は署名時の内容と完全に一致させてください。Action を変更する場合は再署名が必要です。

## 戻り値

| フィールド                   | 説明                                                                          |
| ----------------------- | --------------------------------------------------------------------------- |
| `code` / `message`      | 業務上の成功コードは 10000。HTTP ステータスだけを確認しないでください。                                   |
| `request_id`            | サーバー側の追跡 ID。                                                                |
| `data.status`           | in\_queue は待機中、generating は生成中、done は終了、not\_found は未検出／期限切れ、expired は期限切れ。 |
| `data.video_url`        | 成功した動画のリンク。有効期間は約 1 時間。速やかに保存。                                              |
| `data.aigc_meta_tagged` | 暗黙的な識別情報の付与結果。                                                              |

```json
{"code":10000,"message":"Success","request_id":"request_example","data":{"status":"done","video_url":"https://example.com/video.mp4","aigc_meta_tagged":true}}
```

タスクの有効期間は約 12 時間です。code=10000、status=done、video\_url が空でない場合のみダウンロードしてください。done でも出力がない場合は成功として扱わず、not\_found / expired の場合はポーリングを停止します。

## コード例

次を設定します：`VOLC_ACCESS_KEY`、`VOLC_SECRET_KEY` と `TASK_ID`。タスク ID は作成 API が返した実際の値を使用します。Python 3、Node.js 18 以降、Go は標準ライブラリを使用します。curl には、JSON の安全なエンコードとローカルでの署名生成のために Python 3 も必要です。AK/SK をコードやログに記載しないでください。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import datetime
    import hashlib
    import hmac
    import json
    import os
    import urllib.error
    import urllib.request

    for name in ("VOLC_ACCESS_KEY", "VOLC_SECRET_KEY", "TASK_ID"):
        if not os.environ.get(name) or not os.environ[name].strip():
            raise SystemExit("请设置 " + name)
    body = {'req_key': 'jimeng_ti2v_v30_pro', 'task_id': os.environ['TASK_ID']}
    payload = json.dumps(body, ensure_ascii=False, separators=(",", ":")).encode()
    query = "Action=CVSync2AsyncGetResult&Version=2022-08-31"
    host = "visual.volcengineapi.com"
    xdate = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    date = xdate[:8]
    sha = lambda value: hashlib.sha256(value).hexdigest()
    headers = {"content-type":"application/json", "host":host,
               "x-content-sha256":sha(payload), "x-date":xdate}
    signed_headers = ";".join(sorted(headers))
    canonical_headers = "".join(key + ":" + headers[key] + "\n" for key in sorted(headers))
    canonical = "\n".join(["POST", "/", query, canonical_headers, signed_headers, sha(payload)])
    scope = date + "/cn-north-1/cv/request"
    to_sign = "\n".join(["HMAC-SHA256", xdate, scope, sha(canonical.encode())])
    key = os.environ["VOLC_SECRET_KEY"].encode()
    for item in [date, "cn-north-1", "cv", "request"]:
        key = hmac.new(key, item.encode(), hashlib.sha256).digest()
    signature = hmac.new(key, to_sign.encode(), hashlib.sha256).hexdigest()
    headers["Authorization"] = ("HMAC-SHA256 Credential=" + os.environ["VOLC_ACCESS_KEY"] + "/" + scope
        + ", SignedHeaders=" + signed_headers + ", Signature=" + signature)
    request = urllib.request.Request("https://" + host + "/?" + query, method="POST", headers=headers, data=payload)
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode('utf-8', errors='replace')}")
    if result.get("code") != 10000:
        raise RuntimeError(json.dumps(result, ensure_ascii=False))
    print(json.dumps(result, ensure_ascii=False))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { createHash, createHmac } = require("node:crypto");
    async function main() {
      for (const name of ["VOLC_ACCESS_KEY", "VOLC_SECRET_KEY", "TASK_ID"]) {
        if (!process.env[name]?.trim()) throw new Error("请设置 " + name);
      }
      const payload = JSON.stringify({
      "req_key": "jimeng_ti2v_v30_pro",
      "task_id": process.env.TASK_ID
    });
      const query = "Action=CVSync2AsyncGetResult&Version=2022-08-31";
      const host = "visual.volcengineapi.com";
      const xdate = new Date().toISOString().replace(/[:-]|\.\d{3}/g, "");
      const date = xdate.slice(0, 8);
      const sha = value => createHash("sha256").update(value).digest("hex");
      const headers = {"content-type":"application/json", host,
        "x-content-sha256":sha(payload), "x-date":xdate};
      const names = Object.keys(headers).sort();
      const signed = names.join(";");
      const canonicalHeaders = names.map(key => key + ":" + headers[key] + "\n").join("");
      const canonical = ["POST", "/", query, canonicalHeaders, signed, sha(payload)].join("\n");
      const scope = date + "/cn-north-1/cv/request";
      const toSign = ["HMAC-SHA256", xdate, scope, sha(canonical)].join("\n");
      let key = Buffer.from(process.env.VOLC_SECRET_KEY);
      for (const item of [date, "cn-north-1", "cv", "request"]) key = createHmac("sha256", key).update(item).digest();
      const signature = createHmac("sha256", key).update(toSign).digest("hex");
      headers.Authorization = `HMAC-SHA256 Credential=${process.env.VOLC_ACCESS_KEY}/${scope}, SignedHeaders=${signed}, Signature=${signature}`;
      const res = await fetch("https://" + host + "/?" + query, {
        method:"POST", headers, body:payload, signal:AbortSignal.timeout(180000)});
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`);
      const result = await res.json();
      if (result.code !== 10000) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -euo pipefail
    : "${VOLC_ACCESS_KEY:?请设置 VOLC_ACCESS_KEY}"
    : "${VOLC_SECRET_KEY:?请设置 VOLC_SECRET_KEY}"
    : "${TASK_ID:?请设置 TASK_ID}"
    work=$(mktemp -d)
    trap 'rm -rf "$work"' EXIT
    export SIGNED_REQUEST_DIR="$work"
    python3 - <<'PY_SIGN'
    import datetime
    import hashlib
    import hmac
    import json
    import os

    for name in ("VOLC_ACCESS_KEY", "VOLC_SECRET_KEY", "TASK_ID"):
        if not os.environ.get(name) or not os.environ[name].strip():
            raise SystemExit("请设置 " + name)
    body = {'req_key': 'jimeng_ti2v_v30_pro', 'task_id': os.environ['TASK_ID']}
    payload = json.dumps(body, ensure_ascii=False, separators=(",", ":")).encode()
    query = "Action=CVSync2AsyncGetResult&Version=2022-08-31"
    host = "visual.volcengineapi.com"
    xdate = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    date = xdate[:8]
    sha = lambda value: hashlib.sha256(value).hexdigest()
    headers = {"content-type":"application/json", "host":host,
               "x-content-sha256":sha(payload), "x-date":xdate}
    signed_headers = ";".join(sorted(headers))
    canonical_headers = "".join(key + ":" + headers[key] + "\n" for key in sorted(headers))
    canonical = "\n".join(["POST", "/", query, canonical_headers, signed_headers, sha(payload)])
    scope = date + "/cn-north-1/cv/request"
    to_sign = "\n".join(["HMAC-SHA256", xdate, scope, sha(canonical.encode())])
    key = os.environ["VOLC_SECRET_KEY"].encode()
    for item in [date, "cn-north-1", "cv", "request"]:
        key = hmac.new(key, item.encode(), hashlib.sha256).digest()
    signature = hmac.new(key, to_sign.encode(), hashlib.sha256).hexdigest()
    headers["Authorization"] = ("HMAC-SHA256 Credential=" + os.environ["VOLC_ACCESS_KEY"] + "/" + scope
        + ", SignedHeaders=" + signed_headers + ", Signature=" + signature)

    from pathlib import Path
    folder = Path(os.environ["SIGNED_REQUEST_DIR"])
    (folder / "body.json").write_bytes(payload)
    (folder / "headers.txt").write_text("\n".join(k + ": " + v for k, v in headers.items()) + "\n")
    PY_SIGN
    curl 'https://visual.volcengineapi.com/?Action=CVSync2AsyncGetResult&Version=2022-08-31' \
      --fail-with-body \
      --max-time 180 \
      --header "@$work/headers.txt" \
      --data-binary "@$work/body.json"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
    	"bytes"
    	"crypto/hmac"
    	"crypto/sha256"
    	"encoding/hex"
    	"encoding/json"
    	"fmt"
    	"io"
    	"net/http"
    	"os"
    	"sort"
    	"strings"
    	"time"
    )

    func check(err error) {
    	if err != nil {
    		panic(err)
    	}
    }
    func sha(value []byte) string { sum := sha256.Sum256(value); return hex.EncodeToString(sum[:]) }
    func hm(key []byte, value string) []byte {
    	h := hmac.New(sha256.New, key)
    	h.Write([]byte(value))
    	return h.Sum(nil)
    }
    func main() {
    	for _, name := range []string{"VOLC_ACCESS_KEY", "VOLC_SECRET_KEY", "TASK_ID"} {
    		if strings.TrimSpace(os.Getenv(name)) == "" {
    			panic("请设置 " + name)
    		}
    	}
    	payload, err := json.Marshal(map[string]string{
    		"req_key": "jimeng_ti2v_v30_pro", "task_id": os.Getenv("TASK_ID"),
    	})
    	check(err)
    	query := "Action=CVSync2AsyncGetResult&Version=2022-08-31"
    	host := "visual.volcengineapi.com"
    	xdate := time.Now().UTC().Format("20060102T150405Z")
    	date := xdate[:8]
    	headers := map[string]string{"content-type": "application/json", "host": host,
    		"x-content-sha256": sha(payload), "x-date": xdate}
    	names := []string{}
    	for name := range headers {
    		names = append(names, name)
    	}
    	sort.Strings(names)
    	canonicalHeaders := ""
    	for _, name := range names {
    		canonicalHeaders += name + ":" + headers[name] + "\n"
    	}
    	signed := strings.Join(names, ";")
    	canonical := strings.Join([]string{"POST", "/", query, canonicalHeaders, signed, sha(payload)}, "\n")
    	scope := date + "/cn-north-1/cv/request"
    	toSign := strings.Join([]string{"HMAC-SHA256", xdate, scope, sha([]byte(canonical))}, "\n")
    	key := []byte(os.Getenv("VOLC_SECRET_KEY"))
    	for _, item := range []string{date, "cn-north-1", "cv", "request"} {
    		key = hm(key, item)
    	}
    	signature := hex.EncodeToString(hm(key, toSign))
    	headers["Authorization"] = "HMAC-SHA256 Credential=" + os.Getenv("VOLC_ACCESS_KEY") + "/" + scope + ", SignedHeaders=" + signed + ", Signature=" + signature
    	req, err := http.NewRequest("POST", "https://"+host+"/?"+query, bytes.NewReader(payload))
    	check(err)
    	req.Host = host
    	for name, value := range headers {
    		if name != "host" {
    			req.Header.Set(name, value)
    		}
    	}
    	res, err := (&http.Client{Timeout: 180 * time.Second}).Do(req)
    	check(err)
    	defer res.Body.Close()
    	data, err := io.ReadAll(res.Body)
    	check(err)
    	if res.StatusCode < 200 || res.StatusCode >= 300 {
    		panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data))
    	}
    	var result struct {
    		Code int `json:"code"`
    	}
    	check(json.Unmarshal(data, &result))
    	if result.Code != 10000 {
    		panic(string(data))
    	}
    	fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## エラーコード

まず HTTP、次に業務 code を確認します。HTTP が 200 でも業務上の判定を省略できません。

| 業務コード                 | 意味と対処                                                       |
| --------------------- | ----------------------------------------------------------- |
| 10000                 | API の処理成功。照会では data.status と video\_url も確認。                |
| 50411 / 50412 / 50413 | 画像、テキスト、センシティブワード／著作権に関する審査に不合格。入力を修正し、そのまま繰り返さないでください。     |
| 50511 / 50516         | 出力画像／動画の審査に不合格。                                             |
| 署名エラー / 401 / 403     | AK/SK、UTC 時刻、リージョン、Service、リクエスト本体のハッシュ、権限を確認。              |
| 429 / 5xx             | レート制限またはサービスエラー。作成がタイムアウトした場合、重複タスクを避けるため、確認せずに再送信しないでください。 |

request\_id、code、message を保存してください。code が 10000 以外の場合、data は null の可能性があるため、data.status に続けてアクセスできません。

## 公式資料

[Jimeng 公式 API](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh)、[Volcengine 公式 V4 署名](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py)。