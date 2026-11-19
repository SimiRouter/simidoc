# Édition et image vers image

## Description de l’interface

`POST /v1/images/edits` reçoit images de référence et consignes puis renvoie une image éditée. Permet de changer le fond ou le style, ajouter ou retirer des éléments et combiner plusieurs références.

Adresse d’intégration \: `https://api.dwchainless.com`, avec l’en-tête `Authorization: Bearer $API_KEY`. L’API directe officielle OpenAI est `https://api.openai.com`. Authentification \: Bearer avec une clé OpenAI. Choisissez un modèle accessible au compte et prenant en charge la capacité voulue.

Accepte les références JSON images\[] et les fichiers multipart. Les exemples transmettent une URL HTTPS d’image accessible au serveur via JSON `images[].image_url` ; ils n’utilisent pas multipart.

## Démarrage rapide

1. **Préparer la configuration** \: créez une clé dans [Gestion des clés API](https://api.dwchainless.com/keys) et copiez depuis [Modèles et prix](https://api.dwchainless.com/fr/pricing/) un ID de modèle d’image acceptant l’édition.
2. **Préparer les images de référence** \: utilisez des URL HTTPS accessibles au serveur ou téléversez des fichiers locaux via multipart ; ne mélangez pas les deux dans une requête.
3. **Envoyer la requête** \: envoyez à `https://api.dwchainless.com/v1/images/edits` un JSON contenant `model`, `prompt` et les références d’image ; utilisez l’en-tête `Authorization: Bearer $API_KEY`.
4. **Lire et vérifier** \: le succès exige un HTTP 2xx et un `data[]` non vide ; décodez `data[].b64_json` ou téléchargez `data[].url`, puis vérifiez le fichier, les dimensions et le contenu.

Pour le premier appel, éditez une seule image sans streaming ; une fois que cela fonctionne, ajoutez des références ou activez le streaming.

## Paramètres de requête

| Champ                | Type    | Obligatoire      | Description                                                                                                                                                                                       |
| -------------------- | ------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                | string  | Oui (passerelle) | Choisissez explicitement un modèle d’image acceptant l’édition plutôt que de dépendre du défaut amont.                                                                                            |
| images               | array   | Oui (JSON)       | Liste de références ; GPT Image natif accepte au maximum 16 images, avec d’éventuelles limites plus strictes selon le modèle.                                                                     |
| images\[].image\_url | string  | Conditionnel     | URL HTTPS ou data\:image/...;base64,... ; cet exemple utilise une URL HTTPS.                                                                                                                      |
| images\[].file\_id   | string  | Conditionnel     | ID de ressource Files officielle, au choix avec image\_url ; ne supposez pas sa disponibilité sur la passerelle.                                                                                  |
| prompt               | string  | Oui              | Précisez ce qui doit changer et ce qui doit être conservé.                                                                                                                                        |
| mask                 | object  | Non              | En JSON, référence mask.image\_url ou mask.file\_id ; les règles de masque varient selon le modèle.                                                                                               |
| image / image\[]     | file    | Oui (multipart)  | Champ multipart d’une ou plusieurs images ; ne pas mélanger avec images en JSON.                                                                                                                  |
| mask (multipart)     | file    | Non              | Masque PNG dont les zones transparentes indiquent la zone d’édition ; dimensions et exigences doivent correspondre à la source et au modèle.                                                      |
| input\_fidelity      | string  | Non              | Uniquement pour les modèles acceptant ce paramètre ; toutes les générations GPT Image ne l’acceptent pas nécessairement.                                                                          |
| n                    | integer | Non              | Nombre d’images, de 1 à 10 en GPT Image natif OpenAI ; 1 dans l’exemple.                                                                                                                          |
| size                 | string  | Non              | Forme native OpenAI \: WIDTHxHEIGHT (largeur et hauteur multiples de 16, ratio entre 1\:3 et 3\:1) ou auto ; SimiRouter accepte aussi ratio + resolution, et les limites varient selon le modèle. |
| resolution           | string  | Non              | Extension SimiRouter \: palier 1k, 2k ou 4k utilisé avec un ratio, pas une valeur en pixels ; l’API OpenAI native n’a pas ce champ.                                                               |
| aspect\_ratio        | string  | Non              | Extension SimiRouter \: ratio distinct comme 3\:4 ; un ratio dans size prime.                                                                                                                     |
| quality              | string  | Non              | auto, low, medium, high ; certains nouveaux modèles proposent aussi xhigh et max.                                                                                                                 |
| output\_format       | string  | Non              | png, jpeg (exemples) ou webp ; le schéma officiel liste aussi gif et svg si le modèle et l’accès au projet le permettent.                                                                         |
| output\_compression  | integer | Non              | Qualité de compression JPEG/WebP de 0 à 100, sans effet sur PNG.                                                                                                                                  |
| background           | string  | Non              | auto, opaque ou transparent ; la transparence exige un modèle compatible et PNG/WebP.                                                                                                             |
| moderation           | string  | Non              | auto ou low si accepté ; ne garantit pas le respect de la politique de contenu.                                                                                                                   |
| response\_format     | string  | Non              | Certains modèles compatibles acceptent url ou b64\_json ; GPT Image natif ne l’utilise pas.                                                                                                       |
| stream               | boolean | Non              | true utilise les événements SSE d’image.                                                                                                                                                          |
| partial\_images      | integer | Non              | Avec stream=true, demande de 0 à 3 images intermédiaires ; attendez toujours l’événement final.                                                                                                   |

Choisissez JSON ou multipart ; pour multipart, le client doit produire automatiquement le Content-Type avec boundary. Un masque ne garantit pas une édition précise au pixel ; vérifiez l’image finale.

## Choisir le mode d’envoi des images

Les images de référence peuvent entrer de quatre façons ; choisissez-en une selon votre environnement et ne les mélangez pas dans une même requête \:

| Forme             | Champ                            | Cas d’usage                                                              |
| ----------------- | -------------------------------- | ------------------------------------------------------------------------ |
| URL JSON          | `images[].image_url`             | Image publique accessible au serveur                                     |
| Base64 JSON       | `images[].image_url` en data URL | Image petite, à ne pas exposer à une URL publique                        |
| fichier multipart | `image` ou `image[]`             | Fichiers locaux téléversés par le client                                 |
| ID Files          | `images[].file_id`               | Image déjà téléversée via Files officiel et ID accepté par la passerelle |

Les requêtes JSON utilisent `Content-Type: application/json` ; pour multipart, le client doit générer le boundary du `Content-Type`, ne l’écrivez pas à la main.

### Structure de requête JSON

L’exemple JSON utilise directement une URL HTTPS accessible au serveur.

```json
{
  "model": "gpt-image-2",
  "images": [
    {
      "image_url": "https://example.com/reference.png"
    }
  ],
  "prompt": "保留主体形状和布局，将图片改成水彩插画，背景改为浅蓝色。",
  "n": 1,
  "size": "1024x1024",
  "output_format": "png"
}
```

### Structure de requête multipart

Utilisez le champ `image` pour une référence locale ; utilisez `image[]` pour plusieurs images et décrivez le rôle de chacune dans l’ordre \:

```bash
API_URL="https://api.dwchainless.com/v1/images/edits"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -F "model=gpt-image-2" \
  -F "prompt=保留主体和构图，将背景改为浅蓝色。" \
  -F "image=@reference.png" \
  -F "size=1024x1024" \
  -F "n=1"
```

## Rédiger la consigne d’édition

Une consigne d’édition doit préciser à la fois ce qui est conservé et ce qui change ; écrire seulement « en style aquarelle » peut faire redessiner toute la scène. Organisez-la en « conserver + modifier + contrainte » \:

| Cas                                  | Points de la consigne                                                                 | Exemple                                                                                         |
| ------------------------------------ | ------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Conserver une personne ou un produit | Préciser que sujet, pose, composition et texte restent inchangés                      | Conservez la pose et les vêtements de la personne, changez seulement le fond en bleu clair.     |
| Changement de style                  | Indiquer le style cible et la mise en page à conserver                                | Passez en illustration aquarelle en conservant la composition et la position du sujet.          |
| Retouche locale                      | Nommer la zone à modifier ; utiliser `mask` si le modèle le permet                    | Modifiez seulement la tasse en bas à gauche, laissez le reste inchangé.                         |
| Composition multi-images             | Décrire le rôle de chaque image, les relations entre sujets et la mise en page finale | La première image est la personne, la seconde le décor ; placez la personne au centre du décor. |

« Conserver » est un objectif, pas une garantie au pixel ; les détails des personnes, produits et textes peuvent changer, et tout contenu lié à une identité ou une marque doit être vérifié manuellement. La transparence exige un modèle acceptant `background: transparent` et une sortie PNG ou WebP.

## Dimensions et format

`size` indique les dimensions en pixels acceptées par le modèle, comme `1024x1024` ; `quality` contrôle la qualité et `output_format` l’encodage PNG/JPEG/WebP. Les dimensions du résultat d’édition viennent de `size` (par défaut `auto`, le modèle choisit) et ne doivent pas nécessairement correspondre à l’image de référence.

Les paliers de facturation 1K, 2K et 4K par image du site et les libellés de résolution des fournisseurs sont deux règles distinctes ; voir [Caractéristiques et facturation des images](/simidoc/fr/apps/api/images) pour les trois écritures de size, les 14 ratios et les limites de facturation.

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

Le Base64 est un PNG minimal illustrant les champs. Un data\[].url renvoyé peut expirer ; ne joignez pas la clé API lors du téléchargement de l’image. L’édition en streaming utilise image\_edit.partial\_image et image\_edit.completed ; seul l’événement final valide la fin. L’image vers image ne garantit pas une conservation pixel par pixel des détails de personnes, produits ou textes.

## Exemples de code

Renseignez `API_URL` et `API_KEY` en tête du code; les exemples utilisent `gpt-image-2`. `API_URL` est l’URL complète de la requête et pointe par défaut vers la passerelle `https://api.dwchainless.com`. `IMAGE_URL` doit être une URL HTTPS d’image accessible au serveur. Les exemples n’utilisent que les bibliothèques standard, envoient une requête et affichent le JSON reçu ; ils n’enregistrent pas l’image automatiquement.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/images/edits"
    API_KEY = "PASTE_API_KEY_HERE"

    body = {
        "model": "gpt-image-2",
        "images": [{"image_url": "https://example.com/reference.png"}],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
    const API_URL = 'https://api.dwchainless.com/v1/images/edits';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-image-2',
        images: [
          {
            image_url: 'https://example.com/reference.png',
          },
        ],
        prompt: '保留主体和构图，将背景改为浅蓝色。',
        size: '1024x1024',
        n: 1,
      }),
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
        "model": "gpt-image-2",
        "images": [
          {
            "image_url": "https://example.com/reference.png"
          }
        ],
        "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
        apiURL := "https://api.dwchainless.com/v1/images/edits"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-image-2",
            "images": [
                {
                    "image_url": "https://example.com/reference.png"
                }
            ],
            "prompt": "保留主体和构图，将背景改为浅蓝色。",
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
Read this OpenAI image protocol page and its editing reference first. Set API_KEY,
MODEL, and API_URL directly in the example; use the configured SimiRouter request URL;
never reveal the key or change the existing connection. Use only the authorized HTTPS
image URL in IMAGE_URL. Use POST /v1/images/edits with JSON images[]; do not set
multipart Content-Type or send local files. Keep the subject and layout; change only the
background to pale blue. Request one PNG at 1024x1024 with stream=false only if the
selected model supports it. Print the returned JSON and inspect data[].b64_json; do not
write an image file. Confirm that data[].b64_json contains non-empty Base64 data and
report any unmet requirement. Do not upload unrelated files, change
size/count/model/provider, install remote skills, or retry automatically after an error
or timeout. Ask before another paid request.
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

