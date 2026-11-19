# Reclassement de documents

## Description de l’interface

Le reclassement compare query à une liste de documents candidats et renvoie index et scores classés par pertinence. Il ne génère pas de réponse ni de vecteurs d’embedding. La disponibilité de `/v1/rerank` dans SimiRouter dépend du canal ; les exemples utilisent uniquement **Cohere officiel** `POST https://api.cohere.com/v2/rerank`. Authentification \: `Authorization: Bearer $COHERE_API_KEY`.

## Paramètres de requête

| Champ                 | Type      | Obligatoire | Description                                                                                                                                                                  |
| --------------------- | --------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                 | string    | Oui         | Par exemple rerank-v5.0-pro ; utilisez un modèle activé pour le compte.                                                                                                      |
| query                 | string    | Oui         | Requête de recherche.                                                                                                                                                        |
| documents             | string\[] | Oui         | Tableau de textes candidats ; le fournisseur recommande au maximum 1000 éléments par requête. Les contenus structurés peuvent être préalablement sérialisés en chaînes YAML. |
| top\_n                | integer   | Non         | Au moins 1 ; si omis, tous les résultats sont renvoyés.                                                                                                                      |
| max\_tokens\_per\_doc | integer   | Non         | 4096 par défaut ; les longs documents sont tronqués.                                                                                                                         |
| relevant\_spans       | object    | Non         | Les modèles v5 et ultérieurs peuvent renvoyer des passages pertinents.                                                                                                       |
| priority              | integer   | Non         | 0–999, défaut 0 ; une valeur plus petite indique une priorité plus élevée.                                                                                                   |

En v2 Cohere, documents est un tableau de chaînes \: n’y ajoutez pas d’objets non définis ; `return_documents` appartient à d’autres versions du protocole et n’est pas envoyé ici.

## Valeur de retour

`results[]` est classé par pertinence \: `index` désigne l’index du document original et `relevance_score` son score de pertinence ; si activé et pris en charge, `relevant_spans[]` est renvoyé. Ce score n’est ni un taux d’exactitude ni une probabilité universelle comparable entre modèles. `meta.billed_units` enregistre l’utilisation.

```json
{"results":[{"index":1,"relevance_score":0.95},{"index":0,"relevance_score":0.12}],"id":"request_example","meta":{"api_version":{"version":"2"}}}
```

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Définissez la variable officielle Cohere `COHERE_API_KEY`. L’exemple utilise top\_n positif, sans query ni document vide.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.cohere.com/v2/rerank'
    headers = {'Authorization': 'Bearer ' + os.environ['COHERE_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'rerank-v5.0-pro', 'query': '法国首都是哪里？', 'documents': ['柏林是德国首都。', '巴黎是法国首都。'], 'top_n': 2}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.cohere.com/v2/rerank";
      const headers = { "Authorization": "Bearer " + process.env.COHERE_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
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
    curl "https://api.cohere.com/v2/rerank" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $COHERE_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "rerank-v5.0-pro",
        "query": "法国首都是哪里？",
        "documents": [
          "柏林是德国首都。",
          "巴黎是法国首都。"
        ],
        "top_n": 2
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
      "model": "rerank-v5.0-pro",
      "query": "法国首都是哪里？",
      "documents": [
        "柏林是德国首都。",
        "巴黎是法国首都。"
      ],
      "top_n": 2
    }`)
      req, err := http.NewRequest("POST", "https://api.cohere.com/v2/rerank", body); check(err)
      req.Header.Set("Authorization", "Bearer " + os.Getenv("COHERE_API_KEY"))
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

| Statut HTTP           | Description                                                                               |
| --------------------- | ----------------------------------------------------------------------------------------- |
| 400 / 422             | Paramètres ou entrée refusés par le modèle.                                               |
| 401 / 498             | Échec d’authentification ou token invalide.                                               |
| 403 / 404             | Autorisations insuffisantes ou ressource introuvable.                                     |
| 429                   | Limitation de débit ; vérifiez les quotas et utilisez une attente progressive bornée.     |
| 499                   | Le client a fermé la requête.                                                             |
| 500 / 501 / 503 / 504 | Erreur interne, fonctionnalité non implémentée ou expiration ; conservez l’ID de requête. |

## Références officielles

[Cohere Rerank v2](https\://docs.cohere.com/reference/rerank).