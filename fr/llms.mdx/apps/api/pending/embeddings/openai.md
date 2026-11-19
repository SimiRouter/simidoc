# Embeddings OpenAI

**SimiRouter ne prend pas encore en charge cette interface. Référence de l’accès direct officiel OpenAI ci-dessous.**

## Description de l’interface

`POST https://api.openai.com/v1/embeddings`, `Content-Type: application/json`, `Authorization: Bearer $OPENAI_API_KEY`. Une requête renvoie les vecteurs complets, sans SSE.

## Paramètres de requête

| Champ            | Type                                   | Obligatoire | Description                                                                                                      |
| ---------------- | -------------------------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------- |
| model            | string                                 | Oui         | text-embedding-3-small, text-embedding-3-large ou autre modèle d’embedding accessible au compte.                 |
| input            | string / string\[] / tableau de tokens | Oui         | Texte ou tokens non vides ; 2048 éléments maximum, 8192 tokens par entrée et 300000 tokens au total par requête. |
| dimensions       | integer                                | Non         | Entier positif ; permet de réduire la dimension pour text-embedding-3 et les modèles ultérieurs compatibles.     |
| encoding\_format | string                                 | Non         | float (défaut) renvoie un tableau de flottants ; base64 une chaîne encodée.                                      |
| user             | string                                 | Non         | Identifiant d’utilisateur final sans données personnelles en clair.                                              |

## Valeur de retour

| Champ                                        | Description                                                |
| -------------------------------------------- | ---------------------------------------------------------- |
| `object`                                     | list.                                                      |
| `data[].object`                              | embedding.                                                 |
| `data[].index`                               | Position correspondante dans le tableau d’entrée.          |
| `data[].embedding`                           | Tableau vectoriel ou chaîne Base64 selon encoding\_format. |
| `model`                                      | Modèle utilisé.                                            |
| `usage.prompt_tokens` / `usage.total_tokens` | Statistiques de tokens.                                    |

Les éléments centraux du vecteur sont omis ; seule la structure est illustrée \:

```json
{"object":"list","data":[{"object":"embedding","index":0,"embedding":[0.01,-0.02]}],"model":"text-embedding-3-small","usage":{"prompt_tokens":3,"total_tokens":3}}
```

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Définissez `OPENAI_API_KEY`. L’exemple envoie un lot synchrone ; index associe les résultats aux deux entrées.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://api.openai.com/v1/embeddings'
    headers = {'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'text-embedding-3-small', 'input': ['语义搜索', '文档检索'], 'encoding_format': 'float'}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://api.openai.com/v1/embeddings";
      const headers = { "Authorization": "Bearer " + process.env.OPENAI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
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
    curl "https://api.openai.com/v1/embeddings" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "text-embedding-3-small",
        "input": [
          "语义搜索",
          "文档检索"
        ],
        "encoding_format": "float"
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
      "model": "text-embedding-3-small",
      "input": [
        "语义搜索",
        "文档检索"
      ],
      "encoding_format": "float"
    }`)
      req, err := http.NewRequest("POST", "https://api.openai.com/v1/embeddings", body); check(err)
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

| Statut HTTP           | Sens et traitement                                                                                                                                 |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 400                   | Champs de requête ou paramètres de modèle invalides ; corrigez avant de soumettre.                                                                 |
| 401                   | Clé API absente, invalide ou expirée.                                                                                                              |
| 403                   | Projet ou modèle non autorisé.                                                                                                                     |
| 404                   | Modèle ou route introuvable ; vérifiez l’adresse et l’identifiant du modèle.                                                                       |
| 429                   | Limite de débit ou de quota ; distinguez le manque de crédit d’une limitation temporaire.                                                          |
| 500 / 502 / 503 / 504 | Erreur du service ou de l’amont. Conservez l’ID de requête et patientez avant de réessayer ; ne relancez pas indéfiniment la même requête payante. |

Les champs `error.message`, `error.type` et `error.code` du corps d’erreur précisent la cause mieux que le statut HTTP. Ce point d’accès est synchrone \: il n’y a ni identifiant de tâche ni phase d’interrogation. Ne traitez jamais le texte d’erreur comme un résultat d’embedding.

## Références officielles

[OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings/methods/create), [Embeddings guide](https\://developers.openai.com/api/docs/guides/embeddings).