Les erreurs natives OpenAI contiennent généralement `error.message`, `error.type`, `error.param`, `error.code` ; `param`, `code` peuvent être `null` ; ne supposez pas que ces champs existent toujours ou correspondent au code HTTP. La passerelle peut renvoyer une erreur d’authentification, de routage ou de quota avant que la requête atteigne le fournisseur ; le seul code HTTP ne permet pas d’attribuer l’erreur à l’amont. Image invalide, MIME incohérent, dimensions de masque incorrectes ou paramètre refusé sont des erreurs d’entrée à corriger avant toute nouvelle soumission.

Une édition peut prendre de dizaines de secondes à plusieurs minutes ; définissez un délai client suffisant, car une requête en attente n’est pas un échec. Après un délai dépassé, une coupure de flux ou un 5xx, vérifiez d’abord si la requête a déjà été exécutée avant de réessayer, pour éviter une génération et une facturation en double. En cas de refus pour politique de contenu (souvent 400), révisez la consigne ou l’image de référence au lieu de réessayer à l’identique.

## Références officielles

* [OpenAI Create image edit](https\://developers.openai.com/api/reference/resources/images/methods/edit)
* [Génération et édition d’images OpenAI](https\://developers.openai.com/api/docs/guides/image-generation)
* [Gestion des erreurs OpenAI](https\://developers.openai.com/api/docs/guides/error-codes)