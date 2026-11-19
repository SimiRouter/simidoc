# Installation et configuration de Factory Droid CLI

Droid CLI permet de configurer des modèles avec vos propres clés API. Les modèles personnels sont stockés localement ; cela ne signifie pas que les applications Web ou mobiles hébergées par Factory les utilisent.

## Installation

macOS / Linux \:

```bash
curl -fsSL https://app.factory.ai/cli | sh
droid --version
```

Windows PowerShell \:

```powershell
irm https://app.factory.ai/cli/windows | iex
droid --version
```

Ces commandes exécutent les installateurs officiels \: vérifiez leur provenance avant de les lancer. Dans un environnement géré, suivez les règles de l’organisation. Ne désactivez pas systématiquement les protections et ne réduisez pas la politique d’exécution globale. Si une connexion est demandée au lancement, suivez les indications du client.

## Ajouter un modèle SimiRouter

1. Lancez `droid`, exécutez `/settings` et ouvrez **Custom models** ; vous pouvez aussi utiliser `/model`, sélectionnez **Manage custom models**.
2. Cliquez sur **Add model**, puis choisissez le fournisseur générique Chat Completions.
3. Renseignez les champs suivants et enregistrez \:

| Champ        | Valeur                                                |
| ------------ | ----------------------------------------------------- |
| Provider     | `generic-chat-completion-api`                         |
| Base URL     | `https://api.dwchainless.com/v1`                      |
| API Key      | SimiRouter API Key                                    |
| Model        | ID complet d’un modèle accessible au compte           |
| Display name | Par exemple `SimiRouter`, pour l’affichage uniquement |

## Configuration par fichier

Vous pouvez aussi fusionner dans `~/.factory/settings.json` le tableau `customModels`. Sauvegardez d’abord le fichier et conservez les entrées et réglages existants.

```json
{
  "customModels": [
    {
      "model": "MODEL_ID",
      "displayName": "SimiRouter",
      "baseUrl": "https://api.dwchainless.com/v1",
      "apiKey": "${SIMIROUTER_API_KEY}",
      "provider": "generic-chat-completion-api"
    }
  ]
}
```

Remplacez `MODEL_ID` par l’ID réel du modèle, puis définissez dans l’environnement de Droid `SIMIROUTER_API_KEY`.`${SIMIROUTER_API_KEY}` est une référence de variable d’environnement prise en charge par Droid ; ne la remplacez pas par une clé réelle publiquement accessible.

La configuration actuelle utilise `settings.json` et des champs camelCase. Les entrées de l’ancien fichier `config.json` peuvent être migrées au premier lancement. Modifiez ensuite `settings.json` et n’exécutez plus d’ancien script tiers susceptible d’écraser la configuration.

## Vérification

Dans `/model`, sélectionnez **Custom Models**, sélectionnez le modèle SimiRouter et demandez une tâche peu risquée, comme expliquer un fichier. Vérifiez ensuite le modèle et la consommation dans SimiRouter. Adaptez la sortie maximale, les images et les outils au modèle choisi ; ne recopiez pas les capacités d’un autre modèle.

## Références officielles

* [Démarrage rapide de Factory Droid CLI](https\://docs.factory.com/droid-cli/quickstart)
* [Modèles personnalisés Factory (BYOK)](https\://docs.factory.com/model-independence/byok)