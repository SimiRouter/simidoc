# Configurer Claude CLI

Claude Code se connecte à la passerelle API au moyen de variables d’environnement. Définissez d’abord ces variables, puis lancez `claude`.

## Linux / macOS

```bash
export ANTHROPIC_AUTH_TOKEN="PASTE_API_KEY_HERE"
export ANTHROPIC_BASE_URL="https://api.dwchainless.com"

# 可选：自定义默认模型映射（不配置也可正常使用）
export ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-6-astra"
export ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-terra"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-luna"
```

## Windows CMD

```cmd
set ANTHROPIC_AUTH_TOKEN=PASTE_API_KEY_HERE
set ANTHROPIC_BASE_URL=https://api.dwchainless.com

:: 可选：自定义默认模型映射（不配置也可正常使用）
set ANTHROPIC_DEFAULT_OPUS_MODEL=gpt-6-astra
set ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-5.6-terra
set ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-5.6-luna
```

## Windows PowerShell

```powershell
$env:ANTHROPIC_AUTH_TOKEN="PASTE_API_KEY_HERE"
$env:ANTHROPIC_BASE_URL="https://api.dwchainless.com"

# 可选：自定义默认模型映射（不配置也可正常使用）
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-6-astra"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-terra"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-luna"
```

## Vérifier le démarrage

Une fois les variables d’environnement configurées, exécutez la commande suivante dans un terminal \:

```bash
claude
```

Après un bref message, vérifiez le modèle et la requête dans les journaux SimiRouter. L’ouverture de l’interface de conversation ne valide pas la connexion API.

## Références officielles

[Documentation des passerelles Claude Code](https\://code.claude.com/docs/en/llm-gateway) décrit la connexion à une passerelle. `ANTHROPIC_BASE_URL` est l’adresse racine ; le client ajoute `/v1/messages` ; n’ajoutez pas une seconde fois `/v1`. Le canal utilisé doit prendre en charge la correspondance de modèles.