# Настройка настольного Codex

Настольный Codex поддерживает вход с ключом API и открытие пользовательского `config.toml`. После настройки Codex отправляет запросы через совместимый интерфейс Responses SimiRouter.

<Callout type="info" title="">
  Поле входа по-прежнему называется **OpenAI API key**. Введите в него ключ API SimiRouter, например `sk-...`.
</Callout>

## Предварительные условия

Перед началом подготовьте\:

* Актуальную версию настольного Codex
* Учётную запись SimiRouter;
* API-ключ, созданный в консоли SimiRouter;
* Доступ учетной записи к настраиваемой модели

## Настройка

### 1. Вход с ключом API

1. Откройте настольный Codex.
2. На экране входа выберите **Sign in another way**.
3. В поле **OpenAI API key** введите ключ API SimiRouter.
4. Нажмите **Continue** для входа в приложение.

![Ввод ключа API в настольном Codex](/simidoc/assets/codex-desktop/codex-api-key-login.png)

### 2. Пользовательский файл конфигурации

1. Откройте настройки Codex.
2. Слева выберите **Configuration**.
3. В разделе **Custom config.toml settings** выберите **User config**.
4. Нажмите **Open config.toml** для открытия пользовательской конфигурации.

![Открытие пользовательского config.toml в Codex](/simidoc/assets/codex-desktop/codex-user-config.png)

### 3. Настройки SimiRouter

Перед редактированием сохраните резервную копию `config.toml`; объедините поля модели и провайдера с текущим файлом, не заменяя его целиком. Сохраните MCP, доверие к проектам, подтверждения и песочницу; не добавляйте повторно одноименные таблицы TOML.

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

Сохраните файл, полностью закройте и снова запустите Codex.

<Callout type="info" title="">
  В примере `requires_openai_auth = false` и `experimental_bearer_token` непосредственно задают токен. Замените заглушку ключом API SimiRouter; одновременно создавать `auth.json` не требуется, как и полагаться на ключ из процедуры входа. `config.toml` содержит ключ открытым текстом\: не публикуйте его. В Linux / macOS команда `chmod 600 ~/.codex/config.toml` ограничивает доступ; в Windows задайте права на файл. Сохраните подтверждения, песочницу и доверие к проектам\: ради подключения сервиса не отключайте защиту.
</Callout>

## Проверка конфигурации

После перезапуска Codex\:

1. Откройте проект или рабочую область.
2. Начните с безопасной задачи, например объяснения файла.
3. В журнале SimiRouter проверьте время, модель и расход этого запроса. Подпись клиента и самоописание модели не подтверждают реальный маршрут.

## Частые вопросы

### Недействительный API-ключ

* Снова скопируйте полный ключ API из консоли SimiRouter.
* Проверьте отсутствие пробелов до и после ключа.
* Убедитесь, что ключ начинается с `sk-` и действует.

### Настройки не применились

* Убедитесь, что редактируете **User config**, открытый из `config.toml`.
* Проверьте, что `model_provider = "simirouter"` и `[model_providers.simirouter]` полностью совпадают.
* После сохранения полностью закройте приложение, а не только окно.

### Ошибка модели или подключения

* Проверьте, что `base_url` имеет значение `https://api.dwchainless.com/v1`.
* Проверьте, что `wire_api` имеет значение `responses`.
* Проверьте, что группа текущего ключа API разрешает `gpt-6-astra`. Для другой модели замените `model` соответствующим именем модели.

Если требуется вручную настроить `auth.json`, сменить модель или использовать CLI, см. [Настройка Codex CLI](/simidoc/ru/apps/codex-config).

## Официальные материалы

* [Справочник конфигурации OpenAI Codex](https\://developers.openai.com/codex/config-reference/)