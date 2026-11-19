# Génération d’images Qwen

## Description de l’interface

`POST /v1/images/generations`, avec un corps JSON. Les exemples utilisent la passerelle de ce site `https://api.dwchainless.com` et une `API_KEY` créée sur ce site ; le corps reprend la structure native Qwen `model`, `input.messages`, `parameters`, et la réponse est toujours au format `data[]`.

La génération texte-vers-image ne requiert qu’un élément text dans content. La consigne décrit la composition, le style visuel et le texte à rendre dans l’image.

## Paramètres de requête

| Champ                             | Type      | Obligatoire | Description                                                                                                      |
| --------------------------------- | --------- | ----------- | ---------------------------------------------------------------------------------------------------------------- |
| model                             | string    | Oui         | qwen-image-2.0-pro ou une version précise prise en charge par le canal de ce site.                               |
| input.messages                    | object\[] | Oui         | Un seul message user pour cet échange.                                                                           |
| input.messages\[].role            | string    | Oui         | Fixé à user.                                                                                                     |
| input.messages\[].content\[].text | string    | Oui         | Consigne en chinois ou anglais ; un seul élément text par tour.                                                  |
| parameters.size                   | string    | Non         | Largeur × hauteur, par exemple 2048 × 2048 ; la série 2.0 accepte un total de pixels entre 512×512 et 2048×2048. |
| parameters.n                      | integer   | Non         | 1 par défaut ; la série 2.0 accepte 1–6.                                                                         |
| parameters.negative\_prompt       | string    | Non         | Contenu à exclure, 500 caractères maximum.                                                                       |
| parameters.prompt\_extend         | boolean   | Non         | true par défaut, développe automatiquement la consigne positive.                                                 |
| parameters.watermark              | boolean   | Non         | Ajout d’un filigrane visible ; respectez les obligations applicables d’identification des contenus synthétiques. |

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
{"created":1760000000,"data":[{"url":"https://example.com/generated.png","b64_json":null,"revised_prompt":"..."}]}
```

## Appel depuis le code

Renseignez `API_URL` et `API_KEY` en tête du code. `API_URL` est l’adresse de la passerelle de ce site `https://api.dwchainless.com/v1/images/generations` et `API_KEY` est une clé créée sur ce site ; la disponibilité des modèles est indiquée dans [Modèles et prix](https://api.dwchainless.com/fr/pricing/). Les exemples n’utilisent que la bibliothèque standard \: ils envoient une requête et affichent le JSON renvoyé, sans télécharger ni enregistrer l’image automatiquement.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/generations"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "qwen-image-2.0-pro",
      "input": {
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "text": "生成一张浅蓝色背景的活动海报，不要文字。"
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
    const API_URL = 'https://api.dwchainless.com/v1/images/generations';
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
                  text: '生成一张浅蓝色背景的活动海报，不要文字。'
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
    API_URL="https://api.dwchainless.com/v1/images/generations"
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
                  "text": "生成一张浅蓝色背景的活动海报，不要文字。"
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
        apiURL := "https://api.dwchainless.com/v1/images/generations"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "qwen-image-2.0-pro",
            "input": {
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "text": "生成一张浅蓝色背景的活动海报，不要文字。"
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
Read this Qwen image protocol page and its generation reference first. Use the
existing API_KEY and API_URL from this site's gateway; never print, paste, commit,
or store the key in source files. Use the documented qwen-image-2.0-pro model only
after checking availability and pricing. For this one approved request, POST once
to /v1/images/generations with the native Qwen body: one user message, one text
content item, parameters.n=1 and size=1024*1024 if supported. Image brief: a calm
blue library with a small robot reading, watercolor illustration, no lettering.
Print the returned JSON and inspect data[].url or data[].b64_json; report the final
image URL without forwarding the API key. JSON or a URL alone is not a saved image.
Do not switch model/provider, increase size/count, write files, install remote
skills, or automatically retry an error or timeout. Ask before another paid request.
```

## Codes d’erreur

| Erreur                 | Traitement                                                                                                              |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 400 / InvalidParameter | Vérifiez le JSON, la structure content, les caractéristiques de l’image, size et les paramètres acceptés par le modèle. |
| 401                    | Vérifiez que la clé API de ce site existe, est valide et appartient au bon compte.                                      |
| 403 / 404              | Vérifiez les droits du modèle, ainsi que l’existence du canal et des ressources.                                        |
| 429                    | Limitation de débit ou crédit insuffisant ; identifiez la cause avant de réessayer avec attente progressive.            |
| 5xx                    | Erreur de service ; conservez l’identifiant de requête et évitez les générations répétées sans limite.                  |

## Références officielles

[Génération Qwen-Image](https\://www.alibabacloud.com/help/en/model-studio/qwen-image-api), [Codes d’erreur Model Studio](https\://www.alibabacloud.com/help/en/model-studio/error-code).