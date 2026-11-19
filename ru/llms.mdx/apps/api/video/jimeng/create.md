# Отправить видеозадачу Jimeng (планируется подключение)

## Описание интерфейса

`POST https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31`, тело JSON. Официально требуется подпись AK/SK V4, Region=`cn-north-1`, Service=`cv`, не обычный Bearer.

Страница содержит справку поставщика для Jimeng 3.0 Pro, официально помеченного «выводится из эксплуатации». Подходит только авторизованным аккаунтам, пока сервис доступен; это не публичное соответствие SimiRouter `/jimeng/`. Реализация ниже не использует прокси и не пропускает обязательную подпись.

## Параметры запроса

| Поле                 | Тип       | Обязателен  | Описание                                                                                                 |
| -------------------- | --------- | ----------- | -------------------------------------------------------------------------------------------------------- |
| Action (query)       | string    | Да          | CVSync2AsyncSubmitTask.                                                                                  |
| Version (query)      | string    | Да          | 2022-08-31.                                                                                              |
| req\_key             | string    | Да          | Для продукта всегда jimeng\_ti2v\_v30\_pro, не jimeng\_video\_generation.                                |
| prompt               | string    | При условии | Обязательно для текста в видео, необязательно для изображения; желательно до 400 символов, максимум 800. |
| image\_urls          | string\[] | Нет         | URL первого кадра, только одно изображение; на выбор с binary\_data\_base64.                             |
| binary\_data\_base64 | string\[] | Нет         | Один JPEG/PNG в Base64, до 4,7 МБ; пиксели и прочие ограничения см. у поставщика.                        |
| seed                 | integer   | Нет         | По умолчанию -1 — случайно.                                                                              |
| frames               | integer   | Нет         | 121 (5 секунд) или 241 (10 секунд), по умолчанию 121.                                                    |
| aspect\_ratio        | string    | Нет         | 16\:9, 4\:3, 1\:1, 3\:4, 9\:16, 21\:9, только для текста в видео.                                        |

Подписываются Content-Type, Host, X-Date (UTC), X-Content-Sha256. Отправленные тело и query должны строго совпадать с подписанными; изменение Action требует новой подписи.

## Ответ

| Поле               | Описание                                                 |
| ------------------ | -------------------------------------------------------- |
| `code` / `message` | Бизнес-успех — 10000; одного HTTP-статуса недостаточно.  |
| `request_id`       | ID отслеживания сервера.                                 |
| `data.task_id`     | ID задачи для дальнейшего опроса, только при code=10000. |

```json
{"code":10000,"message":"Success","request_id":"request_example","data":{"task_id":"7392616336519610409"}}
```

Успешная отправка означает лишь принятие; используйте [Получить результат](/simidoc/ru/apps/api/video/jimeng/status) для состояния. Здесь нельзя ожидать синхронного video\_url.

## Примеры вызова

Для Python установите `python3 -m pip install requests`; Node.js 18+ использует fetch, Go — стандартную библиотеку.

Задайте `VOLC_ACCESS_KEY`, `VOLC_SECRET_KEY`. cURL сначала создаёт подпись локально, затем отправляет; не записывайте AK/SK в код или журналы.

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

## Коды ошибок

Сначала HTTP, затем бизнес-code; даже HTTP 200 не отменяет бизнес-проверку.

| Бизнес-код                 | Значение и действие                                                                                                          |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| 10000                      | Успешный вызов; при опросе проверьте также data.status и video\_url.                                                         |
| 50411 / 50412 / 50413      | Изображение, текст, чувствительные слова или авторские права не прошли проверку; измените вход, не повторяйте без изменений. |
| 50511 / 50516              | Выходное изображение/видео не прошло модерацию.                                                                              |
| Ошибка подписи / 401 / 403 | Проверьте AK/SK, UTC, регион, Service, хеш тела и права.                                                                     |
| 429 / 5xx                  | Ограничение частоты или сбой; после тайм-аута создания не отправляйте вслепую повторно, чтобы не дублировать задачи.         |

Сохраните request\_id, code и message. При code не равном 10000 data может быть null; далее читать data.status нельзя.

## Официальные материалы

[Официальный интерфейс Jimeng](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh), [Официальная подпись Volcengine V4](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py).