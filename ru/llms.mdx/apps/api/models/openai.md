# Список моделей в формате OpenAI

## Описание интерфейса

`GET /v1/models` возвращает модели, видимые ключу. Список подходит селектору, но не подтверждает модальности, инструменты, квоту и доступность сервиса.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

Отправляйте только Bearer, без x-api-key/x-goog-api-key, чтобы не вызвать другой формат шлюза.

## Параметры запроса

У списка нет JSON-тела и обязательных параметров запроса.

| Поле          | Тип           | Обязателен | Описание                 |
| ------------- | ------------- | ---------- | ------------------------ |
| Authorization | header string | Да         | Ключ шлюза после Bearer. |

## Ответ

| Поле                              | Тип                    | Описание                                                                                                                                                                |
| --------------------------------- | ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| object                            | string                 | list.                                                                                                                                                                   |
| data                              | array                  | Список моделей, допускается пустой.                                                                                                                                     |
| data\[].id                        | string                 | ID для вызова генерации.                                                                                                                                                |
| data\[].object                    | string                 | model.                                                                                                                                                                  |
| data\[].created                   | integer                | Unix-время в секундах; метаданные шлюза не обязательно отражают релиз производителя.                                                                                    |
| data\[].owned\_by                 | string                 | Метка владельца не доказывает реальный маршрут к провайдеру.                                                                                                            |
| success                           | boolean                | Бизнес-флаг шлюза, не стандарт OpenAI.                                                                                                                                  |
| `data[].context_length`           | integer                | Размер контекста в токенах, указанный шлюзом. Если он не настроен, используется значение платформы по умолчанию. Проверьте документацию модели и ограничения эндпоинта. |
| `data[].supported_endpoint_types` | `array<string>` / null | Типы эндпоинтов, указанные шлюзом. Используйте их при выборе эндпоинта.                                                                                                 |

```json
{
  "object": "list",
  "success": true,
  "data": [
    {
      "id": "MODEL_ID",
      "object": "model",
      "created": 1626777600,
      "owned_by": "custom",
      "context_length": 1048576,
      "supported_endpoint_types": ["openai"]
    }
  ]
}
```

Пустой список допустим\: не обращайтесь сразу к data\[0]. Ошибка группы может вернуть HTTP 200 и success=false/message, что клиент должен распознать. Официальный OpenAI также имеет GET /v1/models/\{model}; метаданные списка не полное описание возможностей.

## Примеры вызова

Задайте `SIMIROUTER_API_KEY`. Чтобы заменить адрес шлюза по умолчанию, укажите в `SIMIROUTER_BASE_URL` корневой адрес без суффикса версии. Во всех примерах отправляется GET-запрос без тела.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1/models'
    request = urllib.request.Request(base + path, method="GET",
        headers={"Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            result = json.load(response)
    except urllib.error.HTTPError as error:
        print(f"HTTP {error.code}: {error.read().decode()}", file=sys.stderr)
        raise SystemExit(1)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    async function main() {
      if (!process.env.SIMIROUTER_API_KEY) throw new Error("请设置 SIMIROUTER_API_KEY");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const endpoint = "/v1/models";
      const response = await fetch(base + endpoint, { method: "GET",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        signal: AbortSignal.timeout(120000) });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch(error => { console.error(error); process.exitCode = 1; });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    curl "${BASE_URL%/}/v1/models" \
      --fail-with-body \
      --max-time 120 \
      -X GET \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      endpoint := "/v1/models"
      req, err := http.NewRequest("GET", base + endpoint, nil); if err != nil { log.Fatal(err) }
      req.Header.Set("Authorization", "Bearer " + key); req.Header.Set("Content-Type", "application/json")
      client := &http.Client{Timeout: 120 * time.Second}
      response, err := client.Do(req); if err != nil { log.Fatal(err) }; defer response.Body.Close()
      result, err := io.ReadAll(response.Body); if err != nil { log.Fatal(err) }
      if response.StatusCode >= 400 { log.Fatalf("HTTP %d: %s", response.StatusCode, result) }
      fmt.Println(string(result))
    }
    ```
  </Tab>
</Tabs>

## Коды ошибок

| Статус HTTP | Значение или тип ошибки провайдера       | Действие                                                                          |
| ----------- | ---------------------------------------- | --------------------------------------------------------------------------------- |
| 400         | Неверный запрос                          | Проверьте обязательные поля, JSON, параметры модели и длину контекста.            |
| 401         | Ошибка аутентификации                    | Проверьте наличие, действительность и принадлежность ключа.                       |
| 403 / 404   | Нет доступа / ресурс не найден           | Проверьте права модели, ID ресурса и URL.                                         |
| 429         | Ограничение частоты или квоты            | Различайте лимит скорости и нехватку квоты по ответу; повтор не восполняет квоту. |
| 500 / 503   | Ошибка сервиса / временная недоступность | Сохраните ID и ограниченно повторите временные сбои с задержкой.                  |

Ошибка OpenAI обычно содержит `error.message`, `error.type`, `error.param`, `error.code`; `param` и `code` могут быть `null`; поля могут отсутствовать и отличаться от HTTP-кода. Ошибки шлюза возможны до провайдера; кроме транспорта проверяйте success=false.

## Официальные материалы

* [OpenAI List models](https\://developers.openai.com/api/reference/resources/models/methods/list)
* [OpenAI Retrieve model](https\://developers.openai.com/api/reference/resources/models/methods/retrieve)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)