# Génération de texte Gemini

## Description de l’interface

`POST /v1beta/models/{model}:generateContent` reçoit la structure Gemini contents/parts et renvoie un GenerateContentResponse complet sans streaming. Son format diffère de messages ou input d’OpenAI.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $SIMIROUTER_API_KEY`. L’API directe officielle Google est `https://generativelanguage.googleapis.com`. Authentification \: généralement `x-goog-api-key: $GEMINI_API_KEY`, pas la clé Bearer de la passerelle. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

## Démarrage rapide

1. **Préparer la configuration** \: créez une clé dans Gestion des clés API et copiez depuis Modèles et prix un ID de modèle complet compatible avec generateContent.
2. **Envoyer une requête minimale** \: placez l’ID du modèle directement dans le chemin (sans préfixe `models/`) et définissez `generationConfig.maxOutputTokens` à une petite valeur.
3. **Lire le résultat** \: la requête réussit uniquement si HTTP est 2xx et `candidates[]` est non vide ; le texte se trouve généralement dans `candidates[0].content.parts[].text`.
4. **Valider** \: contrôlez `finishReason` et `promptFeedback`, puis vérifiez les journaux d’utilisation.

```bash
API_URL="https://api.dwchainless.com/v1beta/models/MODEL_ID:generateContent"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"role": "user", "parts": [{"text": "用一句话解释机器学习。"}]}],
    "generationConfig": {"maxOutputTokens": 256}
  }'
```

Remplacez `PASTE_API_KEY_HERE` et `MODEL_ID` dans le chemin par des valeurs réelles ; pour le streaming, utilisez `streamGenerateContent?alt=sse`.

## Paramètres de requête

Le corps est en JSON. Les champs REST utilisent lowerCamelCase ; ne recopiez pas mécaniquement les noms snake\_case du SDK Python dans une requête REST.

| Champ                                      | Type             | Obligatoire  | Description                                                                                                                                                   |
| ------------------------------------------ | ---------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model (chemin)                             | string           | Oui          | ID du modèle sans préfixe models/ ; le nom de ressource natif est models/\{model}.                                                                            |
| contents                                   | array            | Oui          | Historique et message courant, dans l’ordre.                                                                                                                  |
| contents\[].role                           | string           | Non          | user ou model ; à préciser explicitement en conversation.                                                                                                     |
| contents\[].parts                          | array            | Oui          | Fragments du contenu du message, au moins un.                                                                                                                 |
| parts\[].text                              | string           | Conditionnel | Fragment de texte ; utilisez inlineData ou fileData pour les médias.                                                                                          |
| systemInstruction.parts\[].text            | string           | Non          | Instructions système ; ne les remplacez pas par role=system.                                                                                                  |
| generationConfig.maxOutputTokens           | integer          | Non          | Limite de tokens générés, à interpréter selon les règles du modèle pour les tokens de raisonnement.                                                           |
| generationConfig.responseMimeType          | string           | Non          | application/json peut servir aux sorties structurées si le modèle le prend en charge.                                                                         |
| generationConfig.responseJsonSchema        | object           | Non          | JSON Schema de la réponse, généralement configuré avec application/json.                                                                                      |
| generationConfig.temperature / topP / topK | number / integer | Non          | À utiliser uniquement avec les modèles prenant en charge ces paramètres d’échantillonnage ; ne réutilisez pas des valeurs fixes entre générations de modèles. |
| generationConfig.stopSequences             | array            | Non          | Séquences d’arrêt si le modèle les prend en charge.                                                                                                           |
| safetySettings                             | array            | Non          | Catégories et seuils de sécurité ; ils ne permettent pas de désactiver tous les mécanismes de sécurité de tous les modèles.                                   |
| tools / toolConfig                         | array / object   | Non          | Définitions et configuration d’outils comme Google Search et les appels de fonctions.                                                                         |

