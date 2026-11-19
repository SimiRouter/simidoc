# Third-party plugin configuration (VS Code Roo)

Roo Code supports custom OpenAI-compatible providers. To use SimiRouter, configure its address, key, and model ID; no local model deployment is needed.

## Configure Roo Code

1. Install Roo Code and open extension settings.
2. Set **API Provider** to **OpenAI Compatible**.
3. Enter these values\:

| Field    | Content                                                               |
| -------- | --------------------------------------------------------------------- |
| Base URL | `https://api.dwchainless.com/v1`                                      |
| API Key  | A key created in SimiRouter [API key management](https://api.dwchainless.com/keys)               |
| Model ID | Copy the exact, case-sensitive model ID from [Model Square](https://api.dwchainless.com/en/pricing/) |

4. Set the context window, output limit, and image input according to actual model capabilities, not another model’s fixed values. Roo Code always uses native tool calling; there is no separate toggle.
5. Save, send a short message, and check SimiRouter [Usage Logs](https://api.dwchainless.com/usage-logs/common) to verify the call.

## Endpoint testing

Complete Python, Node.js, curl, and Go examples independent of the client are in [API Script Integration](/simidoc/en/apps/api-script). Use the same model ID and key permissions for the test and plugin. One successful text request does not verify tools or images.

## Common errors

* **401**\: check that the key is complete, valid, and has no extra spaces.
* **404**\: check whether the final URL duplicates `/v1` and verify the model ID.
* **Model unavailable**\: check model, group, and key permissions using the error body.
* **Unsupported parameter**\: disable parameters not applicable to the model, especially sampling, reasoning effort, and output length.

Keep the plugin’s default tool approval settings. Do not permit automatic execution in untrusted projects or publish settings screenshots containing keys.

## Official reference

[Roo Code\: OpenAI Compatible providers](https\://roocodeinc.github.io/Roo-Code/providers/openai-compatible/).