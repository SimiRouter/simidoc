# Télécharger le contenu Sora (interface officielle fermée)

**Sora 2 et Videos API officiels OpenAI ont fermé le 24 septembre 2026.** La structure ci-dessous est conservée à titre de référence, pas comme guide utilisable. Si SimiRouter propose des modèles homonymes ou une implémentation tierce compatible, confirmez séparément origine, capacités et protocole ; ce n’est pas l’accès direct officiel OpenAI.

## Description de l’interface

`GET https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content` était la forme de requête officielle avec une clé Bearer OpenAI ; n’envoyez plus de nouvelles requêtes de production.

## Paramètres de requête

| Champ              | Type   | Obligatoire | Description                                                          |
| ------------------ | ------ | ----------- | -------------------------------------------------------------------- |
| video\_id (chemin) | string | Oui         | Ancien ID de création de tâche.                                      |
| variant (query)    | string | Non         | Anciens types de contenu, notamment video, thumbnail et spritesheet. |

## Valeur de retour

L’ancienne réponse réussie était du binaire MP4, etc., pas un JSON d’URL ; aucun téléchargement avant la fin. Ce service officiel de contenu est maintenant fermé.

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

**Exemple archivé, ne prouvant pas que l’interface fonctionne encore.** Exemples destinés à comprendre l’ancienne structure HTTP ; n’utilisez pas de vraie clé pour tester de nouvelles tâches.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests
    from pathlib import Path

    url = 'https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('GET', url, headers=headers, timeout=180)
    response.raise_for_status()
    Path('video.mp4').write_bytes(response.content)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      const response = await fetch(url, { method: "GET", headers, signal: AbortSignal.timeout(180000) });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      const { writeFile } = require("node:fs/promises");
      await writeFile("video.mp4", Buffer.from(await response.arrayBuffer()));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    [ ! -e "video.mp4" ] || { printf '%s\n' "目标文件已存在：video.mp4" >&2; exit 1; }
    temporary=$(mktemp)
    trap 'rm -f "$temporary"' EXIT
    if curl --fail-with-body --max-time 180 -X GET "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      --output "$temporary"; then
      mv "$temporary" "video.mp4"
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
    )

    func check(err error) { if err != nil { panic(err) } }
    func main() {
        req, err := http.NewRequest("GET", "https://api.openai.com/v1/videos/REPLACE_WITH_VIDEO_ID/content", nil); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("OPENAI_API_KEY"))
      client := &http.Client{Timeout: 180 * time.Second}
      res, err := client.Do(req); check(err)
      defer res.Body.Close()
      data, err := io.ReadAll(res.Body); check(err)
      if res.StatusCode < 200 || res.StatusCode >= 300 { panic(fmt.Sprintf("HTTP %d: %s", res.StatusCode, data)) }
      check(os.WriteFile("video.mp4", data, 0600))
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

Après fermeture, aucune réponse réussie ne peut être promise. L’ancien protocole distinguait authentification/permissions avec HTTP 401/403, absence avec 404 et limitation avec 429 ; les échecs de génération contenaient aussi error.code/message. Ne réessayez pas indéfiniment ces points d’accès et n’enregistrez pas les erreurs comme MP4.

## Références officielles

[Avis de retrait OpenAI](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create).