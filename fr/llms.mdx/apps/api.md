# Référence API

SimiRouter authentifie les requêtes par clé API et les relaie selon le modèle, le groupe et le canal. Les interfaces compatibles et natives peuvent utiliser des adresses, authentifications et structures différentes ; changer seulement le domaine ne suffit pas.

## Aperçu

Les interfaces s’organisent en trois niveaux \: choisir la capacité (texte, images, vidéo, audio, outils, découverte de modèles), puis le protocole (compatible OpenAI, Gemini natif, Claude Messages), enfin vérifier les paramètres sur la page de l’endpoint. Trois formes d’appel déterminent la rédaction de la requête \:

| Forme            | Caractéristiques                                | Endpoints typiques                                          |
| ---------------- | ----------------------------------------------- | ----------------------------------------------------------- |
| Synchrone        | Une connexion renvoie le résultat complet       | Listes de modèles, génération d’images, transcription audio |
| Streaming (SSE)  | Une connexion diffuse des événements successifs | Chat, compréhension d’images, appels d’outils               |
| Tâche asynchrone | Renvoie un ID de tâche, puis interroge son état | Génération vidéo, fine-tuning officiel                      |

Une expiration ou une déconnexion du client n’annule pas nécessairement l’exécution amont. Vérifiez la tâche et les journaux d’utilisation avant de resoumettre une requête de génération.

## Préparer l’intégration

