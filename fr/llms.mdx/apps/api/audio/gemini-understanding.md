# Compréhension audio Gemini

## Description de l’interface

La compréhension audio Gemini traite un enregistrement comme entrée multimodale et renvoie du texte \: transcription, résumé, description des locuteurs et analyse temporelle. Ce n’est ni de la synthèse ni l’interface dédiée `/audio/transcriptions`. Cette page utilise l’API officielle Google `POST /v1beta/interactions`, authentifiée avec `x-goog-api-key: $GEMINI_API_KEY`, sans garantir sa disponibilité via le relais natif SimiRouter.

## Paramètres de requête

| Champ               | Type    | Obligatoire  | Description                                                                                           |
| ------------------- | ------- | ------------ | ----------------------------------------------------------------------------------------------------- |
| model               | string  | Oui          | Modèle acceptant l’audio, par exemple gemini-3.8-flash.                                               |
| input               | array   | Oui          | Tableau de contenu associant une instruction text et une entrée audio.                                |
| input\[].type       | string  | Oui          | text pour le texte, audio pour l’enregistrement.                                                      |
| input\[].data       | string  | Conditionnel | Audio en Base64 intégré, sans préfixe data URL.                                                       |
| input\[].uri        | string  | Conditionnel | URI renvoyé par Google Files API ; choisissez cette option ou data intégré.                           |
| input\[].mime\_type | string  | Conditionnel | Par exemple audio/wav ou audio/mpeg, correspondant au contenu réel.                                   |
| stream              | boolean | Non          | Le texte peut être diffusé en continu, ce qui ne signifie pas un téléversement continu du microphone. |

Pour les gros enregistrements, privilégiez Files puis une référence URI. Les fichiers intégrés doivent respecter les limites du modèle et du corps. Un chemin local n’est pas un URI accessible au cloud ; les horodatages du modèle ne garantissent pas un alignement professionnel précis.

## Valeur de retour

Le texte se trouve dans `steps[].content[]`, dans les éléments text ; le SDK propose `output_text`. Pour une transcription longue, vérifiez l’état final et la troncature. Extrait de structure \:

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"录音主要介绍了会议议程。"}]}]}
```

## Exemples de code

Python 3 et Go utilisent leur bibliothèque standard ; Node.js 18+ utilise fetch intégré.

Préparez dans le dossier courant un court enregistrement `speech.wav` et définissez la variable `GEMINI_API_KEY`. Les exemples lisent le vrai fichier, l’encodent en Base64 et soumettent la requête, puis affichent le JSON complet.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import base64
    from pathlib import Path
    import json, urllib.request

    url = os.environ.get('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com').rstrip('/') + '/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY']}
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")}]}
    headers['Content-Type'] = 'application/json'
    request = urllib.request.Request(url, data=json.dumps(body).encode(), headers=headers, method='POST')
    with urllib.request.urlopen(request, timeout=180) as response:
        print(response.read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const { readFile } = require("node:fs/promises");
    async function main() {
      if (!process.env.GEMINI_API_KEY) throw new Error("请设置 GEMINI_API_KEY");
      const url = (process.env.GEMINI_BASE_URL || "https://generativelanguage.googleapis.com").replace(/\/$/, "") + "/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": (await readFile("speech.wav")).toString("base64")
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
    : "${GEMINI_API_KEY:?请设置 GEMINI_API_KEY}"
    base="${GEMINI_BASE_URL:-https://generativelanguage.googleapis.com}"
    request=$(mktemp)
    trap 'rm -f "$request"' EXIT
    python3 - <<'PY_BODY' > "$request"
    import base64, json
    from pathlib import Path
    body = {'model': 'gemini-3.8-flash', 'input': [{'type': 'text', 'text': '请概括录音的主要内容。'}, {'type': 'audio', 'mime_type': 'audio/wav', 'data': 'ENCODED_MEDIA_DATA'}]}
    body["input"][1]["data"] = base64.b64encode(Path('speech.wav').read_bytes()).decode("ascii")
    print(json.dumps(body, ensure_ascii=False))
    PY_BODY
    curl "${base%/}/v1beta/interactions" \
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
      if os.Getenv("GEMINI_API_KEY")=="" { panic("请设置 GEMINI_API_KEY") }
      base:=os.Getenv("GEMINI_BASE_URL"); if base=="" { base="https://generativelanguage.googleapis.com" }
      media, err := os.ReadFile("speech.wav"); check(err)
      encoded := base64.StdEncoding.EncodeToString(media)
      body := strings.NewReader(strings.Replace(`{
      "model": "gemini-3.8-flash",
      "input": [
        {
          "type": "text",
          "text": "请概括录音的主要内容。"
        },
        {
          "type": "audio",
          "mime_type": "audio/wav",
          "data": "ENCODED_MEDIA_DATA"
        }
      ]
    }`, "ENCODED_MEDIA_DATA", encoded, 1))
      req, err := http.NewRequest("POST", strings.TrimRight(base,"/")+"/v1beta/interactions", body); check(err)
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

| Statut HTTP           | Sens et traitement                                                                                                                                 |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 400                   | Champs de requête ou paramètres de modèle invalides ; corrigez avant de soumettre.                                                                 |
| 401                   | Clé API absente, invalide ou expirée.                                                                                                              |
| 403                   | Projet ou modèle non autorisé.                                                                                                                     |
| 404                   | Modèle ou route introuvable ; vérifiez l’adresse et l’identifiant du modèle.                                                                       |
| 429                   | Limite de débit ou de quota ; distinguez le manque de crédit d’une limitation temporaire.                                                          |
| 500 / 502 / 503 / 504 | Erreur du service ou de l’amont. Conservez l’ID de requête et patientez avant de réessayer ; ne relancez pas indéfiniment la même requête payante. |

Les objets d’erreur Google utilisent `error.code`, `error.status` et `error.message` ; ne déduisez pas la source du seul code HTTP. Ce point d’accès est synchrone \: il n’y a ni identifiant de tâche ni phase d’interrogation. Ne traitez jamais le texte d’erreur comme une transcription ou un résumé.

## Références officielles

[Compréhension audio Google](https\://ai.google.dev/gemini-api/docs/audio), [Google Files](https\://ai.google.dev/gemini-api/docs/files).