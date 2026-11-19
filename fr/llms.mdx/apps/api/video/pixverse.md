# Vidéo PixVerse

## Aperçu

L’OpenAPI officielle de PixVerse soumet les tâches de génération asynchrone avec de simples requêtes HTTP ; la création renvoie un `video_id`, puis interrogez l’état avec le même identifiant et récupérez l’URL de la vidéo. Le texte vers vidéo et l’image vers vidéo sont deux entrées distinctes ; pour l’image vers vidéo, téléversez d’abord l’image, récupérez son `img_id`, puis soumettez la tâche.

| Ce que vous voulez faire               | Entrée                                                                    | Sortie                                        | Endpoint                                  |
| -------------------------------------- | ------------------------------------------------------------------------- | --------------------------------------------- | ----------------------------------------- |
| Générer une vidéo à partir de texte    | Prompt, durée, `quality`, `aspect_ratio`                                  | `video_id`                                    | `POST /openapi/v2/video/text/generate`    |
| Générer une vidéo à partir d’une image | `img_id` d’une image téléversée (ou `img_ids` d’un modèle) plus un prompt | `video_id`                                    | `POST /openapi/v2/video/img/generate`     |
| Consulter le résultat d’une tâche      | `video_id`                                                                | État, URL de la vidéo, spécifications réelles | `GET /openapi/v2/video/result/{video_id}` |
| Téléverser une image                   | Fichier image                                                             | `img_id`                                      | `POST /openapi/v2/image/upload`           |

## Concepts clés

* **Cycle de vie de la tâche** \: la création renvoie `ErrCode=0` et `video_id`, ce qui indique seulement que la tâche a été acceptée. L’état `1` signifie terminé, `5` en cours de génération, `7` échec de modération du contenu, `8` échec de génération ; `1`, `7` et `8` sont tous des états finaux.
* **Deux identifiants aux usages différents** \: `video_id` est l’identifiant métier de la tâche, utilisé pour l’interrogation et le téléchargement ; `Ai-trace-id` est un UUID à générer à nouveau pour chaque requête, utilisé uniquement pour le suivi. Ce n’est pas une clé d’idempotence ; le réutiliser peut créer une autre tâche.
* **Rythme d’interrogation** \: la documentation officielle recommande une consultation toutes les 3 à 5 secondes. Le client doit fixer une attente totale maximale ; après passage à `7` ou `8`, arrêtez immédiatement au lieu de réessayer la même tâche.
* **Unité de facturation** \: `Resp.credits` dans la réponse de création correspond aux credits consommés par cette tâche. Le prix unitaire réel, les forfaits et les règles de remboursement suivent la page tarifaire du fournisseur et la facturation du compte.
* **Cadre et durée contrôlés séparément** \: le texte vers vidéo utilise `quality` pour le palier de netteté et `aspect_ratio` pour le cadre ; l’image vers vidéo n’a pas de champ `aspect_ratio` et le cadre dépend de l’image d’entrée ou du modèle. Les valeurs valides de `duration` varient selon le modèle ; ne vous fiez pas uniquement à la plage 1–15 de l’interface.

## Spécifications et capacités

| Indicateur              | Valeurs vérifiées                                                                                                                       |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| ID de modèle            | `v6-max`, `c1`, `v6`, `v5.6`, `v5.5`, `v5`, `v5-fast`, `v4.5`, `v4`, `v3.5` ; `v5-fast` exige une autorisation du compte                |
| Résolution              | `quality` \: `360p`, `540p`, `720p`, `1080p`                                                                                            |
| Rapport d’aspect        | Texte vers vidéo \: `16:9`, `9:16`, `4:3`, `3:4`, `1:1`, `2:3`, `3:2`, `21:9` ; image vers vidéo \: champ absent                        |
| Durée                   | Plage de l’interface 1–15 secondes ; C1 et V6 \: 1–15 secondes, V5.5 et V5.6 \: 5, 8 ou 10 secondes, anciens modèles \: 5 ou 8 secondes |
| Audio                   | Commutateur booléen `generate_audio_switch`, `false` par défaut ; V5.5, V5.6, V6 et C1 prennent en charge l’audio natif                 |
| Images de référence     | L’image vers vidéo téléverse d’abord pour obtenir `img_id` ; les tâches de modèle utilisent `img_ids` avec `template_id`                |
| Comptage de facturation | La réponse de création renvoie `Resp.credits` ; le prix unitaire suit la page tarifaire du fournisseur                                  |

Lors du choix, regardez d’abord la génération du modèle, puis `quality` et `duration`. `quality` détermine seulement le palier de pixels de sortie, sans changer le cadre ; `aspect_ratio` détermine seulement la forme, et les pixels finaux résultent des deux. L’image vers vidéo n’a pas de champ `aspect_ratio` \: ne recopiez pas le corps du texte vers vidéo, car le cadre dépend de l’image d’entrée ou du modèle. `Resp.credits` dans la réponse de création convient pour tenir un budget ; la facturation réelle et les remboursements suivent la facturation du compte.

