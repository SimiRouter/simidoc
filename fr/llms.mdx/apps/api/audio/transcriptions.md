# Transcription audio

## Description de l’interface

`POST /v1/audio/transcriptions`, authentifiée avec `Authorization: Bearer $SIMIROUTER_API_KEY`. Le téléversement utilise `multipart/form-data` ; laissez la bibliothèque HTTP générer boundary, sans définir un Content-Type incomplet.

L’interface conserve la langue d’origine et ne traduit pas automatiquement le chinois en anglais. Formats \: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm. Taille et durée dépendent aussi du modèle et du canal.

<Callout type="warn" title="Certains modèles s’arrêtent le 2027-02-26">
  `whisper-1`, `gpt-4o-transcribe` et `gpt-4o-mini-transcribe` (y compris les versions datées) sont dépréciés et s’arrêtent le 2027-02-26. Préférez `gpt-transcribe` ; pour le direct, utilisez `gpt-live-transcribe`, ou `gpt-4o-transcribe-diarize` pour la séparation des locuteurs.
</Callout>

## Paramètres de requête

| Champ                         | Type            | Obligatoire  | Description                                                                                                   |
| ----------------------------- | --------------- | ------------ | ------------------------------------------------------------------------------------------------------------- |
| file                          | file            | Oui          | Fichier audio lui-même, pas un chemin ou une URL ordinaire.                                                   |
| model                         | string          | Oui          | Par exemple gpt-transcribe, gpt-4o-transcribe, gpt-4o-mini-transcribe, whisper-1 ou un modèle de diarisation. |
| language                      | string          | Non          | Code ISO-639-1 de la langue d’entrée, par exemple zh ou en.                                                   |
| languages\[]                  | string\[]       | Non          | Liste de langues candidates, seulement pour les modèles compatibles.                                          |
| prompt                        | string          | Non          | Indications terminologiques et contextuelles dans la langue de l’audio ; pas pour les modèles diarize.        |
| keywords\[]                   | string\[]       | Non          | Indications de terminologie, uniquement gpt-transcribe.                                                       |
| response\_format              | string          | Non          | json par défaut ; text, srt, vtt, verbose\_json et diarized\_json selon le modèle.                            |
| temperature                   | number          | Non          | 0–1, défaut 0.                                                                                                |
| stream                        | boolean         | Non          | true renvoie du SSE ; whisper-1 ne le prend pas en charge.                                                    |
| include\[]                    | string\[]       | Non          | logprobs exige un modèle compatible et response\_format=json.                                                 |
| timestamp\_granularities\[]   | string\[]       | Non          | word ou segment ; nécessite verbose\_json et un modèle compatible, pas diarize.                               |
| chunking\_strategy            | string / object | Conditionnel | auto ou configuration server\_vad ; obligatoire avec diarize au-delà de 30 secondes.                          |
| known\_speaker\_names\[]      | string\[]       | Non          | Jusqu’à quatre noms courts de locuteurs connus, associés aux références audio.                                |
| known\_speaker\_references\[] | string\[]       | Non          | Data URLs de 2 à 10 secondes, associées une à une aux noms, pour les modèles compatibles.                     |

`gpt-4o-transcribe` et `gpt-4o-mini-transcribe` utilisent une sortie JSON ; `whisper-1` accepte text, srt, vtt, verbose\_json et d’autres formats. Pour les locuteurs, choisissez un modèle diarize et `diarized_json`, sans imposer ce paramètre à un modèle ordinaire.

## Valeur de retour

| Champ                    | Description                                                                            |
| ------------------------ | -------------------------------------------------------------------------------------- |
| `text`                   | Texte complet de transcription.                                                        |
| `usage`                  | Statistiques d’utilisation du modèle ; les champs varient.                             |
| `logprobs`               | Confiance des tokens renvoyée si demandée et prise en charge.                          |
| `language` / `duration`  | Langue et durée audio en secondes dans verbose\_json.                                  |
| `words[]` / `segments[]` | Segments avec horodatages ou locuteurs selon le format ; absents de certaines sorties. |

```json
{"text":"欢迎参加今天的会议。"}
```

`stream=true` renvoie des fragments et un événement final SSE sur les modèles compatibles. Lisez le flux en continu. Le fichier entier est d’abord téléversé ; ce n’est pas une session Realtime bidirectionnelle.

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Préparez dans le dossier actuel `speech.wav` et définissez la variable `SIMIROUTER_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.dwchainless.com/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'gpt-4o-mini-transcribe', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "gpt-4o-mini-transcribe");
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
    curl "https://api.dwchainless.com/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=gpt-4o-mini-transcribe" \
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
      check(writer.WriteField("model", "gpt-4o-mini-transcribe"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/transcriptions", &buffer); check(err)
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

[OpenAI Create transcription](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create).