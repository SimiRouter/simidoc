# Édition et image vers image Gemini

## Description de l’interface

`POST /v1beta/models/{model}:generateContent` permet d’envoyer consignes et références dans parts pour éditer une image, générer depuis une image, transformer le style, remplacer le fond ou fusionner plusieurs images. Il n’existe pas de chemin Gemini natif `/images/edits` distinct.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $API_KEY`. L’API directe officielle Google est `https://generativelanguage.googleapis.com`. Authentification \: généralement `x-goog-api-key: $GEMINI_API_KEY`, pas la clé Bearer de la passerelle. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

Téléversez uniquement des images que vous êtes autorisé à traiter. L’édition ne garantit pas la préservation pixel par pixel de l’identité, des textes, marques ou détails produits ; vérifiez les éléments importants avant usage.

## Paramètres de requête

| Champ                                    | Type   | Obligatoire              | Description                                                                                                         |
| ---------------------------------------- | ------ | ------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| model (chemin)                           | string | Oui                      | Modèle d’image Gemini acceptant à la fois generateContent et la sortie d’images ; pas un modèle purement textuel.   |
| contents                                 | array  | Oui                      | Liste de messages ; une génération texte vers image ne nécessite généralement qu’un message user.                   |
| contents\[].role                         | string | Non                      | user ; les réponses du modèle dans l’historique utilisent model.                                                    |
| contents\[].parts\[].text                | string | Oui                      | Description de l’image ou consigne d’édition.                                                                       |
| generationConfig.responseModalities      | array  | Non                      | Par exemple \["TEXT","IMAGE"] pour demander texte et images ; les combinaisons disponibles varient selon le modèle. |
| generationConfig.imageConfig.aspectRatio | string | Non                      | Rapports comme 1\:1, 16\:9, 9\:16 si pris en charge.                                                                |
| generationConfig.imageConfig.imageSize   | string | Non                      | 1K, 2K, 4K, etc., si le modèle choisi les accepte ; tous les modèles d’image ne les proposent pas.                  |
| contents\[].parts\[].inlineData          | object | Oui (référence intégrée) | Part distinct du text, contenant mimeType et data.                                                                  |
| inlineData.mimeType                      | string | Oui                      | MIME réel de la référence, par exemple image/png, image/jpeg ou image/webp.                                         |
| inlineData.data                          | string | Oui                      | Base64 pur du fichier de référence, sans préfixe data\:.                                                            |
| contents\[].parts\[].fileData            | object | Conditionnel             | Alternative au contenu intégré, avec fileUri/mimeType autorisés et lisibles par le fournisseur.                     |

Chaque image occupe un Part ; ajoutez des Part pour les autres références et précisez leur rôle dans le texte. Nombre d’images, résolution et cohérence multi-tours dépendent du modèle ; un nombre unique ne couvre pas tous les modèles d’image Gemini.

### Caractéristiques des images \: 1K, 2K et 4K

K désigne couramment une résolution, et non la taille du fichier ou un réglage de qualité. Les dimensions dépendent du modèle et du rapport de forme. À rapport identique, doubler les deux côtés quadruple le nombre de pixels. Ces exemples expliquent les termes, sans constituer des dimensions acceptées par tous les modèles.

Si le modèle le permet, Gemini utilise `generationConfig.imageConfig.imageSize` pour choisir `1K`, `2K` ou `4K`, et `generationConfig.imageConfig.aspectRatio` pour les proportions. Consultez le modèle choisi pour les dimensions réelles.

| Libellé de résolution | Exemples de pixels courants (sans garantie de prise en charge) |
| --------------------- | -------------------------------------------------------------- |
| 1K                    | 1024×1024 · Environ mille pixels par côté                      |
| 2K                    | 2048×2048 · Environ deux mille pixels par côté                 |
| 4K                    | 4096×4096 / 3840×2160 · Environ quatre mille pixels par côté   |

