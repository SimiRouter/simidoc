# Настройка Codex CLI

В этом примере API-ключ задаётся непосредственно в `config.toml`. Скрипт работает с пользовательскими `config.toml` и локальным `models.json`, но не создаёт и не изменяет `auth.json`.

Скрипт использует два URL и один API-ключ\:

* **Базовый URL инференса**\: `https://api.dwchainless.com/v1`, записывается в `model_providers.simirouter.base_url` для запросов Codex.
* **URL каталога моделей**\: `https://api.dwchainless.com/v1/models`. Тот же ключ используется как Bearer-токен; список OpenAI преобразуется в локальный `~/.codex/models.json`, а `model_catalog_json` указывает на этот файл. Это не второй URL инференса.
* **API-ключ**\: один ключ SimiRouter используется для обоих URL. Скрипт отправляет его только как Bearer-учётные данные на эти два фиксированных адреса и не записывает в документацию или другие места.

Каталог требует действительный ключ. Модели и базовые метаданные, например размер контекста, берутся из ответа; преобразование не добавляет неподтверждённые инструменты или возможности рассуждения.

* **Linux / macOS**\: `~/.codex/config.toml`
* **Windows**\: `%USERPROFILE%\.codex\config.toml`

## Способ 1. Скрипт автоматической настройки (необязательно; сначала проверьте скрипт)

В репозитории есть скрипты Bash и PowerShell. Сначала установите и запустите Codex CLI или Codex Desktop; скачайте и изучите скрипт перед запуском локального файла.

* [Скачать скрипт Bash](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.sh)
* [Скачать скрипт PowerShell](https\://cdn.jsdelivr.net/gh/SimiRouter/simidoc@cfec21a766129af49914f80da19529b9ff5d12e1/scripts/codex-simirouter-setup.ps1)

В macOS / Linux выполните в терминале\:

<Callout type="warn" title="">
  Эти шаги сохраняют скрипт с сайта документации, но не передают сетевой ответ непосредственно интерпретатору. Изучите сохранённый файл перед запуском. Если опубликованный файл недоступен, используйте такой же файл из `public/scripts/` репозитория или ручную настройку ниже.
  Скрипт записывает API-ключ в `experimental_bearer_token` файла `config.toml`; `auth.json` не создаётся и не изменяется. Считайте файл открытым секретом.
</Callout>

```bash
# Download the script from the public script link above, then review it.
less ./codex-simirouter-setup.sh
bash ./codex-simirouter-setup.sh
```

В Windows выполните в PowerShell\:

```powershell
# Download the script from the public script link above, then review it.
$script = Join-Path (Get-Location) 'codex-simirouter-setup.ps1'
Get-Content -LiteralPath $script
& powershell -File $script
```

<Callout type="info" title="">
  PowerShell 5.1 и PowerShell 7 сначала сохраняют файл, поэтому его можно проверить до ввода API-ключа. В PowerShell 7 замените `powershell` в последней строке на `pwsh`.
</Callout>

После запуска выберите модель в меню. При первом запуске потребуется API-ключ SimiRouter, начинающийся с `sk-`. Его можно получить в консоли SimiRouter.

Скрипт выполняет следующие действия (для версии Bash требуется Python 3.11 или новее)\:

* **Создаёт резервную копию**\: сохраняет снимок `config.toml` в `~/.codex/backup-simirouter/`; восстановление требует явного ввода `RESTORE`.
* **Синхронизирует каталог моделей**\: запрашивает URL каталога с тем же ключом, преобразует идентификаторы и базовые метаданные в `~/.codex/models.json` и устанавливает `model_catalog_json` на этот файл.
* **Обновляет `config.toml`**\: меняет верхнеуровневые `model_provider`, `model` и `model_catalog_json`, а также поля в `[model_providers.simirouter]`\: `base_url`, `wire_api` и `experimental_bearer_token`, сохраняя остальное содержимое по возможности.
* **Защищает файлы**\: скрипты пытаются ограничить доступ к каталогу и файлам конфигурации текущим пользователем; при отказе ОС выводится предупреждение.
* **Проверяет конфигурацию**\: Bash-версия использует Python 3.11+ для проверки TOML и JSON каталога до замены файлов. Скрипты не проверяют и не изменяют `auth.json` и не заявляют об успешном реальном запросе инференса.

<Callout type="info" title="">
  Повторный запуск позволяет сменить модель или выбрать восстановление настроек по умолчанию, чтобы вернуть резервную копию состояния до настройки.
</Callout>

## Способ 2. Ручная настройка Linux / macOS (запасной вариант)

Перед редактированием сохраните отдельные копии `config.toml` и `auth.json`. Не перемещайте и не создавайте заново весь каталог `~/.codex`\: в нём также находятся история, сеансы и другие настройки. Объедините только поля модели и поставщика, не заменяя весь файл и не добавляя повторные таблицы TOML. Сохраните настройки MCP, подтверждений, песочницы и доверия к проектам.

### `~/.codex/config.toml`

```toml
model_provider = "simirouter"
review_model = "gpt-6-astra"
model = "gpt-6-astra"
model_reasoning_effort = "xhigh"
plan_mode_reasoning_effort = "high"
model_reasoning_summary = "auto"
model_verbosity = "high"

suppress_unstable_features_warning = true
web_search = "live"
model_catalog_json = "~/.codex/models.json"

[model_providers.simirouter]
name = "simirouter"
base_url = "https://api.dwchainless.com/v1"
wire_api = "responses"
stream_idle_timeout_ms = 900000
supports_websockets = false
http_headers = { "x-openai-actor-authorization" = "api.dwchainless.com" }
requires_openai_auth = false
experimental_bearer_token="PASTE_API_KEY_HERE"
```

`model_catalog_json` указывает на локальный каталог, созданный из `https://api.dwchainless.com/v1/models`. При ручной настройке запросите этот URL тем же ключом и сохраните данные в формате Codex `models.json`; нельзя напрямую использовать список OpenAI `data`.

Файл содержит токен в открытом виде\: не публикуйте и не передавайте его. В Linux / macOS после сохранения ограничьте доступ\:

```bash
chmod 600 ~/.codex/config.toml
```

### `auth.json` (только если нужен другой способ аутентификации)

В примере выше токен находится в конфигурации; создавать или перезаписывать `auth.json` не нужно. JSON ниже приведён для других способов аутентификации, которым нужен этот файл. Выберите один способ, поддерживаемый вашей версией Codex, а не смешивайте их для обхода ошибок.

```json
{
  "OPENAI_API_KEY": "PASTE_API_KEY_HERE"
}
```

## Настройка Windows

### PowerShell

Создайте каталог и откройте файлы конфигурации\:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex" | Out-Null
notepad "$env:USERPROFILE\.codex\config.toml"
```

### CMD

```cmd
if not exist "%USERPROFILE%\.codex" mkdir "%USERPROFILE%\.codex"
notepad "%USERPROFILE%\.codex\config.toml"
```

После резервного копирования объедините поля модели и поставщика из TOML выше с `config.toml`, не перезаписывая остальные настройки. Здесь используется токен в конфигурации, поэтому создавать или менять `auth.json` не нужно. В Windows ограничьте доступ к файлу с ключом своим пользователем.

## Проверка запуска

```bash
codex
```

<Callout type="warn" title="">
  В Windows файлы `config.toml` и `auth.json` должны находиться в `%USERPROFILE%\.codex\`. Убедитесь, что они сохранены в правильном каталоге.
</Callout>