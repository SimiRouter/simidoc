# Configuration de Memoh

Memoh est une plateforme multiagents open source avec espaces de travail indépendants et mémoire à long terme. Conversation, synthèse et transcription utilisent des types de clients différents ; n’utilisez pas le même protocole pour tous.

## Installer Memoh

Consultez [Déploiement officiel de Memoh](https\://docs.memoh.ai/self-hosted/docker) pour installer la version actuelle. Sécurisez le compte à la première connexion ; ne réutilisez pas un mot de passe par défaut d’un ancien guide.

## Ajouter un fournisseur

1. Dans SimiRouter, ouvrez [Gestion des clés API](https://api.dwchainless.com/keys) et créez une clé.
2. Dans la barre latérale des paramètres Memoh, ouvrez **Models**, puis choisissez **Add Provider**.
3. Utilisez un modèle de fournisseur OpenAI Chat Completions ou créez un fournisseur personnalisé \:

| Champ       | Valeur                           |
| ----------- | -------------------------------- |
| Name        | `SimiRouter`                     |
| Client Type | `openai-completions`             |
| Base URL    | `https://api.dwchainless.com/v1` |
| API Key     | SimiRouter API Key               |

`openai-responses` correspond au protocole Responses et `openai-completions` à Chat Completions. Ce dernier ne désigne pas l’ancienne complétion de texte malgré son nom. Les types OAuth ne remplacent pas un fournisseur avec clé API SimiRouter.

## Ajouter et activer les modèles

Dans les détails du fournisseur, cliquez sur **Import Models** pour importer, ou saisissez manuellement l’ID accessible au compte. Un import groupé peut laisser les modèles désactivés ; activez-les avant de choisir le modèle de conversation du robot.

Envoyez un bref message, puis ouvrez dans SimiRouter [Journaux d’utilisation](https://api.dwchainless.com/usage-logs/common) pour vérifier la requête. Mémoire, recherche et autres fonctions Memoh peuvent nécessiter des fournisseurs supplémentaires. SimiRouter ne propose pas d’embeddings \: un modèle de conversation ne remplace pas un modèle vectoriel.

## Références officielles

* [Fournisseurs et modèles Memoh](https\://docs.memoh.ai/integrations/providers/llm)
* [Projet Memoh](https\://github.com/felinics/Memoh)