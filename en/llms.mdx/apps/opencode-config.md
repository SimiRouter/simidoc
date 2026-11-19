# OpenCode CLI configuration

OpenCode uses a global configuration file\:

* **Linux / macOS**\: `~/.config/opencode/opencode.jsonc`
* **Windows**\: `%USERPROFILE%\.config\opencode\opencode.jsonc`

First place the key in the configuration’s `apiKey`, then run verification commands. This example does not reference environment variables, so no additional environment variable is needed. Protect key-bearing files and retain OpenCode’s default approval settings.

## Configuration file (V1-compatible format)

Write the following to the configuration file and replace `apiKey` with your API key\:

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

## Verify the setup

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
  `opencode debug config` verifies that configuration loaded; `opencode run "你好"` tests a model response.
</Callout>

## Official reference

[OpenCode configuration documentation](https\://opencode.ai/docs/config/) covers locations and the current format. This guide retains compatible V1 syntax. Follow the version’s migration guide when upgrading instead of replacing the whole configuration.