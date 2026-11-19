# Génération d’images

## Description de l’interface

`POST /v1/images/generations` génère une ou plusieurs images selon prompt.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $API_KEY`. L’API directe officielle OpenAI est `https://api.openai.com`. Authentification \: Bearer avec une clé OpenAI. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

Cette page utilise les paramètres GPT Image. Les modèles d’image compatibles OpenAI de différents fournisseurs peuvent accepter des tailles, qualités et formats distincts ; ces différences ne constituent pas un standard officiel unique.

## Démarrage rapide

1. **Préparer la configuration** \: créez une clé dans [Gestion des clés API](https://api.dwchainless.com/keys) et copiez depuis [Modèles et prix](https://api.dwchainless.com/fr/pricing/) un ID de modèle compatible avec Images API.
2. **Envoyer la requête** \: envoyez du JSON à `https://api.dwchainless.com/v1/images/generations` avec l’en-tête `Authorization: Bearer $API_KEY` ; le corps doit contenir au moins `model` et `prompt`.
3. **Lire le résultat** \: le succès exige un HTTP 2xx et un `data[]` non vide ; décodez et enregistrez le `data[].b64_json` de GPT Image.
4. **Confirmer la fin** \: vérifiez que le fichier s’ouvre et que ses dimensions correspondent, puis consultez le journal d’utilisation.

La requête minimale suit ; une fois qu’elle fonctionne, ajustez le nombre, les dimensions ou le streaming \:

```bash
API_URL="https://api.dwchainless.com/v1/images/generations"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
    "n": 1,
    "size": "1024x1024",
    "output_format": "png"
  }'
```

## Paramètres de requête

Le corps de requête est en JSON.

| Champ               | Type    | Obligatoire | Description                                                                                                                                                                                       |
| ------------------- | ------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model               | string  | Oui         | ID d’un modèle d’image acceptant Images API.                                                                                                                                                      |
| prompt              | string  | Oui         | Décrivez précisément sujet, composition, style et texte à afficher.                                                                                                                               |
| n                   | integer | Non         | Nombre d’images, de 1 à 10 en GPT Image natif OpenAI ; 1 dans l’exemple.                                                                                                                          |
| size                | string  | Non         | Forme native OpenAI \: WIDTHxHEIGHT (largeur et hauteur multiples de 16, ratio entre 1\:3 et 3\:1) ou auto ; SimiRouter accepte aussi ratio + resolution, et les limites varient selon le modèle. |
| resolution          | string  | Non         | Extension SimiRouter \: palier 1k, 2k ou 4k utilisé avec un ratio, pas une valeur en pixels ; l’API OpenAI native n’a pas ce champ.                                                               |
| aspect\_ratio       | string  | Non         | Extension SimiRouter \: ratio distinct comme 3\:4 ; un ratio dans size prime.                                                                                                                     |
| quality             | string  | Non         | auto, low, medium, high ; certains nouveaux modèles proposent aussi xhigh et max.                                                                                                                 |
| output\_format      | string  | Non         | png, jpeg (exemples) ou webp ; le schéma officiel liste aussi gif et svg si le modèle et l’accès au projet le permettent.                                                                         |
| output\_compression | integer | Non         | Qualité de compression JPEG/WebP de 0 à 100, sans effet sur PNG.                                                                                                                                  |
| background          | string  | Non         | auto, opaque ou transparent ; la transparence exige un modèle compatible et PNG/WebP.                                                                                                             |
| moderation          | string  | Non         | auto ou low si accepté ; ne garantit pas le respect de la politique de contenu.                                                                                                                   |
| response\_format    | string  | Non         | Certains modèles compatibles acceptent url ou b64\_json ; GPT Image natif ne l’utilise pas.                                                                                                       |
| stream              | boolean | Non         | true utilise les événements SSE d’image.                                                                                                                                                          |
| partial\_images     | integer | Non         | Avec stream=true, demande de 0 à 3 images intermédiaires ; attendez toujours l’événement final.                                                                                                   |

GPT Image renvoie directement les images en Base64 ; ne vous appuyez pas sur l’ancien response\_format=url/b64\_json. Certains modèles compatibles peuvent utiliser ce champ pour choisir une URL ou du Base64, selon la documentation du modèle et la réponse réelle. style=vivid/natural ne s’applique pas non plus \: décrivez le style dans prompt.

### Exemple de requête

```json
{
  "model": "gpt-image-2",
  "prompt": "一只小机器人在图书馆阅读，水彩插画，柔和蓝金色调，不要文字。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

## Dimensions et format

K désigne couramment une résolution, et non la taille du fichier ou un réglage de qualité. Les dimensions dépendent du modèle et du rapport de forme. À rapport identique, doubler les deux côtés quadruple le nombre de pixels. Ces exemples expliquent les termes, sans constituer des dimensions acceptées par tous les modèles.

OpenAI utilise `size` pour renseigner les dimensions acceptées, comme `1024x1024`, et non le libellé `1K` ; `quality` et `output_format` règlent séparément la qualité et le format.

| Libellé de résolution | Exemples de pixels courants (sans garantie de prise en charge) |
| --------------------- | -------------------------------------------------------------- |
| 1K                    | 1024×1024 · Environ mille pixels par côté                      |
| 2K                    | 2048×2048 · Environ deux mille pixels par côté                 |
| 4K                    | 4096×4096 / 3840×2160 · Environ quatre mille pixels par côté   |

Les paliers de facturation par image du site obéissent à des règles distinctes ; ces exemples de résolution ne définissent pas la facturation. [Caractéristiques et règles de facturation](/simidoc/fr/apps/api/images).

### Trois façons d’écrire size

Certaines passerelles compatibles OpenAI acceptent aussi un ratio avec résolution ou une taille automatique ; leur prise en compte dépend du modèle et de la passerelle. Si elles ne sont pas prises en charge, revenez aux pixels explicites.

| Forme                          | Extrait de requête                 | Remarques                                                             |
| ------------------------------ | ---------------------------------- | --------------------------------------------------------------------- |
| Pixels explicites (recommandé) | `{"size":"1536x2048"}`             | Le plus direct ; évite les écarts de conversion des préréglages.      |
| Ratio + résolution             | `{"size":"3:4","resolution":"2k"}` | Utilise le préréglage 2K, 3\:4 ; resolution n’accepte que 1k, 2k, 4k. |
| Taille automatique             | `{"size":"auto"}`                  | Le modèle choisit largeur et hauteur ; aucune taille fixe garantie.   |

* Un ratio dans size prime sur un aspect\_ratio distinct ; des pixels explicites ou auto priment sur les préréglages de ratio.
* Indiquez le palier dans resolution ; n’envoyez pas size=2k. Utilisez un x minuscule comme séparateur.
* Pour gpt-image-2, la limite officielle des tailles libres est 3840×2160 ; les combinaisons plus grandes comme 4096×4096 renvoient généralement une erreur de paramètre. La ligne 4K illustre un palier, pas une taille garantie.
* Pour les 14 ratios courants en 1K, 2K et 4K, voir [Caractéristiques et règles de facturation](/simidoc/fr/apps/api/images).

## Valeur de retour

| Champ                                                | Type    | Description                                                                                                         |
| ---------------------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------- |
| created                                              | integer | Heure de création, en secondes Unix.                                                                                |
| data\[]                                              | array   | Liste de résultats ; ne supposez pas la présence d’un premier élément.                                              |
| data\[].b64\_json                                    | string  | Base64 des octets d’image ; format utilisé par GPT Image.                                                           |
| data\[].url                                          | string  | Uniquement sur les modèles compatibles acceptant les URL en sortie ; pas un champ garanti de GPT Image.             |
| data\[].revised\_prompt                              | string  | Consigne réécrite renvoyée par certains anciens modèles ou modèles compatibles ; pas un champ garanti de GPT Image. |
| output\_format / size / quality / background         | string  | Configuration de sortie effective facultative.                                                                      |
| usage                                                | object  | Données d’utilisation facultatives ; présence et granularité dépendent du modèle et du service.                     |
| usage.input\_tokens / output\_tokens / total\_tokens | integer | Si présents, tokens d’entrée, de sortie et totaux.                                                                  |
| usage.input\_tokens\_details                         | object  | Détails facultatifs comme image\_tokens et text\_tokens.                                                            |
| X-Request-Id                                         | string  | En-tête de réponse, pas un champ JSON ; conservez-le pour le support ou le diagnostic.                              |

Une data\[].url renvoyée peut expirer ; ne joignez pas la clé API lors du téléchargement. Le Base64 suivant est seulement un PNG minimal illustrant la structure, pas un résultat réel de la consigne ci-dessus.

```json
{
  "created": 1760000000,
  "data": [
    {
      "b64_json": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j0Z0AAAAASUVORK5CYII="
    }
  ],
  "output_format": "png"
}
```

### Génération en streaming

Les modèles compatibles acceptent stream=true \: image\_generation.partial\_image fournit les aperçus et image\_generation.completed l’image finale et l’utilisation. Une image partielle n’est pas finale ; sans completed après une coupure, ne marquez pas l’aperçu comme terminé. L’interface ne renvoie pas d’ID général de tâche de fond à interroger.

## Exemples de code

Renseignez `API_URL` et `API_KEY` en tête du code; les exemples utilisent `gpt-image-2`. `API_URL` est l’URL complète de la requête et pointe par défaut vers la passerelle `https://api.dwchainless.com`. Les exemples n’utilisent que les bibliothèques standard, envoient une requête et affichent le JSON reçu ; ils n’enregistrent pas l’image automatiquement.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/generations"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1,
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
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        prompt: '一只小机器人在图书馆阅读，水彩插画，不要文字。',
        size: '1024x1024',
        n: 1,
      }),
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
        "model": "gpt-image-2",
        "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
        "size": "1024x1024",
        "n": 1
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
            "model": "gpt-image-2",
            "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
            "size": "1024x1024",
            "n": 1
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

