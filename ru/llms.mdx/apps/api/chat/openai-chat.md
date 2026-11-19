# Chat Completions

## Описание интерфейса

`POST /v1/chat/completions` генерирует ответ по истории сообщений. Подходит существующим клиентам Chat Completions и диалогам с явно передаваемой историей.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

## Быстрый старт

1. **Подготовьте конфигурацию**\: создайте ключ в разделе Управление API-ключами и скопируйте полный ID модели с поддержкой Chat Completions из раздела Модели и цены.
2. **Отправьте минимальный запрос**\: передайте одно сообщение пользователя и оставьте `stream` равным `false`; сначала убедитесь, что аутентификация, модель и параметры корректны.
3. **Прочитайте результат**\: запрос успешен, только если HTTP 2xx и `choices[]` не пуст; текст находится в `choices[0].message.content`.
4. **Проверьте**\: сверьте `finish_reason`, отказы и фактическое содержимое, затем проверьте журнал использования.

```bash
API_URL="https://api.dwchainless.com/v1/chat/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "messages": [{"role": "user", "content": "用一句话解释机器学习。"}],
    "stream": false
  }'
```

Замените `PASTE_API_KEY_HERE` и `MODEL_ID` на реальные значения; после успешной проверки добавьте историю диалога, инструменты или включите потоковую передачу.

Если проект уже использует OpenAI SDK, укажите в `baseURL` адрес `https://api.dwchainless.com/v1` и ключ SimiRouter; имена методов и параметры не меняются. См. [Скрипты вызова API](/simidoc/ru/apps/api-script).

## Параметры запроса

Тип содержимого — `application/json`. Неиспользуемые поля опускайте, а не отправляйте пустые строки, 0, пустые объекты и null.

| Поле                                   | Тип                      | Обязателен  | Описание                                                                               |
| -------------------------------------- | ------------------------ | ----------- | -------------------------------------------------------------------------------------- |
| model                                  | string                   | Да          | ID модели.                                                                             |
| messages                               | array                    | Да          | Минимум одно сообщение; нужная история передается по порядку.                          |
| messages\[].role                       | string                   | Да          | `developer`, `system`, `user`, `assistant`, `tool`; допустимые роли зависят от модели. |
| messages\[].content                    | string / array / null    | При условии | Текст или массив частей; при `tool_calls` у assistant можно опустить или указать null. |
| messages\[].content\[].type            | string                   | При условии | Тип соответствующего содержимого\: `text`, `image_url`, `input_audio` или `file`.      |
| messages\[].content\[].text            | string                   | При условии | Текст при type=text.                                                                   |
| messages\[].content\[].image\_url      | object                   | При условии | При type=image\_url укажите `url`, необязателен `detail`; см. понимание изображений.   |
| messages\[].tool\_calls                | array                    | Нет         | Запрошенные функции\: id, type=function, function.name, function.arguments.            |
| messages\[].tool\_call\_id             | string                   | При условии | Обязателен для role=tool\: ID вызова инструмента от assistant.                         |
| max\_completion\_tokens                | integer                  | Нет         | Лимит генерации, включая видимый ответ и рассуждения.                                  |
| stream                                 | boolean                  | Нет         | true возвращает SSE; по умолчанию без потока.                                          |
| stream\_options.include\_usage         | boolean                  | Нет         | Запрос итогового блока usage до завершения потока, требуется stream.                   |
| temperature / top\_p                   | number                   | Нет         | Сэмплирование только при поддержке модели; обычно меняйте одно поле.                   |
| stop                                   | string / array           | Нет         | Стоп-последовательности, только поддерживаемые модели.                                 |
| n                                      | integer                  | Нет         | Число кандидатов, не параллельных запросов.                                            |
| tools / tool\_choice                   | array / string or object | Нет         | Функции и выбор инструментов; см. вызовы инструментов.                                 |
| parallel\_tool\_calls                  | boolean                  | Нет         | Разрешает несколько вызовов функций в ответе, но не выполняет их за приложение.        |
| response\_format                       | object                   | Нет         | Структурированный вывод\: json\_schema или json\_object при поддержке.                 |
| reasoning\_effort                      | string                   | Нет         | Глубина рассуждений\: значения зависят от модели.                                      |
| presence\_penalty / frequency\_penalty | number                   | Нет         | Штрафы повторения от -2 до 2 при поддержке модели.                                     |
| logprobs / top\_logprobs               | boolean / integer        | Нет         | Вероятности токенов и число альтернатив при поддержке.                                 |

