# Генерация текста Gemini

## Описание интерфейса

`POST /v1beta/models/{model}:generateContent` принимает Gemini contents/parts и возвращает полный GenerateContentResponse без потока. Формат отличается от OpenAI messages и input.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $SIMIROUTER_API_KEY`. Официальный Google доступен по `https://generativelanguage.googleapis.com`, обычно с `x-goog-api-key: $GEMINI_API_KEY`, а не Bearer-ключом шлюза. Выберите доступную модель с нужными возможностями.

## Быстрый старт

1. **Подготовьте конфигурацию**\: создайте ключ в разделе Управление API-ключами и скопируйте полный ID модели с поддержкой generateContent из раздела Модели и цены.
2. **Отправьте минимальный запрос**\: укажите ID модели прямо в пути (без префикса `models/`) и задайте небольшое значение `generationConfig.maxOutputTokens`.
3. **Прочитайте результат**\: запрос успешен, только если HTTP 2xx и `candidates[]` не пуст; текст обычно находится в `candidates[0].content.parts[].text`.
4. **Проверьте**\: сверьте `finishReason` и `promptFeedback`, затем проверьте журнал использования.

```bash
API_URL="https://api.dwchainless.com/v1beta/models/MODEL_ID:generateContent"
API_KEY="PASTE_API_KEY_HERE"
curl "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{"role": "user", "parts": [{"text": "用一句话解释机器学习。"}]}],
    "generationConfig": {"maxOutputTokens": 256}
  }'
```

Замените `PASTE_API_KEY_HERE` и `MODEL_ID` в пути на реальные значения; для потоковой передачи используйте `streamGenerateContent?alt=sse`.

## Параметры запроса

Тело JSON. Поля REST в lowerCamelCase\: не копируйте snake\_case Python SDK механически.

| Поле                                       | Тип              | Обязателен  | Описание                                                                                |
| ------------------------------------------ | ---------------- | ----------- | --------------------------------------------------------------------------------------- |
| model (в пути)                             | string           | Да          | ID без префикса models/; полное имя ресурса models/\{model}.                            |
| contents                                   | array            | Да          | История и текущие сообщения по порядку.                                                 |
| contents\[].role                           | string           | Нет         | user или model, явно для нескольких ходов.                                              |
| contents\[].parts                          | array            | Да          | Части сообщения, минимум одна.                                                          |
| parts\[].text                              | string           | При условии | Текстовая часть; для медиа inlineData или fileData.                                     |
| systemInstruction.parts\[].text            | string           | Нет         | Системная инструкция, не role=system.                                                   |
| generationConfig.maxOutputTokens           | integer          | Нет         | Лимит генерации с учетом правил токенов рассуждений модели.                             |
| generationConfig.responseMimeType          | string           | Нет         | application/json для структурированного ответа при поддержке модели.                    |
| generationConfig.responseJsonSchema        | object           | Нет         | JSON Schema ответа, обычно вместе с application/json.                                   |
| generationConfig.temperature / topP / topK | number / integer | Нет         | Только поддерживающие модели\: не переносите фиксированные настройки между поколениями. |
| generationConfig.stopSequences             | array            | Нет         | Стоп-строки при поддержке модели.                                                       |
| safetySettings                             | array            | Нет         | Категории и пороги безопасности не отключают все защитные механизмы любой модели.       |
| tools / toolConfig                         | array / object   | Нет         | Инструменты и конфигурация\: поиск Google, функции и другие.                            |

