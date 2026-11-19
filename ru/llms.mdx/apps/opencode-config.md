# Настройка OpenCode CLI

OpenCode использует глобальный файл конфигурации\:

* **Linux / macOS**\: `~/.config/opencode/opencode.jsonc`
* **Windows**\: `%USERPROFILE%\.config\opencode\opencode.jsonc`

Сначала укажите ключ в поле `apiKey`, затем выполните проверку. Этот пример не использует переменные окружения, поэтому дополнительные переменные окружения не нужны. Защитите файл с ключом и сохраните стандартные запросы разрешений OpenCode.

## Файл конфигурации (совместимый формат V1)

Запишите следующее содержимое в файл и замените `apiKey` своим API-ключом\:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "openai/gpt-6-astra",
  "small_model": "openai/gpt-6-astra",
  "provider": {
    "openai": {
      "options": {
        "baseURL": "https://api.dwchainless.com/v1",
        "apiKey": "PASTE_API_KEY_HERE"
      },
      "models": {
        "gpt-6-astra": {
          "headers": {
            "originator": "opencode"
          }
        }
      }
    }
  },
  "agent": {
    "title": {
      "options": {
        "reasoningEffort": "none"
      }
    },
    "build": {
      "variant": "xhigh",
      "options": {
        "reasoningSummary": "detailed",
        "textVerbosity": "high"
      }
    },
    "plan": {
      "variant": "xhigh",
      "options": {
        "reasoningSummary": "detailed",
        "textVerbosity": "high"
      }
    }
  }
}
```

## Проверка конфигурации

### Linux / macOS

```bash
opencode debug config
opencode run "你好"
```

### Windows CMD

```cmd
opencode debug config
opencode run "你好"
```

### Windows PowerShell

```powershell
opencode debug config
opencode run "你好"
```

<Callout type="info" title="">
  `opencode debug config` проверяет загрузку конфигурации, а команда `opencode run "你好"` из примера выше — ответ модели.
</Callout>

## Официальные материалы

[Документация конфигурации OpenCode](https\://opencode.ai/docs/config/) описывает пути и текущий формат. Здесь сохранен совместимый V1; при обновлении следуйте инструкции миграции своей версии и не заменяйте существующую конфигурацию целиком.