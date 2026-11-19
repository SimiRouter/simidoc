# Скрипты API

Отправьте сообщение через Chat Completions и прочитайте ответ модели. Примеры на четырех языках выполняют одно действие\: отправляют запрос к `POST /v1/chat/completions` в не потоковом режиме JSON, дожидаются полного ответа и выводят результат.

## Скрипты запросов изображений

В разделе [API изображений](/simidoc/ru/apps/api/images) можно выбрать протокол и найти примеры генерации, редактирования и сохранения.

## Подготовка ключа и модели

Сначала в разделе [Ключи API](https://api.dwchainless.com/keys) создайте ключ, затем в разделе [Каталог моделей](https://api.dwchainless.com/ru/pricing/) скопируйте полный идентификатор модели, доступной этому ключу. Примеры читают настройки из переменных окружения и не сохраняют ключ в файле.

* `SIMIROUTER_API_KEY`\: ключ API SimiRouter, обязателен.
* `SIMIROUTER_MODEL`\: полный идентификатор модели, обязателен.
* `SIMIROUTER_BASE_URL`\: необязательно; по умолчанию `https://api.dwchainless.com`. Это корневой адрес без `/v1`.

Настройте эти значения в локальном терминале или окружении платформы запуска. Не выводите ключ в публичные журналы. Реальные запросы API могут тарифицироваться.

## Прямая замена на OpenAI SDK

Если код уже использует официальный SDK OpenAI, замените только `baseURL` и `apiKey`, а имя модели укажите полным идентификатором SimiRouter. `baseURL` должен заканчиваться на `/v1`; имена методов, параметры и объекты ответа сохраняют форму OpenAI.

<Tabs items={["Python","Node.js"]}>
  <Tab value="Python">
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
  </Tab>

  <Tab value="Node.js">
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
  </Tab>
</Tabs>

Сначала установите официальный SDK\: `pip install openai` или `npm install openai`. SDK сам обрабатывает повторы, тайм-ауты и разбор SSE; клиентские опции вроде собственного тайм-аута и `max_retries` сохраняют семантику SDK, шлюз их не переписывает.

Шлюз отвечает по протоколу, совместимому с OpenAI; возможности по-прежнему зависят от выбранной модели. Если SDK возвращает `404`, проверьте, что `baseURL` не указывает на `https://api.dwchainless.com` без `/v1`.

## Запрос и ответ

| Параметр                         | Описание                                                                                                  |
| -------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Метод и путь                     | `POST /v1/chat/completions`                                                                               |
| Аутентификация                   | `Authorization: Bearer <API Key>`                                                                         |
| Тип содержимого                  | `application/json`                                                                                        |
| Обязательные параметры           | `model`, `messages`                                                                                       |
| Необязательные параметры примера | `max_completion_tokens: 256`, `stream: false`; необходима поддержка выбранной моделью                     |
| Успешный ответ                   | HTTP 200, `choices[].message.content` содержит текст ответа; `usage` отражает возвращенный расход токенов |
| Потоковый вызов                  | `stream: true` возвращает SSE\: ответ нельзя разбирать как один JSON                                      |

Полные параметры, вызовы инструментов, мультимодальный ввод и события SSE описаны в [Chat Completions](/simidoc/ru/apps/api/chat/openai-chat).

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

## Коды ошибок

| Статус HTTP | Частая причина                                                 | Действие                                                                                              |
| ----------- | -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| 400         | Неверный формат запроса или неподдерживаемые моделью параметры | Проверьте тело ошибки и удалите неподдерживаемые необязательные параметры                             |
| 401         | Ключ отсутствует, недействителен или указан неверно            | Проверьте переменные окружения; при необходимости создайте новый ключ                                 |
| 403         | Ограничения доступа к модели, группе или каналу                | Проверьте права ключа и учетной записи                                                                |
| 404         | Неверный путь или идентификатор модели                         | Проверьте, не продублирован ли `/v1`, и полный идентификатор модели                                   |
| 429         | Лимит частоты или квоты                                        | Сначала проверьте квоту и ограничения; используйте задержку согласно ошибке, без бесконечных повторов |
| 5xx         | Ошибка шлюза или вышестоящего сервиса                          | Сохраните обезличенное тело ошибки и ID запроса; перед повтором проверьте историю использования       |

Эти статусы служат отправной точкой диагностики; причину определяет ответ с ошибкой. Тайм-аут не доказывает, что модель не выполнила запрос. Не повторяйте запросы генерации без ограничения числа попыток.

## Другие возможности

* [Responses](/simidoc/ru/apps/api/chat/openai-responses)\: организация запроса через типизированные входные и выходные элементы.
* [Claude Messages](/simidoc/ru/apps/api/chat/claude) и [Gemini](/simidoc/ru/apps/api/chat/gemini-text)\: собственные структуры сообщений.
* [Создание изображения](/simidoc/ru/apps/api/images)\: генерация, редактирование и распознавание.
* [Аудио](/simidoc/ru/apps/api/audio)\: понимание аудио, синтез речи, транскрипция и перевод.
* [Видео](/simidoc/ru/apps/api/video)\: задачи генерации и понимание видео.
* [Интеграция аудио MiMo](/simidoc/ru/apps/api/audio/mimo-audio)\: синтез, транскрипция и работа с голосами MiMo.

## Официальные материалы

Описание полей протокола основано на [OpenAI Chat Completions API Reference](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create). Адрес и ключ SimiRouter отличаются от прямого подключения к OpenAI.