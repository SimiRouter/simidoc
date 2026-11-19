# Claude Messages

## Description de l’interface

`POST /v1/messages` reçoit des messages user/assistant et renvoie un Message composé de texte, outils ou raisonnement. system est au niveau racine ; n’ajoutez pas de message role=system.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $SIMIROUTER_API_KEY`. L’adresse directe officielle Anthropic est `https://api.anthropic.com`. Authentification \: `x-api-key: $ANTHROPIC_API_KEY`. L’exemple fixe `anthropic-version: 2023-06-01` pour choisir la version du protocole, sans prétendre qu’elle est la plus récente. Choisissez un modèle accessible prenant en charge la capacité.

## Démarrage rapide

1. **Préparer la configuration** \: créez une clé dans Gestion des clés API et copiez depuis Modèles et prix un ID de modèle complet compatible avec Claude Messages.
2. **Envoyer une requête minimale** \: soumettez un seul message utilisateur, conservez l’en-tête `anthropic-version` et laissez `stream` à `false`.
3. **Lire le résultat** \: la requête réussit uniquement si HTTP est 2xx et `content[]` est non vide ; le texte se trouve dans le bloc de contenu où `type=text`.
4. **Valider** \: contrôlez `stop_reason`, `stop_sequence` et le contenu réel, puis vérifiez les journaux d’utilisation.

