# Configuration de Grok CLI

Dans Grok CLI, l’adresse du catalogue et l’adresse d’inférence se configurent séparément. `[endpoints].models_base_url` sert à la fois de source du catalogue et de base d’inférence par défaut ; le `base_url` d’un modèle peut la remplacer. Si vous n’en réglez qu’une, l’autre peut encore viser l’adresse officielle \: vérifiez les deux.

Emplacement du fichier de configuration \:

* **Linux / macOS** \: `~/.grok/config.toml`
* **Windows** \: `%USERPROFILE%\.grok\config.toml`

## Installer / Mettre à jour

Linux / macOS \:

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
grok update
grok --version
```

Windows (PowerShell) \:

```powershell
irm https://x.ai/cli/install.ps1 | iex
```

Si vous avez installé via WinGet, mettez à jour avec `winget upgrade` plutôt qu’avec `grok update`.

<Callout type="warn" title="XAI_API_KEY est requis au démarrage">
  Au démarrage, Grok CLI récupère la liste des modèles en lisant uniquement la variable d’environnement `XAI_API_KEY` ; si elle est absente, la récupération échoue, quel que soit le `api_key` du fichier de configuration. Avec SimiRouter, placez la même clé dans cette variable \:

  ```bash
  export XAI_API_KEY="PASTE_API_KEY_HERE"
  ```

  Ne placez jamais la clé dans un fichier versionné. Pour un usage durable, stockez-la dans un fichier d’environnement en `600`, puis chargez-le avec `source`.
</Callout>

## Écrire le fichier de configuration

Écrivez ce qui suit dans `~/.grok/config.toml` et remplacez `api_key` par votre clé API \:

```toml
[models]
default = "grok-4.5"

[endpoints]
models_base_url = "https://api.dwchainless.com/v1"

[model."grok-4.5"]
base_url = "https://api.dwchainless.com/v1"
model = "grok-4.5"
name = "Grok 4.5"
api_key = "PASTE_API_KEY_HERE"
api_backend = "responses"
context_window = 500000
supports_backend_search = true

[session]
# 可选：官方默认值为 85；80 会更早触发自动压缩
auto_compact_threshold_percent = 80

[ui]
max_thoughts_width = 120
yolo = false
compact_mode = false
# permission_mode = "always-approve"  # enable only in trusted environments
```

Ces réglages d’interface correspondent à l’usage local présenté \: largeur maximale de raisonnement de 120, mode compact désactivé et approbation automatique des outils.

<Callout type="warn" title="">
  L’exemple désactive `yolo` et laisse `permission_mode = "always-approve"` en commentaire. Les activer autorise Grok à modifier des fichiers et exécuter des commandes sans confirmation ; **à réserver à un projet et un environnement de confiance**.
</Callout>

<Callout type="info" title="">
  `api_key` doit contenir une clé SimiRouter, pas un identifiant OAuth grok.com `refresh_token`. La clé est stockée en clair. Sous Linux/macOS, exécutez `chmod 600 ~/.grok/config.toml`. Sur une machine partagée, préférez la méthode officielle `env_key`.
</Callout>

## Vérifier la configuration

```bash
grok inspect
grok models
grok --model grok-4.5 --output-format json -p '只输出 YAI_GROK_OK'
```

## Références officielles

* [xAI Grok CLI \: modèles personnalisés](https\://docs.x.ai/build/overview)
* [xAI Grok CLI \: référence de configuration](https\://docs.x.ai/build/settings)