# OpenClaw configuration

## Prerequisites

1. OpenClaw is installed and starts correctly.
2. An API key has been created in the SimiRouter console.
3. CC Switch is installed.

<Callout type="info" title="">
  If CC Switch is not installed, first read the [CC Switch Installation and Import Guide](/simidoc/en/apps/cc-switch).
</Callout>

## Configure OpenClaw in CC Switch

1. In CC Switch, select **OpenClaw** from the application sidebar; older versions use top tabs.

![Select OpenClaw in CC Switch’s top tabs](/simidoc/assets/cc/cc1.png)

2. Click **Add** to add a custom provider.

![Click add and fill provider parameters](/simidoc/assets/cc/cc2.png)

3. Save and enable the provider. Run `openclaw onboard` in a terminal and follow onboarding and pairing prompts.

![Enter TUI mode in terminal](/simidoc/assets/cc/cc4.png)

4. Send a short message, confirm a reply, and verify its request in SimiRouter logs. A settings screen or highlighted screenshot does not prove the model is connected.![Enter TUI mode in terminal](/simidoc/assets/cc/cc3.png)

## Common Issues

* `baseUrl` missing `/v1` is a common cause of missing model list.
* Model ID mismatch\: model name must match exactly the exposed model name.
* Still reporting authentication/unavailable\: confirm API Key matches the provider environment.
* For more detailed startup logs, run `openclaw gateway --port 18789` in the foreground.

## Official reference

[CC Switch official project](https\://github.com/farion1231/cc-switch).