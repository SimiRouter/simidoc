# Gemini CLI configuration

Set environment variables to point Gemini CLI to SimiRouter.

## macOS / Linux

**Temporary (current terminal session)\:**

```bash
export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
export GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**Persistent (append to shell configuration)\:**

```bash
install -d -m 700 ~/.config
umask 077
printf '%s\n' \
  'export GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"' \
  'export GEMINI_API_KEY="PASTE_API_KEY_HERE"' > ~/.config/simiroouter.env
chmod 600 ~/.config/simiroouter.env
# Add this line to ~/.zshrc or ~/.bashrc: source ~/.config/simiroouter.env
source ~/.config/simiroouter.env
```

<Callout type="info" title="">
  The key is stored with `600` permissions in `~/.config/simiroouter.env` instead of a shell profile that runs on every login. Add `source ~/.config/simiroouter.env` to `~/.bashrc` or `~/.zshrc` to make it persistent, and keep the file unreadable to other users on shared machines.
</Callout>

## Windows PowerShell

**Temporary\:**

```powershell
$env:GOOGLE_GEMINI_BASE_URL="https://api.dwchainless.com"
$env:GEMINI_API_KEY="PASTE_API_KEY_HERE"
```

**Persistent (append to the PowerShell profile)\:**

```powershell
Add-Content $PROFILE 'Set-Item -Path Env:GOOGLE_GEMINI_BASE_URL -Value "https://api.dwchainless.com"'
Add-Content $PROFILE 'Set-Item -Path Env:GEMINI_API_KEY -Value "PASTE_API_KEY_HERE"'
```

## Windows CMD

**Temporary\:**

```cmd
set GOOGLE_GEMINI_BASE_URL=https://api.dwchainless.com
set GEMINI_API_KEY=PASTE_API_KEY_HERE
```

**Persistent (current user)\:**

1. Press `Win + R`, enter `sysdm.cpl`, and press Enter
2. Click Advanced → Environment Variables
3. Under User variables, click New and add `GOOGLE_GEMINI_BASE_URL` and `GEMINI_API_KEY`
4. Restart the terminal for the variables to take effect

## Verify Startup

```bash
gemini
```

Select API key authentication and send a short message, then verify the call in SimiRouter logs. Opening the client does not prove the endpoint is connected.

## Common Issues

**Is `GEMINI_API_KEY` missing?**

* Check the variable name spelling
* On Windows, restart the terminal after setting environment variables

**Connection timeout or error?**

* Confirm `GOOGLE_GEMINI_BASE_URL` has no extra trailing `/`
* Check network connectivity
* Confirm the key is valid and has not expired

## Official reference

[Gemini CLI configuration reference](https\://geminicli.com/docs/reference/configuration/) documents `GOOGLE_GEMINI_BASE_URL` as the service root override. The SDK appends its own API version and model path, so do not append `/v1`.