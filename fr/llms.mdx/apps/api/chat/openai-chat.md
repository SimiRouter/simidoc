# Chat Completions

## Description de l’interface

`POST /v1/chat/completions` génère une réponse de l’assistant à partir de l’historique. Convient aux clients Chat Completions existants et aux conversations sans état.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $SIMIROUTER_API_KEY`. L’API directe officielle OpenAI est `https://api.openai.com`. Authentification \: Bearer avec une clé OpenAI. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

## Démarrage rapide

1. **Préparer la configuration** \: créez une clé dans Gestion des clés API et copiez depuis Modèles et prix un ID de modèle complet compatible avec Chat Completions.
2. **Envoyer une requête minimale** \: soumettez un seul message utilisateur et laissez `stream` à `false` ; vérifiez d’abord l’authentification, le modèle et les paramètres.
3. **Lire le résultat** \: la requête réussit uniquement si HTTP est 2xx et `choices[]` est non vide ; le texte se trouve dans `choices[0].message.content`.
4. **Valider** \: contrôlez `finish_reason`, les refus et le contenu réel, puis vérifiez les journaux d’utilisation.

```bash
API_URL="https://api.dwchainless.com/v1/chat/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

Remplacez `PASTE_API_KEY_HERE` et `MODEL_ID` par des valeurs réelles ; une fois validé, ajoutez l’historique multi-tours ou des outils, ou activez le streaming.

Si le projet utilise déjà le SDK OpenAI, pointez `baseURL` vers `https://api.dwchainless.com/v1` et utilisez une clé SimiRouter ; les noms de méthodes et les paramètres restent inchangés. Voir [Scripts d’appel API](/simidoc/fr/apps/api-script).

## Paramètres de requête

Le type de contenu est `application/json`. Omettez les champs facultatifs inutilisés ; n’envoyez pas systématiquement des chaînes vides, des 0, des objets vides ou null.

| Champ                                  | Type                     | Obligatoire  | Description                                                                                                                                  |
| -------------------------------------- | ------------------------ | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| model                                  | string                   | Oui          | ID du modèle.                                                                                                                                |
| messages                               | array                    | Oui          | Au moins un message ; l’appelant transmet l’historique nécessaire dans l’ordre.                                                              |
| messages\[].role                       | string                   | Oui          | `developer`, `system`, `user`, `assistant`, `tool` ; les rôles disponibles varient selon le modèle.                                          |
| messages\[].content                    | string / array / null    | Conditionnel | Texte ou tableau de contenu d’un message ordinaire ; un message assistant contenant `tool_calls` peut omettre ce champ ou le définir à null. |
| messages\[].content\[].type            | string                   | Conditionnel | Type de contenu \: `text`, `image_url`, `input_audio` ou `file`.                                                                             |
| messages\[].content\[].text            | string                   | Conditionnel | Texte lorsque type=text.                                                                                                                     |
| messages\[].content\[].image\_url      | object                   | Conditionnel | Lorsque type=image\_url, fournir `url` et éventuellement `detail` ; voir Compréhension d’images.                                             |
| messages\[].tool\_calls                | array                    | Non          | Appels de fonctions demandés par l’assistant ; chacun contient id, type=function, function.name et function.arguments.                       |
| messages\[].tool\_call\_id             | string                   | Conditionnel | Obligatoire avec role=tool ; correspond à l’ID d’appel d’outil fourni par l’assistant.                                                       |
| max\_completion\_tokens                | integer                  | Non          | Limite de tokens générés, comprenant sortie visible et tokens de raisonnement.                                                               |
| stream                                 | boolean                  | Non          | true renvoie du SSE ; sans streaming par défaut.                                                                                             |
| stream\_options.include\_usage         | boolean                  | Non          | Demande un bloc récapitulatif usage avant la fin du flux ; nécessite également stream.                                                       |
| temperature / top\_p                   | number                   | Non          | Paramètres d’échantillonnage, uniquement si le modèle choisi les accepte ; on n’en ajuste généralement qu’un seul.                           |
| stop                                   | string / array           | Non          | Séquences d’arrêt, prises en charge par certains modèles seulement.                                                                          |
| n                                      | integer                  | Non          | Nombre de réponses candidates, pas de requêtes simultanées.                                                                                  |
| tools / tool\_choice                   | array / string or object | Non          | Définitions de fonctions et choix des appels ; voir Appels d’outils.                                                                         |
| parallel\_tool\_calls                  | boolean                  | Non          | Autorise plusieurs appels de fonctions dans une réponse, sans les exécuter à la place de l’application.                                      |
| response\_format                       | object                   | Non          | Configuration de sortie structurée ; json\_schema ou json\_object si pris en charge.                                                         |
| reasoning\_effort                      | string                   | Non          | Effort de raisonnement ; les valeurs possibles dépendent du modèle et ne sont pas universelles.                                              |
| presence\_penalty / frequency\_penalty | number                   | Non          | Pénalités de répétition de -2 à 2, si le modèle les accepte.                                                                                 |
| logprobs / top\_logprobs               | boolean / integer        | Non          | Probabilités des tokens de sortie et nombre de candidats, si le modèle les accepte.                                                          |

