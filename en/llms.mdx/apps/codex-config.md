# Codex CLI Configuration

This example supplies an API key directly through `config.toml`. The script handles the user-level `config.toml` and local `models.json`; it does not create or modify `auth.json`.

The script uses two URLs and one API key\:

* **Inference Base URL**\: `https://api.dwchainless.com/v1`, written to `model_providers.simirouter.base_url` for Codex requests.
* **Model catalog URL**\: `https://api.dwchainless.com/v1/models`. The script uses the same API key as a Bearer token, converts the OpenAI-style model list to local `~/.codex/models.json`, and sets `model_catalog_json`. This is not a second inference endpoint.
* **API key**\: the same SimiRouter key is used for both URLs. The script sends it only as a Bearer credential to these two fixed URLs and does not write it to the docs or other locations.

The catalog endpoint requires a valid key. Available models and basic metadata such as context length come from the response; the conversion does not invent unconfirmed tools or reasoning capabilities.

* **Linux / macOS**\: `~/.codex/config.toml`
* **Windows**\: `%USERPROFILE%\.codex\config.toml`

## Option 1\: automatic configuration script (optional; review before running)

The repository includes Bash and PowerShell scripts. Install and launch Codex CLI or the desktop app first; download and review the script before running the local file.

* [Download the Bash script](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [Download the PowerShell script](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)

Run in a macOS or Linux terminal\:

<Callout type="warn" title="">
  These steps download a script from the docs site but do not pipe the network response directly to an interpreter. Review the saved file before running it. If the published file is unavailable, use the matching file in the repository's `public/scripts/` directory or use manual configuration below.
  The script writes the API key to `experimental_bearer_token` in `config.toml`; it does not create or modify `auth.json`. Treat this file as a plaintext secret.
</Callout>

```bash
# Download the script from the public script link above, then review it.
less ./codex-simirouter-setup.sh
bash ./codex-simirouter-setup.sh
```

Run in Windows PowerShell\:

```powershell
# Download the script from the public script link above, then review it.
$script = Join-Path (Get-Location) 'codex-simirouter-setup.ps1'
Get-Content -LiteralPath $script
& powershell -File $script
```

<Callout type="info" title="">
  PowerShell 5.1 and PowerShell 7 both save the file before execution, so you can inspect it before entering an API key. With PowerShell 7, replace `powershell` in the last line with `pwsh`.
</Callout>

Follow the menu to select a model. The first run asks for an API key beginning with `sk-`, obtained from the SimiRouter console.

The script describes these operations (the Bash version requires Python 3.11 or newer)\:

* **Back up existing configuration**\: save a snapshot of `config.toml` under `~/.codex/backup-simirouter/`; restore requires explicitly typing `RESTORE`.
* **Sync the model catalog**\: request the catalog URL with the same API key, convert model IDs and basic metadata to `~/.codex/models.json`, and set `model_catalog_json` to that file.
* **Modify `config.toml`**\: update top-level `model_provider`, `model`, and `model_catalog_json`, and maintain `[model_providers.simirouter]` fields `base_url`, `wire_api`, and `experimental_bearer_token` while preserving other content where possible.
* **Protect files**\: the scripts attempt to restrict the directory and configuration files to the current user. A warning is shown if the platform cannot apply the restriction.
* **Validation**\: the Bash script uses Python 3.11+ to parse TOML and the catalog JSON before replacing files. The scripts do not validate or modify `auth.json`, and do not claim that a real inference call succeeded.

<Callout type="info" title="">
  Run the script again to switch models or choose Restore defaults to restore the pre-installation backup.
</Callout>

## Option 2\: manual Linux / macOS configuration (alternative)

Back up existing `config.toml` and `auth.json` separately. Do not move or recreate the entire `~/.codex` directory, which contains history, sessions, and other settings. Merge only provider and model fields, avoid duplicate TOML tables, and preserve MCP, approval, sandbox, and trust settings.

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

The `model_catalog_json` value points to the local catalog generated from `https://api.dwchainless.com/v1/models`. For manual setup, request that URL with the same API key and save the response in Codex `models.json` format; do not use the OpenAI `data` list directly as a Codex catalog.

This file contains a plaintext token. Do not commit or share it. Restrict access after saving on Linux or macOS\:

```bash
chmod 600 ~/.codex/config.toml
```

### `auth.json` (only when required by another authentication method)

The configuration token above is sufficient; do not also create or overwrite `auth.json`. The JSON below is only for other authentication methods that need that file. Choose one method supported by your Codex version rather than combining methods to hide errors.

```json
{
  "OPENAI_API_KEY": "PASTE_API_KEY_HERE"
}
```

## Windows configuration

### PowerShell

Create the directory and open the configuration file\:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex" | Out-Null
notepad "$env:USERPROFILE\.codex\config.toml"
```

### CMD

```cmd
if not exist "%USERPROFILE%\.codex" mkdir "%USERPROFILE%\.codex"
notepad "%USERPROFILE%\.codex\config.toml"
```

After backing up existing settings, merge the TOML provider and model fields into `config.toml` and save. Do not overwrite unrelated settings. The example uses a configuration token and does not require creating or replacing `auth.json`. On Windows, restrict key-bearing files to the current user.

## Verify Startup

```bash
codex
```

<Callout type="warn" title="">
  On Windows, `config.toml` and `auth.json` are located at `%USERPROFILE%\.codex\`. Save the file in the correct location.
</Callout>