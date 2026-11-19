# Настройка Grok CLI

В Grok CLI адрес каталога моделей и адрес вывода настраиваются отдельно. `[endpoints].models_base_url` служит и источником каталога, и базовым адресом вывода по умолчанию; `base_url` конкретной модели может его переопределить. Если задать только один из них, второй может по-прежнему указывать на официальный адрес — проверяйте оба.

Путь к файлу конфигурации\:

* **Linux / macOS**\: `~/.grok/config.toml`
* **Windows**\: `%USERPROFILE%\.grok\config.toml`

## Установка / обновление

Linux / macOS\:

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
grok update
grok --version
```

Windows (PowerShell)\:

```powershell
irm https://x.ai/cli/install.ps1 | iex
```

Если пакет установлен через WinGet, обновляйте его командой `winget upgrade`, а не `grok update`.

<Callout type="warn" title="При запуске требуется XAI_API_KEY">
  При запуске Grok CLI получает список моделей, читая только переменную окружения `XAI_API_KEY`; если она не задана, запрос завершается ошибкой независимо от `api_key` в файле конфигурации. При работе с SimiRouter задайте тот же ключ в этой переменной\:

  ```bash
  export XAI_API_KEY="PASTE_API_KEY_HERE"
  ```

  Не записывайте ключ в файл, попадающий в Git. Для постоянного использования храните его в файле окружения с правами `600` и подключайте через `source`.
</Callout>

## Запись конфигурации

Запишите следующее содержимое в `~/.grok/config.toml`, заменив `api_key` своим API-ключом\:

```toml
[models]
default = "grok-4.5"

[endpoints]
models_base_url = "https://api.dwchainless.com/v1"

[model."grok-4.5"]
base_url = "https://api.dwchainless.com/v1"
model = "grok-4.5"
name = "Grok 4.5"
api_key = "PASTE_API_KEY_HERE"
api_backend = "responses"
context_window = 500000
supports_backend_search = true

[session]
# 可选：官方默认值为 85；80 会更早触发自动压缩
auto_compact_threshold_percent = 80

[ui]
max_thoughts_width = 120
yolo = false
compact_mode = false
# permission_mode = "always-approve"  # enable only in trusted environments
```

Параметры интерфейса меняют только отображение\: ширина блока рассуждений — 120, компактный интерфейс отключён; пример сохраняет подтверждение вызовов инструментов.

<Callout type="warn" title="">
  В примере `yolo` отключен, а `permission_mode = "always-approve"` закомментирован. Включение разрешает Grok изменять файлы и выполнять команды без подтверждения; **используйте только в доверенных проектах и среде**.
</Callout>

<Callout type="info" title="">
  `api_key` должен содержать ключ SimiRouter, а не grok.com OAuth `refresh_token` от grok.com. Встроенный ключ хранится открытым текстом; в Linux / macOS выполните `chmod 600 ~/.grok/config.toml`. На общих компьютерах рекомендуется официальный способ через `env_key`.
</Callout>

## Проверка конфигурации

```bash
grok inspect
grok models
grok --model grok-4.5 --output-format json -p '只输出 YAI_GROK_OK'
```

## Официальные материалы

* [xAI Grok CLI\: пользовательские модели](https\://docs.x.ai/build/overview)
* [xAI Grok CLI\: справочник конфигурации](https\://docs.x.ai/build/settings)