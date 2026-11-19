# Vidéo Kling

## Description de l’interface

La nouvelle API officielle Kling utilise des chemins par fonction/modèle, settings/options et une consultation unifiée \:

| Opération        | Interface officielle actuelle                    | Documentation                                         |
| ---------------- | ------------------------------------------------ | ----------------------------------------------------- |
| Texte vers vidéo | `POST /text-to-video/kling-3.0`                  | [Créer](/simidoc/fr/apps/api/video/kling/text-create) / [Consulter](/simidoc/fr/apps/api/video/kling/text-status)   |
| Image vers vidéo | `POST /image-to-video/kling-3.0`                 | [Créer](/simidoc/fr/apps/api/video/kling/image-create) / [Consulter](/simidoc/fr/apps/api/video/kling/image-status) |
| Consulter        | `GET /tasks?task_ids=...` ou external\_task\_ids | Consultation générale des tâches                      |

Les exemples appellent directement `https://api-singapore.klingai.com` avec une clé API officielle Kling en Bearer. AK/SK + JWT HS256 des anciens comptes ne s’appliquent qu’à l’ancien standard ; ni clé SimiRouter ni SecretKey brut ne sont une clé Kling.

## Ne pas mélanger les protocoles

L’ancien `/v1/videos/text2video`, `/v1/videos/image2video` utilise model\_name, task\_id, task\_status et succeed ; le nouveau utilise le modèle dans la route, data.id, status et succeeded. Les anciens points d’accès restent documentés comme legacy, mais leurs champs ne doivent pas être ajoutés aux nouvelles requêtes. Le chemin SimiRouter `/kling/...` est un mappage de passerelle dont la version doit être confirmée ; ajouter un préfixe au nouveau chemin officiel ne suffit pas.

La génération est asynchrone, pas SSE. Après création, interrogez ou recevez un callback et consommez les éléments video de outputs uniquement après un état final réussi.

## Références officielles

[Texte vers vidéo Kling](https\://kling.ai/document-api/apiReference/model/textToVideo), [Image vers vidéo](https\://kling.ai/document-api/apiReference/model/imageToVideo), [Authentification](https\://kling.ai/document-api/api/get-started/authentication).