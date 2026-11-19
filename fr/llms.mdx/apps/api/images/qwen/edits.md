# Édition d’images Qwen

## Description de l’interface

`POST /v1/images/edits`, avec un corps JSON. Les exemples utilisent la passerelle de ce site `https://api.dwchainless.com` et une `API_KEY` créée sur ce site ; le corps reprend la structure native Qwen `model`, `input.messages`, `parameters`, et la réponse est toujours au format `data[]`.

L’édition d’image place un élément image et une instruction textuelle dans content, sans utiliser de champ file multipart.

## Paramètres de requête

| Champ                              | Type      | Obligatoire | Description                                                                                                        |
| ---------------------------------- | --------- | ----------- | ------------------------------------------------------------------------------------------------------------------ |
| model                              | string    | Oui         | qwen-image-2.0-pro ou une version précise prise en charge par le canal de ce site.                                 |
| input.messages                     | object\[] | Oui         | Un seul message user pour cet échange.                                                                             |
| input.messages\[].role             | string    | Oui         | Fixé à user.                                                                                                       |
| input.messages\[].content\[].text  | string    | Oui         | Consigne en chinois ou anglais ; un seul élément text par tour.                                                    |
| input.messages\[].content\[].image | string    | Oui         | URL accessibles ou data URL d’une ou plusieurs références. Nombre et limites de pixels selon la version du modèle. |
| parameters.size                    | string    | Non         | Largeur × hauteur, par exemple 2048 × 2048 ; la série 2.0 accepte un total de pixels entre 512×512 et 2048×2048.   |
| parameters.n                       | integer   | Non         | 1 par défaut ; la série 2.0 accepte 1–6.                                                                           |
| parameters.negative\_prompt        | string    | Non         | Contenu à exclure, 500 caractères maximum.                                                                         |
| parameters.prompt\_extend          | boolean   | Non         | true par défaut, développe automatiquement la consigne positive.                                                   |
| parameters.watermark               | boolean   | Non         | Ajout d’un filigrane visible ; respectez les obligations applicables d’identification des contenus synthétiques.   |

### Caractéristiques des images \: 1K, 2K et 4K

K désigne couramment une résolution, et non la taille du fichier ou un réglage de qualité. Les dimensions dépendent du modèle et du rapport de forme. À rapport identique, doubler les deux côtés quadruple le nombre de pixels. Ces exemples expliquent les termes, sans constituer des dimensions acceptées par tous les modèles.

Qwen utilise `parameters.size` pour les dimensions acceptées, comme `2048*2048`, et non le libellé `2K`. La série 2.0 limite aussi le nombre total de pixels ; le carré 4K ci-dessous ne garantit pas une taille acceptée.

| Libellé de résolution | Exemples de pixels courants (sans garantie de prise en charge)    |
| --------------------- | ----------------------------------------------------------------- |
| 1K                    | Les deux côtés ≤ 1024 pixels ; par exemple 1024×1024.             |
| 2K                    | Côté le plus long > 1024 et ≤ 2048 pixels ; par exemple 1280×720. |
| 4K                    | Un côté > 2048 pixels ; par exemple 2560×1440.                    |

Les paliers de facturation par image de ce site obéissent à des règles distinctes ; ces exemples explicatifs ne définissent pas les tarifs. [Caractéristiques et règles de facturation](/simidoc/fr/apps/api/images).

## Valeurs de retour

| Champ                   | Description                                                                                            |
| ----------------------- | ------------------------------------------------------------------------------------------------------ |
| `created`               | Horodatage de génération de la réponse.                                                                |
| `data[].url`            | URL de l’image générée ; sa durée de validité dépend du canal, téléchargez-la ou copiez-la rapidement. |
| `data[].b64_json`       | Certains canaux renvoient du Base64 pur ; le cas échéant, décodez-le directement pour l’enregistrer.   |
| `data[].revised_prompt` | Consigne réécrite par le canal ; peut être absente.                                                    |
| `error` / `message`     | Code d’erreur et description en cas d’échec.                                                           |

```json
{"created":1760000000,"data":[{"url":"https://example.com/edited.png","b64_json":null,"revised_prompt":"..."}]}
```