`max_tokens` est un ancien paramètre, remplacé par `max_completion_tokens` ; les modèles non o-series peuvent encore l’accepter, tandis que `/v1/completions` n’utilise que `max_tokens`. Les nouvelles intégrations ne doivent pas envoyer les deux. `video_url`, `reasoning_content` sont des extensions de certains modèles compatibles, pas des champs standard généraux de Chat Completions OpenAI.

### Exemple de requête

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释什么是机器学习。"
    }
  ],
  "max_completion_tokens": 256,
  "stream": false
}
```

## Valeur de retour

Une réponse réussie sans streaming est un JSON HTTP 200. La structure ci-dessous est illustrative ; les ID et nombres de tokens sont donnés à titre d’exemple.

| Champ                          | Type             | Description                                                                                                              |
| ------------------------------ | ---------------- | ------------------------------------------------------------------------------------------------------------------------ |
| id / object                    | string           | ID de réponse ; object=chat.completion.                                                                                  |
| created / model                | integer / string | Heure de création (secondes Unix) et modèle de réponse.                                                                  |
| choices\[]                     | array            | Liste des réponses candidates ; index indique la position de chacune.                                                    |
| choices\[].message.role        | string           | assistant.                                                                                                               |
| choices\[].message.content     | string / null    | Réponse textuelle ; peut être vide en cas d’appel d’outil ou de refus, sans signifier un échec de la requête.            |
| choices\[].message.tool\_calls | array            | Appels de fonctions à exécuter par l’application. arguments est une chaîne JSON à analyser et valider.                   |
| choices\[].message.refusal     | string / null    | Informations de refus, le cas échéant.                                                                                   |
| choices\[].finish\_reason      | string           | stop \: fin normale ; length \: limite atteinte ; tool\_calls \: passage aux outils ; content\_filter \: contenu filtré. |
| usage.prompt\_tokens           | integer          | Tokens d’entrée.                                                                                                         |
| usage.completion\_tokens       | integer          | Tokens générés, pouvant inclure les tokens de raisonnement.                                                              |
| usage.total\_tokens            | integer          | Total des tokens d’entrée et générés.                                                                                    |
| usage.\*\_tokens\_details      | object           | Détails facultatifs de l’utilisation, par exemple cached\_tokens et reasoning\_tokens.                                   |

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "机器学习是让计算机从数据中学习规律并用于预测或决策的方法。",
        "refusal": null
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 18,
    "completion_tokens": 24,
    "total_tokens": 42
  }
}
```

### Réponse en streaming

Définissez `stream: true`, recevez `text/event-stream`. Analysez le JSON de chaque ligne `data:` et, selon `choices[].index`, et fusionnez `delta.content` ; et fusionnez les arguments des fonctions par index d’outil avec `delta.tool_calls`. Le marqueur de fin est `data: [DONE]`, pas un objet JSON. Avec include\_usage, choices peut être vide dans le bloc final d’utilisation et usage peut être null dans les blocs ordinaires. Si la connexion est interrompue sans signal de fin, marquez la réponse comme incomplète plutôt que comme réussie.