`max_tokens` — старый параметр, замененный `max_completion_tokens`; модели не из серии o по-прежнему могут его принимать, а `/v1/completions` использует только `max_tokens`; не отправляйте оба в новой интеграции. `video_url`, `reasoning_content` — расширения отдельных совместимых моделей, не общий стандарт OpenAI Chat Completions.

### Пример запроса

```json
{
  "model": "MODEL_ID",
  "messages": [
    {
      "role": "user",
      "content": "用一句话解释什么是机器学习。"
    }
  ],
  "max_completion_tokens": 256,
  "stream": false
}
```

## Ответ

Успешный непотоковый ответ\: HTTP 200 JSON. ID и числа токенов ниже иллюстрируют структуру.

| Поле                           | Тип              | Описание                                                                                          |
| ------------------------------ | ---------------- | ------------------------------------------------------------------------------------------------- |
| id / object                    | string           | ID ответа; object=chat.completion.                                                                |
| created / model                | integer / string | Время Unix в секундах и модель ответа.                                                            |
| choices\[]                     | array            | Кандидаты, позиция каждого задается index.                                                        |
| choices\[].message.role        | string           | assistant.                                                                                        |
| choices\[].message.content     | string / null    | Текст; при инструментах или отказе может отсутствовать, это не обязательно ошибка запроса.        |
| choices\[].message.tool\_calls | array            | Функции для выполнения приложением. arguments — JSON-строка, которую нужно разобрать и проверить. |
| choices\[].message.refusal     | string / null    | Отказ, если имеется.                                                                              |
| choices\[].finish\_reason      | string           | stop — конец, length — лимит, tool\_calls — вызов инструмента, content\_filter — фильтрация.      |
| usage.prompt\_tokens           | integer          | Входные токены.                                                                                   |
| usage.completion\_tokens       | integer          | Сгенерированные токены, включая возможные рассуждения.                                            |
| usage.total\_tokens            | integer          | Сумма входных и сгенерированных токенов.                                                          |
| usage.\*\_tokens\_details      | object           | Необязательные детали расхода\: cached\_tokens, reasoning\_tokens.                                |

```json
{
  "id": "chatcmpl_example",
  "object": "chat.completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "机器学习是让计算机从数据中学习规律并用于预测或决策的方法。",
        "refusal": null
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 18,
    "completion_tokens": 24,
    "total_tokens": 42
  }
}
```

### Потоковый ответ

Задайте `stream: true`, чтобы получить `text/event-stream`. Разбирайте JSON строк `data:` по `choices[].index` и объединяйте `delta.content`; аргументы функций объединяйте по индексу инструмента `delta.tool_calls`. Маркер завершения — `data: [DONE]`, не JSON. При include\_usage итоговый choices может быть пустым, а usage промежуточных блоков — null. Разрыв без маркера означает неполный ответ, а не успех.

