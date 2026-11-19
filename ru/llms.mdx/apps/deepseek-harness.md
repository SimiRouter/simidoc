# Настройка DeepSeek Harness

DeepSeek Harness (`dsh`) — открытая агентная платформа DeepSeek AI. Пользовательский провайдер позволяет использовать модели SimiRouter в Web UI и заданиях Headless Harness.

## Предварительные условия

Подготовьте\:

* Учетную запись SimiRouter и ключ API
* Node.js и `npx`
* Терминал macOS, Linux или Windows
* Каталог проекта, с которым будет работать агент

## Установка и запуск

Перейдите в каталог нужного проекта и выполните\:

```bash
npx @deepseek-ai/dsh web
```

Web UI по умолчанию доступен по адресу `http://127.0.0.1:3080`. Каталог запуска — лишь расположение файлов по умолчанию; новый Web UI не выбирает рабочую область автоматически. Сначала добавьте этот каталог в интерфейсе\: до этого поле ввода сессии недоступно.

Чтобы изменить порт\:

```bash
npx @deepseek-ai/dsh web --port 8080
```

## Настройка SimiRouter в Web UI (рекомендуется)

### 1. Настройки моделей

В Web UI DeepSeek Harness откройте **Settings → Models**.

![Открытие настроек моделей DeepSeek Harness](/simidoc/assets/deepseek-harness/open-model-settings.png)

### 2. Пользовательский провайдер

Нажмите **Add a custom provider** и заполните\:

| Поле         | Значение                         |
| ------------ | -------------------------------- |
| Provider ID  | `simirouter`                     |
| Display name | `SimiRouter`                     |
| Base URL     | `https://api.dwchainless.com/v1` |
| API protocol | `openai-completions`             |
| API key      | Ваш ключ API SimiRouter          |

![Настройка пользовательского провайдера SimiRouter](/simidoc/assets/deepseek-harness/custom-provider-form.png)

<Callout type="warn" title="">
  Provider ID используется в сеансах, модели по умолчанию и учетных данных; после сохранения его нельзя просто переименовать. Используйте строчное имя `simirouter`.
</Callout>

### 3. Получение моделей

В разделе **Model catalog** выберите **Fetch available models**. Harness запросит список с текущими Base URL и ключом API.

Отметьте нужные модели и сохраните. Если автоматическое получение не удалось, укажите ID вручную, например `gpt-6-astra`. Имя должно совпадать с доступным текущей группе ключа API идентификатором.

![Выбор моделей для провайдера SimiRouter](/simidoc/assets/deepseek-harness/select-provider-models.png)

### 4. Выбор модели

После сохранения найдите в селекторе рядом с полем ввода **SimiRouter** и выберите модель. Она станет моделью новых сеансов; сеансы, уже отправлявшие запросы, продолжат использовать прежнюю модель.

![Выбор модели SimiRouter в DeepSeek Harness](/simidoc/assets/deepseek-harness/model-picker.png)

## Настройка через Profile Patch

Расширенные настройки провайдера Web Profile находятся в `$DSH_HOME/profiles/web/cordis.patch.yml` (по умолчанию `~/.dsh/profiles/web/cordis.patch.yml`). Перед изменением сохраните копию файла и объедините конфигурацию плагина, не заменяя существующих провайдеров и плагинов\:

```yaml
- id: llm-pi-ai
  config:
    providers:
      simirouter:
        displayName: SimiRouter
        apiKeyEnv: SIMIROUTER_API_KEY
        api: openai-completions
        baseURL: https://api.dwchainless.com/v1
        models:
          - id: MODEL_ID
```

Замените `MODEL_ID` полным ID модели, а в окружении запуска Harness задайте `SIMIROUTER_API_KEY`. После запуска Web UI выберите модель SimiRouter. Настройка относится к Web Profile и не наследуется другими профилями автоматически.

## Проверка конфигурации

1. Откройте Web UI\: по умолчанию `http://127.0.0.1:3080` или порт, указанный в `--port` при запуске.
2. Убедитесь, что селектор показывает **SimiRouter** и сохраненные модели.
3. Создайте сеанс и отправьте короткое тестовое сообщение.
4. В журнале SimiRouter проверьте время, модель и расход для подтверждения вызова.

## Режим Headless

Headless Profile по умолчанию отключает управляемое хранилище учетных данных Web. Ключ из интерфейса не обязательно будет использован. Настройте того же провайдера в профиле Headless и передайте ключ API через окружение запуска. См. [DeepSeek Harness\: учетные данные Headless](https\://github.com/deepseek-ai/deepseek-harness/blob/master/packages/bundle/headless/README.md#credentials).

## Частые вопросы

### `MISSING_CREDENTIAL`

Harness не находит `SIMIROUTER_API_KEY`. В **Settings → Models** сохраните ключ API повторно либо задайте одноименную переменную в терминале запуска.

### `UNKNOWN_MODEL`

Текущая модель отсутствует в списке текущего профиля `simirouter` с поддержкой `models`. Обновите каталог либо добавьте правильный ID вручную.

### 401 при загрузке моделей или диалоге

* Проверьте полноту и действительность ключа API, удалите лишние пробелы.
* Убедитесь, что Base URL равен `https://api.dwchainless.com/v1`.
* Проверьте доступ группы ключа API к выбранной модели.

### Запрос не прошел через SimiRouter

Убедитесь, что добавлен **custom provider** с Provider ID `simirouter`. Встроенные провайдеры DeepSeek, OpenAI и Anthropic продолжают использовать собственные официальные адреса.

### Смена модели по умолчанию не применилась

Проверьте в новом сеансе. Сеансы, уже отправлявшие запросы, сохраняют собственную модель.

## Официальные материалы

* [DeepSeek Harness](https\://github.com/deepseek-ai/deepseek-harness)
* [DeepSeek Harness\: настройка моделей](https\://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/providers.zh.md)