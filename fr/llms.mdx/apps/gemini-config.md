# Configuration de Gemini CLI

Définissez les variables d’environnement pour pointer Gemini CLI vers SimiRouter.

## macOS / Linux

**Temporaire, pour le terminal actuel \:**

```bash
export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
export GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**Persistant, en ajoutant au fichier de configuration du shell \:**

```bash
install -d -m 700 ~/.config
umask 077
printf '%s\n' \
  'export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"' \
  'export GEMINI_API_KEY="PASTE_API_KEY_HERE"' > ~/.config/simiroouter.env
chmod 600 ~/.config/simiroouter.env
# Add this line to ~/.zshrc or ~/.bashrc: source ~/.config/simiroouter.env
source ~/.config/simiroouter.env
```

<Callout type="info" title="">
  La clé est stockée avec les droits `600` dans `~/.config/simiroouter.env`, et non dans un profil shell exécuté à chaque connexion. Ajoutez `source ~/.config/simiroouter.env` à `~/.bashrc` ou `~/.zshrc` pour la rendre persistante, et empêchez les autres utilisateurs de lire le fichier sur une machine partagée.
</Callout>

## Windows PowerShell

**Temporaire \:**

```powershell
$env:GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
$env:GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**Persistant, en ajoutant au profil PowerShell \:**

```powershell
Add-Content $PROFILE 'Set-Item -Path Env:GOOGLE_GEMINI_BASE_URL -Value "https://api.dwchainless.com"'
Add-Content $PROFILE 'Set-Item -Path Env:GEMINI_API_KEY -Value "PASTE_API_KEY_HERE"'
```

## Windows CMD

**Temporaire \:**

```cmd
set GOOGLE_GEMINI_BASE_URL=https://api.dwchainless.com
set GEMINI_API_KEY=PASTE_API_KEY_HERE
```

**Persistant, via les variables utilisateur \:**

1. Consultez `Win + R`, saisissez `sysdm.cpl`, puis validez
2. Cliquez sur Avancé → Variables d’environnement
3. Dans Variables utilisateur, cliquez sur Nouveau et ajoutez séparément `GOOGLE_GEMINI_BASE_URL` et `GEMINI_API_KEY`
4. Redémarrez le terminal pour appliquer les variables

## Vérifier le démarrage

```bash
gemini
```

Au lancement, choisissez l’authentification par clé API, envoyez un bref message, puis vérifiez l’appel dans SimiRouter. L’ouverture du client ne prouve pas la connexion à l’API.

## Questions fréquentes

**Le message `GEMINI_API_KEY` indique une valeur absente ?**

* Vérifiez l’orthographe du nom de variable
* Sous Windows, redémarrez le terminal après avoir défini les variables système

**Expiration de connexion ou erreur ?**

* Vérifiez que `GOOGLE_GEMINI_BASE_URL` ne se termine pas par un `/`
* Vérifiez la connexion réseau
* Vérifiez que la clé API est valide et non expirée

## Références officielles

[Référence de configuration Gemini CLI](https\://geminicli.com/docs/reference/configuration/), le paramètre `GOOGLE_GEMINI_BASE_URL` remplace l’adresse racine. Le SDK ajoute lui-même la version d’API et le chemin du modèle ; n’ajoutez donc pas `/v1`.