# Responses API

## Описание интерфейса

`POST /v1/responses` использует входные/выходные элементы вместо Chat choices/message, для инструментов, медиа и структурированного вывода.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

Шлюз реализует создание, но не универсальный `GET /v1/responses/{id}` и отмену. Поэтому `background: true` из собственного асинхронного OpenAI не подходит этому подключению\: используйте синхронный ответ или SSE. Для фоновых задач нужен официальный сервис с созданием, опросом и отменой.

## Быстрый старт

1. **Подготовьте конфигурацию**\: создайте ключ в разделе Управление API-ключами и скопируйте полный ID модели с поддержкой Responses из раздела Модели и цены.
2. **Отправьте минимальный запрос**\: передайте короткий текст как `input` и оставьте `stream` равным `false`; сначала убедитесь, что аутентификация, модель и параметры корректны.
3. **Прочитайте результат**\: запрос успешен, только если HTTP 2xx и `status` имеет значение `completed`; текст находится в элементе `output[].content[]`, где `type=output_text`.
4. **Проверьте**\: сверьте `error`, `incomplete_details` и фактическое содержимое, затем проверьте журнал использования.

```bash
API_URL="https://api.dwchainless.com/v1/responses"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "input": "用一句话解释机器学习。",
    "stream": false
  }'
```

Замените `PASTE_API_KEY_HERE` и `MODEL_ID` на реальные значения; после успешной проверки добавьте инструменты, структурированный вывод или включите потоковую передачу.

## Параметры запроса

Тип содержимого — `application/json`.

| Поле                                                  | Тип                      | Обязателен  | Описание                                                                                                                                                                                                               |
| ----------------------------------------------------- | ------------------------ | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                                                 | string                   | Да          | Обязателен у шлюза, модель с Responses.                                                                                                                                                                                |
| input                                                 | string / array           | При условии | Текст или список входных элементов; обычной генерации нужен ввод либо доступный предыдущий контекст.                                                                                                                   |
| input\[].role                                         | string                   | При условии | Роль\: user, assistant, system или developer.                                                                                                                                                                          |
| input\[].content\[].type                              | string                   | При условии | Типизированные input\_text, input\_image, input\_file и другие.                                                                                                                                                        |
| input\[].content\[].text                              | string                   | При условии | Текст input\_text.                                                                                                                                                                                                     |
| input\[].content\[].image\_url                        | string                   | При условии | URL или data URL изображения input\_image.                                                                                                                                                                             |
| input\[].content\[].file\_data / file\_url / file\_id | string                   | При условии | Один источник файла input\_file; см. понимание файлов.                                                                                                                                                                 |
| instructions                                          | string                   | Нет         | Приоритетные инструкции; при previous\_response\_id нужные инструкции передавайте снова.                                                                                                                               |
| max\_output\_tokens                                   | integer                  | Нет         | Лимит всех выходных токенов, включая рассуждения.                                                                                                                                                                      |
| stream                                                | boolean                  | Нет         | true возвращает типизированные события SSE.                                                                                                                                                                            |
| previous\_response\_id                                | string                   | Нет         | ID предыдущего ответа; требует сохраненного доступного контекста провайдера. Не вместе с conversation.                                                                                                                 |
| conversation                                          | string / object          | Нет         | Объект или ID разговора; нельзя сочетать с previous\_response\_id. Доступность зависит от канала.                                                                                                                      |
| store                                                 | boolean                  | Нет         | Просит провайдера сохранить ответ, не управляет журналами шлюза.                                                                                                                                                       |
| tools / tool\_choice                                  | array / string or object | Нет         | Функции, встроенные инструменты и правила выбора.                                                                                                                                                                      |
| parallel\_tool\_calls                                 | boolean                  | Нет         | Разрешение нескольких функций в одном ответе.                                                                                                                                                                          |
| reasoning                                             | object                   | Нет         | effort/summary у моделей рассуждений; допустимые значения зависят от модели.                                                                                                                                           |
| text.format                                           | object                   | Нет         | Формат текста, например type=json\_schema; отличается от Chat response\_format.                                                                                                                                        |
| temperature / top\_p                                  | number                   | Нет         | Сэмплирование при поддержке.                                                                                                                                                                                           |
| truncation                                            | string                   | Нет         | Объявлен устаревшим OpenAI; предпочтите context\_management. disabled (по умолчанию) возвращает ошибку при переполнении, auto разрешает отбросить часть контекста. Поддержка шлюзом зависит от фактического поведения. |
| include                                               | array                    | Нет         | Дополнительные данные, например reasoning.encrypted\_content или web\_search\_call.action.sources.                                                                                                                     |
| metadata                                              | object                   | Нет         | Метаданные приложения, не хранилище чувствительных данных.                                                                                                                                                             |

Не заданные необязательные поля опускайте. `stop`, `enable_thinking` и подобные расширения не входят в стандарт OpenAI Responses. `reasoning_content` также не стандартный выход\: рассуждения — отдельные reasoning-элементы без обещания раскрыть внутреннюю цепочку мыслей модели.

### Пример запроса

