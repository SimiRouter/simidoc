# Files API (non prise en charge)

Files API est l’interface de gestion des ressources de fichiers d’OpenAI. Après téléversement, vous obtenez un ID de fichier, référençable par l’ajustement fin, le traitement par lots ou d’autres points d’accès officiels acceptant un ID de fichier. Cela ne correspond pas à la capacité du modèle à reconnaître le contenu d’un fichier.

**SimiRouter ne prend pas encore en charge Files API. Les pages suivantes conservent descriptions officielles et exemples directs, exigeant une clé du projet OpenAI.**

## Aperçu

Files API répond au besoin de téléverser une fois puis de référencer plusieurs fois \: le fichier existe d’abord comme ressource indépendante, puis les points d’accès d’ajustement fin, de traitement par lots, etc. le récupèrent par ID. Elle convient aux jeux d’entraînement, aux corps de requêtes par lots et aux ressources devant être lues de façon répétée ; les pièces jointes d’une conversation unique ne passent pas par cette interface, mais sont transmises directement dans la requête.

| Cas d’usage                                          | Marqueur au téléversement            | Ce qu’il faut faire ensuite                                   |
| ---------------------------------------------------- | ------------------------------------ | ------------------------------------------------------------- |
| Données d’entraînement pour ajustement fin supervisé | `purpose=fine-tune`                  | Créer une tâche d’entraînement et interroger son état         |
| Requêtes ou sorties par lots                         | `purpose=batch`                      | Créer une tâche de traitement par lots et interroger son état |
| Autres points d’accès acceptant un ID de fichier     | Selon les exigences du point d’accès | Se référer à la documentation de ce point d’accès             |

## Concepts clés

* **ID de fichier et portée** \: l’ID appartient au projet ou à l’organisation qui l’a créé et ne peut pas être réutilisé d’un fournisseur ou d’un projet à l’autre ; insérer l’ID de fichier d’un autre service dans une requête OpenAI renvoie 404 ou 403.
* **purpose détermine l’usage** \: le `purpose` fourni au téléversement indique à qui les données sont destinées (par exemple `fine-tune`, `batch`), et les points d’accès consommateurs vérifient chacun le format, la taille et le nombre de lignes.
* **Cycle de vie** \: un téléversement réussi signifie seulement que la ressource existe ; pour savoir si l’entraînement ou le traitement par lots est terminé, consultez l’état de la tâche correspondante, sans vous fier au résultat du téléversement.
* **Séparation du contenu et des métadonnées** \: `filename`, `bytes` et `status` de l’objet fichier sont des métadonnées ; le contenu vu par le modèle est lu par le point d’accès consommateur, et les deux ne se synchronisent pas automatiquement.

## Interfaces et modes d’exécution

| Opération                                                                | Requête officielle                | Mode d’exécution                                                     |
| ------------------------------------------------------------------------ | --------------------------------- | -------------------------------------------------------------------- |
| [Téléverser un fichier (non pris en charge)](/simidoc/fr/apps/api/pending/files/upload)                   | `POST /v1/files`                  | Téléversement multipart, objet fichier renvoyé de manière synchrone. |
| [Obtenir les informations d’un fichier (non pris en charge)](/simidoc/fr/apps/api/pending/files/retrieve) | `GET /v1/files/{file_id}`         | Métadonnées renvoyées de manière synchrone.                          |
| [Lister les fichiers (non pris en charge)](/simidoc/fr/apps/api/pending/files/list)                       | `GET /v1/files`                   | Consultation paginée synchrone.                                      |
| [Obtenir le contenu d’un fichier (non pris en charge)](/simidoc/fr/apps/api/pending/files/content)        | `GET /v1/files/{file_id}/content` | Téléchargement des octets du fichier, pas un SSE du modèle.          |
| [Supprimer un fichier (non pris en charge)](/simidoc/fr/apps/api/pending/files/delete)                    | `DELETE /v1/files/{file_id}`      | Suppression de la ressource, avec le résultat de suppression.        |

Un téléversement réussi ne signifie pas que la tâche consommatrice est terminée. Les états de traitement de l’entraînement, du traitement par lots et de l’indexation sont interrogés via leurs points d’accès respectifs. Les limites d’usage, de format et de taille des fichiers sont également déterminées conjointement par le point d’accès consommateur.

## Ressources et sécurité

Un ID de fichier appartient au projet ou à l’organisation qui l’a créé ; n’utilisez pas directement dans OpenAI l’ID de fichier d’un autre fournisseur ou d’une passerelle. Les exemples lisent la clé depuis une variable d’environnement ; ne placez pas de jeux d’entraînement, de données personnelles ou de clés dans un dépôt public.

## Références officielles

* [OpenAI Files API](https\://developers.openai.com/api/reference/resources/files)
* [Téléversement de fichiers OpenAI](https\://developers.openai.com/api/reference/resources/files/methods/create)