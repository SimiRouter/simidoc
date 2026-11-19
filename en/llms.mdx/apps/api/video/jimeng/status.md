# Query Jimeng video result (integration pending)

## Endpoint overview

`POST https://visual.volcengineapi.com/?Action=CVSync2AsyncGetResult&Version=2022-08-31`, with a JSON body. Official authentication requires AK/SK V4 signing with Region=`cn-north-1`, Service=`cv`, not ordinary Bearer authentication.

This page references Jimeng 3.0 Pro, officially marked as being retired. It applies only where the account remains authorized and the service remains open; it is not a SimiRouter `/jimeng/` public mapping. The signing implementation below uses no proxy and omits no required signatures.

## Request parameters

| Field           | Type   | Required | Description                                                                           |
| --------------- | ------ | -------- | ------------------------------------------------------------------------------------- |
| Action (query)  | string | Yes      | CVSync2AsyncGetResult.                                                                |
| Version (query) | string | Yes      | 2022-08-31.                                                                           |
| req\_key        | string | Yes      | This product requires jimeng\_ti2v\_v30\_pro, not jimeng\_video\_generation.          |
| task\_id        | string | Yes      | The task ID returned after successful submission.                                     |
| req\_json       | string | No       | A JSON-serialized string such as aigc\_meta configuration, not an unspecified object. |

Signed headers include Content-Type, Host, X-Date (UTC), and X-Content-Sha256. The actual body and query must exactly match what was signed; changing Action requires a new signature.

## Response

| Field                   | Description                                                                                                                 |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `code` / `message`      | Business success is 10000; do not check HTTP status alone.                                                                  |
| `request_id`            | Server tracking ID.                                                                                                         |
| `data.status`           | in\_queue means queued; generating means running; done means ended; not\_found means absent/expired; expired means expired. |
| `data.video_url`        | The successful video URL, valid for about one hour; save promptly.                                                          |
| `data.aigc_meta_tagged` | Implicit-labeling result.                                                                                                   |

```json
{"code":10000,"message":"Success","request_id":"request_example","data":{"status":"done","video_url":"https://example.com/video.mp4","aigc_meta_tagged":true}}
```

Tasks remain available for about 12 hours. Download only when code=10000, status=done, and video\_url is nonempty. done without output is not success; stop polling for not\_found / expired.

## Code examples

Set `VOLC_ACCESS_KEY`, `VOLC_SECRET_KEY` and `TASK_ID`; use the actual task ID returned by creation. Python 3, Node.js 18+, and Go use standard libraries; curl additionally requires Python 3 for safe JSON encoding and local signing. Never put AK/SK in code or logs.

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

## Errors

Check HTTP first, then business code; HTTP 200 does not remove the need for business-result checks.

| Business code               | Meaning and action                                                                                             |
| --------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 10000                       | Request succeeded; polling must also inspect data.status and video\_url.                                       |
| 50411 / 50412 / 50413       | Image, text, sensitive-word, or copyright moderation failed; revise the input rather than repeat it unchanged. |
| 50511 / 50516               | Output image/video moderation failed.                                                                          |
| Signature error / 401 / 403 | Check AK/SK, UTC time, region, Service, body hash, and permissions.                                            |
| 429 / 5xx                   | Rate limit or service error; do not blindly resubmit after creation timeouts and risk duplicate jobs.          |

Retain request\_id, code, and message. When code is not 10000, data may be null; do not access data.status.

## Official reference

[Jimeng official API](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh), [Volcengine official V4 signing](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py).