```json
{
  "model": "MODEL_ID",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "用一句话解释什么是机器学习。"
        }
      ]
    }
  ],
  "max_output_tokens": 256,
  "stream": false
}
```

## Ответ

Успех без потока — HTTP 200. Основные поля ниже; необязательные состояния могут быть null.

| Поле                                                 | Тип              | Описание                                                                                                                      |
| ---------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| id / object                                          | string           | ID ответа; object=response.                                                                                                   |
| created\_at / model                                  | integer / string | Время Unix в секундах и модель.                                                                                               |
| status                                               | string           | completed, incomplete, failed, queued, in\_progress или cancelled; эти состояния возможны и в потоковых, и в фоновых ответах. |
| output\[]                                            | array            | Типизированные message, reasoning, function\_call, web\_search\_call и другие\: нельзя фиксировать output\[0].                |
| output\[].type / id / status                         | string           | Тип элемента, ID и статус при наличии.                                                                                        |
| output\[].role                                       | string           | У сообщения обычно assistant.                                                                                                 |
| output\[].content\[]                                 | array            | Содержимое сообщения\: текст output\_text, отказ refusal.                                                                     |
| output\[].content\[].text / annotations              | string / array   | Текст и аннотации, включая ссылки.                                                                                            |
| output\[].call\_id / name / arguments                | string           | ID связи, имя функции и JSON-строка аргументов function\_call.                                                                |
| error                                                | object / null    | Ошибка; при успехе обычно null.                                                                                               |
| incomplete\_details                                  | object / null    | Причина неполноты, например max\_output\_tokens; не считать полным успехом.                                                   |
| usage.input\_tokens / output\_tokens / total\_tokens | integer          | Входные, выходные и общие токены.                                                                                             |
| usage.\*\_tokens\_details                            | object           | Необязательные детали кеша и рассуждений.                                                                                     |

```json
{
  "id": "resp_example",
  "object": "response",
  "created_at": 1760000000,
  "model": "MODEL_ID",
  "status": "completed",
  "error": null,
  "incomplete_details": null,
  "output": [
    {
      "id": "msg_example",
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "机器学习让计算机从数据中学习规律，用于预测和决策。",
          "annotations": []
        }
      ]
    }
  ],
  "usage": {
    "input_tokens": 18,
    "output_tokens": 22,
    "total_tokens": 40
  }
}
```

Для получения текста перебирайте элементы `output` типа `type=message`, затем в их `content` выбирайте элементы `type=output_text` и объединяйте text. Свойство SDK `output_text` — удобная агрегация, не обязательное поле сырого REST JSON.

### Потоковый ответ

При stream=true разбирайте SSE `event` и `data`\: response.created создает ответ; response.output\_text.delta добавляет текст; output\_item.added/done управляют элементами; function\_call\_arguments.delta собирает аргументы. Полный успех только после response.completed и проверки response.status. failed, incomplete и error обрабатывайте отдельно; EOF не означает успех.

```text
event: response.output_text.delta
data: {"type":"response.output_text.delta","item_id":"msg_example","output_index":0,"content_index":0,"delta":"机器学习","sequence_number":3}

event: response.completed
data: {"type":"response.completed","response":{"id":"resp_example","object":"response","status":"completed","output":[]},"sequence_number":12}
```

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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
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
      if (!process.env.SIMIROUTER_API_KEY) throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        input: [
          {
            role: 'user',
            content: [
              {
                type: 'input_text',
                text: '用一句话解释什么是机器学习。',
              },
            ],
          },
        ],
        max_output_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/responses';
      const response = await fetch(base + endpoint, {
        method: 'POST',
        headers: {
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
    : "${SIMIROUTER_MODEL:?请设置 SIMIROUTER_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
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
      "input": [
        {
          "role": "user",
          "content": [
            {
              "type": "input_text",
              "text": "用一句话解释什么是机器学习。"
            }
          ]
        }
      ],
      "max_output_tokens": 256,
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

Ошибка OpenAI обычно содержит `error.message`, `error.type`, `error.param`, `error.code`; `param` и `code` могут быть `null`; поля необязательны и могут отличаться от HTTP-статуса. Шлюз может отказать до провайдера. Даже при 200 проверяйте status/error/incomplete\_details; событие ошибки SSE не меняет уже отправленный HTTP-код.

Длинные ответы и потоковые запросы могут длиться от десятков секунд до нескольких минут; задайте достаточный тайм-аут клиента и при обрыве потока оценивайте полученные фрагменты и причину завершения, а не отправляйте запрос повторно автоматически. При 429 и 5xx сначала проверьте тело ответа и журнал использования; при отказе по политике содержимого измените запрос или входные данные, а не повторяйте запрос без изменений.

## Официальные материалы

* [OpenAI Responses API](https\://developers.openai.com/api/reference/resources/responses/methods/create)
* [OpenAI\: потоковые события](https\://developers.openai.com/api/docs/guides/streaming-responses)
* [OpenAI\: состояние диалога](https\://developers.openai.com/api/docs/guides/conversation-state)
* [OpenAI\: фоновый режим](https\://developers.openai.com/api/docs/guides/background)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)