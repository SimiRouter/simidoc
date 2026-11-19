# Génération musicale Google Lyria

Les pages ci-dessous suivent l’API officielle Google. SimiRouter n’a pas encore ouvert cette capacité ; tous les exemples se connectent directement à l’API Gemini de Google AI Studio avec `https://generativelanguage.googleapis.com` et une clé API Google. Vertex AI exige un protocole distinct, non vérifié sur cette page ; ne remplacez pas directement l’adresse.

## Description de l’interface

`POST https://generativelanguage.googleapis.com/v1beta/interactions`, authentifiée avec `x-goog-api-key: $GEMINI_API_KEY`. Lyria utilise Interactions, pas generateContent ni `/audio/speech`.

| Modèle                 | Utilité                                 | Durée et sortie                                                                    |
| ---------------------- | --------------------------------------- | ---------------------------------------------------------------------------------- |
| `lyria-3-clip-preview` | Extraits, boucles et écoute rapide      | 30 secondes fixes, MP3 par défaut.                                                 |
| `lyria-3.5`            | Chansons avec couplets, refrain et pont | Chanson de quelques minutes guidée par la consigne ; MP3 par défaut, WAV possible. |

## Paramètres de requête

| Champ                      | Type           | Obligatoire  | Description                                                          |
| -------------------------- | -------------- | ------------ | -------------------------------------------------------------------- |
| model                      | string         | Oui          | L’un des modèles Lyria ci-dessus.                                    |
| input                      | string / array | Oui          | Description musicale ou tableau de contenu multimodal text/image.    |
| input\[].text              | string         | Conditionnel | Genre, tempo, ambiance, instruments, paroles et structure.           |
| input\[].mime\_type / data | string         | Conditionnel | Une image utilise un élément image avec MIME réel et data en Base64. |
| response\_format           | object         | Non          | \{"type"\:"audio"} peut demander du WAV ; référez-vous au MIME réel. |

Ne considérez pas le contrôle de durée comme une garantie exacte. Décrire le style et les caractéristiques instrumentales est plus adapté à un usage sûr que demander l’imitation d’un chanteur précis.

## Valeur de retour

| Champ                                       | Description                                                                            |
| ------------------------------------------- | -------------------------------------------------------------------------------------- |
| `id` / `status`                             | Identifiant Interaction et état de traitement.                                         |
| `steps[].content[]`                         | model\_output contient audio, paroles et structure musicale ; analysez chaque élément. |
| Élément audio `type` / `mime_type` / `data` | Pour type=audio, data est du Base64, pas une URL.                                      |
| Élément texte `text`                        | Paroles, structure ou autre contenu textuel.                                           |

La propriété SDK `output_audio` / `output_text` est pratique ; pour des résultats complexes entrelacés, parcourez steps plutôt que de perdre des éléments en ne prenant que la dernière partie. Extrait de structure \:

```json
{"steps":[{"type":"model_output","content":[{"type":"text","text":"[Instrumental]"},{"type":"audio","mime_type":"audio/mpeg","data":"<Base64音频>"}]}]}
```

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Définissez `GEMINI_API_KEY`. L’exemple renvoie du JSON ; décodez data des éléments audio en MP3. Remplacez model par `lyria-3.5` pour produire une chanson complète.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/interactions'
    headers = {'x-goog-api-key': '' + os.environ['GEMINI_API_KEY'], 'Api-Revision': '2026-05-20'}
    response = requests.request('POST', url, headers=headers, json={'model': 'lyria-3-clip-preview', 'input': '30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/interactions";
      const headers = { "x-goog-api-key": "" + process.env.GEMINI_API_KEY, "Api-Revision": "2026-05-20" };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "lyria-3-clip-preview",
      "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
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
    curl "https://generativelanguage.googleapis.com/v1beta/interactions" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Api-Revision: 2026-05-20" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "lyria-3-clip-preview",
        "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
      }'
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
      "model": "lyria-3-clip-preview",
      "input": "30秒温暖的原声吉他纯音乐，轻柔节拍，不要人声。"
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/interactions", body); check(err)
      req.Header.Set("x-goog-api-key", "" + os.Getenv("GEMINI_API_KEY"))
      req.Header.Set("Api-Revision", "2026-05-20")
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

Les objets d’erreur Google utilisent `error.code`, `error.status` et `error.message` ; ne déduisez pas la source du seul code HTTP. Ce point d’accès est synchrone \: il n’y a ni identifiant de tâche ni phase d’interrogation. Ne décodez jamais le texte d’erreur comme des données audio.

## Références officielles

[Génération musicale Google Lyria](https\://ai.google.dev/gemini-api/docs/music-generation), [Interactions](https\://ai.google.dev/gemini-api/docs/interactions).