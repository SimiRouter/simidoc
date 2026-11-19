# Vidéo Sora (interface officielle fermée)

**Sora 2 et Videos API officiels OpenAI ont fermé le 24 septembre 2026.** La structure ci-dessous est conservée à titre de référence, pas comme guide utilisable. Si SimiRouter propose des modèles homonymes ou une implémentation tierce compatible, confirmez séparément origine, capacités et protocole ; ce n’est pas l’accès direct officiel OpenAI.

## Description de l’interface

| Opération            | Ancien point d’accès officiel       | Référence             |
| -------------------- | ----------------------------------- | --------------------- |
| Créer une tâche      | `POST /v1/videos`                   | [Créer](/simidoc/fr/apps/api/video/sora/create)     |
| Consulter une tâche  | `GET /v1/videos/{video_id}`         | [Consulter](/simidoc/fr/apps/api/video/sora/status) |
| Télécharger la vidéo | `GET /v1/videos/{video_id}/content` | [Valeur](/simidoc/fr/apps/api/video/sora/content)   |

L’ancien protocole était asynchrone \: queued/in\_progress devenait completed ou failed, sans sortie de génération ordinaire en streaming. L’avis officiel indique l’absence d’API remplaçante directe. Choisissez un autre fournisseur disponible dans [la catégorie vidéo](/simidoc/fr/apps/api/video), sans substitution automatique.

## Références officielles

[Avis de fermeture OpenAI](https\://developers.openai.com/api/docs/deprecations#2026-03-24-sora-2-video-generation-models-and-videos-api), [Videos API Reference](https\://developers.openai.com/api/reference/resources/videos/methods/create).