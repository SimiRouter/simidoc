# Créer une vidéo Sora (interface officielle fermée)

**Sora 2 et Videos API officiels OpenAI ont fermé le 24 septembre 2026.** La structure ci-dessous est conservée à titre de référence, pas comme guide utilisable. Si SimiRouter propose des modèles homonymes ou une implémentation tierce compatible, confirmez séparément origine, capacités et protocole ; ce n’est pas l’accès direct officiel OpenAI.

## Description de l’interface

`POST https://api.openai.com/v1/videos` était la forme de requête officielle avec une clé Bearer OpenAI ; n’envoyez plus de nouvelles requêtes de production.

## Paramètres de requête

| Champ            | Type   | Obligatoire | Description                                                                     |
| ---------------- | ------ | ----------- | ------------------------------------------------------------------------------- |
| prompt           | string | Oui         | Description textuelle de la vidéo.                                              |
| model            | string | Non         | Anciens modèles sora-2 / sora-2-pro, désormais fermés.                          |
| seconds          | string | Non         | Durées anciennement acceptées, par exemple 4, 8 ou 12 ; référence de structure. |
| size             | string | Non         | Anciennes résolutions, par exemple 1280x720.                                    |
| input\_reference | object | Non         | Objet de référence, au choix image\_url ou file\_id.                            |

## Valeur de retour

L’ancienne création renvoyait un objet vidéo \: id, object, status, progress, model, created\_at, seconds et size. status=queued / in\_progress ne signifie pas terminé.

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

**Exemple archivé, ne prouvant pas que l’interface fonctionne encore.** Exemples destinés à comprendre l’ancienne structure HTTP ; n’utilisez pas de vraie clé pour tester de nouvelles tâches.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/videos'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'sora-2', 'prompt': '海边日落，平稳镜头。', 'seconds': '4', 'size': '1280x720'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "sora-2",
      "prompt": "海边日落，平稳镜头。",
      "seconds": "4",
      "size": "1280x720"
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
    curl "https://api.openai.com/v1/videos" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "sora-2",
        "prompt": "海边日落，平稳镜头。",
        "seconds": "4",
        "size": "1280x720"
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
      "model": "sora-2",
      "prompt": "海边日落，平稳镜头。",
      "seconds": "4",
      "size": "1280x720"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/videos", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
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

Après fermeture, aucune réponse réussie ne peut être promise. L’ancien protocole distinguait authentification/permissions avec HTTP 401/403, absence avec 404 et limitation avec 429 ; les échecs de génération contenaient aussi error.code/message. Ne réessayez pas indéfiniment ces points d’accès et n’enregistrez pas les erreurs comme MP4.

## Références officielles

[Avis de retrait OpenAI](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create).