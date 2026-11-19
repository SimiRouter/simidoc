# API d’images au format OpenAI

Cette section utilise le format OpenAI et distingue génération, édition, génération conversationnelle et compréhension d’image. Commencez par un appel produisant une seule image avant d’augmenter la quantité ou d’utiliser un agent ; le modèle doit posséder la capacité graphique correspondante.

## Ordre d’appel

1. **Préparer la configuration** \: créez une clé dans [Gestion des clés API](https://api.dwchainless.com/keys) et copiez depuis [Modèles et prix](https://api.dwchainless.com/fr/pricing/) un ID de modèle complet pris en charge ; l’adresse est la passerelle `https://api.dwchainless.com` et l’en-tête `Authorization: Bearer $API_KEY`.
2. **Choisir un point de terminaison** \: `POST /v1/images/generations` pour le texte vers image, `POST /v1/images/edits` pour l’édition / image vers image, `POST /v1/responses` pour la génération conversationnelle et `POST /v1/chat/completions` pour la compréhension d’image.
3. **Envoyer d’abord une requête minimale** \: demandez une seule image sans streaming ; confirmez que l’authentification, le modèle et les paramètres sont valides avant d’augmenter la quantité, la taille ou de connecter un agent.
4. **Lire et vérifier** \: décodez le Base64 de `data[]` ou téléchargez l’URL, vérifiez que le fichier s’ouvre et que les dimensions et le contenu sont conformes, puis contrôlez les journaux d’utilisation.

Les paramètres complets, exemples et gestion des erreurs figurent dans les pages de protocole ci-dessous ; pour le premier appel, commencez par la [génération](/simidoc/fr/apps/api/images/openai/generations).

## Format et paramètres de requête

| API                          | Format de requête                                             | Paramètres principaux                                                               | Documentation détaillée                                              |
| ---------------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Texte vers image             | `POST /v1/images/generations`, JSON                           | `model`, `prompt` ; selon le modèle \: `n`, `size`, `quality`                       | [Paramètres de génération et code en quatre langages](/simidoc/fr/apps/api/images/openai/generations) |
| Édition / image vers image   | `POST /v1/images/edits`, JSON ou multipart, sans les mélanger | `model`, `prompt`, `images[]` ou fichier `image` ; ajouter `mask` si pris en charge | [Paramètres d’édition et code en quatre langages](/simidoc/fr/apps/api/images/openai/edits)           |
| Génération conversationnelle | `POST /v1/responses`, JSON                                    | `input`, outil de génération d’images et configuration du modèle                    | [Génération conversationnelle](/simidoc/fr/apps/api/images/openai/chat-format)                        |
| Compréhension d’image        | `POST /v1/chat/completions`, JSON                             | Dans `messages`, texte et éléments `image_url`                                      | [Compréhension d’image](/simidoc/fr/apps/api/images/openai/vision)                                    |

La consigne d’édition doit distinguer ce qu’il faut conserver et modifier. Changement de style, remplacement du fond et ajout ou retrait d’éléments sont des objectifs d’édition, pas d’autres API. Masques, références multiples et transparence nécessitent une prise en charge du modèle ; la fidélité pixel par pixel des personnes, produits ou textes n’est pas garantie.

### Spécifications de l’image

`size` exprime une largeur et une hauteur en pixels, par exemple `1024x1024`, pas une énumération universelle `1K` / `2K` / `4K` ; les dimensions acceptées varient selon le modèle. `quality` règle la qualité et `output_format` l’encodage PNG/JPEG/WebP ; ils ne remplacent pas la résolution. Un fond transparent exige aussi la prise en charge de `background: transparent` et un format PNG ou WebP.

Les trois écritures de size, l’aide-mémoire des 14 ratios et les paliers de facturation par image 1K/2K/4K sont réunis dans la [vue d’ensemble des spécifications et tarifs](/simidoc/fr/apps/api/images). Le tableau de facturation ne s’applique qu’aux modèles soumis explicitement à cette règle dans [Modèles et prix](https://api.dwchainless.com/fr/pricing/) et ne garantit pas l’acceptation de chaque dimension citée.

## Champs de réponse

| Champ / événement                                     | Signification et traitement                                                                                                                                      |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Images `data[].b64_json`                              | Image Base64 de GPT Image ; décodez-la et enregistrez le binaire, ne renommez pas le JSON en PNG.                                                                |
| Images `data[].url`                                   | Éventuellement renvoyé par les anciens modèles ou modèles compatibles acceptant les URL ; téléchargez rapidement, sans supposer ce champ présent pour GPT Image. |
| Images `usage`                                        | Données d’utilisation facultatives ; leur présence ne signifie pas forcément une facturation en tokens.                                                          |
| `image_generation.completed` / `image_edit.completed` | Événements finaux de génération / édition Images en streaming ; `partial_image` n’est qu’un aperçu intermédiaire.                                                |
| Responses `output[]`                                  | Traitez les sorties de l’outil image conversationnel, sans reprendre la structure Images `data[]`.                                                               |
| Chat `choices[].message.content`                      | Analyse textuelle de compréhension, et non image générée.                                                                                                        |

## Exemples d’appel

### Préparer la configuration

Créez une clé dans [Gestion des clés API](https://api.dwchainless.com/keys), copiez dans [Modèles et prix](https://api.dwchainless.com/fr/pricing/) l’identifiant complet d’un modèle d’image accessible avec cette clé, puis vérifiez droits, groupe et crédit. Variables à renseigner \:

| Variable    | Utilité                                                                                                              |
| ----------- | -------------------------------------------------------------------------------------------------------------------- |
| `API_KEY`   | Obligatoire ; définissez-la directement dans l’exemple, jamais dans les consignes, fichiers source, captures ou Git. |
| `MODEL`     | Obligatoire ; vérifiez séparément la prise en charge des points de terminaison de génération et d’édition.           |
| `API_URL`   | URL complète de la requête ; les exemples utilisent la passerelle `https://api.dwchainless.com`.                     |
| `IMAGE_URL` | URL HTTPS utilisée par l’exemple d’édition ; le serveur doit pouvoir accéder à une image PNG, JPEG ou WebP.          |

Les [exemples de génération](/simidoc/fr/apps/api/images/openai/generations) et d’[édition](/simidoc/fr/apps/api/images/openai/edits) proposent Python, Node.js, curl et Go. Choisissez un langage et demandez une seule image sans streaming. Les exemples Python 3.8+ et Node.js 20+ utilisent les bibliothèques standard. Enregistrez la génération dans `generate.py` ou `generate.mjs`, l’édition dans `edit.py` ou `edit.mjs`, puis lancez le fichier, par exemple `python3 generate.py` ou `node generate.mjs`. Les exemples d’édition Python et Node.js utilisent tous deux JSON `images[].image_url` et n’utilisent pas multipart.

### Démo de génération avec un agent

L’agent doit pouvoir exécuter des scripts locaux, lire les images autorisées et examiner les réponses. Cette page n’installe aucun Skill et ne donne pas d’outils à un client textuel. Conservez la connexion existante sans changer de service.

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

### Démo d’édition avec un agent

Vérifiez les droits de traitement du fichier de référence ainsi que les données personnelles et secrets commerciaux ; autorisez uniquement les fichiers nécessaires. « Conserver » désigne un objectif, pas une garantie pixel par pixel.

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

## Enregistrement et critères de fin

* Avant l’enregistrement, vérifiez le statut HTTP, le champ d’image finale, le décodage et le format réel. Une extension différente ne convertit pas le fichier. En cas d’échec, nettoyez uniquement les sorties invalides créées par cet appel, jamais les fichiers préexistants.
* Commencez par une image sans streaming. En streaming, attendez le `completed` correspondant et traitez plusieurs résultats par indice ; sans événement final, un aperçu n’est pas un résultat terminé. Images n’est pas une file asynchrone universelle renvoyant un ID à interroger.
* Vérifiez présence, ouverture, dimensions et contenu du fichier, puis le journal d’utilisation. Un succès HTTP ou l’affirmation « terminé » d’un agent ne prouve pas l’enregistrement.

## Erreurs, nouvelles tentatives et coût

Pour 400, vérifiez modèle et paramètres ; 401, la clé ; 403/404, droits, ID et chemin ; 429, crédit et limites de débit. Après 5xx, expiration ou interruption du flux, consultez d’abord journaux et résultats existants, sans renvoyer automatiquement la requête afin d’éviter doublons et doubles débits. Rapportez seulement une erreur expurgée et l’identifiant de requête, jamais la clé, le Base64 complet ou le contenu privé.

Les générations et éditions réelles peuvent être facturées. Confirmez modèle, dimensions, quantité et sortie avant l’appel. Augmenter `n`, monter de palier, changer de modèle ou réessayer exige une nouvelle confirmation. Chaque requête parallèle a ses limites, son délai et son coût ; `n` est la quantité d’une requête, pas le parallélisme. Les prix actuels et journaux font foi.

## Références officielles

* [Guide de génération d’images OpenAI](https\://developers.openai.com/api/docs/guides/image-generation)
* [API Images OpenAI](https\://developers.openai.com/api/reference/resources/images/methods/generate)
* [Entrées visuelles OpenAI](https\://developers.openai.com/api/docs/guides/images-vision)