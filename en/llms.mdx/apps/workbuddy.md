# WorkBuddy guide

<Callout type="info" title="Scope">
  This guide applies to WorkBuddy desktop versions with Configure custom models. Entry points and options may vary; follow the actual interface.
</Callout>

## Prerequisites

Before configuration, confirm\:

* WorkBuddy is installed and running with a Configure custom models entry.
* You have registered with SimiRouter and created a key on the console’s API keys page.
* You know the exact model ID, and the key has model access and available quota.

[Open API key management](https\://api.dwchainless.com/keys)

## Configuration Steps

### 1. Open Configure custom models

In WorkBuddy’s conversation view, click the model name at the lower right of the input, then select **Configure custom models**.

![Open Configure custom models from the model list](/simidoc/assets/workbuddy/open-custom-model.png)

On the model management page, click **Add model**. If that dialog is already open, continue to the next step.

### 2. Set the provider to Custom

In the Add model window, expand **Provider**, scroll down, and under Other select **Custom**.

![Select Custom under Other in the provider list](/simidoc/assets/workbuddy/select-custom-provider.png)

Confirm the Provider field displays **Custom**.

### 3. Enter endpoint, key, and model name

Enter the basic details below\:

| Configuration Item | Value                                             |
| ------------------ | ------------------------------------------------- |
| Provider           | Custom                                            |
| Endpoint address   | `https://api.dwchainless.com/v1/chat/completions` |
| API Key            | An API key created in SimiRouter                  |
| Model Name         | The exact model ID to call                        |

**Endpoint address\:** Copy the complete address above, retaining the final `/v1/chat/completions`.

\*\*API Key\: \*\* Paste only the key, without `Bearer`, quotes, or explanatory text, and remove surrounding spaces.

**Model name\:** Copy an exact ID from SimiRouter’s current model catalog, not a translated description, nickname, or partial family name. Confirm the key can call it.

### 4. Configure advanced options

For initial setup, retain default input/output settings. Configure other options only according to the model and channel capabilities.

| Configuration Item              | Recommended setting                                                                                         |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Tool calling                    | Enable for tool tasks only when both the model and channel support it.                                      |
| Image input                     | Enable when needed and supported by the selected model and channel.                                         |
| Thinking mode                   | Follow the model’s integration notes; it can remain disabled for initial setup.                             |
| Custom protocol                 | Leave disabled unless explicitly required.                                                                  |
| Reasoning effort (if available) | Keep the default initially; adjust only for a specific need.                                                |
| Input / output                  | Keep Use provider defaults initially. Verify model and channel length limits before changing them manually. |

![Custom model form\: endpoint, key, model name, and advanced options](/simidoc/assets/workbuddy/custom-model-form.png)

*The screenshot shows Chinese field labels. Enter your own key and actual model ID as described above.*

### 5. Test, save, and select the model

When complete, click **Test connection**, then click **Save**. If the test fails, use the troubleshooting section below.

Return to WorkBuddy’s conversation interface and open the model picker at the lower right. **Select the custom model you just added**, then send a short message, such as\:

```text
请只回复：连接成功。
```

After a normal reply, check the corresponding request time and model in SimiRouter logs.

Once basic chat works, test tools, images, and thinking separately as needed.

## Common Issues

Read the complete error message first, then use this table.

| Problem                                                        | Troubleshooting                                                                                              |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| Configure custom models is missing                             | Check client support and open the model picker at the lower right of the conversation input.                 |
| Connection test or message fails                               | Use the error to check endpoint, key, model ID, permissions, and quota individually.                         |
| Saved configuration, but conversations still use the old model | Return to the conversation and select the newly saved custom model.                                          |
| Failure after enabling images or thinking                      | Restore the last working settings, then confirm model and channel support for that feature.                  |
| Long conversations or outputs fail                             | Check model and channel length limits. Shorten the input or lower the output limit as directed by the error. |

For troubleshooting assistance, provide **WorkBuddy version, model ID, request time, and complete error message**.

<Callout type="warn" title="Key security">
  Keep keys private. Hide the complete key before sending screenshots, logs, or errors; never share it publicly.
</Callout>

## Official reference

[WorkBuddy custom model configuration](https\://www.codebuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Model).