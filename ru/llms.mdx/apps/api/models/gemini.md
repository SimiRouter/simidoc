# Список моделей в формате Gemini

## Описание интерфейса

`GET /v1beta/models` возвращает список Gemini.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Официальный Google доступен по `https://generativelanguage.googleapis.com`, обычно с `x-goog-api-key: $GEMINI_API_KEY`, а не Bearer-ключом шлюза. Выберите доступную модель с нужными возможностями.

Список шлюза нужен для поиска имен и не является полным каталогом возможностей Google.

## Параметры запроса

У шлюза нет тела и обязательной пагинации. Google models.list поддерживает pageSize (по умолчанию 50, до 1000) и pageToken, но шлюз возвращает весь список без той же гарантии метаданных и страниц.

| Поле                 | Тип                    | Обязателен                      | Описание                                                               |
| -------------------- | ---------------------- | ------------------------------- | ---------------------------------------------------------------------- |
| Authorization        | header string          | Да                              | Bearer-ключ шлюза; при прямом подключении ключ Google.                 |
| pageSize / pageToken | query integer / string | Необязательно в собственном API | Только пагинация официального API; не полагайтесь на обработку шлюзом. |

## Ответ

| Поле                                         | Тип            | Описание                                                                                |
| -------------------------------------------- | -------------- | --------------------------------------------------------------------------------------- |
| models                                       | array          | Список моделей, может быть пустым.                                                      |
| models\[].name                               | string         | Имя ресурса\: обычно models/\{id}, шлюз может вернуть непосредственно ID.               |
| models\[].displayName                        | string         | Читаемое имя.                                                                           |
| nextPageToken                                | string / null  | Официальный токен следующей страницы; null у шлюза может означать отсутствие пагинации. |
| models\[].version / description              | string / null  | Официальные версия и описание; у шлюза могут отсутствовать или быть null.               |
| models\[].inputTokenLimit / outputTokenLimit | integer / null | Официальные входные/выходные лимиты\: не выводите их из отсутствующего значения.        |
| models\[].supportedGenerationMethods         | array / null   | Официальные методы, например generateContent; могут отсутствовать у шлюза.              |

```json
{
  "models": [
    {
      "name": "MODEL_ID",
      "displayName": "MODEL_ID"
    }
  ],
  "nextPageToken": null
}
```

Пример сокращенных метаданных шлюза. Перед вставкой name в путь удаляйте models/ только один раз. Успех models.list не исключает отказа generateContent по правам, возможностям или квоте.

## Примеры вызова

Задайте `SIMIROUTER_API_KEY`. Чтобы заменить адрес шлюза по умолчанию, укажите в `SIMIROUTER_BASE_URL` корневой адрес без суффикса версии. Во всех примерах отправляется GET-запрос без тела.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    path = '/v1beta/models'
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
      const endpoint = "/v1beta/models";
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
    curl "${BASE_URL%/}/v1beta/models" \
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
      endpoint := "/v1beta/models"
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

| Статус HTTP | Значение или тип ошибки провайдера | Действие                                                                    |
| ----------- | ---------------------------------- | --------------------------------------------------------------------------- |
| 400         | `INVALID_ARGUMENT` и другие        | Проверьте JSON, параметры модели, MIME и длину ввода.                       |
| 403         | `PERMISSION_DENIED`                | Проверьте ключ, права проекта, регион и платежные ограничения.              |
| 404         | `NOT_FOUND`                        | Проверьте имя модели и версию API.                                          |
| 429         | `RESOURCE_EXHAUSTED`               | Проверьте частоту и квоту; для повторяемых ошибок ограничьте число попыток. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`         | Сохраните ID запроса и повторите ограниченно либо позже.                    |

Ошибка Google содержит `error.code` (HTTP-число), `error.status` (имя перечисления), `error.message`; возможны также `details`. Шлюз может вернуть ошибку до провайдера; HTTP-код не определяет ее источник. Внутренний запрос шлюза может также дать success=false при HTTP 200\: проверяйте тело.

## Официальные материалы

* [Google Models API](https\://ai.google.dev/api/models)
* [Каталог моделей Google](https\://ai.google.dev/gemini-api/docs/models)
* [Google\: диагностика ошибок](https\://ai.google.dev/gemini-api/docs/troubleshooting)