## Appel depuis le code

Renseignez `API_URL` et `API_KEY` en tête du code. `API_URL` est l’adresse de la passerelle de ce site `https://api.dwchainless.com/v1/images/edits` et `API_KEY` est une clé créée sur ce site. Les exemples n’utilisent que la bibliothèque standard \: ils envoient une requête et affichent le JSON renvoyé, sans télécharger ni enregistrer l’image automatiquement.

Définissez `IMAGE_URL` sur une vraie adresse HTTP(S) d’image autorisée et accessible depuis le cloud. Le code ne vérifie que la forme de l’URL, sans prouver que l’image est téléchargeable ni qu’elle respecte les limites de format du canal ; n’utilisez ni chemin local, localhost, page nécessitant une connexion ni faux lien.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "qwen-image-2.0-pro",
      "input": {
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "image": "https://example.com/reference.png"
              },
              {
                "text": "保留主体和构图，将背景改为浅蓝色。"
              }
            ]
          }
        ]
      },
      "parameters": {
        "size": "1024*1024",
        "n": 1
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'qwen-image-2.0-pro',
        input: {
          messages: [
            {
              role: 'user',
              content: [
                {
                  image: 'https://example.com/reference.png'
                },
                {
                  text: '保留主体和构图，将背景改为浅蓝色。'
                }
              ]
            }
          ]
        },
        parameters: {
          size: '1024*1024',
          n: 1
        }
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/images/edits"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "qwen-image-2.0-pro",
        "input": {
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "image": "https://example.com/reference.png"
                },
                {
                  "text": "保留主体和构图，将背景改为浅蓝色。"
                }
              ]
            }
          ]
        },
        "parameters": {
          "size": "1024*1024",
          "n": 1
        }
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/images/edits"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "qwen-image-2.0-pro",
            "input": {
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "image": "https://example.com/reference.png"
                            },
                            {
                                "text": "保留主体和构图，将背景改为浅蓝色。"
                            }
                        ]
                    }
                ]
            },
            "parameters": {
                "size": "1024*1024",
                "n": 1
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

Copiez la tâche ci-dessous dans un agent capable d’exécuter des scripts locaux et d’examiner les résultats renvoyés ; configurez d’abord [ce protocole](/simidoc/fr/apps/api/images/qwen) en renseignant directement API\_URL et API\_KEY dans l’exemple, et confirmez le nom du modèle. N’inscrivez jamais la clé dans la consigne.

```text
Read this Qwen image protocol page and its editing reference first. Use the existing
API_KEY and API_URL from this site's gateway; never reveal the key or switch the
existing connection. Verify qwen-image-2.0-pro supports the edit. Use only the
authorized cloud-readable image in IMAGE_URL; do not upload unrelated local files or
publish a file. POST once to /v1/images/edits with the native Qwen body: one user
message containing that image item and one text instruction: keep the subject and
layout; change only the background to pale blue. Set parameters.n=1 and size=1024*1024
only if supported. Do not use OpenAI multipart or mask fields. Check the completed
business result, inspect data[].url or data[].b64_json without forwarding the API key,
and report it. Do not write files, change model/size/count/provider, install remote
skills, or retry automatically. If any step fails or the requested edit is not met,
report a redacted error instead of claiming success.
```

## Codes d’erreur

| Erreur                 | Traitement                                                                                                                  |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| 400 / InvalidParameter | Vérifiez la structure content, les caractéristiques de l’image, le size de sortie et les paramètres acceptés par le modèle. |
| 401                    | Vérifiez que la clé API de ce site existe, est valide et appartient au bon compte.                                          |
| 403 / 404              | Vérifiez les droits du modèle, ainsi que l’existence du canal et des ressources.                                            |
| 429                    | Limitation de débit ou crédit insuffisant ; identifiez la cause avant de réessayer avec attente progressive.                |
| 5xx                    | Erreur de service ; conservez l’identifiant de requête et évitez les générations répétées sans limite.                      |

## Références officielles

[Édition Qwen-Image](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-edit-api), [Codes d’erreur Model Studio](https\://www.alibabacloud.com/help/en/model-studio/error-code).