### Exemple de requête

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "用一句话解释机器学习。"
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 256
  }
}
```

En conversation, alternez role=user et role=model et terminez par la question courante ; le serveur ne conserve pas automatiquement la conversation à partir de la connexion HTTP précédente.

## Valeur de retour

| Champ                                 | Type           | Description                                                                                                                     |
| ------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| candidates\[]                         | array          | Résultats candidats ; peuvent être absents en cas de blocage.                                                                   |
| candidates\[].index                   | integer        | Position du candidat.                                                                                                           |
| candidates\[].content.role / parts\[] | string / array | Rôle et fragments de sortie ; le texte se trouve généralement dans parts\[].text.                                               |
| candidates\[].finishReason            | string         | STOP indique une fin normale ; MAX\_TOKENS une limite atteinte ; SAFETY, RECITATION, etc. nécessitent un traitement spécifique. |
| candidates\[].safetyRatings           | array          | Évaluation de sécurité facultative.                                                                                             |
| candidates\[].groundingMetadata       | object         | Sources et citations lors de l’utilisation d’outils de grounding comme la recherche.                                            |
| promptFeedback.blockReason            | string         | Raison du blocage de l’entrée ; il peut ne pas y avoir de candidat.                                                             |
| usageMetadata.promptTokenCount        | integer        | Tokens d’entrée.                                                                                                                |
| usageMetadata.candidatesTokenCount    | integer        | Tokens de sortie des candidats.                                                                                                 |
| usageMetadata.thoughtsTokenCount      | integer        | Tokens de raisonnement facultatifs ; ce ne sont pas des éléments de texte directement affichables.                              |
| usageMetadata.totalTokenCount         | integer        | Total des tokens de la requête, pouvant inclure outils, raisonnement et autres éléments.                                        |
| modelVersion / responseId             | string         | Version du modèle et identifiant de réponse facultatifs.                                                                        |

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "机器学习让计算机通过数据学习规律并完成预测。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 12,
    "candidatesTokenCount": 20,
    "totalTokenCount": 32
  }
}
```

### Réponse en streaming

Remplacez le chemin par `/v1beta/models/{model}:streamGenerateContent?alt=sse`, sans modifier le corps. Analysez chaque GenerateContentResponse dans data et et fusionnez le texte de parts selon candidate.index ; n’attendez pas le marqueur OpenAI `[DONE]`. Vérifiez finalement finishReason, promptFeedback et l’utilisation. SSE livre progressivement une même génération ; ce n’est ni une tâche en arrière-plan ni plusieurs requêtes en parallèle.

## Exemples de code

Définissez `SIMIROUTER_API_KEY`, `SIMIROUTER_GEMINI_MODEL` ; `SIMIROUTER_BASE_URL` permet de remplacer l’adresse de la passerelle par défaut ; n’y ajoutez pas `/v1`. Les exemples Python 3, Node.js 18+ et Go utilisent uniquement la bibliothèque standard. L’exemple curl fait encoder le JSON de façon sûre par Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
    path = "/v1beta/models/" + urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe="") + ":generateContent"
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
      if (!process.env.SIMIROUTER_GEMINI_MODEL)
        throw new Error('请设置 SIMIROUTER_GEMINI_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '用一句话解释机器学习。',
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 256,
        },
      };
      const endpoint = `/v1beta/models/${encodeURIComponent(process.env.SIMIROUTER_GEMINI_MODEL)}:generateContent`;
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
    : "${SIMIROUTER_GEMINI_MODEL:?请设置 SIMIROUTER_GEMINI_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    MODEL_PATH=$(python3 -c 'import os, urllib.parse; print(urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe=""))')
    curl "${BASE_URL%/}/v1beta/models/${MODEL_PATH}:generateContent" \
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
      model := os.Getenv("SIMIROUTER_GEMINI_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_GEMINI_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }`), &body); err != nil { log.Fatal(err) }
      endpoint := "/v1beta/models/" + model + ":generateContent"
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

| Statut HTTP | Signification ou type d’erreur du fournisseur | Traitement                                                                                                                                 |
| ----------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 400         | `INVALID_ARGUMENT`, etc.                      | Vérifiez le JSON, les paramètres du modèle, le MIME et la longueur des entrées.                                                            |
| 403         | `PERMISSION_DENIED`                           | Vérifiez la clé, les autorisations du projet, la région et les restrictions de facturation.                                                |
| 404         | `NOT_FOUND`                                   | Vérifiez le nom du modèle et la version de l’API.                                                                                          |
| 429         | `RESOURCE_EXHAUSTED`                          | Vérifiez les limites de débit et quotas ; pour les erreurs récupérables, utilisez un nombre limité de tentatives avec attente progressive. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`                    | Conservez l’identifiant de requête ; réessayez un nombre limité de fois ou ultérieurement.                                                 |

L’objet d’erreur natif Google contient `error.code` (code HTTP numérique), `error.status` (nom de l’énumération), `error.message` et éventuellement `details`. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont. Avec HTTP 200, un tableau candidates vide ou finishReason=SAFETY peut indiquer un blocage de contenu, pas une panne réseau.

Les réponses longues et les requêtes en streaming peuvent durer de plusieurs dizaines de secondes à plusieurs minutes ; configurez un délai d’attente suffisant et, en cas de coupure, jugez à partir des deltas reçus et du motif d’arrêt plutôt que de renvoyer automatiquement. Pour 429 et 5xx, examinez d’abord le corps de la réponse et les journaux d’utilisation ; en cas de refus par la politique de contenu, modifiez le prompt ou l’entrée au lieu de réessayer à l’identique.

## Références officielles

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Génération de texte Google](https\://ai.google.dev/gemini-api/docs/text-generation)
* [Dépannage Google](https\://ai.google.dev/gemini-api/docs/troubleshooting)