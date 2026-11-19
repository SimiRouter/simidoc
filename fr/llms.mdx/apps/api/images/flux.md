# Génération d’images BFL FLUX

## Aperçu

L’API FLUX de Black Forest Labs (BFL) suit un modèle asynchrone « soumettre une tâche + interroger le résultat ». La requête de soumission ne renvoie que l’ID de tâche et `polling_url` ; l’URL signée de l’image n’est lisible dans le résultat d’interrogation qu’une fois la génération terminée.

| Ce que vous voulez faire                     | Entrée                      | Sortie                         | Endpoint                                        |
| -------------------------------------------- | --------------------------- | ------------------------------ | ----------------------------------------------- |
| Générer une image à partir de texte          | `prompt`, `width`, `height` | `id` de tâche et `polling_url` | `POST https://api.bfl.ai/v1/flux-pro-1.1`       |
| Générer une image large selon un ratio       | `prompt`, `aspect_ratio`    | `id` de tâche et `polling_url` | `POST https://api.bfl.ai/v1/flux-pro-1.1-ultra` |
| Générer ou modifier à partir d’une référence | `prompt` + `input_image`    | `id` de tâche et `polling_url` | `POST https://api.bfl.ai/v1/flux-2-pro` etc.    |
| Récupérer l’image finale                     | `polling_url`               | URL signée `result.sample`     | `GET {polling_url}`                             |

## Concepts clés

* **Dimensions via `width` / `height`** \: FLUX 1.1 pro accepte une largeur et une hauteur de 256 à 1440, obligatoirement multiples de 32. Ce ne sont ni des paliers de résolution, ni une chaîne `size`.
* **Ultra utilise `aspect_ratio`** \: `/v1/flux-pro-1.1-ultra` n’a pas de champs de largeur et de hauteur et utilise `aspect_ratio` (`16:9` par défaut, avec une plage documentée de `21:9` à `9:21`).
* **`seed` contrôle la reproductibilité** \: un même prompt, les mêmes paramètres et le même `seed` servent à comparer différents réglages ; cela ne garantit pas une image identique entre modèles ou versions.
* **`steps` / `guidance` n’existent que sur certains modèles** \: FLUX.2 flex prend en charge `steps` (1–50) et `guidance` (1.5–10.0) ; FLUX 1.1 pro n’a pas ces deux champs.
* **Soumission et résultat sont deux requêtes** \: la soumission renvoie `id`, `polling_url` et éventuellement `cost` ; l’image n’est lue qu’après `Ready` dans `result.sample`, le traitement correspond à `Pending`, et un échec ou une modération de contenu renvoie l’état correspondant.
* **L’URL signée est valide environ 10 minutes** \: `result.sample` expire vite ; téléchargez et réarchivez rapidement, et ne traitez pas cette adresse comme un lien public durable.

## Spécifications et capacités

| Endpoint                 | Contrôle des dimensions                                               | Images de référence                                    | Autres champs principaux                                             | Format de retour                    |
| ------------------------ | --------------------------------------------------------------------- | ------------------------------------------------------ | -------------------------------------------------------------------- | ----------------------------------- |
| `/v1/flux-pro-1.1`       | `width`, `height` \: 256–1440, multiples de 32 ; 1024×768 par défaut  | `image_prompt` (Base64, référence de style Flux Redux) | `seed`, `prompt_upsampling`, `safety_tolerance` 0–6, `output_format` | `result.sample` après interrogation |
| `/v1/flux-pro-1.1-ultra` | Pas de `width` / `height` ; utilise `aspect_ratio`, `16:9` par défaut | `image_prompt`, `image_prompt_strength` 0.0–1.0        | `seed`, `prompt_upsampling`, `raw`, `safety_tolerance` 0–6           | Idem                                |
| `/v1/flux-2-pro`         | `width`, `height` \: 64 minimum, sans limite documentée               | `input_image` à `input_image_8`, 8 images au plus      | `seed`, `safety_tolerance` 0–7, `output_format`                      | Idem                                |
| `/v1/flux-2-flex`        | `width`, `height` \: 64 minimum, sans limite documentée               | `input_image` à `input_image_8`, 8 images au plus      | `steps` 1–50, `guidance` 1.5–10.0, `seed`, `output_format`           | Idem                                |

`output_format` accepte `jpeg`, `png` et `webp`, avec `jpeg` par défaut. Pour les endpoints dont le tableau ne donne pas de limite, référez-vous au schéma OpenAPI de l’endpoint concerné ; n’appliquez pas la limite de dimensions d’un endpoint à un autre.

## Flux d’appel