Copiez cette tâche dans un agent capable d’exécuter des scripts locaux et d’examiner la réponse. Définissez d’abord les variables selon [la configuration de ce protocole](/simidoc/fr/apps/api/images/openai). Ne mettez jamais la clé dans la consigne.

```text
Read this OpenAI image protocol page and its generation reference first. Use the
SimiRouter request URL in API_URL (default gateway https://api.dwchainless.com) and the
image model in MODEL. Set API_KEY directly in the example; never print, paste, commit,
or store it in source files. For this one approved request, use POST
/v1/images/generations with n=1, size=1024x1024, stream=false and output_format=png only
after verifying the model supports these parameters. Image brief: a calm blue library
with a small robot reading, watercolor illustration, no lettering. Print the returned
JSON and inspect data[].b64_json; do not write an image file. Confirm that
data[].b64_json contains non-empty Base64 data before reporting completion. Do not
install remote skills, switch providers/models/billing groups, increase size/count,
write files, or retry after timeout or ambiguous failure without approval. If the
request or validation fails, report a redacted error, not success.
```

## Codes d’erreur

| Statut HTTP     | Signification ou type d’erreur du fournisseur                 | Traitement                                                                                                                       |
| --------------- | ------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 400             | Requête invalide                                              | Vérifiez les champs obligatoires, le JSON, les paramètres du modèle et la longueur du contexte.                                  |
| 401             | Échec de l’authentification                                   | Vérifiez que la clé est présente, valide et rattachée au bon compte.                                                             |
| 403 / 404       | Accès interdit / ressource introuvable                        | Vérifiez les autorisations du modèle, l’ID de ressource et l’URL.                                                                |
| 413             | Corps de requête ou image trop volumineux                     | Privilégiez les URL d’image ; réduisez la taille Base64 ou les dimensions.                                                       |
| 429             | Limite de débit ou de quota                                   | Distinguez limitation de débit et crédit insuffisant à l’aide du corps de réponse ; réessayer ne résout pas un manque de crédit. |
| 500 / 502 / 503 | Erreur de service / amont occupé / indisponibilité temporaire | Conservez l’identifiant de requête et limitez les nouvelles tentatives avec attente progressive aux erreurs temporaires.         |

Les erreurs natives OpenAI contiennent généralement `error.message`, `error.type`, `error.param`, `error.code` ; `param`, `code` peuvent être `null` ; ne supposez pas que ces champs existent toujours ou correspondent au code HTTP. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont. Si data est vide, si les données d’image manquent ou s’il n’y a qu’un aperçu, HTTP 200 ne suffit pas pour déclarer la génération terminée.

La génération et l’édition peuvent prendre de dizaines de secondes à plusieurs minutes ; définissez un délai client suffisant, car une requête en attente n’est pas un échec. Après un délai dépassé, une coupure de flux ou un 5xx, vérifiez d’abord si la requête a déjà été exécutée avant de réessayer, pour éviter une génération et une facturation en double. En cas de refus pour politique de contenu (souvent 400), révisez la consigne ou l’image de référence au lieu de réessayer à l’identique.

## Références officielles

* [OpenAI Create image](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [Guide OpenAI de génération d’images](https\://developers.openai.com/api/docs/guides/image-generation)
* [Gestion des erreurs OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)