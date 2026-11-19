# Claude Desktop Setup

Use CC Switch **model mappings** to choose a menu name in Claude Desktop while CC Switch routes the request to the corresponding SimiRouter model. The steps use macOS; labels may differ by system or version.

## Prerequisites

1. Install and open a recent Claude Desktop release.
2. Install a version of [CC Switch](https\://github.com/farion1231/cc-switch/releases/latest) that supports **Claude Desktop**, then open CC Switch.
3. Sign in to SimiRouter and open [API key management](https://api.dwchainless.com/keys) page to create or copy a valid API key. Confirm access to the intended model.

<Callout type="info" title="">
  API keys grant access. Keep them private and out of public screenshots. Model IDs and permissions are determined by the SimiRouter console.
</Callout>

## Configure model mappings through CC Switch

### 1. Add a custom Claude Desktop provider

In CC Switch, select **Claude Desktop**, click **Add provider**, then choose **Custom configuration**. Select Claude Desktop, not Claude Code.

![Add a custom Claude Desktop provider in CC Switch](/simidoc/assets/claude-desktop/cc-switch-add-provider.png)

### 2. Enter connection details and model mappings

Complete the custom configuration\:

| Field           | Value                                                          |
| --------------- | -------------------------------------------------------------- |
| Name            | `SimiRouter`, or a name of your choice                         |
| API Key         | The SimiRouter API key you copied                              |
| Request address | `https://api.dwchainless.com`, without a trailing `/` or `/v1` |
| Connection mode | Select **model mappings**                                      |
| Upstream format | Select **Anthropic Messages (native)**                         |

Under **model mappings**, enter a “Menu display name” and “Actual request model” for each required role. For example\:

| Model role | Menu display name   | Actual request model |
| ---------- | ------------------- | -------------------- |
| Sonnet     | `claude-sonnet-5-5` | `gpt-6-astra`        |
| Opus       | `claude-opus-5-5`   | `gpt-6-astra`        |
| Haiku      | `claude-haiku-5-5`  | `gpt-6.1-sol`        |

**The menu name is only a Claude Desktop label; the actual model is specified in the right-hand column.** For example, selecting the option labeled `claude-sonnet-5-5` sends a request to `gpt-6-astra` in this example, not Claude Sonnet. Replace the actual model with an exact SimiRouter ID your account can access. Display names may be descriptive. The available role list varies by version.

The screenshot’s `1M` option only declares context capability to the client. **Do not copy its checked state blindly**; select it only when both the model and endpoint support it. When finished, click **Add**.

![Model mapping columns in CC Switch\: menu name and actual model](/simidoc/assets/claude-desktop/cc-switch-model-mapping.png)

The screenshot hides the API key; enter your own key when configuring.

### 3. Test and enable routing

1. Return to the provider list and click **… → Test connectivity** on the SimiRouter card to inspect the result.
2. After a successful test, click the enable button (▶) on the SimiRouter card and follow the prompts. A card showing **Routing** means that provider is selected.
3. Keep CC Switch and its local router running. After changing a route or model mapping, fully quit and reopen Claude Desktop to reload configuration.

![Choose Test connectivity in the provider menu](/simidoc/assets/claude-desktop/cc-switch-test-connection.png)

![SimiRouter provider showing Routing](/simidoc/assets/claude-desktop/cc-switch-routing.png)

### 4. Enable developer mode in Claude Desktop

Open **Claude Desktop application** and choose **Help → Troubleshooting → Enable Developer Mode** in the top menu. Skip this if already enabled.

![Enable developer mode from Claude Desktop’s Help menu](/simidoc/assets/claude-desktop/claude-enable-developer-mode.png)

### 5. Check the CC Switch inference configuration

1. Open the account menu at the lower left of Claude Desktop, select **Inference configuration**, and open **Configure third-party inference**.
2. Check the configuration list at the upper right and select **CC Switch**. If multiple profiles exist, choose CC Switch. A status of **applied** means it is applied; apply any pending changes with **Apply Changes**.
3. On the **Connection** page, click **Test Connection**. Close settings after the green success message.

![Open Inference configuration from the account menu](/simidoc/assets/claude-desktop/claude-inference-menu.png)

![CC Switch selected and applied as the third-party inference profile](/simidoc/assets/claude-desktop/claude-cc-switch-profile.png)

The gateway key is hidden in the screenshot. Keep the automatically configured CC Switch value; do not clear it.

<Callout type="info" title="">
  The gateway address in CC Switch points to the local router, unlike the SimiRouter request address in step 2. Usually neither the local gateway address nor its key needs manual editing. A successful connection check does not replace an actual model call.
</Callout>

### 6. Select a model and verify

1. Create a conversation and select the configured **Menu display name** in the model menu beside the input. Send a short message; real calls may incur charges.
2. After receiving a reply, check the request time, **actual model**, and usage in SimiRouter logs. A model’s self-description and Claude Desktop’s display name do not prove which model handled the request.

## Common Issues

### Claude Desktop or developer mode is missing

* Use a recent CC Switch version supporting Claude Desktop and select **Claude Desktop**.
* In Claude Desktop, open **Help → Troubleshooting** and enable **Enable Developer Mode**; update the client if the entry is missing.

### CC Switch profile is missing or models have not updated

* Confirm the SimiRouter card shows **Routing** and keep CC Switch and its local router running.
* Fully quit and reopen Claude Desktop, then inspect **Inference configuration** at the lower left. Some versions also provide **Developer → Configure third-party inference** to open the page.
* Ensure the mapping includes a menu display name and that the **CC Switch** profile is selected. Restart Claude Desktop after mapping or provider changes.

### Connection test or conversation fails

* Check that the CC Switch key is complete and valid and that the request address is `https://api.dwchainless.com`.
* Ensure **Anthropic Messages (native)** is selected as the upstream format; check network and local router status.
* Check the actual request model ID, key group, and model permissions, not just its menu label.
* Use the error message to check quota and model compatibility. A successful connectivity test does not verify every model or feature.

## Other configuration methods

### Optional\: original direct configuration

The original direct-connection steps are retained but have not been reverified in the current client. Fields and UI may differ. Do not repeat them after using CC Switch above; direct model availability depends on client support.

First enable developer mode in **Help → Troubleshooting**, then\:

1. From the top menu, select **Developer → Configure third-party inference**.
2. Fill in the fields as follows\:

| Field                 | Value                                                                                            |
| --------------------- | ------------------------------------------------------------------------------------------------ |
| Base URL              | `https://api.dwchainless.com`                                                                    |
| API Key               | Your SimiRouter API key, for example `sk-...`                                                    |
| Authentication method | Select `x-api-key`                                                                               |
| Provider / API format | If this field is available, select `Anthropic-compatible`, `custom gateway`, or a similar option |

<Callout type="warn" title="">
  For Claude Desktop, enter `https://api.dwchainless.com` as the Base URL. Do not copy the `ANTHROPIC_BASE_URL` environment-variable format from the Claude CLI guide into this field.
</Callout>

3. Select **Apply locally** to save the configuration on this computer.
4. Continue with the Claude Desktop sign-in or startup flow.

## Official reference

* [CC Switch\: Claude Desktop configuration](https\://github.com/farion1231/cc-switch-website/blob/main/public/docs/en/2-providers/2.6-claude-desktop.md)
* [Anthropic Docs\: Configure Claude Cowork with third-party platforms](https\://claude.com/docs/third-party/claude-desktop/overview)