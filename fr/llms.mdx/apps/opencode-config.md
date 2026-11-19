# Configuration d’OpenCode CLI

OpenCode utilise un fichier de configuration global \:

* **Linux / macOS** \: `~/.config/opencode/opencode.jsonc`
* **Windows** \: `%USERPROFILE%\.config\opencode\opencode.jsonc`

Renseignez d’abord la clé dans `apiKey`, puis exécutez les commandes de vérification. Cet exemple ne référence aucune variable d’environnement \: aucune variable supplémentaire n’est nécessaire. Protégez le fichier contenant la clé et conservez les confirmations d’autorisation par défaut d’OpenCode.

## Fichier de configuration (format compatible V1)

Ajoutez le contenu suivant au fichier et remplacez `apiKey` par votre clé API \:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "openai/gpt-6-astra",
  "small_model": "openai/gpt-6-astra",
  "provider": {
    "openai": {
      "options": {
        "baseURL": "https://api.dwchainless.com/v1",
        "apiKey": "PASTE_API_KEY_HERE"
      },
      "models": {
        "gpt-6-astra": {
          "headers": {
            "originator": "opencode"
          }
        }
      }
    }
  },
  "agent": {
    "title": {
      "options": {
        "reasoningEffort": "none"
      }
    },
    "build": {
      "variant": "xhigh",
      "options": {
        "reasoningSummary": "detailed",
        "textVerbosity": "high"
      }
    },
    "plan": {
      "variant": "xhigh",
      "options": {
        "reasoningSummary": "detailed",
        "textVerbosity": "high"
      }
    }
  }
}
```

## Vérifier la configuration

### Linux / macOS

```bash
opencode debug config
opencode run "你好"
```

### Windows CMD

```cmd
opencode debug config
opencode run "你好"
```

### Windows PowerShell

```powershell
opencode debug config
opencode run "你好"
```

<Callout type="info" title="">
  `opencode debug config` vérifie que la configuration est chargée correctement ; `opencode run "你好"` permet de tester la réponse du modèle.
</Callout>

## Références officielles

[Documentation de configuration OpenCode](https\://opencode.ai/docs/config/) indique les emplacements et formats actuels. Cette page conserve le format V1 compatible ; lors d’une mise à niveau, suivez la migration de votre version sans écraser toute la configuration.