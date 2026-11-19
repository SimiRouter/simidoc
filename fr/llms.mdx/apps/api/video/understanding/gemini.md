# Compréhension vidéo Gemini

## Description de l’interface

La compréhension reçoit une vidéo existante et renvoie une analyse textuelle, sans créer de vidéo. Les exemples utilisent **Google Interactions officiel** \: `POST https://generativelanguage.googleapis.com/v1beta/interactions`, authentifiée avec `x-goog-api-key: $GEMINI_API_KEY`. Ce n’est pas une création de tâche Seedance/Kling et cela ne signifie pas que SimiRouter relaie toutes les entrées multimédias Google.

## Paramètres de requête

| Champ               | Type    | Obligatoire  | Description                                                                                                  |
| ------------------- | ------- | ------------ | ------------------------------------------------------------------------------------------------------------ |
| model               | string  | Oui          | Modèle acceptant la vidéo, par exemple gemini-3.8-flash.                                                     |
| input               | array   | Oui          | Média video et question text.                                                                                |
| input\[].type       | string  | Oui          | video ou text.                                                                                               |
| input\[].data       | string  | Conditionnel | Base64 d’une courte vidéo, au choix avec uri.                                                                |
| input\[].mime\_type | string  | Conditionnel | Par exemple video/mp4, correspondant au véritable encodage.                                                  |
| input\[].uri        | string  | Conditionnel | URI de fichier Google téléversé à l’état ACTIVE, ou URL publique acceptée par le modèle.                     |
| input\[].text       | string  | Conditionnel | Résumé, question ou demande concernant une plage temporelle précise.                                         |
| stream / background | boolean | Non          | Une longue analyse peut utiliser streaming ou arrière-plan, avec gestion d’événements/tâches correspondante. |

L’exemple choisit prudemment un court MP4 pour une requête totale inférieure à 20 Mo. Préférez Google Files API pour les vidéos plus grosses ou réutilisées ; après téléversement, attendez ACTIVE et arrêtez sur FAILED, sans interrogation illimitée. URL publique, Cloud Storage et données intégrées sont des chemins d’entrée distincts, non interchangeables.

## Valeur de retour

Le `steps[]` d’Interactions contient model\_output ; les éléments textuels sont `content[].type=text` et `text`. output\_text du SDK est une propriété pratique. Les instants sont une interprétation du modèle à vérifier dans l’original, pas une preuve précise ou une annotation trame par trame.

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"00:10 出现海面上的帆船，随后镜头向右移动。"}]}]}
```

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Préparez une courte vidéo `video.mp4` et définissez la variable officielle Google `GEMINI_API_KEY`. L’exemple ne lance ni génération payante de vidéo ni gestion de fichiers, mais l’inférence elle-même peut être facturée.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")}]}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": (await readFile("video.mp4")).toString("base64")
        }
      ]
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '总结视频内容，并列出关键事件对应的时间点。'}, {'type': 'video', 'mime_type': 'video/mp4', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('video.mp4').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "@$request"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "encoding/base64"
      "io"
      "net/http"
      "os"
      "time"
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      media, err := os.ReadFile("video.mp4"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "总结视频内容，并列出关键事件对应的时间点。"
        },
        {
          "type": "video",
          "mime_type": "video/mp4",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      fmt.Println(string(data))
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

| Statut HTTP           | Sens et traitement                                                                                                                                                                |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 400 / 422             | Champs, média ou paramètres de modèle invalides ; corrigez avant de soumettre.                                                                                                    |
| 401                   | Clé API absente, invalide ou expirée.                                                                                                                                             |
| 403                   | Projet ou modèle non autorisé.                                                                                                                                                    |
| 404                   | Modèle, route ou ressource d’entrée introuvable ; vérifiez l’adresse, l’ID du modèle et l’état du fichier.                                                                        |
| 413 / 415             | Fichier trop volumineux ou type de média non pris en charge.                                                                                                                      |
| 429                   | Limite de débit ou de quota ; distinguez le manque de crédit d’une limitation temporaire.                                                                                         |
| 500 / 502 / 503 / 504 | Erreur du service ou de l’amont \: conservez l’ID. Après un délai d’une requête synchrone, vérifiez les journaux ou l’état avant de réessayer pour éviter une double facturation. |

L’objet d’erreur Google utilise `error.code`, `error.status`, `error.message` ; ne traitez pas le corps d’erreur comme un résultat d’analyse normal.

## Références officielles

[Compréhension vidéo Google](https\://ai.google.dev/gemini-api/docs/video-understanding), [Files](https\://ai.google.dev/gemini-api/docs/files).