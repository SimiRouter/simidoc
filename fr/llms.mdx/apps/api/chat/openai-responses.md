# Responses API

## Description de l’interface

`POST /v1/responses` utilise des éléments d’entrée et de sortie plutôt que la structure choices/message de Chat, pour les outils, le multimodal et les sorties structurées.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $SIMIROUTER_API_KEY`. L’API directe officielle OpenAI est `https://api.openai.com`. Authentification \: Bearer avec une clé OpenAI. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

La passerelle fournit la création de réponses, mais pas d’interface générale `GET /v1/responses/{id}` ni d’annulation. Le fonctionnement asynchrone natif OpenAI avec `background: true` ne s’applique donc pas à cette intégration ; utilisez le mode synchrone ou SSE. Les tâches en arrière-plan nécessitent une connexion officielle directe offrant création, consultation et annulation.

## Démarrage rapide

1. **Préparer la configuration** \: créez une clé dans Gestion des clés API et copiez depuis Modèles et prix un ID de modèle complet compatible avec Responses.
2. **Envoyer une requête minimale** \: passez un court texte comme `input` et laissez `stream` à `false` ; vérifiez d’abord l’authentification, le modèle et les paramètres.
3. **Lire le résultat** \: la requête réussit uniquement si HTTP est 2xx et `status` vaut `completed` ; le texte se trouve dans l’élément `output[].content[]` où `type=output_text`.
4. **Valider** \: contrôlez `error`, `incomplete_details` et le contenu réel, puis vérifiez les journaux d’utilisation.

```bash
API_URL="https://api.dwchainless.com/v1/responses"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "input": "用一句话解释机器学习。",
    "stream": false
  }'
```

Remplacez `PASTE_API_KEY_HERE` et `MODEL_ID` par des valeurs réelles ; une fois validé, ajoutez des outils, une sortie structurée, ou activez le streaming.

## Paramètres de requête

Le type de contenu est `application/json`.

| Champ                                                 | Type                     | Obligatoire  | Description                                                                                                                                                                                                                |
| ----------------------------------------------------- | ------------------------ | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                                                 | string                   | Oui          | Obligatoire via la passerelle ; choisissez un modèle acceptant Responses.                                                                                                                                                  |
| input                                                 | string / array           | Conditionnel | Texte ou liste d’éléments d’entrée ; une génération ordinaire exige une entrée, éventuellement avec un historique disponible.                                                                                              |
| input\[].role                                         | string                   | Conditionnel | Rôle du message \: user, assistant, system ou developer.                                                                                                                                                                   |
| input\[].content\[].type                              | string                   | Conditionnel | Éléments de contenu typés comme input\_text, input\_image ou input\_file.                                                                                                                                                  |
| input\[].content\[].text                              | string                   | Conditionnel | Texte lorsque type=input\_text.                                                                                                                                                                                            |
| input\[].content\[].image\_url                        | string                   | Conditionnel | URL d’image ou data URL lorsque type=input\_image.                                                                                                                                                                         |
| input\[].content\[].file\_data / file\_url / file\_id | string                   | Conditionnel | Choisissez une seule source lorsque type=input\_file ; voir Compréhension de fichiers.                                                                                                                                     |
| instructions                                          | string                   | Non          | Instructions prioritaires ; avec previous\_response\_id, fournissez de nouveau les instructions nécessaires.                                                                                                               |
| max\_output\_tokens                                   | integer                  | Non          | Limite totale des tokens de sortie, raisonnement compris.                                                                                                                                                                  |
| stream                                                | boolean                  | Non          | true renvoie un flux SSE avec types d’événements.                                                                                                                                                                          |
| previous\_response\_id                                | string                   | Non          | ID de la réponse précédente ; dépend de la conservation amont et d’un contexte accessible commun. Ne pas combiner avec conversation.                                                                                       |
| conversation                                          | string / object          | Non          | Objet ou ID de conversation ; ne peut pas être combiné avec previous\_response\_id. La disponibilité dépend du canal.                                                                                                      |
| store                                                 | boolean                  | Non          | Demande à l’amont de conserver la réponse ; ne contrôle pas les journaux de la passerelle.                                                                                                                                 |
| tools / tool\_choice                                  | array / string or object | Non          | Fonctions ou outils intégrés du fournisseur et règles de sélection.                                                                                                                                                        |
| parallel\_tool\_calls                                 | boolean                  | Non          | Autorise ou non plusieurs appels de fonctions dans une réponse.                                                                                                                                                            |
| reasoning                                             | object                   | Non          | Les modèles de raisonnement compatibles peuvent configurer effort et summary ; les valeurs varient selon le modèle.                                                                                                        |
| text.format                                           | object                   | Non          | Format de texte, par exemple type=json\_schema ; différent de response\_format dans Chat.                                                                                                                                  |
| temperature / top\_p                                  | number                   | Non          | Paramètres d’échantillonnage si le modèle les accepte.                                                                                                                                                                     |
| truncation                                            | string                   | Non          | Déprécié par OpenAI ; préférez context\_management. disabled (défaut) renvoie une erreur si le contexte est trop long, auto peut en supprimer une partie. La prise en charge dépend du comportement réel de la passerelle. |
| include                                               | array                    | Non          | Données supplémentaires demandées, par exemple reasoning.encrypted\_content et web\_search\_call.action.sources.                                                                                                           |
| metadata                                              | object                   | Non          | Métadonnées de corrélation métier ; ne pas y stocker d’informations sensibles.                                                                                                                                             |

