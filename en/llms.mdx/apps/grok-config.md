# Grok CLI configuration

Grok CLI configures model catalog and inference addresses separately. `[endpoints].models_base_url` is both the catalog source and the default inference base; a model’s `base_url` can override it. If you set only one of them, the other may still point at the official address, so verify both.

Configuration file locations\:

* **Linux / macOS**\: `~/.grok/config.toml`
* **Windows**\: `%USERPROFILE%\.grok\config.toml`

## Install / update

Linux / macOS\:

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
grok update
grok --version
```

Windows (PowerShell)\:

```powershell
irm https://x.ai/cli/install.ps1 | iex
```

If you installed through WinGet, update with `winget upgrade` instead of relying on `grok update`.

<Callout type="warn" title="XAI_API_KEY is required at startup">
  During startup Grok CLI fetches the model list using only the `XAI_API_KEY` environment variable; if it is unset the fetch fails, regardless of any `api_key` in the config file. When using SimiRouter, write the same key into the environment variable\:

  ```bash
  export XAI_API_KEY="PASTE_API_KEY_HERE"
  ```

  Never put the key in a file committed to Git. For long-term use, store it in an environment file with `600` permissions and `source` it.
</Callout>

## Write the configuration

Write the following to `~/.grok/config.toml` and replace `api_key` with your API key\:

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

The UI example uses a 120-character thought width, disables compact mode, and automatically approves tool calls.

<Callout type="warn" title="">
  The example disables `yolo` and comments out `permission_mode = "always-approve"`. Enabling them lets Grok modify files and execute commands without confirmation; **use them only in trusted projects and environments**.
</Callout>

<Callout type="info" title="">
  `api_key` must contain a SimiRouter key from this service, not a grok.com OAuth `refresh_token`. Inline keys are plaintext. On Linux or macOS, run `chmod 600 ~/.grok/config.toml`. On shared machines, prefer the officially supported `env_key` method.
</Callout>

## Verify the setup

```bash
grok inspect
grok models
grok --model grok-4.5 --output-format json -p '只输出 YAI_GROK_OK'
```

## Official reference

* [xAI Grok CLI\: custom models](https\://docs.x.ai/build/overview)
* [xAI Grok CLI\: configuration reference](https\://docs.x.ai/build/settings)