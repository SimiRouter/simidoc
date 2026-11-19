# Установка и настройка Factory Droid CLI

Droid CLI поддерживает собственные ключи API. Личные модели сохраняются локально; это не означает, что та же модель используется в размещенном веб- или мобильном интерфейсе Factory.

## Установка

macOS / Linux\:

```bash
curl -fsSL https://app.factory.ai/cli | sh
droid --version
```

Windows PowerShell\:

```powershell
irm https://app.factory.ai/cli/windows | iex
droid --version
```

Команды выполняют официальный установочный скрипт\: проверьте источник. В управляемом окружении следуйте правилам организации. Не отключайте защитное ПО и глобальную политику выполнения ради установки. Если при запуске требуется вход, выполните его по инструкции клиента.

## Добавление модели SimiRouter

1. Запустите `droid`, выполните `/settings` и откройте **Custom models**; также можно в `/model` открыть **Manage custom models**.
2. Нажмите **Add model** и выберите универсального провайдера Chat Completions.
3. Заполните поля и сохраните\:

| Поле         | Значение                                       |
| ------------ | ---------------------------------------------- |
| Provider     | `generic-chat-completion-api`                  |
| Base URL     | `https://api.dwchainless.com/v1`               |
| API Key      | SimiRouter API Key                             |
| Model        | Полный ID доступной модели                     |
| Display name | Например `SimiRouter`; только отображаемое имя |

## Настройка файлом

Можно также объединить настройки `~/.factory/settings.json` с разделом `customModels`. Перед изменением сделайте резервную копию; сохраните остальные элементы и настройки.

```json
{
  "customModels": [
    {
      "model": "MODEL_ID",
      "displayName": "SimiRouter",
      "baseUrl": "https://api.dwchainless.com/v1",
      "apiKey": "${SIMIROUTER_API_KEY}",
      "provider": "generic-chat-completion-api"
    }
  ]
}
```

Замените `MODEL_ID` реальным ID модели и задайте в окружении Droid `SIMIROUTER_API_KEY`.`${SIMIROUTER_API_KEY}` — поддерживаемая Droid ссылка на переменную окружения; не заменяйте ее публично доступным настоящим ключом.

Текущая конфигурация использует `settings.json` и поля camelCase. Элементы старого `config.json` могут мигрировать при первом запуске; последующие изменения вносите в `settings.json`, не запускайте устаревшие сторонние скрипты, заменяющие конфигурацию.

## Проверка

Откройте `/model`, затем **Custom Models** и выберите модель SimiRouter. Начните с безопасной задачи, например объяснения файла, затем проверьте реальную модель и расход в журнале SimiRouter. Настраивайте лимит вывода, изображения и инструменты по возможностям модели, а не по произвольным значениям другого примера.

## Официальные материалы

* [Быстрый старт Factory Droid CLI](https\://docs.factory.com/droid-cli/quickstart)
* [Пользовательские модели Factory (BYOK)](https\://docs.factory.com/model-independence/byok)