# Traduction audio

## Description de l’interface

`POST /v1/audio/translations` reçoit un enregistrement et produit de l’**anglais**, sans paramètre arbitraire de langue cible. Authentification \: `Authorization: Bearer $SIMIROUTER_API_KEY` et le corps est `multipart/form-data`. Référence \: OpenAI Audio Translations API. Le compte doit disposer du canal du modèle.

<Callout type="warn" title="Endpoint et modèle arrêtés le 2027-02-26">
  OpenAI a déprécié `/v1/audio/translations` et `whisper-1`, arrêtés le 2027-02-26. La solution de remplacement est l’API Realtime `/v1/realtime/translations` avec `gpt-realtime-translate`, qui demande une intégration distincte. Cette page n’est conservée que comme référence avant migration.
</Callout>

## Paramètres de requête

| Champ            | Type   | Obligatoire | Description                                                                   |
| ---------------- | ------ | ----------- | ----------------------------------------------------------------------------- |
| file             | file   | Oui         | Fichier audio lui-même \: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav ou webm.  |
| model            | string | Oui         | Cette interface utilise whisper-1 ; pas un modèle de transcription ordinaire. |
| prompt           | string | Non         | Termes ou contexte en anglais.                                                |
| response\_format | string | Non         | json (défaut), text, srt, verbose\_json ou vtt.                               |
| temperature      | number | Non         | 0–1, défaut 0.                                                                |

## Valeur de retour

La sortie JSON contient `text` pour la traduction anglaise. `verbose_json` ajoute aussi `duration` (secondes) et `language` (english), `segments[]`. Les formats de sous-titres renvoient du texte, pas du JSON. Cet appel de fichier ne propose pas stream ; la traduction temps réel utilise une session distincte.

```json
{"text":"Welcome to today's meeting."}
```

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Préparez `speech.wav`, puis définissez `SIMIROUTER_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/translations'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'whisper-1', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/translations";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "whisper-1");
      form.append("response_format", "json");
      const body = form;
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      console.log(await response.text());
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    curl "https://api.dwchainless.com/v1/audio/translations" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=whisper-1" \
      -F "response_format=json"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "net/http"
      "os"
      "time"
      "bytes"
      "mime/multipart"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      var buffer bytes.Buffer
      writer := multipart.NewWriter(&buffer)
      source, err := os.Open("speech.wav"); check(err)
      part, err := writer.CreateFormFile("file", "speech.wav"); check(err)
      _, err = io.Copy(part, source); source.Close(); check(err)
      check(writer.WriteField("model", "whisper-1"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/translations", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", writer.FormDataContentType())
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
| 413                   | Fichier au-delà de la limite d’envoi ; compressez-le ou utilisez un fichier plus petit.                                                            |
| 429                   | Limite de débit ou de quota ; distinguez le manque de crédit d’une limitation temporaire.                                                          |
| 500 / 502 / 503 / 504 | Erreur du service ou de l’amont. Conservez l’ID de requête et patientez avant de réessayer ; ne relancez pas indéfiniment la même requête payante. |

Les champs `error.message`, `error.type` et `error.code` du corps d’erreur précisent la cause mieux que le statut HTTP. Ce point d’accès est synchrone \: il n’y a ni identifiant de tâche ni phase d’interrogation. N’enregistrez jamais le texte d’erreur comme transcription.

## Références officielles

[OpenAI Create translation](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create).