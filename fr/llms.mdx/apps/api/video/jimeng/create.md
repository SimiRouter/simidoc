# Soumettre une tâche vidéo Jimeng (intégration prévue)

## Description de l’interface

`POST https://visual.volcengineapi.com/?Action=CVSync2AsyncSubmitTask&Version=2022-08-31`, corps JSON. L’API officielle exige une signature V4 AK/SK, Region=`cn-north-1`, Service=`cv`, pas un simple Bearer.

Cette page est une référence fournisseur pour Jimeng 3.0 Pro, indiqué officiellement « en cours de retrait ». Applicable uniquement si le compte est autorisé et le service encore ouvert ; ce n’est pas le mappage public `/jimeng/` de SimiRouter. La signature ci-dessous n’appelle aucun proxy et n’omet aucune signature obligatoire.

## Paramètres de requête

| Champ                | Type      | Obligatoire  | Description                                                                                                      |
| -------------------- | --------- | ------------ | ---------------------------------------------------------------------------------------------------------------- |
| Action (query)       | string    | Oui          | CVSync2AsyncSubmitTask.                                                                                          |
| Version (query)      | string    | Oui          | 2022-08-31.                                                                                                      |
| req\_key             | string    | Oui          | Ce produit utilise jimeng\_ti2v\_v30\_pro, pas jimeng\_video\_generation.                                        |
| prompt               | string    | Conditionnel | Obligatoire en texte vers vidéo, facultatif en image vers vidéo ; 400 caractères conseillés, 800 maximum.        |
| image\_urls          | string\[] | Non          | URL de l’image de première trame, une seule ; au choix avec binary\_data\_base64.                                |
| binary\_data\_base64 | string\[] | Non          | Base64 JPEG/PNG, une image, 4,7 Mo maximum ; autres limites, notamment pixels, dans la documentation officielle. |
| seed                 | integer   | Non          | -1 par défaut pour l’aléatoire.                                                                                  |
| frames               | integer   | Non          | 121 (5 secondes) ou 241 (10 secondes), 121 par défaut.                                                           |
| aspect\_ratio        | string    | Non          | 16\:9, 4\:3, 1\:1, 3\:4, 9\:16, 21\:9, uniquement en texte vers vidéo.                                           |

Les en-têtes signés comprennent Content-Type, Host, X-Date (UTC) et X-Content-Sha256. Corps et query envoyés doivent être strictement identiques aux données signées ; changer Action exige une nouvelle signature.

## Valeur de retour

| Champ              | Description                                                      |
| ------------------ | ---------------------------------------------------------------- |
| `code` / `message` | Succès métier \: 10000 ; ne vérifiez pas seulement le code HTTP. |
| `request_id`       | ID de suivi serveur.                                             |
| `data.task_id`     | ID de tâche à consulter, présent uniquement avec code=10000.     |

```json
{"code":10000,"message":"Success","request_id":"request_example","data":{"task_id":"7392616336519610409"}}
```

Une soumission réussie signifie seulement l’acceptation ; utilisez [Consulter le résultat](/simidoc/fr/apps/api/video/jimeng/status) pour l’état. N’attendez pas un video\_url synchrone sur cette page.

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Définissez `VOLC_ACCESS_KEY`, `VOLC_SECRET_KEY`. L’exemple cURL génère d’abord la signature localement puis envoie ; ne placez pas AK/SK dans le code ou les journaux.

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

## Codes d’erreur

Vérifiez d’abord HTTP puis code métier ; HTTP 200 ne dispense pas de ce contrôle.

| Code métier                     | Sens et traitement                                                                                                  |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| 10000                           | Appel réussi ; la consultation exige encore data.status et video\_url.                                              |
| 50411 / 50412 / 50413           | Image, texte ou vérification de termes sensibles/droits d’auteur refusés ; modifiez l’entrée au lieu de la répéter. |
| 50511 / 50516                   | Image/vidéo de sortie refusée par la modération.                                                                    |
| Erreur de signature / 401 / 403 | Vérifiez AK/SK, heure UTC, région, Service, hachage du corps et autorisations.                                      |
| 429 / 5xx                       | Limitation ou erreur de service ; ne répétez pas aveuglément une création expirée pour éviter les doublons.         |

Conservez request\_id, code et message. Si code n’est pas 10000, data peut être null ; n’accédez pas ensuite à data.status.

## Références officielles

[Interface officielle Jimeng](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh), [Signature V4 officielle Volcengine](https\://github.com/volcengine/volc-sdk-python/blob/main/volcengine/auth/SignerV4.py).