# Compréhension vidéo

La compréhension reçoit une vidéo existante et renvoie résumé, description de scènes, ordre des événements ou réponses. Elle ne génère pas une nouvelle vidéo depuis une consigne. Dots, Kimi et Gemini proposent tous la vidéo en entrée, avec des formats, références de fichiers et authentifications différents.

## Fournisseurs et protocoles

| Documentation                          | Modèle officiel d’exemple | Entrée vidéo                                                   | Requête et réponse                                                                  |
| -------------------------------------- | ------------------------- | -------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| [Compréhension vidéo Dots](/simidoc/fr/apps/api/video/understanding/dots)     | `dots3-note-prev`         | URL lisible par le modèle dans `video_url.url`                 | Tableau de messages Chat Completions ; texte final dans `choices[].message.content` |
| [Compréhension vidéo Kimi](/simidoc/fr/apps/api/video/understanding/kimi)     | `kimi-k3`                 | data URL vidéo Base64 ou référence `ms://` de fichier Moonshot | Tableau de messages Chat Completions ; texte final dans `choices[].message.content` |
| [Compréhension vidéo Gemini](/simidoc/fr/apps/api/video/understanding/gemini) | `gemini-3.8-flash`        | Données vidéo intégrées ou URI de fichier acceptée par Google  | Cette page utilise Interactions ; texte dans `steps[].content[]`                    |

Les requêtes vidéo Dots utilisent l’en-tête officiel `api-key` ; Kimi utilise Bearer et Gemini `x-goog-api-key`. Le champ `video_url` de Dots et Kimi est une extension multimodale de ces fournisseurs, pas un standard vidéo universel pour tous les services compatibles OpenAI. Le même chemin `/v1/chat/completions` ne suffit pas pour échanger leurs charges vidéo.

## Synchrone, streaming et références de fichiers

* **Sans streaming** \: une requête HTTP attend la réponse textuelle complète, sans ID de tâche de génération vidéo.
* **Streaming** \: SSE renvoie le texte progressivement ; téléchargement, décodage et analyse peuvent précéder le premier événement. Ce n’est pas un téléversement continu de caméra et le premier mot n’est pas garanti immédiatement.
* **Références de fichiers** \: téléversement préalable chez le fournisseur, puis référence dans l’analyse. Un téléversement terminé n’est pas une analyse terminée et les ID ne sont pas interchangeables entre fournisseurs.
* **Requêtes parallèles** \: plusieurs requêtes indépendantes sont émises par le client, chacune avec ses limites, contexte et utilisation ; ce n’est pas un paramètre « parallèle » du corps.

## Préparation des entrées

Utilisez une vidéo que vous êtes autorisé à traiter. Lien direct public, page de partage, chemin local et Base64 sont des entrées différentes à transmettre selon le protocole. Une page Xiaohongshu ou d’un autre site n’est pas une URL de fichier téléchargeable ; connexion obligatoire et protection contre les liens externes peuvent empêcher la lecture par le modèle.

Durée, résolution, trames échantillonnées et taille influent sur délai, tokens et frais ; consultez les limites du fournisseur. Vérifiez instants et événements dans l’original, sans les assimiler à une preuve exacte trame par trame ou un alignement forcé.

## Intégration SimiRouter

Les sous-pages fournissent les exemples officiels directs, avec les clés fournisseurs. Via SimiRouter, confirmez l’ID complet disponible, le mappage vidéo du canal et les références de fichiers ; une capacité officielle du modèle ne prouve pas une intégration testée sur le site. Clés fournisseur et SimiRouter ne sont pas interchangeables.

## Références officielles

* [Dots \: entrée vidéo](https\://dots.ai/platform/docs#video-input)
* [Démarrage rapide Kimi K3](https\://platform.kimi.com/docs/guide/kimi-k3-quickstart) et [Modèles visuels](https\://platform.kimi.com/docs/guide/use-kimi-vision-model)
* [Google \: compréhension vidéo](https\://ai.google.dev/gemini-api/docs/video-understanding)