# Génération vidéo DashScope (Wan / HappyHorse)

## Aperçu

Wan et HappyHorse sont deux familles de modèles de génération vidéo de la plateforme Alibaba Cloud Model Studio ; elles partagent le même protocole asynchrone DashScope \: endpoint de soumission, en-tête `X-DashScope-Async`, chemin de consultation des tâches, chaînes d’état et champs de résultat identiques. Les différences se limitent à trois points \: l’ID de modèle, la structure d’entrée et les paramètres de cadre.

| Ce que vous voulez faire                                               | Entrée                                                           | Sortie                     | Endpoint                                                      |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------- | -------------------------- | ------------------------------------------------------------- |
| Texte vers vidéo (Wan)                                                 | Prompt, `parameters.size`, `duration`                            | `task_id`                  | `POST /api/v1/services/aigc/video-generation/video-synthesis` |
| Image vers vidéo sur première frame (Wan)                              | Prompt, `input.img_url`, `parameters.resolution`                 | `task_id`                  | Même endpoint de soumission                                   |
| Texte vers vidéo (HappyHorse)                                          | Prompt, `resolution`, `ratio`, `duration`                        | `task_id`                  | Même endpoint de soumission                                   |
| Image vers vidéo sur première frame ou image de référence (HappyHorse) | `input.media` contenant `first_frame` ou 1 à 9 `reference_image` | `task_id`                  | Même endpoint de soumission                                   |
| Consulter une tâche                                                    | `task_id`                                                        | `task_status`, `video_url` | `GET /api/v1/tasks/{task_id}`                                 |

## Concepts clés

* **Cycle de vie de la tâche** \: `PENDING → RUNNING → SUCCEEDED`, l’état final d’échec est `FAILED`, avec aussi `CANCELED` et `UNKNOWN`. Seul `SUCCEEDED` permet de lire `output.video_url`.
* **Deux ID aux rôles différents** \: `output.task_id` sert à consulter la tâche ; `request_id` sert uniquement à suivre une requête HTTP. Conservez les deux lors du diagnostic.
* **Rythme d’interrogation** \: la documentation officielle recommande une consultation toutes les 15 secondes. L’ID de tâche et l’URL de résultat sont valides 24 heures ; après expiration, la consultation renvoie `UNKNOWN`.
* **Structure d’entrée selon la famille de modèles** \: l’image vers vidéo de Wan utilise `input.img_url` ; HappyHorse utilise le tableau `input.media`, dont chaque élément porte `type` (`first_frame` ou `reference_image`) et `url`. Les deux structures ne sont pas interchangeables.
* **Paramètres de cadre selon la famille de modèles** \: le texte vers vidéo de Wan utilise `parameters.size` (`宽*高`, par exemple `1280*720`), l’image vers vidéo de Wan utilise `parameters.resolution` (`480P`, `720P`, `1080P`) ; le texte vers vidéo et l’image de référence vers vidéo de HappyHorse utilisent `parameters.ratio` (par exemple `16:9`), tandis que l’image vers vidéo sur première frame suit l’image de première frame.
* **Audio seulement sur certaines générations Wan** \: Wan2.6 et Wan2.5 génèrent par défaut une musique ou des effets sonores assortis à l’image, et `input.audio_url` permet de fournir un WAV ou un MP3 ; Wan2.2 et Wan2.1 produisent par défaut une vidéo muette. La documentation HappyHorse ne mentionne aucun paramètre d’entrée ou de sortie audio.
* **Facturation à la seconde de sortie** \: `usage.duration` dans la réponse de consultation correspond à la durée de la vidéo produite. Le prix unitaire, le règlement des tâches échouées et les règles de remboursement suivent la page tarifaire du fournisseur et la facturation.

## Spécifications et capacités

Valeurs pour Wan \:

