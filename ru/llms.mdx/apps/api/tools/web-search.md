# Инструмент веб-поиска

## Описание интерфейса

`POST /v1/responses` позволяет объявить в tools размещенный у OpenAI инструмент web\_search. Поддерживаемая модель ищет страницы, читает результаты и отвечает со ссылками. Поиск не является отдельной универсальной конечной точкой `/search` и не является именем функции для любой модели Chat.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

`{"type":"web_search"}` предназначен для Responses. Не помещайте его напрямую в tools обычного Chat Completions\: универсальный инструмент Chat — function. У официального поиска Chat есть специальные модели и web\_search\_options; это другой протокол.

## Параметры запроса

| Поле                              | Тип             | Обязателен | Описание                                                                                                                     |
| --------------------------------- | --------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------- |
| model                             | string          | Да         | Модель с поддержкой web\_search в Responses.                                                                                 |
| input                             | string / array  | Да         | Вопрос и необходимый контекст.                                                                                               |
| tools\[].type                     | string          | Да         | web\_search.                                                                                                                 |
| tools\[].search\_context\_size    | string          | Нет        | Если поддерживается\: low, medium или high для объема поискового контекста.                                                  |
| tools\[].filters.allowed\_domains | array           | Нет        | Если поддерживается\: разрешенные домены без префикса протокола.                                                             |
| tools\[].user\_location           | object          | Нет        | Приблизительное местоположение\: type=approximate, country, city, region, timezone. Не передавайте точные личные координаты. |
| tool\_choice                      | string / object | Нет        | auto разрешает модели выбрать инструмент; required требует вызова инструмента.                                               |
| include                           | array           | Нет        | web\_search\_call.action.sources позволяет запросить полный список источников.                                               |
| stream                            | boolean         | Нет        | true включает SSE-события Responses.                                                                                         |

### Пример запроса

```json
{
  "model": "MODEL_ID",
  "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
  "tools": [
    {
      "type": "web_search"
    }
  ],
  "stream": false
}
```

## Ответ

| Поле                                     | Тип             | Описание                                                                          |
| ---------------------------------------- | --------------- | --------------------------------------------------------------------------------- |
| output\[].type=web\_search\_call         | object          | Один вызов поиска или чтения; его наличие не означает завершенный итоговый ответ. |
| web\_search\_call.status                 | string          | Статус выполнения инструмента.                                                    |
| web\_search\_call.action                 | object          | Действия search, open\_page, find и соответствующие запросы либо URL.             |
| output\[].type=message                   | object          | Итоговое сообщение модели.                                                        |
| content\[].type / text                   | string          | Текст элемента output\_text.                                                      |
| content\[].annotations\[]                | array           | Список ссылок, обычно url\_citation.                                              |
| annotations\[].url / title               | string          | URL и заголовок источника.                                                        |
| annotations\[].start\_index / end\_index | integer         | Диапазон текста, связанный со ссылкой.                                            |
| status / error / incomplete\_details     | string / object | Итоговый статус и причина ошибки или неполного ответа.                            |
| usage                                    | object          | Токены модели; это не означает отсутствия дополнительной платы за поиск.          |

```json
{
  "id": "resp_search_example",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "id": "ws_example",
      "type": "web_search_call",
      "status": "completed",
      "action": {
        "type": "search",
        "query": "site:developers.openai.com Responses API"
      }
    },
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "Responses API 支持有类型的输入输出以及工具调用。",
          "annotations": [
            {
              "type": "url_citation",
              "start_index": 0,
              "end_index": 36,
              "title": "Responses API",
              "url": "https://developers.openai.com/api/docs/guides/responses"
            }
          ]
        }
      ]
    }
  ]
}
```

Отображайте ответ с понятными кликабельными ссылками и указанием источников. Страницы — данные\: не исполняйте их команды и не раскрывайте учетные данные приложения. Результаты могут устареть или противоречить друг другу; важные выводы сверяйте с первоисточниками.

## Примеры вызова

Задайте `SIMIROUTER_API_KEY`, `SIMIROUTER_MODEL`; `SIMIROUTER_BASE_URL` переопределяет адрес шлюза по умолчанию; не добавляйте в конец `/v1`. Примеры Python 3, Node.js 18+ и Go используют только стандартную библиотеку; JSON в примере curl безопасно формируется Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_MODEL"): raise RuntimeError("请设置 SIMIROUTER_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/responses'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
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
      if (!process.env.SIMIROUTER_MODEL) throw new Error("请设置 SIMIROUTER_MODEL");
      const base = (process.env.SIMIROUTER_BASE_URL || "https://api.dwchainless.com").replace(/\/$/, "");
      const body = {
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = "/v1/responses";
      const response = await fetch(base + endpoint, { method: "POST",
        headers: { Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify(body),
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
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/responses" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "Authorization: Bearer $SIMIROUTER_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary "$BODY"
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import (
      "bytes"
      "fmt"
      "io"
      "log"
      "net/http"
      "os"
      "strings"
      "time"
      "encoding/json"
    )

    func main() {
      key := os.Getenv("SIMIROUTER_API_KEY"); if key == "" { log.Fatal("请设置 SIMIROUTER_API_KEY") }
      model := os.Getenv("SIMIROUTER_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "input": "查找OpenAI官方文档中关于Responses API的说明，并提供来源链接。",
      "tools": [
        {
          "type": "web_search"
        }
      ],
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/responses"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
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

Ошибка OpenAI обычно содержит `error.message`, `error.type`, `error.param`, `error.code`; `param` и `code` могут быть `null`; эти поля необязательны и могут отличаться от HTTP-статуса. Шлюз может вернуть ошибку аутентификации, маршрута или квоты до обращения к провайдеру. Даже при HTTP 200 проверяйте статус поиска, итогового ответа и наличие ссылок. Без источников нельзя заявлять о проверке фактов.

## Официальные материалы

* [OpenAI\: веб-поиск](https\://developers.openai.com/api/docs/guides/tools-web-search)
* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)