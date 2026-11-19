# Vidéo

La vidéo se divise en **génération** et **compréhension** \: la génération synthétise une nouvelle vidéo à partir de texte ou de références ; la compréhension extrait résumés, événements et réponses textuelles d’une vidéo existante. Requêtes, durées et sorties sont entièrement différentes.

## Aperçu

| Capacité                         | Entrée                               | Sortie                                 | Ordre de durée                                       |
| -------------------------------- | ------------------------------------ | -------------------------------------- | ---------------------------------------------------- |
| Texte vers vidéo                 | Prompt                               | Fichier vidéo ou URL de téléchargement | De quelques dizaines de secondes à plusieurs minutes |
| Image vers vidéo                 | Image de première frame + prompt     | Fichier vidéo                          | De quelques dizaines de secondes à plusieurs minutes |
| Contrôle première/dernière frame | Images de première et dernière frame | Vidéo contrôlée aux deux extrémités    | Plusieurs minutes                                    |
| Compréhension vidéo              | Vidéo + question                     | Résumé ou réponse textuelle            | Lié à la durée de la vidéo                           |

## Concepts clés

* **Résolution** \: couramment 480p, 720p, 1080p. Elle détermine la netteté de l’image et influence directement la durée de génération et le prix ; les brouillons ou aperçus ne prennent souvent en charge qu’une résolution inférieure.
* **Rapport d’aspect** \: `16:9` paysage, `9:16` portrait, `1:1` carré. Le rapport et la résolution déterminent ensemble les pixels réels ; par exemple, le portrait 1080p correspond à `1080x1920`.
* **Fréquence d’images (fps)** \: nombre d’images par seconde, couramment 24 ou 30. L’augmenter agrandit le fichier et ralentit la génération, sans rendre forcément le mouvement plus naturel.
* **Durée** \: nombre de secondes d’un segment vidéo, avec une limite propre au modèle. Certains modèles acceptent un nombre d’images au lieu de la durée ; en cas d’envoi simultané, vérifiez dans la documentation de l’interface lequel est prioritaire.
* **Références** \: les images servent de première frame, de dernière frame ou de référence de style ; la prise en charge des vidéos et audios de référence varie fortement selon le modèle et ne doit pas être supposée.
* **État de la tâche** \: l’ID renvoyé à la création indique seulement l’acceptation. Le vrai succès se lit dans l’état final et l’URL de sortie valide de l’interface de consultation ; un état comme `done` ne signifie pas toujours un succès.

Les valeurs disponibles et les limites de ces spécifications dépendent de la version du modèle ; consultez le tableau des paramètres de requête de chaque sous-page, et n’appliquez pas les champs d’une version à une autre.

## Description des interfaces

| Capacité                   | Mode                                                | Protocole officiel                                | Documentation                                     |
| -------------------------- | --------------------------------------------------- | ------------------------------------------------- | ------------------------------------------------- |
| Génération Seedance        | Création asynchrone → consultation → téléchargement | Volcengine Ark contents/generations/tasks         | [Seedance](/simidoc/fr/apps/api/video/seedance)                            |
| Génération Kling           | Création asynchrone → consultation/rappel           | Nouveau protocole de tâches Kling 3.0             | [Kling](/simidoc/fr/apps/api/video/kling)                                  |
| Génération Jimeng          | Soumission asynchrone → consultation                | Volcengine Visual CVSync2Async, signature AK/SK   | [Jimeng (à intégrer)](/simidoc/fr/apps/api/video/jimeng)                   |
| Référence Sora             | Videos API officielle fermée                        | Référence de structure uniquement                 | [Sora](/simidoc/fr/apps/api/video/sora)                                    |
| Génération Veo             | Opération asynchrone → interrogation                | Gemini API `predictLongRunning`                   | [Veo](/simidoc/fr/apps/api/video/veo)                                      |
| Génération PixVerse        | Création asynchrone → consultation                  | PixVerse OpenAPI v2                               | [PixVerse](/simidoc/fr/apps/api/video/pixverse)                            |
| Génération vidéo DashScope | Création asynchrone → consultation                  | DashScope video-synthesis                         | [DashScope (Wan / HappyHorse)](/simidoc/fr/apps/api/video/dashscope-video) |
| Génération Grok Imagine    | Création asynchrone → consultation                  | xAI `/v1/videos`                                  | [Grok Imagine](/simidoc/fr/apps/api/video/grok-imagine)                    |
| Compréhension vidéo        | Requête multimodale → texte / SSE                   | Dots, Kimi Chat Completions ; Gemini Interactions | [Compréhension vidéo](/simidoc/fr/apps/api/video/understanding)            |

