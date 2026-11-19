# Complétion de texte classique

## Description de l’interface

`POST /v1/completions` reçoit prompt et renvoie le texte complété, sans messages, appels d’outils ni éléments de sortie Responses. C’est une interface classique ; préférez Chat Completions ou Responses pour les nouveaux projets. Seuls les modèles acceptant ce protocole peuvent l’utiliser ; n’insérez pas l’ID d’un modèle de conversation quelconque.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $SIMIROUTER_API_KEY`. L’API directe officielle OpenAI est `https://api.openai.com`. Authentification \: Bearer avec une clé OpenAI. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

## Démarrage rapide

1. **Préparer la configuration** \: créez une clé dans Gestion des clés API et copiez depuis Modèles et prix un ID de modèle complet compatible avec les complétions héritées.
2. **Envoyer une requête minimale** \: soumettez un seul `prompt` et laissez `stream` à `false` ; vérifiez d’abord l’authentification, le modèle et les paramètres.
3. **Lire le résultat** \: la requête réussit uniquement si HTTP est 2xx et `choices[]` est non vide ; la complétion se trouve dans `choices[0].text`.
4. **Valider** \: contrôlez `finish_reason` et le contenu réel, puis vérifiez les journaux d’utilisation.

```bash
API_URL="https://api.dwchainless.com/v1/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "prompt": "请补全这句话：机器学习是",
    "max_tokens": 64,
    "stream": false
  }'
```

Remplacez `PASTE_API_KEY_HERE` et `MODEL_ID` par des valeurs réelles ; les nouveaux projets doivent préférer Chat Completions ou Responses.

## Paramètres de requête

Corps de requête JSON.

| Champ                                  | Type           | Obligatoire  | Description                                                                                                                   |
| -------------------------------------- | -------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| model                                  | string         | Oui          | ID d’un modèle acceptant la complétion classique.                                                                             |
| prompt                                 | string / array | Conditionnel | Texte à compléter ; peut aussi contenir plusieurs textes ou un tableau d’ID de tokens. L’exemple utilise une chaîne.          |
| max\_tokens                            | integer        | Non          | Nombre maximal de tokens générés ; entrée et sortie doivent respecter ensemble la fenêtre de contexte.                        |
| stream                                 | boolean        | Non          | true renvoie SSE ; false par défaut.                                                                                          |
| temperature / top\_p                   | number         | Non          | Contrôle de l’échantillonnage ; on n’ajuste généralement qu’un seul paramètre.                                                |
| n                                      | integer        | Non          | Nombre de complétions candidates par prompt.                                                                                  |
| stop                                   | string / array | Non          | Jusqu’à 4 séquences d’arrêt ; elles ne figurent pas dans le texte renvoyé.                                                    |
| echo                                   | boolean        | Non          | Inclure ou non le prompt d’entrée dans text en sortie.                                                                        |
| logprobs                               | integer        | Non          | Log-probabilités des tokens candidats, jusqu’à 5.                                                                             |
| presence\_penalty / frequency\_penalty | number         | Non          | Pénalités de répétition entre -2 et 2.                                                                                        |
| suffix                                 | string         | Non          | Uniquement pour les modèles acceptant la complétion par insertion.                                                            |
| best\_of                               | integer        | Non          | Génère plusieurs candidats côté serveur puis sélectionne le meilleur ; incompatible avec stream et augmente le volume généré. |

### Exemple de requête

```json
{
  "model": "MODEL_ID",
  "prompt": "请补全这句话：机器学习是",
  "max_tokens": 64,
  "stream": false
}
```

## Valeur de retour

| Champ                                                     | Type             | Description                                                   |
| --------------------------------------------------------- | ---------------- | ------------------------------------------------------------- |
| id / object                                               | string           | ID de complétion ; object=text\_completion.                   |
| created / model                                           | integer / string | Horodatage Unix en secondes et modèle.                        |
| choices\[].text                                           | string           | Texte complété, pas message.content.                          |
| choices\[].index                                          | integer          | Index du candidat.                                            |
| choices\[].finish\_reason                                 | string           | stop, length ou content\_filter.                              |
| choices\[].logprobs                                       | object / null    | Probabilités des tokens ; généralement null si non demandées. |
| usage.prompt\_tokens / completion\_tokens / total\_tokens | integer          | Tokens d’entrée, générés et totaux.                           |

```json
{
  "id": "cmpl_example",
  "object": "text_completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "text": "一种从数据中学习规律的方法。",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 14,
    "total_tokens": 26
  }
}
```

En streaming, concaténez choices\[].text jusqu’à `[DONE]` ; avec plusieurs prompts ou candidats, assemblez séparément selon index.

## Exemples de code

Définissez `SIMIROUTER_API_KEY`, `SIMIROUTER_COMPLETION_MODEL` ; `SIMIROUTER_BASE_URL` permet de remplacer l’adresse de la passerelle par défaut ; n’y ajoutez pas `/v1`. Les exemples Python 3, Node.js 18+ et Go utilisent uniquement la bibliothèque standard. L’exemple curl fait encoder le JSON de façon sûre par Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_COMPLETION_MODEL"): raise RuntimeError("请设置 SIMIROUTER_COMPLETION_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    path = '/v1/completions'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
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
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_COMPLETION_MODEL)
        throw new Error('请设置 SIMIROUTER_COMPLETION_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        prompt: '请补全这句话：机器学习是',
        max_tokens: 64,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_COMPLETION_MODEL;
      const endpoint = '/v1/completions';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000),
      });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_COMPLETION_MODEL:?请设置 SIMIROUTER_COMPLETION_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/completions" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "bytes"
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_COMPLETION_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_COMPLETION_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/completions"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
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

Les erreurs natives OpenAI contiennent généralement `error.message`, `error.type`, `error.param`, `error.code` ; `param`, `code` peuvent être `null` ; ne supposez pas que ces champs existent toujours ou correspondent au code HTTP. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont.

Les réponses longues et les requêtes en streaming peuvent durer de plusieurs dizaines de secondes à plusieurs minutes ; configurez un délai d’attente suffisant et, en cas de coupure, jugez à partir des deltas reçus et du motif d’arrêt plutôt que de renvoyer automatiquement. Pour 429 et 5xx, examinez d’abord le corps de la réponse et les journaux d’utilisation ; en cas de refus par la politique de contenu, modifiez le prompt ou l’entrée au lieu de réessayer à l’identique.

## Références officielles

* [OpenAI Completions API](https\://developers.openai.com/api/reference/resources/completions/methods/create)
* [Gestion des erreurs OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)