# Устаревшее текстовое дополнение

## Описание интерфейса

`POST /v1/completions` принимает prompt и возвращает текст, без messages, инструментов и элементов Responses. Для новых проектов предпочтительны Chat Completions/Responses. Требуется поддерживающая этот протокол модель\: произвольный ID чата не подходит.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

## Быстрый старт

1. **Подготовьте конфигурацию**\: создайте ключ в разделе Управление API-ключами и скопируйте полный ID модели с поддержкой традиционных дополнений из раздела Модели и цены.
2. **Отправьте минимальный запрос**\: передайте один `prompt` и оставьте `stream` равным `false`; сначала убедитесь, что аутентификация, модель и параметры корректны.
3. **Прочитайте результат**\: запрос успешен, только если HTTP 2xx и `choices[]` не пуст; текст дополнения находится в `choices[0].text`.
4. **Проверьте**\: сверьте `finish_reason` и фактическое содержимое, затем проверьте журнал использования.

```bash
API_URL="https://api.dwchainless.com/v1/completions"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "MODEL_ID",
    "prompt": "请补全这句话：机器学习是",
    "max_tokens": 64,
    "stream": false
  }'
```

Замените `PASTE_API_KEY_HERE` и `MODEL_ID` на реальные значения; в новых проектах предпочитайте Chat Completions или Responses.

## Параметры запроса

Тело запроса JSON.

| Поле                                   | Тип            | Обязателен  | Описание                                                                                        |
| -------------------------------------- | -------------- | ----------- | ----------------------------------------------------------------------------------------------- |
| model                                  | string         | Да          | ID модели устаревших completions.                                                               |
| prompt                                 | string / array | При условии | Текст для дополнения; также допускаются массивы строк или ID токенов. Пример — строка.          |
| max\_tokens                            | integer        | Нет         | Максимум токенов генерации вместе с входом должен помещаться в контекст.                        |
| stream                                 | boolean        | Нет         | true возвращает SSE; по умолчанию false.                                                        |
| temperature / top\_p                   | number         | Нет         | Сэмплирование\: обычно меняйте только один параметр.                                            |
| n                                      | integer        | Нет         | Число дополнений для каждого prompt.                                                            |
| stop                                   | string / array | Нет         | До 4 стоп-строк; в ответ не включаются.                                                         |
| echo                                   | boolean        | Нет         | Включать ли исходный prompt в возвращаемый text.                                                |
| logprobs                               | integer        | Нет         | Логарифмы вероятностей альтернативных токенов, максимум 5.                                      |
| presence\_penalty / frequency\_penalty | number         | Нет         | Штрафы повторения от -2 до 2.                                                                   |
| suffix                                 | string         | Нет         | Только модели вставочного дополнения.                                                           |
| best\_of                               | integer        | Нет         | Сервер генерирует кандидатов и выбирает лучших; несовместимо со stream и увеличивает генерацию. |

### Пример запроса

```json
{
  "model": "MODEL_ID",
  "prompt": "请补全这句话：机器学习是",
  "max_tokens": 64,
  "stream": false
}
```

## Ответ

| Поле                                                      | Тип              | Описание                                      |
| --------------------------------------------------------- | ---------------- | --------------------------------------------- |
| id / object                                               | string           | ID дополнения; object=text\_completion.       |
| created / model                                           | integer / string | Unix-время в секундах и модель.               |
| choices\[].text                                           | string           | Текст дополнения, не message.content.         |
| choices\[].index                                          | integer          | Индекс кандидата.                             |
| choices\[].finish\_reason                                 | string           | stop, length или content\_filter.             |
| choices\[].logprobs                                       | object / null    | Вероятности токенов; без запроса обычно null. |
| usage.prompt\_tokens / completion\_tokens / total\_tokens | integer          | Входные, выходные и общие токены.             |

```json
{
  "id": "cmpl_example",
  "object": "text_completion",
  "created": 1760000000,
  "model": "MODEL_ID",
  "choices": [
    {
      "text": "一种从数据中学习规律的方法。",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 12,
    "completion_tokens": 14,
    "total_tokens": 26
  }
}
```

В потоке объединяйте choices\[].text до `[DONE]`; при нескольких prompt/кандидатах отдельно по index.

## Примеры вызова

Задайте `SIMIROUTER_API_KEY`, `SIMIROUTER_COMPLETION_MODEL`; `SIMIROUTER_BASE_URL` переопределяет адрес шлюза по умолчанию; не добавляйте в конец `/v1`. Примеры Python 3, Node.js 18+ и Go используют только стандартную библиотеку; JSON в примере curl безопасно формируется Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_COMPLETION_MODEL"): raise RuntimeError("请设置 SIMIROUTER_COMPLETION_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    path = '/v1/completions'
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
      if (!process.env.SIMIROUTER_COMPLETION_MODEL)
        throw new Error('请设置 SIMIROUTER_COMPLETION_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        model: 'MODEL_ID',
        prompt: '请补全这句话：机器学习是',
        max_tokens: 64,
        stream: false,
      };
      body.model = process.env.SIMIROUTER_COMPLETION_MODEL;
      const endpoint = '/v1/completions';
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
    : "${SIMIROUTER_COMPLETION_MODEL:?请设置 SIMIROUTER_COMPLETION_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }''')
    body["model"] = os.environ["SIMIROUTER_COMPLETION_MODEL"]
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    curl "${BASE_URL%/}/v1/completions" \
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
      model := os.Getenv("SIMIROUTER_COMPLETION_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_COMPLETION_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "model": "MODEL_ID",
      "prompt": "请补全这句话：机器学习是",
      "max_tokens": 64,
      "stream": false
    }`), &body); err != nil { log.Fatal(err) }
      body["model"] = model
      endpoint := "/v1/completions"
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

Ошибка OpenAI обычно содержит `error.message`, `error.type`, `error.param`, `error.code`; `param` и `code` могут быть `null`; поля могут отсутствовать, быть null или отличаться от HTTP-кода. Шлюз может вернуть ошибку до провайдера; одного HTTP-числа недостаточно для определения источника.

Длинные ответы и потоковые запросы могут длиться от десятков секунд до нескольких минут; задайте достаточный тайм-аут клиента и при обрыве потока оценивайте полученные фрагменты и причину завершения, а не отправляйте запрос повторно автоматически. При 429 и 5xx сначала проверьте тело ответа и журнал использования; при отказе по политике содержимого измените запрос или входные данные, а не повторяйте запрос без изменений.

## Официальные материалы

* [OpenAI Completions API](https\://developers.openai.com/api/reference/resources/completions/methods/create)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)