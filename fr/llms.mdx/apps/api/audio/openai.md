# Format audio OpenAI

## Description de l’interface

Le format audio OpenAI comprend trois interfaces HTTP distinctes utilisant toutes `Authorization: Bearer $SIMIROUTER_API_KEY`.

| Point d’accès                   | Type de contenu     | Valeur de retour                                   | Documentation                            |
| ------------------------------- | ------------------- | -------------------------------------------------- | ---------------------------------------- |
| `POST /v1/audio/speech`         | JSON                | Octets audio ; SSE si le modèle le prend en charge | [Synthèse vocale](/simidoc/fr/apps/api/audio/speech)              |
| `POST /v1/audio/transcriptions` | multipart/form-data | JSON, texte ou sous-titres de transcription        | [Transcription vocale](/simidoc/fr/apps/api/audio/transcriptions) |
| `POST /v1/audio/translations`   | multipart/form-data | Texte ou sous-titres traduits en anglais           | [Traduction vocale](/simidoc/fr/apps/api/audio/translations)      |

Le paramètre `model` doit choisir un modèle audio accessible au compte. Le TTS `voice`, les formats de transcription, horodatages et streaming dépendent du modèle et ne sont pas interchangeables. Pour un microphone continu, consultez [Realtime](/simidoc/fr/apps/api/pending/realtime).

Cette page décrit le format OpenAI. Le cycle de vie des modèles et leurs paramètres dépendent des références officielles de chaque interface. Ne mélangez pas clés de passerelle et clés OpenAI.