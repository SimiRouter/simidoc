# Embeddings Gemini

**SimiRouter ne prend pas encore en charge cette interface. Référence de l’accès direct officiel Google ci-dessous.** Les exemples utilisent une clé Gemini API issue de Google AI Studio. Pour les chemins de requête, la configuration du projet et l’authentification Vertex AI, suivez la documentation Google Cloud.

## Description de l’interface

`POST https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent`. Authentification \: `x-goog-api-key: $GEMINI_API_KEY`. L’exemple utilise du texte ; Gemini Embedding 2 peut aussi traiter les contenus multimodaux acceptés par le modèle, sans étendre ces capacités aux anciens modèles textuels.

## Paramètres de requête

| Champ                                   | Type      | Obligatoire | Description                                                                        |
| --------------------------------------- | --------- | ----------- | ---------------------------------------------------------------------------------- |
| model (chemin)                          | string    | Oui         | models/gemini-embedding-2 ; doit être un modèle d’embedding disponible.            |
| content                                 | object    | Oui         | Objet Content à encoder, avec le texte dans parts\[].text.                         |
| content.parts                           | object\[] | Oui         | Élément textuel ou multimodal inline\_data / file\_data accepté par ce modèle.     |
| embedContentConfig                      | object    | Non         | Configuration d’embedding ; options selon la version du modèle et l’API Reference. |
| embedContentConfig.outputDimensionality | integer   | Non         | Dimension de sortie acceptée ; identique côté index et requête.                    |

`gemini-embedding-2` n’accepte pas `embedContentConfig.taskType` ni `title`. Pour la recherche, utilisez des préfixes dans le texte \:

* Requête \: `task: search result | query: {content}`
* Document \: `title: {title} | text: {content}` ; sans titre, utilisez `title: none`
* Tâche symétrique \: `task: {task} | query: {content}`

`taskType` et `title` ne s’appliquent qu’à `gemini-embedding-001`. `gemini-embedding-2` ne prend pas en charge ces champs ; utilisez plutôt les préfixes d’entrée ci-dessus et ne dépendez pas d’un traitement non défini. Les espaces vectoriels d’embedding-2 et d’embedding-001 sont incompatibles \: l’index et la requête doivent utiliser le même modèle.

Les champs de premier niveau `taskType`, `title`, `outputDimensionality` sont d’anciennes configurations ; le SDK utilise un objet config, sans mélanger snake\_case et camelCase JSON.

## Valeur de retour

Un appel synchrone renvoie `embedding.values`, un tableau de nombres flottants. `batchEmbedContents` reçoit un tableau requests et renvoie `embeddings[]` dans l’ordre des entrées. L’API asynchrone `asyncBatchEmbedContent` renvoie une ressource de tâche longue dont il faut gérer état et fichiers de sortie ; ce n’est pas la requête synchrone de cette page.

```json
{"embedding":{"values":[0.01,-0.02,0.03]}}
```

Le vecteur montré est un extrait. Si vous réduisez la dimension, suivez les consignes de normalisation du modèle ; les trois premières composantes ne constituent pas le vecteur complet.

## Exemples de code

L’exemple Python nécessite `python3 -m pip install requests` ; Node.js 18+ utilise fetch intégré et Go sa bibliothèque standard.

Définissez d’abord `GEMINI_API_KEY`.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import os
    import requests

    url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent'
    headers = {'x-goog-api-key': os.environ['GEMINI_API_KEY']}
    response = requests.request('POST', url, headers=headers, json={'model': 'models/gemini-embedding-2', 'content': {'parts': [{'text': 'task: search result | query: 如何让文档检索理解语义？'}]}}, timeout=180)
    response.raise_for_status()
    print(response.text)
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent";
      const headers = { "x-goog-api-key": process.env.GEMINI_API_KEY };
      headers["Content-Type"] = "application/json";
      const body = JSON.stringify({
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
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
    curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent" \
      --fail-with-body \
      --max-time 180 \
      -X POST \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "models/gemini-embedding-2",
        "content": {
          "parts": [
            {
              "text": "task: search result | query: 如何让文档检索理解语义？"
            }
          ]
        }
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
      "model": "models/gemini-embedding-2",
      "content": {
        "parts": [
          {
            "text": "task: search result | query: 如何让文档检索理解语义？"
          }
        ]
      }
    }`)
      req, err := http.NewRequest("POST", "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-2:embedContent", body); check(err)
      req.Header.Set("x-goog-api-key", os.Getenv("GEMINI_API_KEY"))
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

Les objets d’erreur Google utilisent `error.code`, `error.status` et `error.message` ; ne déduisez pas la source du seul code HTTP. Ce point d’accès est synchrone \: il n’y a ni identifiant de tâche ni phase d’interrogation. Ne traitez jamais le texte d’erreur comme un résultat d’embedding.

## Références officielles

[Google Embeddings guide](https\://ai.google.dev/gemini-api/docs/embeddings), [Embedding API](https\://ai.google.dev/api/embeddings).