```text
data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"content":"机器学习"},"finish_reason":null}]}

data: {"id":"chatcmpl_example","object":"chat.completion.chunk","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
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
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    path = '/v1/chat/completions'
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
      if (!process.env.SIMIROUTER_API_KEY)
        throw new Error('请设置 SIMIROUTER_API_KEY');
      if (!process.env.SIMIROUTER_MODEL) throw new Error('请设置 SIMIROUTER_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        messages: [
          {
            role: 'user',
            content: '用一句话解释什么是机器学习。',
          },
        ],
        max_completion_tokens: 256,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_MODEL;
      const endpoint = '/v1/chat/completions';
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
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/chat/completions" \
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
      "messages": [
        {
          "role": "user",
          "content": "用一句话解释什么是机器学习。"
        }
      ],
      "max_completion_tokens": 256,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/chat/completions"
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

### Использование OpenAI SDK

Если установлен официальный SDK `openai`, писать HTTP-запросы вручную не нужно\: укажите в `baseURL` адрес шлюза, чтобы использовать официальные типы, повторы и разбор потока. Установка\: `pip install openai` или `npm install openai`.

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://api.dwchainless.com/v1",
    api_key=os.environ["SIMIROUTER_API_KEY"],
)
response = client.chat.completions.create(
    model=os.environ["SIMIROUTER_MODEL"],
    messages=[{"role": "user", "content": "用一句话解释什么是机器学习。"}],
)
print(response.choices[0].message.content)
```

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'https://api.dwchainless.com/v1',
  apiKey: process.env.SIMIROUTER_API_KEY,
});
const response = await client.chat.completions.create({
  model: process.env.SIMIROUTER_MODEL,
  messages: [{ role: 'user', content: '用一句话解释什么是机器学习。' }],
});
console.log(response.choices[0].message.content);
```

## Коды ошибок

| Статус HTTP | Значение или тип ошибки провайдера       | Действие                                                                          |
| ----------- | ---------------------------------------- | --------------------------------------------------------------------------------- |
| 400         | Неверный запрос                          | Проверьте обязательные поля, JSON, параметры модели и длину контекста.            |
| 401         | Ошибка аутентификации                    | Проверьте наличие, действительность и принадлежность ключа.                       |
| 403 / 404   | Нет доступа / ресурс не найден           | Проверьте права модели, ID ресурса и URL.                                         |
| 429         | Ограничение частоты или квоты            | Различайте лимит скорости и нехватку квоты по ответу; повтор не восполняет квоту. |
| 500 / 503   | Ошибка сервиса / временная недоступность | Сохраните ID и ограниченно повторите временные сбои с задержкой.                  |

Ошибка OpenAI обычно содержит `error.message`, `error.type`, `error.param`, `error.code`; `param` и `code` могут быть `null`; поля необязательны и не обязаны равняться HTTP-статусу. Шлюз может отказать до провайдера; по числу HTTP нельзя установить источник ошибки. При 200 проверяйте finish\_reason, отказ и целостность потока; length/content\_filter не являются HTTP-ошибками.

Длинные ответы и потоковые запросы могут длиться от десятков секунд до нескольких минут; задайте достаточный тайм-аут клиента и при обрыве потока оценивайте полученные фрагменты и причину завершения, а не отправляйте запрос повторно автоматически. При 429 и 5xx сначала проверьте тело ответа и журнал использования; при отказе по политике содержимого измените запрос или входные данные, а не повторяйте запрос без изменений.

### Примеры ответов с ошибкой

Ответ с ошибкой обычно содержит объект `error` в формате OpenAI, где `param` и `code` могут быть `null`. Примеры ниже условны; текст зависит от шлюза или провайдера, поэтому не сравнивайте его по строке.

```json
{
  "error": {
    "message": "You didn't provide an API key.",
    "type": "invalid_request_error",
    "param": null,
    "code": "invalid_api_key"
  }
}
```

```json
{
  "error": {
    "message": "Rate limit reached for requests.",
    "type": "rate_limit_error",
    "param": null,
    "code": "rate_limit_exceeded"
  }
}
```

## Частые вопросы

**Что делать при 401 или `Invalid token`?**
Проверьте, что заголовок — `Authorization: Bearer <Key>`, ключ принадлежит этому шлюзу и не отозван, а также что вы не вставили пароль от аккаунта или ключ провайдера.

**Почему возвращается 404 или «модель не найдена»?**
`model` должен быть полным идентификатором из Каталога и цен, а группе вашего ключа должен быть разрешён доступ. Пользователям SDK стоит также проверить, что в `baseURL` есть `/v1`.

**Стоит ли повторять запрос при 429?**
Сначала прочитайте тело ответа. При ограничении частоты повторяйте с экспоненциальной задержкой и джиттером; при исчерпанной квоте или балансе повтор не поможет — пополните счёт или измените лимит.

**Когда потоковый ответ считается полным?**
Только после `data: [DONE]` и последнего блока с `finish_reason`. Если соединение оборвалось без маркера завершения, считайте ответ неполным и не отправляйте автоматически уже оплаченный запрос повторно.

**`max_tokens` или `max_completion_tokens`?**
Для Chat Completions используйте `max_completion_tokens`. `max_tokens` — устаревшее поле, его принимают только некоторые модели. Не отправляйте оба; `/v1/completions` по-прежнему использует только `max_tokens`.

**Почему temperature не действует?**
Некоторые reasoning-модели фиксируют сэмплирование или принимают только значения по умолчанию, а шлюз передаёт параметры провайдеру. Ориентируйтесь на документацию и ошибки модели, не считая, что все параметры OpenAI применимы.

## Официальные материалы

* [OpenAI Chat Completions API](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI\: генерация текста](https\://developers.openai.com/api/docs/guides/text)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)