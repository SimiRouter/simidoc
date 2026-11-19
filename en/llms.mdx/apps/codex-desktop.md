# Codex Desktop Setup

Codex Desktop supports API key sign-in and lets you open the user-level `config.toml` from the app. After completing the following setup, Codex sends requests through SimiRouter's Responses-compatible endpoint.

<Callout type="info" title="">
  The sign-in field is still labeled **OpenAI API key**. Enter your SimiRouter API key here, for example `sk-...`.
</Callout>

## Prerequisites

Before you begin, make sure you have\:

* The latest version of Codex Desktop
* A SimiRouter account
* An API key created in the SimiRouter console
* Access to the model you plan to configure

## Configuration Steps

### 1. Sign in with an API key

1. Open Codex Desktop.
2. Select **Sign in another way**.
3. Enter your SimiRouter API key in the **OpenAI API key** field.
4. Select **Continue** to enter the app.

![Enter an API key in Codex Desktop](/simidoc/assets/codex-desktop/codex-api-key-login.png)

### 2. Open the user-level configuration

1. Open the Codex settings page.
2. Select **Configuration**.
3. Under **Custom config.toml settings**, select **User config**.
4. Select **Open config.toml** to open the user-level configuration file.

![Open the user-level config.toml in Codex Desktop](/simidoc/assets/codex-desktop/codex-user-config.png)

### 3. Add the SimiRouter provider

Back up your existing `config.toml` first. Merge the model and provider fields below rather than overwriting the file. Preserve MCP, project-trust, approval, and sandbox settings; do not add duplicate TOML tables.

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

Save the file, completely quit Codex Desktop, and then reopen it.

<Callout type="info" title="">
  This example supplies the token directly with `requires_openai_auth = false` and `experimental_bearer_token`. Replace the placeholder with your SimiRouter API key. You do not also need `auth.json`, and this method does not rely on the key saved during sign-in. Because `config.toml` contains a plaintext secret, do not commit or share it. On Linux / macOS, restrict access with `chmod 600 ~/.codex/config.toml`; on Windows, restrict the file permissions. Preserve your approval, sandbox, and project-trust settings; connecting a provider does not require disabling safety confirmations.
</Callout>

## Verify the setup

After reopening Codex\:

1. Open a project or workspace.
2. Start with a low-risk task, such as asking Codex to explain a file.
3. Check the request time, model, and usage in SimiRouter logs. A display name or model self-description does not prove routing.

## Common Issues

### Invalid API key

* Copy the complete API key again from the SimiRouter console.
* Check for extra spaces before or after the key.
* Confirm the key starts with `sk-` and is still active.

### Configuration is not applied

* Confirm you edited the `config.toml` file opened through **User config**.
* Confirm `model_provider = "simirouter"` exactly matches `[model_providers.simirouter]`.
* Completely quit the app after saving instead of only closing the current window.

### Model or connection error

* Confirm `base_url` is `https://api.dwchainless.com/v1`.
* Confirm `wire_api` is `responses`.
* Confirm the API key's group can access `gpt-6-astra`; replace `model` with another available model name when needed.

For manual `auth.json` setup, model switching, or CLI usage, see [Codex CLI Configuration](/simidoc/en/apps/codex-config).

## Official reference

* [OpenAI Codex configuration reference](https\://developers.openai.com/codex/config-reference/)