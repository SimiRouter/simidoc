# Image vers vidéo Kling

## Description de l’interface

`POST https://api-singapore.klingai.com/image-to-video/kling-3.0`, authentification `Authorization: Bearer $KLING_API_KEY`, corps JSON. L’exemple utilise la nouvelle API officielle Kling, pas l’ancien mappage `/kling/v1/videos/...` de SimiRouter.

## Paramètres de requête

| Champ                           | Type      | Obligatoire  | Description                                                                           |
| ------------------------------- | --------- | ------------ | ------------------------------------------------------------------------------------- |
| contents                        | object\[] | Oui          | Contenus d’entrée \: images, texte, éléments, etc.                                    |
| contents\[].type                | string    | Oui          | Types acceptés comme prompt, first\_frame et last\_frame.                             |
| contents\[].text                | string    | Conditionnel | Instructions d’action, caméra et contenu de l’élément prompt.                         |
| contents\[].url                 | string    | Conditionnel | URL accessible d’image first\_frame / last\_frame.                                    |
| settings.resolution             | string    | Non          | 720p (défaut), 1080p ou 4k, selon les droits du modèle.                               |
| settings.duration               | integer   | Non          | 5 secondes par défaut ; la référence 3.0 actuelle accepte 3–15 secondes.              |
| settings.audio                  | string    | Non          | off (défaut) ou native pour une piste audio native.                                   |
| settings.multi\_shot            | boolean   | Non          | true par défaut ; false dans cet exemple pour un seul plan.                           |
| options.callback\_url           | string    | Non          | Rappel d’état ; implémentez une réception sûre et un traitement idempotent.           |
| options.external\_task\_id      | string    | Non          | ID personnalisé unique dans le compte pour consultation, sans remplacer l’ID système. |
| options.watermark\_info.enabled | boolean   | Non          | Propose ou non un résultat filigrané ; pas de filigrane personnalisé.                 |

La présence d’un champ ne permet pas de déduire les capacités de tous les modèles. Les consignes multi-plans doivent respecter la syntaxe shot officielle et la somme des durées doit correspondre à la durée totale. Première/dernière trame, éléments et formats de référence dépendent du modèle courant.

## Valeur de retour

```json
{"code":0,"message":"Success","request_id":"request_example","data":{"id":"task_example","status":"submitted","create_time":1780000000000,"update_time":1780000000000}}
```

`data.id` est l’ID système de consultation ; `data.status` peut être submitted, processing, succeeded ou failed ; les horodatages sont en millisecondes. La création ne renvoie pas une vidéo terminée. Ne lisez pas l’ancien `data.task_id` ou `task_status`.

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Définissez la variable officielle Kling `KLING_API_KEY`. L’appel crée une tâche facturable. Après création, consultez [Consultation de tâche](/simidoc/fr/apps/api/video/kling/image-status).

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api-singapore.klingai.com/image-to-video/kling-3.0'
    headers = {'Authorization': 'Bearer ' + os.environ['KLING_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'contents': [{'type': 'prompt', 'text': '镜头缓缓拉远，画面保持稳定。'}, {'type': 'first_frame', 'url': 'https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png'}], 'settings': {'resolution': '720p', 'duration': 5, 'audio': 'off', 'multi_shot': False}}, timeout=180)
    response.raise_for_status()
    result = response.json()
    if result.get("code") != 0:
        raise RuntimeError(result)
    print(result)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api-singapore.klingai.com/image-to-video/kling-3.0";
      const headers = { "Authorization": "Bearer " + process.env.KLING_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "contents": [
        {
          "type": "prompt",
          "text": "镜头缓缓拉远，画面保持稳定。"
        },
        {
          "type": "first_frame",
          "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
        }
      ],
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false
      }
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const result = await response.json();
      if (result.code !== 0) throw new Error(JSON.stringify(result));
      console.log(result);
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    response=$(mktemp)
    trap 'rm -f "$response"' EXIT
    curl "https://api-singapore.klingai.com/image-to-video/kling-3.0" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $KLING_API_KEY" \
      -H "Content-Type: application/json" \
      --output "$response" \
      -d '{
        "contents": [
          {
            "type": "prompt",
            "text": "镜头缓缓拉远，画面保持稳定。"
          },
          {
            "type": "first_frame",
            "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
          }
        ],
        "settings": {
          "resolution": "720p",
          "duration": 5,
          "audio": "off",
          "multi_shot": false
        }
      }'
    python3 - "$response" <<'PY_CHECK'
    import json, sys
    from pathlib import Path
    result = json.loads(Path(sys.argv[1]).read_text())
    if result.get("code") != 0:
        raise SystemExit(json.dumps(result, ensure_ascii=False))
    print(json.dumps(result, ensure_ascii=False))
    PY_CHECK
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "encoding/json"
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "contents": [
        {
          "type": "prompt",
          "text": "镜头缓缓拉远，画面保持稳定。"
        },
        {
          "type": "first_frame",
          "url": "https://p2-kling.klingai.com/kcdn/cdn-kcdn112452/kling-tob-release_note/image_25.png"
        }
      ],
      "settings": {
        "resolution": "720p",
        "duration": 5,
        "audio": "off",
        "multi_shot": false
      }
    }`)
      req, err := http.NewRequest("POST", "https://api-singapore.klingai.com/image-to-video/kling-3.0", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("KLING_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      var result struct { Code int `json:"code"` }
      check(json.Unmarshal(data, &result))
      if result.Code != 0 { panic(string(data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

| HTTP / code métier                   | Description                                                                               |
| ------------------------------------ | ----------------------------------------------------------------------------------------- |
| 200 / 0                              | Requête réussie ; vérifiez status de la tâche pour la fin de génération.                  |
| 400 / 1201                           | Paramètres incorrects ; lisez message.                                                    |
| 404 / 1202, 1203                     | Méthode incorrecte ou modèle/ressource introuvable.                                       |
| 401                                  | Clé API ou ancien JWT invalide.                                                           |
| 400 / 1300, 1301                     | Restriction de politique ou de sécurité ; corrigez le contenu sans réessayer aveuglément. |
| 429 / 1302, 1303, 1304               | Limite de débit, concurrence ou politique IP.                                             |
| 500 / 5000 ; 503 / 5001 ; 504 / 5002 | Erreur de service ou délai dépassé ; conservez request\_id.                               |

HTTP 200 n’est pas une réussite métier ; vérifiez code=0 avant de lire data.

## Références officielles

[Interface officielle Kling](https\://kling.ai/document-api/apiReference/model/imageToVideo), [Authentification](https\://kling.ai/document-api/api/get-started/authentication), [Codes d’erreur](https\://kling.ai/document-api/api/get-started/error-codes).