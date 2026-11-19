# Vidéo Veo (modèles d’aperçu Gemini API désactivés)

## Aperçu

Veo génère des vidéos via les opérations de longue durée de Gemini API \: appelez d’abord `predictLongRunning` pour lancer la tâche, récupérez le nom de l’opération, puis interrogez cette opération ; une fois terminée, téléchargez le MP4 depuis l’URI de fichier de la réponse.

**Les modèles d’aperçu `veo-3.1-generate-preview`, `veo-3.1-fast-generate-preview` et autres sur Gemini API ont été désactivés le 2026-10-22.** Cette page conserve la structure du protocole comme référence pour comprendre les appels existants et préparer une migration ; cet endpoint ne doit pas être considéré aujourd’hui comme une interface de production utilisable. Vous pouvez migrer vers `gemini-omni-1.2-flash` ou utiliser un modèle GA sur Gemini Enterprise Agent Platform.

| Ce que vous voulez faire   | Entrée                                                       | Sortie                     | Endpoint                                            |
| -------------------------- | ------------------------------------------------------------ | -------------------------- | --------------------------------------------------- |
| Lancer la génération vidéo | Prompt, première frame, dernière frame ou image de référence | Nom de l’opération         | `POST /v1beta/models/{MODEL_ID}:predictLongRunning` |
| Interroger l’opération     | Nom de l’opération                                           | `done`, résultat ou erreur | `GET /v1beta/{operation_name}`                      |
| Télécharger la vidéo       | URI de fichier du résultat                                   | Octets MP4                 | `GET {video.uri}`                                   |

## Concepts clés

* **Une opération n’est pas un ID de tâche** \: la réponse de création renvoie `name`, par exemple `models/veo-3.1-generate-preview/operations/...`. L’interrogation, la lecture du résultat et le diagnostic utilisent tous ce nom complet.
* **La condition d’achèvement est `done: true`** \: `done: false` indique seulement que le traitement continue. Lorsque `done: true`, vérifiez aussi la présence d’une `error` et si `response.generateVideoResponse.generatedSamples[0].video.uri` est vide.
* **Plage de durée** \: la documentation officielle annonce un minimum de 11 secondes et un maximum de 6 minutes. L’interrogation peut utiliser un intervalle de 10 à 15 secondes, avec une attente totale maximale côté client.
* **Durée et résolution liées** \: la durée n’a que trois valeurs, 4, 6 et 8 secondes. Avec 1080p, 4k, une image de référence ou une extension vidéo, la durée doit être de 8 secondes ; une requête de 4 secondes ne passe pas directement en 1080p.
* **L’audio est généré avec le modèle** \: la documentation Gemini API décrit l’audio comme toujours activé, sans commutateur `generateAudio` séparé. Le prompt peut contenir des dialogues, des effets sonores et des sons d’ambiance.
* **Facturation selon la plateforme** \: Gemini API et Agent Platform ont deux systèmes de facturation et de quotas ; le prix unitaire suit la page tarifaire du fournisseur. Après la désactivation des modèles d’aperçu, aucun nouveau coût d’appel ne devrait être généré.

## Spécifications et capacités

| Indicateur       | Modèles d’aperçu Gemini API                                                                                                                                                                                    | Modèles GA Agent Platform                                                                         |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| ID de modèle     | `veo-3.1-generate-preview`, `veo-3.1-fast-generate-preview`, `veo-3.1-lite-generate-preview` ; `veo-3.0-generate-001`, `veo-3.0-fast-generate-001`. La documentation Gemini API marque ces ID comme Deprecated | `veo-3.1-generate-001`, `veo-3.1-fast-generate-001` (GA) ; `veo-3.1-lite-generate-001` en Preview |
| Résolution       | `720p` par défaut ; `1080p` et `4k` réservés à 8 secondes                                                                                                                                                      | Le modèle standard produit `720p`, `1080p` et `4K` ; le modèle Fast produit `720p` et `1080p`     |
| Rapport d’aspect | `16:9`, `9:16`                                                                                                                                                                                                 | `16:9`, `9:16`                                                                                    |
| Durée            | `4`, `6`, `8` secondes                                                                                                                                                                                         | `4`, `6`, `8` secondes ; le mode image de référence accepte seulement 8 secondes                  |
| Audio            | Génération native, toujours activée                                                                                                                                                                            | Le tableau des capacités mentionne la génération de son                                           |
| Références       | `image` en première frame, `lastFrame` en dernière frame, jusqu’à 3 `referenceImages`                                                                                                                          | Images de référence d’actif, première et dernière frames                                          |
| Extension vidéo  | 7 secondes ajoutées par fois, 20 fois au maximum ; entrée de 141 secondes au plus, sortie de 148 secondes au plus ; 720p uniquement                                                                            | Capacité d’extension prise en charge ; paramètres selon la documentation de la plateforme         |

