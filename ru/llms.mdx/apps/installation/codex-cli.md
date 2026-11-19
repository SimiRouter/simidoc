# Установка Codex CLI

## macOS / Linux

OpenAI предлагает отдельный установщик\:

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex --version
```

Команда скачивает и выполняет официальный скрипт. В управляемом окружении сначала изучите его либо используйте утвержденный пакетный менеджер из официальной инструкции.

## Windows

Windows поддерживает собственный терминал или Linux-инструменты WSL. Установка и песочница описаны в [документации OpenAI для Windows](https\://learn.chatgpt.com/docs/windows/windows-sandbox).

Для npm сначала установите совместимую Node.js по официальной инструкции, затем выполните\:

```powershell
npm install -g @openai/codex
codex --version
```

В WSL устанавливайте и настраивайте Codex внутри WSL\: нельзя смешивать Windows-конфигурацию в `%USERPROFILE%` с Linux-конфигурацией `~/.codex`. Не отключайте защиту и не включайте администратора без необходимости.

## Настройка и проверка

1. По инструкции [Настройка Codex CLI](/simidoc/ru/apps/codex-config) объедините `config.toml` с полями провайдера и модели; предварительно сохраните файл.
2. В каталоге проекта выполните `codex`.
3. Сохраните стандартные подтверждения и песочницу, попросите объяснить файл и проверьте запрос в журнале SimiRouter.

`codex --version` проверяет запуск команды, но не подключение API. Не заменяйте целиком `~/.codex`, чтобы не потерять сеансы и другие настройки.

## Официальные материалы

* [OpenAI Codex CLI](https\://learn.chatgpt.com/docs/codex/cli)
* [Песочница OpenAI в Windows](https\://learn.chatgpt.com/docs/windows/windows-sandbox)