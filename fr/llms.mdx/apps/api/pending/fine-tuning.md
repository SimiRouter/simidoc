# Ajustement fin (non pris en charge)

L’ajustement fin modifie le comportement d’un modèle de base à l’aide de données d’entraînement et produit un nouveau modèle utilisable pour l’inférence. OpenAI propose l’apprentissage supervisé, l’optimisation directe des préférences (DPO) et le renforcement ; les méthodes disponibles dépendent du modèle de base choisi.

**SimiRouter ne prend pas encore en charge l’ajustement fin. Les pages suivantes conservent documentation et exemples officiels directs, avec une clé de projet OpenAI. L’entraînement peut être facturé.**

OpenAI met progressivement fin à l’ajustement fin en libre-service \: les nouveaux utilisateurs ne peuvent pas créer de tâches, tandis que les utilisateurs existants éligibles le peuvent jusqu’au **6 janvier 2027**, sauf si le modèle de base est retiré plus tôt. Les modèles déjà ajustés restent disponibles en inférence uniquement jusqu’à la dépréciation de leur modèle de base. Les conditions, modèles et dates peuvent changer ; consultez la [chronologie officielle des dépréciations](https\://developers.openai.com/api/docs/deprecations) avant utilisation.

## Aperçu

L’ajustement fin modifie les poids du modèle, pas le prompt. Il convient aux contraintes de format stables, à un ton fixe et à un vocabulaire métier ; il ne convient pas pour injecter des connaissances susceptibles de changer à tout moment — pour ce type de besoin, la recherche ou un prompt système plus long coûte moins cher. La validation des résultats doit utiliser des échantillons indépendants n’ayant pas participé à l’entraînement.

| Ce que vous voulez faire             | Entrée                                    | Sortie                             | Mode d’exécution                                    |
| ------------------------------------ | ----------------------------------------- | ---------------------------------- | --------------------------------------------------- |
| Entraîner un modèle dédié            | Jeu d’entraînement JSONL + modèle de base | Objet tâche et `fine_tuned_model`  | Asynchrone en arrière-plan, interrogation de l’état |
| Observer le processus d’entraînement | ID de tâche                               | Journaux d’événements et métriques | Consultation paginée, pas SSE                       |
| Arrêter l’entraînement               | ID de tâche                               | Objet tâche annulé                 | Requête synchrone                                   |

## Concepts clés

* **Modèle de base** \: détermine les méthodes et le prix disponibles. Les méthodes et paramètres pris en charge diffèrent selon le modèle de base ; choisir une méthode incorrecte entraîne un rejet à la création de la tâche.
* **Jeu d’entraînement et jeu de validation** \: JSONL, une conversation par ligne ; le minimum officiel est de 10 échantillons, mais commencez généralement par 50, et une amélioration nette est souvent visible entre 50 et 100. Le jeu de validation doit être préparé séparément et ne doit pas chevaucher le jeu d’entraînement.
* **État de la tâche** \: `queued`, `running`, `succeeded`, `failed`, `cancelled`. Seul `succeeded` produit un nouveau modèle utilisable pour l’inférence ; pour `failed`, lisez `error` afin de déterminer s’il s’agit d’un problème de données ou de paramètres.
* **Modèle produit** \: en cas de succès, l’identifiant `fine_tuned_model` est renvoyé ; utilisez-le à la place du modèle de base pour lancer l’inférence. Le modèle a un cycle de vie indépendant ; supprimez-le vous-même si nécessaire.
* **Coût** \: l’entraînement est facturé par tokens, et le modèle produit peut générer des frais de stockage pendant sa période de conservation ; un essai sur un petit échantillon avant d’élargir est plus maîtrisable qu’un envoi unique de toutes les données.

## Interfaces et modes d’exécution

| Opération                                                           | Requête officielle                                      | Mode d’exécution                                                    |
| ------------------------------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------- |
| [Créer une tâche (non pris en charge)](/simidoc/fr/apps/api/pending/fine-tuning/create)                    | `POST /v1/fine_tuning/jobs`                             | Renvoie l’objet tâche, entraînement asynchrone en arrière-plan.     |
| [Obtenir les détails d’une tâche (non pris en charge)](/simidoc/fr/apps/api/pending/fine-tuning/retrieve)  | `GET /v1/fine_tuning/jobs/{fine_tuning_job_id}`         | Consultation synchrone de l’état, du modèle produit et des erreurs. |
| [Lister les tâches (non pris en charge)](/simidoc/fr/apps/api/pending/fine-tuning/list)                    | `GET /v1/fine_tuning/jobs`                              | Consultation paginée synchrone.                                     |
| [Obtenir les événements d’une tâche (non pris en charge)](/simidoc/fr/apps/api/pending/fine-tuning/events) | `GET /v1/fine_tuning/jobs/{fine_tuning_job_id}/events`  | Journaux paginés, pas SSE.                                          |
| [Annuler une tâche (non pris en charge)](/simidoc/fr/apps/api/pending/fine-tuning/cancel)                  | `POST /v1/fine_tuning/jobs/{fine_tuning_job_id}/cancel` | Arrête la tâche et renvoie son objet.                               |

## Déroulement de base

1. Préparez un jeu d’entraînement JSONL selon la méthode d’ajustement fin choisie, ainsi qu’un jeu de validation indépendant.
2. Téléversez les données via [l’interface officielle de téléversement de fichiers](/simidoc/fr/apps/api/pending/files/upload) avec `purpose=fine-tune`.
3. Choisissez un modèle prenant en charge cette méthode, créez la tâche et conservez son ID.
4. Consultez l’état et les événements de la tâche ; `succeeded` indique la réussite, `failed` exige de lire `error`, `cancelled` indique une annulation.
5. Une fois l’entraînement réussi, utilisez le `fine_tuned_model` renvoyé pour l’inférence et validez les résultats sur un jeu d’évaluation indépendant.

Une requête de création réussie ne signifie pas un entraînement réussi ; annuler une tâche ne signifie pas non plus que l’utilisation déjà consommée est annulée. Ne recréez pas directement la même tâche d’entraînement à cause d’un délai réseau.

## Références officielles

* [Guide OpenAI d’optimisation des modèles](https\://developers.openai.com/api/docs/guides/model-optimization)
* [Guide OpenAI d’ajustement fin supervisé](https\://developers.openai.com/api/docs/guides/supervised-fine-tuning)
* [OpenAI Fine-tuning Jobs API](https\://developers.openai.com/api/reference/resources/fine_tuning/subresources/jobs)