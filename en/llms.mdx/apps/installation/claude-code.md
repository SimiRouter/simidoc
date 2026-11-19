# Install Claude Code CLI

Claude Code supports macOS, Linux, native Windows, and WSL. Its native installer does not require Node.js; npm installation requires an appropriate Node.js version.

## macOS / Linux / WSL

Run the official command in Bash or Zsh\:

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
```

This downloads and executes an official script. Review it or use an organization-approved installation method in managed environments. Do not run it with `sudo`.

## Windows PowerShell

```powershell
irm https://claude.ai/install.ps1 | iex
claude --version
```

Administrator privileges are not required. Git for Windows is optional on native Windows and needed for Bash tools. WSL users should use the Linux command inside WSL, not configure the Linux client from PowerShell.

## Configure and launch

1. Follow [Claude CLI Configuration](/simidoc/en/apps/claude-config) to set the SimiRouter address and key.
2. Open the intended project directory and run `claude`.
3. Keep permission prompts. Start with a low-risk request such as explaining a file, then verify SimiRouter usage logs.

`claude --version` only verifies installation, not model connectivity. Do not disable antivirus or weaken system security to work around installation issues.

## Official reference

[Anthropic\: Claude Code installation and system requirements](https\://code.claude.com/docs/en/setup).