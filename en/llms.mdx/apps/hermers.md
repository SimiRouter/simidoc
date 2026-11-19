# Hermes Configuration

## Prerequisites

1. Hermes is installed and runs normally.
2. An API key has been created in the SimiRouter console.
3. CC Switch is installed.

<Callout type="info" title="">
  If CC Switch is not installed, first read the [CC Switch Installation and Import Guide](/simidoc/en/apps/cc-switch).
</Callout>

## Configure Hermes in CC Switch

1. In CC Switch, select **Hermes** from the application sidebar; older versions use top tabs.

![Select the Hermes tab in CC Switch](/simidoc/assets/hermers/h1.png)

2. Click **Add** and add a custom provider. Return to the Hermes tab and enable it.

![Click add and fill provider parameters](/simidoc/assets/hermers/h2.png)

3. Open the terminal and run `hermes desktop` to launch the desktop app, then send a short test message. `--skip-build` is only for development installations with an existing desktop build, not first startup.

![Enter TUI mode in terminal](/simidoc/assets/hermers/h4.png)

4. Alternatively, run `hermes --tui` in a terminal to use TUI mode. Send a short message and check the matching request record in the SimiRouter console; opening the TUI alone does not confirm a working model connection.

![Enter TUI mode in terminal](/simidoc/assets/hermers/h5.png)

## Common Issues

* `baseUrl` missing `/v1` is a common cause of missing model list.
* Model ID mismatch\: model name must match exactly the exposed model name.
* Still reporting authentication/unavailable\: confirm API Key matches the provider environment.

## Official reference

[Hermes desktop CLI reference](https\://hermes-agent.nousresearch.com/docs/user-guide/desktop#cli-reference-hermes-desktop).