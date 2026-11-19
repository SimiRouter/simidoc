# Embeddings (non pris en charge)

**SimiRouter ne prend pas encore en charge l’interface d’embeddings.** Cette section explique les protocoles fournisseurs ; les exemples utilisent uniquement l’accès direct avec le compte et la clé du fournisseur concerné.

## Aperçu

Les embeddings transforment du texte ou d’autres entrées autorisées par le modèle en vecteurs de longueur fixe, pour la recherche sémantique, le regroupement et l’analyse de similarité. Ils ne renvoient pas de réponse de conversation et n’exécutent pas directement de recherche ; le processus de recherche comprend généralement trois étapes \: rappel de candidats par embeddings, classement fin par reclassement, puis génération de la réponse par le modèle. Voir [Embeddings OpenAI](/simidoc/fr/apps/api/pending/embeddings/openai) et [Embeddings Gemini](/simidoc/fr/apps/api/pending/embeddings/gemini) pour le détail des interfaces.

| Ce que vous voulez faire                           | Entrée                                          | Sortie                                             | Point d’accès                                                                                |
| -------------------------------------------------- | ----------------------------------------------- | -------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Générer des vecteurs de texte                      | Une ou plusieurs chaînes de texte               | Tableau de flottants de longueur fixe              | OpenAI `POST /v1/embeddings` ; Google `POST /v1beta/models/{model}:embedContent`             |
| Générer des vecteurs de médias tels que des images | Contenu multimodal pris en charge par le modèle | Tableau de flottants dans le même espace vectoriel | Uniquement les modèles multimodaux tels que `gemini-embedding-2`                             |
| Construire un index par lots                       | Plusieurs chaînes de texte                      | Liste de vecteurs alignée sur l’ordre d’entrée     | `batchEmbedContents` ou Batch API ; les tâches par lots asynchrones sont traitées séparément |

## Concepts clés

* **Dimensions** \: OpenAI `text-embedding-3-small` utilise 1536 dimensions par défaut et `text-embedding-3-large` 3072 dimensions par défaut ; Gemini Embedding 2 prend en charge 128 à 3072 dimensions (768, 1536 ou 3072 recommandées), tandis que `gemini-embedding-001` utilise 3072 par défaut. Les dimensions peuvent être réduites dans la plage du modèle, sans dépasser sa limite ; les deux fournisseurs lient directement le coût de stockage et de recherche de la base vectorielle aux dimensions.
* **Normalisation et similarité** \: OpenAI renvoie des vecteurs de longueur 1, dont le produit scalaire est la similarité cosinus ; Gemini exige une renormalisation hors 3072 dimensions (`gemini-embedding-2` la gère automatiquement, `gemini-embedding-001` manuellement). La base vectorielle doit fixer une seule mesure.
* **L’index et la requête doivent être isomorphes** \: un même lot de documents et les requêtes doivent utiliser le même modèle, les mêmes dimensions et la même configuration de tâche. Après un changement de modèle ou de dimensions, l’ancien index et les nouveaux vecteurs ne sont plus comparables et doivent être reconstruits.
* **`index` n’est pas un classement** \: l’`index` de la réponse indique seulement à quelle entrée correspond ce vecteur, pour l’aligner avec le texte d’origine ; le classement de pertinence relève du reclassement, voir [Reclassement](/simidoc/fr/apps/api/pending/rerank).
* **Synchrone et par lots** \: les embeddings sont des requêtes synchrones, sans SSE ; pour de gros volumes, utilisez Batch API ou `batchEmbedContents`, plutôt que des appels unitaires en boucle.

## Appel simulé

Exemple de requête et de réponse en accès direct à OpenAI. Utilisez la clé de projet `$OPENAI_API_KEY` pour envoyer la requête.

```json
{
  "model": "text-embedding-3-small",
  "input": ["文档检索的第一段文本", "如何计算两段文本的相似度"]
}
```

```json
{
  "object": "list",
  "data": [
    { "object": "embedding", "index": 0, "embedding": [0.0023, -0.0119, 0.0044] },
    { "object": "embedding", "index": 1, "embedding": [0.0011, 0.0087, -0.0026] }
  ],
  "model": "text-embedding-3-small",
  "usage": { "prompt_tokens": 12, "total_tokens": 12 }
}
```

Les vecteurs réels comptent 1536 nombres flottants ; seuls les trois premiers sont conservés ici ; `usage` est facturé selon les tokens d’entrée, indépendamment de la longueur de sortie.

## Points clés pour la recherche

Ces deux ensembles de réponses n’ont pas la même structure ; remplacer seulement le nom du modèle ne suffit pas. Il n’y a généralement ni SSE ni Realtime ; une tâche par lots asynchrone n’est pas non plus un flux de vecteurs en temps réel. Les documents et les requêtes d’une même base vectorielle doivent utiliser le même modèle, les mêmes dimensions et la même stratégie de normalisation ; après un changement de modèle, il faut généralement reconstruire l’index.

## Références officielles

* [OpenAI Embeddings](https\://developers.openai.com/api/docs/guides/embeddings)
* [OpenAI Create embeddings](https\://developers.openai.com/api/reference/resources/embeddings)
* [Google Embeddings](https\://ai.google.dev/gemini-api/docs/embeddings)