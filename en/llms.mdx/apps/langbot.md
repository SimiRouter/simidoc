# LangBot configuration

LangBot stores connection details in a provider, which individual models reference. An OpenAI-compatible provider can connect SimiRouter chat models.

## Create a provider and model

1. Follow the [LangBot official documentation](https\://docs.langbot.app/) to install and start the application.
2. Open SimiRouter [API key management](https://api.dwchainless.com/keys) to copy the key.
3. Add a chat model on LangBot’s model page. Select an OpenAI-compatible provider or create one.
4. Configure the connection\:

| Field                  | Content                                      |
| ---------------------- | -------------------------------------------- |
| Base URL / Request URL | `https://api.dwchainless.com/v1`             |
| API Key                | SimiRouter API Key                           |
| Model Name             | The exact model ID available to your account |

Models inherit their provider’s address and key. Enable vision and tools only if the actual model supports them; toggles do not add missing capabilities.

## Bind a pipeline

Select the added model in a pipeline and save. Use debugging or a connected bot to send a message, then open SimiRouter [Usage Logs](https://api.dwchainless.com/usage-logs/common) to check request time, model, and consumption.

## Knowledge bases and embeddings (unsupported)

LangBot knowledge bases require an embedding model. SimiRouter does not currently support embedding integration; chat model configuration is not a vector service. Configure another embedding provider supported by LangBot or use an officially documented built-in option.

## Official reference

[LangBot model configuration](https\://docs.langbot.app/zh/usage/models/readme) explains relationships between providers, chat models, embedding models, and pipelines.