# Claude Messages

## Описание интерфейса

`POST /v1/messages` принимает user/assistant и возвращает Message с текстом, инструментами или рассуждениями. Системная инструкция — верхнее поле system, а не сообщение role=system.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Прямое подключение Anthropic — `https://api.anthropic.com`, с `x-api-key: $ANTHROPIC_API_KEY`. Пример фиксирует `anthropic-version: 2023-06-01` для выбранной версии протокола, не обязательно последней. Выберите доступную модель нужных возможностей.

## Быстрый старт

1. **Подготовьте конфигурацию**\: создайте ключ в разделе Управление API-ключами и скопируйте полный ID модели с поддержкой Claude Messages из раздела Модели и цены.
2. **Отправьте минимальный запрос**\: передайте одно сообщение пользователя, сохраните заголовок `anthropic-version` и оставьте `stream` равным `false`.
3. **Прочитайте результат**\: запрос успешен, только если HTTP 2xx и `content[]` не пуст; текст находится в блоке содержимого, где `type=text`.
4. **Проверьте**\: сверьте `stop_reason`, `stop_sequence` и фактическое содержимое, затем проверьте журнал использования.

```bash
API_URL="https://api.dwchainless.com/v1/messages"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "anthropic-version: 2023-06-01" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "max_tokens": 256,
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

Замените `PASTE_API_KEY_HERE` и `MODEL_ID` на реальные значения; `anthropic-version` выбирает версию протокола и не означает последнюю версию.

## Параметры запроса

Тело JSON; пример содержит заголовок `anthropic-version: 2023-06-01`.

| Поле                          | Тип              | Обязателен  | Описание                                                                                                  |
| ----------------------------- | ---------------- | ----------- | --------------------------------------------------------------------------------------------------------- |
| model                         | string           | Да          | Доступный ID Claude.                                                                                      |
| max\_tokens                   | integer          | Да          | Лимит генерации; положительное число для обычного вывода, 0 только в поддерживаемом сценарии записи кеша. |
| messages                      | array            | Да          | Список сообщений.                                                                                         |
| messages\[].role              | string           | Да          | user или assistant.                                                                                       |
| messages\[].content           | string / array   | Да          | Текстовая строка или массив блоков.                                                                       |
| content\[].type               | string           | При условии | Соответствующие типы text, image, tool\_use, tool\_result.                                                |
| content\[].text               | string           | При условии | Текст блока text.                                                                                         |
| content\[].source             | object           | При условии | Источник image\: base64 с media\_type/data либо url с адресом.                                            |
| system                        | string / array   | Нет         | Системная инструкция; текстовые блоки при поддержке.                                                      |
| stream                        | boolean          | Нет         | true возвращает SSE; по умолчанию без потока.                                                             |
| stop\_sequences               | array            | Нет         | Пользовательские стоп-последовательности.                                                                 |
| temperature / top\_p / top\_k | number / integer | Нет         | Сэмплирование только у поддерживающих моделей.                                                            |
| tools                         | array            | Нет         | Функции с name, description и input\_schema.                                                              |
| tool\_choice                  | object           | Нет         | auto, any, tool, none; при tool задайте name.                                                             |
| thinking                      | object           | Нет         | Режим рассуждений зависит от поколения\: adaptive/enabled принимаются не всеми моделями.                  |
| metadata.user\_id             | string           | Нет         | Идентификатор пользователя приложения без прямых персональных данных.                                     |

### Пример запроса

```json
{
  "model": "MODEL_ID",
  "max_tokens": 256,
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释机器学习。"
    }
  ],
  "stream": false
}
```

## Ответ

Непотоковый ответ с HTTP 200 содержит Message.

| Поле                                                              | Тип           | Описание                                                                                                   |
| ----------------------------------------------------------------- | ------------- | ---------------------------------------------------------------------------------------------------------- |
| id / type                                                         | string        | ID сообщения; type=message.                                                                                |
| role / model                                                      | string        | assistant и ID модели ответа.                                                                              |
| content\[]                                                        | array         | Массив блоков\: не каждый содержит text.                                                                   |
| content\[].type / text                                            | string        | Для type=text читайте text; для tool\_use — id/name/input.                                                 |
| stop\_reason                                                      | string / null | end\_turn — завершение, max\_tokens — лимит, stop\_sequence — стоп-строка, tool\_use — запрос инструмента. |
| stop\_sequence                                                    | string / null | Сработавшая стоп-строка либо null.                                                                         |
| usage.input\_tokens / output\_tokens                              | integer       | Входные и выходные токены.                                                                                 |
| usage.cache\_creation\_input\_tokens / cache\_read\_input\_tokens | integer       | Необязательные метрики записи и чтения кеша, не дополнительный текст ответа.                               |

```json
{
  "id": "msg_example",
  "type": "message",
  "role": "assistant",
  "model": "MODEL_ID",
  "content": [
    {
      "type": "text",
      "text": "机器学习是一种从数据中提取规律并用于预测的方法。"
    }
  ],
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 14,
    "output_tokens": 24
  }
}
```

### Потоковый ответ

При stream=true обрабатывайте message\_start, content\_block\_start/delta/stop, message\_delta и message\_stop. text\_delta добавляет текст; input\_json\_delta — partial\_json аргументов инструмента, разбирайте после сборки. message\_delta содержит остановку и обновление расхода; message\_stop завершает сообщение. error возможен уже после HTTP 200.

При инструментах сохраните блоки assistant и следующим user-сообщением через `{"type":"tool_result","tool_use_id":"...","content":"..."}` верните результат. Перед выполнением проверяйте параметры и права.

## Примеры вызова

Задайте `SIMIROUTER_API_KEY`, `SIMIROUTER_CLAUDE_MODEL`; `SIMIROUTER_BASE_URL` переопределяет адрес шлюза по умолчанию; не добавляйте в конец `/v1`. Примеры Python 3, Node.js 18+ и Go используют только стандартную библиотеку; JSON в примере curl безопасно формируется Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_CLAUDE_MODEL"): raise RuntimeError("请设置 SIMIROUTER_CLAUDE_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    path = '/v1/messages'
    request = urllib.request.Request(base + path, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={'anthropic-version': '2023-06-01', "Authorization": "Bearer " + os.environ["SIMIROUTER_API_KEY"], "Content-Type": "application/json"})
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
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_CLAUDE_MODEL)
        throw new Error('请设置 SIMIROUTER_CLAUDE_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        max_tokens: 256,
        messages: [
          {
            role: 'user',
            content: '用一句话解释机器学习。',
          },
        ],
        stream: false,
      };
      body.model = process.env.SIMIROUTER_CLAUDE_MODEL;
      const endpoint = '/v1/messages';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
          'anthropic-version': '2023-06-01',
          Authorization: `Bearer ${process.env.SIMIROUTER_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(120000),
      });
      const result = await response.text();
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${result}`);
      console.log(JSON.stringify(JSON.parse(result), null, 2));
    }
    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    set -eu
    : "${SIMIROUTER_API_KEY:?请设置 SIMIROUTER_API_KEY}"
    : "${SIMIROUTER_CLAUDE_MODEL:?请设置 SIMIROUTER_CLAUDE_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_CLAUDE_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/messages" \
      --fail-with-body \
      --max-time 120 \
      -X POST \
      -H "anthropic-version: 2023-06-01" \
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
      model := os.Getenv("SIMIROUTER_CLAUDE_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_CLAUDE_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "max_tokens": 256,
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释机器学习。"
        }
      ],
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/messages"
      payload, err := json.Marshal(body); if err != nil { log.Fatal(err) }
      req, err := http.NewRequest("POST", base + endpoint, bytes.NewReader(payload)); if err != nil { log.Fatal(err) }
      req.Header.Set("anthropic-version", "2023-06-01")
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

| Статус HTTP     | Значение или тип ошибки провайдера                 | Действие                                                                        |
| --------------- | -------------------------------------------------- | ------------------------------------------------------------------------------- |
| 400             | `invalid_request_error`                            | Несовместимые структура, параметры или возможности модели.                      |
| 401 / 403       | `authentication_error` / `permission_error`        | Неверный ключ либо нет доступа.                                                 |
| 404             | `not_found_error`                                  | Адрес, модель или ресурс не найдены.                                            |
| 413             | `request_too_large`                                | Уменьшите тело запроса.                                                         |
| 429             | `rate_limit_error`                                 | Проверьте частоту и квоту.                                                      |
| 500 / 504 / 529 | `api_error` / `timeout_error` / `overloaded_error` | Ошибка, тайм-аут или перегрузка\: повторяйте ограниченно только временные сбои. |

Собственная ошибка Anthropic имеет вид `{"type":"error","error":{"type":"invalid_request_error","message":"..."},"request_id":"..."}`. Шлюз может отклонить аутентификацию, маршрут или квоту до провайдера; одного HTTP-статуса недостаточно, чтобы считать ошибку вышестоящей.

Длинные ответы и потоковые запросы могут длиться от десятков секунд до нескольких минут; задайте достаточный тайм-аут клиента и при обрыве потока оценивайте полученные фрагменты и причину завершения, а не отправляйте запрос повторно автоматически. При 429 и 5xx сначала проверьте тело ответа и журнал использования; при отказе по политике содержимого измените запрос или входные данные, а не повторяйте запрос без изменений.

## Официальные материалы

* [Anthropic Messages API](https\://platform.claude.com/docs/en/api/messages/create)
* [Версии API Anthropic](https\://platform.claude.com/docs/en/api/versioning)
* [Ошибки Anthropic](https\://platform.claude.com/docs/en/api/errors)