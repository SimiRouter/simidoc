# Vidéo Seedance

## Description de l’interface

Seedance accepte texte vers vidéo et les références image, vidéo ou audio permises par le modèle. Le déroulement officiel Ark est \: créer une tâche asynchrone, consulter son état puis télécharger après réussite.

| Opération | Chemin officiel                               | Documentation                   |
| --------- | --------------------------------------------- | ------------------------------- |
| Créer     | `POST /api/v3/contents/generations/tasks`     | [Créer une tâche](/simidoc/fr/apps/api/video/seedance/create)     |
| Consulter | `GET /api/v3/contents/generations/tasks/{id}` | [Consulter une tâche](/simidoc/fr/apps/api/video/seedance/status) |

Adresse de base officielle `https://ark.cn-beijing.volces.com`. Authentification \: `ARK_API_KEY` en Bearer. `/v1/video/generations` est un chemin compatible de passerelle, pas l’adresse officielle Ark. Utilisez-le seulement si le canal définit le mappage ; ne convertissez pas automatiquement id/status au format d’un autre fournisseur.

Les états sont `queued → running → succeeded` ; les fins d’échec comprennent failed, expired et cancelled. Ce n’est ni SSE ni Realtime. Version du modèle, vidéo sonore, références, durée et résolution déterminent les capacités.

## Références officielles

[Créer une tâche vidéo](https\://docs.volcengine.com/docs/ark/create-video-generation-task-api?lang=zh), [Consulter une tâche](https\://docs.volcengine.com/docs/ark/get-video-generation-task-api?lang=zh), [Tutoriel vidéo](https\://docs.volcengine.com/docs/ark/video-generation-tutorial?lang=zh).