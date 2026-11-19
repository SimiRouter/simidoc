# Installation de Codex CLI

## macOS / Linux

OpenAI propose un installateur autonome \:

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex --version
```

Cette commande télécharge et exécute un script officiel. Dans un environnement géré, examinez-le ou utilisez un gestionnaire approuvé selon la documentation.

## Windows

Sous Windows, vous pouvez installer dans un terminal natif ou utiliser les outils Linux sous WSL. Pour l’installation et le bac à sable, consultez [Documentation Windows OpenAI](https\://learn.chatgpt.com/docs/windows/windows-sandbox).

Avec npm, préparez d’abord une version Node.js compatible selon sa documentation, puis exécutez \:

```powershell
npm install -g @openai/codex
codex --version
```

Sous WSL, installez et configurez Codex dans WSL. Ne confondez pas les réglages Windows sous `%USERPROFILE%` avec ceux de Linux sous `~/.codex`. Ne désactivez pas les protections et n’utilisez pas systématiquement un compte administrateur.

## Configurer et vérifier

1. Consultez [Configurer Codex CLI](/simidoc/fr/apps/codex-config) et fusionnez `config.toml` pour les champs de fournisseur et de modèle, après sauvegarde.
2. Dans le dossier du projet, exécutez `codex`.
3. Conservez l’approbation et le bac à sable par défaut. Demandez d’abord l’explication d’un fichier, puis vérifiez l’appel SimiRouter.

`codex --version` prouve que la commande s’exécute, pas que l’API est connectée. N’écrasez pas tout le dossier `~/.codex`, afin de préserver les sessions et autres réglages.

## Références officielles

* [OpenAI Codex CLI](https\://learn.chatgpt.com/docs/codex/cli)
* [Bac à sable Windows OpenAI](https\://learn.chatgpt.com/docs/windows/windows-sandbox)