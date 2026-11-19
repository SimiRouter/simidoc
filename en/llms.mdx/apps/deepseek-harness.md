# DeepSeek Harness setup

DeepSeek Harness (`dsh`) is an open-source agent framework from DeepSeek AI. Add SimiRouter as a custom provider to use its models in Harness Web UI and headless tasks.

## Prerequisites

Before you begin, prepare\:

* A SimiRouter account and API key
* Node.js and `npx`
* A macOS, Linux, or Windows terminal
* A project directory for the agent to work in

## Install and start

Open the intended project directory and run\:

```bash
npx @deepseek-ai/dsh web
```

The default Web UI address is `http://127.0.0.1:3080`. The startup directory is only the default filesystem location; a fresh Web UI does not select a workspace automatically. Add that directory in the interface first, and the session input stays disabled until you do.

To change the port\:

```bash
npx @deepseek-ai/dsh web --port 8080
```

## Configure SimiRouter in the Web UI (recommended)

### 1. Open model settings

In the DeepSeek Harness Web UI, open **Settings → Models**.

![Open DeepSeek Harness model settings](/simidoc/assets/deepseek-harness/open-model-settings.png)

### 2. Add a custom provider

Select **Add a custom provider** and complete these fields\:

| Field        | Value                            |
| ------------ | -------------------------------- |
| Provider ID  | `simirouter`                     |
| Display name | `SimiRouter`                     |
| Base URL     | `https://api.dwchainless.com/v1` |
| API protocol | `openai-completions`             |
| API key      | Your SimiRouter API key          |

![SimiRouter custom provider form](/simidoc/assets/deepseek-harness/custom-provider-form.png)

<Callout type="warn" title="">
  Provider IDs are referenced by sessions, default models, and credentials and cannot simply be renamed after saving. Use lowercase `simirouter`.
</Callout>

### 3. Fetch models

Under **Model catalog**, select **Fetch available models**. Harness requests the model list using the current Base URL and key.

Select the models you need and save. If fetching fails, enter a model ID manually, such as `gpt-6-astra`. It must match the exact ID available to the current key’s group.

![Select models for the SimiRouter provider](/simidoc/assets/deepseek-harness/select-provider-models.png)

### 4. Select a model

After saving, find **SimiRouter** in the model picker beside the input and select a model. It becomes the default for new sessions; existing sessions that already sent requests retain their previous model.

![Select a SimiRouter model in DeepSeek Harness](/simidoc/assets/deepseek-harness/model-picker.png)

## Configure a Profile Patch

Advanced provider configuration for the Web Profile uses `$DSH_HOME/profiles/web/cordis.patch.yml` (by default `~/.dsh/profiles/web/cordis.patch.yml`). Back up the file and merge the plugin settings below without replacing existing plugins or providers\:

```yaml
- id: llm-pi-ai
  config:
    providers:
      simirouter:
        displayName: SimiRouter
        apiKeyEnv: SIMIROUTER_API_KEY
        api: openai-completions
        baseURL: https://api.dwchainless.com/v1
        models:
          - id: MODEL_ID
```

Replace `MODEL_ID` with the exact model ID and set `SIMIROUTER_API_KEY` in the environment that starts Harness. Select the SimiRouter model in the Web UI. This configuration applies to the Web Profile; other profiles do not automatically inherit it.

## Verify the setup

1. Open the Web UI\: `http://127.0.0.1:3080` by default, or the port you passed to `--port` when starting it.
2. Confirm the model picker contains **SimiRouter** and your saved models.
3. Create a session and send a short test message.
4. Check the request time, model, and usage in SimiRouter logs to verify this call.

## Headless mode

The Headless Profile disables the Web managed credential store by default. Do not assume keys saved in the UI apply automatically. Configure the same provider in the Headless Profile and pass the key through its startup environment. See [DeepSeek Harness headless credentials](https\://github.com/deepseek-ai/deepseek-harness/blob/master/packages/bundle/headless/README.md#credentials).

## Common Issues

### `MISSING_CREDENTIAL`

Harness cannot find `SIMIROUTER_API_KEY`. Open **Settings → Models** to save the key again, or set that environment variable in the terminal starting the process.

### `UNKNOWN_MODEL`

The model is not in the current Profile’s `simirouter` provider’s `models` list. Fetch models again or add the exact ID manually.

### 401 while fetching models or chatting

* Check that the key is complete, valid, and has no extra spaces.
* Confirm the Base URL is `https://api.dwchainless.com/v1`.
* Confirm the selected model is available to the current key’s group.

### Requests are not routed through SimiRouter

Ensure you added a **custom provider** with Provider ID `simirouter`. Built-in DeepSeek, OpenAI, and Anthropic providers continue to use their official endpoints.

### Changing the default model has no effect

Create a new session to test. Existing sessions retain their recorded model.

## Official reference

* [DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness)
* [DeepSeek Harness model configuration guide](https\://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/providers.zh.md)