Omettez les champs facultatifs non définis. `stop`, `enable_thinking` et autres extensions de compatibilité ne sont pas des champs standard OpenAI Responses. `reasoning_content` n’est pas non plus un champ de sortie standard ; le raisonnement utilise des éléments reasoning distincts et ne garantit pas l’exposition de la chaîne de pensée interne.

### Exemple de requête

```json
{
  "model": "MODEL_ID",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "用一句话解释什么是机器学习。"
        }
      ]
    }
  ],
  "max_output_tokens": 256,
  "stream": false
}
```

## Valeur de retour

Une réussite sans streaming renvoie HTTP 200. Les principaux champs sont présentés ci-dessous ; les champs d’état facultatifs inutilisés peuvent être null.

| Champ                                                | Type             | Description                                                                                                                                     |
| ---------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| id / object                                          | string           | ID de réponse ; object=response.                                                                                                                |
| created\_at / model                                  | integer / string | Heure de création (secondes Unix) et modèle.                                                                                                    |
| status                                               | string           | completed, incomplete, failed, queued, in\_progress ou cancelled ; ces états peuvent apparaître en streaming comme en arrière-plan.             |
| output\[]                                            | array            | Éléments de sortie typés, pouvant mêler message, reasoning, function\_call, web\_search\_call, etc. ; ne lisez pas systématiquement output\[0]. |
| output\[].type / id / status                         | string           | Type, ID et état de l’élément de sortie, selon son type.                                                                                        |
| output\[].role                                       | string           | Le rôle de sortie d’un message est généralement assistant.                                                                                      |
| output\[].content\[]                                 | array            | Éléments de contenu \: type=output\_text pour le texte, type=refusal pour un refus.                                                             |
| output\[].content\[].text / annotations              | string / array   | Texte et annotations, notamment les citations.                                                                                                  |
| output\[].call\_id / name / arguments                | string           | ID de corrélation, nom de fonction et arguments sous forme de chaîne JSON de function\_call.                                                    |
| error                                                | object / null    | Informations d’échec ; généralement null en cas de réussite complète.                                                                           |
| incomplete\_details                                  | object / null    | Raison d’incomplétude, par exemple max\_output\_tokens ; ne pas assimiler à une réussite complète.                                              |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | Tokens d’entrée, de sortie et totaux.                                                                                                           |
| usage.\*\_tokens\_details                            | object           | Détails facultatifs d’utilisation, notamment cache et raisonnement.                                                                             |

```json
{
  "id": "resp_example",
  "object": "response",
  "created_at": 1760000000,
  "model": "MODEL_ID",
  "status": "completed",
  "error": null,
  "incomplete_details": null,
  "output": [
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "机器学习让计算机从数据中学习规律，用于预测和决策。",
          "annotations": []
        }
      ]
    }
  ],
  "usage": {
    "input_tokens": 18,
    "output_tokens": 22,
    "total_tokens": 40
  }
}
```

Pour extraire le texte, parcourez `output` et sélectionnez les éléments `type=message`, puis concaténez les text de leurs `content` sous `type=output_text`. La propriété SDK `output_text` est une agrégation pratique, pas un champ nécessairement présent dans le JSON REST brut.

### Réponse en streaming

Avec stream=true, analysez les SSE selon `event` et `data` \: response.created crée la réponse ; response.output\_text.delta ajoute du texte ; response.output\_item.added/done gère les éléments ; response.function\_call\_arguments.delta assemble les arguments d’outils. Une réponse n’est complète qu’après response.completed et vérification du response.status final ; traitez séparément response.failed, response.incomplete et error. Une simple fin de connexion réseau ne prouve pas la réussite.

```text
event: response.output_text.delta
data: {"type":"response.output_text.delta","item_id":"msg_example","output_index":0,"content_index":0,"delta":"机器学习","sequence_number":3}

event: response.completed
data: {"type":"response.completed","response":{"id":"resp_example","object":"response","status":"completed","output":[]},"sequence_number":12}
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/responses'
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
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        input: [
          {
            role: 'user',
            content: [
              {
                type: 'input_text',
                text: '用一句话解释什么是机器学习。',
              },
            ],
          },
        ],
        max_output_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/responses';
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/responses" \
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/responses"
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

Les erreurs natives OpenAI contiennent généralement `error.message`, `error.type`, `error.param`, `error.code` ; `param`, `code` peuvent être `null` ; ne supposez pas que ces champs existent toujours ou correspondent au code HTTP. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont. Même avec HTTP 200, vérifiez status, error et incomplete\_details ; un événement SSE d’échec ne modifie pas forcément le code HTTP déjà envoyé.

Les réponses longues et les requêtes en streaming peuvent durer de plusieurs dizaines de secondes à plusieurs minutes ; configurez un délai d’attente suffisant et, en cas de coupure, jugez à partir des deltas reçus et du motif d’arrêt plutôt que de renvoyer automatiquement. Pour 429 et 5xx, examinez d’abord le corps de la réponse et les journaux d’utilisation ; en cas de refus par la politique de contenu, modifiez le prompt ou l’entrée au lieu de réessayer à l’identique.

## Références officielles

* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [Événements de streaming OpenAI](https\://developers.openai.com/api/docs/guides/streaming-responses)
* [État des conversations OpenAI](https\://developers.openai.com/api/docs/guides/conversation-state)
* [Mode en arrière-plan OpenAI](https\://developers.openai.com/api/docs/guides/background)
* [Gestion des erreurs OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)