```text
data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"content":"机器学习"},"finish_reason":null}]}

data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

## Exemples de code

Définissez `SIMIROUTER_API_KEY`, `SIMIROUTER_MODEL` ; `SIMIROUTER_BASE_URL` permet de remplacer l’adresse de la passerelle par défaut ; n’y ajoutez pas `/v1`. Les exemples Python 3, Node.js 18+ et Go utilisent uniquement la bibliothèque standard. L’exemple curl fait encoder le JSON de façon sûre par Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/chat/completions'
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
      if (!process.env.SIMIROUTER_API_KEY)
        throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        messages: [
          {
            role: 'user',
            content: '用一句话解释什么是机器学习。',
          },
        ],
        max_completion_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/chat/completions';
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
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/chat/completions" \
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
      model := os.Getenv("SIMIROUTER_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/chat/completions"
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

### Utiliser le SDK OpenAI

Avec le SDK officiel `openai` installé, inutile d’écrire les requêtes HTTP à la main \: pointez `baseURL` vers la passerelle pour réutiliser les types officiels, les nouvelles tentatives et l’analyse du flux. Installation \: `pip install openai` ou `npm install openai`.

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://api.dwchainless.com/v1",
    api_key=os.environ["SIMIROUTER_API_KEY"],
)
response = client.chat.completions.create(
    model=os.environ["SIMIROUTER_MODEL"],
    messages=[{"role": "user", "content": "用一句话解释什么是机器学习。"}],
)
print(response.choices[0].message.content)
```

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'https://api.dwchainless.com/v1',
  apiKey: process.env.SIMIROUTER_API_KEY,
});
const response = await client.chat.completions.create({
  model: process.env.SIMIROUTER_MODEL,
  messages: [{ role: 'user', content: '用一句话解释什么是机器学习。' }],
});
console.log(response.choices[0].message.content);
```

## Codes d’erreur

| Statut HTTP | Signification ou type d’erreur du fournisseur  | Traitement                                                                                                                       |
| ----------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 400         | Requête invalide                               | Vérifiez les champs obligatoires, le JSON, les paramètres du modèle et la longueur du contexte.                                  |
| 401         | Échec de l’authentification                    | Vérifiez que la clé est présente, valide et rattachée au bon compte.                                                             |
| 403 / 404   | Accès interdit / ressource introuvable         | Vérifiez les autorisations du modèle, l’ID de ressource et l’URL.                                                                |
| 429         | Limite de débit ou de quota                    | Distinguez limitation de débit et crédit insuffisant à l’aide du corps de réponse ; réessayer ne résout pas un manque de crédit. |
| 500 / 503   | Erreur de service / indisponibilité temporaire | Conservez l’identifiant de requête et limitez les nouvelles tentatives avec attente progressive aux erreurs temporaires.         |

Les erreurs natives OpenAI contiennent généralement `error.message`, `error.type`, `error.param`, `error.code` ; `param`, `code` peuvent être `null` ; ne supposez pas que ces champs existent toujours ou correspondent au code HTTP. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont. Même avec HTTP 200, vérifiez finish\_reason, les refus et l’intégrité du flux ; length et content\_filter ne sont pas des erreurs HTTP.

Les réponses longues et les requêtes en streaming peuvent durer de plusieurs dizaines de secondes à plusieurs minutes ; configurez un délai d’attente suffisant et, en cas de coupure, jugez à partir des deltas reçus et du motif d’arrêt plutôt que de renvoyer automatiquement. Pour 429 et 5xx, examinez d’abord le corps de la réponse et les journaux d’utilisation ; en cas de refus par la politique de contenu, modifiez le prompt ou l’entrée au lieu de réessayer à l’identique.

### Exemples de réponse d’erreur

Les réponses d’erreur sont généralement un objet `error` au format OpenAI, avec `param` et `code` éventuellement `null`. Les exemples ci-dessous sont indicatifs ; le libellé varie selon la passerelle ou le fournisseur, ne comparez donc jamais la chaîne du message.

```json
{
  "error": {
    "message": "You didn't provide an API key.",
    "type": "invalid_request_error",
    "param": null,
    "code": "invalid_api_key"
  }
}
```

```json
{
  "error": {
    "message": "Rate limit reached for requests.",
    "type": "rate_limit_error",
    "param": null,
    "code": "rate_limit_exceeded"
  }
}
```

## FAQ

**Que faire en cas de 401 ou de `Invalid token` ?**
Vérifiez que l’en-tête est `Authorization: Bearer <Key>`, que la clé appartient à cette passerelle et n’a pas été révoquée, et que vous n’avez pas collé votre mot de passe de connexion ou une clé de fournisseur.

**Pourquoi une erreur 404 ou « modèle introuvable » ?**
`model` doit être un identifiant complet du Catalogue et tarifs, et le groupe de votre clé doit y avoir accès. Avec un SDK, vérifiez aussi que `baseURL` contient `/v1`.

**Faut-il réessayer après un 429 ?**
Lisez d’abord le corps de la réponse. En cas de limitation de débit, réessayez avec un recul exponentiel et un jitter ; si le quota ou le solde est épuisé, réessayer ne peut pas aboutir \: rechargez ou ajustez la limite.

**Quand une réponse en streaming est-elle complète ?**
Seulement après `data: [DONE]` et un dernier bloc portant `finish_reason`. Si la connexion tombe sans marqueur de fin, considérez la réponse comme incomplète et ne renvoyez pas automatiquement une requête déjà facturée.

**`max_tokens` ou `max_completion_tokens` ?**
Utilisez `max_completion_tokens` pour Chat Completions. `max_tokens` est l’ancien champ et seuls certains modèles l’acceptent encore. N’envoyez jamais les deux ; `/v1/completions` n’utilise toujours que `max_tokens`.

**Pourquoi temperature reste-t-il sans effet ?**
Certains modèles de raisonnement fixent l’échantillonnage ou n’acceptent que les valeurs par défaut, et la passerelle transmet au fournisseur. Suivez la documentation et les erreurs du modèle au lieu de supposer que tous les paramètres OpenAI s’appliquent.

## Références officielles

* [OpenAI Chat Completions API](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [Génération de texte OpenAI](https\://developers.openai.com/api/docs/guides/text)
* [Gestion des erreurs OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)