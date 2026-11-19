# Vidéo Grok Imagine

## Aperçu

Grok Imagine utilise l’interface vidéo asynchrone de xAI \: `POST /v1/videos/generations` soumet la tâche et renvoie un `request_id`, puis `GET /v1/videos/{request_id}` interroge le résultat. Un prompt textuel génère directement une vidéo ; fournir `image` passe en image vers vidéo, fournir des images de référence ou des images clés passe en génération avec références.

| Ce que vous voulez faire   | Entrée                                       | Sortie                       | Endpoint                      |
| -------------------------- | -------------------------------------------- | ---------------------------- | ----------------------------- |
| Texte vers vidéo           | `prompt`, durée, cadre, résolution           | `request_id`                 | `POST /v1/videos/generations` |
| Image vers vidéo           | `image` + `prompt` facultatif                | `request_id`                 | Même endpoint                 |
| Génération avec références | `prompt` + `reference_images` ou `keyframes` | `request_id`                 | Même endpoint                 |
| Consulter la tâche         | `request_id`                                 | État, URL de la vidéo, usage | `GET /v1/videos/{request_id}` |

## Concepts clés

* **Cycle de vie de la tâche** \: l’état de consultation ne prend que `pending`, `done` et `failed`. En `pending`, `progress` va de 0 à 99 ; en `done`, il vaut 100 ; en `failed`, il peut être omis.
* **`request_id` est l’identifiant d’interrogation** \: ce n’est pas une clé d’idempotence. Après un délai dépassé à la soumission, ne concluez pas que la tâche n’a pas été créée parce que vous n’avez pas reçu de réponse ; conservez et interrogez d’abord le `request_id` éventuel.
* **Rythme d’interrogation** \: la documentation officielle ne fixe pas d’intervalle. Le client peut utiliser 5 à 10 secondes, avec une attente totale maximale ; arrêtez immédiatement après `failed`.
* **Durée et cadre** \: `duration` va de 1 à 15 secondes, avec 8 secondes par défaut ; l’image vers vidéo ignore `aspect_ratio` et le cadre suit l’image d’entrée. `resolution` vaut `480p` par défaut, et `grok-imagine-video-1.5` prend en charge le 1080p natif.
* **Commutateur audio** \: la page des capacités mentionne `generate_audio`, `true` par défaut ; `false` demande une sortie muette. La référence REST ne liste pas ce champ séparément, et la disponibilité réelle dépend de la réponse de l’interface.
* **Unité de facturation** \: `usage.cost_in_usd_ticks` dans la réponse de consultation est le compteur de coût de cette tâche ; la conversion exacte, le prix unitaire et le règlement des échecs suivent la page tarifaire du fournisseur.

## Spécifications et capacités

| Indicateur              | Valeurs vérifiées                                                                                                        |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| ID de modèle            | `grok-imagine-video-1.5`, `grok-imagine-video-1.5-lite`, `grok-imagine-video`                                            |
| Résolution              | `480p` (par défaut), `720p`, `1080p` ; `grok-imagine-video-1.5` offre le 1080p natif                                     |
| Rapport d’aspect        | `1:1`, `16:9` (par défaut), `9:16`, `4:3`, `3:4`, `3:2`, `2:3`, `21:9`, `5:2` ; l’image vers vidéo ignore ce champ       |
| Durée                   | 1–15 secondes, 8 secondes par défaut ; l’édition d’une vidéo existante n’accepte pas de durée personnalisée              |
| Audio                   | `generate_audio` vaut `true` par défaut ; `false` demande le silence ; voir la page des capacités                        |
| Références              | `image` en première frame, `reference_images` en références, jusqu’à 4 `keyframes`, `last_frame` en dernière frame (1.5) |
| Entrée image            | URL publique, URI de données Base64 ou `file_id` de xAI Files API ; JPEG, PNG, WebP                                      |
| Comptage de facturation | `usage.cost_in_usd_ticks` ; le prix unitaire suit la page tarifaire du fournisseur                                       |

