# Install Codex CLI

## macOS / Linux

OpenAI provides a standalone installer\:

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex --version
```

The command downloads and executes an official script. Managed environments should review it or use an approved package manager method from the official documentation.

## Windows

Windows users may install natively or use Linux tools inside WSL. For installation and sandbox support, see [OpenAI Windows documentation](https\://learn.chatgpt.com/docs/windows/windows-sandbox).

For npm installation, first configure a compatible Node.js version, then run\:

```powershell
npm install -g @openai/codex
codex --version
```

WSL users must install and configure Codex inside WSL. Do not confuse Windows configuration under `%USERPROFILE%` with Linux `~/.codex`. Do not disable security software or enable administrator access unconditionally.

## Configure and verify

1. Follow [Codex CLI Configuration](/simidoc/en/apps/codex-config) to merge the provider and model fields into `config.toml` after backing up the original file.
2. Open a project directory and run `codex`.
3. Keep default approval and sandbox settings. Ask Codex to explain a file, then verify the request in SimiRouter logs.

`codex --version` verifies the executable, not endpoint connectivity. Do not replace the entire `~/.codex` directory, which contains history, sessions, and other settings.

## Official reference

* [OpenAI Codex CLI](https\://learn.chatgpt.com/docs/codex/cli)
* [OpenAI Windows sandbox documentation](https\://learn.chatgpt.com/docs/windows/windows-sandbox)