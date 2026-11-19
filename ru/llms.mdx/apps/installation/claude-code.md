# Установка Claude Code CLI

Claude Code работает в macOS, Linux, Windows и WSL. Собственный установщик не требует Node.js; совместимая Node.js нужна только для npm.

## macOS / Linux / WSL

В Bash или Zsh выполните официальную команду\:

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
```

Команда скачивает и выполняет официальный скрипт. В управляемом окружении проверьте скрипт или используйте утвержденный установщик; не запускайте от `sudo`.

## Windows PowerShell

```powershell
irm https://claude.ai/install.ps1 | iex
claude --version
```

Установка не требует администратора. Git for Windows необязателен и нужен для инструмента Bash. В WSL используйте Linux-команды внутри WSL, а не настраивайте Linux-клиент в PowerShell.

## Настройка и запуск

1. По инструкции [настройки Claude CLI](/simidoc/ru/apps/claude-config) задайте адрес и ключ SimiRouter.
2. Перейдите в каталог проекта и выполните `claude`.
3. Сохраните подтверждения действий. Начните с объяснения файла и проверьте журнал SimiRouter.

`claude --version` проверяет лишь установку команды, а не подключение модели. Не отключайте антивирус и глобальную защиту из-за проблем установки.

## Официальные материалы

[Anthropic\: установка и требования Claude Code](https\://code.claude.com/docs/en/setup).