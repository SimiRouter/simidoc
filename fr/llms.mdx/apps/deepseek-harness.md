# Configurer DeepSeek Harness

DeepSeek Harness (`dsh`) est un framework d’agents open source de DeepSeek AI. En configurant SimiRouter comme fournisseur personnalisé, vous pouvez utiliser ses modèles dans l’interface web de Harness et dans les tâches sans interface.

## Prérequis

Avant de commencer, préparez les éléments suivants \:

* Un compte SimiRouter et une clé API
* Node.js et `npx`
* Un terminal sous macOS, Linux ou Windows
* Le dossier du projet dans lequel l’agent doit intervenir

## Installer et démarrer

Placez-vous dans le dossier du projet à confier à l’agent, puis exécutez \:

```bash
npx @deepseek-ai/dsh web
```

L’interface web est accessible par défaut à `http://127.0.0.1:3080`. Le dossier de démarrage n’est que l’emplacement de fichiers par défaut ; une nouvelle interface web ne sélectionne pas d’espace de travail automatiquement. Ajoutez ce dossier dans l’interface \: le champ de saisie de session reste désactivé tant qu’aucun espace de travail n’est choisi.

Pour changer de port \:

```bash
npx @deepseek-ai/dsh web --port 8080
```

## Configurer SimiRouter dans l’interface web (recommandé)

### 1. Ouvrir les paramètres des modèles

Dans l’interface web de DeepSeek Harness, ouvrez **Settings → Models**.

![Ouvrir les paramètres des modèles de DeepSeek Harness](/simidoc/assets/deepseek-harness/open-model-settings.png)

### 2. Ajouter un fournisseur personnalisé

Choisissez **Add a custom provider**, puis renseignez \:

| Champ        | Valeur                           |
| ------------ | -------------------------------- |
| Provider ID  | `simirouter`                     |
| Display name | `SimiRouter`                     |
| Base URL     | `https://api.dwchainless.com/v1` |
| API protocol | `openai-completions`             |
| API key      | Votre clé API SimiRouter         |

![Renseigner le fournisseur personnalisé SimiRouter](/simidoc/assets/deepseek-harness/custom-provider-form.png)

<Callout type="warn" title="">
  Provider ID est référencé par les conversations, le modèle par défaut et les identifiants. Il ne peut pas être renommé directement après l’enregistrement. Conservez la valeur minuscule `simirouter`.
</Callout>

### 3. Récupérer les modèles

Dans **Model catalog**, sélectionnez **Fetch available models**. Harness utilise la Base URL et la clé API actuelles pour demander la liste des modèles.

Cochez les modèles souhaités et enregistrez. Si la récupération automatique échoue, saisissez manuellement un identifiant, par exemple `gpt-6-astra`. Le nom doit correspondre exactement à un modèle disponible pour le groupe de votre clé API.

![Sélectionner les modèles du fournisseur SimiRouter](/simidoc/assets/deepseek-harness/select-provider-models.png)

### 4. Sélectionner le modèle

Après l’enregistrement, repérez **SimiRouter** dans le sélecteur de modèles près du champ de saisie et choisissez le modèle à utiliser. Celui-ci devient le modèle par défaut des nouvelles conversations. Les conversations ayant déjà envoyé des requêtes conservent leur modèle antérieur.

![Sélectionner un modèle SimiRouter dans DeepSeek Harness](/simidoc/assets/deepseek-harness/model-picker.png)

## Configuration avec un patch de profil

La configuration avancée des fournisseurs du profil Web utilise `$DSH_HOME/profiles/web/cordis.patch.yml` (par défaut `~/.dsh/profiles/web/cordis.patch.yml`). Sauvegardez le fichier avant de fusionner les réglages suivants sans écraser les extensions et fournisseurs existants \:

```yaml
- id: llm-pi-ai
  config:
    providers:
      simirouter:
        displayName: SimiRouter
        apiKeyEnv: SIMIROUTER_API_KEY
        api: openai-completions
        baseURL: https://api.dwchainless.com/v1
        models:
          - id: MODEL_ID
```

Remplacez `MODEL_ID` par l’ID complet du modèle et définissez dans l’environnement de lancement de Harness `SIMIROUTER_API_KEY`. Dans l’interface Web, choisissez ensuite le modèle SimiRouter. Cette configuration concerne le profil Web ; ne supposez pas qu’un autre profil en hérite.

## Vérifier la configuration

1. Ouvrez l’interface web \: `http://127.0.0.1:3080` par défaut, ou le port passé à `--port` au démarrage.
2. Vérifiez que **SimiRouter** et les modèles enregistrés apparaissent dans le sélecteur.
3. Créez une conversation et envoyez un court message de test.
4. Vérifiez l’heure, le modèle et la consommation dans les journaux SimiRouter pour confirmer cet appel.

## Mode sans interface

Le profil Headless désactive par défaut le stockage d’identifiants géré par le Web. Une clé enregistrée dans l’interface n’est donc pas automatiquement utilisable. Configurez le fournisseur dans le profil Headless et passez la clé API par l’environnement de lancement. Consultez [Identifiants du profil Headless DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness/blob/master/packages/bundle/headless/README.md#credentials).

## Questions fréquentes

### `MISSING_CREDENTIAL`

Harness ne trouve pas `SIMIROUTER_API_KEY`. Enregistrez à nouveau la clé dans **Settings → Models**, ou définissez cette variable d’environnement dans le terminal qui lance le processus.

### `UNKNOWN_MODEL`

Le modèle actuel n’est pas présent dans la liste du profil actuel `simirouter` de `models`. Récupérez à nouveau les modèles ou ajoutez manuellement l’identifiant exact.

### Erreur 401 lors de la récupération des modèles ou d’une conversation

* Vérifiez que la clé API est complète, valide et dépourvue d’espaces superflus.
* Vérifiez que Base URL vaut `https://api.dwchainless.com/v1`.
* Vérifiez que le groupe de votre clé API peut utiliser le modèle choisi.

### Les requêtes ne passent pas par SimiRouter

Vérifiez que vous avez ajouté un **custom provider** dont Provider ID est `simirouter`. Les fournisseurs intégrés DeepSeek, OpenAI et Anthropic continuent d’utiliser leurs propres points de terminaison officiels.

### La modification du modèle par défaut ne s’applique pas

Créez une nouvelle conversation pour tester. Les conversations ayant déjà envoyé des requêtes conservent leur modèle enregistré.

## Références officielles

* [DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness)
* [Guide de configuration des modèles DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/providers.zh.md)