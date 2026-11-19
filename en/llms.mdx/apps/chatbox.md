# Chatbox AI configuration

This guide uses the Chatbox AI 1.21.1 desktop interface and its built-in **OpenAI** model provider. Labels and locations may differ in other versions; the screenshots show the Chinese interface.

<Callout type="warn" title="Protect your API key">
  An API key grants access. Never share it or expose it in public screenshots. Connection checks and conversations may incur charges; confirm quota and model prices first.
</Callout>

## Prerequisites

1. Visit the [Chatbox AI official website](https\://chatboxai.app/) to download and install the client.
2. Sign in to SimiRouter and open [API key management](https://api.dwchainless.com/keys) to create or copy a key. Confirm that the key can access the intended model and has sufficient quota.

![SimiRouter API key management with key details hidden](/simidoc/assets/chatbox/03a-create-api-key.png)

## Configure the connection

### 1. Open settings and select a provider

In the Chatbox main window, click **Settings** at the lower left.

![Open Chatbox settings](/simidoc/assets/chatbox/01-open-settings.png)

Open **Model providers**, and select **OpenAI**. This guide uses an API key rather than OAuth. This changes the OpenAI provider configuration; record any existing connection first to avoid overwriting it.

![Select OpenAI under model providers](/simidoc/assets/chatbox/02-select-openai.png)

### 2. Enter the API key and host

| Configuration Item      | Value                                             |
| ----------------------- | ------------------------------------------------- |
| API key                 | Paste the SimiRouter key you copied               |
| API host                | `https://api.dwchainless.com`                     |
| Request address preview | `https://api.dwchainless.com/v1/chat/completions` |

Use the host above and retain the default API path. Do not append the endpoint to the host. If you previously customized the path, restore the default and check the preview.

![Enter the API key and host for the OpenAI provider](/simidoc/assets/chatbox/03b-fill-api-fields.png)

### 3. Fetch and add models

In the model section, click **Fetch**, search, and click **+** beside a model to add it. If fetching fails, use **New** to enter an exact model ID available to your account. Listed models may not all be available to this key; check account permissions.

![Search for and add a model](/simidoc/assets/chatbox/04-add-models.png)

### 4. Check the connection and start chatting

For the intended model, click **Check**. Even after “Connection successful”, send a short message to verify a real conversation. Some models support only text; a failed image or tool check does not necessarily mean text is unavailable.

![Connection check results for an example model](/simidoc/assets/chatbox/05-check-success.png)

Close settings, click **New chat**, select the added model under the OpenAI group beside the input, and send a short message. Check the request and actual model in SimiRouter usage logs.

![Create a conversation and select the added model](/simidoc/assets/chatbox/06-new-chat-select-model.png)

## Common Issues

* **Cannot fetch models\:** Check the network, host, and key, or add an exact model ID manually.
* **401 or authentication failure\:** Check that the key is complete, valid, and free of surrounding spaces; recreate it if needed.
* **404 or path error\:** Check the request preview and restore the default path to avoid duplicated segments.
* **Model missing or conversation unavailable\:** Check the model ID, key permissions, account quota, and selected model.
* **Images or tool calls fail\:** Check model and endpoint support. Test text separately if that is all you need.

Reference\: [Chatbox OpenAI address and path handling](https\://github.com/chatboxai/chatbox/blob/main/src/shared/utils/llm_utils.ts).