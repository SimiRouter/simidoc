# Настройка Claude CLI

Claude Code подключается к API-шлюзу через переменные окружения. Сначала задайте переменные, затем запустите `claude`.

## Linux / macOS

```bash
export ANTHROPIC_AUTH_TOKEN="PASTE_API_KEY_HERE"
export ANTHROPIC_BASE_URL="https://api.dwchainless.com"

# 可选：自定义默认模型映射（不配置也可正常使用）
export ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-6-astra"
export ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-terra"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-luna"
```

## Windows CMD

```cmd
set ANTHROPIC_AUTH_TOKEN=PASTE_API_KEY_HERE
set ANTHROPIC_BASE_URL=https://api.dwchainless.com

:: 可选：自定义默认模型映射（不配置也可正常使用）
set ANTHROPIC_DEFAULT_OPUS_MODEL=gpt-6-astra
set ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-5.6-terra
set ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-5.6-luna
```

## Windows PowerShell

```powershell
$env:ANTHROPIC_AUTH_TOKEN="PASTE_API_KEY_HERE"
$env:ANTHROPIC_BASE_URL="https://api.dwchainless.com"

# 可选：自定义默认模型映射（不配置也可正常使用）
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-6-astra"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.6-terra"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.6-luna"
```

## Проверка запуска

После настройки переменных окружения выполните в терминале\:

```bash
claude
```

После короткого сообщения проверьте соответствующие модель и запрос в журнале SimiRouter. Одного открытия окна диалога недостаточно для подтверждения подключения API.

## Официальные материалы

[Руководство подключения шлюза Claude Code](https\://code.claude.com/docs/en/llm-gateway) описывает подключение шлюза. `ANTHROPIC_BASE_URL` — корневой адрес; клиент добавляет `/v1/messages`; не добавляйте повторно `/v1`. Канал должен поддерживать заданное соответствие моделей.