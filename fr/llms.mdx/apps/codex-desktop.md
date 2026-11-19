# Configurer l’application de bureau Codex

L’application de bureau Codex permet de se connecter avec une clé API et d’ouvrir le fichier `config.toml` utilisateur depuis l’application. Après la configuration suivante, les requêtes de Codex passent par l’API compatible Responses de SimiRouter.

<Callout type="info" title="">
  Le champ de connexion porte toujours le nom **OpenAI API key**. Saisissez-y votre clé API SimiRouter, par exemple `sk-...`.
</Callout>

## Prérequis

Avant de commencer, préparez les éléments suivants \:

* La dernière version de l’application de bureau Codex
* Un compte SimiRouter
* Une clé API créée dans la console SimiRouter
* Un compte autorisé à utiliser le modèle que vous souhaitez configurer

## Configuration

### 1. Se connecter avec une clé API

1. Ouvrez l’application de bureau Codex.
2. Sur la page de connexion, sélectionnez **Sign in another way**.
3. Dans le champ **OpenAI API key**, saisissez votre clé API SimiRouter.
4. Choisissez **Continue** pour accéder à l’application.

![Saisir la clé API dans l’application de bureau Codex](/simidoc/assets/codex-desktop/codex-api-key-login.png)

### 2. Ouvrir la configuration utilisateur

1. Ouvrez les paramètres de Codex.
2. Sélectionnez **Configuration**.
3. Dans **Custom config.toml settings**, sélectionnez **User config**.
4. Choisissez **Open config.toml** pour ouvrir la configuration utilisateur.

![Ouvrir le config.toml utilisateur dans Codex](/simidoc/assets/codex-desktop/codex-user-config.png)

### 3. Ajouter la configuration SimiRouter

Sauvegardez d’abord votre `config.toml`. Fusionnez les champs du modèle et du fournisseur ci-dessous sans remplacer tout le fichier. Conservez les réglages MCP, de confiance des projets, d’approbation et de bac à sable ; ne créez pas de tables TOML en double.

```toml
model_provider = "simirouter"
review_model = "gpt-6-astra"
model = "gpt-6-astra"
model_reasoning_effort = "xhigh"
plan_mode_reasoning_effort = "high"
model_reasoning_summary = "auto"
model_verbosity = "high"

suppress_unstable_features_warning = true
web_search = "live"

[model_providers.simirouter]
name = "simirouter"
base_url = "https://api.dwchainless.com/v1"
wire_api = "responses"
stream_idle_timeout_ms = 900000
supports_websockets = false
http_headers = { "x-openai-actor-authorization" = "api.dwchainless.com" }
requires_openai_auth = false
experimental_bearer_token="PASTE_API_KEY_HERE"
```

Enregistrez le fichier, puis quittez complètement Codex et rouvrez l’application.

<Callout type="info" title="">
  Cet exemple fournit directement le jeton avec `requires_openai_auth = false` et `experimental_bearer_token`. Remplacez la valeur d’exemple par votre clé API SimiRouter. Il n’est pas nécessaire de configurer aussi `auth.json`, ni de réutiliser la clé enregistrée à la connexion. Comme `config.toml` contient une clé en clair, ne le publiez et ne le partagez pas. Sous Linux / macOS, limitez l’accès avec `chmod 600 ~/.codex/config.toml` ; sous Windows, limitez les permissions du fichier. Conservez vos réglages d’approbation, de bac à sable et de confiance des projets \: la connexion d’un fournisseur ne nécessite pas de désactiver les confirmations de sécurité.
</Callout>

## Vérifier la configuration

Après avoir rouvert Codex \:

1. Ouvrez un projet ou un espace de travail.
2. Demandez d’abord à Codex une tâche peu risquée, comme expliquer un fichier.
3. Vérifiez ensuite l’heure, le modèle et la consommation dans les journaux SimiRouter. Le nom du client et l’identité annoncée par le modèle ne prouvent pas le routage.

## Questions fréquentes

### Clé API invalide

* Recopiez la clé API complète depuis la console SimiRouter.
* Vérifiez l’absence d’espaces superflus avant et après la clé.
* Assurez-vous que la clé commence par `sk-` et reste valide.

### Configuration non prise en compte

* Vérifiez que vous modifiez bien le fichier **User config** `config.toml`.
* Les valeurs de `model_provider = "simirouter"` et `[model_providers.simirouter]` doivent être strictement identiques.
* Après l’enregistrement, quittez entièrement l’application, au lieu de simplement fermer la fenêtre.

### Erreur de modèle ou de connexion

* Vérifiez que `base_url` vaut `https://api.dwchainless.com/v1`.
* Vérifiez que `wire_api` vaut `responses`.
* Vérifiez que le groupe de votre clé API peut utiliser `gpt-6-astra`. Pour un autre modèle, remplacez `model` par son nom exact.

Pour configurer manuellement `auth.json`, changer de modèle ou utiliser la version en ligne de commande, consultez [Configurer Codex CLI](/simidoc/fr/apps/codex-config).

## Références officielles

* [Référence de configuration OpenAI Codex](https\://developers.openai.com/codex/config-reference/)