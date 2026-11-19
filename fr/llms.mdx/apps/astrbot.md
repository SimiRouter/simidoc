# Configuration d’AstrBot

AstrBot est un assistant IA open source compatible avec plusieurs plateformes de messagerie. Ce guide connecte SimiRouter avec le protocole compatible OpenAI.

## Ajouter un fournisseur

1. Installez et lancez AstrBot ; les étapes d’installation figurent dans [Documentation officielle d’AstrBot](https\://docs.astrbot.app/).
2. Dans SimiRouter, ouvrez [Gestion des clés API](https://api.dwchainless.com/keys) et créez une clé.
3. Ouvrez le panneau AstrBot, rubrique **Providers → Chat Completion**, cliquez sur **Add**, puis choisissez **OpenAI Compatible**. Les anciennes versions peuvent afficher « Fournisseurs de modèles → Ajouter → OpenAI ».
4. Renseignez les champs suivants et enregistrez \:

| Champ              | Valeur                                                                                        |
| ------------------ | --------------------------------------------------------------------------------------------- |
| Nom du fournisseur | `SimiRouter`                                                                                  |
| API Base URL       | `https://api.dwchainless.com/v1`                                                              |
| API Key            | SimiRouter API Key                                                                            |
| Model              | Depuis [Place des modèles](https://api.dwchainless.com/fr/pricing/) copiez l’ID complet d’un modèle disponible sur le compte |

Cliquez sur **Save and Fetch Models** pour récupérer les modèles, puis utilisez `+` à droite pour ajouter et activer un modèle. Vous pouvez aussi utiliser **Custom Model** pour saisir manuellement son ID.

## Définir le modèle de conversation par défaut

Ouvrez **Config → AI → Model**, puis définissez **Chat Model** sur le modèle ajouté et enregistrez. Utilisez **Test Model** ou envoyez un bref message de test, puis consultez dans SimiRouter [Journaux d’utilisation](https://api.dwchainless.com/usage-logs/common) pour vérifier l’appel.

La compréhension d’images et les appels d’outils doivent être pris en charge à la fois par AstrBot, le modèle et le canal. Un échange textuel réussi ne valide pas toutes les fonctionnalités supplémentaires.

## Références officielles

* [Configuration des fournisseurs AstrBot](https\://docs.astrbot.app/en/providers/llm.html)
* [Connexion des services de modèles à AstrBot](https\://docs.astrbot.app/en/providers/start.html)