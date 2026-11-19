# Audio

L’API audio convertit du texte en parole, des enregistrements en texte et comprend le contenu audio. La voix, la génération musicale et les pistes audio vidéo sont des capacités distinctes ; ne mélangez pas les modèles et les endpoints.

## Aperçu

| Ce que vous voulez faire                                   | Direction                 | Sortie typique                                    | Unité de facturation                       |
| ---------------------------------------------------------- | ------------------------- | ------------------------------------------------- | ------------------------------------------ |
| Lire un texte, faire une voix off                          | Texte → Parole            | Fichiers audio MP3, WAV, etc.                     | Nombre de caractères saisis ou durée audio |
| Convertir un enregistrement en texte                       | Parole → Texte            | Texte dans la langue d’origine, horodatages       | Secondes ou minutes d’audio                |
| Convertir un enregistrement en langue étrangère en anglais | Parole → Texte anglais    | Texte anglais, sans conserver la langue d’origine | Durée audio                                |
| Comprendre le contenu d’un enregistrement                  | Parole → Texte d’analyse  | Résumé, locuteurs, conclusion                     | Tokens correspondant à l’audio saisi       |
| Dialoguer en temps réel                                    | Flux audio bidirectionnel | Audio et événements continus                      | Durée de session ou tokens                 |

## Concepts clés

* **Fréquence d’échantillonnage** \: nombre d’échantillons par seconde, couramment 16 kHz (suffisant pour la reconnaissance vocale), 24 kHz et 44,1 kHz (qualité supérieure). Une fréquence inadaptée provoque des distorsions de lecture ou une baisse de qualité de transcription.
* **Profondeur de bits et canaux** \: 16 bits mono est le choix courant pour la parole ; la stéréo et une profondeur supérieure augmentent le volume du fichier, sans être forcément exploitées par le modèle.
* **Conteneur et encodage** \: MP3 est compressé avec perte et léger ; WAV est généralement non compressé et volumineux ; PCM est un échantillonnage brut sans conteneur, dont les paramètres doivent être précisés manuellement à la lecture.
* **Durée et taille** \: les limites de téléversement combinent souvent taille de fichier et durée ; passer à une fréquence élevée n’améliore pas la reconnaissance et augmente seulement le risque de dépassement.
* **Synchrone et streaming** \: le TTS renvoie des octets audio, l’ASR du JSON. Le streaming réduit l’attente du premier mot ou du premier segment sans modifier le total facturé.

Les valeurs de spécification (durée maximale, formats pris en charge, plage de fréquences) dépendent du modèle ; consultez le tableau des paramètres de requête de chaque page d’interface.

## Description des interfaces

| Capacité                   | Entrée → Sortie                                             | Type de requête                                                                       | Documentation                                 |
| -------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------- | --------------------------------------------- |
| Synthèse vocale (TTS)      | Texte → Audio                                               | Appel HTTP unique ; certains modèles proposent des fragments ou SSE                   | [Texte vers parole](/simidoc/fr/apps/api/audio/speech)                 |
| Transcription vocale (ASR) | Fichier audio → Texte dans sa langue                        | Téléversement multipart ; certains modèles prennent en charge le SSE de transcription | [Transcription audio](/simidoc/fr/apps/api/audio/transcriptions)       |
| Traduction vocale          | Fichier audio multilingue → Texte anglais                   | Requête multipart unique                                                              | [Traduction audio](/simidoc/fr/apps/api/audio/translations)            |
| Synthèse vocale Gemini     | Texte → Audio à une ou plusieurs voix                       | Interactions natif, generateContent pour les anciens modèles compatibles              | [Gemini TTS](/simidoc/fr/apps/api/audio/gemini)                        |
| Compréhension audio Gemini | Enregistrement → Résumé, transcription ou analyse textuelle | Requête multimodale native                                                            | [Compréhension audio](/simidoc/fr/apps/api/audio/gemini-understanding) |
| Voix MiMo                  | Texte / référence vocale → Voix ; enregistrement → Texte    | Routes compatibles autonomes ou Chat Completions officiel                             | [MiMo](/simidoc/fr/apps/api/audio/mimo-audio)                          |
| Voix en temps réel         | Entrée et sortie continues                                  | WebRTC / WebSocket bidirectionnel                                                     | [Realtime](/simidoc/fr/apps/api/pending/realtime)               |

## Synchrone, asynchrone et streaming

* **HTTP synchrone** \: une requête renvoie un fichier audio ou une transcription complète, sans ID de tâche ni étape d’interrogation.
* **Streaming HTTP** \: une même réponse renvoie l’audio ou des événements SSE par fragments ; ce n’est pas une session bidirectionnelle en temps réel. N’appliquez pas un analyseur JSON à un flux binaire.
* **Tâche asynchrone** \: obtenez d’abord un ID de tâche, puis interrogez l’état ; la génération vidéo suit généralement ce mode, pas le TTS/ASR ordinaire.
* **Realtime** \: la session maintient la connexion, permettant au client d’envoyer de l’audio en continu, d’interrompre la lecture et de traiter des événements ; un téléversement de fichier ne la remplace pas.

## Appel simulé

Le corps de requête de la synthèse vocale est du JSON, mais la réponse contient des octets audio, pas du JSON \:

```json
{
  "model": "gpt-4o-mini-tts",
  "voice": "alloy",
  "input": "欢迎使用 SimiRouter。",
  "response_format": "mp3"
}
```

Les en-têtes renvoyés déterminent comment enregistrer le fichier ; le corps est écrit directement dans `.mp3` \:

```text
HTTP/1.1 200 OK
Content-Type: audio/mpeg
Content-Length: 24576

<二进制音频数据>
```

La transcription passe par un téléversement multipart et renvoie du JSON \:

```json
{"text":"欢迎使用 SimiRouter。"}
```

Dans la même catégorie « audio », la synthèse renvoie du binaire et la transcription du JSON ; les analyseurs ne doivent pas être mélangés. Le modèle d’exemple `gpt-4o-mini-tts` est marqué comme obsolète par le fournisseur ; voir [Texte vers parole](/simidoc/fr/apps/api/audio/speech) pour le remplacement et la migration.

## Conditions préalables

Les pages compatibles OpenAI utilisent l’adresse et la clé SimiRouter ; les références natives du fournisseur utilisent l’adresse et la clé correspondantes. La disponibilité d’un modèle dépend de la liste de modèles du compte et des droits du canal ; ne considérez pas toutes les capacités d’un fournisseur comme déjà fournies par la passerelle. Obtenez les autorisations nécessaires avant de téléverser un enregistrement ; le clonage vocal exige le droit d’utiliser la voix et l’information des auditeurs sur la synthèse.

## Références officielles

* [Synthèse vocale OpenAI](https\://developers.openai.com/api/reference/resources/audio/subresources/speech/methods/create)
* [Transcription vocale OpenAI](https\://developers.openai.com/api/reference/resources/audio/subresources/transcriptions/methods/create)
* [Traduction vocale OpenAI](https\://developers.openai.com/api/reference/resources/audio/subresources/translations/methods/create)
* [Compréhension audio Google](https\://ai.google.dev/gemini-api/docs/audio)
* [Google Gemini TTS](https\://ai.google.dev/gemini-api/docs/speech-generation)