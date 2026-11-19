# Génération d’images conversationnelle

## Description de l’interface

`POST /v1/responses` déclare image\_generation dans tools pour qu’un modèle principal compatible génère depuis les entrées. Le model principal est conversationnel ; choisissez les options du modèle d’outil image selon les capacités officielles courantes.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $API_KEY`. L’API directe officielle OpenAI est `https://api.openai.com`. Authentification \: Bearer avec une clé OpenAI. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

La génération conversationnelle native OpenAI utilise image\_generation dans Responses, pas une convention de liens Markdown renvoyés par Chat Completions ordinaire. Un fournisseur compatible renvoyant des liens d’image dans Chat emploie une extension, pas le standard OpenAI.

## Paramètres de requête

| Champ                                | Type            | Obligatoire | Description                                                                                                                                   |
| ------------------------------------ | --------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| model                                | string          | Oui         | Modèle principal Responses acceptant image\_generation.                                                                                       |
| input                                | string / array  | Oui         | Consigne textuelle ; peut inclure input\_image pour l’édition.                                                                                |
| tools\[].type                        | string          | Oui         | image\_generation.                                                                                                                            |
| tools\[].output\_format              | string          | Non         | png, jpeg ou webp ; png dans l’exemple.                                                                                                       |
| tools\[].size / quality / background | string          | Non         | Dimensions, qualité et fond, si l’outil les accepte.                                                                                          |
| tool\_choice                         | string / object | Non         | auto laisse le modèle décider ; imposer l’outil nécessite le format qu’il accepte.                                                            |
| previous\_response\_id               | string          | Non         | Continue une réponse amont conservée, dans un contexte accessible commun ; la passerelle ne fournit pas d’interface générale de consultation. |
| stream                               | boolean         | Non         | true utilise le flux d’événements Responses.                                                                                                  |

### Exemple de requête

```json
{
  "model": "gpt-5.5",
  "input": "生成一张小机器人在图书馆阅读的水彩插画，浅蓝色背景，不要文字。",
  "tools": [
    {
      "type": "image_generation",
      "model": "gpt-image-2",
      "output_format": "png"
    }
  ],
  "stream": false
}
```

## Valeur de retour

| Champ                       | Type          | Description                                                                                            |
| --------------------------- | ------------- | ------------------------------------------------------------------------------------------------------ |
| id / status                 | string        | ID et état final de réponse ; seul completed indique une réponse complète.                             |
| output\[].type              | string        | Le résultat de l’outil est image\_generation\_call ; un message peut aussi être présent.               |
| output\[].id / status       | string        | ID de l’appel image et état d’exécution de l’outil.                                                    |
| output\[].result            | string        | Base64 du résultat final de l’appel, pas data\[].b64\_json.                                            |
| output\[].revised\_prompt   | string        | Consigne réécrite utilisée par l’outil, si prise en charge.                                            |
| output\[].content\[].text   | string        | Explications éventuellement présentes dans un élément message.                                         |
| usage                       | object        | Utilisation du modèle principal ; les frais de l’outil d’image ne se limitent pas aux tokens textuels. |
| error / incomplete\_details | object / null | Raisons d’échec et d’incomplétude.                                                                     |

```json
{
  "id": "resp_image_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ig_example",
      "type": "image_generation_call",
      "status": "completed",
      "result": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "error": null,
  "incomplete_details": null
}
```

Le Base64 est seulement un PNG minimal illustrant la structure. Pour une édition ultérieure, envoyez l’image comme input\_image avec de nouvelles instructions ou utilisez previous\_response\_id si le service accepte et conserve le contexte. Un ID de réponse n’est pas une ressource de fichier universelle entre canaux.

## Exemples de code

Renseignez `API_URL` et `API_KEY` en tête du code; les exemples utilisent `gpt-5.5` comme modèle principal et `gpt-image-2` comme modèle de l’outil image. `API_URL` est l’URL complète de la requête et pointe par défaut vers la passerelle `https://api.dwchainless.com`. Les exemples n’utilisent que les bibliothèques standard, envoient une requête et affichent le JSON reçu ; ils n’enregistrent pas l’image automatiquement.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/responses"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
      "tools": [
        {
          "type": "image_generation",
          "model": "gpt-image-2"
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
    const API_URL = 'https://api.dwchainless.com/v1/responses';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        input: '生成一张小机器人在图书馆阅读的水彩插画，不要文字。',
        tools: [
          {
            type: 'image_generation',
            model: 'gpt-image-2'
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/responses"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
        "tools": [
          {
            "type": "image_generation",
            "model": "gpt-image-2"
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
        apiURL := "https://api.dwchainless.com/v1/responses"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "input": "生成一张小机器人在图书馆阅读的水彩插画，不要文字。",
            "tools": [
                {
                    "type": "image_generation",
                    "model": "gpt-image-2"
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

Les erreurs natives OpenAI contiennent généralement `error.message`, `error.type`, `error.param`, `error.code` ; `param`, `code` peuvent être `null` ; ne supposez pas que ces champs existent toujours ou correspondent au code HTTP. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont. Une réponse completed sans image\_generation\_call.result peut n’avoir produit que du texte ; vérifiez la sélection d’outil et les éléments renvoyés, sans inventer d’image.

## Références officielles

* [Génération d’images conversationnelle OpenAI](https\://developers.openai.com/api/docs/guides/image-generation)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [Gestion des erreurs OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)