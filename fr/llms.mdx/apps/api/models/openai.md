# Liste des modèles au format OpenAI

## Description de l’interface

`GET /v1/models` renvoie les modèles visibles avec la clé courante. La liste peut alimenter un sélecteur de configuration, mais ne prouve ni toutes les modalités et outils ni le crédit disponible ou la disponibilité en temps réel.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $SIMIROUTER_API_KEY`. L’API directe officielle OpenAI est `https://api.openai.com`. Authentification \: Bearer avec une clé OpenAI. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

Envoyez uniquement l’authentification Bearer, sans x-api-key ou x-goog-api-key, pour éviter de déclencher un autre format de réponse de la passerelle.

## Paramètres de requête

Cette requête de liste n’a ni corps JSON ni paramètre de consultation obligatoire.

| Champ         | Type          | Obligatoire | Description                     |
| ------------- | ------------- | ----------- | ------------------------------- |
| Authorization | header string | Oui         | Clé de passerelle après Bearer. |

## Valeur de retour

| Champ                             | Type                   | Description                                                                                                                                                                                        |
| --------------------------------- | ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| object                            | string                 | list.                                                                                                                                                                                              |
| data                              | array                  | Liste des modèles, éventuellement vide.                                                                                                                                                            |
| data\[].id                        | string                 | ID du modèle à utiliser pour la génération.                                                                                                                                                        |
| data\[].object                    | string                 | model.                                                                                                                                                                                             |
| data\[].created                   | integer                | Horodatage Unix en secondes ; les métadonnées de passerelle ne correspondent pas forcément à la date de publication du modèle.                                                                     |
| data\[].owned\_by                 | string                 | Étiquette de propriétaire ; elle ne prouve pas le fournisseur vers lequel la requête est réellement routée.                                                                                        |
| success                           | boolean                | Indicateur métier facultatif ajouté par la passerelle ; ce n’est pas un champ standard OpenAI.                                                                                                     |
| `data[].context_length`           | integer                | Longueur de contexte en tokens indiquée par la passerelle. Sans configuration, la valeur par défaut de la plateforme s’applique. Vérifiez la documentation du modèle et les limites de l’endpoint. |
| `data[].supported_endpoint_types` | `array<string>` / null | Types d’endpoints indiqués par la passerelle pour orienter le choix de l’endpoint.                                                                                                                 |

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

Un tableau vide est valide ; n’accédez pas directement à data\[0]. Si la recherche du groupe utilisateur échoue, la passerelle peut renvoyer HTTP 200 avec success=false/message ; le client doit détecter cet échec métier. OpenAI officiel propose aussi GET /v1/models/\{model} pour un modèle ; les métadonnées de liste ne décrivent pas toutes ses capacités.

## Exemples de code

Définissez `SIMIROUTER_API_KEY`. Pour remplacer l’adresse racine par défaut de la passerelle, définissez `SIMIROUTER_BASE_URL` sans suffixe de version. Tous les exemples envoient une requête GET sans corps.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1/models'
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
      const endpoint = "/v1/models";
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
    curl "${BASE_URL%/}/v1/models" \
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
      endpoint := "/v1/models"
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

| Statut HTTP | Signification ou type d’erreur du fournisseur  | Traitement                                                                                                                       |
| ----------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 400         | Requête invalide                               | Vérifiez les champs obligatoires, le JSON, les paramètres du modèle et la longueur du contexte.                                  |
| 401         | Échec de l’authentification                    | Vérifiez que la clé est présente, valide et rattachée au bon compte.                                                             |
| 403 / 404   | Accès interdit / ressource introuvable         | Vérifiez les autorisations du modèle, l’ID de ressource et l’URL.                                                                |
| 429         | Limite de débit ou de quota                    | Distinguez limitation de débit et crédit insuffisant à l’aide du corps de réponse ; réessayer ne résout pas un manque de crédit. |
| 500 / 503   | Erreur de service / indisponibilité temporaire | Conservez l’identifiant de requête et limitez les nouvelles tentatives avec attente progressive aux erreurs temporaires.         |

Les erreurs natives OpenAI contiennent généralement `error.message`, `error.type`, `error.param`, `error.code` ; `param`, `code` peuvent être `null` ; ne supposez pas que ces champs existent toujours ou correspondent au code HTTP. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont. Vérifiez aussi les échecs métier success=false, distincts de la réussite du transport HTTP.

## Références officielles

* [OpenAI List models](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [OpenAI Retrieve model](https\://developers.openai.com/api/reference/resources/models/methods/retrieve)
* [Gestion des erreurs OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)