La résolution et la durée ne sont pas des options indépendantes \: 1080p, 4k, les images de référence et l’extension exigent toutes 8 secondes ; 4 ou 6 secondes ne s’utilisent qu’en 720p. Les images de référence sont limitées à 3 et les première et dernière frames contraignent l’image, pas le style. L’audio est toujours généré et ne peut pas être désactivé par un paramètre. Après migration vers Agent Platform, les ID de modèle, l’authentification et les quotas changent tous ; ne remplacez pas simplement l’endpoint de cette page par un nom de modèle GA pour continuer.

## Flux d’appel

1. Vérifiez la plateforme et les identifiants. Gemini API utilise `x-goog-api-key` ; Agent Platform utilise l’authentification propre à la plateforme, et les deux ne sont pas interchangeables.
2. Soumettez à `POST /v1beta/models/{MODEL_ID}:predictLongRunning` les champs `instances` et `parameters`. Le prompt va dans `instances[0].prompt` et la première frame dans `instances[0].image`.
3. Conservez `name` de la réponse. Une création réussie signifie seulement que l’opération est établie, pas que la vidéo est téléchargeable.
4. Interrogez `GET /v1beta/{operation_name}` jusqu’à `done: true`. Si une `error` existe, terminez selon son contenu au lieu de continuer d’attendre.
5. Lisez l’adresse de téléchargement dans `response.generateVideoResponse.generatedSamples[0].video.uri`, appelez cet URI avec la clé API et autorisez les redirections HTTP.
6. Réarchivez le fichier dans votre propre stockage. La documentation officielle indique que les vidéos générées sont conservées 2 jours et qu’une extension réinitialise le délai ; ne dépendez pas d’une URL de fournisseur à long terme.

## Appel simulé

Voici une archive illustrative, destinée à montrer la structure des messages de l’ancienne Gemini API. Les modèles d’aperçu sont désactivés depuis le 2026-10-22 et aucune nouvelle tâche n’est créée aujourd’hui à partir de ces exemples ; les noms d’opération et les URL sont indicatifs.

Requête de lancement \:

```json
{
  "instances": [
    {
      "prompt": "示例：海边日落，镜头缓慢推进。"
    }
  ],
  "parameters": {
    "aspectRatio": "16:9",
    "resolution": "720p",
    "numberOfVideos": 1,
    "durationSeconds": 8,
    "personGeneration": "allow_all"
  }
}
```

La réponse de création ne contient que le nom de l’opération \:

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": false
}
```

Réponse de l’opération terminée \:

```json
{
  "name": "models/veo-3.1-generate-preview/operations/demo-operation",
  "done": true,
  "response": {
    "generateVideoResponse": {
      "generatedSamples": [
        {
          "video": {
            "uri": "https://example.com/demo-veo.mp4"
          }
        }
      ]
    }
  }
}
```

Avec `done: true` mais sans `generatedSamples` ou avec un URI vide, traitez la tâche comme un échec et conservez le nom de l’opération.

## Accès et sessions

* **Adresse de base** \: `https://generativelanguage.googleapis.com/v1beta`.
* **En-tête d’authentification** \: `x-goog-api-key: PASTE_API_KEY_HERE`, avec `Content-Type: application/json`.
* **Deux jeux d’adresses** \: pour Gemini API en direct, utilisez `https://generativelanguage.googleapis.com/v1beta` avec l’en-tête `x-goog-api-key` ; n’utilisez `https://api.dwchainless.com` et `Authorization: Bearer` avec la clé de ce site que lorsque le canal confirme explicitement ce mappage de passerelle ; ne supposez pas qu’il suffit de remplacer l’adresse et l’authentification. Si SimiRouter fournit un modèle de même nom, le chemin, les champs et le mode d’interrogation dépendent du mappage du canal. Les modèles GA d’Agent Platform utilisent des adresses régionales comme `https://{region}-aiplatform.googleapis.com` et l’authentification du projet ; il ne s’agit ni d’une adresse `generativelanguage`, ni d’un simple remplacement de chaîne de modèle.
* **Délai d’expiration et idempotence** \: après un délai dépassé sur la requête de lancement, vérifiez d’abord si une opération a été créée ; conserver `name` importe plus que conserver le statut HTTP. Ne relancez pas la même tâche parce que l’attente est longue.
* **Conseil de migration** \: la forme d’interface de `gemini-omni-1.2-flash` diffère de `predictLongRunning` ; le code d’interrogation existant devra peut-être être réécrit. Avant la migration, référez-vous à la documentation officielle de migration et à la liste des modèles disponibles du compte.

## Références officielles

* [Gemini API \: génération vidéo Veo](https\://aistudio.google.com/docs/veo)
* [Note de désactivation des modèles d’aperçu Veo 3.1](https\://aistudio.google.com/docs/models/veo-3.1-generate-preview)
* [Gemini Enterprise Agent Platform \: Veo 3.1](https\://docs.cloud.google.com/gemini-enterprise-agent-platform/models/veo/3-1-generate)