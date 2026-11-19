# Create a SimiRouter key

This guide covers registration, login, key creation, and the first call. Existing users can sign in directly; client operations and API parameters are documented separately.

## 1. Register or sign in to SimiRouter

Visit the [registration page](https://api.dwchainless.com/sign-up) to create an account; existing users can [sign in](https://api.dwchainless.com/sign-in). Available registration methods and whether registration is open depend on the current page.

Sign in and open [Wallet](https://api.dwchainless.com/wallet) and confirm sufficient quota and model access for the account group and key. To recharge or redeem a code, follow the prompts on the wallet page; plans, credited quota, and validity are shown there. Do not pay twice.

## 2. Create an API key

Open [API key management](https://api.dwchainless.com/keys) and choose Create key. Set group, model permissions, quota, and expiration as needed. Read unclear options before saving and copying the key.

![API key management and creation entry](/simidoc/assets/start/start5.png)

<Callout type="warn" title="Protect your key">
  An API key grants calling permissions. Keep it out of public repositories, screenshots, and logs, and do not give it to untrusted applications. Revoke and replace it immediately if compromised.
</Callout>

## 3. Understand the three connection values

| Value                  | Purpose                 | Notes                                                                                                            |
| ---------------------- | ----------------------- | ---------------------------------------------------------------------------------------------------------------- |
| API address / Base URL | Where requests are sent | Follow the client guide; some clients require `/v1`, while others need the root. Do not duplicate path segments. |
| API Key                | Authenticate requests   | Use the newly created key, not your login password.                                                              |
| Model Name             | Select the model        | Copy the exact model ID from [Model Square](https://api.dwchainless.com/en/pricing/). Its name, group, and permissions must match.              |

The endpoint address, key, and model ID are separate fields. Never place the key in the URL.

## 4. Choose your client

* [Codex desktop](/simidoc/en/apps/codex-desktop)\: desktop coding workflow.
* [Codex CLI](/simidoc/en/apps/installation/codex-cli)\: command-line installation and connection.
* [Claude Code](/simidoc/en/apps/installation/claude-code)\: installation, environment setup, and usage.
* [WorkBuddy](/simidoc/en/apps/workbuddy)\: custom desktop model setup.
* [API scripts](/simidoc/en/apps/api-script)\: integrate your own application using request examples.

Clients use different fields and protocols. Follow each guide rather than copying one client’s configuration into another.

## 5. Run a small test and check records

After saving, send a short request. Open [Usage Logs](https://api.dwchainless.com/usage-logs/common) to check the time, actual channel, model, status, and consumption. Super administrators can view global logs; administrators can view their own request, recharge, management-operation, and error logs; regular users can view their own request, recharge, and management-operation logs, but not error logs. For trends, see [Dashboard](https://api.dwchainless.com/dashboard).

A reply only proves that this request returned a result, not its actual route. On failure, check the address, key, exact model ID, and group permissions, then use the error and request ID. Give support redacted information, never the key.