# Memoh configuration

Memoh is an open-source multi-agent platform with isolated workspaces and long-term memory. Chat, speech, and transcription models use different client types and cannot share one protocol configuration.

## Install Memoh

Follow the [Memoh official deployment guide](https\://docs.memoh.ai/self-hosted/docker) to install the current release. Complete account security setup after first login; do not reuse default passwords from older guides.

## Add a provider

1. In SimiRouter, open [API key management](https://api.dwchainless.com/keys) to create a key.
2. In Memoh’s settings sidebar, open the **Models** page and select **Add Provider**.
3. Use an OpenAI Chat Completions template or create a custom provider\:

| Field       | Content                          |
| ----------- | -------------------------------- |
| Name        | `SimiRouter`                     |
| Client Type | `openai-completions`             |
| Base URL    | `https://api.dwchainless.com/v1` |
| API Key     | SimiRouter API Key               |

`openai-responses` uses the Responses protocol; `openai-completions` uses Chat Completions, not legacy text completion despite the name. OAuth login types do not replace a SimiRouter API key provider.

## Add and enable models

In provider details, click **Import Models** to import models or enter available IDs manually. Bulk-imported models may start disabled; enable them before selecting one in bot settings.

Send a short message and open SimiRouter [Usage Logs](https://api.dwchainless.com/usage-logs/common) to verify the request. Memory and search may need additional providers. SimiRouter does not currently offer embeddings; a chat model cannot replace a vector model.

## Official reference

* [Memoh providers and models](https\://docs.memoh.ai/integrations/providers/llm)
* [Memoh project](https\://github.com/felinics/Memoh)