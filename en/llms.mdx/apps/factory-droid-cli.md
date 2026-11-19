# Factory Droid CLI installation and configuration

Droid CLI supports custom models with your own key. Personal models are stored locally; this does not make Factory’s hosted web or mobile clients use the same model.

## Installation

macOS / Linux\:

```bash
curl -fsSL https://app.factory.ai/cli | sh
droid --version
```

Windows PowerShell\:

```powershell
irm https://app.factory.ai/cli/windows | iex
droid --version
```

These commands run official installation scripts. Verify their source and follow organizational policy. Do not disable security software or globally weaken execution policy. Complete account login if prompted after startup.

## Add a SimiRouter model

1. Start `droid`, run `/settings`, and open **Custom models**; alternatively, open `/model`, select **Manage custom models**.
2. Click **Add model** and select the generic Chat Completions provider.
3. Complete and save these fields\:

| Field        | Content                                      |
| ------------ | -------------------------------------------- |
| Provider     | `generic-chat-completion-api`                |
| Base URL     | `https://api.dwchainless.com/v1`             |
| API Key      | SimiRouter API Key                           |
| Model        | The exact model ID available to your account |
| Display name | For example, `SimiRouter`; display only      |

## Configuration file alternative

You can also edit `~/.factory/settings.json` and merge entries into its `customModels` array. Back up the file and preserve existing entries and settings.

```json
{
  "customModels": [
    {
      "model": "MODEL_ID",
      "displayName": "SimiRouter",
      "baseUrl": "https://api.dwchainless.com/v1",
      "apiKey": "${SIMIROUTER_API_KEY}",
      "provider": "generic-chat-completion-api"
    }
  ]
}
```

Replace `MODEL_ID` with the actual model ID and set `SIMIROUTER_API_KEY`. `${SIMIROUTER_API_KEY}` is a supported environment-variable reference. Do not replace it with a publicly visible real key.

Current configuration uses `settings.json` and camelCase fields. Entries in legacy `config.json` may be migrated on first startup. Edit `settings.json` afterward; do not run old third-party scripts that overwrite configuration.

## Verify

Under `/model`, select **Custom Models** and choose the SimiRouter model. Begin with a low-risk task such as explaining a file, then verify the actual model and usage in SimiRouter logs. Set output limits, image support, and tools according to the selected model rather than copying another model’s fixed values.

## Official reference

* [Factory Droid CLI quickstart](https\://docs.factory.com/droid-cli/quickstart)
* [Factory custom models (BYOK)](https\://docs.factory.com/model-independence/byok)