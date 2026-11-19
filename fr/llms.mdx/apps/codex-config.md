# Configurer Codex CLI

Cet exemple fournit directement une clé API dans `config.toml`. Le script traite le `config.toml` utilisateur et le `models.json` local ; il ne crée ni ne modifie `auth.json`.

Le script utilise deux URL et une seule clé API \:

* **URL de base d’inférence** \: `https://api.dwchainless.com/v1`, écrite dans `model_providers.simirouter.base_url` pour les requêtes Codex.
* **URL du catalogue des modèles** \: `https://api.dwchainless.com/v1/models`. La même clé API est utilisée comme jeton Bearer ; la liste au format OpenAI est convertie en `~/.codex/models.json`, puis `model_catalog_json` est défini. Ce n’est pas une deuxième URL d’inférence.
* **Clé API** \: la même clé SimiRouter sert aux deux URL. Le script l’envoie uniquement comme identifiant Bearer à ces deux URL fixes et ne l’écrit ni dans la documentation ni ailleurs.

Le catalogue exige une clé valide. Les modèles et les métadonnées de base, comme la longueur de contexte, viennent de la réponse ; la conversion n’invente pas d’outils ou de capacités de raisonnement non confirmés.

* **Linux / macOS** \: `~/.codex/config.toml`
* **Windows** \: `%USERPROFILE%\.codex\config.toml`

## Méthode 1 \: script de configuration automatique (facultative, à vérifier avant exécution)

Le dépôt fournit des scripts Bash et PowerShell. Installez et lancez d’abord Codex CLI ou Codex Desktop ; téléchargez et examinez le script avant d’exécuter le fichier local.

* [Télécharger le script Bash (CDN)](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [Télécharger le script Bash (secours GitHub Raw)](https\://raw.githubusercontent.com/SimiRouter/simidoc/cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [Télécharger le script PowerShell (CDN)](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)
* [Télécharger le script PowerShell (secours GitHub Raw)](https\://raw.githubusercontent.com/SimiRouter/simidoc/cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)

Sous macOS / Linux, exécutez cette commande dans un terminal \:

<Callout type="warn" title="">
  Ces étapes téléchargent un script depuis l’un des liens CDN ou GitHub Raw ci-dessus, sans transmettre directement la réponse réseau à un interpréteur. Examinez le fichier local enregistré avant de l’exécuter.
  Le script écrit la clé API dans `experimental_bearer_token` de `config.toml` ; il ne crée ni ne modifie `auth.json`. Traitez ce fichier comme un secret en clair.
</Callout>

```bash
# Download the script from the public script link above, then review it.
less ./codex-simirouter-setup.sh
bash ./codex-simirouter-setup.sh
```

Sous Windows, exécutez cette commande dans PowerShell \:

```powershell
# Download the script from the public script link above, then review it.
$script = Join-Path (Get-Location) 'codex-simirouter-setup.ps1'
Get-Content -LiteralPath $script
& powershell -File $script
```

<Callout type="info" title="">
  PowerShell 5.1 et PowerShell 7 enregistrent d’abord le fichier afin de pouvoir l’examiner avant la saisie de la clé. Avec PowerShell 7, remplacez `powershell` par `pwsh` dans la dernière ligne.
</Callout>

Choisissez ensuite le modèle dans le menu. À la première exécution, le script demande votre clé API, qui commence par `sk-` et s’obtient dans la console SimiRouter.

Le script effectue les opérations suivantes (la version Bash nécessite Python 3.11 ou une version ultérieure) \:

* **Sauvegarder la configuration existante** \: un instantané de `config.toml` est conservé dans `~/.codex/backup-simirouter/` ; la restauration exige la saisie explicite de `RESTORE`.
* **Synchroniser le catalogue** \: demander l’URL du catalogue avec la même clé, convertir les identifiants et métadonnées de base dans `~/.codex/models.json`, puis définir `model_catalog_json` vers ce fichier.
* **Modifier `config.toml`** \: les champs globaux `model_provider`, `model` et `model_catalog_json` sont mis à jour, ainsi que `[model_providers.simirouter]` \: `base_url`, `wire_api` et `experimental_bearer_token`. Le reste du contenu est conservé autant que possible.
* **Protéger les fichiers** \: les scripts tentent de limiter l’accès au dossier et aux fichiers de configuration à l’utilisateur courant ; un avertissement est affiché si le système refuse.
* **Valider** \: le script Bash utilise Python 3.11+ pour analyser le TOML et le JSON du catalogue avant le remplacement. Les scripts ne valident ni ne modifient `auth.json` et ne prétendent pas qu’un appel d’inférence réel a réussi.

<Callout type="info" title="">
  Relancez le script pour changer de modèle ou choisissez l’option de restauration de la configuration par défaut pour revenir à l’état antérieur à l’installation à l’aide de la sauvegarde.
</Callout>

## Méthode 2 \: configuration manuelle sous Linux / macOS (solution de secours)

Sauvegardez séparément `config.toml` et `auth.json` avant toute modification. Ne déplacez et ne recréez pas tout le dossier `~/.codex`, qui contient aussi l’historique, les sessions et d’autres réglages. Fusionnez uniquement les champs du modèle et du fournisseur, sans remplacer le fichier entier ni créer de tables TOML en double. Conservez les réglages MCP, d’approbation, de bac à sable et de confiance des projets.

### `~/.codex/config.toml`

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
model_catalog_json = "~/.codex/models.json"

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

`model_catalog_json` pointe vers le catalogue local généré depuis `https://api.dwchainless.com/v1/models`. Pour une configuration manuelle, demandez cette URL avec la même clé puis enregistrez le format `models.json` de Codex ; n’utilisez pas directement la liste OpenAI `data`.

Ce fichier contient un jeton en clair \: ne le publiez et ne le partagez pas. Sous Linux / macOS, limitez l’accès après enregistrement \:

```bash
chmod 600 ~/.codex/config.toml
```

### `auth.json` (uniquement pour un autre mode d’authentification)

L’exemple ci-dessus utilise un jeton dans la configuration \: il n’est pas nécessaire de créer ou remplacer `auth.json`. Le JSON ci-dessous sert de référence aux autres modes qui l’exigent. Choisissez une méthode prise en charge par votre version de Codex, sans les cumuler pour masquer une erreur d’authentification.

```json
{
  "OPENAI_API_KEY": "PASTE_API_KEY_HERE"
}
```

## Configuration sous Windows

### PowerShell

Créez le dossier et ouvrez les fichiers de configuration \:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex" | Out-Null
notepad "$env:USERPROFILE\.codex\config.toml"
```

### CMD

```cmd
if not exist "%USERPROFILE%\.codex" mkdir "%USERPROFILE%\.codex"
notepad "%USERPROFILE%\.codex\config.toml"
```

Après sauvegarde, et fusionnez les champs du modèle et du fournisseur ci-dessus dans `config.toml`, sans remplacer les autres réglages. Cet exemple utilise un jeton dans la configuration \: inutile de créer ou remplacer `auth.json`. Sous Windows, réservez l’accès au fichier contenant la clé à votre utilisateur.

## Vérifier le démarrage

```bash
codex
```

<Callout type="warn" title="">
  Sous Windows, `config.toml` et `auth.json` se trouvent dans `%USERPROFILE%\.codex\`. Vérifiez que les fichiers sont enregistrés au bon emplacement.
</Callout>