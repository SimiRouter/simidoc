# Configuration de LangBot

LangBot stocke les informations de connexion dans un fournisseur auquel les modèles font référence. Un fournisseur compatible OpenAI permet de configurer les modèles de conversation SimiRouter.

## Créer le fournisseur et le modèle

1. Consultez [Documentation officielle de LangBot](https\://docs.langbot.app/) pour installer et lancer l’application.
2. Depuis SimiRouter, ouvrez [Gestion des clés API](https://api.dwchainless.com/keys) pour copier la clé.
3. Dans la page des modèles LangBot, ajoutez un modèle de conversation et sélectionnez ou créez un fournisseur compatible OpenAI.
4. Renseignez la connexion \:

| Champ                     | Valeur                                      |
| ------------------------- | ------------------------------------------- |
| Base URL / URL de requête | `https://api.dwchainless.com/v1`            |
| API Key                   | SimiRouter API Key                          |
| Nom du modèle             | ID complet d’un modèle accessible au compte |

Le modèle hérite de l’adresse et de la clé du fournisseur. Activez la vision ou les outils selon les capacités réelles du modèle ; ces options n’ajoutent pas de capacités absentes.

## Associer un pipeline

Sélectionnez le modèle ajouté dans le pipeline, enregistrez, puis envoyez un message via le débogueur ou le robot associé. Dans SimiRouter, ouvrez [Journaux d’utilisation](https://api.dwchainless.com/usage-logs/common) pour vérifier l’heure, le modèle et la consommation.

## Base de connaissances et embeddings (non pris en charge)

La base de connaissances LangBot nécessite un modèle d’embeddings. SimiRouter ne propose pas actuellement cette intégration ; un modèle de conversation ne remplace pas un service de vecteurs. Configurez un autre fournisseur d’embeddings compatible ou une solution intégrée selon la documentation LangBot.

## Références officielles

[Configuration des modèles LangBot](https\://docs.langbot.app/zh/usage/models/readme) explique la relation entre fournisseurs, modèles de conversation, embeddings et pipelines.