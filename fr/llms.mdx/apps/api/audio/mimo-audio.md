# Intégration audio MiMo

## Description de l’interface

MiMo propose synthèse, transcription, création de voix et clonage à partir d’une référence. Deux interfaces doivent être distinguées \:

| Protocole                         | Adresse / Point d’accès                                                         | Authentification                                    | Sortie                        |
| --------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------------- | ----------------------------- |
| Service audio compatible autonome | Adresse de déploiement suivie de `/v1/audio/speech`, `/v1/audio/transcriptions` | Clé Bearer du service ; x-api-key également accepté | Octets audio ou transcription |
| Interface native Xiaomi           | `https://api.xiaomimimo.com/v1/chat/completions`                                | Clé officielle MiMo api-key ou Bearer               | Chat Completions JSON / SSE   |

**Les routes compatibles ne sont pas des interfaces natives Xiaomi.** Les exemples compatibles ciblent par défaut le service autonome `http://127.0.0.1:8080` ; adaptez l’hôte et le port si nécessaire. Vérifiez séparément la configuration publique SimiRouter ; une clé du service autonome n’y est pas interchangeable.

## Paramètres de requête

### Synthèse \: POST /v1/audio/speech

| Champ            | Type            | Obligatoire | Description                                                                                                                                   |
| ---------------- | --------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| model            | string          | Oui         | mimo-v2.5-tts, mimo-v2.5-tts-voicedesign, mimo-v2.5-tts-voiceclone.                                                                           |
| input            | string          | Oui         | Texte non vide ; maximum par défaut de 4096 caractères, configurable au déploiement.                                                          |
| voice            | string / object | Oui         | Voix prédéfinie ; pour un clonage, data URL audio ou \{"id"\:"voice\_..."} créé par le service.                                               |
| instructions     | string          | Non         | Consignes de ton/style, maximum 4096 caractères.                                                                                              |
| style            | string          | Non         | Extension du service compatible prioritaire sur instructions ; voicedesign l’utilise pour décrire la voix.                                    |
| speed            | number          | Non         | 0,25–4, défaut 1 ; transformé en consigne de style, sans garantie de vitesse exacte échantillon par échantillon.                              |
| response\_format | string          | Non         | wav, mp3, opus, aac, flac ou pcm. MiMo direct produit du WAV par défaut ; précisez le format.                                                 |
| stream\_format   | string          | Non         | Le service compatible accepte uniquement audio ; sse renvoie explicitement 400. Il ne propose pas de synthèse amont en flux à faible latence. |

Correspondance des voix prédéfinies \: alloy→Bingtang, echo→Moli, fable→Baihua, onyx→Suda, nova→Mia, shimmer→Chloe, dean→Dean, milo→Milo. Ce sont des alias du service compatible, pas les voix OpenAI de mêmes noms.

### Transcription \: POST /v1/audio/transcriptions

| Champ                       | Type      | Obligatoire | Description                                                                                               |
| --------------------------- | --------- | ----------- | --------------------------------------------------------------------------------------------------------- |
| file                        | file      | Oui         | Fichier multipart ; maximum par défaut de 25 Mio, configurable au déploiement.                            |
| model                       | string    | Oui         | mimo-v2.5-asr.                                                                                            |
| language                    | string    | Non         | auto (défaut), zh ou en.                                                                                  |
| languages\[]                | string\[] | Non         | Langues candidates, exclusives de language ; plusieurs candidates reviennent à une détection automatique. |
| response\_format            | string    | Non         | json (défaut), text, verbose\_json, srt ou vtt. diarized\_json n’est pas pris en charge.                  |
| stream                      | boolean   | Non         | Événements SSE après transcription complète, pas une transcription amont pendant l’écoute.                |
| timestamp\_granularities\[] | string\[] | Non         | Non pris en charge ; une valeur non vide renvoie 400. Aucun horodatage de mot ou segment n’est inventé.   |

Le service compatible accepte mp3, wav, aac, flac, m4a, mp4, mpeg, mpga, oga, ogg, opus et webm ; les formats non natifs nécessitent un convertisseur. L’ASR natif Xiaomi accepte uniquement MP3/WAV ; ne mélangez pas les limites.

## Valeur de retour

* Le TTS réussi renvoie des octets audio avec le MIME approprié après synthèse complète, sans task\_id public.
* Le JSON ASR est `{"text":"识别文字"}` ; text renvoie directement du texte brut.
* verbose\_json contient task, language, duration, text et des segments vides ; **aucun véritable horodatage de segment n’est fourni**. SRT/VTT porte sur l’enregistrement entier, sans alignement mot à mot.
* stream=true enveloppe uniquement la transcription finale en SSE ; cela ne prouve pas que l’amont reconnaît en temps réel.

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

### Texte vers parole

