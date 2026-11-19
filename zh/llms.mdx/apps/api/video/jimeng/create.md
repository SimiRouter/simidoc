# 提交即梦视频任务（待接入）

## 接口说明

`POST https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31`，JSON 正文。官方需要 AK/SK V4 签名，Region=`cn-north-1`、Service=`cv`，不可使用普通 Bearer。

本页为即梦 3.0 Pro 的厂商参考，官方标记该版本“下线中”。仅账户已获授权且服务仍开放时适用；不是 SimiRouter `/jimeng/` 公网映射。以下签名实现不调用任何代理，不省略必需签名。

## 请求参数

| 字段                   | 类型        | 必填 | 说明                                                         |
| -------------------- | --------- | -- | ---------------------------------------------------------- |
| Action（query）        | string    | 是  | CVSync2AsyncSubmitTask。                                    |
| Version（query）       | string    | 是  | 2022-08-31。                                                |
| req\_key             | string    | 是  | 本产品固定 jimeng\_ti2v\_v30\_pro，不是 jimeng\_video\_generation。 |
| prompt               | string    | 条件 | 文生视频必填，图生可选；建议 400 字以内，不超过 800 字。                          |
| image\_urls          | string\[] | 否  | 首帧图片 URL，只支持一张；与 binary\_data\_base64 二选一。                 |
| binary\_data\_base64 | string\[] | 否  | JPEG/PNG 图片 Base64，一张，最大 4.7MB；像素等限制见官方。                   |
| seed                 | integer   | 否  | 默认 -1 随机。                                                  |
| frames               | integer   | 否  | 121（5秒）或 241（10秒），默认 121。                                  |
| aspect\_ratio        | string    | 否  | 16\:9、4\:3、1\:1、3\:4、9\:16、21\:9，仅文生视频生效。                  |

签名 headers 包含 Content-Type、Host、X-Date（UTC）与 X-Content-Sha256。实际发送的正文、query 必须与签名完全相同；更换 Action 时必须重新签名。

## 返回值

| 字段                 | 说明                           |
| ------------------ | ---------------------------- |
| `code` / `message` | 业务成功为 10000；不要只检查 HTTP 状态。   |
| `request_id`       | 服务端追踪 ID。                    |
| `data.task_id`     | 后续查询的任务 ID，仅 code=10000 时存在。 |

```json
{"code":10000,"message":"Success","request_id":"request_example","data":{"task_id":"7392616336519610409"}}
```

提交成功只代表受理，使用 [查询结果](/simidoc/zh/apps/api/video/jimeng/status) 获取状态；不应在本页等待同步返回 video\_url。

## 代码调用

Python 示例需 `python3 -m pip install requests`；Node.js 示例使用 Node.js 18 或更新版本的内置 fetch；Go 使用标准库。

