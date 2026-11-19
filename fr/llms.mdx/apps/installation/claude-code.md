# Installation de Claude Code CLI

Claude Code fonctionne sur macOS, Linux, Windows natif et WSL. L’installateur natif ne nécessite pas Node.js ; seule l’installation npm impose une version adaptée.

## macOS / Linux / WSL

Dans Bash ou Zsh, exécutez la commande officielle \:

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
```

La commande télécharge et exécute un script officiel. Dans un environnement géré, examinez-le ou utilisez une méthode approuvée. Ne l’exécutez pas avec `sudo`.

## Windows PowerShell

```powershell
irm https://claude.ai/install.ps1 | iex
claude --version
```

L’installation ne demande pas les droits administrateur. Git for Windows est facultatif sous Windows natif, sauf pour l’outil Bash. Sous WSL, utilisez les commandes Linux dans le terminal WSL, pas les réglages PowerShell du client Windows.

## Configurer et lancer

1. Consultez [Configurer Claude CLI](/simidoc/fr/apps/claude-config) pour définir l’adresse et la clé SimiRouter.
2. Ouvrez le dossier du projet et exécutez `claude`.
3. Conservez les confirmations et commencez par une opération peu risquée, comme expliquer un fichier, puis vérifiez les journaux SimiRouter.

`claude --version` confirme seulement l’installation de la commande, pas la connexion API. Ne désactivez pas l’antivirus et ne réduisez pas globalement la sécurité pour contourner un problème d’installation.

## Références officielles

[Anthropic \: installation et exigences Claude Code](https\://code.claude.com/docs/en/setup).