## Déroulement des requêtes

1. La requête de création renvoie un ID de tâche qui indique seulement l’acceptation, pas que la vidéo est déjà générée.
2. Utilisez l’interface de consultation de tâche du même fournisseur ou canal ; espacez les appels de quelques secondes et fixez une attente totale maximale. Arrêtez immédiatement en cas d’échec, d’expiration ou d’annulation.
3. Ne téléchargez qu’après un état final réussi et en présence d’une sortie vidéo valide. Conservez l’ID de tâche original, l’ID de requête et le motif d’échec, au lieu de ne noter que « HTTP 200 ».
4. Les URL de résultat ont souvent une durée de validité \: transférez rapidement les fichiers. Un lien de téléchargement n’est pas une adresse de stockage permanente.

La génération vidéo n’utilise généralement pas SSE ; l’interrogation d’état n’est pas un flux vidéo en direct. Audio, résolution, durée, première et dernière frame et références multiples varient selon la version du modèle ; n’appliquez pas les champs d’une version à tous les modèles vidéo.

## Appel simulé

L’exemple suivant utilise le protocole Seedance pour illustrer les trois étapes de création, d’acceptation et de consultation ; le contenu est illustratif et les adresses et l’authentification relèvent de l’accès direct officiel à Volcengine Ark.

La requête de création ne soumet que le prompt et les spécifications vidéo \:

```json
{
  "model": "doubao-seedance-2-5-260628",
  "content": [
    { "type": "text", "text": "海边日落，镜头缓慢推进" }
  ],
  "resolution": "720p",
  "ratio": "16:9",
  "duration": 5
}
```

Une création réussie ne renvoie qu’un ID de tâche, pas la vidéo \:

```json
{"id":"cgt-example"}
```

La tâche n’est terminée qu’après un état final et la présence d’une adresse de résultat \:

```json
{
  "id": "cgt-example",
  "status": "succeeded",
  "content": { "video_url": "https://example.com/video.mp4" },
  "error": null
}
```

Lorsque l’état est `queued` ou `running`, continuez d’attendre ; sur `failed`, `expired` ou `cancelled`, arrêtez immédiatement l’interrogation et conservez `error`. La génération vidéo n’a pas d’incréments SSE ; le résultat ne peut être obtenu que par interrogation ou rappel.

## Adresses des fournisseurs et SimiRouter

Les sous-pages de cette section suivent le **protocole officiel du fournisseur** pour les champs et le déroulé. Considérez d’abord le corps de requête, le chemin et les champs d’état des exemples comme des références d’accès direct au fournisseur ; n’utilisez l’adresse de la passerelle `https://api.dwchainless.com` et une clé SimiRouter que lorsque la page confirme explicitement le mappage de la passerelle. L’ouverture d’un modèle de même nom, le chemin utilisé et le mappage des champs dépendent de la liste des modèles du compte et de la configuration actuelle du canal. Ne transmettez pas une requête du fournisseur à la passerelle en remplaçant uniquement le domaine.

Les clés du fournisseur, les AK/SK Volcengine et les clés SimiRouter ne sont pas interchangeables. Si le canal n’a pas de mappage explicite, ne lancez pas une génération payante en remplaçant seulement le domaine.

## Références officielles

* [Volcengine Ark \: créer une tâche de génération vidéo](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh)
* [Volcengine Ark \: interroger une tâche de génération vidéo](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh)
* [API de génération vidéo Jimeng](https\://docs.volcengine.com/docs/jimeng-ai/jimeng-ai-video-generation-30-pro-interface-documentation?lang=zh)
* [Kling texte vers vidéo](https\://kling.ai/document-api/apiReference/model/textToVideo)
* [OpenAI Videos API](https\://developers.openai.com/api/reference/resources/videos/methods/create)