| Indicateur               | Valeurs vérifiées                                                                                                                                                                                                                                 |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Modèles texte vers vidéo | `wan2.6-t2v`, `wan2.5-t2v-preview`, `wan2.2-t2v-plus`, `wan2.1-t2v-turbo`, `wan2.1-t2v-plus`                                                                                                                                                      |
| Modèles image vers vidéo | `wan2.6-i2v`, `wan2.6-i2v-flash`, `wan2.5-i2v-preview`, `wan2.2-i2v-plus`, `wan2.2-i2v-flash`, `wan2.1-i2v-turbo`, `wan2.1-i2v-plus`                                                                                                              |
| Résolution               | Texte vers vidéo `size` \: `832*480`, `480*832`, `624*624`, `1280*720`, `720*1280`, `960*960`, `1088*832`, `832*1088`, `1920*1080`, `1080*1920`, `1440*1440`, `1632*1248`, `1248*1632` ; image vers vidéo `resolution` \: `480P`, `720P`, `1080P` |
| Durée                    | `wan2.6-t2v` \: 2 à 15 secondes ; `wan2.5-t2v-preview` \: 5 ou 10 secondes ; texte vers vidéo `wan2.2` et `wan2.1` \: 5 secondes fixes ; `wan2.1-i2v-turbo` \: 3, 4 ou 5 secondes                                                                 |
| Audio                    | Wan2.6 et Wan2.5 génèrent automatiquement musique ou effets sonores ; `audio_url` accepte WAV et MP3, 3 à 30 secondes, 15 Mo maximum ; Wan2.2 et Wan2.1 sont muets par défaut                                                                     |
| Références               | L’image vers vidéo utilise `input.img_url`, avec une URL publique ou du Base64 ; largeur et hauteur de l’image entre 240 et 8000 pixels, 20 Mo maximum pour Wan2.6/2.5                                                                            |

Valeurs pour HappyHorse \:

| Indicateur          | Valeurs vérifiées                                                                                                                                                                                                                                        |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ID de modèle        | `happyhorse-1.1-t2v`, `happyhorse-1.0-t2v`, `happyhorse-1.1-i2v`, `happyhorse-1.1-r2v`                                                                                                                                                                   |
| Résolution          | `480P`, `720P`, `1080P`, par défaut `1080P`                                                                                                                                                                                                              |
| Rapport d’aspect    | Texte vers vidéo et image de référence vers vidéo \: `16:9` (par défaut), `9:16`, `1:1`, `4:3`, `3:4`, `4:5`, `5:4`, `9:21`, `21:9` ; image vers vidéo \: suit la première frame, avec un rapport autorisé de 1\:2.5 à 2.5\:1                            |
| Durée               | 3 à 15 secondes, 5 secondes par défaut ; cette plage est explicite dans la documentation de `happyhorse-1.0-t2v`, de l’image vers vidéo et de l’image de référence vers vidéo, tandis que la documentation de `happyhorse-1.1-t2v` ne donne pas de plage |
| Images de référence | Image vers vidéo \: 1 première frame, côté le plus court d’au moins 300 pixels ; image de référence vers vidéo \: 1 à 9 images, côté le plus court d’au moins 400 pixels ; 20 Mo maximum par image ; formats JPEG, JPG, PNG, WEBP                        |
| Autres paramètres   | `watermark` vaut `true` par défaut ; lorsqu’il est activé, HappyHorse s’affiche en bas à droite ; `seed` va de 0 à 2147483647                                                                                                                            |

Le `size` de Wan désigne des pixels précis, tandis que `resolution` désigne un palier ; les deux servent des endpoints différents \: pour un texte vers vidéo 1080P portrait, écrivez `1080*1920`, pas `1080P` ; pour l’image vers vidéo, c’est l’inverse, seuls `480P`, `720P` et `1080P` sont acceptés. L’image vers vidéo sur première frame de HappyHorse ne lit pas `ratio` \: le rapport de sortie est déterminé par l’image. Le texte vers vidéo de Wan2.2 et Wan2.1 est fixé à 5 secondes ; allonger `duration` ne produit pas de segment plus long. Wan2.6 et Wan2.5 génèrent automatiquement une piste audio ; si l’aval n’en a pas besoin, retirez-la en post-production ou vérifiez d’abord si le modèle offre un paramètre de désactivation. Avec 1 à 9 images de référence, les `[Image N]` du prompt doivent respecter l’ordre de `media` ; un ordre incorrect référence la mauvaise image.

## Flux d’appel

1. Créez une clé API sur Alibaba Cloud Model Studio. Le modèle, l’adresse de requête et la clé doivent appartenir à la même région ; un appel inter-régions échoue.
2. Choisissez la famille de modèles et le mode \: texte vers vidéo ou image vers vidéo pour Wan, ou texte vers vidéo, image vers vidéo sur première frame ou image de référence vers vidéo pour HappyHorse. Les structures d’entrée diffèrent ; un même corps de requête n’est pas réutilisable.
3. Soumettez un JSON à `POST /api/v1/services/aigc/video-generation/video-synthesis` avec `Authorization: Bearer`, `Content-Type: application/json` et `X-DashScope-Async: enable`.
4. Conservez `output.task_id` et `request_id`. Un `PENDING` renvoyé à la création signifie seulement que la mise en file a réussi.
5. Appelez `GET /api/v1/tasks/{task_id}` toutes les 15 secondes. Après `SUCCEEDED`, lisez `output.video_url` ; en cas de `FAILED`, lisez `output.code` et `output.message`.
6. Téléchargez et réarchivez la vidéo sous 24 heures. Une fois la tâche expirée, la consultation n’est plus possible et l’URL de résultat ne doit plus être utilisée.