1. Suivez [Créer une clé SimiRouter](/simidoc/fr/apps/getting-started) et créez une clé.
2. Choisissez l’ID complet d’un modèle accessible à votre compte dans le [catalogue des modèles](https://api.dwchainless.com/fr/pricing/).
3. Vérifiez l’adresse, le format et les exigences du modèle sur sa page. L’adresse racine de SimiRouter est `https://api.dwchainless.com` ; `/v1` ou `/v1beta` dépend du chemin de l’interface.
4. Conservez les clés dans l’environnement ou un coffre serveur. Les requêtes peuvent être facturées ; n’exposez pas les clés dans le navigateur ou du code public.

[Utiliser l’API avec des scripts](/simidoc/fr/apps/api-script) propose une requête textuelle complète en Python, Node.js, curl et Go.

## Adresses des services

Avant de passer à l’API d’un fournisseur, vérifiez le chemin, l’authentification, l’ID du modèle et les champs de la requête. Réutilisez la structure de la requête uniquement si les deux services suivent le même protocole et que la page de l’endpoint confirme leur compatibilité.

| Service                           | Adresse                                      | Authentification                                |
| --------------------------------- | -------------------------------------------- | ----------------------------------------------- |
| Passerelle SimiRouter             | `https://api.dwchainless.com`                | `Authorization: Bearer` avec une clé SimiRouter |
| Google Gemini API (clé AI Studio) | `https://generativelanguage.googleapis.com`  | `x-goog-api-key`                                |
| Google Vertex AI                  | `https://{region}-aiplatform.googleapis.com` | Jeton d’accès OAuth                             |
| OpenAI                            | `https://api.openai.com`                     | `Authorization: Bearer` avec une clé OpenAI     |
| Anthropic                         | `https://api.anthropic.com`                  | `x-api-key`                                     |
| xAI                               | `https://api.x.ai`                           | `Authorization: Bearer`                         |
| Volcengine Ark                    | `https://ark.cn-beijing.volces.com/api/v3`   | `Authorization: Bearer`                         |
| Alibaba Cloud DashScope           | `https://dashscope.aliyuncs.com`             | `Authorization: Bearer` avec une clé DashScope  |

Pour le débogage local, utilisez `http://127.0.0.1:3001` comme adresse de passerelle. Les clés des fournisseurs et les clés SimiRouter ne sont pas interchangeables ; lorsque vous remplacez l’adresse, remplacez aussi l’authentification.

## Catalogue des fonctionnalités

| Fonction                                                     | Valeur                                                                                                                                        | Mode d’appel                                                                                    |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| [Conversation](/simidoc/fr/apps/api/chat)                                       | Chat Completions, Responses, Claude Messages et génération Gemini                                                                             | Sans streaming \: réponse complète ; en streaming \: événements SSE progressifs                 |
| [Générer une image](/simidoc/fr/apps/api/images)                                | Génération, retouche, images de référence et reconnaissance, couvrant les protocoles OpenAI, Gemini, Qwen, Jimeng, Grok et FLUX               | Données d’image, URL ou texte selon le protocole ; consultez chaque interface pour le streaming |
| [Vidéo](/simidoc/fr/apps/api/video)                                             | Protocoles de génération Seedance, Kling, Veo, PixVerse, Wan, Happy Horse et Grok Imagine, et compréhension vidéo ; intégration Jimeng prévue | Génération généralement soumise puis consultée ; compréhension via une interface multimodale    |
| [Audio](/simidoc/fr/apps/api/audio)                                             | Entrées et sorties audio OpenAI, Gemini et MiMo                                                                                               | Fichiers, audio binaire ou événements ; ne mélangez pas leurs parseurs                          |
| [Synthèse vocale](/simidoc/fr/apps/api/audio/speech)                            | Texte vers parole                                                                                                                             | Fichier audio ou événements de streaming pris en charge par le modèle                           |
| [Transcription vocale](/simidoc/fr/apps/api/audio/transcriptions)               | Audio vers texte dans la langue d’origine                                                                                                     | Téléversement audio puis transcription                                                          |
| [Traduction audio](/simidoc/fr/apps/api/audio/translations)                     | Audio vers texte anglais                                                                                                                      | Téléversement puis texte anglais, pas une sortie vocale traduite                                |
| [Musique (non prise en charge)](/simidoc/fr/apps/api/music)                     | Exemples officiels Google Lyria                                                                                                               | Référence Google en accès direct uniquement                                                     |
| [Embeddings (non pris en charge)](/simidoc/fr/apps/api/pending/embeddings)      | Références vectorielles officielles OpenAI et Gemini                                                                                          | Référence du fournisseur en accès direct uniquement                                             |
| [Reclassement](/simidoc/fr/apps/api/pending/rerank)                             | Classement de documents par pertinence                                                                                                        | Appeler le protocole du fournisseur indiqué                                                     |
| [Voix en temps réel](/simidoc/fr/apps/api/pending/realtime)                     | Protocole OpenAI Realtime                                                                                                                     | Connexion bidirectionnelle, pas une requête HTTP de fichier audio                               |
| [Outils](/simidoc/fr/apps/api/tools)                                            | Appels de fonctions et recherche Web                                                                                                          | Le modèle propose l’appel ; exécutez l’outil adapté et renvoyez le résultat                     |
| [Modération](/simidoc/fr/apps/api/pending/moderations)                          | Classification de sécurité du texte et des images                                                                                             | Catégories et scores                                                                            |
| [Récupérer les modèles](/simidoc/fr/apps/api/models)                            | Listes aux formats OpenAI et Gemini                                                                                                           | Identifiants de modèles ; une liste ne garantit pas toutes les capacités                        |
| [Compréhension de fichiers](/simidoc/fr/apps/api/upload)                        | Transmettre le contenu à un modèle multimodal compatible                                                                                      | Distinct de l’API Files autonome                                                                |
| [Ajustement fin (non pris en charge)](/simidoc/fr/apps/api/pending/fine-tuning) | Référence officielle d’ajustement fin                                                                                                         | Référence OpenAI en accès direct uniquement                                                     |
| [API Files (non prise en charge)](/simidoc/fr/apps/api/pending/files)           | Référence officielle de gestion des fichiers                                                                                                  | Référence OpenAI en accès direct uniquement                                                     |

## Lire les descriptions d’interfaces

Chaque page décrit la méthode, les paramètres, les champs de réponse, les exemples de code, les erreurs et les références officielles. Les exemples pour la passerelle utilisent une clé SimiRouter. Les exemples en accès direct utilisent les identifiants du fournisseur. Les fonctions signalées comme non prises en charge renvoient uniquement à la documentation du fournisseur.