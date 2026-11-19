# Compréhension d’images

## Description de l’interface

`POST /v1/chat/completions` associe une question textuelle et une image dans un message user et renvoie une analyse textuelle. La compréhension d’images n’est ni génération ni édition.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $API_KEY`. L’API directe officielle OpenAI est `https://api.openai.com`. Authentification \: Bearer avec une clé OpenAI. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

Une image peut être une URL HTTPS accessible ou une data URL contenant ses vrais octets ; cette page utilise une URL HTTPS accessible.

## Paramètres de requête

| Champ                       | Type    | Obligatoire  | Description                                                             |
| --------------------------- | ------- | ------------ | ----------------------------------------------------------------------- |
| model                       | string  | Oui          | Modèle de conversation acceptant les entrées visuelles.                 |
| messages\[].role            | string  | Oui          | Utilisez user pour le message contenant l’image.                        |
| messages\[].content         | array   | Oui          | Au moins une question et un élément d’image.                            |
| content\[].type=text / text | string  | Conditionnel | Élément de question textuelle.                                          |
| content\[].type=image\_url  | string  | Conditionnel | Déclare un élément d’image.                                             |
| image\_url.url              | string  | Oui          | URL HTTPS ou data\:image/\{format};base64,... ; pas un chemin local.    |
| image\_url.detail           | string  | Non          | Réglage de détail accepté par le modèle, par exemple auto, low ou high. |
| max\_completion\_tokens     | integer | Non          | Nombre maximal de tokens de sortie.                                     |
| stream                      | boolean | Non          | true renvoie les SSE Chat.                                              |

PNG, JPEG, WebP, etc. doivent porter leur MIME correspondant ; respectez les limites de nombre, pixels et taille de requête du modèle choisi. Ne renommez pas simplement un GIF animé, une vidéo ou un binaire quelconque en image/png.

### Structure de la requête

```json
{
  "model": "gpt-5.5",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "描述图片中的主要物体，并指出无法确定的细节。"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/png;base64,BASE64_IMAGE_BYTES",
            "detail": "auto"
          }
        }
      ]
    }
  ],
  "max_completion_tokens": 512,
  "stream": false
}
```

## Valeur de retour

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
  "id": "chatcmpl_vision_example",
  "object": "chat.completion",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "图中可见一张桌子和一个杯子，杯内物品无法确认。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 280,
    "completion_tokens": 30,
    "total_tokens": 310
  }
}
```

Ajoutez des éléments image\_url pour plusieurs images ; précisez ordre et objectif dans le texte pour les comparer. En streaming, assemblez Chat delta.content. Ne vous fiez pas uniquement à la vision du modèle pour les petits textes, comptages exacts, identités ou décisions sensibles.

## Exemples de code

Renseignez `API_URL` et `API_KEY` en tête du code; les exemples utilisent `gpt-5.5`. `API_URL` est l’URL complète de la requête et pointe par défaut vers la passerelle `https://api.dwchainless.com`. `IMAGE_URL` doit être une URL HTTPS d’image accessible au serveur. Les exemples n’utilisent que les bibliothèques standard, envoient une requête et affichent le JSON reçu ; ils n’enregistrent pas l’image automatiquement.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/chat/completions"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "描述图片中的主要物体。"
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "https://example.com/reference.png"
              }
            }
          ]
        }
      ]
    }
    request = urllib.request.Request(
        API_URL,
        data=json.dumps(body).encode(),
        method="POST",
        headers={
            "Authorization": "Bearer " + API_KEY,
            "Content-Type": "application/json",
        },
    )
    print(urllib.request.urlopen(request).read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const API_URL = 'https://api.dwchainless.com/v1/chat/completions';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: '描述图片中的主要物体。'
              },
              {
                type: 'image_url',
                image_url: {
                  url: 'https://example.com/reference.png'
                }
              }
            ]
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/chat/completions"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "描述图片中的主要物体。"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "https://example.com/reference.png"
                }
              }
            ]
          }
        ]
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/chat/completions"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "描述图片中的主要物体。"
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": "https://example.com/reference.png"
                            }
                        }
                    ]
                }
            ]
        }`)
        request, _ := http.NewRequest("POST", apiURL, bytes.NewReader(body))
        request.Header.Set("Authorization", "Bearer "+apiKey)
        request.Header.Set("Content-Type", "application/json")
        response, _ := http.DefaultClient.Do(request)
        defer response.Body.Close()
        result, _ := io.ReadAll(response.Body)
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

## Références officielles

* [Images et vision OpenAI](https\://developers.openai.com/api/docs/guides/images-vision)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [Gestion des erreurs OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)