```bash
API_URL="https://api.dwchainless.com/v1/messages"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "anthropic-version: 2023-06-01" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "max_tokens": 256,
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

Remplacez `PASTE_API_KEY_HERE` et `MODEL_ID` par des valeurs réelles ; `anthropic-version` sélectionne la version du protocole et n’indique pas la plus récente.

## Paramètres de requête

Corps JSON ; les en-têtes de l’exemple comprennent `anthropic-version: 2023-06-01`.

| Champ                         | Type             | Obligatoire  | Description                                                                                                                   |
| ----------------------------- | ---------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| model                         | string           | Oui          | ID d’un modèle Claude accessible.                                                                                             |
| max\_tokens                   | integer          | Oui          | Limite de génération de tokens ; entier positif pour une génération, 0 seulement pour les écritures de cache qui l’acceptent. |
| messages                      | array            | Oui          | Historique de conversation.                                                                                                   |
| messages\[].role              | string           | Oui          | user ou assistant.                                                                                                            |
| messages\[].content           | string / array   | Oui          | Chaîne de texte ou tableau de blocs.                                                                                          |
| content\[].type               | string           | Conditionnel | Types text, image, tool\_use, tool\_result, etc.                                                                              |
| content\[].text               | string           | Conditionnel | Texte d’un bloc text.                                                                                                         |
| content\[].source             | object           | Conditionnel | Source d’image \: base64 avec media\_type/data, ou url avec url.                                                              |
| system                        | string / array   | Non          | Instruction système ; blocs textuels si pris en charge.                                                                       |
| stream                        | boolean          | Non          | true renvoie du SSE ; sans streaming par défaut.                                                                              |
| stop\_sequences               | array            | Non          | Séquences d’arrêt personnalisées.                                                                                             |
| temperature / top\_p / top\_k | number / integer | Non          | Paramètres d’échantillonnage, uniquement sur les modèles compatibles.                                                         |
| tools                         | array            | Non          | Définitions de fonctions \: name, description et input\_schema.                                                               |
| tool\_choice                  | object           | Non          | Choix auto, any, tool ou none ; tool nécessite name.                                                                          |
| thinking                      | object           | Non          | Le raisonnement dépend de la génération du modèle ; adaptive ou enabled ne sont pas universels.                               |
| metadata.user\_id             | string           | Non          | Identifiant utilisateur métier ; ne transmettez pas une identité directe.                                                     |

### Exemple de requête

```json
{
  "model": "MODEL_ID",
  "max_tokens": 256,
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释机器学习。"
    }
  ],
  "stream": false
}
```

## Valeur de retour

La réponse HTTP 200 sans streaming est un Message.

| Champ                                                             | Type          | Description                                                                                                                    |
| ----------------------------------------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| id / type                                                         | string        | ID de message ; type=message.                                                                                                  |
| role / model                                                      | string        | assistant et ID du modèle de réponse.                                                                                          |
| content\[]                                                        | array         | Liste de blocs ; tous ne contiennent pas text.                                                                                 |
| content\[].type / text                                            | string        | Lire text pour type=text et id/name/input pour tool\_use.                                                                      |
| stop\_reason                                                      | string / null | end\_turn \: fin naturelle ; max\_tokens \: limite ; stop\_sequence \: séquence atteinte ; tool\_use \: appel d’outil demandé. |
| stop\_sequence                                                    | string / null | Séquence d’arrêt atteinte, sinon null.                                                                                         |
| usage.input\_tokens / output\_tokens                              | integer       | Tokens d’entrée et de sortie.                                                                                                  |
| usage.cache\_creation\_input\_tokens / cache\_read\_input\_tokens | integer       | Comptabilisation facultative des écritures et lectures du cache ; elle ne constitue pas simplement du texte supplémentaire.    |

```json
{
  "id": "msg_example",
  "type": "message",
  "role": "assistant",
  "model": "MODEL_ID",
  "content": [
    {
      "type": "text",
      "text": "机器学习是一种从数据中提取规律并用于预测的方法。"
    }
  ],
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 14,
    "output_tokens": 24
  }
}
```

### Réponse en streaming

Avec stream=true, traitez successivement message\_start, content\_block\_start, content\_block\_delta, content\_block\_stop, message\_delta et message\_stop. text\_delta ajoute du texte ; input\_json\_delta ajoute partial\_json aux arguments de l’outil, à analyser une fois assemblés. message\_delta fournit la raison d’arrêt et les mises à jour d’utilisation ; message\_stop marque la fin du message. Un événement error peut survenir après un HTTP 200.

Lors de l’utilisation d’outils, conservez les blocs de contenu de l’assistant reçus et renvoyez le résultat dans un message user ultérieur avec `{"type":"tool_result","tool_use_id":"...","content":"..."}`. Vérifiez les arguments et autorisations avant d’exécuter un outil.

## Exemples de code

Définissez `SIMIROUTER_API_KEY`, `SIMIROUTER_CLAUDE_MODEL` ; `SIMIROUTER_BASE_URL` permet de remplacer l’adresse de la passerelle par défaut ; n’y ajoutez pas `/v1`. Les exemples Python 3, Node.js 18+ et Go utilisent uniquement la bibliothèque standard. L’exemple curl fait encoder le JSON de façon sûre par Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_CLAUDE_MODEL"): raise RuntimeError("请设置 SIMIROUTER_CLAUDE_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    path = '/v1/messages'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={'anthropic-version': '2023-06-01', "Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
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
      if (!process.env.SIMIROUTER_CLAUDE_MODEL)
        throw new Error('请设置 SIMIROUTER_CLAUDE_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        max_tokens: 256,
        messages: [
          {
            role: 'user',
            content: '用一句话解释机器学习。',
          },
        ],
        stream: false,
      };
      body.model = process.env.SIMIROUTER_CLAUDE_MODEL;
      const endpoint = '/v1/messages';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          'anthropic-version': '2023-06-01',
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
    : "${SIMIROUTER_CLAUDE_MODEL:?请设置 SIMIROUTER_CLAUDE_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/messages" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "anthropic-version: 2023-06-01" \
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
      model := os.Getenv("SIMIROUTER_CLAUDE_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_CLAUDE_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/messages"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("anthropic-version", "2023-06-01")
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

| Statut HTTP     | Signification ou type d’erreur du fournisseur      | Traitement                                                                                                     |
| --------------- | -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 400             | `invalid_request_error`                            | Structure, paramètres ou capacités du modèle incompatibles avec la requête.                                    |
| 401 / 403       | `authentication_error` / `permission_error`        | Clé invalide ou accès non autorisé.                                                                            |
| 404             | `not_found_error`                                  | Point d’accès, modèle ou ressource introuvable.                                                                |
| 413             | `request_too_large`                                | Réduisez le corps de la requête.                                                                               |
| 429             | `rate_limit_error`                                 | Vérifiez les limites de débit et de quota.                                                                     |
| 500 / 504 / 529 | `api_error` / `timeout_error` / `overloaded_error` | Erreur de service, délai dépassé ou surcharge ; limitez les nouvelles tentatives aux défaillances temporaires. |

Une erreur native Anthropic a la forme `{"type":"error","error":{"type":"invalid_request_error","message":"..."},"request_id":"..."}`. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont.

Les réponses longues et les requêtes en streaming peuvent durer de plusieurs dizaines de secondes à plusieurs minutes ; configurez un délai d’attente suffisant et, en cas de coupure, jugez à partir des deltas reçus et du motif d’arrêt plutôt que de renvoyer automatiquement. Pour 429 et 5xx, examinez d’abord le corps de la réponse et les journaux d’utilisation ; en cas de refus par la politique de contenu, modifiez le prompt ou l’entrée au lieu de réessayer à l’identique.

## Références officielles

* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Version de l’API Anthropic](https\://platform.claude.com/docs/en/api/versioning)
* [Gestion des erreurs Anthropic](https\://platform.claude.com/docs/en/api/errors)