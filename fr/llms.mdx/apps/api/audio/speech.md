# Texte vers parole

## Description de l’interface

`POST /v1/audio/speech` convertit `input` en parole. Avec SimiRouter, l’adresse de base est `https://api.dwchainless.com`, authentifiée avec `Authorization: Bearer $SIMIROUTER_API_KEY` et le corps est `application/json`. Cette page se réfère à Speech API OpenAI ; le canal détermine les modèles et champs relayés.

<Callout type="warn" title="Modèles arrêtés le 2027-01-06">
  `gpt-4o-mini-tts`, `tts-1` et `tts-1-hd` sont dépréciés par OpenAI et seront arrêtés le 2027-01-06. Le remplacement officiel est `gpt-realtime-2.1-mini` sur la Realtime API, qui ne prend pas en charge `/v1/audio/speech` ; migrez via `/v1/realtime`. Les exemples utilisent encore un modèle routable aujourd’hui ; vérifiez que le canal fournit un remplacement avant l’appel.
</Callout>

## Paramètres de requête

| Champ            | Type            | Obligatoire | Description                                                                                |
| ---------------- | --------------- | ----------- | ------------------------------------------------------------------------------------------ |
| model            | string          | Oui         | Modèle TTS disponible, par exemple gpt-4o-mini-tts ; pas un modèle de transcription.       |
| input            | string          | Oui         | Texte à lire, maximum 4096 caractères.                                                     |
| voice            | string / object | Oui         | Nom de voix intégré ou voix personnalisée autorisée \{"id"\:"voice\_..."}.                 |
| instructions     | string          | Non         | Consignes de ton/style, maximum 4096 caractères ; non prises en charge par tts-1/tts-1-hd. |
| response\_format | string          | Non         | mp3 (défaut), opus, aac, flac, wav ou pcm.                                                 |
| speed            | number          | Non         | 0,25–4,0, défaut 1.                                                                        |
| stream\_format   | string          | Non         | audio (défaut) ou sse ; tts-1/tts-1-hd n’acceptent pas sse.                                |

Les voix intégrées comprennent `alloy`, `ash`, `ballad`, `coral`, `echo`, `fable`, `onyx`, `nova`, `sage`, `shimmer`, `verse`, `marin`, `cedar` ; chaque modèle peut n’en accepter qu’une partie. Le nom d’une voix ne fixe pas sa langue.

## Valeur de retour

En cas de succès, des octets audio sont renvoyés, pas un JSON contenant une URL. L’extension doit correspondre à `response_format`. PCM contient des échantillons bruts sans conteneur ; la lecture exige leurs paramètres corrects. La réponse audio peut être lue par fragments pour réduire l’attente.

`stream_format: "sse"` utilise un flux d’événements ; analysez-les et décodez les fragments audio. Ne sauvegardez pas le texte SSE comme MP3. La disponibilité dépend aussi du canal.

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Définissez d’abord `SIMIROUTER_API_KEY`. L’exemple choisit MP3 et s’arrête en cas d’erreur HTTP pour ne pas enregistrer du JSON comme audio.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.dwchainless.com/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['SIMIROUTER_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'gpt-4o-mini-tts', 'input': '你好，欢迎使用语音合成。', 'voice': 'alloy', 'response_format': 'mp3'}, timeout=180)
    response.raise_for_status()
    Path('speech.mp3').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.dwchainless.com/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.SIMIROUTER_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("speech.mp3", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "speech.mp3" ] || { printf '%s\n' "目标文件已存在：speech.mp3" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "https://api.dwchainless.com/v1/audio/speech" \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }' \
      --output "$temporary"; then
      mv "$temporary" "speech.mp3"
    else
      status=$?
      cat "$temporary" >&2
      exit "$status"
    fi
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
      "strings"
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
      body := strings.NewReader(`{
      "model": "gpt-4o-mini-tts",
      "input": "你好，欢迎使用语音合成。",
      "voice": "alloy",
      "response_format": "mp3"
    }`)
      req, err := http.NewRequest("POST", "https://api.dwchainless.com/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("SIMIROUTER_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("speech.mp3", data, 0600))
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

Les champs `error.message`, `error.type` et `error.code` du corps d’erreur précisent la cause mieux que le statut HTTP. Ce point d’accès est synchrone \: il n’y a ni identifiant de tâche ni phase d’interrogation. N’enregistrez jamais le texte d’erreur comme fichier audio.

## Références officielles

[OpenAI Create speech](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create).