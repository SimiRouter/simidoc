# Musique (non prise en charge)

Cette section décrit le protocole public de génération de Google Lyria. SimiRouter n’a pas encore ouvert cette capacité ; tous les exemples se connectent directement à l’API Gemini de Google AI Studio avec `https://generativelanguage.googleapis.com` et une clé API Google. Vertex AI exige un protocole distinct, non vérifié sur cette page ; ne remplacez pas directement l’adresse.

## Aperçu

| Capacité                     | Entrée                                             | Produit                                                           | Nature de cette section       |
| ---------------------------- | -------------------------------------------------- | ----------------------------------------------------------------- | ----------------------------- |
| Générer un extrait musical   | Description textuelle ou image                     | Environ 30 secondes d’audio, MP3 par défaut                       | Référence de l’API officielle |
| Générer une chanson complète | Prompt décrivant les couplets et les refrains      | Chanson de plusieurs minutes, avec paroles et structure possibles | Référence de l’API officielle |
| Performance en temps réel    | Prompts et contrôles de lecture envoyés en continu | Blocs audio PCM continus                                          | Référence de l’API officielle |

## Concepts clés

* **Extrait et chanson** \: un extrait dure exactement 30 secondes et convient à l’écoute et à la boucle ; la longueur et la structure d’une chanson sont pilotées par le prompt, la durée n’est donc pas garantie avec précision.
* **Session en temps réel** \: un WebSocket bidirectionnel qui reçoit en continu des prompts et les contrôles PLAY et PAUSE pendant la connexion ; il ne s’agit pas d’une requête ponctuelle transformée en option stream.
* **Format audio** \: MP3 par défaut, WAV sur demande ; l’interface temps réel renvoie des blocs PCM bruts que l’application doit mettre en mémoire tampon et encapsuler elle-même.
* **Clés et adresses** \: les exemples de cette page utilisent uniquement l’adresse de l’API Gemini de Google AI Studio et une clé API Google ; SimiRouter ne relaie pas encore les modèles musicaux et le protocole distinct de Vertex AI n’est pas vérifié ici.

Les limites de durée, la fréquence d’échantillonnage et le débit dépendent du modèle ; voir les tableaux de paramètres de [Lyria](/simidoc/fr/apps/api/music/lyria) et [RealTime](/simidoc/fr/apps/api/music/realtime).

## Description de l’interface

| Mode                           | Protocole officiel          | Capacité                                                                  | Documentation                        |
| ------------------------------ | --------------------------- | ------------------------------------------------------------------------- | ------------------------------------ |
| Génération musicale ponctuelle | `POST /v1beta/interactions` | Créer un extrait ou une chanson complète depuis du texte ou une image     | [Génération musicale Lyria](/simidoc/fr/apps/api/music/lyria) |
| Musique en temps réel          | WebSocket bidirectionnel    | Produire continuellement et ajuster dynamiquement de l’audio instrumental | [Lyria RealTime](/simidoc/fr/apps/api/music/realtime)         |

Lyria Clip produit des extraits de 30 secondes ; Lyria 3.5 vise des chansons plus complètes. RealTime est expérimental et utilise une connexion persistante, pas l’option stream d’Interactions. Les modèles musicaux ne lisent pas du texte ordinaire à voix haute ; pour le TTS, utilisez [Audio](/simidoc/fr/apps/api/audio).

## Appel simulé

La génération ponctuelle officielle de Google utilise Interactions ; la requête décrit le style et la structure \:

```json
{
  "model": "lyria-3-clip-preview",
  "input": "温暖的钢琴与弦乐，节奏舒缓，适合纪录片开场"
}
```

L’audio de la réponse est en Base64, pas une adresse de téléchargement \:

```json
{
  "steps": [
    {
      "type": "model_output",
      "content": [
        { "type": "text", "text": "[Instrumental]" },
        { "type": "audio", "data": "<Base64音频>" }
      ]
    }
  ]
}
```

Les éléments audio et texte peuvent être entrelacés ; il faut parcourir `content[]` et les prendre selon `type` ; ne prendre que le dernier élément ferait manquer les paroles ou les indications de structure musicale.

## Authentification et droits

Interactions officiel Google utilise `x-goog-api-key: $GEMINI_API_KEY` ; la connexion temps réel utilise le SDK officiel ou son protocole WebSocket. Les contenus générés restent soumis aux conditions Google, au droit d’auteur et aux autorisations vocales. Modèles disponibles, régions et quotas dépendent du compte Google.

## Références officielles

[Génération musicale Google](https\://ai.google.dev/gemini-api/docs/music-generation), [Musique en temps réel](https\://ai.google.dev/gemini-api/docs/realtime-music-generation).