Les paliers de facturation par image du site obéissent à des règles distinctes ; ces exemples de résolution ne définissent pas la facturation. [Caractéristiques et règles de facturation](/simidoc/fr/apps/api/images).

### Structure de la requête

Remplacez `BASE64_IMAGE_BYTES` par le Base64 pur de l’image autorisée.

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。"
        },
        {
          "inlineData": {
            "mimeType": "image/png",
            "data": "BASE64_IMAGE_BYTES"
          }
        }
      ]
    }
  ],
  "generationConfig": {
    "responseModalities": [
      "TEXT",
      "IMAGE"
    ]
  }
}
```

## Valeur de retour

| Champ                          | Type    | Description                                                                                                      |
| ------------------------------ | ------- | ---------------------------------------------------------------------------------------------------------------- |
| candidates\[]                  | array   | Liste de candidats, éventuellement vide après filtrage de sécurité.                                              |
| candidates\[].content.parts\[] | array   | Fragments ordonnés de texte, d’image ou de raisonnement ; ne lisez pas seulement le premier.                     |
| parts\[].text                  | string  | Texte explicatif, présent ou non selon le modèle.                                                                |
| parts\[].inlineData.mimeType   | string  | MIME réel de l’image, par exemple image/png ou image/jpeg.                                                       |
| parts\[].inlineData.data       | string  | Données d’image en Base64 pur, sans préfixe data\:.                                                              |
| parts\[].thought               | boolean | Marqueur facultatif de raisonnement ; ne prenez pas une image intermédiaire thought=true pour le résultat final. |
| parts\[].thoughtSignature      | string  | Signature opaque facultative à conserver telle quelle en édition multi-tours, sans la fabriquer ni la modifier.  |
| candidates\[].finishReason     | string  | STOP \: fin normale ; distinguez MAX\_TOKENS, SAFETY, etc.                                                       |
| promptFeedback                 | object  | Informations facultatives de blocage de l’entrée.                                                                |
| usageMetadata                  | object  | Tokens d’entrée, candidats, raisonnement et total ; les champs dépendent du modèle.                              |

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "已根据描述生成图片。"
          },
          {
            "inlineData": {
              "mimeType": "image/png",
              "data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
            }
          }
        ]
      },
      "finishReason": "STOP"
    }
  ]
}
```

Le Base64 ci-dessus illustre seulement la structure. Enregistrez selon le MIME réel. Pour une édition multi-tours, ajoutez le model content complet précédent à l’historique, avec thoughtSignature et les autres champs opaques, puis la nouvelle demande user. Ne copiez pas seulement les octets d’image en perdant les signatures requises et ne modifiez pas ces champs.

L’édition native Gemini décrit les zones en langage naturel ; mask d’OpenAI n’est pas un paramètre général de cette interface. Pour une contrainte de zone précise, vérifiez les entrées acceptées par le modèle au lieu de raisonner par analogie de noms.

## Exemples de code