Le `480p` par défaut convient à un aperçu ; `720p` et `1080p` augmentent le temps de génération et le coût. L’image vers vidéo ignore `aspect_ratio` et le cadre dépend de `image` ; pour contrôler le paysage ou le portrait, préparez l’image d’entrée en conséquence. `duration` vaut 8 secondes par défaut et le temps réel dépend aussi de la file d’attente ; ne l’estimez pas seulement à partir de la durée. `generate_audio` est documenté sur la page des capacités mais absent de la référence REST ; avant l’intégration, validez avec une courte requête si le modèle actuel accepte ce champ.

## Flux d’appel

1. Créez une clé API dans la console xAI ; les requêtes suivantes utilisent `Authorization: Bearer`.
2. Choisissez le mode de génération \: envoyer seulement `prompt` correspond au texte vers vidéo ; ajouter `image` correspond à l’image vers vidéo ; ajouter `reference_images`, `keyframes` ou `last_frame` correspond à la génération avec références.
3. Appelez `POST https://api.x.ai/v1/videos/generations` en réglant `duration`, `aspect_ratio`, `resolution` et le commutateur audio selon le modèle visé.
4. Conservez `request_id` de la réponse. Une création réussie signifie seulement que la tâche a été acceptée.
5. Interrogez `GET https://api.x.ai/v1/videos/{request_id}` jusqu’à ce que `status` passe à `done` ou `failed`.
6. Après `done`, téléchargez `video.url` ; pour écrire dans votre propre stockage objet, la requête peut aussi utiliser `output.upload_url` ou `storage_options`. En cas de `failed`, lisez `error.code` et `error.message`.

## Appel simulé

Les messages suivants sont indicatifs ; `request_id`, l’URL et l’usage ne proviennent pas d’un compte réel.

Requête de création \:

```json
{
  "model": "grok-imagine-video-1.5",
  "prompt": "示例：夜晚的霓虹街道，镜头缓慢前推。",
  "duration": 6,
  "aspect_ratio": "16:9",
  "resolution": "720p",
  "generate_audio": true
}
```

Une création réussie renvoie l’identifiant d’interrogation \:

```json
{
  "request_id": "demo-request-0001"
}
```

Consultation jusqu’à l’état final de succès \:

```json
{
  "status": "done",
  "progress": 100,
  "model": "grok-imagine-video-1.5",
  "video": {
    "url": "https://example.com/demo-grok-imagine.mp4",
    "duration": 6,
    "respect_moderation": true
  }
}
```

Continuez l’interrogation en `pending` ; arrêtez-vous en `failed` et lisez `error`. Lorsque `video.respect_moderation` vaut `false`, l’URL peut être vide et ne doit pas être considérée comme un résultat lisible.

## Accès et sessions

* **Adresse de base** \: `https://api.x.ai`. La génération, la consultation, l’édition et l’extension utilisent respectivement `/v1/videos/generations`, `/v1/videos/{request_id}`, `/v1/videos/edits` et `/v1/videos/extensions`.
* **En-tête d’authentification** \: `Authorization: Bearer PASTE_API_KEY_HERE`, avec un corps de requête JSON.
* **Deux jeux d’adresses** \: en direct, utilisez `https://api.x.ai` ; n’utilisez `https://api.dwchainless.com` et `Authorization: Bearer` avec la clé de ce site que lorsque le canal confirme explicitement ce mappage de passerelle ; ne supposez pas qu’il suffit de remplacer l’adresse et l’authentification. L’exposition de `/v1/videos/*` par le canal SimiRouter et la conservation de `request_id` et des champs d’état dépendent du mappage du canal.
* **Délai d’expiration et idempotence** \: aucune clé d’idempotence publique n’existe. Après un délai dépassé à la soumission, interrogez d’abord le `request_id` connu et ne réessayez qu’après avoir confirmé l’absence de la tâche ; n’envoyez pas le même prompt en parallèle pour contourner l’attente.
* **Conservation du résultat** \: `video.url` est une adresse temporaire, et la documentation fournit aussi des champs de sortie de fichier et d’expiration. Côté produit, téléchargez ou réarchivez d’abord, puis exposez un lien durable.

## Références officielles

* [xAI \: génération vidéo Grok Imagine](https\://docs.x.ai/developers/model-capabilities/video/generation)
* [xAI \: référence de l’API REST vidéo](https\://docs.x.ai/developers/rest-api-reference/inference/videos)
* [xAI \: image vers vidéo](https\://docs.x.ai/developers/model-capabilities/video/image-to-video)