Définissez pour le service autonome `MIMO_AUDIO_API_KEY`. L’exemple produit `mimo-speech.wav`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'http://127.0.0.1:8080/v1/audio/speech'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'mimo-v2.5-tts', 'input': '你好，欢迎使用 MiMo 语音。', 'voice': 'alloy', 'response_format': 'wav'}, timeout=180)
    response.raise_for_status()
    Path('mimo-speech.wav').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/speech";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    });
      const response = await fetch(url, { method: "POST", headers, body, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("mimo-speech.wav", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "mimo-speech.wav" ] || { printf '%s\n' "目标文件已存在：mimo-speech.wav" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X POST "http://127.0.0.1:8080/v1/audio/speech" \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary '{
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }' \
      --output "$temporary"; then
      mv "$temporary" "mimo-speech.wav"
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
      "model": "mimo-v2.5-tts",
      "input": "你好，欢迎使用 MiMo 语音。",
      "voice": "alloy",
      "response_format": "wav"
    }`)
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/speech", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
      req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("mimo-speech.wav", data, 0600))
    }
    ```
  </Tab>
</Tabs>

### Parole vers texte

Préparez `speech.wav`. L’authentification utilise toujours la clé du service autonome.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'http://127.0.0.1:8080/v1/audio/transcriptions'
    headers = {'Authorization': 'Bearer ' + os.environ['MIMO_AUDIO_API_KEY']}
    with open('speech.wav', "rb") as source:
        response = requests.request('POST', url, headers=headers, data={'model': 'mimo-v2.5-asr', 'language': 'auto', 'response_format': 'json'}, files={'file': source}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "http://127.0.0.1:8080/v1/audio/transcriptions";
      const headers = { "Authorization": "Bearer " + process.env.MIMO_AUDIO_API_KEY };
      const { readFile } = require("node:fs/promises");
      const form = new FormData();
      form.append("file", new Blob([await readFile("speech.wav")]), "speech.wav");
      form.append("model", "mimo-v2.5-asr");
      form.append("language", "auto");
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
    curl "http://127.0.0.1:8080/v1/audio/transcriptions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $MIMO_AUDIO_API_KEY" \
      -F "file=@speech.wav" \
      -F "model=mimo-v2.5-asr" \
      -F "language=auto" \
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
      check(writer.WriteField("model", "mimo-v2.5-asr"))
      check(writer.WriteField("language", "auto"))
      check(writer.WriteField("response_format", "json"))
      check(writer.Close())
      req, err := http.NewRequest("POST", "http://127.0.0.1:8080/v1/audio/transcriptions", &buffer); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("MIMO_AUDIO_API_KEY"))
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

### Création et clonage de voix

Pour la création de voix, remplacez model par `mimo-v2.5-tts-voicedesign` et ajoutez `style: "温暖低沉的成年男声，普通话清晰"`. Pour le clonage, utilisez le modèle `mimo-v2.5-tts-voiceclone` et définissez voice sur `data:audio/wav;base64,<真实参考音频>`. N’envoyez pas de Base64 vide, de faux format de fichier ou de voix d’un tiers sans autorisation.

```python
import base64
import os
from pathlib import Path
import requests
reference = base64.b64encode(Path("reference.wav").read_bytes()).decode("ascii")
response = requests.post("http://127.0.0.1:8080/v1/audio/speech",
    headers={"Authorization": "Bearer " + os.environ["MIMO_AUDIO_API_KEY"]},
    json={"model":"mimo-v2.5-tts-voiceclone","input":"这是一条授权声音示例。",
          "voice":"data:audio/wav;base64," + reference,"response_format":"wav"}, timeout=180)
response.raise_for_status()
Path("clone.wav").write_bytes(response.content)
```

### Protocole natif officiel Xiaomi

Le TTS officiel place le texte à lire dans un message `assistant` et les consignes de style dans un message `user`. Ce JSON officiel ne doit pas être envoyé à `/audio/speech` \:

```json
{"model":"mimo-v2.5-tts","messages":[{"role":"user","content":"温暖自然"},{"role":"assistant","content":"你好，欢迎使用 MiMo。"}],"audio":{"format":"wav","voice":"mimo_default"},"stream":false}
```

L’audio officiel se trouve dans `choices[0].message.audio.data` et doit être décodé en Base64. L’ASR natif place l’audio dans `messages[0].content` \:

```json
{"model":"mimo-v2.5-asr","messages":[{"role":"user","content":[{"type":"input_audio","input_audio":{"data":"data:audio/wav;base64,<真实Base64>"}}]}],"asr_options":{"language":"auto"},"stream":false}
```

Le texte de l’ASR natif se trouve dans `choices[0].message.content`. format est facultatif si le data URL indique déjà le format ; avec du Base64 nu, précisez `format: "wav"` ou `"mp3"`. Si les deux sont fournis, ils doivent correspondre.

## Codes d’erreur

| HTTP / code                       | Signification                                                      |
| --------------------------------- | ------------------------------------------------------------------ |
| 400 / unsupported\_audio\_format  | Format de sortie TTS invalide.                                     |
| 400 / speech\_sse\_not\_supported | SSE TTS non pris en charge par le service compatible.              |
| 400 / diarization\_not\_supported | Format avec séparation des locuteurs non pris en charge par l’ASR. |
| 400 / timestamps\_not\_supported  | Granularité des horodatages ASR non prise en charge.               |
| 401 / 403                         | Clé ou autorisations du service autonome incorrectes.              |
| 404 / voice\_not\_found           | Voix personnalisée absente ou n’appartenant pas à cette clé.       |
| 413 / input\_too\_large           | Texte ou média dépassant la limite.                                |
| 415 / unsupported\_file\_type     | Extension ou MIME non pris en charge.                              |
| 422 / invalid\_audio              | Média impossible à décoder.                                        |
| 502 / invalid\_audio\_output      | Aucun audio valide renvoyé par l’amont.                            |
| 503 / audio\_failover\_exhausted  | Service audio temporairement indisponible.                         |

Le téléversement d’une voix clonée crée un état ; ne le répétez pas aveuglément après expiration.

## Références officielles

[MiMo TTS](https\://mimo.mi.com/docs/en-US/api/audio/tts), [MiMo ASR](https\://mimo.mi.com/docs/en-US/api/audio/Speech-Recognition). Ces pages décrivent le protocole natif et ne présentent pas les extensions du service compatible comme des capacités natives Xiaomi.