# AstrBot configuration

AstrBot is an open-source AI assistant for multiple messaging platforms. This guide connects it to SimiRouter using an OpenAI-compatible protocol.

## Add a provider

1. Install and start AstrBot; installation instructions are in the [AstrBot official documentation](https\://docs.astrbot.app/).
2. In SimiRouter, open [API key management](https://api.dwchainless.com/keys) to create a key.
3. Open the AstrBot admin panel at **Providers → Chat Completion**, click **Add**, and select **OpenAI Compatible**. Older versions may show “Model providers → Add → OpenAI”.
4. Complete these fields and save\:

| Field         | Content                                                                         |
| ------------- | ------------------------------------------------------------------------------- |
| Provider name | `SimiRouter`                                                                    |
| API Base URL  | `https://api.dwchainless.com/v1`                                                |
| API Key       | SimiRouter API Key                                                              |
| Model         | Copy from [Model Square](https://api.dwchainless.com/en/pricing/) the exact model ID available to your account |

Click **Save and Fetch Models** to fetch models. Click `+` beside a model to add and enable it. Alternatively, use **Custom Model** to enter the exact ID manually.

## Set the default chat model

Open **Config → AI → Model**, set **Chat Model** to the model you added, and save. Use **Test Model** or send a short message, then check SimiRouter [Usage Logs](https://api.dwchainless.com/usage-logs/common) to verify the call.

Image understanding and tool calling require support in AstrBot, the selected model, and the channel. A successful text conversation does not verify every extension.

## Official reference

* [AstrBot model provider configuration](https\://docs.astrbot.app/en/providers/llm.html)
* [Connecting AstrBot to model services](https\://docs.astrbot.app/en/providers/start.html)