Renseignez `API_URL` et `API_KEY` en tête du code; les exemples utilisent `gemini-3-pro-image` ; remplacez `BASE64_IMAGE_BYTES` par le Base64 brut de l’image autorisée (sans préfixe data\:). `API_URL` est l’URL complète de la requête et pointe par défaut vers la passerelle `https://api.dwchainless.com`. Les exemples n’utilisent que les bibliothèques standard, envoient une requête et affichent le JSON reçu ; ils n’enregistrent pas l’image automatiquement.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY = "PASTE_API_KEY_HERE"
    IMAGE_BASE64 = "BASE64_IMAGE_BYTES"
    body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "保留主体和构图，将背景改为浅蓝色。"
            },
            {
              "inlineData": {
                "mimeType": "image/png",
                "data": IMAGE_BASE64
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "responseModalities": [
          "TEXT",
          "IMAGE"
        ]
      }
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
    const API_URL = 'https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const IMAGE_BASE64 = 'BASE64_IMAGE_BYTES';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '保留主体和构图，将背景改为浅蓝色。'
              },
              {
                inlineData: {
                  mimeType: 'image/png',
                  data: IMAGE_BASE64
                }
              }
            ]
          }
        ],
        generationConfig: {
          responseModalities: [
            'TEXT',
            'IMAGE'
          ]
        }
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
    API_KEY="PASTE_API_KEY_HERE"
    IMAGE_BASE64="BASE64_IMAGE_BYTES"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary @- <<JSON
      {
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              },
              {
                "inlineData": {
                  "mimeType": "image/png",
                  "data": "$IMAGE_BASE64"
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "responseModalities": [
            "TEXT",
            "IMAGE"
          ]
        }
      }
    JSON
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1beta/models/gemini-3-pro-image:generateContent"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "contents": [
                {
                    "role": "user",
                    "parts": [
                        {
                            "text": "保留主体和构图，将背景改为浅蓝色。"
                        },
                        {
                            "inlineData": {
                                "mimeType": "image/png",
                                "data": "BASE64_IMAGE_BYTES"
                            }
                        }
                    ]
                }
            ],
            "generationConfig": {
                "responseModalities": [
                    "TEXT",
                    "IMAGE"
                ]
            }
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

## Démo d’appel par un agent

Copiez cette tâche dans un agent capable d’exécuter des scripts locaux et d’examiner la réponse. Définissez d’abord les variables selon [la configuration de ce protocole](/simidoc/fr/apps/api/images/gemini). Ne mettez jamais la clé dans la consigne.

```text
Read this Gemini protocol page and its image editing reference first. Use the existing
API_KEY, MODEL and configured SimiRouter request URL; never reveal credentials or change
the existing connection. Read only the authorized local image, encode it as pure Base64,
and put it in IMAGE_BASE64. Submit its inlineData Part alongside the text instruction
through POST /v1beta/models/{model}:generateContent. Set
generationConfig.responseModalities=["TEXT","IMAGE"] when supported by the selected
model. Keep the subject and layout; change only the background to pale blue. Request one
image, non-streaming; use aspectRatio=1:1 and imageSize=1K only if supported. Do not use
OpenAI multipart or mask fields. After the response, read only completed, non-thought
inlineData from parts; decode the Base64 in memory and report any unmet requirement; do
not write an image file. Preserve opaque signatures for later turns. Do not upload
unrelated files, overwrite results, change model/size/count/provider, install remote
skills, or retry automatically. Ask before any additional paid request.
```

## Codes d’erreur

| Statut HTTP | Signification ou type d’erreur du fournisseur | Traitement                                                                                                                                 |
| ----------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 400         | `INVALID_ARGUMENT`, etc.                      | Vérifiez le JSON, les paramètres du modèle, le MIME et la longueur des entrées.                                                            |
| 403         | `PERMISSION_DENIED`                           | Vérifiez la clé, les autorisations du projet, la région et les restrictions de facturation.                                                |
| 404         | `NOT_FOUND`                                   | Vérifiez le nom du modèle et la version de l’API.                                                                                          |
| 429         | `RESOURCE_EXHAUSTED`                          | Vérifiez les limites de débit et quotas ; pour les erreurs récupérables, utilisez un nombre limité de tentatives avec attente progressive. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`                    | Conservez l’identifiant de requête ; réessayez un nombre limité de fois ou ultérieurement.                                                 |

L’objet d’erreur natif Google contient `error.code` (code HTTP numérique), `error.status` (nom de l’énumération), `error.message` et éventuellement `details`. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont. Refus du modèle, absence d’image, fin autre que STOP et erreurs HTTP doivent être traités séparément ; ne présentez pas l’image d’entrée comme résultat édité.

## Références officielles

* [Génération et édition d’images Google](https\://ai.google.dev/gemini-api/docs/image-generation)
* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Compréhension d’images et entrées multimédias Google](https\://ai.google.dev/gemini-api/docs/image-understanding)
* [Dépannage Google](https\://ai.google.dev/gemini-api/docs/troubleshooting)