# Liste des modèles au format Gemini

## Description de l’interface

`GET /v1beta/models` renvoie une liste de modèles au format Gemini.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $SIMIROUTER_API_KEY`. L’API directe officielle Google est `https://generativelanguage.googleapis.com`. Authentification \: généralement `x-goog-api-key: $GEMINI_API_KEY`, pas la clé Bearer de la passerelle. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

La liste de la passerelle sert principalement à découvrir les noms ; elle ne constitue pas le catalogue natif complet des capacités Google.

## Paramètres de requête

La requête de passerelle n’a pas de corps et n’exige pas de pagination. models.list natif Google accepte pageSize (50 par défaut, maximum 1000) et pageToken ; la passerelle actuelle renvoie une liste complète, sans garanties équivalentes de pagination ou de métadonnées.

| Champ                | Type                   | Obligatoire         | Description                                                                                                |
| -------------------- | ---------------------- | ------------------- | ---------------------------------------------------------------------------------------------------------- |
| Authorization        | header string          | Oui                 | Clé Bearer de passerelle ; remplacez-la par une clé Google pour l’accès officiel direct.                   |
| pageSize / pageToken | query integer / string | Facultatif en natif | Pagination des seules requêtes officielles natives ; ne comptez pas sur leur traitement par la passerelle. |

## Valeur de retour

| Champ                                        | Type           | Description                                                                                                          |
| -------------------------------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------- |
| models                                       | array          | Liste de modèles, éventuellement vide.                                                                               |
| models\[].name                               | string         | Nom de ressource ; généralement models/\{id} chez le fournisseur, mais la passerelle peut renvoyer directement l’ID. |
| models\[].displayName                        | string         | Nom lisible.                                                                                                         |
| nextPageToken                                | string / null  | Jeton officiel de page suivante ; la passerelle peut renvoyer null pour indiquer l’absence de pagination.            |
| models\[].version / description              | string / null  | Version et description officielles éventuelles ; peuvent être absentes ou null dans la liste de passerelle.          |
| models\[].inputTokenLimit / outputTokenLimit | integer / null | Limites d’entrée et de sortie officielles éventuelles ; ne rien déduire de leur absence.                             |
| models\[].supportedGenerationMethods         | array / null   | Méthodes officielles éventuelles comme generateContent ; peuvent être absentes ou null dans la liste de passerelle.  |

```json
{
  "models": [
    {
      "name": "MODEL_ID",
      "displayName": "MODEL_ID"
    }
  ],
  "nextPageToken": null
}
```

La structure simplifiée de la passerelle est illustrée ci-dessus. Avant d’utiliser name dans le chemin, supprimez une seule occurrence initiale de models/. Même si models.list réussit, generateContent peut ensuite échouer pour des raisons d’autorisation, de capacité ou de quota.

## Exemples de code

Définissez `SIMIROUTER_API_KEY`. Pour remplacer l’adresse racine par défaut de la passerelle, définissez `SIMIROUTER_BASE_URL` sans suffixe de version. Tous les exemples envoient une requête GET sans corps.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1beta/models'
    request = urllib.request.Request(base + path, method="GET",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const endpoint = "/v1beta/models";
      const response = await fetch(base + endpoint, { method: "GET",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    curl "${BASE_URL%/}/v1beta/models" \
      --fail-with-body \
      --max-time 120 \
      -X GET \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      endpoint := "/v1beta/models"
      req, err := http.NewRequest("GET", base + endpoint, nil); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Codes d’erreur

| Statut HTTP | Signification ou type d’erreur du fournisseur | Traitement                                                                                                                                 |
| ----------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 400         | `INVALID_ARGUMENT`, etc.                      | Vérifiez le JSON, les paramètres du modèle, le MIME et la longueur des entrées.                                                            |
| 403         | `PERMISSION_DENIED`                           | Vérifiez la clé, les autorisations du projet, la région et les restrictions de facturation.                                                |
| 404         | `NOT_FOUND`                                   | Vérifiez le nom du modèle et la version de l’API.                                                                                          |
| 429         | `RESOURCE_EXHAUSTED`                          | Vérifiez les limites de débit et quotas ; pour les erreurs récupérables, utilisez un nombre limité de tentatives avec attente progressive. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`                    | Conservez l’identifiant de requête ; réessayez un nombre limité de fois ou ultérieurement.                                                 |

L’objet d’erreur natif Google contient `error.code` (code HTTP numérique), `error.status` (nom de l’énumération), `error.message` et éventuellement `details`. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont. Une recherche interne peut aussi renvoyer HTTP 200 avec success=false ; vérifiez donc la structure.

## Références officielles

* [Google Models API](https\://ai.google.dev/api/models)
* [Catalogue des modèles Google](https\://ai.google.dev/gemini-api/docs/models)
* [Dépannage Google](https\://ai.google.dev/gemini-api/docs/troubleshooting)