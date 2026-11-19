# Понимание изображений

## Описание интерфейса

`POST /v1/chat/completions` сочетает вопрос и изображение в одном user и возвращает текст анализа. Понимание не является генерацией или редактированием.

Адрес подключения — `https://api.dwchainless.com`, заголовок — `Authorization: Bearer $API_KEY`. Прямой OpenAI — `https://api.openai.com`; также Bearer, но нужен ключ OpenAI. Выберите доступную модель с поддержкой требуемой функции.

Изображение передается доступным HTTPS URL или data URL с реальными байтами. Здесь используется доступный HTTPS URL изображения.

## Параметры запроса

| Поле                        | Тип     | Обязателен  | Описание                                                                   |
| --------------------------- | ------- | ----------- | -------------------------------------------------------------------------- |
| model                       | string  | Да          | Чат-модель с визуальным вводом.                                            |
| messages\[].role            | string  | Да          | Для сообщения с изображением используется user.                            |
| messages\[].content         | array   | Да          | Как минимум вопрос и элемент изображения.                                  |
| content\[].type=text / text | string  | При условии | Элемент с текстом вопроса.                                                 |
| content\[].type=image\_url  | string  | При условии | Объявляет элемент изображения.                                             |
| image\_url.url              | string  | Да          | HTTPS URL или data\:image/\{format};base64,...; локальный путь недопустим. |
| image\_url.detail           | string  | Нет         | Поддерживаемая моделью детализация, например auto, low или high.           |
| max\_completion\_tokens     | integer | Нет         | Лимит выходных токенов.                                                    |
| stream                      | boolean | Нет         | true возвращает SSE Chat.                                                  |

Для PNG, JPEG, WebP и других форматов указывайте правильный MIME. Соблюдайте ограничения модели по числу изображений, пикселям и размеру запроса. Нельзя просто обозначить GIF-анимацию, видео или произвольные байты как image/png.

### Структура запроса

```json
{
  "model": "gpt-5.5",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "描述图片中的主要物体，并指出无法确定的细节。"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/png;base64,BASE64_IMAGE_BYTES",
            "detail": "auto"
          }
        }
      ]
    }
  ],
  "max_completion_tokens": 512,
  "stream": false
}
```

## Ответ

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
  "id": "chatcmpl_vision_example",
  "object": "chat.completion",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "图中可见一张桌子和一个杯子，杯内物品无法确认。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 280,
    "completion_tokens": 30,
    "total_tokens": 310
  }
}
```

Для нескольких изображений добавляйте элементы image\_url; при сравнении укажите в тексте порядок и цель. В потоке объединяйте Chat delta.content. Для мелкого текста, точного подсчёта, идентификации и важных решений не полагайтесь только на зрение модели.

## Примеры вызова

Укажите `API_URL` и `API_KEY` в начале кода; в примерах используется `gpt-5.5`. `API_URL` — полный URL запроса, по умолчанию адрес шлюза `https://api.dwchainless.com`. `IMAGE_URL` — HTTPS-URL изображения, доступный серверу. Примеры используют только стандартные библиотеки, отправляют один запрос и выводят полученный JSON; изображение автоматически не сохраняется.

<Tabs items={["Python","Node.js","curl","Go"]}>
  <Tab value="Python">
    ```python
    import json
    import urllib.request

    API_URL = "https://api.dwchainless.com/v1/chat/completions"
    API_KEY = "PASTE_API_KEY_HERE"
    body = {
      "model": "gpt-5.5",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "描述图片中的主要物体。"
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "https://example.com/reference.png"
              }
            }
          ]
        }
      ]
    }
    request = urllib.request.Request(
        API_URL,
        data=json.dumps(body).encode(),
        method="POST",
        headers={
            "Authorization": "Bearer " + API_KEY,
            "Content-Type": "application/json",
        },
    )
    print(urllib.request.urlopen(request).read().decode())
    ```
  </Tab>

  <Tab value="Node.js">
    ```javascript
    const API_URL = 'https://api.dwchainless.com/v1/chat/completions';
    const API_KEY = 'PASTE_API_KEY_HERE';
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-5.5',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: '描述图片中的主要物体。'
              },
              {
                type: 'image_url',
                image_url: {
                  url: 'https://example.com/reference.png'
                }
              }
            ]
          }
        ]
      })
    });
    console.log(await response.text());
    ```
  </Tab>

  <Tab value="curl">
    ```bash
    API_URL="https://api.dwchainless.com/v1/chat/completions"
    API_KEY="PASTE_API_KEY_HERE"
    curl "$API_URL" \
      -H "Authorization: Bearer $API_KEY" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "gpt-5.5",
        "messages": [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "描述图片中的主要物体。"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "https://example.com/reference.png"
                }
              }
            ]
          }
        ]
      }'
    ```
  </Tab>

  <Tab value="Go">
    ```go
    package main

    import ("bytes"; "fmt"; "io"; "net/http")

    func main() {
        apiURL := "https://api.dwchainless.com/v1/chat/completions"
        apiKey := "PASTE_API_KEY_HERE"
        body := []byte(`{
            "model": "gpt-5.5",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "描述图片中的主要物体。"
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": "https://example.com/reference.png"
                            }
                        }
                    ]
                }
            ]
        }`)
        request, _ := http.NewRequest("POST", apiURL, bytes.NewReader(body))
        request.Header.Set("Authorization", "Bearer "+apiKey)
        request.Header.Set("Content-Type", "application/json")
        response, _ := http.DefaultClient.Do(request)
        defer response.Body.Close()
        result, _ := io.ReadAll(response.Body)
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

## Официальные материалы

* [Изображения и зрение OpenAI](https\://developers.openai.com/api/docs/guides/images-vision)
* [OpenAI Chat Completions](https\://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)
* [OpenAI\: обработка ошибок](https\://developers.openai.com/api/docs/guides/error-codes)