## Appel simulé

Les messages suivants sont illustratifs ; les ID de tâche, ID de requête, URL et usages ne proviennent pas d’un compte réel.

Requête de création d’un texte vers vidéo Wan \:

```json
{
  "model": "wan2.5-t2v-preview",
  "input": {
    "prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "parameters": {
    "size": "1280*720",
    "duration": 5,
    "prompt_extend": true,
    "watermark": false,
    "seed": 20260804
  }
}
```

Requête de création d’une image vers vidéo sur première frame HappyHorse \:

```json
{
  "model": "happyhorse-1.1-i2v",
  "input": {
    "prompt": "示例：让画面中的帆船缓慢向前移动。",
    "media": [
      {
        "type": "first_frame",
        "url": "https://example.com/demo-first-frame.png"
      }
    ]
  },
  "parameters": {
    "resolution": "720P",
    "duration": 5,
    "watermark": false,
    "seed": 20260804
  }
}
```

La réponse de création réussie a la même structure pour les deux familles et ne renvoie que l’état de mise en file \:

```json
{
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "PENDING"
  },
  "request_id": "demo-request-0001"
}
```

Consultation jusqu’à l’état final réussi \:

```json
{
  "request_id": "demo-request-0001",
  "output": {
    "task_id": "demo-task-0001",
    "task_status": "SUCCEEDED",
    "video_url": "https://example.com/demo-video.mp4",
    "orig_prompt": "示例：清晨的竹林，薄雾缓慢流动，镜头横移。"
  },
  "usage": {
    "duration": 5,
    "output_video_duration": 5,
    "video_count": 1,
    "SR": 720
  }
}
```

`PENDING` et `RUNNING` \: continuez d’attendre ; `FAILED` et `CANCELED` \: arrêtez immédiatement et conservez `output.code` et `output.message` ; `UNKNOWN` \: vérifiez d’abord si la tâche a dépassé 24 heures.

## Accès et sessions

* **Adresse de base** \: `https://{WorkspaceId}.{region}.maas.aliyuncs.com`. Singapour, les États-Unis, Pékin, Francfort et Tokyo utilisent des hôtes régionaux différents ; les chemins de soumission et de consultation sont identiques.
* **En-tête d’authentification** \: `Authorization: Bearer PASTE_API_KEY_HERE` ; la création de tâche doit ajouter `X-DashScope-Async: enable` ; sans cet en-tête, vous recevez une erreur d’appel synchrone.
* **Deux jeux d’adresses** \: en direct, utilisez `https://{WorkspaceId}.{region}.maas.aliyuncs.com` ; n’utilisez `https://api.dwchainless.com` et `Authorization: Bearer` avec la clé de ce site que lorsque le canal confirme explicitement ce mappage de passerelle ; ne supposez pas qu’il suffit de remplacer l’adresse et l’authentification. Si le canal SimiRouter fournit un habillage unifié, `task_id`, les chaînes d’état et les champs de résultat peuvent être réécrits ; référez-vous à la documentation du canal.
* **Délai d’expiration et idempotence** \: après un délai dépassé à la soumission, conservez d’abord le `task_id` éventuellement déjà créé et consultez-le, sans soumettre immédiatement à nouveau. Les requêtes d’interrogation peuvent être réessayées, mais fixez une attente totale maximale.
* **Conservation des résultats** \: `video_url` est une adresse de téléchargement à durée limitée. Pour un usage durable, téléchargez puis transcodez ou réarchivez ; n’écrivez pas directement l’URL du fournisseur dans la base de données produit comme ressource permanente.

## Références officielles

* [Référence de l’API Wan texte vers vidéo](https\://www.alibabacloud.com/help/en/model-studio/legacy-wan-text-to-video-api-reference)
* [Référence de l’API Wan image vers vidéo](https\://www.alibabacloud.com/help/en/model-studio/image-to-video-api-reference)
* [Description du modèle Wan2.5 image vers vidéo](https\://www.alibabacloud.com/help/en/model-studio/wan2-5-i2v)
* [API HappyHorse texte vers vidéo](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-text-to-video-api-reference)
* [API HappyHorse image vers vidéo sur première frame](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-image-to-video-api-reference)
* [API HappyHorse image de référence vers vidéo](https\://www.alibabacloud.com/help/en/model-studio/happyhorse-reference-to-video-api-reference)