设置 `VOLC_ACCESS_KEY`、`VOLC_SECRET_KEY`。cURL 示例先在本地生成签名再发送；不要把 AK/SK 写在代码或日志中。

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import datetime
    import hashlib
    import hmac
    import json
    import os
    import requests

    body = {'req_key': 'jimeng_ti2v_v30_pro', 'prompt': '一艘帆船缓缓驶过夕阳下的海面，平稳运镜。', 'frames': 121, 'aspect_ratio': '16:9', 'seed': -1}
    payload = json.dumps(body, ensure_ascii=False, separators=(",", ":")).encode()
    query = "Action=CVSync2AsyncSubmitTask&Version=2022-08-31"
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
    response = requests.post("https://" + host + "/?" + query, headers=headers, data=payload, timeout=180)
    response.raise_for_status()
    result = response.json()
    if result.get("code") != 10000:
        raise RuntimeError(json.dumps(result, ensure_ascii=False))
    print(json.dumps(result, ensure_ascii=False))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { createHash, createHmac } = require("node:crypto");
    async function main() {
      const payload = JSON.stringify({
      "req_key": "jimeng_ti2v_v30_pro",
      "prompt": "一艘帆船缓缓驶过夕阳下的海面，平稳运镜。",
      "frames": 121,
      "aspect_ratio": "16:9",
      "seed": -1
    });
      const query = "Action=CVSync2AsyncSubmitTask&Version=2022-08-31";
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
    set -eu
    work=$(mktemp -d)
    trap 'rm -rf "$work"' EXIT
    export SIGNED_REQUEST_DIR="$work"
    python3 - <<'PY_SIGN'
    import datetime
    import hashlib
    import hmac
    import json
    import os

    body = {'req_key': 'jimeng_ti2v_v30_pro', 'prompt': '一艘帆船缓缓驶过夕阳下的海面，平稳运镜。', 'frames': 121, 'aspect_ratio': '16:9', 'seed': -1}
    payload = json.dumps(body, ensure_ascii=False, separators=(",", ":")).encode()
    query = "Action=CVSync2AsyncSubmitTask&Version=2022-08-31"
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
    curl 'https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31' \
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
    func check(err error) { if err != nil { panic(err) } }
    func sha(value []byte) string { sum := sha256.Sum256(value); return hex.EncodeToString(sum[:]) }
    func hm(key []byte, value string) []byte { h := hmac.New(sha256.New,key); h.Write([]byte(value)); return h.Sum(nil) }
    func main() {
      payload := []byte(`{
      "req_key": "jimeng_ti2v_v30_pro",
      "prompt": "一艘帆船缓缓驶过夕阳下的海面，平稳运镜。",
      "frames": 121,
      "aspect_ratio": "16:9",
      "seed": -1
    }`)
      query := "Action=CVSync2AsyncSubmitTask&Version=2022-08-31"
      host := "visual.volcengineapi.com"
      xdate := time.Now().UTC().Format("20060102T150405Z")
      date := xdate[:8]
      headers := map[string]string{"content-type":"application/json", "host":host,
        "x-content-sha256":sha(payload), "x-date":xdate}
      names := []string{}
      for name := range headers { names = append(names,name) }; sort.Strings(names)
      canonicalHeaders := ""
      for _,name := range names { canonicalHeaders += name+":"+headers[name]+"\n" }
      signed := strings.Join(names,";")
      canonical := strings.Join([]string{"POST","/",query,canonicalHeaders,signed,sha(payload)},"\n")
      scope := date+"/cn-north-1/cv/request"
      toSign := strings.Join([]string{"HMAC-SHA256",xdate,scope,sha([]byte(canonical))},"\n")
      key := []byte(os.Getenv("VOLC_SECRET_KEY"))
      for _,item := range []string{date,"cn-north-1","cv","request"} { key=hm(key,item) }
      signature := hex.EncodeToString(hm(key,toSign))
      headers["Authorization"] = "HMAC-SHA256 Credential="+os.Getenv("VOLC_ACCESS_KEY")+"/"+scope+", SignedHeaders="+signed+", Signature="+signature
      req,err:=http.NewRequest("POST","https://"+host+"/?"+query,bytes.NewReader(payload)); check(err)
      req.Host = host
      for name,value := range headers { if name!="host" {req.Header.Set(name,value)} }
      res,err:=(&http.Client{Timeout:180*time.Second}).Do(req); check(err); defer res.Body.Close()
      data,err:=io.ReadAll(res.Body); check(err)
      if res.StatusCode<200||res.StatusCode>=300 {panic(fmt.Sprintf("HTTP %d: %s",res.StatusCode,data))}
      var result struct { Code int `json:"code"` }; check(json.Unmarshal(data,&result))
      if result.Code!=10000 {panic(string(data))}; fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## 错误码

先检查 HTTP，再检查业务 code；即便 HTTP 为 200，也不能跳过业务判断。

| 业务码                   | 含义与处理                                 |
| --------------------- | ------------------------------------- |
| 10000                 | 接口成功；查询还须检查 data.status 与 video\_url。 |
| 50411 / 50412 / 50413 | 图片、文本或敏感词/版权相关审核未通过；修改输入，不原样重复。       |
| 50511 / 50516         | 输出图片/视频审核未通过。                         |
| 签名错误 / 401 / 403      | 检查 AK/SK、UTC 时间、区域、Service、请求体哈希和权限。  |
| 429 / 5xx             | 限流或服务异常；创建超时时不要盲目重提，避免重复任务。           |

保留 request\_id、code 和 message。code 非 10000 时 data 可能为 null，不能继续访问 data.status。

## 官方参考

[即梦官方接口](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh)、[火山官方 V4 签名](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py)。