1. **Préparer la clé** \: créez une clé API dans la console BFL ; l’en-tête de requête utilise `x-key: $BFL_API_KEY`, et non `Authorization: Bearer`.
2. **Choisir l’endpoint** \: selon les capacités du modèle, choisissez `/v1/flux-pro-1.1`, `/v1/flux-pro-1.1-ultra` ou un autre endpoint `/v1/flux-*`.
3. **Soumettre la tâche** \: envoyez un JSON en définissant `prompt`, les champs de dimensions, `output_format` et éventuellement `seed`.
4. **Conserver `polling_url`** \: lisez `id` et `polling_url` dans la réponse et ne construisez pas vous-même l’adresse d’interrogation.
5. **Interroger jusqu’à `Ready`** \: appelez avec le même `x-key` `polling_url` ; continuez d’attendre sur `Pending`, et arrêtez-vous en consignant la cause sur `Error` ou un état de modération.
6. **Télécharger et vérifier** \: téléchargez `result.sample` avant l’expiration de l’URL signée, vérifiez que le fichier s’ouvre, ses dimensions et son contenu, puis contrôlez `cost` et le journal d’utilisation.

## Appel simulé

Les messages suivants sont indicatifs et ne proviennent pas d’un compte réel ; l’ID de tâche, l’URL et les valeurs de coût servent uniquement à illustrer la structure.

Requête de soumission \:

```json
{
  "prompt": "一只小机器人在图书馆阅读，水彩插画，不要文字。",
  "width": 1024,
  "height": 768,
  "seed": 42,
  "output_format": "jpeg",
  "safety_tolerance": 2
}
```

Réponse de soumission réussie (asynchrone, image pas encore générée) \:

```json
{
  "id": "task_example_01",
  "polling_url": "https://api.bfl.ai/v1/get_result?id=task_example_01",
  "cost": 0.04
}
```

Réponse d’interrogation terminée (`status` vaut `Ready`) \:

```json
{
  "id": "task_example_01",
  "status": "Ready",
  "progress": 1,
  "result": {
    "sample": "https://delivery.example.bfl.ai/sample/image.jpeg"
  }
}
```

Pendant l’interrogation, vous pouvez aussi voir les états `Pending`, `Error`, `Request Moderated`, `Content Moderated`, etc. Si la modération échoue, `result` peut être `null` et la cause figure dans `details`.

## Accès et sessions

* **URL de base** \: `https://api.bfl.ai` ; `https://api.eu.bfl.ai` et `https://api.us.bfl.ai` sont également proposés. Quel que soit l’accès choisi, interrogez le même `polling_url` renvoyé dans la réponse.
* **Authentification** \: `x-key: $BFL_API_KEY`. C’est la différence la plus visible avec les interfaces de style OpenAI ; ne placez pas la clé dans l’en-tête `Authorization`.
* **Entièrement asynchrone** \: la requête de soumission ne renvoie pas d’image, seulement `id` et `polling_url` ; un second `GET` est nécessaire pour obtenir le résultat.
* **Différences avec OpenAI** \: pas d’endpoint `/v1/images/generations`, ni de champs `size`, `quality` ou `n` ; les dimensions sont contrôlées par `width` / `height` ou `aspect_ratio`.
* **Rappel au lieu de l’interrogation** \: la requête peut inclure `webhook_url` et `webhook_secret`, et BFL appelle le webhook à la fin ; avec un rappel, validez toujours la signature et traitez les événements d’échec.
* **Appel via la passerelle de ce site** \: remplacez l’adresse par `https://api.dwchainless.com` et utilisez la clé de ce site ; FLUX est une tâche asynchrone, et la transmission de `polling_url` et de l’en-tête `x-key` par la passerelle dépend du canal. Si le canal n’est pas activé, utilisez l’accès direct à l’adresse officielle ci-dessus.
* **Appel via la passerelle de ce site** \: l’adresse de requête et le mode d’authentification suivent les indications du canal de ce site ; les champs de cette page relèvent du protocole natif BFL, vérifiez la disponibilité du modèle et la portée de transmission des paramètres avant d’utiliser la passerelle.
* **Délai d’expiration** \: la requête de soumission doit revenir rapidement ; après expiration, vérifiez d’abord si une tâche a été créée ; pour l’interrogation, un intervalle d’environ 0.5 seconde est conseillé, avec une limite totale selon le modèle et la longueur de la file, sans réessai infini.

## Références officielles

* [Démarrage rapide BFL \: texte vers image](https\://docs.bfl.ai/quick_start/generating_images)
* [Spécification OpenAPI BFL](https\://api.bfl.ai/openapi.json)
* [Documentation complète de l’API BFL](https\://docs.bfl.ai/llms-full.txt)