### Пример запроса

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "用一句话解释机器学习。"
        }
      ]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 256
  }
}
```

Для диалога чередуйте role=user/model; последний элемент — текущий вопрос. Сервер не сохраняет историю автоматически из прежнего HTTP-соединения.

## Ответ

| Поле                                  | Тип            | Описание                                                                                            |
| ------------------------------------- | -------------- | --------------------------------------------------------------------------------------------------- |
| candidates\[]                         | array          | Кандидаты\: при блокировке могут отсутствовать.                                                     |
| candidates\[].index                   | integer        | Индекс кандидата.                                                                                   |
| candidates\[].content.role / parts\[] | string / array | Роль и части результата; текст обычно в parts\[].text.                                              |
| candidates\[].finishReason            | string         | STOP — завершение, MAX\_TOKENS — лимит; SAFETY, RECITATION и другие причины обрабатывайте отдельно. |
| candidates\[].safetyRatings           | array          | Необязательная оценка безопасности.                                                                 |
| candidates\[].groundingMetadata       | object         | Источники и ссылки при использовании grounding, например поиска.                                    |
| promptFeedback.blockReason            | string         | Причина блокировки ввода, кандидатов может не быть.                                                 |
| usageMetadata.promptTokenCount        | integer        | Входные токены.                                                                                     |
| usageMetadata.candidatesTokenCount    | integer        | Выходные токены кандидатов.                                                                         |
| usageMetadata.thoughtsTokenCount      | integer        | Необязательные токены рассуждений, не отображаемый текст.                                           |
| usageMetadata.totalTokenCount         | integer        | Всего токенов, включая возможные инструменты и рассуждения.                                         |
| modelVersion / responseId             | string         | Необязательные версия модели и ID ответа.                                                           |

```json
{
  "candidates": [
    {
      "index": 0,
      "content": {
        "role": "model",
        "parts": [
          {
            "text": "机器学习让计算机通过数据学习规律并完成预测。"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 12,
    "candidatesTokenCount": 20,
    "totalTokenCount": 32
  }
}
```

### Потоковый ответ

Замените путь на `/v1beta/models/{model}:streamGenerateContent?alt=sse` без изменения тела. Разбирайте GenerateContentResponse из data и объединяйте текст по candidate.index; не ждите OpenAI-маркер `[DONE]`. Проверяйте finishReason, promptFeedback и расход. SSE — части одной генерации, не фоновая задача и не параллельные запросы.

## Примеры вызова

Задайте `SIMIROUTER_API_KEY`, `SIMIROUTER_GEMINI_MODEL`; `SIMIROUTER_BASE_URL` переопределяет адрес шлюза по умолчанию; не добавляйте в конец `/v1`. Примеры Python 3, Node.js 18+ и Go используют только стандартную библиотеку; JSON в примере curl безопасно формируется Python 3.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json, os, sys, urllib.request, urllib.error, urllib.parse
    if not os.environ.get("SIMIROUTER_API_KEY"): raise RuntimeError("请设置 SIMIROUTER_API_KEY")
    if not os.environ.get("SIMIROUTER_GEMINI_MODEL"): raise RuntimeError("请设置 SIMIROUTER_GEMINI_MODEL")
    base = os.environ.get("SIMIROUTER_BASE_URL", "https://api.dwchainless.com").rstrip("/")
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
    path = "/v1beta/models/" + urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe="") + ":generateContent"
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
      if (!process.env.SIMIROUTER_GEMINI_MODEL)
        throw new Error('请设置 SIMIROUTER_GEMINI_MODEL');
      const base = (
        process.env.SIMIROUTER_BASE_URL || 'https://api.dwchainless.com'
      ).replace(/\/$/, '');
      const body = {
        contents: [
          {
            role: 'user',
            parts: [
              {
                text: '用一句话解释机器学习。',
              },
            ],
          },
        ],
        generationConfig: {
          maxOutputTokens: 256,
        },
      };
      const endpoint = `/v1beta/models/${encodeURIComponent(process.env.SIMIROUTER_GEMINI_MODEL)}:generateContent`;
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
    : "${SIMIROUTER_GEMINI_MODEL:?请设置 SIMIROUTER_GEMINI_MODEL}"
    BASE_URL="${SIMIROUTER_BASE_URL:-https://api.dwchainless.com}"
    BODY=$(python3 - <<'PYBODY'
    import json, os
    body = json.loads(r'''{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }''')
    print(json.dumps(body, ensure_ascii=False))
    PYBODY
    )
    MODEL_PATH=$(python3 -c 'import os, urllib.parse; print(urllib.parse.quote(os.environ["SIMIROUTER_GEMINI_MODEL"], safe=""))')
    curl "${BASE_URL%/}/v1beta/models/${MODEL_PATH}:generateContent" \
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
      model := os.Getenv("SIMIROUTER_GEMINI_MODEL"); if model == "" { log.Fatal("请设置 SIMIROUTER_GEMINI_MODEL") }
      base := strings.TrimRight(os.Getenv("SIMIROUTER_BASE_URL"), "/"); if base == "" { base = "https://api.dwchainless.com" }
      var body map[string]any
      if err := json.Unmarshal([]byte(`{
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "用一句话解释机器学习。"
            }
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 256
      }
    }`), &body); err != nil { log.Fatal(err) }
      endpoint := "/v1beta/models/" + model + ":generateContent"
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

| Статус HTTP | Значение или тип ошибки провайдера | Действие                                                                    |
| ----------- | ---------------------------------- | --------------------------------------------------------------------------- |
| 400         | `INVALID_ARGUMENT` и другие        | Проверьте JSON, параметры модели, MIME и длину ввода.                       |
| 403         | `PERMISSION_DENIED`                | Проверьте ключ, права проекта, регион и платежные ограничения.              |
| 404         | `NOT_FOUND`                        | Проверьте имя модели и версию API.                                          |
| 429         | `RESOURCE_EXHAUSTED`               | Проверьте частоту и квоту; для повторяемых ошибок ограничьте число попыток. |
| 500 / 503   | `INTERNAL` / `UNAVAILABLE`         | Сохраните ID запроса и повторите ограниченно либо позже.                    |

Ошибка Google содержит `error.code` (HTTP-число), `error.status` (имя перечисления), `error.message`; возможны также `details`. Шлюз может вернуть ошибку аутентификации, маршрута или квоты до провайдера. HTTP 200 с пустыми candidates или finishReason=SAFETY может означать блокировку содержимого, а не сеть.

Длинные ответы и потоковые запросы могут длиться от десятков секунд до нескольких минут; задайте достаточный тайм-аут клиента и при обрыве потока оценивайте полученные фрагменты и причину завершения, а не отправляйте запрос повторно автоматически. При 429 и 5xx сначала проверьте тело ответа и журнал использования; при отказе по политике содержимого измените запрос или входные данные, а не повторяйте запрос без изменений.

## Официальные материалы

* [Google GenerateContent API](https\://ai.google.dev/api/generate-content)
* [Google\: генерация текста](https\://ai.google.dev/gemini-api/docs/text-generation)
* [Google\: диагностика ошибок](https\://ai.google.dev/gemini-api/docs/troubleshooting)