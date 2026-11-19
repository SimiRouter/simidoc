# Autres capacités et références à intégrer

Cette section regroupe les interfaces qui ne sont pas encore ouvertes comme capacités générales de SimiRouter \: embeddings, fichiers, ajustement fin, Realtime, modération et reclassement. Leur différence avec les capacités déjà activées ne réside pas dans la difficulté du protocole, mais dans le fait que la passerelle fournisse ou non le routage, l’authentification et la facturation.

## Aperçu

Vérifiez d’abord l’état, puis décidez si vous écrivez du code. Figurer dans cette section ne signifie pas que l’état est identique.

| État                             | Signification                                                                                                       | Ce que vous pouvez faire maintenant                                                                       |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Explicitement non pris en charge | La passerelle ne fournit pas cette capacité, et elle ne deviendra pas disponible en changeant simplement de domaine | Utilisez uniquement la référence en accès direct au fournisseur, avec la clé du fournisseur               |
| Pas encore pris en charge        | Non ouvert actuellement, mais le protocole lui-même est stable                                                      | Validez via la référence en accès direct au fournisseur ; ne l’écrivez pas comme un appel à la passerelle |
| Canal à confirmer                | La disponibilité dépend du compte et de la configuration du canal                                                   | Confirmez d’abord le modèle et le routage, puis décidez si vous en dépendez                               |

## Concepts clés

* **Référence en accès direct** \: les adresses et l’authentification des exemples de cette section appartiennent au fournisseur. Remplacer `api.openai.com` par le domaine de la passerelle ne rend pas la capacité disponible ; le chemin, le mappage des champs et les droits doivent être explicitement pris en charge par le canal.
* **Propriété de la clé** \: les clés du fournisseur et les clés SimiRouter ne sont pas interchangeables. Les exemples en accès direct doivent utiliser la clé du fournisseur correspondant ; n’y insérez pas une clé de la passerelle.
* **Propriété des ressources** \: les ID de fichier, ID de tâche et ID de session appartiennent au projet ou à l’organisation qui les a créés et ne peuvent pas être réutilisés directement d’un fournisseur ou d’un projet à l’autre.
* **État et facturation** \: une tâche asynchrone renvoie d’abord un ID, puis son état est interrogé ; une création réussie ne signifie pas une exécution réussie, et annuler une tâche ne signifie pas que l’utilisation déjà consommée est annulée.

## Liste des capacités

| Catégorie           | État SimiRouter               | Nature du protocole                                                             | Référence                       |
| ------------------- | ----------------------------- | ------------------------------------------------------------------------------- | ------------------------------- |
| Embeddings          | Pas encore pris en charge     | Retour synchrone de vecteurs, tâches par lots séparées                          | [Embeddings](/simidoc/fr/apps/api/pending/embeddings)      |
| Gestion de fichiers | Non pris en charge            | Téléversement, liste, métadonnées, téléchargement et suppression                | [Fichiers](/simidoc/fr/apps/api/pending/files)             |
| Ajustement fin      | Non pris en charge            | Création de tâches d’entraînement asynchrones, état et événements               | [Ajustement fin](/simidoc/fr/apps/api/pending/fine-tuning) |
| Realtime            | Canal dédié à confirmer       | Sessions avec état WebRTC / WebSocket                                           | [Realtime](/simidoc/fr/apps/api/pending/realtime)          |
| Modération          | Modèle et routage à confirmer | Classification de sécurité synchrone, sans garantie de filtrage de conversation | [Modération](/simidoc/fr/apps/api/pending/moderations)     |
| Reclassement        | Modèle et routage à confirmer | Classement synchrone de pertinence des documents                                | [Reclassement](/simidoc/fr/apps/api/pending/rerank)        |

Pour les interfaces musicales, voir [Musique (non prise en charge)](/simidoc/fr/apps/api/music). Les sessions temps réel, les ressources téléversées et les tâches d’entraînement impliquent généralement des droits, du stockage et des frais supplémentaires ; avant d’intégrer une application, définissez explicitement la politique de conservation et de suppression des données.