## Flux d’appel

1. Créez une clé API sur la plateforme ouverte PixVerse. Les requêtes utilisent l’en-tête `API-KEY` ; ne l’écrivez pas dans un prompt ni dans un dépôt de code.
2. Pour l’image vers vidéo, appelez d’abord `POST /openapi/v2/image/upload` pour téléverser l’image et conservez `Resp.img_id` de la réponse ; le texte vers vidéo ignore cette étape.
3. Soumettez un JSON à l’endpoint de génération correspondant. Les champs obligatoires sont `model`, `prompt`, `duration` et `quality` ; le texte vers vidéo exige aussi `aspect_ratio`. Générez un nouvel `Ai-trace-id` à chaque requête.
4. Conservez `Resp.video_id` de la réponse de création. Ne considérez pas `ErrCode=0` comme une vidéo déjà générée.
5. Appelez l’endpoint de consultation toutes les 3 à 5 secondes. Ne téléchargez que lorsque `status=1` et que `Resp.url` est accessible ; pour `status=7`, corrigez le contenu avant de décider d’un nouvel essai ; pour `status=8`, conservez `Ai-trace-id` pour le diagnostic.
6. Réarchivez la vidéo dans votre propre stockage. La politique d’accès et la durée de validité de l’URL de résultat suivent les indications du fournisseur ; ne la traitez pas comme une adresse publique permanente.

## Appel simulé

Les messages ci-dessous servent uniquement à illustrer la structure des champs ; l’ID de tâche, les credits et les URL sont indicatifs et ne proviennent pas d’un compte réel.

Création d’une tâche texte vers vidéo \:

```json
{
  "model": "v6-max",
  "prompt": "示例：海边日落，一艘白色帆船缓慢驶过，镜头平稳。",
  "duration": 5,
  "quality": "720p",
  "aspect_ratio": "16:9",
  "seed": 20260804,
  "generate_audio_switch": false
}
```

Une création réussie renvoie seulement l’ID de tâche et les credits consommés \:

```json
{
  "ErrCode": 0,
  "ErrMsg": "Success",
  "Resp": {
    "video_id": 900000000000001,
    "credits": 12
  }
}
```

Une adresse téléchargeable n’apparaît qu’une fois `status=1` \:

```json
{
  "ErrCode": 0,
  "ErrMsg": "Success",
  "Resp": {
    "id": 900000000000001,
    "status": 1,
    "url": "https://example.com/demo-pixverse.mp4",
    "duration": 5,
    "quality": "720p",
    "aspect_ratio": "16:9",
    "outputWidth": 1280,
    "outputHeight": 720,
    "has_audio": false,
    "credits": 12
  }
}
```

Continuez l’interrogation lorsque `status=5` ; pour `status=7` ou `status=8`, terminez immédiatement et consignez la cause de l’échec depuis `ErrMsg`, `Error.Message` et `Ai-trace-id`.

## Accès et sessions

* **Adresse de base** \: `https://app-api.pixverse.ai`. La génération et la consultation se font sous `/openapi/v2/`.
* **En-tête d’authentification** \: `API-KEY: PASTE_API_KEY_HERE` ; `Content-Type: application/json` ; ajoutez un nouvel `Ai-trace-id` à chaque requête.
* **Deux jeux d’adresses** \: en direct, utilisez `https://app-api.pixverse.ai` avec l’en-tête `API-KEY` ; n’utilisez `https://api.dwchainless.com` et `Authorization: Bearer` avec la clé de ce site que lorsque le canal confirme explicitement ce mappage de passerelle ; ne supposez pas qu’il suffit de remplacer l’adresse et l’authentification. Le mappage de ces chemins par le canal SimiRouter, et l’éventuel passage au protocole vidéo unifié, dépendent de la configuration du canal ; ne supposez pas que les champs sont compatibles en changeant seulement le domaine.
* **Délai d’expiration et idempotence** \: un délai dépassé sur la création ne prouve pas que le serveur n’a pas accepté la tâche. Interrogez d’abord avec le `video_id` déjà conservé et ne réessayez qu’après avoir confirmé son absence ; n’envoyez pas le même prompt en continu pour « accélérer ».
* **Diagnostic des erreurs** \: un HTTP 200 peut aussi contenir un `ErrCode` non nul. Pour les erreurs métier, lisez `ErrCode`, `ErrMsg` et éventuellement `Error.Type` et `Error.Param` ; ne regardez pas seulement le code HTTP.

## Références officielles

* [Démarrage rapide PixVerse](https\://docs.platform.pixverse.ai/quick-start-2394985m0)
* [API texte vers vidéo PixVerse](https\://docs.platform.pixverse.ai/text-to-video-generation-13016634e0)
* [API image vers vidéo PixVerse](https\://docs.platform.pixverse.ai/image-to-video-generation-13016633e0)
* [Consultation de l’état d’une tâche PixVerse](https\://docs.platform.pixverse.ai/query-task-status-43051212e0)